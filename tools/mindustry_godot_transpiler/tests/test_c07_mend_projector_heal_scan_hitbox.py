import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_HEAL_SCAN_HITBOX_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanHitboxProof.gd'
MEND_PROJECTOR_HEAL_SCAN_HITBOX_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanHitboxProof.tscn'


class C07MendProjectorHealScanHitboxTests(unittest.TestCase):
    def test_c07_mend_projector_heal_scan_hitbox_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2350']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_candidates_hitbox_state')
        # N2329 proved the eachBlock rect broad phase (the
        # candidate CENTER against the inclusive range*2
        # rect) and N2335 proved the within / privileged
        # narrow check chained after it -- but Java's
        # buildings.intersect is a QuadTree HITBOX overlap
        # query (BlockIndexer.java:345): the QuadTree admits
        # a building whose hitbox (a hitSize-sided square
        # centered on the building, BuildingComp.java:2293)
        # STRICTLY overlaps the query rect (QuadTree.
        # java:190-191 / Rect.java:274-276). A large-hitbox
        # building whose center sits outside the rect but
        # within range + hitSize/2 was dropped by the N2329
        # center test before the N2335 narrow check ever saw
        # it. N2350 is the broad phase itself: a new pure
        # filter by STRICT hitbox overlap, and the N2329
        # pure calls it INSTEAD of the rect center test (the
        # rect was an approximation of the port; Java-exact
        # is hitbox overlap). One new result symbol: the
        # hitbox-admitted candidate list.
        self.assertEqual(
            ledger['N2350']['source_symbols'],
            [
                'source_mend_projector_heal_candidates_hitbox_state_result.candidates',
            ],
        )
        for name in ledger['N2350']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'arc-core/src/arc/math/geom/Rect.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_candidates_hitbox_state')
        self.assertEqual(ledger['N2350']['runtime_proof'], '/root/C07MendProjectorHealScanHitboxProof')
        self.assertEqual(
            ledger['N2350']['tests'],
            [
                'test_c07_mend_projector_heal_scan_hitbox_registration',
                'test_all_c07_mend_projector_heal_scan_hitbox_input_evidence_is_exact',
                'test_mend_projector_heal_scan_hitbox_state',
                'test_reference_graph_and_actual_c07_mend_projector_heal_scan_hitbox',
            ],
        )
        self.assertTrue(ledger['N2350']['deferred_exprs'])
        # This slice RESOLVES the rect broad phase misses
        # large-hitbox buildings entry (#326 in the merged
        # advances-15 DEFERRED base) and adds NO new entry:
        # the broad phase is now Java-exact over the
        # supplied candidates; the only remaining scan gap
        # is the live building-index fill, which stays
        # deferred. The N2242 heal-effect / mendSound /
        # recentlyHealed entries stay deferred. Net -1+0 =
        # 331.
        self.assertFalse(any(entry.startswith('MendProjector heal scan rect broad phase misses large-hitbox buildings (') for entry in ledger['N2350']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan live building-index fill (') for entry in ledger['N2350']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal effect rows (') for entry in ledger['N2350']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector mendSound rows (') for entry in ledger['N2350']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector recentlyHealed rows (') for entry in ledger['N2350']['deferred_exprs']))
        self.assertEqual(len(ledger['N2350']['deferred_exprs']), 331)

    def test_all_c07_mend_projector_heal_scan_hitbox_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2350']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_candidates_hitbox_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/MendProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/ai/BlockIndexer.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/EntityGroup.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/QuadTree.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Rect.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2350']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_heal_scan_hitbox_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The hitbox broad phase (buildings.intersect is a
        # QuadTree hitbox overlap query, BlockIndexer.
        # java:345): the eachBlock float-range overload
        # intersects the team's buildingTree quadtree with
        # the rect (wx - range, wy - range, range*2f,
        # range*2f) -- WORLD units directly, no tilesize
        # factor -- and EntityGroup.intersect delegates to
        # the QuadTree (EntityGroup.java:195-198), which
        # admits a building whose HITBOX overlaps the query
        # rect (`hitbox(item);` / `if(tmp.overlaps(x, y,
        # width, height)){`, QuadTree.java:190-191) with the
        # STRICT Rect overlap (`return x < rx + rwidth &&
        # x + width > rx && y < ry + rheight && y + height
        # > ry;`, Rect.java:274-276). A building's hitbox
        # is a hitSize-sided square centered on the building
        # (`out.setCentered(x, y, block.size * tilesize,
        # block.size * tilesize);`, BuildingComp.java:2293),
        # with hitSize `return tile.block().size *
        # tilesize;` (BuildingComp.java:2048). The N2329
        # center-in-rect test was an approximation of the
        # port; the N2329 pure now calls this hitbox pure
        # INSTEAD. Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this test).
        self.assertIn('static func source_mend_projector_heal_candidates_hitbox_state', mend_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', mend_projector)
        self.assertIn('indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {', mend_projector)
        self.assertIn('buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {', mend_projector)
        self.assertIn('if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){', mend_projector)
        self.assertIn('public void intersect(float x, float y, float width, float height, Cons<? super T> out){', mend_projector)
        self.assertIn('tree.intersect(x, y, width, height, out);', mend_projector)
        self.assertIn('hitbox(item);', mend_projector)
        self.assertIn('if(tmp.overlaps(x, y, width, height)){', mend_projector)
        self.assertIn('return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;', mend_projector)
        self.assertIn('out.setCentered(x, y, block.size * tilesize, block.size * tilesize);', mend_projector)
        self.assertIn('return tile.block().size * tilesize;', mend_projector)
        # The pure returns exactly the one N2350 key, the
        # hitbox-admitted candidates in candidate order;
        # the overlap test is STRICT (a hitbox edge exactly
        # touching the rect edge does NOT overlap -- the
        # exclusion is the negated STRICT test on both
        # axes); a missing hit_size defaults to 0.0 (the
        # N2335 narrow precedent -- a degenerate point
        # hitbox, admitted only strictly inside); a missing
        # x or y excludes; a non-Dictionary entry is
        # excluded the same way; the admitted entries are
        # the candidate dicts themselves, never rewritten.
        self.assertIn('static func source_mend_projector_heal_candidates_hitbox_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:', mend_projector)
        self.assertIn('return {"candidates": in_range}', mend_projector)
        self.assertIn('float(candidate.get("hit_size", 0.0)) / 2.0', mend_projector)
        self.assertIn('if candidate_x - half_size >= building_x + real_range or candidate_x + half_size <= building_x - real_range:', mend_projector)
        self.assertIn('if candidate_y - half_size >= building_y + real_range or candidate_y + half_size <= building_y - real_range:', mend_projector)
        self.assertIn('if not (candidate is Dictionary):', mend_projector)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', mend_projector)
        self.assertIn('in_range.append(candidate)', mend_projector)
        # The N2329 pure keeps its signature and its
        # {candidates} return shape but DELEGATES to the
        # hitbox pure instead of the rect center test -- the
        # old inclusive center test is gone from this driver.
        self.assertIn('static func source_mend_projector_supplied_heal_candidates_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:', mend_projector)
        self.assertIn('return source_mend_projector_heal_candidates_hitbox_state(candidates, real_range, building_x, building_y)', mend_projector)
        self.assertNotIn('if dx > real_range or dy > real_range:', mend_projector)
        # The tick is UNCHANGED: it still calls the N2329
        # pure (now hitbox-backed) at the live realRange
        # from the post-advance phase_heat, chains the
        # N2335 narrow filter after it at the same realRange
        # and building position, and passes the NARROWED
        # list into the N2242 heal scan. The scan runs
        # before the heal_scan call and the result is still
        # recorded as last_heal_scan.
        self.assertIn('source_mend_projector_supplied_heal_candidates_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)', mend_projector)
        self.assertIn('source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)', mend_projector)
        self.assertIn('source_mend_projector_heal_scan_state(frame, narrowed_candidates.get("candidates", [])', mend_projector)
        self.assertIn('frame["last_heal_scan"] = heal_scan', mend_projector)
        self.assertLess(
            mend_projector.index('source_mend_projector_supplied_heal_candidates_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)'),
            mend_projector.index('source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)'),
        )
        self.assertLess(
            mend_projector.index('source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)'),
            mend_projector.index('source_mend_projector_heal_scan_state(frame, narrowed_candidates.get("candidates", [])'),
        )
        self.assertLess(
            mend_projector.index('source_mend_projector_update_tile_advance_state(frame, reload_value, time_delta, time_scale)'),
            mend_projector.index('source_mend_projector_supplied_heal_candidates_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)'),
        )
        # The documented limits now record the hitbox broad
        # phase as live; the N2329 range query, the N2335
        # within/privileged refinement, the N2242 heal scan,
        # the N2193 advance and the N2269 timer are
        # preserved, and the live building index still waits.
        self.assertIn('hitbox broad phase is live since N2350', mend_projector)
        self.assertIn('range query is live since N2329', mend_projector)
        self.assertIn('within/privileged refinement is live since N2335', mend_projector)
        self.assertIn('live building index', mend_projector)
        self.assertIn('static func source_mend_projector_heal_scan_state', mend_projector)
        self.assertIn('static func source_mend_projector_update_tile_advance_state', mend_projector)
        self.assertIn('static func source_mend_projector_timer_use_state', mend_projector)
        # The N2335 narrow pure is untouched: its signature
        # and its STRICT within + privileged filter are
        # unchanged -- the hitbox pure replaces the broad
        # phase BEFORE it, never inside it.
        self.assertIn('static func source_mend_projector_supplied_heal_candidates_narrow_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:', mend_projector)
        self.assertIn('return {"candidates": narrowed}', mend_projector)
        self.assertIn('if bool(candidate.get("privileged", false)):', mend_projector)
        self.assertIn('if dx * dx + dy * dy >= limit * limit:', mend_projector)
        self.assertIn('narrowed.append(candidate)', mend_projector)
        # The N2242 heal scan is untouched: its signature
        # keeps the candidates parameter and its damaged +
        # not-heal-suppressed predicate is unchanged.
        self.assertIn('static func source_mend_projector_heal_scan_state(frame: Dictionary, candidates: Array, charge_before: float, reload_value: float, range_value: float, heal_percent: float, phase_boost: float, phase_range_boost: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:', mend_projector)
        self.assertIn('if bool(entry.get("damaged", false)) and not bool(entry.get("heal_suppressed", false)):', mend_projector)
        # The proof's keys drive the hitbox pure (a
        # straddling hitbox is admitted even with its center
        # outside the rect -- the differentiator vs N2329; a
        # center on the edge with a real hitbox is admitted;
        # a degenerate hitSize-0 hitbox on the edge or
        # corner is dropped -- the STRICT boundary; a
        # missing hit_size defaults to 0.0, so a point on
        # the edge is dropped while a point strictly inside
        # is admitted; empty candidates give an empty list)
        # plus the live tick (a charged mender heals the
        # straddler the old rect would have dropped).
        proof = MEND_PROJECTOR_HEAL_SCAN_HITBOX_PROOF.read_text(encoding='utf-8')
        for key in [
            'hitbox_admits_straddling_hitbox',
            'hitbox_admits_edge_hitbox',
            'hitbox_drops_degenerate_edge_hitbox',
            'hitbox_defaults_missing_hit_size',
            'hitbox_empty_stays_empty',
            'live_tick_passes_hitbox_candidates',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The strict-boundary pins: a straddler at (144, 0)
        # with hit_size 16.0 is admitted by the pure; a
        # hitSize-0 hitbox with its center exactly on the
        # rect edge (140, 0) is dropped, while the same
        # center with hit_size 8.0 is admitted.
        self.assertIn('"x": 144.0, "y": 100.0, "hit_size": 16.0', proof)
        self.assertIn('"x": 140.0, "y": 100.0, "hit_size": 0.0', proof)
        self.assertIn('"x": 140.0, "y": 100.0, "hit_size": 8.0', proof)
        # The live tick seeds the full N2329/N2335 live-tick
        # frame (power_status 1.0, charge 199.5, heat 1.0,
        # phase_heat 0.5) and a straddling frame candidate
        # the old rect would drop.
        self.assertIn('projector_frame["power_status"] = 1.0', proof)
        self.assertIn('projector_frame["charge"] = 199.5', proof)
        self.assertIn('projector_frame["heat"] = 1.0', proof)
        self.assertIn('projector_frame["phase_heat"] = 0.5', proof)
        self.assertIn('"hit_size": 16.0', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        self.assertIn('mend_projector_build_state.source_mend_projector_heal_candidates_hitbox_state(', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = MEND_PROJECTOR_HEAL_SCAN_HITBOX_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorHealScanHitboxProof.gd', scene)
        self.assertIn('[node name="C07MendProjectorHealScanHitboxProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mend_projector_heal_scan_hitbox(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorHealScanHitboxProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_HEAL_SCAN_HITBOX_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'hitbox_admits_straddling_hitbox',
            'hitbox_admits_edge_hitbox',
            'hitbox_drops_degenerate_edge_hitbox',
            'hitbox_defaults_missing_hit_size',
            'hitbox_empty_stays_empty',
            'live_tick_passes_hitbox_candidates',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
