# Handoff — N2153: Fracker power.status live read (oil-extractor) (C07)

Date: 2026-11-13. Batch: N2153 (single slice). Status: **DONE + PUSHED (targeted 4/4 OK, neighbours 67/67 OK, Godot proof GREEN, 9 keys, matches:true — verified by main thread: targeted re-run 4/4 OK in 14.4s, proof JSON 9 keys all true, SSOT 11316/1604/1525/2841). Full gate attempt 1 (PID 15276, main thread) DIED in a VM restart ~14:48 +07. Attempt 2 (PID 3721, main thread ~15:02) finished ~15:17 +07: Ran 5709 in 892.858s, failures=104, skipped=5, 0 errors — all 104 verified Godot-absent asserts by the 15:30 report run. Slice committed + pushed after gate verification.**

## Scope

- Family: the Fracker implementation — **oil-extractor** (consumePower 3f, pumpAmount 0.25f, size 3, liquidCapacity 40f, attribute oil, itemUseTime 60f, result oil, consumeItem sand, consumeLiquid water 0.15f). The ONLY Fracker block in the game (Blocks.java:2964-2979). Catalog confirms implementation Fracker + consumePower 3.0 (content_registry.json, properties consumePower 3.0 / consumesPower true / hasPower true / connectedPower true).
- Why: Fracker extends SolidPump (Fracker.java:7, `public class Fracker extends SolidPump{`), but the N2150 solid-pump driver only ticks the SolidPump implementation (`SOURCE_SOLID_PUMP_BUILD_IMPLEMENTATIONS` is `["SolidPump"]`), so the oil-extractor never ticked at all and would pump as if power.status were 1.0. N2153 is the Fracker family's live read — the same proven N2145–N2152 pure-row pattern, one new file over.
- Families considered and rejected (catalog `content_registry.json`, verified against Java + drivers):
  - HeatCrafter (5 blocks) / AttributeCrafter (3 blocks): already covered — the N2145 factory driver lists both implementations and applies the power row whenever `consumePower` is present. Separator likewise already covered by the N2146 adjacent-factory driver.
  - LaserTurret (meltdown 17f) / ContinuousTurret (lustre 3.33f): already covered by N2148.
  - Mechanical Pump (rotary-pump 0.3f, impulse-pump 1.3f): the pump runtime (SourcePumpRuntimeState.gd) ticks only the scenario mechanical pump at PUMP_POS with efficiency hardcoded 1.0 ("consumes no power"); placed rotary/impulse pumps have NO placed-buildings driver at all — needs a new general pump driver, not a one-file row. Deferred to its own slice.
  - BeamDrill (plasma-bore 0.15f, large-plasma-bore 0.8f): no BeamDrill driver exists at all — new driver needed. Deferred.
  - Projectors (MendProjector mender 0.3f / mend-projector 1.5f, OverdriveProjector 3.5f / overdrive-dome 10f, ForceProjector 4f, BaseShield shield-projector / large-shield-projector 5f): heal/overdrive/shield semantics, not a production-efficiency fold — separate family group. Deferred.
  - Payload producers (Constructor 2.5f / large-constructor 3f, PayloadLoader / PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor): separate family group. Deferred.
- Base SolidPump tick untouched — the Fracker driver is separate, like BurstDrill vs base Drill and SolidPump vs mechanical Pump.

## Design (decided in RED)

- New file `godot-mindustry/src/game/SourceFrackerBuildState.gd` (mirrors SourceSolidPumpBuildState.gd): pure `source_fracker_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_fracker_tick_buildings_state(game, seconds)` mirroring the solid-pump driver's shape — iterate placed Fracker buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the fracker accumulator fold (Fracker.java:38) and the `super.updateTile()` solid-pump speed fold (SolidPump.java:121) follow power.status.
- Frame key (decided in RED): the driver uses its OWN family frame key `"source_fracker_building"` (the turret precedent — the solid-pump frame `source_solid_pump_building` stays untouched, the oil-extractor never binds it). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list has NO fracker key — so GREEN must add `"source_fracker_building"` to that list (one line, same mechanism as the solid-pump key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call right after the solid-pump tick, the subclass grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the accumulator line `accumulator += delta() * efficiency;` (Fracker.java:38), the super-updateTile speed fold `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:121) and the eff gate `if(efficiency > 0){` (Fracker.java:31) — keep the accumulator and maxPump lines each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2152): (1) power-only first pass — the item (sand) / liquid (water 0.15f) consumers and the water-attribute / validTiles / boost fraction (SolidPump.java:118, 137-147, inherited via `super.updateTile()`) wait for their own slices; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — FrackerBuild inherits `SolidPumpBuild.shouldConsume()` (SolidPump.java:113-115, `return liquids.get(result) < liquidCapacity - 0.01f;`) which needs liquid state the tick does not track yet; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — accumulator / itemUseTime consume / `super.updateTile()` (Fracker.java:30-44) and warmup / pumpTime / lastPump / validTiles / boost (SolidPump.java:118-133) wait for their own slices; the proof carries no progress keys, the accumulator/speed fold (Fracker.java:38, SolidPump.java:121) is what the efficiency keys prove.
- Proof scene (new, modeled on the N2150 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_FRACKER_POWER_STATUS_PROOF `, 6 keys: `oil_extractor_has_power_consumer` (catalog oil-extractor properties has consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place oil-extractor live, stamp frame["power_status"] = 0.5, call `source_fracker_tick_buildings_state` directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (11, all verified verbatim at RED)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(3f);` (Blocks.java:2977, oil-extractor def)
- `public class Fracker extends SolidPump{` (Fracker.java:7)
- `if(efficiency > 0){` (Fracker.java:31)
- `accumulator += delta() * efficiency;` (Fracker.java:38)
- `super.updateTile();` (Fracker.java:37)
- `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:121)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)

## RED

- RED run (~14:35 +07): test module `tools/mindustry_godot_transpiler/tests/test_c07_fracker_power_status.py`, Ran 4 tests in 1.158s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2153', evidence ERROR KeyError 'N2153', source-text ERROR FileNotFoundError on `SourceFrackerBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 11/11 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11314/1603/1524/2839, audit 1335 (unchanged from N2152 — main at fe69509).
- Register script written (not yet run): `tools/mindustry_godot_transpiler/register_c07_fracker_power_status.py` (modeled on the N2150 register script; N2153 + 2 symbols, SSOT +2/+1/+1/+2 expected).

## GREEN

- GREEN run (~14:37 +07): register script run (SSOT 11314/1603/1524/2839 → **11316/1604/1525/2841**, audit 1335 — exactly +2/+1/+1/+2; audit report file unchanged); new file `SourceFrackerBuildState.gd` (pure row + driver, accumulator and maxPump lines each on ONE comment line); `"source_fracker_building"` added to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140); driver wired into `SourceFactoryRuntimeState.simulate_factory` (preload + one call right after the solid-pump tick); proof scene `C07FrackerPowerStatusProof.gd/.tscn` (6 keys). First targeted run **4/4 OK in 13.3s** — no fix needed during the run. Neighbours **67/67 OK in 206.3s** (C07 power family N2142/N2145–N2152 — 9 modules × 4 = 36 — + power-graph live-update binding + factory/adjacent/unit-factory consumer bindings + factory/adjacent/unit-factory/turret live loops). Godot proof GREEN (6 keys + registry keys, matches:true) — part of targeted test 4, on Godot 4.6.2-stable Linux; standalone proof re-run ~14:40 confirms proof JSON 9 keys, all true, `matches:true`, no `ERROR:` lines. Port 7777 was FREE before every proof run; no proof scene ran while a gate ran.
- `git diff --check` clean.

## Gate result

- Full gate attempt 1 (PID 15276, main thread ~14:46) **DIED in a VM restart ~14:48 +07** — verified by main thread at 15:02: PID gone, log stopped at 3,508 bytes, no footer, `uptime` 14 min, javalang wiped (reinstalled 0.13.0 by the 15:00 run, import verified OK before relaunch). Worktree intact (main fe69509, 15 N2153 files uncommitted).
- Full gate attempt 2 **launched from the MAIN THREAD ~15:02 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2153-gate.log 2>&1 < /dev/null &` — **PID 3721, SID 3721 (own session), PPID 3718 (background subshell)** — **finished ~15:17 +07: Ran 5709 tests in 892.858s, FAILED (failures=104, skipped=5), 0 errors** — exactly the expected outcome. Verified by the 15:30 report run: log footer present, PID gone, 104 `FAIL:` lines, 0 `ERROR:` lines, all 104 `AssertionError: unexpectedly None` (assertIsNotNone(godot)), including the new N2153 proof test. Gate runs with no Godot on PATH (established pattern); the proof itself was run separately with Godot present and is green.
- Slice committed + pushed after the gate verification (see Commits below).

## Commits

- Slice commit **`07fa495`** (2026-11-13 ~15:3x +07, 15 files, `git diff --check` clean): `godot-mindustry/src/game/SourceFrackerBuildState.gd`, `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`, `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd`, `godot-mindustry/tools/runtime_proofs/C07FrackerPowerStatusProof.gd`, `godot-mindustry/tools/runtime_proofs/C07FrackerPowerStatusProof.tscn`, `godot-mindustry/src/generated/source_symbol_registry.json`, `source_slice_ledger.json`, `source_api_contracts.json`, `source_state_schema.json`, `source_modules/production_api_contracts.json`, `source_modules/production_slices.json`, `source_modules/production_state_schema.json`, `source_modules/production_symbols.json`, `tools/mindustry_godot_transpiler/register_c07_fracker_power_status.py`, `tools/mindustry_godot_transpiler/tests/test_c07_fracker_power_status.py` (15 files; `git diff --check` clean). Note: 15, not N2152's 14 — the register script touched the production shards (Fracker is production, not defense); `source_ssot_modules.json` and the audit report are unchanged (production modules already carry `optional_mirror_fields: ["return_type"]`). Never stage `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, `full-suite-*.log`, or `targeted-env-fix.log`.
- Docs commit (pending gate): report + design spec + handoff. GOAL.md §5 debt line update follows (names the slice commit carrying the proof to Windows).

## Deferred (NOT this slice)

- Fracker updateTile advance (accumulator / itemUseTime consume / super.updateTile(), Fracker.java:30-44), Fracker shouldConsume gate (inherited SolidPump.java:113-115), Fracker item/liquid rows (sand / water 0.15f), Fracker attribute/validTiles/boost fraction rows (see register script DEFERRED).
- Mechanical Pump power.status (rotary-pump / impulse-pump) — needs a new general pump driver; BeamDrill power.status (plasma-bore / large-plasma-bore) — needs a new driver; projector families (Mend/Overdrive/Force/BaseShield); payload-producer families (Constructor / PayloadLoader / Unloader / MassDriver / UnitCargoLoader / PayloadDeconstructor).
- PointDefenseTurret / TractorBeamTurret updateTile advance / shouldConsume gate / coolant rows; SolidPump updateTile advance / shouldConsume gate / water-attribute rows; BurstDrill updateTile advance / shouldConsume gate / liquid rows / ore-dominant binding.
- spawn_occupied / allow_update / moveOutPayload, net drone sync (see register script DEFERRED).
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED and before every proof run. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Environment note: javalang 0.13.0 verified OK at RED (no VM restart in this run). Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
