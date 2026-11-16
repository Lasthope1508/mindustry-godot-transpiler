import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgePerDefStatRowsProof.gd'
LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgePerDefStatRowsProof.tscn'


class C07LiquidBridgePerDefStatRowsTests(unittest.TestCase):
    def test_c07_liquid_bridge_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2494']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_per_def_stats_state')
        # The LiquidBridge tick is live (N2275 transport +
        # N2287 doDump + N2379 write-back + N2412 live
        # fill + N2463 link rows) but NOTHING modeled
        # the per-def stat rows as a source-backed
        # pure: the phase-conduit def
        # (Blocks.java:2385-2397) sets range 12,
        # liquidCapacity 100f, arrowPeriod 0.9f,
        # arrowTimeScl 2.75f and requirements
        # phase-fabric 5 / silicon 7 / metaglass 20
        # / titanium 10 (size 1 is the inherited
        # Block default -- the def sets NO size
        # line), while the values only existed as
        # constants in the driver header comment.
        # N2494 ports them as ONE pure-only stats
        # pure (the N2304 / N2442 / N2489 / N2490
        # verification-slice precedent): the def's
        # rows for phase-conduit, with the CLASS
        # defaults (size 1, range 0, liquidCapacity
        # 10f, arrowPeriod 0.4f, arrowTimeScl 6.2f,
        # no requirements) for an unknown def id
        # (the N2304 fallback precedent). Six new
        # result symbols: the size + range + liquid
        # capacity + arrow period + arrow time
        # scale + requirements.
        self.assertEqual(
            ledger['N2494']['source_symbols'],
            [
                'source_liquid_bridge_per_def_stats_state_result.size',
                'source_liquid_bridge_per_def_stats_state_result.range',
                'source_liquid_bridge_per_def_stats_state_result.liquid_capacity',
                'source_liquid_bridge_per_def_stats_state_result.arrow_period',
                'source_liquid_bridge_per_def_stats_state_result.arrow_time_scl',
                'source_liquid_bridge_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_liquid_bridge_per_def_stats_state_result.size': 'core/src/mindustry/world/Block.java',
            'source_liquid_bridge_per_def_stats_state_result.range': 'core/src/mindustry/content/Blocks.java',
            'source_liquid_bridge_per_def_stats_state_result.liquid_capacity': 'core/src/mindustry/content/Blocks.java',
            'source_liquid_bridge_per_def_stats_state_result.arrow_period': 'core/src/mindustry/content/Blocks.java',
            'source_liquid_bridge_per_def_stats_state_result.arrow_time_scl': 'core/src/mindustry/content/Blocks.java',
            'source_liquid_bridge_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2494']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidBridgeBuildState.source_liquid_bridge_'))
        self.assertEqual(ledger['N2494']['runtime_proof'], '/root/C07LiquidBridgePerDefStatRowsProof')
        self.assertEqual(
            ledger['N2494']['tests'],
            [
                'test_c07_liquid_bridge_per_def_stat_rows_registration',
                'test_all_c07_liquid_bridge_per_def_stat_rows_input_evidence_is_exact',
                'test_liquid_bridge_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2494']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #42 (1-based in
        # the merged advances-34 DEFERRED base, 225
        # entries): the LiquidBridge per-def stat
        # rows entry is REMOVED -- size / range /
        # liquidCapacity / arrowPeriod / arrowTimeScl
        # / requirements are live now as a
        # source-backed pure. Net 225 - 1 = 224.
        # The bridge-conduit rows (#40) and the
        # reinforced-bridge-conduit rows (#41)
        # STAY: bridge-conduit still falls back to
        # the class defaults until its own
        # verification slice, and
        # reinforced-bridge-conduit is a
        # DirectionLiquidBridge, a different class.
        self.assertFalse(any(entry.startswith('LiquidBridge per-def stat rows (') for entry in ledger['N2494']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('bridge-conduit rows (') for entry in ledger['N2494']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('reinforced-bridge-conduit rows (') for entry in ledger['N2494']['deferred_exprs']))
        self.assertEqual(len(ledger['N2494']['deferred_exprs']), 224)

    def test_all_c07_liquid_bridge_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2494']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidBridgeBuildState.source_liquid_bridge_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2494']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_per_def_stat_rows_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2489 / N2490
        # precedent): the phase-conduit def
        # (Blocks.java:2385-2397) sets range 12,
        # liquidCapacity 100f, arrowPeriod 0.9f,
        # arrowTimeScl 2.75f and requirements
        # phase-fabric 5 / silicon 7 / metaglass 20
        # / titanium 10; size 1 is the inherited
        # Block default (the def sets NO size line).
        # An unknown def id falls back to the CLASS
        # defaults (the N2304 fallback precedent):
        # size 1 (Block.java:215), range 0
        # (ItemBridge.java:27 has NO initializer, so
        # the Java default is 0), liquidCapacity 10f
        # (the -1f field, Block.java:77, is a
        # sentinel Block.init() replaces with
        # round(10f * consumeAmount), Block.java:1418
        # -- consumeAmount stays 1f, LiquidBridge
        # has no liquid consumers), arrowPeriod 0.4f
        # (ItemBridge.java:37), arrowTimeScl 6.2f
        # (ItemBridge.java:38) and NO requirements
        # (the Block default is the empty array,
        # Block.java:356). The class defaults live
        # on the PARENTS -- LiquidBridge.java sets
        # NO stat field. The requirements dict is
        # the {item: amount} dict from the def (the
        # N2490 precedent); the catalog carries the
        # same rows as an Array of {item, amount}
        # (content_registry.json, phase-conduit) but
        # NO size / liquidCapacity / arrow keys.
        # Pure-only: the caller reads it; the
        # existing advance + shouldConsume pures are
        # unchanged. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_liquid_bridge_per_def_stats_state', liquid_bridge)
        self.assertIn('phaseConduit = new LiquidBridge("phase-conduit"){{', liquid_bridge)
        self.assertIn('requirements(Category.liquid, with(Items.phaseFabric, 5, Items.silicon, 7, Items.metaglass, 20, Items.titanium, 10));', liquid_bridge)
        self.assertIn('range = 12;', liquid_bridge)
        self.assertIn('liquidCapacity = 100f;', liquid_bridge)
        self.assertIn('arrowPeriod = 0.9f;', liquid_bridge)
        self.assertIn('arrowTimeScl = 2.75f;', liquid_bridge)
        self.assertIn('public int range;', liquid_bridge)
        self.assertIn('public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;', liquid_bridge)
        self.assertIn('public float arrowTimeScl = 6.2f;', liquid_bridge)
        self.assertIn('public float liquidCapacity = -1f;', liquid_bridge)
        self.assertIn('liquidCapacity = Mathf.round(10f * consumeAmount);', liquid_bridge)
        self.assertIn('public int size = 1;', liquid_bridge)
        self.assertIn('public ItemStack[] requirements = {};', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class ItemBridge extends Block{', liquid_bridge)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2494)', liquid_bridge)
        # The proof's keys drive the per-def stats pure
        # (the phase-conduit def row, the range +
        # capacity def-vs-class split, the arrow def
        # vs class split, the requirements dict, the
        # class fallback for an unknown def id, and
        # the def rows feeding the N2275 transport
        # pure as live inputs).
        proof = LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_bridge',
            'stats_range_capacity',
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
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.exists())
        self.assertTrue(LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LiquidBridgePerDefStatRowsProof.gd', LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_liquid_bridge_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgePerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_bridge',
            'stats_range_capacity',
            'stats_arrows',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
