import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_BULLET_SCAN_HITBOX_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerBulletScanHitboxProof.gd'
SHOCKWAVE_TOWER_BULLET_SCAN_HITBOX_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerBulletScanHitboxProof.tscn'


class C07ShockwaveTowerBulletScanHitboxTests(unittest.TestCase):
    def test_c07_shockwave_tower_bullet_scan_hitbox_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2340']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_supplied_bullets_hitbox_state')
        # N2327 proved the rect broad phase (the bullet
        # CENTER against the inclusive range*2 rect) -- but
        # Groups.bullet.intersect is a QuadTree HITBOX
        # overlap query (EntityGroup.java:195), admitting a
        # bullet whose hitbox (type hitSize, BulletType.
        # java:43, a hitSize-sided square centered on the
        # bullet, HitboxComp.java:65-67) STRICTLY overlaps
        # the query rect (QuadTree.java:190-191 /
        # Rect.java:274-276). N2340 is the refinement: a
        # pure filter chained AFTER the N2327 rect scan
        # (rect -> hitbox, the N2335 pattern), wired into
        # the tick between the rect scan and the N2247
        # advance, passing the refined list into the
        # advance. One new result symbol: the refined
        # bullets list.
        self.assertEqual(
            ledger['N2340']['source_symbols'],
            [
                'source_shockwave_tower_supplied_bullets_hitbox_state_result.bullets',
            ],
        )
        for name in ledger['N2340']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'arc-core/src/arc/math/geom/Rect.java')
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_supplied_bullets_hitbox_state')
        self.assertEqual(ledger['N2340']['runtime_proof'], '/root/C07ShockwaveTowerBulletScanHitboxProof')
        self.assertEqual(
            ledger['N2340']['tests'],
            [
                'test_c07_shockwave_tower_bullet_scan_hitbox_registration',
                'test_all_c07_shockwave_tower_bullet_scan_hitbox_input_evidence_is_exact',
                'test_shockwave_tower_bullet_scan_hitbox_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan_hitbox',
            ],
        )
        self.assertTrue(ledger['N2340']['deferred_exprs'])
        # This slice RESOLVES the center-in-rect vs QuadTree
        # hitbox overlap refinement entry (#321 in the
        # merged advances-14 DEFERRED base) and adds ONE
        # deferral: the N2327 rect broad phase still drops
        # a bullet whose center sits outside the rect but
        # whose hitbox straddles the edge before the
        # refinement ever sees it -- Java's intersect is a
        # QuadTree hitbox overlap query, so Java admits it.
        # The live bullet query, the timer first-fire
        # deviation and the wave damage application entries
        # stay deferred. Net -1+1 = 334.
        self.assertFalse(any(entry.startswith('ShockwaveTower bullet scan center-in-rect vs QuadTree hitbox overlap refinement (') for entry in ledger['N2340']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower bullet scan rect broad phase drops straddling hitboxes (') for entry in ledger['N2340']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower live bullet query (') for entry in ledger['N2340']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower timer-check first-fire deviation (') for entry in ledger['N2340']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave damage application on live bullets (') for entry in ledger['N2340']['deferred_exprs']))
        self.assertEqual(len(ledger['N2340']['deferred_exprs']), 334)

    def test_all_c07_shockwave_tower_bullet_scan_hitbox_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2340']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_supplied_bullets_hitbox_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/bullet/BulletType.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/HitboxComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/EntityGroup.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/QuadTree.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Rect.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2340']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_bullet_scan_hitbox_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The hitbox refinement (Groups.bullet.intersect is
        # a QuadTree hitbox overlap query, EntityGroup.
        # java:195, `public void intersect(float x, float y,
        # float width, float height, Cons<? super T> out){`,
        # delegating to `tree.intersect(x, y, width,
        # height, out);`, EntityGroup.java:198; the QuadTree
        # admits a bullet whose HITBOX overlaps the query
        # rect (`hitbox(item);` / `if(tmp.overlaps(x, y,
        # width, height)){`, QuadTree.java:190-191) with the
        # STRICT Rect overlap (`return x < rx + rwidth &&
        # x + width > rx && y < ry + rheight && y + height
        # > ry;`, Rect.java:274-276); a bullet's hitbox is
        # its type hitSize (`public float hitSize = 4;`,
        # BulletType.java:43, set onto the bullet at spawn,
        # `bullet.hitSize = hitSize;`, BulletType.java:970),
        # a hitSize-sided square centered on the bullet
        # (`rect.setCentered(x, y, hitSize, hitSize);`,
        # HitboxComp.java:67). The N2327 rect pure tests the
        # bullet CENTER against the inclusive rect, so this
        # refinement chains AFTER it (the N2335 pattern) and
        # filters hitbox overlap ONLY -- it does not
        # re-filter team / hittable (the N2327 pure already
        # did). A missing hit_size reads as the BulletType
        # default 4.0. Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_shockwave_tower_supplied_bullets_hitbox_state', shockwave_tower)
        self.assertIn('Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', shockwave_tower)
        self.assertIn('public void intersect(float x, float y, float width, float height, Cons<? super T> out){', shockwave_tower)
        self.assertIn('tree.intersect(x, y, width, height, out);', shockwave_tower)
        self.assertIn('hitbox(item);', shockwave_tower)
        self.assertIn('if(tmp.overlaps(x, y, width, height)){', shockwave_tower)
        self.assertIn('return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;', shockwave_tower)
        self.assertIn('public float hitSize = 4;', shockwave_tower)
        self.assertIn('bullet.hitSize = hitSize;', shockwave_tower)
        self.assertIn('rect.setCentered(x, y, hitSize, hitSize);', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        # The pure returns exactly the one N2340 key, the
        # refined bullets in candidate order; the overlap
        # test is STRICT (a hitbox edge exactly touching
        # the rect edge does NOT overlap -- the exclusion
        # is the negated STRICT test on both axes); a
        # missing hit_size defaults to 4.0 (the BulletType
        # default); a missing x or y excludes; a
        # non-Dictionary entry is excluded the same way;
        # the admitted entries are the candidate dicts
        # themselves, never rewritten.
        self.assertIn('static func source_shockwave_tower_supplied_bullets_hitbox_state(candidates: Array, range_value: float, tower_x: float, tower_y: float) -> Dictionary:', shockwave_tower)
        self.assertIn('return {"bullets": refined}', shockwave_tower)
        self.assertIn('float(candidate.get("hit_size", 4.0))', shockwave_tower)
        self.assertIn('if bullet_x - half_size >= tower_x + range_value or bullet_x + half_size <= tower_x - range_value:', shockwave_tower)
        self.assertIn('if bullet_y - half_size >= tower_y + range_value or bullet_y + half_size <= tower_y - range_value:', shockwave_tower)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', shockwave_tower)
        self.assertIn('refined.append(candidate)', shockwave_tower)
        # The tick wires the refinement AFTER the N2327 rect
        # scan and BEFORE the N2247 advance (the N2335
        # chain pattern): the rect-admitted list is refined
        # at the SAME def range from the SAME live tower
        # position, and the refined list reaches the advance
        # call -- the rect-only list no longer does.
        self.assertIn('source_shockwave_tower_supplied_bullets_state(scan_candidates, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y, team_id)', shockwave_tower)
        self.assertIn('var scanned_bullets: Array = scan.get("bullets", [])', shockwave_tower)
        self.assertIn('source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)', shockwave_tower)
        self.assertIn('var refined_bullets: Array = refinement.get("bullets", [])', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER, refined_bullets, check_ready)', shockwave_tower)
        self.assertLess(
            shockwave_tower.index('source_shockwave_tower_supplied_bullets_state(scan_candidates, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y, team_id)'),
            shockwave_tower.index('source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)'),
        )
        self.assertLess(
            shockwave_tower.index('source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)'),
            shockwave_tower.index('source_shockwave_tower_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds)'),
        )
        # The documented limits now record the refinement as
        # live and the remaining deferral is the live bullet
        # QUERY (Groups.bullet) plus the rect broad phase
        # dropping straddlers, not the refinement.
        self.assertIn('hitbox refinement is live (N2340)', shockwave_tower)
        self.assertIn('live bullet scan is live (N2327)', shockwave_tower)
        self.assertIn('updateTile advance live (N2247)', shockwave_tower)
        self.assertIn('timerCheck cadence live (N2318)', shockwave_tower)
        self.assertIn('shouldConsume gate live (N2187)', shockwave_tower)
        # The N2327 rect pure is untouched: its signature
        # keeps the five parameters and its inclusive
        # center test + exact return are unchanged -- the
        # refinement chains AFTER its call, never inside it.
        self.assertIn('static func source_shockwave_tower_supplied_bullets_state(candidates: Array, range_value: float, tower_x: float, tower_y: float, tower_team: int) -> Dictionary:', shockwave_tower)
        self.assertIn('return {"bullets": bullets}', shockwave_tower)
        self.assertIn('if bullet_x < tower_x - range_value or bullet_x > tower_x + range_value:', shockwave_tower)
        self.assertIn('if bullet_y < tower_y - range_value or bullet_y > tower_y + range_value:', shockwave_tower)
        # The N2247 advance is untouched: its signature keeps
        # the bullet_candidates parameter and its fire gate /
        # wave / heat lines are unchanged -- the refinement
        # wires BEFORE its call, never inside it.
        self.assertIn('static func source_shockwave_tower_update_tile_advance_state(frame: Dictionary, source_delta: float, reload: float, bullet_damage: float, falloff_count: float, cooldown_multiplier: float, bullet_candidates: Array, check_ready: bool) -> Dictionary:', shockwave_tower)
        self.assertIn('if potential_efficiency > 0.0 and reload_counter >= reload and check_ready:', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_timer_check_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_should_consume_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_power_status_row_state', shockwave_tower)
        # The proof's keys drive the pure refinement (a
        # straddling hitbox is admitted even with its center
        # outside the rect; a center on the edge with a
        # real hitbox is admitted; a degenerate hitSize-0
        # hitbox on the edge or corner is dropped -- the
        # STRICT boundary; a missing hit_size defaults to
        # the BulletType 4.0; empty candidates give an empty
        # refinement) plus the live tick (a placed tower
        # fires its wave from the refined bullets -- the
        # degenerate edge bullet the N2327 rect admits is
        # dropped by the refinement, so the wave hits only
        # the refined targets).
        proof = SHOCKWAVE_TOWER_BULLET_SCAN_HITBOX_PROOF.read_text(encoding='utf-8')
        for key in [
            'refine_admits_straddling_hitbox',
            'refine_admits_edge_hitbox',
            'refine_drops_degenerate_edge_hitbox',
            'refine_defaults_missing_hit_size',
            'refine_empty_stays_empty',
            'live_tick_passes_refined_bullets',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The strict-boundary pins: a hitSize-0 bullet with
        # its center exactly on the rect edge (170, 0) is
        # dropped, while the same center with hit_size 4.0
        # is admitted; a straddler at (172, 0) with
        # hit_size 8.0 is admitted by the pure.
        self.assertIn('"x": 170.0, "y": 0.0, "hit_size": 0.0', proof)
        self.assertIn('"x": 170.0, "y": 0.0, "hit_size": 4.0', proof)
        self.assertIn('"x": 172.0, "y": 0.0, "hit_size": 8.0', proof)
        # The live tick MUST seed cyanogen (the N2331
        # lesson: the required cyanogen row folds efficiency
        # 0 without it, so the tower never charges or fires).
        self.assertIn('source_set_state(tower_liquids, cyanogen_id, 10.0)', proof)
        self.assertIn('source_initialize_building_liquids_state(tower, true, catalog)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_supplied_bullets_hitbox_state(', proof)
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('tower.set_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, 1)', proof)
        scene = SHOCKWAVE_TOWER_BULLET_SCAN_HITBOX_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ShockwaveTowerBulletScanHitboxProof.gd', scene)
        self.assertIn('[node name="C07ShockwaveTowerBulletScanHitboxProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan_hitbox(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerBulletScanHitboxProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_BULLET_SCAN_HITBOX_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'refine_admits_straddling_hitbox',
            'refine_admits_edge_hitbox',
            'refine_drops_degenerate_edge_hitbox',
            'refine_defaults_missing_hit_size',
            'refine_empty_stays_empty',
            'live_tick_passes_refined_bullets',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
