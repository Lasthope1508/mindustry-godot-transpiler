import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
LIQUID_BRIDGE_BRIDGE_CONDUIT_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeBridgeConduitRowProof.gd'
LIQUID_BRIDGE_BRIDGE_CONDUIT_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeBridgeConduitRowProof.tscn'


class C07LiquidBridgeBridgeConduitRowTests(unittest.TestCase):
    def test_c07_liquid_bridge_bridge_conduit_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2501']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_per_def_stats_state')
        # The N2494 pure carries ONLY the phase-conduit
        # row; bridge-conduit (the second LiquidBridge
        # def, Blocks.java:2374-2384) falls back to the
        # class defaults. N2501 AMENDS that pure (the
        # N2446 amendment precedent): it adds the
        # bridge-conduit def branch -- size 1, range 4,
        # liquidCapacity 100f, arrowPeriod 0.4f,
        # arrowTimeScl 6.2f, requirements graphite 4 /
        # metaglass 8 -- with the pure signature and
        # the return keys UNCHANGED, so NO new
        # symbols / contracts / schemas. The ledger
        # entry references the SAME six N2494 result
        # symbols (shared-symbol precedent: 834
        # symbols are referenced by more than one
        # slice). SSOT delta +0/+1/+0/+0.
        self.assertEqual(
            ledger['N2501']['source_symbols'],
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
        for name in ledger['N2501']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidBridgeBuildState.source_liquid_bridge_'))
        self.assertEqual(ledger['N2501']['runtime_proof'], '/root/C07LiquidBridgeBridgeConduitRowProof')
        self.assertEqual(
            ledger['N2501']['tests'],
            [
                'test_c07_liquid_bridge_bridge_conduit_row_registration',
                'test_all_c07_liquid_bridge_bridge_conduit_row_input_evidence_is_exact',
                'test_liquid_bridge_bridge_conduit_row_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_bridge_conduit_row',
            ],
        )
        self.assertTrue(ledger['N2501']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #38 (1-based in
        # the merged advances-35 DEFERRED base, 218
        # entries): the bridge-conduit rows entry is
        # REMOVED -- the bridge-conduit STAT rows are
        # live now as the second def branch of the
        # per-def stats pure. Net 218 - 1 = 217. The
        # entry's power-scope clause (the
        # bridge-conduit transport does not depend on
        # power.status) stays TRUE and is preserved in
        # the register docstring; this slice ports the
        # STAT rows, not the power rows. The
        # reinforced-bridge-conduit rows STAY: it is a
        # DirectionLiquidBridge, a different class
        # (N2502 covers it).
        self.assertFalse(any(entry.startswith('bridge-conduit rows (') for entry in ledger['N2501']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('reinforced-bridge-conduit rows (') for entry in ledger['N2501']['deferred_exprs']))
        self.assertEqual(len(ledger['N2501']['deferred_exprs']), 217)

    def test_all_c07_liquid_bridge_bridge_conduit_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2501']['source_symbols']:
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
        for expr in ledger['N2501']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_bridge_conduit_row_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The bridge-conduit def row (the AMENDMENT
        # slice: the N2494 pure carries only the
        # phase-conduit row). The bridge-conduit def
        # (Blocks.java:2374-2384) sets range 4,
        # liquidCapacity 100f and requirements
        # graphite 4 / metaglass 8; it sets NO size
        # line (size 1 is the inherited Block
        # default, Block.java:215) and NO arrowPeriod
        # / arrowTimeScl lines, so its arrows ride
        # the ItemBridge class defaults (arrowPeriod
        # 0.4f, ItemBridge.java:37; arrowTimeScl 6.2f,
        # ItemBridge.java:38) -- unlike phase-conduit,
        # which overrides both (0.9f / 2.75f). The def
        # DOES set arrowSpacing 6f (Blocks.java:2378)
        # and fadeIn = moveArrows = false (:2377), but
        # neither is a return key of the pure, so
        # neither is ported here. Phase-conduit + the
        # class fallback are UNCHANGED. Keep each Java
        # expr on ONE comment line (the N2148 lesson:
        # a split line fails this test).
        self.assertIn('static func source_liquid_bridge_per_def_stats_state', liquid_bridge)
        self.assertIn('bridgeConduit = new LiquidBridge("bridge-conduit"){{', liquid_bridge)
        self.assertIn('requirements(Category.liquid, with(Items.graphite, 4, Items.metaglass, 8));', liquid_bridge)
        self.assertIn('range = 4;', liquid_bridge)
        self.assertIn('liquidCapacity = 100f;', liquid_bridge)
        self.assertIn('public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;', liquid_bridge)
        self.assertIn('public float arrowTimeScl = 6.2f;', liquid_bridge)
        self.assertIn('public int size = 1;', liquid_bridge)
        self.assertIn('if def_id == "bridge-conduit":', liquid_bridge)
        # The phase-conduit row is unchanged.
        self.assertIn('phaseConduit = new LiquidBridge("phase-conduit"){{', liquid_bridge)
        self.assertIn('requirements(Category.liquid, with(Items.phaseFabric, 5, Items.silicon, 7, Items.metaglass, 20, Items.titanium, 10));', liquid_bridge)
        self.assertIn('range = 12;', liquid_bridge)
        self.assertIn('arrowPeriod = 0.9f;', liquid_bridge)
        self.assertIn('arrowTimeScl = 2.75f;', liquid_bridge)
        # The documented limits record the per-def stat
        # rows as live (N2494) and the bridge-conduit
        # row as live (N2501).
        self.assertIn('Per-def stat rows live (N2494)', liquid_bridge)
        self.assertIn('bridge-conduit row live (N2501)', liquid_bridge)
        # The proof's keys drive the per-def stats pure
        # (the bridge-conduit def row, the range +
        # capacity def-vs-phase split, the arrow
        # class-default rows, the requirements dict,
        # the phase-conduit row unchanged, and the def
        # rows feeding the N2275 transport pure as live
        # inputs -- range 4 vs 12 changes the link
        # validation).
        proof = LIQUID_BRIDGE_BRIDGE_CONDUIT_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'row_conduit',
            'row_range_capacity',
            'row_arrows',
            'row_requirements',
            'row_phase_unchanged',
            'row_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.exists())
        self.assertTrue(LIQUID_BRIDGE_BRIDGE_CONDUIT_ROW_PROOF_SCENE.exists())
        self.assertIn('C07LiquidBridgeBridgeConduitRowProof.gd', LIQUID_BRIDGE_BRIDGE_CONDUIT_ROW_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_liquid_bridge_bridge_conduit_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeBridgeConduitRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_BRIDGE_CONDUIT_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'row_conduit',
            'row_range_capacity',
            'row_arrows',
            'row_requirements',
            'row_phase_unchanged',
            'row_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
