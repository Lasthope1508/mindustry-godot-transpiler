# Handoff — N2162: PayloadLoader power.status live read (payload-loader) (C07)

Date: 2026-11-14. Batch: N2162 (single slice). Status: **DONE (2026-11-14 ~01:30 +07 — GREEN 01:10: targeted 4/4 OK, proof JSON 9 keys all true, neighbours 104/104 OK; gate attempt 1 FINISHED ~01:27: Ran 5745 in 922.543s, failures=113, skipped=5, 0 errors — all 113 verified Godot-absent asserts. SSOT 11334/1613/1534/2859. Committing + pushing now, per the slice process).**

## Scope (decided at RED)

- Family: the PayloadLoader implementation — **payload-loader** (consumePower 2f, size 3, loadTime 2f, maxPowerConsumption 40f, Blocks.java:6682-6689). PayloadLoader extends PayloadBlock (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`); PayloadLoader has hasItems=true, hasLiquids=true, hasPower=true, itemCapacity 100, liquidCapacity 100f, update=true, outputsPayload=true, size 3, rotate=true (PayloadLoader.java:31-41). Catalog confirms implementation PayloadLoader + consumePower 2f (Blocks.java def is the source of truth, see Exact exprs).
- Why: PayloadLoader (PayloadLoader.java:19) has NO placed-buildings driver at all — payload-loader would load as if power.status were 1.0. N2162 is the PayloadLoader family's live read — the same proven N2145–N2161 pure-row pattern, one new file over. Second payload-producer family: the deferred list in the N2161 handoff named payload producers (PayloadLoader / PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) as the next family group after Constructor; PayloadLoader is first in that order.
- PayloadLoader extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; it gets its own family frame key (the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor precedent).
- The port has NO SourcePayloadLoader* files at all yet — no display/runtime state to lean on. The efficiency fold this slice proves is the load gate (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`), with the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`).
- Out of scope for this slice: the remaining payload producers (PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) stay deferred — separate family slices. PayloadLoader has a DYNAMIC power consumer (consumePowerDynamic, PayloadLoader.java:80 — maxPowerConsumption 40f + basePowerUse when hasBattery() && !exporting, else basePowerUse) besides the static consumePower(2f) def — the dynamic usage value waits for its own slice.

## Design (decided in scoping, to confirm at RED)

- New file `godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd` (mirrors SourceConstructorBuildState.gd): pure `source_payload_loader_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_payload_loader_tick_buildings_state(game, seconds)` mirroring the constructor driver's shape — iterate placed PayloadLoader buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the load gate (PayloadLoader.java:157) follows power.status.
- Frame key (DECIDED at RED 2026-11-14 ~00:45 +07): `"source_payload_loader_building"` — verified no collision: grep finds no `source_payload_loader_building` anywhere in the port. GREEN adds it to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` (one line, same mechanism as the constructor key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call next to the constructor tick, the production grouping).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the load gate `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){` (PayloadLoader.java:157), the battery charge `float powerInput = power.status * (basePowerUse + maxPowerConsumption);` (PayloadLoader.java:202), the shouldConsume default `public boolean shouldConsume(){` (BuildingComp.java:755), the shouldConsume override `return payload != null;` (PayloadLoader.java:241), the payload-loader consumePower `consumePower(2f);` (Blocks.java:6686) — keep each on ONE comment line (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148–N2161): (1) power-only first pass — the PayloadLoader power consumer is dynamic (consumePowerDynamic, PayloadLoader.java:80), so the folded efficiency is the min over the *modeled* consumers (power only) with the dynamic usage value deferred. (2) shouldConsume gate deferred — PayloadLoaderBuild overrides shouldConsume() to return payload != null (PayloadLoader.java:240-242); payload state is not tracked yet, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance — moveInPayload / moveOutPayload / load items+liquids / battery charge (PayloadLoader.java:143-220) wait for their own slices; the proof carries no load/export/battery keys, the load gate (PayloadLoader.java:157) is what the efficiency keys prove. (4) No accept/handle payload rows — acceptPayload fits maxBlockSize (PayloadLoader.java:102-115) is payload acceptance, not tick state.
- Proof scene (new, modeled on the N2161 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_PAYLOAD_LOADER_POWER_STATUS_PROOF `, 6 keys: `payload_loader_has_power_consumer` (catalog payload-loader properties have consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place payload-loader live, stamp frame["power_status"] = 0.5, call the driver directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (13, all verified verbatim at scoping — grep 2026-11-14 ~00:45)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(2f);` (Blocks.java:6686, payload-loader def 6682)
- `public class PayloadLoader extends PayloadBlock{` (PayloadLoader.java:19)
- `hasPower = true;` (PayloadLoader.java:36)
- `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){` (PayloadLoader.java:157)
- `float powerInput = power.status * (basePowerUse + maxPowerConsumption);` (PayloadLoader.java:202)
- `public boolean shouldConsume(){` (BuildingComp.java:755)
- `return payload != null;` (PayloadLoader.java:241)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)
- `public float maxPowerConsumption = 40f;` (PayloadLoader.java:26)

## RED (DONE 2026-11-14 ~00:45 +07, 00:45 report run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_payload_loader_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_payload_loader_power_status.py` written (modeled on N2161; frame key decided: `"source_payload_loader_building"`).
- RED run: Ran 4 tests in 1.054s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2162', evidence ERROR KeyError 'N2162', source-text ERROR FileNotFoundError on `SourcePayloadLoaderBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11332/1612/1533/2857 (unchanged from N2161 — main at 1244db7; verified slices 1612, symbols 11332 from the generated JSONs), audit 1335. javalang 0.13.0 present (no reinstall needed).
- Next: GREEN (new `SourcePayloadLoaderBuildState.gd` pure row + driver, wiring in `SourceFactoryRuntimeState.simulate_factory`, key added to `SOURCE_CONSUMER_FRAME_META_KEYS`, proof scene `C07PayloadLoaderPowerStatusProof` 6 keys, register script run → expected SSOT 11334/1613/1534/2859), then targeted 4/4 → neighbours → Godot proof → full gate (main thread) → commit + push only when all green.

## GREEN (DONE 2026-11-14 ~01:10 +07, 01:00 report run)

- New `godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd` (pure row `source_payload_loader_power_status_row_state` + driver `source_payload_loader_tick_buildings_state` + bind `source_payload_loader_bind_frame_state`, frame key `source_payload_loader_building`), proof scene `C07PayloadLoaderPowerStatusProof` (6 keys) + `.tscn`, wiring: preload + one call in `SourceFactoryRuntimeState.simulate_factory` next to the constructor tick, `"source_payload_loader_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` in `SourcePlacedPowerGraphState.gd`. Register script run → SSOT 11334/1613/1534/2859 (symbols/slices/contracts/schemas; was 11332/1612/1533/2857), audit 1335. All 13 exact exprs present verbatim in the driver (each on ONE comment line, N2148 lesson).
- RED-time bug fixed at GREEN: the register script's symbol dict was missing `java_method=method` (N2161's script has it, line 179) — first register run failed `ValueError: invalid source symbol registry: ... source-backed requires java_method`; added the field, re-ran clean.
- Targeted: Ran 4 tests in 15.069s, OK (includes the Godot proof test). Godot proof GREEN standalone: proof JSON 9 keys all true, `matches: true`, no ERROR (port 7777 was FREE). `git diff --check` clean.
- Neighbours: C07 power-status family 18 modules / 72 tests + wiring-sensitive 9 modules / 32 tests (factory live loop, power-graph grouping/live-update, battery binding/placement, adjacent/unit-factory live loops, turret live loop, consumer cheating) — **104/104 OK in 344.421s** (01:00 run).
- Next: full gate (main thread — worker-launched gates die at session end, N2146/N2147/N2149/N2151/N2154/N2157/N2160 precedent; expected Ran ~5745, failures=113, skipped=5, 0 errors, all Godot-absent asserts), then report + design spec (Status Summary 1612→1613) + handoff + GOAL.md §5 debt line, then commit + push only when all green.

## Gate (DONE — attempt 1, verified by the 01:30 report run)

- Full gate attempt 1 **launched from the MAIN THREAD ~01:12 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2162-gate.log 2>&1 < /dev/null &` — **PID 20134, SID 20134 (own session), PPID 20131 (background subshell), CPU ~92%, log growing** (930 → 1,164 bytes in 3s, verified ~01:12). No Godot on PATH. No proof scene will run while the gate runs (port-7777 rule). Expect: Ran ~5745, failures=113 (112 inherited + 1 new N2162 proof test), skipped=5, 0 errors, all Godot-absent. Finish ~01:27–01:37 +07 (N2161 took 901s; recent gates 893–1722s).
- **FINISHED ~01:27 +07: Ran 5745 tests in 922.543s, FAILED (failures=113, skipped=5), 0 errors.** Verified by the 01:30 report run: 113 FAIL blocks, 0 ERROR lines; 112 plain `assertIsNotNone(godot)` + 1 hydration `test_live_block_shared_consumers_and_optional_efficiency_runtime` ('Godot required for hydration proof'); the new N2162 proof test `test_reference_graph_and_actual_c07_payload_loader_power_status` is among the 113 (expected — gate env has no Godot; the proof itself was verified GREEN headless at 01:10 with 9 keys). Exactly as predicted. Gate clean except Godot — slice cleared to commit + push.

## Commits (TODO)

## Deferred (NOT this slice)

- PayloadLoader updateTile advance (moveInPayload / moveOutPayload / load items+liquids / battery charge, PayloadLoader.java:143-220), PayloadLoader shouldConsume gate (payload != null, PayloadLoader.java:240-242), PayloadLoader dynamic power consumer row (consumePowerDynamic, PayloadLoader.java:80), PayloadLoader battery-charge rows (PayloadLoader.java:202-213), PayloadLoader load params (loadTime 2f / itemsLoaded 8 / liquidsLoaded 40f / maxBlockSize 3, PayloadLoader.java:22-25), PayloadLoader accept/handle payload rows (PayloadLoader.java:102-121).
- Payload producers (PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) — the next families after PayloadLoader.
- Constructor / BlockProducer updateTile advance / shouldConsume gate / dynamic item consumer rows / config-filter rows / buildSpeed rows / payload-draw rows; RegenProjector / BaseShield / ForceProjector / OverdriveProjector / MendProjector / BeamDrill / Pump / Fracker / SolidPump updateTile advance / shouldConsume / liquid / proximity rows (see register script DEFERRED).
- spawn_occupied / allow_update frame inputs, moveOutPayload(), net drone sync.
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH".
- Worktree at RED: main `1244db7`, clean except untracked `*.gd.uid` (never stage). New uncommitted files: the N2162 test module + register script + this handoff.
- VM restarts wipe the system-wide javalang install — reinstalled 0.13.0 at the N2160 RED run (22:45 run). After any VM restart, reinstall javalang first before any gate. javalang 0.13.0 present at this run.
- N2162 proof not yet run on Windows Godot (debt in GOAL.md §5 — to add at GREEN completion, scene reaches Windows with the slice commit).
