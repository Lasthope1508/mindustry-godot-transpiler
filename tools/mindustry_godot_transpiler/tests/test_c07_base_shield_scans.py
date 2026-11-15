import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE_SHIELD_STATE = ROOT / 'godot-mindustry/src/game/SourceBaseShieldBuildState.gd'
BASE_SHIELD_SCANS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldScansProof.gd'
BASE_SHIELD_SCANS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldScansProof.tscn'


class C07BaseShieldScansTests(unittest.TestCase):
    def test_c07_base_shield_scans_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2328']['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_supplied_bullets_state')
        # The N2236 advance ported the BaseShield updateTile
        # absorb/repel/kill with explicit `bullets` and
        # `enemy_units` lists -- but the driver passed `[], []`
        # every tick, so no live absorb/repel ever happened:
        # the Groups.bullet RECTANGLE intersect
        # (BaseShield.java:96) and the Units.nearbyEnemies
        # (rad + 10f) scan (BaseShield.java:97) were never
        # ported. N2328 ports both scans as filter pures over
        # frame candidates and wires them into the tick: the
        # bullet scan is the RECT broad phase only (center in
        # [x +/- rad, y +/- rad], INCLUSIVE -- the N2277
        # precedent; the advance already does the enemy +
        # absorbable + STRICT within narrow check), and the
        # unit scan filters enemy team + STRICT within(rad +
        # 10 + hitSize/2) (Units.java:482-488, the
        # nearbyEnemies radius overload -- enemy-only by
        # construction, so the advance checks no team). Two
        # new result symbols: the scanned bullets and the
        # scanned enemy units.
        self.assertEqual(
            ledger['N2328']['source_symbols'],
            [
                'source_base_shield_supplied_bullets_state_result.bullets',
                'source_base_shield_supplied_enemy_units_state_result.enemy_units',
            ],
        )
        for name in ledger['N2328']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_base_shield_supplied_bullets_state_result.bullets': 'core/src/mindustry/world/blocks/defense/BaseShield.java',
                    'source_base_shield_supplied_enemy_units_state_result.enemy_units': 'core/src/mindustry/entities/Units.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_base_shield_supplied_bullets_state_result.bullets': 'SourceBaseShieldBuildState.source_base_shield_supplied_bullets_state',
                    'source_base_shield_supplied_enemy_units_state_result.enemy_units': 'SourceBaseShieldBuildState.source_base_shield_supplied_enemy_units_state',
                }[name])
        self.assertEqual(ledger['N2328']['runtime_proof'], '/root/C07BaseShieldScansProof')
        self.assertEqual(
            ledger['N2328']['tests'],
            [
                'test_c07_base_shield_scans_registration',
                'test_all_c07_base_shield_scans_input_evidence_is_exact',
                'test_base_shield_scans_state',
                'test_reference_graph_and_actual_c07_base_shield_scans',
            ],
        )
        self.assertTrue(ledger['N2328']['deferred_exprs'])
        # This slice resolves the scan-fill half of the
        # BaseShield live-fill deferral (the rect bullet scan
        # + the nearby-enemies unit scan now run live over
        # frame candidates), so the old entry -- which said
        # both scans wait for a bullet-query / unit-query
        # slice -- is gone, replaced by an entry that keeps
        # only what is still missing: the live
        # Groups.bullet / Units queries that fill the frame
        # candidates, the absorb/repel/kill application onto
        # live bullets/units, the spark effect, and the
        # disabled early return.
        self.assertFalse(any(entry.startswith('BaseShield updateTile live fill (') and 'waits for a bullet-query slice' in entry for entry in ledger['N2328']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('BaseShield updateTile live fill (') and 'waits for a unit-query slice' in entry for entry in ledger['N2328']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BaseShield updateTile live fill (') for entry in ledger['N2328']['deferred_exprs']))
        self.assertTrue(any('no live Groups.bullet.intersect / Units.nearbyEnemies query fills the frame candidates yet' in entry for entry in ledger['N2328']['deferred_exprs']))

    def test_all_c07_base_shield_scans_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2328']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_base_shield_supplied_bullets_state_result.bullets': 'SourceBaseShieldBuildState.source_base_shield_supplied_bullets_state',
                    'source_base_shield_supplied_enemy_units_state_result.enemy_units': 'SourceBaseShieldBuildState.source_base_shield_supplied_enemy_units_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BaseShield.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/EntityGroup.java',
            'core/src/mindustry/entities/GroupDefs.java',
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta / within formulas live in Arc, not
        # Mindustry: Mathf.java and Position.java under
        # arc-upstream (the N2229 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Position.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8')
        for expr in ledger['N2328']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_shield_scans_state(self):
        base_shield = BASE_SHIELD_STATE.read_text(encoding='utf-8')
        # The bullet scan ports the Groups.bullet RECTANGLE
        # intersect (BaseShield.java:96,
        # `Groups.bullet.intersect(x - rad, y - rad, rad * 2f,
        # rad * 2f, bulletConsumer);`) as a broad-phase filter
        # only: a candidate is admitted when its CENTER falls
        # in [x +/- rad, y +/- rad], INCLUSIVE -- a rect, not
        # a circle, so a bullet at the rect corner (rad, rad)
        # is IN even though it is outside the radius circle
        # (the N2277 precedent). NO team / absorbable filter
        # here: the N2236 advance already does the enemy +
        # absorbable + STRICT within narrow check
        # (bulletConsumer, BaseShield.java:27-37). A candidate
        # without x/y is EXCLUDED (no center to test). The
        # intersect runs over the spatial bullet group
        # (EntityGroup.java:195, the consumer overload;
        # GroupDefs.java:9, QuadTree hitbox overlap) -- the
        # port tests centers, and the hitbox-overlap
        # refinement waits for its own slice.
        self.assertIn('static func source_base_shield_supplied_bullets_state', base_shield)
        self.assertIn('Groups.bullet.intersect(x - rad, y - rad, rad * 2f, rad * 2f, bulletConsumer);', base_shield)
        self.assertIn('public void intersect(float x, float y, float width, float height, Cons<? super T> out){', base_shield)
        self.assertIn('@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;', base_shield)
        self.assertIn('absf(float(candidate.get("x", 0.0)) - building_x) <= rad', base_shield)
        self.assertIn('absf(float(candidate.get("y", 0.0)) - building_y) <= rad', base_shield)
        self.assertIn('not candidate.has("x") or not candidate.has("y")', base_shield)
        # The unit scan ports the Units.nearbyEnemies radius
        # overload (Units.java:482-488): the rect scan
        # (`nearbyEnemies(team, x - radius, y - radius, radius
        # * 2f, radius * 2f, u -> {`, :483) is enemy-only by
        # construction, then the filter (`if(u.within(x, y,
        # radius + u.hitSize/2f)){`, :484) admits a unit whose
        # center is STRICTLY within radius + hitSize/2 of the
        # building (`return Mathf.dst2(getX(), getY(), x, y) <
        # dst*dst;`, Position.java:44-46): exactly at the range
        # is OUT. The BaseShield call passes rad + 10f
        # (BaseShield.java:97), so the scan range is rad + 10
        # + hitSize/2. A unit without a team is its own team
        # (never an enemy); a unit without x/y is EXCLUDED; a
        # unit without hit_size defaults to 0.0 (the N2226
        # repair-turret precedent). The advance checks no team
        # (the N2230 closestEnemy precedent) -- the scan is the
        # only team filter.
        self.assertIn('static func source_base_shield_supplied_enemy_units_state', base_shield)
        self.assertIn('Units.nearbyEnemies(team, x, y, rad + 10f, unitConsumer);', base_shield)
        self.assertIn('public static void nearbyEnemies(Team team, float x, float y, float radius, Cons<Unit> cons){', base_shield)
        self.assertIn('nearbyEnemies(team, x - radius, y - radius, radius * 2f, radius * 2f, u -> {', base_shield)
        self.assertIn('if(u.within(x, y, radius + u.hitSize/2f)){', base_shield)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', base_shield)
        self.assertIn('int(unit.get("team", team_id)) == team_id', base_shield)
        self.assertIn('unit.get("hit_size", 0.0)', base_shield)
        self.assertIn('not unit.has("x") or not unit.has("y")', base_shield)
        self.assertIn('rad + SOURCE_BASE_SHIELD_NEARBY_MARGIN + hit_size / 2.0', base_shield)
        self.assertIn('unit_dst2 < scan_range * scan_range', base_shield)
        # The rad problem (BaseShield.java:89-93): rad is
        # radius() = smoothRadius AFTER the lerpDelta fold
        # (`smoothRadius = Mathf.lerpDelta(smoothRadius, radius
        # * efficiency, 0.05f);`, :89; `float rad = radius();`,
        # :91), but the tick needs rad BEFORE the advance call
        # to run the scans. The driver computes rad_after with
        # the SAME shared helper + const the advance uses
        # (source_lerp_delta, progress * Time.delta CLAMPED,
        # Mathf.java:430-432) -- deterministic, the same
        # result the advance computes inside. The rad > 1 gate
        # (`if(rad > 1){`, :93) lives at the TICK: rad <= 1
        # skips both scans and the advance gets empty lists.
        self.assertIn('smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);', base_shield)
        self.assertIn('float rad = radius();', base_shield)
        self.assertIn('if(rad > 1){', base_shield)
        self.assertIn('public float radius(){', base_shield)
        self.assertIn('return smoothRadius;', base_shield)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', base_shield)
        self.assertIn('source_math_state.source_lerp_delta(float(frame.get("smooth_radius", SOURCE_BASE_SHIELD_SMOOTH_RADIUS_DEFAULT)), advance_shield_radius * float(frame.get("efficiency", 0.0)), SOURCE_BASE_SHIELD_SMOOTH_RADIUS_LERP, source_delta)', base_shield)
        self.assertIn('if scan_rad > SOURCE_BASE_SHIELD_ENGAGE_RADIUS:', base_shield)
        # The tick wires the scans into the advance: the frame
        # candidates (frame["bullet_candidates"] /
        # frame["enemy_unit_candidates"], default [] -- the
        # live Groups.bullet / Units queries still defer) are
        # filtered by the scan pures and passed into the N2236
        # advance instead of `[], []`.
        self.assertIn('frame.get("bullet_candidates", [])', base_shield)
        self.assertIn('frame.get("enemy_unit_candidates", [])', base_shield)
        self.assertIn('source_base_shield_supplied_bullets_state(frame.get("bullet_candidates", []), scan_rad, advance_building_x, advance_building_y)', base_shield)
        self.assertIn('source_base_shield_supplied_enemy_units_state(frame.get("enemy_unit_candidates", []), scan_rad, advance_building_x, advance_building_y, team_id)', base_shield)
        self.assertIn('source_base_shield_update_tile_advance_state(frame, source_delta, advance_shield_radius, advance_building_x, advance_building_y, scanned_bullets, scanned_enemy_units)', base_shield)
        # The documented limits now record the scans as live
        # (N2328); the live Groups.bullet / Units queries are
        # still frame inputs, and the absorb/repel/kill
        # application still waits for its own slice.
        self.assertIn('bullet + enemy-unit scans live (N2328)', base_shield)
        self.assertIn('updateTile advance live (N2236)', base_shield)
        # The proof's keys drive the pure bullet scan (a
        # bullet in the rect -- including the rect corner --
        # is admitted, a bullet outside the rect is excluded),
        # the pure unit scan (an enemy unit within rad + 10 +
        # hitSize/2, STRICT, is admitted; an out-of-range /
        # own-team unit is excluded), the rad <= 1 gate (both
        # scans empty on a collapsed shield), and the live
        # tick (the tick passes the scanned lists into the
        # advance, so a live shield absorbs / repels).
        proof = BASE_SHIELD_SCANS_PROOF.read_text(encoding='utf-8')
        for key in [
            'bullet_scan_admits_in_rect',
            'bullet_scan_excludes_out_of_rect',
            'unit_scan_admits_enemy_in_range',
            'unit_scan_excludes_out_of_range',
            'scans_empty_when_radius_small',
            'live_tick_passes_scanned_lists',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBaseShieldBuildState.gd")', proof)
        self.assertIn('base_shield_build_state.source_base_shield_supplied_bullets_state(', proof)
        self.assertIn('base_shield_build_state.source_base_shield_supplied_enemy_units_state(', proof)
        self.assertIn('base_shield_build_state.source_base_shield_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(BASE_SHIELD_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = BASE_SHIELD_SCANS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BaseShieldScansProof.gd', scene)
        self.assertIn('C07BaseShieldScansProof', scene)

    def test_reference_graph_and_actual_c07_base_shield_scans(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseShieldScansProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_SHIELD_SCANS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bullet_scan_admits_in_rect',
            'bullet_scan_excludes_out_of_rect',
            'unit_scan_admits_enemy_in_range',
            'unit_scan_excludes_out_of_range',
            'scans_empty_when_radius_small',
            'live_tick_passes_scanned_lists',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
