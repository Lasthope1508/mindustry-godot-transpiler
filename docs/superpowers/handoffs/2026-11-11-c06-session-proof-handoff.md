# Handoff — N2121: C06 session proof

Date: 2026-11-11. Batch: N2121 (single slice). Status: built, registered, proof 40/40 verified, test module 4/4 standalone. **Targeted gate 5579 tests OK in 1742.901s** (log `~/workspace/logs/targeted-n2121.log`, started 06:40 +07 on the overdue boot — uptime 2:49, the expected ~05:52 restart never came and the gate survived); **full Python suite 5579 tests OK in 1736.535s** (log `~/workspace/logs/full-suite-n2121.log`). Commit: `f154f06`.

## What this batch is

The first C06-chain slice: it drives the whole bootstrap world end to end through the real game loop and asserts the session state before/after. Two functions, 19 symbols, SSOT +19/+1/+2/+4 → 11152 / 1572 / 1489 / 2769; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourceSessionSnapshotState.gd` (new): `source_session_snapshot_state(game)` — one pure read of the live session, 16 fields (core copper/health, placed power graph grouped at one live tick, drill DrillBuild fields from the legacy per-cell stores, pump frame + held water, conduit-line water). Null game → all zeros.
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`: new `source_factory_conveyor_tick_delta_state(seconds)` → `{ticks}` and the one-line `simulate_factory` change that feeds it into `source_factory_advance_conveyors_state` (the belt fix, below).
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`: `PORT_GAME_SOURCE_SESSION_SNAPSHOT_STATE`, `PORT_GAME_SOURCE_FACTORY_CONVEYOR_TICK_DELTA_STATE`.
- `godot-mindustry/src/generated/` (SSOT JSONs + `power_*` shards): N2121 row, 19 symbols, 2 contracts, 4 schemas. All 77 shards equal a fresh build. The snapshot mirrors into the `power_*` shards; the tick conversion lives only in the canonical contracts (the N2120 helper-owner precedent — the conveyor shard mirrors only slice `godot_owner`s, and the slice's owner is the snapshot).
- `tools/mindustry_godot_transpiler/tests/test_c06_session_snapshot.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_c06_session_snapshot.py` (new).
- `godot-mindustry/tools/runtime_proofs/C06SessionProof.gd` + `.tscn` (new). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1571 → 1572, N2121 checklist row + cube sentence + Not-Done C06 leg + migration-log row; plus the corrections found while editing — N2119 checklist proof 42/42 → 43/43 (its JSON has 43 keys), the missing N2119 migration-log row, N2118/N2120 gate results filled in (5566/5575 OK).
- `docs/superpowers/reports/2026-11-11-c06-session-proof.md` (this batch's report; gate line TBD until the gate runs).

## The belt bug (the important finding)

Before this slice, the live loop never delivered copper to the core. `simulate_factory` passed its delta in seconds straight into the belt advance, but the advance moves items by `moved = speed * edelta()` (Conveyor.java:262) with `edelta` in ticks (arc Time.java:26, `* 60f`; BuildingComp.java:1922-1929). Belts advanced 60× too slowly; the first item sat on the first belt cell and blocked every later dump on the 0.4 item spacing (`drill_items` grew 1..5, `core_copper` stayed 0 over 900 ticks). The N2070 proof never caught it: its live-loop check calls `simulate_factory(game, 1.0)`, where 1.0 second and 1.0 tick coincide numerically. The fix converts at the boundary (the N2093 pump precedent). The wrapper's contract is unchanged (its delta was already in ticks).

## Verified numbers (do not re-derive, these are measured)

- Proof `C06SessionProof`: **40/40 keys true** (counted from `godot-mindustry/tools/runtime_proofs/C06SessionProof.json`, `matches: true`; snapshots bit-identical across runs).
- S0 (reset): all zeros except core health 1100, battery capacity 4000, power 0.1/0.002/0.02, drill warmup 1.0.
- S1 (300 ticks): `drill_time_drilled` 431.7, warmup 1.6, `lastDrillSpeed` 5.12/650, produced 2, drill water 8.405, pump `total_progress` 274.182, pump water 6.781, conduit water 7.813, core copper 0.
- S2 (900 ticks): `drill_time_drilled` 1391.7, warmup 1.6, `lastDrillSpeed` 5.12/650, produced 6, drill water 14.257, pump `total_progress` 874.182, pump water 10.659, conduit water 38.083, **core copper 4** (first delivery ~tick 470).
- Power constant throughout: needed 0.1, produced 0.002, coverage 0.02, battery stored 0.0, capacity 4000.0, core health 1100.
- Delay = `getDrillTime(copper)` = (600 + 50 × 1) / 1 = **650 ticks** (Drill.java:170-172, `hardnessDrillMultiplier` 50f, copper hardness 1) — not 600. Boosted steady state: speed 1.6, warmup 1.6, `lastDrillSpeed` = 5.12/650. Water reaches the drill ~tick 60 (the conduit flow timers fire in phase and the line cascades in one firing).
- Test module standalone: 4/4 OK in 18.358s.
- The pre-slice snapshot reads the already-placed world (the Main scene builds it; the setup frames run the live loop with real deltas), so the pre-slice key asserts the placed state (core health 1100, battery capacity 4000, deficit power balance, nothing produced/delivered), not zeros. The null-game key asserts all zeros.
- The `SessionChainProbe.gd` + `.tscn` scratch files left by the cron probe are still in the tree (untracked). Delete them once this proof supersedes the probe's production-chain observations; the probe's approach (spawn_enemy_unit + load_selected_turret_ammo + the four simulate calls per tick) is the N2122 starting point, below.

## Deferred (not this slice)

- Per-class `shouldConsume()` bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389).
- `ConsumeItemDynamic.trigger` plan stacks leaving only at unit completion.
- UnitAssembler plan dynamics (UnitAssembler.java:158-160).
- Power-graph `shouldConsumePower` from the live frame `enabled` flag (Java `ConsumePower.requestedPower` gates on `entity.shouldConsume()`; the port uses static catalog properties — a disable → battery-charges act needs a separate slice).
- `Predict.intercept` + death sweep (defense leg).
- Pause/timeScale/disable/removal + source-exhaustion/output-full acts.

## Next: N2122 (defense leg, candidate)

`Predict.intercept` lead targeting + the death sweep, starting from the probe approach: `game.call("spawn_enemy_unit", dagger, 0)`, `SourceTurretAmmoState.load_selected_turret_ammo(game, "copper", 30)`, four simulate calls per tick (`simulate_factory`, `simulate_turrets`, `simulate_bullets`, `simulate_enemy_units`). Verify against the Java first — the probe's claims about the belt→core link are superseded by this batch (the link exists in code and now works live after the tick fix).

## Commit (not done by this builder)

Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, proof `.json`): `SourceSessionSnapshotState.gd`, `SourceFactoryRuntimeState.gd`, `SourceRuntimeOwnerGameplayRegistry.gd`, the SSOT JSONs + `power_*` shards, `test_c06_session_snapshot.py`, `register_c06_session_snapshot.py`, `C06SessionProof.gd` + `.tscn`, the design spec, the report + this handoff. Fill the real gate/suite results into the report, the handoff, the spec checklist/cube/migration rows, then commit + push, then the MEMORY.md N2121 entry.
