import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_TARGETS_NARROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorTargetsNarrowProof.gd'
REGEN_PROJECTOR_TARGETS_NARROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorTargetsNarrowProof.tscn'


class C07RegenProjectorTargetsNarrowTests(unittest.TestCase):
    def test_c07_regen_projector_targets_narrow_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2338']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_targets_narrow_state')
        # N2277 proved the updateTargets rect scan (the
        # center-in-rect filter over the placed buildings) --
        # but Java's eachBlock is a QuadTree hitbox overlap
        # query (BlockIndexer.java:364-380): a building whose
        # hitbox straddles the rect edge counts, and
        # privileged blocks are excluded
        # (`if(pred.get(b) && !b.block.privileged){`,
        # BlockIndexer.java:372). N2338 is the refinement,
        # chained AFTER the N2277 rect scan (the N2335
        # pattern): it drops privileged rect members (joined
        # to the raw candidates by pos) and admits
        # same-team straddlers whose hitbox STRICTLY overlaps
        # the rect, rebuilt in the exact N2277 entry format.
        # One new result symbol: the refined targets list.
        self.assertEqual(
            ledger['N2338']['source_symbols'],
            [
                'source_regen_projector_update_targets_narrow_state_result.targets',
            ],
        )
        for name in ledger['N2338']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/BlockIndexer.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_targets_narrow_state')
        self.assertEqual(ledger['N2338']['runtime_proof'], '/root/C07RegenProjectorTargetsNarrowProof')
        self.assertEqual(
            ledger['N2338']['tests'],
            [
                'test_c07_regen_projector_targets_narrow_registration',
                'test_all_c07_regen_projector_targets_narrow_input_evidence_is_exact',
                'test_regen_projector_update_targets_narrow_state',
                'test_reference_graph_and_actual_c07_regen_projector_targets_narrow',
            ],
        )
        self.assertTrue(ledger['N2338']['deferred_exprs'])
        # This slice RESOLVES the updateTargets hitbox
        # overlap + privileged entry (DEFERRED #249: the
        # narrow check is live and the tick passes the
        # narrowed list into the frame targets) and adds ONE
        # deferral: the live privileged flag fill (the tick
        # passes privileged=false for every live candidate
        # because the catalog carries no privileged flag).
        # The live tileChanges counter and the updateTile
        # live-fill bundle stay deferred.
        self.assertFalse(any(entry.startswith('RegenProjector updateTargets hitbox overlap + privileged filter (') for entry in ledger['N2338']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector updateTargets live privileged flag fill (') for entry in ledger['N2338']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector live tileChanges counter (') for entry in ledger['N2338']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector updateTile live fill (') for entry in ledger['N2338']['deferred_exprs']))

    def test_all_c07_regen_projector_targets_narrow_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2338']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_targets_narrow_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/RegenProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/ai/BlockIndexer.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/HealthComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/Vars.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Rect.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/QuadTree.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2338']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_update_targets_narrow_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The updateTargets refinement (BlockIndexer.java:
        # 364-380): Java's eachBlock intersects the team
        # buildingTree quadtree with the rect -- the
        # QuadTree tests each building's HITBOX against the
        # rect (QuadTree.java:190-191, `hitbox(item);` +
        # `if(tmp.overlaps(x, y, width, height)){`), with
        # Rect.overlaps STRICT (Rect.java:274-276), so a
        # building whose hitbox merely TOUCHES the rect edge
        # is OUT -- and excludes privileged blocks
        # (`if(pred.get(b) && !b.block.privileged){`,
        # BlockIndexer.java:372). The building hitbox is a
        # square centered on the building center with side
        # block.size * tilesize (BuildingComp.java:2292-2294,
        # hitSize is `tile.block().size * tilesize`,
        # BuildingComp.java:2048) and privileged defaults
        # false (Block.java:148). The four privileged defs
        # are the world-processor-only logic blocks
        # (Blocks.java:6955/6965/6974/6981 -- the brief and
        # the N2277 docstring cite only three, missing
        # world-switch at :6981, verified by grep at this
        # pin). Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_regen_projector_update_targets_narrow_state', regen_projector)
        self.assertIn('indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);', regen_projector)
        self.assertIn('public boolean eachBlock(Team team, Rect rect, Boolf<Building> pred, Cons<Building> cons){', regen_projector)
        self.assertIn('buildings.intersect(rect, b -> {', regen_projector)
        self.assertIn('if(pred.get(b) && !b.block.privileged){', regen_projector)
        self.assertIn('public boolean privileged = false;', regen_projector)
        self.assertIn('return tile.block().size * tilesize;', regen_projector)
        self.assertIn('out.setCentered(x, y, block.size * tilesize, block.size * tilesize);', regen_projector)
        self.assertIn('public void intersect(Rect rect, Cons<T> out){', regen_projector)
        self.assertIn('if(tmp.overlaps(x, y, width, height)){', regen_projector)
        self.assertIn('return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;', regen_projector)
        self.assertIn('return health < maxHealth - 0.001f;', regen_projector)
        self.assertIn('range = 28;', regen_projector)
        self.assertIn('public static final int tilesize = 8;', regen_projector)
        # The pure returns exactly the one N2338 key, the
        # refined targets list. It chains AFTER the N2277
        # rect scan (it cannot filter the rect output alone:
        # the N2277 entries carry no x/y/hit_size/privileged,
        # so the narrow joins them to the raw candidates by
        # pos): pass 1 keeps the rect members untouched
        # except privileged ones (joined by pos; a member
        # with no matching candidate is kept -- privileged
        # defaults false, Block.java:148 -- and its hitbox
        # overlap is automatic, its center being in the
        # rect), pass 2 admits same-team straddlers whose
        # hitbox STRICTLY overlaps the rect, rebuilt in the
        # exact N2277 entry format (pos, block_health,
        # health, damaged with the 0.001f epsilon,
        # heal_suppressed). A missing hit_size defaults to
        # 0.0 (the N2335/N2226 precedent -- the overlap test
        # then falls back to the center, STRICT); a missing
        # privileged defaults to false; a missing x or y
        # excludes the candidate from admission; a
        # non-Dictionary candidate or target is skipped.
        # The team check runs only on newly admitted
        # straddlers (the rect members already passed the
        # N2277 team filter).
        self.assertIn('return {"targets": narrowed}', regen_projector)
        self.assertIn('if not (candidate is Dictionary):', regen_projector)
        self.assertIn('if not (target is Dictionary):', regen_projector)
        self.assertIn('if not candidate.has("x") or not candidate.has("y"):', regen_projector)
        self.assertIn('if bool(candidate.get("privileged", false)):', regen_projector)
        self.assertIn('float(candidate.get("hit_size", 0.0)) / 2.0', regen_projector)
        self.assertIn('if dx >= half_side + hit_half or dy >= half_side + hit_half:', regen_projector)
        self.assertIn('narrowed.append(target)', regen_projector)
        self.assertIn('"damaged": health < block_health - 0.001', regen_projector)
        # The tick chains the narrow filter AFTER the N2277
        # rect scan and BEFORE the advance: the scan runs at
        # the live building position over the placed
        # buildings, the narrow refines the scanned targets
        # against the same raw candidates at the same
        # position and team, and the frame targets take the
        # NARROWED list (not the rect-only list) while
        # last_change still stamps from the scan. The
        # candidates now carry hit_size (size * tilesize,
        # BuildingComp.java:2048) and privileged (the live
        # flag fill, N2344: the pure result per candidate
        # block id -- the catalog carries no privileged
        # flag, so the pure reads the four def ids).
        self.assertIn('source_regen_projector_update_targets_state(frame, scan_building_x, scan_building_y, scan_candidates)', regen_projector)
        self.assertIn('source_regen_projector_update_targets_narrow_state(scanned["targets"], scan_candidates, team_id, scan_building_x, scan_building_y)', regen_projector)
        self.assertIn('frame["targets"] = narrowed["targets"]', regen_projector)
        self.assertIn('frame["last_change"] = scanned["last_change"]', regen_projector)
        self.assertNotIn('frame["targets"] = scanned["targets"]', regen_projector)
        self.assertIn('"hit_size": float(other_size) * source_world_defaults.TILESIZE', regen_projector)
        # N2344 follow-through: the tick no longer stamps the
        # literal false -- the live privileged flag fill
        # stamps the pure result per candidate block id (the
        # narrow then drops the privileged ones).
        self.assertIn('"privileged": bool(source_regen_projector_privileged_state(other_block_id).get("privileged", false))', regen_projector)
        self.assertLess(
            regen_projector.index('source_regen_projector_update_targets_state(frame, scan_building_x, scan_building_y, scan_candidates)'),
            regen_projector.index('source_regen_projector_update_targets_narrow_state(scanned["targets"], scan_candidates, team_id, scan_building_x, scan_building_y)'),
        )
        self.assertLess(
            regen_projector.index('source_regen_projector_update_targets_narrow_state(scanned["targets"], scan_candidates, team_id, scan_building_x, scan_building_y)'),
            regen_projector.index('source_regen_projector_update_tile_advance_state(frame, source_delta, time_scale)'),
        )
        # The documented limits now record the
        # hitbox-overlap + privileged refinement as live;
        # the N2277 scan, the N2214 gate and the N2228
        # advance are preserved.
        self.assertIn('hitbox-overlap + privileged refinement is live since N2338', regen_projector)
        self.assertIn('updateTargets live (N2277)', regen_projector)
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        self.assertIn('updateTile advance live (N2228)', regen_projector)
        self.assertIn('static func source_regen_projector_update_targets_state', regen_projector)
        self.assertIn('static func source_regen_projector_should_consume_state', regen_projector)
        self.assertIn('static func source_regen_projector_update_tile_advance_state', regen_projector)
        # The N2277 rect pure is untouched: its signature
        # and its inclusive center-in-rect test are unchanged
        # -- the narrow filter chains AFTER its call, never
        # inside it (the N2277 proof's pure keys still admit
        # rect corners at the pure level, and its live tick
        # still passes: an in-rect neighbor is kept by the
        # narrow with privileged default false).
        self.assertIn('static func source_regen_projector_update_targets_state(frame: Dictionary, building_x: float, building_y: float, candidates: Array) -> Dictionary:', regen_projector)
        self.assertIn('return {"targets": targets, "last_change": tile_changes, "refreshed": true}', regen_projector)
        self.assertIn('if dx > half_side or dy > half_side:', regen_projector)
        # The proof's keys drive the narrow pure (a straddler
        # whose hitbox overlaps the rect is admitted even
        # though its center is outside -- the differentiator
        # vs N2277; exactly touching the rect edge is OUT,
        # STRICT; a privileged rect member and a privileged
        # straddler are excluded; kept rect entries ride
        # through untouched and straddler entries are rebuilt
        # in the N2277 format, with missing-key defaults)
        # plus the live tick (a placed size-2 straddler lands
        # in the frame targets on the first tick and stays put
        # on the second, while a far building stays out).
        proof = REGEN_PROJECTOR_TARGETS_NARROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'narrow_admits_hitbox_straddler',
            'narrow_excludes_at_exact_hitbox_edge',
            'narrow_excludes_privileged',
            'narrow_keeps_rect_entries_intact',
            'live_tick_passes_narrowed_targets',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        self.assertIn('regen_projector_build_state.source_regen_projector_update_targets_narrow_state(', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = REGEN_PROJECTOR_TARGETS_NARROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorTargetsNarrowProof.gd', scene)
        self.assertIn('[node name="C07RegenProjectorTargetsNarrowProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_regen_projector_targets_narrow(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorTargetsNarrowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_TARGETS_NARROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'narrow_admits_hitbox_straddler',
            'narrow_excludes_at_exact_hitbox_edge',
            'narrow_excludes_privileged',
            'narrow_keeps_rect_entries_intact',
            'live_tick_passes_narrowed_targets',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
