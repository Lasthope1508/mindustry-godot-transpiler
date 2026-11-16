import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorPerDefStatRowsProof.gd'
IMPACT_REACTOR_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorPerDefStatRowsProof.tscn'


class C07ImpactReactorPerDefStatRowsTests(unittest.TestCase):
    def test_c07_impact_reactor_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2497']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_per_def_stats_state')
        # The ImpactReactor tick is live (N2192 advance +
        # N2266 item row + N2254 liquid row) and the bar
        # / stats rows are live (N2450) but NOTHING
        # modeled the per-def stat rows as a
        # source-backed pure: the impact-reactor def
        # (Blocks.java:2632-2645) sets size 4, health
        # 900, powerProduction 130f, itemDuration 140f,
        # liquidCapacity 80f and requirements lead 500 /
        # silicon 300 / graphite 400 / thorium 100 /
        # surge-alloy 250 / metaglass 250, while the
        # values only existed as constants in the
        # driver header comment. N2497 ports them as ONE
        # pure-only stats pure (the N2304 / N2442 /
        # N2490 verification-slice precedent): the def's
        # rows for impact-reactor, with the CLASS
        # defaults (size 1, health 40 post-init,
        # powerProduction 0f, itemDuration 60f,
        # liquidCapacity 30f, no requirements) for an
        # unknown def id (the N2304 fallback precedent).
        # Six new result symbols: the size + health +
        # power production + item duration + liquid
        # capacity + requirements.
        self.assertEqual(
            ledger['N2497']['source_symbols'],
            [
                'source_impact_reactor_per_def_stats_state_result.size',
                'source_impact_reactor_per_def_stats_state_result.health',
                'source_impact_reactor_per_def_stats_state_result.power_production',
                'source_impact_reactor_per_def_stats_state_result.item_duration',
                'source_impact_reactor_per_def_stats_state_result.liquid_capacity',
                'source_impact_reactor_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_impact_reactor_per_def_stats_state_result.size': 'core/src/mindustry/content/Blocks.java',
            'source_impact_reactor_per_def_stats_state_result.health': 'core/src/mindustry/content/Blocks.java',
            'source_impact_reactor_per_def_stats_state_result.power_production': 'core/src/mindustry/content/Blocks.java',
            'source_impact_reactor_per_def_stats_state_result.item_duration': 'core/src/mindustry/content/Blocks.java',
            'source_impact_reactor_per_def_stats_state_result.liquid_capacity': 'core/src/mindustry/content/Blocks.java',
            'source_impact_reactor_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2497']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        self.assertEqual(ledger['N2497']['runtime_proof'], '/root/C07ImpactReactorPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2497']['tests'],
            [
                'test_c07_impact_reactor_per_def_stat_rows_registration',
                'test_all_c07_impact_reactor_per_def_stat_rows_input_evidence_is_exact',
                'test_impact_reactor_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_impact_reactor_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2497']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #59 (1-based in
        # the merged advances-34 DEFERRED base, 225
        # entries): the ImpactReactor per-def stat rows
        # entry is REMOVED -- size / health /
        # powerProduction / itemDuration /
        # liquidCapacity / requirements are live now as
        # a source-backed pure. Net 225 - 1 = 224. The
        # power-production, explosion and read/write
        # rows STAY.
        self.assertFalse(any(entry.startswith('ImpactReactor per-def stat rows (') for entry in ledger['N2497']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor power-production rows (') for entry in ledger['N2497']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor explosion rows (') for entry in ledger['N2497']['deferred_exprs']))
        self.assertEqual(len(ledger['N2497']['deferred_exprs']), 224)

    def test_all_c07_impact_reactor_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2497']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2497']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_per_def_stat_rows_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2490
        # precedent): the single ImpactReactor def
        # impact-reactor (Blocks.java:2632-2645) sets
        # size 4, health 900, powerProduction 130f,
        # itemDuration 140f, liquidCapacity 80f and
        # requirements lead 500 / silicon 300 /
        # graphite 400 / thorium 100 / surge-alloy 250
        # / metaglass 250. An unknown def id falls
        # back to the CLASS defaults (the N2304
        # fallback precedent): size 1 (Block.java:215),
        # health 40 POST-INIT (the class field is the
        # -1 sentinel, Block.java:190, resolved by
        # init() to round(1 * 1 * 40, 5) = 40,
        # Block.java:1378-1395, scaledHealth 40 with no
        # requirements), powerProduction 0f (declared
        # without an initializer,
        # PowerGenerator.java:25), itemDuration 60f
        # (ImpactReactor.java:20), liquidCapacity 30f
        # (ImpactReactor.java:26) and NO requirements
        # (the Block default is the empty array,
        # Block.java:356). The requirements dict is the
        # {item: amount} dict from the def (the N2490
        # precedent); the catalog carries the same rows
        # as an Array of {item, amount}
        # (content_registry.json, impact-reactor) --
        # except liquidCapacity, which the catalog does
        # not carry for this def. Pure-only: the caller
        # reads it; the existing advance + shouldConsume
        # pures are unchanged. Keep each Java expr on
        # ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_impact_reactor_per_def_stats_state', impact_reactor)
        self.assertIn('impactReactor = new ImpactReactor("impact-reactor"){{', impact_reactor)
        self.assertIn('requirements(Category.power, with(Items.lead, 500, Items.silicon, 300, Items.graphite, 400, Items.thorium, 100, Items.surgeAlloy, 250, Items.metaglass, 250));', impact_reactor)
        self.assertIn('size = 4;', impact_reactor)
        self.assertIn('health = 900;', impact_reactor)
        self.assertIn('powerProduction = 130f;', impact_reactor)
        self.assertIn('itemDuration = 140f;', impact_reactor)
        self.assertIn('liquidCapacity = 80f;', impact_reactor)
        self.assertIn('public int size = 1;', impact_reactor)
        self.assertIn('public int health = -1;', impact_reactor)
        self.assertIn('public float powerProduction;', impact_reactor)
        self.assertIn('public float itemDuration = 60f;', impact_reactor)
        self.assertIn('liquidCapacity = 30f;', impact_reactor)
        self.assertIn('public ItemStack[] requirements = {};', impact_reactor)
        self.assertIn('public class ImpactReactor extends PowerGenerator{', impact_reactor)
        self.assertIn('public float scaledHealth = -1;', impact_reactor)
        self.assertIn('scaledHealth = 40;', impact_reactor)
        self.assertIn('if(health == -1){', impact_reactor)
        self.assertIn('Mathf.round(size * size * scaledHealth, 5)', impact_reactor)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2497)', impact_reactor)
        # The proof's keys drive the per-def stats pure
        # (the impact-reactor def row, the size / health
        # values at the def vs the class, the power /
        # duration values at the def vs the class, the
        # requirements dict, the class fallback for an
        # unknown def id, and the def rows feeding the
        # N2450 stats pure as live inputs).
        proof = IMPACT_REACTOR_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_reactor',
            'stats_size_health',
            'stats_power_duration',
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
        self.assertIn('preload("res://src/game/SourceImpactReactorBuildState.gd")', proof)
        self.assertTrue(IMPACT_REACTOR_STATE.exists())
        self.assertTrue(IMPACT_REACTOR_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ImpactReactorPerDefStatRowsProof.gd', IMPACT_REACTOR_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_impact_reactor_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_reactor',
            'stats_size_health',
            'stats_power_duration',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
