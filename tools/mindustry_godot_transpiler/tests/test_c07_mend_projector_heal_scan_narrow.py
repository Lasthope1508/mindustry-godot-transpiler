import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_HEAL_SCAN_NARROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanNarrowProof.gd'
MEND_PROJECTOR_HEAL_SCAN_NARROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealScanNarrowProof.tscn'


class C07MendProjectorHealScanNarrowTests(unittest.TestCase):
    def test_c07_mend_projector_heal_scan_narrow_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2335']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_supplied_heal_candidates_narrow_state')
        # N2329 proved the eachBlock rect broad phase (the
        # center-in-rect filter over the frame-supplied heal
        # candidates) -- but Java's float-range overload
        # admits only `b.within(wx, wy, range + b.hitSize()
        # / 2f) && pred.get(b) && !b.block.privileged`
        # past the rect (BlockIndexer.java:346), with within
        # a STRICT dst2 < dst^2 circle (Position.java:44-46).
        # N2335 is the narrow half: a pure filter chained
        # AFTER the N2329 rect scan (rect -> within /
        # privileged), wired into the tick between the rect
        # scan and the N2242 heal scan, passing the narrowed
        # list into the heal scan. One new result symbol:
        # the narrowed candidate list.
        self.assertEqual(
            ledger['N2335']['source_symbols'],
            [
                'source_mend_projector_supplied_heal_candidates_narrow_state_result.candidates',
            ],
        )
        for name in ledger['N2335']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/BlockIndexer.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_supplied_heal_candidates_narrow_state')
        self.assertEqual(ledger['N2335']['runtime_proof'], '/root/C07MendProjectorHealScanNarrowProof')
        self.assertEqual(
            ledger['N2335']['tests'],
            [
                'test_c07_mend_projector_heal_scan_narrow_registration',
                'test_all_c07_mend_projector_heal_scan_narrow_input_evidence_is_exact',
                'test_mend_projector_heal_scan_narrow_state',
                'test_reference_graph_and_actual_c07_mend_projector_heal_scan_narrow',
            ],
        )
        self.assertTrue(ledger['N2335']['deferred_exprs'])
        # This slice RESOLVES the within / privileged
        # refinement entry (the narrow check is live and the
        # tick passes the narrowed list into the heal scan)
        # and adds ONE deferral: the rect broad phase still
        # drops large-hitbox buildings whose center sits
        # outside the rect but within range + hitSize/2 --
        # Java's intersect is a QuadTree hitbox overlap
        # query (BlockIndexer.java:345), so those buildings
        # never reach the narrow check. The live
        # building-index fill and the N2242 heal-effect /
        # mendSound / recentlyHealed entries stay deferred.
        self.assertFalse(any(entry.startswith('MendProjector heal scan within / privileged refinement (') for entry in ledger['N2335']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan rect broad phase misses large-hitbox buildings (') for entry in ledger['N2335']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan live building-index fill (') for entry in ledger['N2335']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal effect rows (') for entry in ledger['N2335']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector mendSound rows (') for entry in ledger['N2335']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector recentlyHealed rows (') for entry in ledger['N2335']['deferred_exprs']))

    def test_all_c07_mend_projector_heal_scan_narrow_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2335']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_supplied_heal_candidates_narrow_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/MendProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/ai/BlockIndexer.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Position.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2335']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_heal_scan_narrow_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The narrow check (BlockIndexer.java:346): past the
        # eachBlock rect broad phase, Java admits only
        # `b.within(wx, wy, range + b.hitSize() / 2f) &&
        # pred.get(b) && !b.block.privileged`, with within a
        # STRICT dst2 < dst^2 circle (Position.java:44-46) --
        # exactly at range + hitSize/2 is OUT. hitSize is
        # the building hitbox size in world units (`return
        # tile.block().size * tilesize;`,
        # BuildingComp.java:2048) and privileged defaults
        # false (`public boolean privileged = false;`,
        # Block.java:148). The predicate halves (damaged +
        # not heal-suppressed) already live in the N2242
        # heal scan, so the narrow pure filters within +
        # privileged ONLY.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_mend_projector_supplied_heal_candidates_narrow_state', mend_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', mend_projector)
        self.assertIn('indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {', mend_projector)
        self.assertIn('buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {', mend_projector)
        self.assertIn('if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){', mend_projector)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', mend_projector)
        self.assertIn('return tile.block().size * tilesize;', mend_projector)
        self.assertIn('public boolean privileged = false;', mend_projector)
        # The pure returns exactly the one N2335 key, the
        # narrowed candidate list in candidate order. The
        # filter is WITHIN + PRIVILEGED ONLY: it does not
        # filter damaged / heal_suppressed (the N2242 heal
        # scan already does), it never rewrites an entry
        # (hit_size / privileged / damaged /
        # heal_suppressed / max_health ride through
        # untouched), a missing x or y key EXCLUDES the
        # candidate (the N2329 precedent), and a
        # non-Dictionary entry is excluded the same way.
        # The within test is STRICT (dst2 >= limit^2
        # excludes, so exactly at range + hitSize/2 is OUT);
        # a missing hit_size defaults to 0.0 (the N2226
        # RepairTurret precedent) and a missing privileged
        # defaults to false (Block.java:148).
        self.assertIn('return {"candidates": narrowed}', mend_projector)
        self.assertIn('if not (candidate is Dictionary):', mend_projector)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', mend_projector)
        self.assertIn('if bool(candidate.get("privileged", false)):', mend_projector)
        self.assertIn('float(candidate.get("hit_size", 0.0)) / 2.0', mend_projector)
        self.assertIn('if dx * dx + dy * dy >= limit * limit:', mend_projector)
        self.assertIn('narrowed.append(candidate)', mend_projector)
        # The tick chains the narrow filter AFTER the N2329
        # rect scan and BEFORE the N2242 heal scan: the
        # rect scan runs at the live realRange from the
        # post-advance phase_heat, the narrow filter runs
        # on the ranged list at the same realRange and
        # building position, and the heal scan takes the
        # NARROWED list (not the rect-only list). The N2329
        # rect call and the heal_scan call site are
        # unchanged apart from the narrowed argument.
        self.assertIn('source_mend_projector_supplied_heal_candidates_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)', mend_projector)
        self.assertIn('source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)', mend_projector)
        self.assertIn('source_mend_projector_heal_scan_state(frame, narrowed_candidates.get("candidates", [])', mend_projector)
        self.assertNotIn('source_mend_projector_heal_scan_state(frame, ranged_candidates.get("candidates", [])', mend_projector)
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
            mend_projector.index('source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)'),
        )
        # The documented limits now record the
        # within/privileged refinement as live; the N2329
        # range query, the N2242 heal scan, the N2193
        # advance and the N2269 timer are preserved.
        self.assertIn('within/privileged refinement is live since N2335', mend_projector)
        self.assertIn('range query is live since N2329', mend_projector)
        self.assertIn('live building index', mend_projector)
        self.assertIn('static func source_mend_projector_supplied_heal_candidates_state', mend_projector)
        self.assertIn('static func source_mend_projector_heal_scan_state', mend_projector)
        self.assertIn('static func source_mend_projector_update_tile_advance_state', mend_projector)
        self.assertIn('static func source_mend_projector_timer_use_state', mend_projector)
        # The N2329 broad-phase pure keeps its signature and
        # its {candidates} return shape, but since N2350 it
        # DELEGATES to the hitbox broad phase instead of the
        # rect center test -- the narrow filter chains AFTER
        # its call, never inside it (the N2329 proof's pure
        # keys still admit edge and corner buildings with
        # real hitboxes at the pure level, hit_size 8.0
        # seeded since N2350).
        self.assertIn('static func source_mend_projector_supplied_heal_candidates_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:', mend_projector)
        self.assertIn('return source_mend_projector_heal_candidates_hitbox_state(candidates, real_range, building_x, building_y)', mend_projector)
        self.assertIn('return {"candidates": in_range}', mend_projector)
        self.assertNotIn('if dx > real_range or dy > real_range:', mend_projector)
        # The N2242 heal scan is untouched: its signature
        # keeps the candidates parameter and its damaged +
        # not-heal-suppressed predicate is unchanged.
        self.assertIn('static func source_mend_projector_heal_scan_state(frame: Dictionary, candidates: Array, charge_before: float, reload_value: float, range_value: float, heal_percent: float, phase_boost: float, phase_range_boost: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:', mend_projector)
        self.assertIn('if bool(entry.get("damaged", false)) and not bool(entry.get("heal_suppressed", false)):', mend_projector)
        # The proof's keys drive the narrow pure (a
        # candidate within range + hitSize/2 is admitted,
        # including a hitSize-extended admit; a rect-corner
        # candidate and a beyond-limit candidate are
        # excluded -- the differentiator vs N2329; exactly
        # at range + hitSize/2 is OUT, STRICT; a privileged
        # candidate is excluded; admitted entries keep
        # their keys intact, with missing-key defaults) plus
        # the live tick (a charged mender passes its
        # narrowed frame candidates into the heal scan).
        proof = MEND_PROJECTOR_HEAL_SCAN_NARROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'narrow_admits_within_range',
            'narrow_excludes_beyond_range_plus_hit_size',
            'narrow_excludes_at_exact_range',
            'narrow_excludes_privileged',
            'narrow_keeps_candidate_entries_intact',
            'live_tick_passes_narrowed_candidates',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        self.assertIn('mend_projector_build_state.source_mend_projector_supplied_heal_candidates_narrow_state(', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = MEND_PROJECTOR_HEAL_SCAN_NARROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorHealScanNarrowProof.gd', scene)
        self.assertIn('[node name="C07MendProjectorHealScanNarrowProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mend_projector_heal_scan_narrow(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorHealScanNarrowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_HEAL_SCAN_NARROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'narrow_admits_within_range',
            'narrow_excludes_beyond_range_plus_hit_size',
            'narrow_excludes_at_exact_range',
            'narrow_excludes_privileged',
            'narrow_keeps_candidate_entries_intact',
            'live_tick_passes_narrowed_candidates',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
