import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OVERDRIVE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd'
OVERDRIVE_PROJECTOR_BOOST_SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorBoostScanProof.gd'
OVERDRIVE_PROJECTOR_BOOST_SCAN_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorBoostScanProof.tscn'


class C07OverdriveProjectorBoostScanTests(unittest.TestCase):
    def test_c07_overdrive_projector_boost_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2334']['godot_owner'], 'SourceOverdriveProjectorBuildState.source_overdrive_projector_supplied_boost_targets_state')
        # N2194 proved the updateTile advance (the charge
        # advance + reset at reload, the phaseHeat lerp) but
        # the boost scan stayed deferred: when charge crossed
        # reload, the tick reset the charge and did NOTHING
        # with the in-range buildings -- the realRange fold
        # (OverdriveProjector.java:107) and the indexer scan
        # (OverdriveProjector.java:110) were both unmodeled.
        # N2334 is the scan half: a pure filter over the
        # frame-supplied boost candidates by the eachBlock
        # rect (BlockIndexer.java:345, world units directly,
        # half-side realRange, INCLUSIVE, center-in-rect --
        # the N2277 precedent) + the canOverdrive predicate
        # (OverdriveProjector.java:110), wired into the tick
        # after the advance (realRange needs the post-advance
        # phase_heat) when the advance reports charge_ready.
        # The pure only REPORTS the targets -- applyBoost on
        # the reported targets (OverdriveProjector.java:110)
        # waits for its own slice (the N2325
        # heal_applications precedent). Two new result
        # symbols: the reported target list and the folded
        # realRange.
        self.assertEqual(
            ledger['N2334']['source_symbols'],
            [
                'source_overdrive_projector_supplied_boost_targets_state_result.boost_targets',
                'source_overdrive_projector_supplied_boost_targets_state_result.real_range',
            ],
        )
        for name in ledger['N2334']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/OverdriveProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceOverdriveProjectorBuildState.source_overdrive_projector_supplied_boost_targets_state')
        self.assertEqual(ledger['N2334']['runtime_proof'], '/root/C07OverdriveProjectorBoostScanProof')
        self.assertEqual(
            ledger['N2334']['tests'],
            [
                'test_c07_overdrive_projector_boost_scan_registration',
                'test_all_c07_overdrive_projector_boost_scan_input_evidence_is_exact',
                'test_overdrive_projector_boost_scan_state',
                'test_reference_graph_and_actual_c07_overdrive_projector_boost_scan',
            ],
        )
        self.assertTrue(ledger['N2334']['deferred_exprs'])
        # This slice RESOLVES the range / phase-range entry
        # (the realRange fold is live and the scan consumes
        # it) and adds TWO deferrals: the live building-index
        # fill (nothing fills frame["boost_candidates"] yet)
        # and the within / privileged refinement (Java's
        # float-range overload admits only b.within(range +
        # hitSize/2) + pred + !privileged past the rect broad
        # phase, so the center-in-rect port admits corners
        # Java rejects). The boost-application entry stays
        # deferred (the scan reports targets; applyBoost on
        # them waits), as do the draw rows.
        self.assertFalse(any(entry.startswith('OverdriveProjector range / phase-range rows (') for entry in ledger['N2334']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector boost application (') for entry in ledger['N2334']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector boost scan live building-index fill (') for entry in ledger['N2334']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector boost scan within / privileged refinement (') for entry in ledger['N2334']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector draw / drawLight / drawSelect / drawPlace rows (') for entry in ledger['N2334']['deferred_exprs']))

    def test_all_c07_overdrive_projector_boost_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2334']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceOverdriveProjectorBuildState.source_overdrive_projector_supplied_boost_targets_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/OverdriveProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/ai/BlockIndexer.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Position.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2334']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_overdrive_projector_boost_scan_state(self):
        overdrive_projector = OVERDRIVE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The boost scan (OverdriveProjector.java:106-111):
        # `if(charge >= reload){` then `float realRange =
        # range + phaseHeat * phaseRangeBoost;`, the charge
        # reset, and `indexer.eachBlock(this, realRange,
        # other -> other.block.canOverdrive, other ->
        # other.applyBoost(realBoost(), reload + 1f));`. The
        # float-range overload (BlockIndexer.java:324-328)
        # delegates to the (team, wx, wy, range) form, which
        # intersects the team's buildingTree quadtree with
        # the rect (wx - range, wy - range, range*2f,
        # range*2f) -- WORLD units directly, no tilesize
        # factor -- and then admits only `b.within(wx, wy,
        # range + b.hitSize() / 2f) && pred.get(b) &&
        # !b.block.privileged` (BlockIndexer.java:345-346),
        # with within a STRICT dst2 < dst^2 circle
        # (Position.java:44-46). The port tests candidate
        # centers against the rect inclusively (the N2277
        # precedent) plus the canOverdrive predicate and
        # models no hitSize / privileged flag -- a documented
        # deviation, recorded in DEFERRED. Keep each Java
        # expr on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_overdrive_projector_supplied_boost_targets_state', overdrive_projector)
        self.assertIn('if(charge >= reload){', overdrive_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', overdrive_projector)
        self.assertIn('indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload + 1f));', overdrive_projector)
        self.assertIn('public boolean eachBlock(Teamc team, float range, Boolf<Building> pred, Cons<Building> cons){', overdrive_projector)
        self.assertIn('return eachBlock(team.team(), team.getX(), team.getY(), range, pred, cons);', overdrive_projector)
        self.assertIn('public boolean eachBlock(@Nullable Team team, float wx, float wy, float range, Boolf<Building> pred, Cons<Building> cons){', overdrive_projector)
        self.assertIn('buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {', overdrive_projector)
        self.assertIn('if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){', overdrive_projector)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', overdrive_projector)
        self.assertIn('public boolean canOverdrive = true;', overdrive_projector)
        self.assertIn('public float range = 80f;', overdrive_projector)
        self.assertIn('public float phaseRangeBoost = 20f;', overdrive_projector)
        self.assertIn('range = 200f;', overdrive_projector)
        self.assertIn('hasBoost = false;', overdrive_projector)
        self.assertIn('return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;', overdrive_projector)
        # The pure returns exactly the two N2334 keys: the
        # reported target list (the admitted candidate dicts
        # themselves, in candidate order) and the folded
        # realRange. The filter is RANGE + the canOverdrive
        # predicate: a candidate with can_overdrive false is
        # excluded, but a MISSING can_overdrive reads TRUE --
        # the Java field default (Block.java:309 `public
        # boolean canOverdrive = true;`); only defs that opt
        # out read false. The pure never rewrites an entry, a
        # missing x or y key EXCLUDES the candidate, and a
        # non-Dictionary entry is excluded the same way. The
        # rect test is inclusive on the edge (|dx| <=
        # realRange and |dy| <= realRange), so a rect corner
        # counts -- rect, NOT circle.
        self.assertIn('return {"boost_targets": boost_targets, "real_range": real_range}', overdrive_projector)
        self.assertIn('if not (candidate is Dictionary):', overdrive_projector)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', overdrive_projector)
        self.assertIn('if not bool(candidate.get("can_overdrive", true)):', overdrive_projector)
        self.assertIn('if dx > real_range or dy > real_range:', overdrive_projector)
        self.assertIn('boost_targets.append(candidate)', overdrive_projector)
        # The tick wires the scan AFTER the advance (the
        # N2329 post-advance pattern): realRange needs the
        # post-advance phase_heat, so the tick folds it from
        # the post-advance frame + the block props through
        # the existing projector_range accessor (the SAME
        # formula the drawSelect fold uses,
        # OverdriveProjector.java:129 -- no duplicate math),
        # filters the frame boost candidates (default [] --
        # no candidates, the Java no-buildings-in-range
        # outcome) from the live building position (origin
        # cell + block offset, the N2306 RepairTower
        # precedent: Building x/y are tile.drawx()/drawy(),
        # BuildingComp.java:124), and reports the scan as
        # last_boost_scan -- but ONLY when the advance
        # reports charge_ready: Java runs no scan at all when
        # charge < reload, so the tick reports an empty
        # target list at the live realRange instead.
        self.assertIn('const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")', overdrive_projector)
        self.assertIn('frame.get("boost_candidates", [])', overdrive_projector)
        self.assertIn('source_overdrive_projector_state.projector_range(block, float(frame.get("phase_heat", 0.0)))', overdrive_projector)
        self.assertIn('source_overdrive_projector_supplied_boost_targets_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)', overdrive_projector)
        self.assertIn('if bool(advance.get("charge_ready", false)):', overdrive_projector)
        self.assertIn('frame["last_boost_scan"] = boost_scan', overdrive_projector)
        self.assertIn('source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)', overdrive_projector)
        self.assertIn('source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)', overdrive_projector)
        self.assertLess(
            overdrive_projector.index('source_overdrive_projector_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds)'),
            overdrive_projector.index('source_overdrive_projector_supplied_boost_targets_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)'),
        )
        # The documented limits now record the boost scan as
        # live and the remaining deferrals (the boost
        # application + the live building index that would
        # fill frame["boost_candidates"]); the N2194 advance,
        # the N2157 power row and the N2262 item rows are
        # preserved, and the old "realRange fold waits" text
        # is gone.
        self.assertIn('boost scan is live since N2334', overdrive_projector)
        self.assertIn('live building index', overdrive_projector)
        self.assertNotIn('the proof asserts only the charge reset, never a boosted', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_update_tile_advance_state', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_power_status_row_state', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_item_consumer_row_state', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_tick_buildings_state', overdrive_projector)
        # The N2194 advance is untouched: its signature keeps
        # the per-def params and the charge reset still sits
        # inside the charge_ready branch -- the scan wires
        # AFTER its call, never inside it.
        self.assertIn('static func source_overdrive_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, has_boost: bool, reload_value: float, use_time_value: float) -> Dictionary:', overdrive_projector)
        self.assertIn('var charge_ready: bool = charge >= reload_value', overdrive_projector)
        # The proof's keys drive the pure scan (an in-range
        # overdrivable candidate is admitted, edges and rect
        # corners included, and a missing can_overdrive reads
        # the Java default true; an out-of-range candidate is
        # excluded, with missing-key exclusions; an
        # in-range non-overdrivable candidate is excluded;
        # the realRange fold admits further as phaseHeat
        # grows; empty candidates give an empty list) plus
        # the live tick (a charged projector scans its frame
        # candidates when charge_ready and reports an empty
        # list when charge is not ready).
        proof = OVERDRIVE_PROJECTOR_BOOST_SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'scan_admits_in_range_overdrivable',
            'scan_excludes_out_of_range',
            'scan_excludes_non_overdrivable',
            'scan_uses_real_range_with_phase_heat',
            'empty_candidates_empty',
            'live_tick_scans_when_charge_ready',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        self.assertIn('overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(', proof)
        self.assertIn('overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = OVERDRIVE_PROJECTOR_BOOST_SCAN_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07OverdriveProjectorBoostScanProof.gd', scene)
        self.assertIn('[node name="C07OverdriveProjectorBoostScanProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_overdrive_projector_boost_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07OverdriveProjectorBoostScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_OVERDRIVE_PROJECTOR_BOOST_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'scan_admits_in_range_overdrivable',
            'scan_excludes_out_of_range',
            'scan_excludes_non_overdrivable',
            'scan_uses_real_range_with_phase_heat',
            'empty_candidates_empty',
            'live_tick_scans_when_charge_ready',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
