import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_PRIVILEGED_FLAG_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorPrivilegedFlagFillProof.gd'
REGEN_PROJECTOR_PRIVILEGED_FLAG_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorPrivilegedFlagFillProof.tscn'


class C07RegenProjectorPrivilegedFlagFillTests(unittest.TestCase):
    def test_c07_regen_projector_privileged_flag_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2344']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_privileged_state')
        # The N2338 narrow pure excludes privileged candidates
        # from the updateTargets result -- but the tick stamped
        # privileged=false for every live candidate, because
        # the catalog carries no privileged flag (Block.java:148
        # defaults it false; only the four world-processor-only
        # logic blocks set it, Blocks.java:6955/6965/6974/6981),
        # so a placed privileged block wrongly counted as a
        # target. N2344 is the live fill: a pure that reads the
        # candidate block id against the four privileged def ids
        # and the tick stamping its result on every candidate.
        # One new result symbol: the privileged flag.
        self.assertEqual(
            ledger['N2344']['source_symbols'],
            [
                'source_regen_projector_privileged_state_result.privileged',
            ],
        )
        for name in ledger['N2344']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/content/Blocks.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_privileged_state')
        self.assertEqual(ledger['N2344']['runtime_proof'], '/root/C07RegenProjectorPrivilegedFlagFillProof')
        self.assertEqual(
            ledger['N2344']['tests'],
            [
                'test_c07_regen_projector_privileged_flag_fill_registration',
                'test_all_c07_regen_projector_privileged_flag_fill_input_evidence_is_exact',
                'test_regen_projector_privileged_flag_fill_state',
                'test_reference_graph_and_actual_c07_regen_projector_privileged_flag_fill',
            ],
        )
        self.assertTrue(ledger['N2344']['deferred_exprs'])
        # This slice RESOLVES the live privileged flag fill
        # (DEFERRED #328: the tick now stamps the pure result
        # per candidate block id) and adds NO new deferral.
        # The live tileChanges counter and the updateTile
        # live-fill bundle stay deferred.
        self.assertFalse(any(entry.startswith('RegenProjector updateTargets live privileged flag fill (') for entry in ledger['N2344']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector live tileChanges counter (') for entry in ledger['N2344']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector updateTile live fill (') for entry in ledger['N2344']['deferred_exprs']))

    def test_all_c07_regen_projector_privileged_flag_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2344']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_privileged_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/RegenProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/ai/BlockIndexer.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2344']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_privileged_flag_fill_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The live privileged flag fill (BlockIndexer.java:
        # 364-380): Java's eachBlock excludes privileged
        # blocks (`if(pred.get(b) && !b.block.privileged){`,
        # BlockIndexer.java:372) from the updateTargets query
        # (`indexer.eachBlock(team, Tmp.r1.setCentered(x, y,
        # range * tilesize), b -> true, targets::add);`,
        # RegenProjector.java:118). privileged defaults false
        # (`public boolean privileged = false;`, Block.java:148)
        # and exactly four defs set it (`privileged = true;`,
        # Blocks.java:6955/6965/6974/6981): the
        # world-processor-only logic blocks. The catalog
        # carries no privileged flag, so the pure reads the
        # block id against the four def ids; an empty or
        # unknown id is NOT privileged (the false default).
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_regen_projector_privileged_state', regen_projector)
        self.assertIn('indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);', regen_projector)
        self.assertIn('if(pred.get(b) && !b.block.privileged){', regen_projector)
        self.assertIn('public boolean privileged = false;', regen_projector)
        self.assertIn('privileged = true;', regen_projector)
        self.assertIn('worldProcessor = new LogicBlock("world-processor"){{', regen_projector)
        self.assertIn('worldCell = new MemoryBlock("world-cell"){{', regen_projector)
        self.assertIn('worldMessage = new MessageBlock("world-message"){{', regen_projector)
        self.assertIn('worldSwitch = new SwitchBlock("world-switch"){{', regen_projector)
        # The pure returns exactly the one N2344 key, the
        # privileged flag, read off the four-def id list.
        self.assertIn('SOURCE_REGEN_PROJECTOR_PRIVILEGED_BLOCK_IDS', regen_projector)
        self.assertIn('"world-processor", "world-cell", "world-message", "world-switch"', regen_projector)
        self.assertIn('return {"privileged": SOURCE_REGEN_PROJECTOR_PRIVILEGED_BLOCK_IDS.has(block_id)}', regen_projector)
        # The tick stamps the pure result on every live
        # candidate (replacing the N2338 literal false) --
        # the narrow then drops the privileged ones. The
        # stamp sits in the candidate build, before the
        # narrow call, and no literal false remains.
        self.assertIn('"privileged": bool(source_regen_projector_privileged_state(other_block_id).get("privileged", false))', regen_projector)
        self.assertNotIn('"privileged": false', regen_projector)
        self.assertLess(
            regen_projector.index('"privileged": bool(source_regen_projector_privileged_state(other_block_id).get("privileged", false))'),
            regen_projector.index('source_regen_projector_update_targets_narrow_state(scanned["targets"], scan_candidates, team_id, scan_building_x, scan_building_y)'),
        )
        # The N2277 rect pure and the N2338 narrow pure are
        # untouched: their signatures and their exact returns
        # are unchanged -- this slice only changes the tick
        # input candidates, never the pures (their candidates
        # are frame inputs, not tick-filled).
        self.assertIn('static func source_regen_projector_update_targets_state(frame: Dictionary, building_x: float, building_y: float, candidates: Array) -> Dictionary:', regen_projector)
        self.assertIn('static func source_regen_projector_update_targets_narrow_state(targets: Array, candidates: Array, team_id: int, building_x: float, building_y: float) -> Dictionary:', regen_projector)
        self.assertIn('return {"targets": targets, "last_change": tile_changes, "refreshed": true}', regen_projector)
        self.assertIn('return {"targets": narrowed}', regen_projector)
        self.assertIn('if dx > half_side or dy > half_side:', regen_projector)
        self.assertIn('if dx >= half_side + hit_half or dy >= half_side + hit_half:', regen_projector)
        # The documented limits now record the live
        # privileged flag fill as live; the N2277 scan, the
        # N2214 gate, the N2228 advance and the N2338
        # refinement are preserved.
        self.assertIn('privileged flag fill is live since N2344', regen_projector)
        self.assertIn('updateTargets live (N2277)', regen_projector)
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        self.assertIn('updateTile advance live (N2228)', regen_projector)
        self.assertIn('hitbox-overlap + privileged refinement is live since N2338', regen_projector)
        # The proof's keys drive the pure (true for exactly
        # the four privileged defs, false for every other id
        # including empty and unknown) plus the live tick (a
        # placed damaged world-processor inside the rect is
        # excluded from the frame targets while the in-rect
        # copper-wall and the projector itself stay in).
        proof = REGEN_PROJECTOR_PRIVILEGED_FLAG_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'privileged_pure_four_defs',
            'privileged_pure_false_otherwise',
            'live_tick_excludes_privileged',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        self.assertIn('regen_projector_build_state.source_regen_projector_privileged_state(', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = REGEN_PROJECTOR_PRIVILEGED_FLAG_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorPrivilegedFlagFillProof.gd', scene)
        self.assertIn('[node name="C07RegenProjectorPrivilegedFlagFillProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_regen_projector_privileged_flag_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorPrivilegedFlagFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_PRIVILEGED_FLAG_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'privileged_pure_four_defs',
            'privileged_pure_false_otherwise',
            'live_tick_excludes_privileged',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
