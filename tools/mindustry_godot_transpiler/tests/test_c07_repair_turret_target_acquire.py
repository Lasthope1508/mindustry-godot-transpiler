import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
UNIT_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitRuntimeState.gd'
REPAIR_TURRET_TARGET_ACQUIRE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretTargetAcquireProof.gd'


class C07RepairTurretTargetAcquireTests(unittest.TestCase):
    def test_c07_repair_turret_target_acquire_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2212']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state')
        # N2188 wired the shouldConsume gate on the live
        # `has_target` observation but no slice stamped it yet
        # ("The gate activates when the future
        # target-acquisition slice stamps `has_target` from
        # `Units.closest(team, x, y, repairRadius,
        # Unit::damaged)` (RepairTurret.java:216) plus the
        # null-out conditions (RepairTurret.java:193-195)");
        # N2209 then ported the coolant multiplier that the
        # heal advance multiplies by. This slice is the target
        # acquisition itself: RepairPointBuild.updateTile
        # nulls the target when it dies, walks out of range,
        # or is fully healed
        # (`if(target != null && (target.dead() ||
        # target.dst(this) - target.hitSize/2f > repairRadius
        # || target.health() >= target.maxHealth())){` /
        # `target = null;`, RepairTurret.java:193-195), zeroes
        # the beam offset when there is no target
        # (`if(target == null){` / `offset.setZero();`,
        # RepairTurret.java:197-199), and re-acquires every
        # 20s through the closest damaged ally in range
        # (`if(timer(timerTarget, 20)){` /
        # `rect.setSize(repairRadius * 2).setCenter(x, y);` /
        # `target = Units.closest(team, x, y, repairRadius,
        # Unit::damaged);`, RepairTurret.java:214-217).
        # Units.closest (the range overload, Units.java:358)
        # runs the circle nearby (`nearby(team, x, y, range, e
        # -> {`, Units.java:363), keeps only valid damaged
        # units (`if(!e.isValid() || !predicate.get(e))
        # return;`, Units.java:364), and takes the minimum
        # squared distance (`float dist = e.dst2(x, y);` /
        # `if(result == null || dist < cdist){` /
        # `result = e;` / `cdist = dist;`,
        # Units.java:366-369). The heal advance itself (angle
        # gate, `target.heal(...)`, rotation slerp, strength
        # lerp, RepairTurret.java:200-212) is NOT this slice --
        # it waits for its own slice (the N2188/N2202 split
        # precedent: target acquisition is the smallest
        # coherent slice here). Two pure functions: the Units
        # query on SourceUnitRuntimeState.gd (the N2210
        # precedent) and the acquire on
        # SourceRepairTurretBuildState.gd, plus one driver tick
        # line that stamps the acquired target live (the N2211
        # precedent). Seven new result symbols: the query's
        # target + has_target, and the acquire's target +
        # has_target + target_timer + offset + reacquired.
        self.assertEqual(
            ledger['N2212']['source_symbols'],
            [
                'source_units_closest_damaged_state_result.target',
                'source_units_closest_damaged_state_result.has_target',
                'source_repair_turret_target_acquire_state_result.target',
                'source_repair_turret_target_acquire_state_result.has_target',
                'source_repair_turret_target_acquire_state_result.target_timer',
                'source_repair_turret_target_acquire_state_result.offset',
                'source_repair_turret_target_acquire_state_result.reacquired',
            ],
        )
        for name in ledger['N2212']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/Units.java',
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'arc-core/src/arc/util/Interval.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_units_closest_damaged_state_result.target': 'SourceUnitRuntimeState.source_units_closest_damaged_state',
                    'source_units_closest_damaged_state_result.has_target': 'SourceUnitRuntimeState.source_units_closest_damaged_state',
                    'source_repair_turret_target_acquire_state_result.target': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.has_target': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.target_timer': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.offset': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.reacquired': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                }[name])
        self.assertEqual(ledger['N2212']['runtime_proof'], '/root/C07RepairTurretTargetAcquireProof')
        self.assertEqual(
            ledger['N2212']['tests'],
            [
                'test_c07_repair_turret_target_acquire_registration',
                'test_all_c07_repair_turret_target_acquire_input_evidence_is_exact',
                'test_repair_turret_target_acquire_state',
                'test_reference_graph_and_actual_c07_repair_turret_target_acquire',
            ],
        )
        self.assertTrue(ledger['N2212']['deferred_exprs'])

    def test_all_c07_repair_turret_target_acquire_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2212']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_units_closest_damaged_state_result.target': 'SourceUnitRuntimeState.source_units_closest_damaged_state',
                    'source_units_closest_damaged_state_result.has_target': 'SourceUnitRuntimeState.source_units_closest_damaged_state',
                    'source_repair_turret_target_acquire_state_result.target': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.has_target': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.target_timer': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.offset': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                    'source_repair_turret_target_acquire_state_result.reacquired': 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'arc-core/src/arc/util/Interval.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2212']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_target_acquire_state(self):
        unit_state = UNIT_STATE.read_text(encoding='utf-8')
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The closest-damaged query lives on the units runtime
        # state (the N2210 precedent: Units.* statics live in
        # SourceUnitRuntimeState.gd, next to
        # source_units_nearby_damaged_count_state): the range
        # overload (`public static Unit closest(Team team,
        # float x, float y, float range, Boolf<Unit>
        # predicate){`, Units.java:358) runs the circle nearby
        # (`nearby(team, x, y, range, e -> {`,
        # Units.java:363), keeps only valid damaged units
        # (`if(!e.isValid() || !predicate.get(e)) return;`,
        # Units.java:364), and takes the minimum squared
        # distance (`float dist = e.dst2(x, y);` /
        # `if(result == null || dist < cdist){` /
        # `result = e;` / `cdist = dist;`,
        # Units.java:366-369). The circle test is the N2210
        # one (`if(unit.within(x, y, radius + unit.hitSize/2f)){`,
        # Units.java:449, STRICT dst2 < (radius + hitSize/2)^2).
        # isValid is `!dead && isAdded()` (HealthComp.java:16-18);
        # listed units are present by construction, so the port
        # checks only `dead` (absent -> false). Damaged is
        # `health < maxHealth - 0.001f` (HealthComp.java:48).
        # Ties keep the first unit (strict `<`, Units.java:367).
        self.assertIn('static func source_units_closest_damaged_state(units: Array, team_id: Variant, x: float, y: float, radius: float) -> Dictionary:', unit_state)
        self.assertIn('if team_id != null and int(unit.get("team_id", -1)) != int(team_id):', unit_state)
        self.assertIn('var hit_size: float = float(unit.get("hit_size", 6.0))', unit_state)
        self.assertIn('if dx * dx + dy * dy >= effective_radius * effective_radius:', unit_state)
        self.assertIn('if bool(unit.get("dead", false)):', unit_state)
        self.assertIn('if health >= max_health - 0.001:', unit_state)
        self.assertIn('if not has_target or dist2 < best_dist2:', unit_state)
        self.assertIn('return {"target": null, "has_target": false}', unit_state)
        self.assertIn('return {"target": best, "has_target": true}', unit_state)
        self.assertIn('public static Unit closest(Team team, float x, float y, float range, Boolf<Unit> predicate){', unit_state)
        self.assertIn('nearby(team, x, y, range, e -> {', unit_state)
        self.assertIn('if(!e.isValid() || !predicate.get(e)) return;', unit_state)
        self.assertIn('float dist = e.dst2(x, y);', unit_state)
        self.assertIn('if(result == null || dist < cdist){', unit_state)
        self.assertIn('return health < maxHealth - 0.001f;', unit_state)
        self.assertIn('boolean isValid(){', unit_state)
        self.assertIn('return !dead && isAdded();', unit_state)
        self.assertIn('hitSize = 6f,', unit_state)
        # The acquire lives on the repair-turret build state,
        # next to the N2209 coolant multiplier: the invalidation
        # (`if(target != null && (target.dead() ||
        # target.dst(this) - target.hitSize/2f > repairRadius ||
        # target.health() >= target.maxHealth())){` /
        # `target = null;`, RepairTurret.java:193-195) reads the
        # CURRENT unit record (looked up by `id` in the units
        # list -- the stored dict is a snapshot, Java holds a
        # live reference; a target whose id is absent from the
        # list is gone, so it is dropped); the health check is
        # PLAIN `health >= maxHealth` (no 0.001 epsilon, unlike
        # damaged()); the distance check is Euclidean dst minus
        # hitSize/2, STRICTLY greater than repairRadius. The
        # offset reset (`if(target == null){` /
        # `offset.setZero();`, RepairTurret.java:197-199) zeroes
        # the beam offset whenever there is no target. The
        # timer (`if(timer(timerTarget, 20)){`,
        # RepairTurret.java:214) is a per-frame accumulator
        # starting at 0.0 (absent -> 0.0), firing at >= 20.0
        # and resetting to 0.0 -- the Interval.get model
        # (Interval.java: `return Time.time - times[id] >= time
        # || Time.time < times[id];`, times[] init 0, so the
        # first fire is at Time.time >= 20; reset-to-0 drops
        # overshoot exactly like Interval.get stamping
        # Time.time). The re-acquire (`target =
        # Units.closest(team, x, y, repairRadius,
        # Unit::damaged);`, RepairTurret.java:216) replaces the
        # target unconditionally on fire -- even a still-valid
        # one is re-picked. The driver stamps target /
        # has_target / target_timer / offset on the frame every
        # tick (unconditional: Java updateTile runs regardless
        # of power, enabled, or cheating -- only the heal
        # needs efficiency > 0, RepairTurret.java:203); the
        # radius is per-def (repair-point 60f, repair-turret
        # 145f, Blocks.java:6388/6400; class default 50f,
        # RepairTurret.java:31 -- the catalog carries no
        # repairRadius, so the driver resolves it from the
        # block id, the N2209 per-def-param precedent).
        self.assertIn('static func source_repair_turret_target_acquire_state(frame: Dictionary, units: Array, team_id: int, x: float, y: float, repair_radius: float, delta: float) -> Dictionary:', repair_turret)
        self.assertIn('var target_timer: float = float(frame.get("target_timer", 0.0)) + delta', repair_turret)
        self.assertIn('if target_timer >= 20.0:', repair_turret)
        self.assertIn('target_timer = 0.0', repair_turret)
        self.assertIn('var query: Dictionary = source_unit_runtime_state.source_units_closest_damaged_state(units, team_id, x, y, repair_radius)', repair_turret)
        self.assertIn('if dead or dist - hit_size / 2.0 > repair_radius or health >= max_health:', repair_turret)
        self.assertIn('offset = Vector2.ZERO', repair_turret)
        self.assertIn('return {"target": target, "has_target": target != null, "target_timer": target_timer, "offset": offset, "reacquired": reacquired}', repair_turret)
        self.assertIn('const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")', repair_turret)
        self.assertIn('source_repair_turret_target_acquire_state(frame, frame.get("units", []), team_id, sprite.position.x, sprite.position.y, repair_radius, seconds)', repair_turret)
        self.assertIn('frame["has_target"] = acquire.get("has_target", false)', repair_turret)
        self.assertIn('if(target != null && (target.dead() || target.dst(this) - target.hitSize/2f > repairRadius || target.health() >= target.maxHealth())){', repair_turret)
        self.assertIn('offset.setZero();', repair_turret)
        self.assertIn('if(timer(timerTarget, 20)){', repair_turret)
        self.assertIn('target = Units.closest(team, x, y, repairRadius, Unit::damaged);', repair_turret)
        self.assertIn('public float repairRadius = 50f;', repair_turret)
        self.assertIn('repairRadius = 60f;', repair_turret)
        self.assertIn('repairRadius = 145f;', repair_turret)
        self.assertIn('public int timerTarget = timers++;', repair_turret)
        self.assertIn('public Unit target;', repair_turret)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', repair_turret)
        # The proof's keys drive the acquire through the real
        # driver (closest damaged picked / no target before
        # the 20s timer fires / undamaged ignored / other-team
        # ignored / per-def radius used / acquisition runs
        # without power / target cleared when fully healed /
        # target cleared when out of range or dead). There are
        # no heal / rotation / strength keys: the heal advance
        # (RepairTurret.java:200-212) waits for its own slice.
        proof = REPAIR_TURRET_TARGET_ACQUIRE_PROOF.read_text(encoding='utf-8')
        for key in [
            'acquire_picks_closest_damaged',
            'no_target_before_timer_fire',
            'acquire_ignores_undamaged',
            'acquire_ignores_other_team',
            'acquire_uses_per_def_radius',
            'acquire_runs_without_power',
            'target_cleared_when_fully_healed',
            'target_cleared_when_out_of_range_or_dead',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_target_acquire(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretTargetAcquireProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_TARGET_ACQUIRE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'acquire_picks_closest_damaged',
            'no_target_before_timer_fire',
            'acquire_ignores_undamaged',
            'acquire_ignores_other_team',
            'acquire_uses_per_def_radius',
            'acquire_runs_without_power',
            'target_cleared_when_fully_healed',
            'target_cleared_when_out_of_range_or_dead',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
