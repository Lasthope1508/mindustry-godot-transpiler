import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgePerDefStatRowsProof.gd'
ITEM_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgePerDefStatRowsProof.tscn'


class C07ItemBridgePerDefStatRowsTests(unittest.TestCase):
    def test_c07_item_bridge_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2493']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_per_def_stats_state')
        # The ItemBridge tick is live (N2225 advance +
        # N2321 timer + N2288 doDump + N2404 live fill)
        # and the draw / drawPlace / checkAccept rows
        # are live (N2429 / N2456 / N2467) but NOTHING
        # modeled the per-def stat rows as a
        # source-backed pure: the phase-conveyor def
        # (Blocks.java:2116-2125) sets range 12,
        # transportTime 2f, arrowPeriod 0.9f,
        # arrowTimeScl 2.75f and requirements
        # phase-fabric 5 / silicon 7 / lead 10 /
        # graphite 10, while the values only existed
        # as constants in the driver header comment.
        # N2493 ports them as ONE pure-only stats pure
        # (the N2304 / N2442 / N2490 verification-slice
        # precedent): the def's rows for
        # phase-conveyor, with the CLASS defaults (size
        # 1, range 0, transportTime 0f, arrowPeriod
        # 0.4f, arrowTimeScl 6.2f, no requirements) for
        # an unknown def id (the N2304 fallback
        # precedent). Six new result symbols: the size
        # + range + transport time + arrow period +
        # arrow time scale + requirements.
        self.assertEqual(
            ledger['N2493']['source_symbols'],
            [
                'source_item_bridge_per_def_stats_state_result.size',
                'source_item_bridge_per_def_stats_state_result.range_value',
                'source_item_bridge_per_def_stats_state_result.transport_time',
                'source_item_bridge_per_def_stats_state_result.arrow_period',
                'source_item_bridge_per_def_stats_state_result.arrow_time_scl',
                'source_item_bridge_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_item_bridge_per_def_stats_state_result.size': 'core/src/mindustry/world/Block.java',
            'source_item_bridge_per_def_stats_state_result.range_value': 'core/src/mindustry/content/Blocks.java',
            'source_item_bridge_per_def_stats_state_result.transport_time': 'core/src/mindustry/content/Blocks.java',
            'source_item_bridge_per_def_stats_state_result.arrow_period': 'core/src/mindustry/content/Blocks.java',
            'source_item_bridge_per_def_stats_state_result.arrow_time_scl': 'core/src/mindustry/content/Blocks.java',
            'source_item_bridge_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2493']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceItemBridgeBuildState.source_item_bridge_'))
        self.assertEqual(ledger['N2493']['runtime_proof'], '/root/C07ItemBridgePerDefStatRowsProof')
        self.assertEqual(
            ledger['N2493']['tests'],
            [
                'test_c07_item_bridge_per_def_stat_rows_registration',
                'test_all_c07_item_bridge_per_def_stat_rows_input_evidence_is_exact',
                'test_item_bridge_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_item_bridge_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2493']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #39 (1-based in
        # the merged advances-34 DEFERRED base, 225
        # entries): the ItemBridge per-def stat rows
        # entry is REMOVED -- size / range /
        # transportTime / arrowPeriod / arrowTimeScl /
        # requirements are live now as a
        # source-backed pure. Net 225 - 1 = 224. The
        # BufferedItemBridge rows and the LiquidBridge
        # per-def stat rows STAY.
        self.assertFalse(any(entry.startswith('ItemBridge per-def stat rows (') for entry in ledger['N2493']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BufferedItemBridge rows (') for entry in ledger['N2493']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge per-def stat rows (') for entry in ledger['N2493']['deferred_exprs']))
        self.assertEqual(len(ledger['N2493']['deferred_exprs']), 224)

    def test_all_c07_item_bridge_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2493']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceItemBridgeBuildState.source_item_bridge_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2493']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_per_def_stat_rows_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2490
        # precedent): the single ItemBridge def
        # phase-conveyor (Blocks.java:2116-2125) sets
        # range 12, transportTime 2f, arrowPeriod 0.9f,
        # arrowTimeScl 2.75f and requirements
        # phase-fabric 5 / silicon 7 / lead 10 /
        # graphite 10; size 1 comes from the Block
        # class default (Block.java:215) -- the def
        # block sets NO size. An unknown def id falls
        # back to the CLASS defaults (the N2304
        # fallback precedent): size 1 (Block.java:215),
        # range 0 (ItemBridge.java:27, no initializer),
        # transportTime 0f (ItemBridge.java:28, no
        # initializer), arrowPeriod 0.4f
        # (ItemBridge.java:37), arrowTimeScl 6.2f
        # (ItemBridge.java:38) and NO requirements
        # (the Block default is the empty array,
        # Block.java:356). The requirements dict is the
        # {item: amount} dict from the def (the N2490
        # precedent); the catalog carries the same rows
        # as an Array of {item, amount}
        # (content_registry_blocks.json,
        # phase-conveyor). The range key is range_value
        # (the N2490 precedent -- `range` shadows the
        # GDScript builtin, the N2456 lesson).
        # Pure-only: the caller reads it; the existing
        # advance + draw + linkValid pures are
        # unchanged. Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_item_bridge_per_def_stats_state', item_bridge)
        self.assertIn('phaseConveyor = new ItemBridge("phase-conveyor"){{', item_bridge)
        self.assertIn('requirements(Category.distribution, with(Items.phaseFabric, 5, Items.silicon, 7, Items.lead, 10, Items.graphite, 10));', item_bridge)
        self.assertIn('range = 12;', item_bridge)
        self.assertIn('transportTime = 2f;', item_bridge)
        self.assertIn('arrowPeriod = 0.9f;', item_bridge)
        self.assertIn('arrowTimeScl = 2.75f;', item_bridge)
        self.assertIn('public int range;', item_bridge)
        self.assertIn('public float transportTime;', item_bridge)
        self.assertIn('public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;', item_bridge)
        self.assertIn('public float arrowTimeScl = 6.2f;', item_bridge)
        self.assertIn('public int size = 1;', item_bridge)
        self.assertIn('public ItemStack[] requirements = {};', item_bridge)
        self.assertIn('public class ItemBridge extends Block{', item_bridge)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2493)', item_bridge)
        # The proof's keys drive the per-def stats pure
        # (the phase-conveyor def row, the range +
        # transport time at the def vs the class, the
        # arrow period / time scale at the def vs the
        # class, the requirements dict, the class
        # fallback for an unknown def id, and the def
        # rows feeding the N2197 linkValid pure as live
        # inputs).
        proof = ITEM_BRIDGE_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_bridge',
            'stats_range_time',
            'stats_arrows',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.exists())
        self.assertTrue(ITEM_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ItemBridgePerDefStatRowsProof.gd', ITEM_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_item_bridge_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgePerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_bridge',
            'stats_range_time',
            'stats_arrows',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
