# Handoff — N2123: C06 pause gate

Date: 2026-11-11. Batch: N2123 (single slice). Status: built, registered, proof 50/50 verified, test module 4/4 standalone. **Targeted gate 5593 tests OK** (log `~/workspace/logs/targeted-n2123-n2124.log`, 1831.774s); **full Python suite 5593 tests OK** (log `~/workspace/logs/full-suite-n2123-n2124.log`, 1846.009s). Gate history: the first targeted gate run was killed by the ~12:56 +07 VM restart; re-run green on both logs. Commit: c38826d (pushed).

## What this batch is

The C06 pause gate: `Logic.update`'s `isPaused` gate + `GameState.isPaused`. Two symbols, 10 exprs, SSOT +2/+1/+1/+2 → 11182 / 1574 / 1494 / 2779; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourceGameLoopRuntimeState.gd`: new `source_game_loop_paused_state(game)` — `GameState.isPaused` (GameState.java:93-95, `state == State.paused`; states paused/playing/menu, set with `GameState.set(State)`, GameState.java:60-62) — and the `process_tick` early return: while paused it returns before `Time.update` and before any sim, so a paused game advances nothing at all (Logic.update, Logic.java:507, runs the tick, `Time.update` and `updateEntities` only inside `if(!state.isPaused())`). One-line compile fix by the N2124 builder: `Object.get()` takes at most 1 arg (line 19) — that fix turned the pause module 3/4 → 4/4 and its proof green.
- `godot-mindustry/src/game/SourcePortGameRootStatePortBridge.gd`: `paused` flag on the game root (the live pause state the loop reads).
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`: `PORT_GAME_SOURCE_GAME_LOOP_PAUSED_STATE`.
- `godot-mindustry/src/generated/` (SSOT JSONs): N2123 row, 2 symbols, 1 contract, 2 schemas. No shard mirror changes (the new owner lives only in the canonical contracts, the N2120/N2121 helper-owner precedent).
- `tools/mindustry_godot_transpiler/tests/test_c06_pause_gate.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_c06_pause_gate.py` (new).
- `godot-mindustry/tools/runtime_proofs/C06PauseProof.gd` + `.tscn` (new). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1573 → 1574, N2123 checklist row.
- `docs/superpowers/reports/2026-11-11-c06-pause-gate.md` (this batch's report; gate lines filled with the real re-gate results: targeted + full suite 5593 OK).

## Verified numbers (do not re-derive, these are measured)

- Proof `C06PauseProof`: **50/50 keys true** (counted from `godot-mindustry/tools/runtime_proofs/C06PauseProof.json`, `matches: true`).
- Test module standalone: 4/4 OK (verified in the builders' run; the joint gate covers it).
- Suite size: 5584 + 9 new tests = 5593 tests (4 pause + 4 shouldConsume + 1 content-registry test).

## Deferred (not this slice)

- Per-building timeScale expiry (BuildingComp.update's timeScaleDuration decay runs in `simulate_block_time_scales` already, but no overdrive boost ever sets a duration yet).
- The disabled-building gate (BuildingComp.update's `enabled || !block.noUpdateDisabled` updateTile gate — the factory tick still runs its updateTile half for a disabled factory because GenericCrafter leaves noUpdateDisabled false, and efficiency 0 is what stops its progress).
- Removal of destroyed buildings from the live loop.
- Source-exhaustion/output-full acts.
- The per-class shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389) — done in N2124, next commit.
- `ConsumeItemDynamic.trigger` plan stacks leaving only at unit completion.
- UnitAssembler plan dynamics (UnitAssembler.java:158-160).
- Power-graph `shouldConsumePower` from the live frame `enabled` flag.

## Next: N2124 (built, same gate)

Per-class shouldConsume() bodies — built alongside this batch, committed right after it. Then remaining: `ConsumeItemDynamic.trigger`, UnitAssembler plan dynamics, shouldConsumePower-from-frame, timeScale/disable/removal; C06–C12 remainder.

## Commit

Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, proof `.json`): `SourceGameLoopRuntimeState.gd`, `SourcePortGameRootStatePortBridge.gd`, `SourceRuntimeOwnerGameplayRegistry.gd`, the four SSOT JSONs, `test_c06_pause_gate.py`, `register_c06_pause_gate.py`, `C06PauseProof.gd` + `.tscn`, the design spec, the report + this handoff. Gates already green (targeted + full suite 5593 OK, logs `targeted-n2123-n2124.log` / `full-suite-n2123-n2124.log`). Commit: c38826d (pushed), then the MEMORY.md N2123 entry.
