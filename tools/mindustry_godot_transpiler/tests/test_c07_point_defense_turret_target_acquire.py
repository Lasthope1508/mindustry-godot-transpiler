import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_TARGET_ACQUIRE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretTargetAcquireProof.gd'


class C07PointDefenseTurretTargetAcquireTests(unittest.TestCase):
    def test_c07_point_defense_turret_target_acquire_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2239']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state')
        # N2151 wired the power.status live read but deferred the
        # updateTile advance ("No updateTile advance:
        # PointDefenseBuild.updateTile()
        # (PointDefenseTurret.java:62-103, retarget / rotation /
        # reloadCounter / beam effects) waits for its own slice;
        # the proof carries no progress keys"). This slice is
        # the first half of that advance -- the retarget: every
        # retargetTime (5s) the build re-acquires the nearest
        # enemy hittable bullet in the range rect
        # (`if(timer(timerTarget, retargetTime)){` /
        # `target = Groups.bullet.intersect(x - range, y -
        # range, range*2, range*2).min(b -> b.team != team &&
        # b.type().hittable, b -> b.dst2(this));`,
        # PointDefenseTurret.java:65-67), and a pooled bullet
        # is nulled (`if(target != null &&
        # !target.isAdded()){` / `target = null;`,
        # PointDefenseTurret.java:69-71). The aim / rotation /
        # reloadCounter / shoot half (PointDefenseTurret.java:
        # 76-101) is NOT this slice -- it waits for its own
        # slice (the RepairTurret N2212/N2215 split
        # precedent: target acquisition is the smallest
        # coherent slice here). One pure function on
        # SourcePointDefenseTurretBuildState.gd, plus one
        # driver tick line that stamps the acquired target
        # live (the N2212 precedent). Four new result
        # symbols: target + has_target + target_timer +
        # reacquired.
        self.assertEqual(
            ledger['N2239']['source_symbols'],
            [
                'source_point_defense_turret_target_acquire_state_result.target',
                'source_point_defense_turret_target_acquire_state_result.has_target',
                'source_point_defense_turret_target_acquire_state_result.target_timer',
                'source_point_defense_turret_target_acquire_state_result.reacquired',
            ],
        )
        for name in ledger['N2239']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'arc-core/src/arc/util/Interval.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_target_acquire_state_result.target': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                    'source_point_defense_turret_target_acquire_state_result.has_target': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                    'source_point_defense_turret_target_acquire_state_result.target_timer': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                    'source_point_defense_turret_target_acquire_state_result.reacquired': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                }[name])
        self.assertEqual(ledger['N2239']['runtime_proof'], '/root/C07PointDefenseTurretTargetAcquireProof')
        self.assertEqual(
            ledger['N2239']['tests'],
            [
                'test_c07_point_defense_turret_target_acquire_registration',
                'test_all_c07_point_defense_turret_target_acquire_input_evidence_is_exact',
                'test_point_defense_turret_target_acquire_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_target_acquire',
            ],
        )
        self.assertTrue(ledger['N2239']['deferred_exprs'])

    def test_all_c07_point_defense_turret_target_acquire_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2239']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_target_acquire_state_result.target': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                    'source_point_defense_turret_target_acquire_state_result.has_target': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                    'source_point_defense_turret_target_acquire_state_result.target_timer': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                    'source_point_defense_turret_target_acquire_state_result.reacquired': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'arc-core/src/arc/util/Interval.java',
            'core/src/mindustry/content/Blocks.java',
            # Groups.java is build-generated from GroupDefs.java
            # (@GroupDef(value = Bulletc.class, spatial = true,
            # collide = true) G bullet;, GroupDefs.java:9), so
            # it never exists on disk: the on-disk source is
            # GroupDefs.java, not Groups.java. (RED-test fix,
            # N2239: the 23:00 RED listed Groups.java and the
            # evidence test would FileNotFoundError on it.)
            'core/src/mindustry/entities/GroupDefs.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2239']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_target_acquire_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # The acquire lives on the point-defense build state,
        # next to the N2151 power row: the retarget
        # (`if(timer(timerTarget, retargetTime)){` /
        # `target = Groups.bullet.intersect(x - range, y -
        # range, range*2, range*2).min(b -> b.team != team &&
        # b.type().hittable, b -> b.dst2(this));`,
        # PointDefenseTurret.java:65-67) re-acquires every
        # retargetTime (5f, PointDefenseTurret.java:20) through
        # the nearest enemy hittable bullet in the range rect,
        # and the pooled check (`if(target != null &&
        # !target.isAdded()){` / `target = null;`,
        # PointDefenseTurret.java:69-71) nulls a bullet that
        # left the live list. The timer slot is `public final
        # int timerTarget = timers++;`
        # (PointDefenseTurret.java:19) on a per-building
        # Interval (`transient Interval timer = new
        # Interval(6);`, TimerComp.java:8); `timer()`
        # (TimerComp.java:10-12) delegates to `Interval.get`,
        # which fires on elapsed game time (`return Time.time
        # - times[id] >= time || Time.time < times[id];`,
        # Interval.java:32, times[] init 0, so the first fire
        # is at Time.time >= 5) and stamps the fire time
        # (`if(got) times[id] = Time.time;`,
        # Interval.java:31). The port models this with a
        # per-frame accumulator `target_timer += delta; if
        # target_timer >= 5.0: fire, target_timer = 0` --
        # reset-to-0 drops overshoot exactly like
        # `Interval.get`; do NOT subtract the interval (that
        # would carry overshoot and drift the re-acquire
        # cadence vs Java). The port has no live bullet query
        # (no Groups.bullet equivalent), so the pure function
        # consumes an observed bullet list (the ShockwaveTower
        # N2190 precedent: `observed_bullets`, an array of
        # dicts with team/hittable/x/y, world coords, plus an
        # `id` so the stored target can be re-identified
        # across ticks -- the live `game["bullets"]` dicts
        # carry no team/hittable/id yet, so the driver maps
        # them in a later wiring step and stamps nothing
        # until then). The invalidation reads the CURRENT
        # bullet record: the stored target is looked up by
        # `id` in the observed list (the stored dict is a
        # snapshot, Java holds a live reference over `public
        # @Nullable Bullet target;`, PointDefenseTurret.java:60;
        # a target whose id is absent from the list is pooled,
        # so it is dropped, and a stored target with no id
        # cannot be re-identified, so it is dropped too -- the
        # RepairTurret N2212 precedent). The re-acquire is a
        # point-in-rect test against the Java intersect rect
        # (x +/- range, y +/- range, range 180f per-def,
        # Blocks.java:3838, `range = 180f;`, the only
        # PointDefenseTurret def) with a min-dst2 pick; ties
        # keep the first bullet (strict `<`, the N2212
        # precedent). The port models no bullet hitSize, so
        # the rect overlap is approximated by the bullet
        # point, a documented limit owned by a later
        # bullet-hitSize slice (the ShockwaveTower precedent).
        # The re-acquire replaces the target unconditionally
        # on fire -- even a still-valid one is re-picked.
        # The result is a 4-key dict: `target` (the target
        # dict after this tick, null when none), `has_target`
        # (the observation the future shouldConsume gate
        # reads, `return super.shouldConsume() && target !=
        # null;`, PointDefenseTurret.java:105-107),
        # `target_timer` (the accumulator after this tick,
        # 0.0 on a fire), and `reacquired` (whether the 5s
        # timer fired this tick). The aim / rotation /
        # reloadCounter / shoot half
        # (PointDefenseTurret.java:76-101) is NOT this slice
        # -- it waits for its own slice.
        self.assertIn('static func source_point_defense_turret_target_acquire_state(frame: Dictionary, observed_bullets: Array, team_id: int, x: float, y: float, range: float, delta: float) -> Dictionary:', point_defense)
        self.assertIn('var target_timer: float = float(frame.get("target_timer", 0.0)) + delta', point_defense)
        self.assertIn('if target_timer >= 5.0:', point_defense)
        self.assertIn('target_timer = 0.0', point_defense)
        self.assertIn('if int(bullet.get("team", -1)) == team_id:', point_defense)
        self.assertIn('if not bool(bullet.get("hittable", false)):', point_defense)
        self.assertIn('if absf(float(bullet.get("x", 0.0)) - x) > range:', point_defense)
        self.assertIn('if absf(float(bullet.get("y", 0.0)) - y) > range:', point_defense)
        self.assertIn('if not has_target or dist2 < best_dist2:', point_defense)
        self.assertIn('var target_id: int = int(target.get("id", -1))', point_defense)
        self.assertIn('if fresh.is_empty():', point_defense)
        self.assertIn('target = null', point_defense)
        self.assertIn('return {"target": target, "has_target": target != null, "target_timer": target_timer, "reacquired": reacquired}', point_defense)
        self.assertIn('if frame.has("observed_bullets"):', point_defense)
        self.assertIn('var acquire: Dictionary = source_point_defense_turret_target_acquire_state(frame, frame.get("observed_bullets", []), team_id, sprite.position.x, sprite.position.y, 180.0, seconds)', point_defense)
        self.assertIn('frame["target"] = acquire.get("target", null)', point_defense)
        self.assertIn('frame["has_target"] = acquire.get("has_target", false)', point_defense)
        self.assertIn('frame["target_timer"] = acquire.get("target_timer", 0.0)', point_defense)
        self.assertIn('if(timer(timerTarget, retargetTime)){', point_defense)
        self.assertIn('target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', point_defense)
        self.assertIn('if(target != null && !target.isAdded()){', point_defense)
        self.assertIn('public float retargetTime = 5f;', point_defense)
        self.assertIn('public final int timerTarget = timers++;', point_defense)
        self.assertIn('public @Nullable Bullet target;', point_defense)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', point_defense)
        self.assertIn('range = 180f;', point_defense)
        # The proof's keys drive the acquire through the real
        # driver (closest enemy hittable picked / no target
        # before the 5s timer fires / same-team ignored /
        # non-hittable ignored / out-of-rect ignored /
        # acquisition runs without power / pooled target
        # cleared / re-acquire replaces even a valid target on
        # fire). There are no aim / rotation / reload /
        # shoot keys: that half (PointDefenseTurret.java:
        # 76-101) waits for its own slice.
        proof = POINT_DEFENSE_TARGET_ACQUIRE_PROOF.read_text(encoding='utf-8')
        for key in [
            'acquire_picks_closest_enemy_hittable',
            'no_target_before_timer_fire',
            'acquire_ignores_same_team',
            'acquire_ignores_non_hittable',
            'acquire_ignores_out_of_rect',
            'acquire_runs_without_power',
            'target_cleared_when_pooled',
            'reacquire_replaces_valid_target_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_target_acquire(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretTargetAcquireProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_TARGET_ACQUIRE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'acquire_picks_closest_enemy_hittable',
            'no_target_before_timer_fire',
            'acquire_ignores_same_team',
            'acquire_ignores_non_hittable',
            'acquire_ignores_out_of_rect',
            'acquire_runs_without_power',
            'target_cleared_when_pooled',
            'reacquire_replaces_valid_target_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
