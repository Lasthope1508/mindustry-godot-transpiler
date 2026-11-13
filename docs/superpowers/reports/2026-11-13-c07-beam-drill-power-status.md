# Report — N2155: BeamDrill power.status live read (plasma-bore / large-plasma-bore) (C07)

Date: 2026-11-13. Batch: N2155 (single slice). Status: **DONE + PUSHED (targeted 4/4 OK, neighbours 86/86 OK, Godot proof GREEN, 9 keys, matches:true; full gate attempt 1 GREEN except Godot: Ran 5717, failures=106, skipped=5, 0 errors — all 106 Godot-absent asserts).**

## What changed

The next `power.status` consumer family after the N2154 mechanical-pump slice: the BeamDrill implementation — **plasma-bore** (consumePower 0.15f, drillTime 160f, tier 3, size 2, range 5, hydrogen 0.25f/60f booster) and **large-plasma-bore** (consumePower 0.8f, drillTime 100f, tier 5, size 3, range 6, hydrogen 0.5f/60f + nitrogen 3f/60f booster). Both havePower=true. BeamDrill (BeamDrill.java:25, `public class BeamDrill extends Block{`) has NO placed-buildings driver at all — plasma-bore / large-plasma-bore would drill as if power.status were 1.0. N2155 is the BeamDrill family's live read — the same proven N2145–N2154 pure-row pattern, one new file over.

BeamDrill extends Block, NOT Drill, so it cannot reuse the drill frame key (`"source_drill_building"`, bound by the drill proximity path for DrillBuild); it gets its own family frame key (the mechanical-pump precedent).

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2155 does not touch it. N2155 supplies the missing pure power row + wires it into the driver.

Pure `SourceBeamDrillBuildState.source_beam_drill_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update).

Driver wiring in `source_beam_drill_tick_buildings_state(game, seconds)`: iterate placed BeamDrill buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the lastDrillSpeed fold (BeamDrill.java:249, `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`) follows it. Live-loop wiring: the driver is called from `simulate_factory` in SourceFactoryRuntimeState.gd next to the mechanical-pump tick.

Frame key (decided in RED): the driver uses its OWN family frame key `"source_beam_drill_building"` (verified no collision: grep finds no `source_beam_drill` anywhere in the port and no BeamDrill references in `godot-mindustry/src/game/*.gd`). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list had NO beam-drill key — so GREEN added `"source_beam_drill_building"` to that list (one line, SourcePlacedPowerGraphState.gd:140, same mechanism as the mechanical-pump key).

Scope decision (decided in RED): **the BeamDrill implementation only — plasma-bore / large-plasma-bore**. Families considered and rejected, with reasons (catalog `content_registry.json`, verified against Java + drivers):
- Projectors (MendProjector, OverdriveProjector, ForceProjector, BaseShield): heal/overdrive/shield semantics, not a production-efficiency fold — separate family group, deferred.
- Payload producers (Constructor, PayloadLoader/Unloader/MassDriver, UnitCargoLoader, PayloadDeconstructor): separate family group, deferred.
- BeamDrill wins: 2 blocks, drill/pump group already half-done, direct `lastDrillSpeed` eff fold — the smallest, safest next family.

Documented limits in the pure function's comment, same discipline as N2148–N2154: (1) power-only first pass — the plasma hydrogen booster and large hydrogen + nitrogen booster liquid rows wait for their own slices; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — BeamDrillBuild.shouldConsume() (BeamDrill.java:270-271, `return items.total() < itemCapacity && facingAmount > 0 && enabled;`) needs items/facing state the tick does not track yet; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — warmup / multiplier / lastDrillSpeed / time / dump (BeamDrill.java:237-263) wait for their own slices; the proof carries no progress keys, the lastDrillSpeed fold (BeamDrill.java:249) is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07BeamDrillPowerStatusProof` (modeled on the N2149/N2154 proofs — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_BEAM_DRILL_POWER_STATUS_PROOF `:

- `plasma_bore_has_power_consumer`: catalog `plasma-bore` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place plasma-bore live, stamp `frame["power_status"] = 0.5`, call `source_beam_drill_tick_buildings_state` directly (as the N2147–N2154 proofs call their drivers directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_beam_drill_power_status.py`: **4/4 OK in 15.188s** — registration (ledger N2155, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 13 exprs over ConsumePower.java + BuildingComp.java + BeamDrill.java + Blocks.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment — each on ONE comment line, the N2148 shootWarmup lesson — + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (~17:30 +07): Ran 4 tests in 1.000s, FAILED (failures=1, errors=3), all expected — registration `KeyError: 'N2155'`, evidence `KeyError: 'N2155'`, source-text `FileNotFoundError` on `SourceBeamDrillBuildState.gd` (file did not exist yet), proof returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11318/1605/1526/2843 (unchanged from N2154 — main at 2a6d1ec), audit 1335.
- GREEN first targeted run 4/4 OK — no fix needed during the run. Main-thread re-run 4/4 OK in 14.7s.
- Neighbours: **86/86 OK in 273.3s** (C07 power family N2142/N2145–N2155 — 12 modules × 4 = 48 — + battery power-status binding + factory/adjacent/unit-factory/continuous-liquid-turret consumer bindings + factory/adjacent/unit-factory/turret/continuous-liquid-turret live loops).
- Godot proof: **GREEN ~17:45 +07** — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build); standalone proof re-run (18:00 run) confirms the same 9 keys, all true, no `ERROR:` lines. Port 7777 was FREE before every proof run; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this slice's commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11320 / 1606 / 1527 / 2845** (registry `symbols` 11320, ledger `slices` 1606, contracts 1527, schemas 2845); audit stays 1335 (audit report file unchanged by the register run).
- Environment note: Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH". javalang 0.13.0 already present (no reinstall needed this run).

## Gate / suite

- Full gate attempt 1 launched from the MAIN THREAD ~18:06 +07 (PID 13344, setsid, own session) **finished ~18:21 +07: Ran 5717 tests in 903.463s, FAILED (failures=106, skipped=5), 0 errors** — exactly the expected outcome (105 inherited + 1 new N2155 proof test). Verified by the 18:30 report run: 106 `FAIL:` lines, 0 `ERROR:` lines, all 106 `AssertionError: unexpectedly None` (105 plain assertIsNotNone(godot) + 1 hydration assertIsNotNone(godot, 'Godot required for hydration proof')), including the new N2155 proof test. Gate clean except Godot. First-attempt finish.
- Slice committed + pushed after the gate verification (see handoff Commits).
- Next after gate + push: N2156 — next power.status family, scoped from the consumePower catalog (projectors or payload producers per the deferred list).
