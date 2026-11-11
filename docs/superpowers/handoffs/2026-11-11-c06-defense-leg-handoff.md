# Handoff — N2122: C06 defense leg

Date: 2026-11-11. Batch: N2122 (single slice). Status: built, registered, proof 30/30 verified, test module 4/4 standalone. **Targeted gate 5584 tests OK** (log `~/workspace/logs/targeted-n2122c.log`, 1760.730s); **full Python suite 5584 tests OK** (log `~/workspace/logs/full-suite-n2122c.log`, 1746.208s). Gate history: the first full suite (5583 tests) failed 1 test (`test_reference_graph_and_actual_c06_defense_leg`, `matches: False`) — a real bug, not a flake: with no target the duo burned its 30 copper rounds into empty air, so the defense leg came down to a single hit. Fixed with a null-target guard in `turret_fire_state` (holds rotation, never fires, cooldown ticks down; Turret.java:569-601 `validateTarget` gates the aim/turn/shoot) plus a `TICK_RATE` pin fix in `test_playable.py`; re-gate green on both logs. Commit: pending (this handoff's commit step).

## What this batch is

The C06 defense leg: `Predict.intercept` lead targeting + the death sweep, driven live per tick. Four functions, 28 symbols, SSOT +28/+1/+4/+8 → 11180 / 1573 / 1493 / 2777; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourcePredictState.gd` (new): `source_predict_intercept_state(src_x, src_y, dst_x, dst_y, dst_vx, dst_vy, bullet_speed, time_delta)` — `Predict.intercept` (Predict.java: per-frame displacement ÷ `Time.delta`, quadratic `a = dstv^2 - v^2`, `b = 2(dstv . t)`, `c = t^2`, smallest positive root, else the current position) — and `source_predict_quad_state(a, b, c)` — `Predict.quad` (the `|a| < 1e-6` linear branch, the non-negative discriminant branch).
- `godot-mindustry/src/game/SourceTurretCombatState.gd`: new `source_turret_target_position_state(game, origin, target)` — `Turret.targetPosition` (Turret.java:453-470: `predictTarget` true and `bullet.speed >= 0.01f` run the intercept, else the current position; a zero intercept falls back; the duo's charge offset is zero since `accurateDelay` runs with `moveWhileCharging`). Wired into `game_angle_to_target` before the pinned return line, reassigning `target` and `origin`; the pinned line stays textually identical. The wiring only runs for a Vector2 cell origin + a real enemy dict (has "type"); the tractor beam (dict origin) and the module proof (fake target) keep the plain angle.
- `godot-mindustry/src/game/SourceEnemyUnitRuntimeState.gd`: new `source_enemy_units_sweep_dead_state(game)` — the kill half of the death chain (`HealthComp.damage` kills at `health <= 0`, HealthComp.java:76-77; `HealthComp.kill`, :33-41; a non-flying unit's `killed()` destroys it, UnitComp.java:959-968; `remove()` drops it from its team, :603-608) — called at the top of `simulate_units`, before the movement loop. Returns `{swept_count, swept_health, remaining_count}`; null game → zeros.
- `godot-mindustry/src/game/SourceTurretRuntimePortBridge.gd`: `find_enemy_target` converts the cell to world first (`call("grid_to_world", ...)` — a direct call is NOT in that bridge's extends chain and breaks PortGame loading).
- `godot-mindustry/src/game/SourceTurretSimulationState.gd`: `turret_shot_application_state` takes the bullet origin from the turret's world position via `shot_context.get("game")` (set by `simulate_turrets`; absent in the module proof → falls back to `Vector2(cell)`).
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`: `PORT_GAME_SOURCE_PREDICT_INTERCEPT_STATE`, `PORT_GAME_SOURCE_PREDICT_QUAD_STATE`, `PORT_GAME_SOURCE_TURRET_TARGET_POSITION_STATE`, `PORT_GAME_SOURCE_ENEMY_UNITS_SWEEP_DEAD_STATE`.
- `godot-mindustry/src/generated/` (SSOT JSONs): N2122 row, 28 symbols, 4 contracts, 8 schemas. No shard mirror changes (the new owners live only in the canonical contracts, the N2120/N2121 helper-owner precedent).
- `tools/mindustry_godot_transpiler/tests/test_c06_defense_leg.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_c06_defense_leg.py` (new).
- `godot-mindustry/tools/runtime_proofs/C06DefenseProof.gd` + `.tscn` (new). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1572 → 1573, N2122 checklist row + cube sentence + Not-Done C06 leg + migration-log row.
- `docs/superpowers/reports/2026-11-11-c06-defense-leg.md` (this batch's report; gate lines filled with the real re-gate results: targeted + full suite 5584 OK).

## The two gaps (the important findings)

- **The sim aimed from the turret's grid cell.** `turret_fire_state` and `turret_shot_application_state` used `Vector2(cell)` as the origin, so the range was measured from (19, 7) in pixel space and the bullet spawned there — the turret only acquired the dagger in the far west and every shot missed by the lead distance. Fixed here: the origin is the turret's world position at all three call sites (Java aims from the building's world x/y). `find_enemy_target` must use `call("grid_to_world", ...)` — a direct call breaks PortGame loading because `SourceWorldGridPortBridge` is not an ancestor of `SourceTurretRuntimePortBridge`.
- **There was no lead at all.** The aim used the target's current sprite position while the bullet needs ~64 ticks to cross 160px and the dagger walks ~32px in that time. The intercept now feeds the aim. The approach runs straight through the duo, so the dagger's motion is radial and the lead angle is zero by construction — the lead is a forward displacement (~32px at full range), not a turn; the proof asserts it as >10px ahead along the walk, not as an angle.

## Verified numbers (do not re-derive, these are measured)

- Proof `C06DefenseProof`: **30/30 keys true** (counted from `godot-mindustry/tools/runtime_proofs/C06DefenseProof.json`, `matches: true`).
- Predict unit checks (hand-computed): lead (0,0)→(100,0) vel (0,1) v5 → intercept (100, 20.412414523193153), t 20.412414523193153; outrun (10/tick vs 5/tick) → falls back to (10, 0), `used_intercept` false; stationary (30, 40) v5 → (30, 40), t = 10. Quad: roots (-2, 2); degenerate linear (2, 2); no roots; zero (0, 0).
- Duo world (624, 240); core world (560, 272). Duo loads 15 copper (30 ammo): the bootstrap already fills it to maxAmmo 30 during `enter_campaign_playable_slice`, so the proof drains the stacks before loading.
- Dagger spawn: 1 unit, health 150. Approach placement (847.607, 128.197) — 250px out on the line through the duo and the core.
- Live leg (up to 700 ticks, four simulates per tick): dagger enters the 160px range; on the first tick in range the live aim matches the intercept angle within 1°, the intercept point sits >10px ahead of the dagger along its walk, `used_intercept` true; hits land; dagger dies before the core (`death_tick < 643` — the unopposed walk would take ~643 ticks: 250px approach + 71.6px duo→core at 0.5 px/tick) and is swept (`enemy_units` empty after; the sweep runs at the top of `simulate_units` and bullets run before `simulate_enemy_units` in each tick, so a dead unit never moves again); core health stays 1100; ammo is spent.
- Test module standalone: 4/4 OK in 28.538s (re-run at build time).
- The wave timer is pinned to 100000.0 and setup-spawned enemies are cleared (wave hazard: spacing 3.0s = 180 ticks, cooldown starts 0 — a wave spawns on the first `simulate_enemy_units` call with no enemies).

## Deferred (not this slice)

- `Unit.destroy()` effects (explosion, sound, `UnitDestroyEvent`, wreck decal, shoot-on-death, crash damage — `SourceUnitDestroyState` holds them unwired).
- The bullet hit check uses only the bullet's `hitSize` (4.0) — Java's physics collision adds the target hitbox.
- The turret `shootY` offset (3.0) is used as-is in the pixel frame.
- Per-class `shouldConsume()` bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389).
- `ConsumeItemDynamic.trigger` plan stacks leaving only at unit completion.
- UnitAssembler plan dynamics (UnitAssembler.java:158-160).
- Power-graph `shouldConsumePower` from the live frame `enabled` flag.
- Pause/timeScale/disable/removal + source-exhaustion/output-full acts.

## Next: N2123 (candidate)

The remaining C06 work: pause/timeScale/disable/removal, or source-exhaustion/output-full acts. Deferred list above carries forward; the per-class `shouldConsume()` bodies, `ConsumeItemDynamic.trigger`, UnitAssembler plan dynamics and `shouldConsumePower`-from-frame are the older tails.

## Commit

Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, proof `.json`): `SourcePredictState.gd`, `SourceEnemyUnitRuntimeState.gd`, `SourceRuntimeOwnerGameplayRegistry.gd`, `SourceTurretCombatState.gd`, `SourceTurretRuntimePortBridge.gd`, `SourceTurretSimulationState.gd`, the four SSOT JSONs, `test_c06_defense_leg.py`, `register_c06_defense_leg.py`, `C06DefenseProof.gd` + `.tscn`, `test_playable.py` (the `TICK_RATE` pin fix), the design spec, the report + this handoff. Gates already green on the re-run (targeted + full suite 5584 OK, logs `targeted-n2122c.log` / `full-suite-n2122c.log`). Commit: `15a3a9f` (pushed), then the MEMORY.md N2122 entry.
