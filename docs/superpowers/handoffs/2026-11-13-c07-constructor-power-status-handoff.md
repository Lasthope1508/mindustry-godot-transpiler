# Handoff — N2161: Constructor power.status live read (constructor / large-constructor) (C07)

Date: 2026-11-13. Batch: N2161 (single slice). Status: **DONE + PUSHED (2026-11-14 ~00:3x +07 — targeted 4/4 OK in 14.544s, neighbours 104/104 OK in 338.3s, Godot proof GREEN 9 keys, matches:true; full gate attempt 1 Ran 5741 in 901.128s, failures=112, skipped=5, 0 errors — all 112 verified Godot-absent asserts).**

## Scope (decided at RED)

- Family: the Constructor implementation — **constructor** (consumePower 2.5f, size 3, buildSpeed 0.6f, Blocks.java:6658-6667) and **large-constructor** (consumePower 3f, size 5, buildSpeed 0.75f, Blocks.java:6670-6680). Constructor extends BlockProducer (Constructor.java:19, `public class Constructor extends BlockProducer{`); BlockProducer has hasPower=true, hasItems=true, update=true, solid=true, outputsPayload=true (BlockProducer.java:28-35). Catalog confirms implementation Constructor + consumePower 2.5f / 3f (content_registry.json — to re-verify at GREEN; the Blocks.java def is the source of truth, see Exact exprs).
- Why: Constructor (Constructor.java:19) has NO placed-buildings driver at all — constructor / large-constructor would produce as if power.status were 1.0. N2161 is the Constructor family's live read — the same proven N2145–N2160 pure-row pattern, one new file over. First payload-producer family: the deferred list in the N2160 handoff named payload producers (Constructor / PayloadLoader / PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) as the next family group after the projectors.
- Constructor extends BlockProducer, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector precedent).
- The port has NO SourceConstructor* files at all yet — no display/runtime state to lean on. The efficiency fold this slice proves is the produce gate (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`), with the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`).
- Out of scope for this slice: the remaining payload producers (PayloadLoader / PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) stay deferred — separate family slices. Constructor has a dynamic item consumer (ConsumeItemDynamic over recipe requirements, BlockProducer.java:39-58) besides power — that row waits for its own slice.

## Design (decided in scoping, to confirm at RED)

- New file `godot-mindustry/src/game/SourceConstructorBuildState.gd` (mirrors SourceRegenProjectorBuildState.gd): pure `source_constructor_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_constructor_tick_buildings_state(game, seconds)` mirroring the regen-projector driver's shape — iterate placed Constructor buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the produce gate (BlockProducer.java:110) follows power.status.
- Frame key (DECIDED at RED 2026-11-13 ~23:45 +07): `"source_constructor_building"` — verified no collision: grep finds no `source_constructor_building` anywhere in the port. GREEN adds it to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` (one line, same mechanism as the regen-projector key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call next to the regen-projector tick, the production grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the produce gate `boolean produce = recipe != null && efficiency > 0 && payload == null;` (BlockProducer.java:110), the progress advance `progress += buildSpeed * edelta();` (BlockProducer.java:113), the shouldConsume default `public boolean shouldConsume(){` (BuildingComp.java:755), the shouldConsume override `return super.shouldConsume() && recipe() != null;` (BlockProducer.java:103), the constructor consumePower `consumePower(2.5f);` (Blocks.java:6663) — keep each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2160): (1) power-only first pass — the BlockProducer item consumer is dynamic (ConsumeItemDynamic over recipe requirements, BlockProducer.java:39-58), so the folded efficiency is the min over the *modeled* consumers (power only) with that row deferred. (2) shouldConsume gate deferred — BlockProducerBuild overrides shouldConsume() to return super.shouldConsume() && recipe() != null (BlockProducer.java:102-104); recipe state is not tracked yet, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance — progress / heat / time / moveOutPayload (BlockProducer.java:109-131) wait for their own slices; the proof carries no progress/heat/recipe keys, the produce gate (BlockProducer.java:110) is what the efficiency keys prove. (4) No config/filter rows — filter, minBlockSize/maxBlockSize, canProduce (Constructor.java:21-22, 54-56) are config, not tick state.
- Proof scene (new, modeled on the N2159/N2160 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_CONSTRUCTOR_POWER_STATUS_PROOF `, 6 keys: `constructor_has_power_consumer` (catalog constructor + large-constructor properties have consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place constructor live, stamp frame["power_status"] = 0.5, call the driver directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (13, all verified verbatim at scoping — grep 2026-11-13 ~23:45)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(2.5f);` (Blocks.java:6663, constructor def 6658)
- `public class Constructor extends BlockProducer{` (Constructor.java:19)
- `hasPower = true;` (BlockProducer.java:32)
- `boolean produce = recipe != null && efficiency > 0 && payload == null;` (BlockProducer.java:110)
- `progress += buildSpeed * edelta();` (BlockProducer.java:113)
- `public boolean shouldConsume(){` (BuildingComp.java:755)
- `return super.shouldConsume() && recipe() != null;` (BlockProducer.java:103)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)
- `consumePower(3f);` (Blocks.java:6679, large-constructor def 6670)

## RED (DONE 2026-11-13 ~23:45 +07, 23:45 report run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_constructor_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_constructor_power_status.py` written (modeled on N2160; frame key decided: `"source_constructor_building"`).
- RED run: Ran 4 tests in 1.015s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2161', evidence ERROR KeyError 'N2161', source-text ERROR FileNotFoundError on `SourceConstructorBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Re-run confirmed the same breakdown (3 ERRORs + 1 FAIL). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11330/1611/1532/2855 (unchanged from N2160 — main at 4a527a3; verified slices 1611, symbols 11330 from the generated JSONs), audit 1335. javalang 0.13.0 present (no reinstall needed).
- Next: GREEN (new `SourceConstructorBuildState.gd` pure row + driver, wiring in `SourceFactoryRuntimeState.simulate_factory`, key added to `SOURCE_CONSUMER_FRAME_META_KEYS`, proof scene `C07ConstructorPowerStatusProof` 6 keys, register script run → expected SSOT 11332/1612/1533/2857), then targeted 4/4 → neighbours → Godot proof → full gate (main thread) → commit + push only when all green.

## GREEN (DONE 2026-11-14 ~00:05 +07, 00:00 report run)

- New `godot-mindustry/src/game/SourceConstructorBuildState.gd` (pure row `source_constructor_power_status_row_state` + driver `source_constructor_tick_buildings_state` + bind `source_constructor_bind_frame_state`, frame key `source_constructor_building`), proof scene `C07ConstructorPowerStatusProof` (6 keys) + `.tscn`, wiring: preload + one call in `SourceFactoryRuntimeState.simulate_factory` next to the regen-projector tick, `"source_constructor_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` in `SourcePlacedPowerGraphState.gd`. Register script run → SSOT 11332/1612/1533/2857 (symbols/slices/contracts/schemas; was 11330/1611/1532/2855), audit 1335. All 13 exact exprs present verbatim in the driver (each on ONE comment line, N2148 lesson).
- Targeted: Ran 4 tests in 14.544s, OK (includes the Godot proof test). Godot proof GREEN standalone: proof JSON 9 keys all true, `matches: true`, no ERROR (port 7777 was FREE). `git diff --check` clean.
- Neighbours: C07 power-status family 18 modules / 72 tests + wiring-sensitive 9 modules / 32 tests (factory live loop, power-graph grouping/live-update, battery binding/placement, adjacent/unit-factory live loops, turret live loop, consumer cheating) — **104/104 OK in 338.3s** (00:00 run).
- Next: full gate (main thread — worker-launched gates die at session end, N2146/N2147/N2149/N2151/N2154/N2157/N2160 precedent; expected Ran ~5741, failures=112, skipped=5, 0 errors, all Godot-absent asserts), then report + design spec (Status Summary 1611→1612) + handoff + GOAL.md §5 debt line, then commit + push only when all green.

## Gate (DONE — attempt 1)

- Full gate attempt 1 **launched from the MAIN THREAD ~00:12 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2161-gate.log 2>&1 < /dev/null &` — **PID 13149, SID 13149 (own session), PPID 13146 (background subshell), CPU ~94%**. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule). **FINISHED ~00:27 +07: Ran 5741 tests in 901.128s, FAILED (failures=112, skipped=5), 0 errors.** Verified by the 00:30 report run: 112 FAIL blocks, all 112 are `AssertionError: unexpectedly None` (111 plain `assertIsNotNone(godot)` + 1 hydration `test_live_block_shared_consumers_and_optional_efficiency_runtime` with 'Godot required for hydration proof'); 0 `ERROR:` lines; the new N2161 proof test `test_reference_graph_and_actual_c07_constructor_power_status` is among the 112 (expected — gate env has no Godot; the proof itself was verified GREEN headless at 00:05 with 9 keys). Exactly as predicted (Ran ~5741, failures=112, skipped=5, 0 errors). Slice committed + pushed after gate verification (see Commits).

## Commits (PENDING — hashes to record after push)

## Deferred (NOT this slice)

- Constructor / BlockProducer updateTile advance (progress / heat / time / moveOutPayload, BlockProducer.java:109-131), BlockProducer shouldConsume gate (recipe() != null, BlockProducer.java:102-104), BlockProducer dynamic item consumer rows (ConsumeItemDynamic, BlockProducer.java:39-58), Constructor config/filter rows (Constructor.java:21-22, 54-56), Constructor buildSpeed rows (0.6f / 0.75f, Blocks.java:6662/6674), Constructor payload/draw rows (BlockProducer.java:116-119, 134-160; Constructor.java:77-87).
- Payload producers (PayloadLoader / PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) — the next families after Constructor.
- RegenProjector updateTile advance / shouldConsume gate / suppression gate / booster item row / liquid row / range-heal rows / mendMap rows; BaseShield / ForceProjector / OverdriveProjector / MendProjector / BeamDrill / Pump / Fracker / SolidPump updateTile advance / shouldConsume / liquid / proximity rows (see register script DEFERRED).
- spawn_occupied / allow_update frame inputs, moveOutPayload(), net drone sync.
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
- Worktree at RED: main `4a527a3`, clean except untracked `*.gd.uid` (never stage). New uncommitted files: the N2161 test module + register script + this handoff.
- VM restarts wipe the system-wide javalang install — reinstalled 0.13.0 at the N2160 RED run (22:45 run). After any VM restart, reinstall javalang first before any gate. javalang 0.13.0 present at this run.
- N2161 proof not yet run on Windows Godot (debt in GOAL.md §5 — to add at GREEN completion, scene reaches Windows with the slice commit).
