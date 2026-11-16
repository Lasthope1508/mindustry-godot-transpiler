import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_BULLET_SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerBulletScanProof.gd'
SHOCKWAVE_TOWER_BULLET_SCAN_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerBulletScanProof.tscn'


class C07ShockwaveTowerBulletScanTests(unittest.TestCase):
    def test_c07_shockwave_tower_bullet_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2327']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_supplied_bullets_state')
        # N2247 ported the updateTile advance (the fire gate
        # over the already-charged counter, the bullet scan
        # over an explicit candidate list, the wave damage,
        # the fire reset and the heat decay) and N2318 wired
        # the timerCheck cadence live -- but the scan itself
        # was a SUPPLIED list: the live Groups.bullet.
        # intersect (ShockwaveTower.java:75-79) was deferred,
        # so the tick passed [] and a live tower never fired.
        # N2327 is the scan: a pure filter over the
        # frame-supplied bullet candidates by the exact Java
        # predicates -- in the range*2 RECT
        # (`Groups.bullet.intersect(x - range, y - range,
        # range * 2, range * 2, b -> {`, ShockwaveTower.
        # java:75), enemy team and hittable (`if(b.team !=
        # team && b.type.hittable){`, ShockwaveTower.java:76)
        # -- returning the admitted list, which the tick
        # passes into the N2247 advance before its call. One
        # new result symbol: the admitted bullets list.
        self.assertEqual(
            ledger['N2327']['source_symbols'],
            [
                'source_shockwave_tower_supplied_bullets_state_result.bullets',
            ],
        )
        for name in ledger['N2327']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_supplied_bullets_state')
        self.assertEqual(ledger['N2327']['runtime_proof'], '/root/C07ShockwaveTowerBulletScanProof')
        self.assertEqual(
            ledger['N2327']['tests'],
            [
                'test_c07_shockwave_tower_bullet_scan_registration',
                'test_all_c07_shockwave_tower_bullet_scan_input_evidence_is_exact',
                'test_shockwave_tower_bullet_scan_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan',
            ],
        )
        self.assertTrue(ledger['N2327']['deferred_exprs'])
        # The live bullet scan fill entry is resolved by this
        # slice, so it is gone from the carried-forward list;
        # the live bullet QUERY entry is new (no live query
        # fills frame["bullet_candidates"] yet); the timer
        # first-fire deviation and the wave damage
        # application entries stay.
        self.assertFalse(any(entry.startswith('ShockwaveTower updateTile live bullet scan fill (') for entry in ledger['N2327']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower live bullet query (') for entry in ledger['N2327']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower timer-check first-fire deviation (') for entry in ledger['N2327']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave damage application on live bullets (') for entry in ledger['N2327']['deferred_exprs']))
        self.assertEqual(len(ledger['N2327']['deferred_exprs']), 325)

    def test_all_c07_shockwave_tower_bullet_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2327']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_supplied_bullets_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
            'core/src/mindustry/entities/EntityGroup.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The QuadTree intersect / Rect overlap formulas live
        # in Arc, not Mindustry: QuadTree.java and Rect.java
        # under arc-upstream (the N2318 Interval/Time
        # precedent).
        upstream['arc-core/src/arc/math/geom/QuadTree.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/QuadTree.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Rect.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Rect.java').read_text(encoding='utf-8')
        for expr in ledger['N2327']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_bullet_scan_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure live bullet scan (ShockwaveTowerBuild.
        # updateTile(), ShockwaveTower.java:75-79): at
        # fire-gate time Java clears (`targets.clear();`,
        # ShockwaveTower.java:74) and scans
        # `Groups.bullet.intersect(x - range, y - range,
        # range * 2, range * 2, b -> {` /
        # `if(b.team != team && b.type.hittable){` /
        # `targets.add(b);` (ShockwaveTower.java:75-77). The
        # scan is a RECTANGLE intersect over the range*2 box
        # -- NOT a circle: a bullet at the rect corner
        # (range, range) is IN even though its distance
        # exceeds range. The intersect visits the spatial
        # bullet group (EntityGroup.java:195, `public void
        # intersect(float x, float y, float width, float
        # height, Cons<? super T> out){`, delegating to
        # `tree.intersect(x, y, width, height, out);`,
        # EntityGroup.java:198); the QuadTree admits a bullet
        # whose HITBOX overlaps the query rect (`hitbox(item);`
        # / `if(tmp.overlaps(x, y, width, height)){`,
        # QuadTree.java:190-191) with the STRICT Rect overlap
        # (`return x < rx + rwidth && x + width > rx && y <
        # ry + rheight && y + height > ry;`, Rect.java:274-276);
        # a bullet's hitbox is its type hitSize (`public float
        # hitSize = 4;`, BulletType.java:43). DOCUMENTED
        # DEVIATION (the N2277 precedent): the port tests the
        # bullet CENTER against the rect (INCLUSIVE bounds)
        # because the candidate dict carries no hitbox. The
        # range is the class `public float range = 110f;`
        # (ShockwaveTower.java:25), overridden by the def
        # `range = 170f;` (Blocks.java:2043); the pure takes
        # it as a parameter and stays def-agnostic. hittable
        # lives on the bullet TYPE (`public boolean hittable
        # = true;`, BulletType.java:143, default true),
        # carried on the candidate dict; the bullet dict
        # contract (the N2212 fixture precedent) is x / y /
        # team / hittable / damage (`@Import float x, y,
        # damage, lastX, lastY, time, lifetime;`,
        # BulletComp.java:31). Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_shockwave_tower_supplied_bullets_state', shockwave_tower)
        self.assertIn('Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', shockwave_tower)
        self.assertIn('if(b.team != team && b.type.hittable){', shockwave_tower)
        self.assertIn('targets.add(b);', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('public boolean hittable = true;', shockwave_tower)
        self.assertIn('public void intersect(float x, float y, float width, float height, Cons<? super T> out){', shockwave_tower)
        self.assertIn('tree.intersect(x, y, width, height, out);', shockwave_tower)
        self.assertIn('hitbox(item);', shockwave_tower)
        self.assertIn('if(tmp.overlaps(x, y, width, height)){', shockwave_tower)
        self.assertIn('return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;', shockwave_tower)
        self.assertIn('@Import float x, y, damage, lastX, lastY, time, lifetime;', shockwave_tower)
        self.assertIn('public float hitSize = 4;', shockwave_tower)
        # The pure returns exactly the one N2327 key, the
        # admitted bullets in candidate order; the rect test
        # is INCLUSIVE on both axes (a center exactly on the
        # edge counts); a missing x or y excludes; a missing
        # team reads as the tower's own team (the N2236
        # precedent); a missing hittable reads as true (the
        # BulletType default); the tower team is an explicit
        # parameter (the pure reads no frame).
        self.assertIn('static func source_shockwave_tower_supplied_bullets_state(candidates: Array, range_value: float, tower_x: float, tower_y: float, tower_team: int) -> Dictionary:', shockwave_tower)
        self.assertIn('return {"bullets": bullets}', shockwave_tower)
        self.assertIn('if bullet_x < tower_x - range_value or bullet_x > tower_x + range_value:', shockwave_tower)
        self.assertIn('if bullet_y < tower_y - range_value or bullet_y > tower_y + range_value:', shockwave_tower)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', shockwave_tower)
        self.assertIn('int(candidate.get("team", tower_team)) == tower_team', shockwave_tower)
        self.assertIn('bool(candidate.get("hittable", true))', shockwave_tower)
        # The tick wires the scan BEFORE the advance (the
        # N2306 fill-before-advance pattern): the frame
        # bullet candidates (default [] -- no candidates, the
        # Java no-bullets-in-range outcome) are filtered by
        # the pure at the def range from the live tower
        # position (origin cell + block offset, the N2306
        # RepairTower precedent: Building x/y are
        # tile.drawx()/drawy(), BuildingComp.java:124), and
        # the filtered list reaches the advance call -- the
        # empty-list literal is gone. N2340 follow-through:
        # the hitbox refinement now chains between the rect
        # scan and the advance, so the advance takes the
        # REFINED list (the rect call itself is unchanged).
        self.assertIn('const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")', shockwave_tower)
        self.assertIn('frame.get("bullet_candidates", [])', shockwave_tower)
        self.assertIn('source_shockwave_tower_supplied_bullets_state(scan_candidates, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y, team_id)', shockwave_tower)
        self.assertIn('var scanned_bullets: Array = scan.get("bullets", [])', shockwave_tower)
        self.assertIn('source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)', shockwave_tower)
        self.assertIn('var refined_bullets: Array = refinement.get("bullets", [])', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER, refined_bullets, check_ready)', shockwave_tower)
        self.assertIn('source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)', shockwave_tower)
        self.assertIn('source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)', shockwave_tower)
        self.assertLess(
            shockwave_tower.index('source_shockwave_tower_supplied_bullets_state(scan_candidates, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y, team_id)'),
            shockwave_tower.index('source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)'),
        )
        self.assertLess(
            shockwave_tower.index('source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)'),
            shockwave_tower.index('source_shockwave_tower_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds)'),
        )
        # The documented limits now record the scan as live
        # and the remaining deferral is the live bullet
        # QUERY (Groups.bullet), not the scan; the old "no
        # live fire until the bullet-query slice lands" text
        # is gone.
        self.assertIn('live bullet scan is live (N2327)', shockwave_tower)
        self.assertIn('updateTile advance live (N2247)', shockwave_tower)
        self.assertIn('timerCheck cadence live (N2318)', shockwave_tower)
        self.assertIn('shouldConsume gate live (N2187)', shockwave_tower)
        self.assertNotIn('the live tick still passes an empty candidate list', shockwave_tower)
        self.assertNotIn('no live fire happens until the bullet-query slice lands', shockwave_tower)
        self.assertNotIn('the live bullet scan still defers', shockwave_tower)
        # The N2247 advance is untouched: its signature keeps
        # the bullet_candidates parameter and its fire gate /
        # wave / heat lines are unchanged -- the scan wires
        # BEFORE its call, never inside it.
        self.assertIn('static func source_shockwave_tower_update_tile_advance_state(frame: Dictionary, source_delta: float, reload: float, bullet_damage: float, falloff_count: float, cooldown_multiplier: float, bullet_candidates: Array, check_ready: bool) -> Dictionary:', shockwave_tower)
        self.assertIn('if potential_efficiency > 0.0 and reload_counter >= reload and check_ready:', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_timer_check_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_should_consume_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_power_status_row_state', shockwave_tower)
        # The proof's keys drive the pure scan (an enemy
        # hittable bullet in the rect is admitted, with the
        # rect corner and the inclusive edge; out-of-rect on
        # either axis is excluded; own team -- including a
        # missing team -- is excluded; non-hittable is
        # excluded; empty candidates give an empty scan) plus
        # the live tick (a placed tower fires its wave from
        # the scanned bullets).
        proof = SHOCKWAVE_TOWER_BULLET_SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'scan_admits_enemy_hittable_in_rect',
            'scan_excludes_out_of_rect',
            'scan_excludes_own_team',
            'scan_excludes_non_hittable',
            'empty_candidates_empty',
            'live_tick_passes_scanned_bullets',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The rect-not-circle pin: the (170, 170) corner is
        # admitted (distance ~240 > range 170), and the
        # class-range 110f case excludes the bullet at 150
        # that the def range 170f admits.
        self.assertIn('"x": 170.0, "y": 170.0', proof)
        self.assertIn('scan.call([{"id": "mid", "team": 2, "hittable": true, "damage": 500.0, "x": 150.0, "y": 0.0}], 110.0, 0.0, 0.0, 1)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_supplied_bullets_state(', proof)
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('tower.set_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, 1)', proof)
        scene = SHOCKWAVE_TOWER_BULLET_SCAN_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ShockwaveTowerBulletScanProof.gd', scene)
        self.assertIn('[node name="C07ShockwaveTowerBulletScanProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerBulletScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_BULLET_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'scan_admits_enemy_hittable_in_rect',
            'scan_excludes_out_of_rect',
            'scan_excludes_own_team',
            'scan_excludes_non_hittable',
            'empty_candidates_empty',
            'live_tick_passes_scanned_bullets',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
