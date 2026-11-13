# Report — N2156: MendProjector power.status live read (mender / mend-projector) (C07)

Date: 2026-11-13. Batch: N2156 (single slice). Status: **DONE + PUSHED (targeted 4/4 OK, neighbours 90/90 OK, Godot proof GREEN, 9 keys, matches:true; full gate attempt 1 GREEN except Godot: Ran 5721, failures=107, skipped=5, 0 errors — all 107 Godot-absent asserts).**

## What changed

The next `power.status` consumer family after the N2155 beam-drill slice: the MendProjector implementation — **mender** (consumePower 0.3f, size 1, reload 200f, range 40f, healPercent 4f, phaseBoost 4f, phaseRangeBoost 20f, silicon booster) and **mend-projector** (consumePower 1.5f, size 2, reload 250f, range 85f, healPercent 11f, phaseBoost 15f, phaseFabric booster). Both havePower=true, hasItems=true. Catalog confirms implementation MendProjector + consumePower 0.3 / 1.5, consumesPower true, hasPower true, connectedPower true (content_registry.json).

MendProjector (MendProjector.java:21, `public class MendProjector extends Block{`) has NO placed-buildings driver at all — mender / mend-projector would heal as if power.status were 1.0. N2156 is the MendProjector family's live read — the same proven N2145–N2155 pure-row pattern, one new file over. First projector family: the deferred list in the N2155 handoff named projectors (Mend/Overdrive/Force/BaseShield) as the next group after BeamDrill.

MendProjector extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill precedent).

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2156 does not touch it. N2156 supplies the missing pure power row + wires it into the driver. The port already has MendProjector display/runtime state (SourceMendProjectorRuntimeState.gd reads `runtime_step.get("efficiency", 1.0)` and multiplies the heal by it, `healed_amount *= float(runtime_step.get("efficiency", 1.0))` at :67) — the heal fold already consumes efficiency; the missing piece was the live power.status → efficiency driver, which is exactly this slice.

Pure `SourceMendProjectorBuildState.source_mend_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update).

Driver wiring in `source_mend_projector_tick_buildings_state(game, seconds)`: iterate placed MendProjector buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the heal fold (MendProjector.java:113, `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`) follows it. Live-loop wiring: the driver is called from `simulate_factory` in SourceFactoryRuntimeState.gd next to the beam-drill tick.

Frame key (decided in RED): the driver uses its OWN family frame key `"source_mend_projector_building"` (verified no collision: grep finds no `source_mend_projector_building` anywhere in the port — the existing `SourceMendProjector*` files use per-cell state dicts, not this meta key). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list had NO mend-projector key — so GREEN added `"source_mend_projector_building"` to that list (one line, SourcePlacedPowerGraphState.gd:140, same mechanism as the beam-drill key).

Scope decision (decided in RED): **the MendProjector implementation only — mender / mend-projector**. Families considered and rejected, with reasons (catalog `content_registry.json`, verified against Java + drivers):
- Remaining projectors (OverdriveProjector overdrive-projector 3.5f / overdrive-dome 10f, ForceProjector 4f, BaseShield shield-projector 5f, RegenProjector 1f): separate projector slices, deferred after this one.
- Payload producers (Constructor, PayloadLoader/Unloader/MassDriver, UnitCargoLoader, PayloadDeconstructor): separate family group, deferred.
- MendProjector wins: first projector family, 2 blocks, direct heal-fold efficiency dependency — the smallest, safest next family.

Documented limits in the pure function's comment, same discipline as N2148–N2155: (1) power-only first pass — the silicon (mender) and phaseFabric (mend-projector) booster item rows wait for their own slices; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — MendBuild has no shouldConsume override, so the default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled. (3) No suppression gate — `canHeal = !checkSuppression();` (MendProjector.java:94) needs suppression state the tick does not track yet. (4) No updateTile advance — smoothEfficiency / heat / charge / phaseHeat / heal (MendProjector.java:94-120) wait for their own slices; the proof carries no progress/heal keys, the heal fold (MendProjector.java:113) is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07MendProjectorPowerStatusProof` (modeled on the N2155 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_MEND_PROJECTOR_POWER_STATUS_PROOF `:

- `mender_has_power_consumer`: catalog `mender` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place mender live, stamp `frame["power_status"] = 0.5`, call `source_mend_projector_tick_buildings_state` directly (as the N2147–N2155 proofs call their drivers directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_mend_projector_power_status.py`: **4/4 OK in 16.158s** — registration (ledger N2156, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 13 exprs over ConsumePower.java + BuildingComp.java + MendProjector.java + Blocks.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment — each on ONE comment line, the N2148 shootWarmup lesson — + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (~18:45 +07): Ran 4 tests in 4.126s, FAILED (failures=1, errors=3), all expected — registration `KeyError: 'N2156'`, evidence `KeyError: 'N2156'`, source-text `FileNotFoundError` on `SourceMendProjectorBuildState.gd` (file did not exist yet), proof returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11320/1606/1527/2845 (unchanged from N2155 — main at 516ac38), audit 1335. javalang 0.13.0 REINSTALLED at RED (VM restarted ~18:39 +07 — the system-wide pip install was wiped; `pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from the repo root).
- GREEN first targeted run 4/4 OK — no fix needed during the run. Main-thread re-run 4/4 OK in 14.5s.
- Neighbours: **90/90 OK in 307.393s** (C07 power family N2142/N2145–N2156 — 13 modules × 4 = 52 — + battery power-status binding + factory/adjacent/unit-factory/continuous-liquid-turret consumer bindings + factory/adjacent/unit-factory/turret/continuous-liquid-turret live loops).
- Godot proof: **GREEN ~19:09 +07** — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build); standalone proof re-run confirms the same 9 keys, all true, no `ERROR:` lines. Port 7777 was FREE before every proof run; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this slice's commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11322 / 1607 / 1528 / 2847** (registry `symbols` 11322, ledger `slices` 1607, contracts 1528, schemas 2847); audit stays 1335 (audit report file unchanged by the register run).
- Environment note: Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH". javalang 0.13.0 reinstalled at RED after the ~18:39 VM restart.

## Gate / suite

- Full gate attempt 1 launched from the MAIN THREAD ~19:09 +07 (PID 5359, setsid, own session) **finished ~19:27 +07: Ran 5721 tests in 1083.854s, FAILED (failures=107, skipped=5), 0 errors** — exactly the expected outcome (106 inherited + 1 new N2156 proof test). Verified by the 19:30 report run: 107 `FAIL:` lines, 0 `ERROR:` lines, all 107 `AssertionError: unexpectedly None` (106 plain assertIsNotNone(godot) + 1 hydration assertIsNotNone(godot, 'Godot required for hydration proof')), including the new N2156 proof test. Gate clean except Godot. First-attempt finish.
- Slice committed + pushed after the gate verification (see handoff Commits).
- Next after gate + push: N2157 — next power.status family, scoped from the consumePower catalog (remaining projectors: OverdriveProjector overdrive-projector 3.5f / overdrive-dome 10f, ForceProjector 4f, BaseShield shield-projector 5f, RegenProjector 1f; or payload producers per the deferred list).
