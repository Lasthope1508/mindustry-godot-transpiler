import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_HEAL_SCAN_RANGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanRangeProof.gd'
MEND_PROJECTOR_HEAL_SCAN_RANGE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanRangeProof.tscn'


class C07MendProjectorHealScanRangeTests(unittest.TestCase):
    def test_c07_mend_projector_heal_scan_range_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2329']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_supplied_heal_candidates_state')
        # N2242 proved the heal scan (the realRange fold, the
        # damaged + not-heal-suppressed predicate, the heal
        # formula, the `any` flag) -- but took its candidate
        # list explicit with NO range filter: the live
        # indexer range query was deferred and the live tick
        # passed []. N2329 is the range half: a pure filter
        # over the frame-supplied heal candidates by the
        # eachBlock rect (BlockIndexer.java:345, world units
        # directly, half-side realRange, INCLUSIVE,
        # center-in-rect -- the N2277 precedent), wired into
        # the tick after the advance (realRange needs the
        # post-advance phase_heat) and passed into the N2242
        # heal scan. One new result symbol: the ranged
        # candidate list.
        self.assertEqual(
            ledger['N2329']['source_symbols'],
            [
                'source_mend_projector_supplied_heal_candidates_state_result.candidates',
            ],
        )
        for name in ledger['N2329']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_supplied_heal_candidates_state')
        self.assertEqual(ledger['N2329']['runtime_proof'], '/root/C07MendProjectorHealScanRangeProof')
        self.assertEqual(
            ledger['N2329']['tests'],
            [
                'test_c07_mend_projector_heal_scan_range_registration',
                'test_all_c07_mend_projector_heal_scan_range_input_evidence_is_exact',
                'test_mend_projector_heal_scan_range_state',
                'test_reference_graph_and_actual_c07_mend_projector_heal_scan_range',
            ],
        )
        self.assertTrue(ledger['N2329']['deferred_exprs'])
        # This slice RESOLVES the live range query entry (the
        # rect filter is live and the tick passes the ranged
        # list into the heal scan) and adds TWO deferrals:
        # the live building-index fill (nothing fills
        # frame["heal_candidates"] yet) and the within /
        # privileged refinement (Java's float-range overload
        # admits only b.within(range + hitSize/2) + pred +
        # !privileged past the rect broad phase, so the
        # center-in-rect port admits corners Java rejects).
        # The N2242 heal-effect / mendSound / recentlyHealed
        # entries stay deferred.
        self.assertFalse(any(entry.startswith('MendProjector heal scan range query (') for entry in ledger['N2329']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan live building-index fill (') for entry in ledger['N2329']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan within / privileged refinement (') for entry in ledger['N2329']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal effect rows (') for entry in ledger['N2329']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector mendSound rows (') for entry in ledger['N2329']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector recentlyHealed rows (') for entry in ledger['N2329']['deferred_exprs']))

    def test_all_c07_mend_projector_heal_scan_range_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2329']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_supplied_heal_candidates_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/MendProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/ai/BlockIndexer.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Position.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2329']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_heal_scan_range_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The range query pure (MendProjector.java:106-122):
        # `float realRange = range + phaseHeat *
        # phaseRangeBoost;` then `indexer.eachBlock(this,
        # realRange, ...)` visits the same-team buildings in
        # range. The float-range overload
        # (BlockIndexer.java:324-328) delegates to the
        # (team, wx, wy, range) form, which intersects the
        # team's buildingTree quadtree with the rect
        # (wx - range, wy - range, range*2f, range*2f) --
        # WORLD units directly, no tilesize factor -- and
        # then admits only `b.within(wx, wy, range +
        # b.hitSize() / 2f) && pred.get(b) &&
        # !b.block.privileged` (BlockIndexer.java:345-346),
        # with within a STRICT dst2 < dst^2 circle
        # (Position.java:44-46). Java's intersect is a
        # QuadTree HITBOX overlap query, so since N2350 this
        # pure delegates to the hitbox broad phase
        # (source_mend_projector_heal_candidates_hitbox_
        # state, STRICT Rect.overlaps, Rect.java:274-276)
        # instead of the N2329 center-in-rect test -- a
        # real building centered on the rect edge is
        # admitted through its hitbox, while a degenerate
        # hitSize-0 hitbox on the edge is dropped.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_mend_projector_supplied_heal_candidates_state', mend_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', mend_projector)
        self.assertIn('indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {', mend_projector)
        self.assertIn('public boolean eachBlock(Teamc team, float range, Boolf<Building> pred, Cons<Building> cons){', mend_projector)
        self.assertIn('return eachBlock(team.team(), team.getX(), team.getY(), range, pred, cons);', mend_projector)
        self.assertIn('public boolean eachBlock(@Nullable Team team, float wx, float wy, float range, Boolf<Building> pred, Cons<Building> cons){', mend_projector)
        self.assertIn('buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {', mend_projector)
        self.assertIn('if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){', mend_projector)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', mend_projector)
        self.assertIn('public float range = 60f;', mend_projector)
        self.assertIn('public float phaseRangeBoost = 50f;', mend_projector)
        self.assertIn('range = 40f;', mend_projector)
        self.assertIn('phaseRangeBoost = 20f;', mend_projector)
        self.assertIn('range = 85f;', mend_projector)
        # The pure returns exactly the one N2329 key, the
        # ranged candidate list in candidate order. The
        # filter is RANGE ONLY: it does not filter damaged /
        # heal_suppressed (the N2242 heal scan already does),
        # it never rewrites an entry (damaged /
        # heal_suppressed / max_health ride through
        # untouched), a missing x or y key EXCLUDES the
        # candidate, and a non-Dictionary entry is excluded
        # the same way. Since N2350 the pure DELEGATES to
        # the hitbox broad phase instead of the rect center
        # test: the admission is STRICT hitbox overlap, so
        # a straddling hitbox is admitted even with its
        # center outside the rect, and a degenerate
        # hitSize-0 hitbox exactly on the edge is dropped.
        self.assertIn('return {"candidates": in_range}', mend_projector)
        self.assertIn('return source_mend_projector_heal_candidates_hitbox_state(candidates, real_range, building_x, building_y)', mend_projector)
        self.assertIn('if candidate_x - half_size >= building_x + real_range or candidate_x + half_size <= building_x - real_range:', mend_projector)
        self.assertIn('if candidate_y - half_size >= building_y + real_range or candidate_y + half_size <= building_y - real_range:', mend_projector)
        self.assertNotIn('if dx > real_range or dy > real_range:', mend_projector)
        self.assertIn('if not (candidate is Dictionary):', mend_projector)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', mend_projector)
        self.assertIn('in_range.append(candidate)', mend_projector)
        # The tick wires the scan AFTER the advance (the
        # N2242 heal_scan call site): realRange needs the
        # post-advance phase_heat, so the tick computes it
        # from the post-advance frame + the block props with
        # the class defaults (range 60f, phaseRangeBoost 50f,
        # MendProjector.java:27/30) -- the SAME formula the
        # heal scan pure uses internally -- filters the frame
        # heal candidates (default [] -- no candidates, the
        # Java no-buildings-in-range outcome) from the live
        # building position (origin cell + block offset, the
        # N2306 RepairTower precedent: Building x/y are
        # tile.drawx()/drawy(), BuildingComp.java:124), and
        # passes the ranged list into the heal scan instead
        # of []. The scan runs before the heal_scan call and
        # the result is still recorded as last_heal_scan.
        # N2335 follow-through: the narrow filter now chains
        # between the broad phase and the heal scan, so the
        # heal scan takes the NARROWED list (the broad-phase
        # call itself is unchanged).
        self.assertIn('const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")', mend_projector)
        self.assertIn('var scan_real_range: float = scan_range + float(frame.get("phase_heat", 0.0)) * scan_phase_range_boost', mend_projector)
        self.assertIn('frame.get("heal_candidates", [])', mend_projector)
        self.assertIn('source_mend_projector_supplied_heal_candidates_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)', mend_projector)
        self.assertIn('source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)', mend_projector)
        self.assertIn('source_mend_projector_heal_scan_state(frame, narrowed_candidates.get("candidates", [])', mend_projector)
        self.assertIn('source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)', mend_projector)
        self.assertIn('source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)', mend_projector)
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
        # The documented limits now record the range query as
        # live and the remaining deferral (the live building
        # index that would fill frame["heal_candidates"]);
        # the N2242 heal scan, the N2193 advance and the
        # N2269 timer are preserved, and the old "no
        # candidates" text is gone.
        self.assertIn('range query is live since N2329', mend_projector)
        self.assertIn('live building index', mend_projector)
        self.assertNotIn('the live tick passes no candidates', mend_projector)
        self.assertNotIn('the range query stays deferred', mend_projector)
        self.assertIn('static func source_mend_projector_heal_scan_state', mend_projector)
        self.assertIn('static func source_mend_projector_update_tile_advance_state', mend_projector)
        self.assertIn('static func source_mend_projector_timer_use_state', mend_projector)
        # The N2242 heal scan is untouched: its signature
        # keeps the candidates parameter and its damaged +
        # not-heal-suppressed predicate is unchanged -- the
        # range filter wires BEFORE its call, never inside it.
        self.assertIn('static func source_mend_projector_heal_scan_state(frame: Dictionary, candidates: Array, charge_before: float, reload_value: float, range_value: float, heal_percent: float, phase_boost: float, phase_range_boost: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:', mend_projector)
        self.assertIn('if bool(entry.get("damaged", false)) and not bool(entry.get("heal_suppressed", false)):', mend_projector)
        # The proof's keys drive the pure scan (an in-range
        # candidate is admitted, edges and rect corners
        # included -- with a real hit_size 8.0 seeded since
        # N2350, so the STRICT hitbox overlap admits them;
        # an out-of-range candidate is excluded, with
        # missing-key exclusions; the realRange fold admits
        # further as phaseHeat grows; admitted entries keep
        # their keys intact, including a healthy + suppressed
        # entry the range pure does not filter; empty
        # candidates give an empty list) plus the live tick
        # (a charged mender passes its ranged frame
        # candidates into the heal scan).
        proof = MEND_PROJECTOR_HEAL_SCAN_RANGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'scan_admits_in_range',
            'scan_excludes_out_of_range',
            'scan_uses_real_range_with_phase_heat',
            'scan_keeps_candidate_entries_intact',
            'empty_candidates_empty',
            'live_tick_passes_ranged_candidates',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # N2350 follow-through: the in-range edge/corner
        # candidates seed a real hit_size (a size-1 building,
        # BuildingComp.java:2048) -- without it the STRICT
        # hitbox overlap drops the degenerate point hitboxes
        # on the edge and scan_admits_in_range falls from 6
        # to 1 (verified by simulating the pure logic in
        # Python before concluding).
        self.assertIn('"hit_size": 8.0', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        self.assertIn('mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = MEND_PROJECTOR_HEAL_SCAN_RANGE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorHealScanRangeProof.gd', scene)
        self.assertIn('[node name="C07MendProjectorHealScanRangeProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mend_projector_heal_scan_range(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorHealScanRangeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_HEAL_SCAN_RANGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'scan_admits_in_range',
            'scan_excludes_out_of_range',
            'scan_uses_real_range_with_phase_heat',
            'scan_keeps_candidate_entries_intact',
            'empty_candidates_empty',
            'live_tick_passes_ranged_candidates',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
