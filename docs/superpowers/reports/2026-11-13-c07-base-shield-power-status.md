# Report — N2159: BaseShield power.status live read (shield-projector / large-shield-projector) (C07)

Date: 2026-11-13. Batch: N2159 (single slice). Status: **DONE + PUSHED (targeted 4/4 OK, neighbours 92/92 OK, Godot proof GREEN, 9 keys, matches:true; full gate attempt 1 GREEN except Godot: Ran 5733, failures=110, skipped=5, 0 errors — all 110 Godot-absent asserts).**

## What changed

The next `power.status` consumer family after the N2158 force-projector slice: the BaseShield implementation — **shield-projector** (consumePower 5f, size 3, radius 200f default) and **large-shield-projector** (consumePower 5f, size 4, radius 400f, Blocks.java:2060). hasPower=true, update=true, solid=true, rebuildable=false, canPickup=true. Catalog confirms implementation BaseShield + consumePower 5.0 for both (content_registry.json).

BaseShield (BaseShield.java:18, `public class BaseShield extends Block{`) has NO placed-buildings driver at all — shield-projector / large-shield-projector would shield as if power.status were 1.0. N2159 is the BaseShield family's live read — the same proven N2145–N2158 pure-row pattern, one new file over. Fourth projector family: the deferred list in the N2158 handoff named remaining projectors (BaseShield/Regen) as the next group after ForceProjector.

BaseShield extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector precedent).

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2159 does not touch it. N2159 supplies the missing pure power row + wires it into the driver. The port has NO SourceBaseShield* files at all yet — no display/runtime state to lean on. The efficiency fold this slice proves is the smooth-radius fold (BaseShield.java:89, `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);`), with the shield only engaging past radius 1 (BaseShield.java:91-93, `float rad = radius();` + `if(rad > 1){`).

Pure `SourceBaseShieldBuildState.source_base_shield_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update).

Driver wiring in `source_base_shield_tick_buildings_state(game, seconds)`: iterate placed BaseShield buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the smooth-radius fold (BaseShield.java:89) follows it. Live-loop wiring: the driver is called from `simulate_factory` in SourceFactoryRuntimeState.gd next to the force-projector tick.

Frame key (decided in RED): the driver uses its OWN family frame key `"source_base_shield_building"` (verified no collision: grep finds no `source_base_shield_building` anywhere in the port). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list had NO base-shield key — so GREEN added `"source_base_shield_building"` to that list (one line, SourcePlacedPowerGraphState.gd:140, same mechanism as the force-projector key).

Scope decision (decided in RED): **the BaseShield implementation only — shield-projector / large-shield-projector**. Families considered and rejected, with reasons (catalog `content_registry.json`, verified against Java + drivers):
- RegenProjector (regen-projector, 1f): separate projector slice, deferred — the last projector family.
- Payload producers (Constructor, PayloadLoader/Unloader/MassDriver, UnitCargoLoader, PayloadDeconstructor): separate family group, deferred.
- BaseShield wins: fourth projector family, 2 blocks, direct smooth-radius efficiency dependency — the smallest, safest next family.

Documented limits in the pure function's comment, same discipline as N2148–N2158: (1) power-only first pass — BaseShield has no item or liquid consumers at all, so the folded efficiency is the min over the *modeled* consumers (power only) with nothing else to defer. (2) No shouldConsume gate — BaseShieldBuild has no shouldConsume override, so the default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — smoothRadius / bullet absorb / unit repel / broken / hit (BaseShield.java:88-99) wait for their own slices; the proof carries no shield/radius/broken keys, the smooth-radius fold (BaseShield.java:89) is what the efficiency keys prove. (4) No drawShield rows — shieldColor / animateShields / sides 24 / hit alpha (BaseShield.java:125-147) are presentation, not state.

## Proof keys (new scene, 6 keys)

New scene `C07BaseShieldPowerStatusProof` (modeled on the N2158 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_BASE_SHIELD_POWER_STATUS_PROOF `:

- `shield_has_power_consumer`: catalog `shield-projector` AND `large-shield-projector` properties have `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place shield-projector live, stamp `frame["power_status"] = 0.5`, call `source_base_shield_tick_buildings_state` directly (as the N2147–N2158 proofs call their drivers directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_base_shield_power_status.py`: **4/4 OK in 15.027s** — registration (ledger N2159, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 13 exprs over ConsumePower.java + BuildingComp.java + BaseShield.java + Blocks.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment — each on ONE comment line, the N2148 shootWarmup lesson — + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (~21:45 +07): Ran 4 tests in 1.011s, FAILED (failures=1, errors=3), all expected — registration `KeyError: 'N2159'`, evidence `KeyError: 'N2159'`, source-text `FileNotFoundError` on `SourceBaseShieldBuildState.gd` (file did not exist yet), proof returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11326/1609/1530/2851 (unchanged from N2158 — main at 26a8ef4), audit 1335. javalang 0.13.0 present (no reinstall needed).
- GREEN first targeted run 4/4 OK in 15.027s — no fix needed during the run. Main-thread re-run 4/4 OK in 13.8s.
- Neighbours: **92/92 OK in 305.1s** (C07 power-status family 60/60 in 191.6s + wiring-sensitive modules — factory live loop, power-graph grouping/live-update, battery binding/placement, adjacent/unit-factory live loops, turret live loop, consumer cheating — 32/32 in 113.5s).
- Godot proof: **GREEN ~22:00 +07** — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build); standalone proof re-run confirms the same 9 keys, all true, no `ERROR:` lines. Port 7777 was FREE before every proof run; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this slice's commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11328 / 1610 / 1531 / 2853** (registry `symbols` 11328, ledger `slices` 1610, contracts 1531, schemas 2853); audit stays 1335 (audit report file unchanged by the register run).
- Environment note: Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH". javalang 0.13.0 present at RED (no VM restart since the N2158 reinstall).

## Gate / suite

- Full gate attempt 1 launched from the MAIN THREAD ~22:10 +07 (PID 13158, setsid, own session) **finished ~22:25 +07: Ran 5733 tests in 894.668s, FAILED (failures=110, skipped=5), 0 errors** — exactly the expected outcome (109 inherited + 1 new N2159 proof test). Verified by the 22:30 cron run: 110 `FAIL:` lines, 0 `ERROR:` lines, all 110 `AssertionError: unexpectedly None` (109 plain assertIsNotNone(godot) + 1 hydration assertIsNotNone(godot, 'Godot required for hydration proof')), including the new N2159 proof test (fails only on `assertIsNotNone(godot)` — the gate env has no Godot on PATH; the proof itself is GREEN headless). Gate clean except Godot. **First-attempt finish.**
- Slice committed + pushed after the gate verification (see handoff Commits).
- Next after gate + push: N2160 — next power.status family, scoped from the consumePower catalog (remaining projector: RegenProjector regen-projector 1f; or payload producers per the deferred list).
