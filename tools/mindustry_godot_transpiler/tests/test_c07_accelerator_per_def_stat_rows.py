import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorPerDefStatRowsProof.gd'
ACCELERATOR_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorPerDefStatRowsProof.tscn'


class C07AcceleratorPerDefStatRowsTests(unittest.TestCase):
    def test_c07_accelerator_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2498']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_per_def_stats_state')
        # The Accelerator tick is live (N2191 advance +
        # N2271 launch + N2422 bar + N2485 progress /
        # isCoreBuilt) but NOTHING modeled the per-def
        # stat rows as a source-backed pure: the
        # interplanetary-accelerator def
        # (Blocks.java:6823-6832) sets size 7,
        # scaledHealth 80, powerBufferRequirement
        # 1,000,000f and requirements copper 16000 /
        # silicon 11000 / thorium 13000 / titanium
        # 12000 / surge-alloy 6000 / phase-fabric
        # 5000, while the values only existed as
        # constants in the driver header comment.
        # N2498 ports them as ONE pure-only stats
        # pure (the N2304 / N2442 / N2489 / N2490
        # verification-slice precedent): the def's
        # rows for interplanetary-accelerator, with
        # the CLASS defaults (size 1, scaledHealth
        # -1, powerBufferRequirement 0f, no
        # requirements) for an unknown def id (the
        # N2304 fallback precedent). Four new result
        # symbols: the size + scaled health + power
        # buffer requirement + requirements.
        self.assertEqual(
            ledger['N2498']['source_symbols'],
            [
                'source_accelerator_per_def_stats_state_result.size',
                'source_accelerator_per_def_stats_state_result.scaled_health',
                'source_accelerator_per_def_stats_state_result.power_buffer_requirement',
                'source_accelerator_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_accelerator_per_def_stats_state_result.size': 'core/src/mindustry/content/Blocks.java',
            'source_accelerator_per_def_stats_state_result.scaled_health': 'core/src/mindustry/content/Blocks.java',
            'source_accelerator_per_def_stats_state_result.power_buffer_requirement': 'core/src/mindustry/content/Blocks.java',
            'source_accelerator_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2498']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceAcceleratorBuildState.source_accelerator_'))
        self.assertEqual(ledger['N2498']['runtime_proof'], '/root/C07AcceleratorPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2498']['tests'],
            [
                'test_c07_accelerator_per_def_stat_rows_registration',
                'test_all_c07_accelerator_per_def_stat_rows_input_evidence_is_exact',
                'test_accelerator_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_accelerator_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2498']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #64 (1-based in
        # the merged advances-34 DEFERRED base, 225
        # entries): the Accelerator per-def stat rows
        # entry is REMOVED -- size / scaledHealth /
        # powerBufferRequirement / requirements are
        # live now as a source-backed pure. Net 225 -
        # 1 = 224. The launch and launch animator
        # rows STAY.
        self.assertFalse(any(entry.startswith('Accelerator per-def stat rows (') for entry in ledger['N2498']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch rows (') for entry in ledger['N2498']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch animator rows (') for entry in ledger['N2498']['deferred_exprs']))
        self.assertEqual(len(ledger['N2498']['deferred_exprs']), 224)

    def test_all_c07_accelerator_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2498']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceAcceleratorBuildState.source_accelerator_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2498']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_per_def_stat_rows_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2489 / N2490
        # precedent): the single Accelerator def
        # interplanetary-accelerator
        # (Blocks.java:6823-6832) sets size 7,
        # scaledHealth 80, powerBufferRequirement
        # 1,000,000f and requirements copper 16000 /
        # silicon 11000 / thorium 13000 / titanium
        # 12000 / surge-alloy 6000 / phase-fabric
        # 5000. An unknown def id falls back to the
        # CLASS defaults (the N2304 fallback
        # precedent): size 1 (Block.java:215),
        # scaledHealth -1 (Block.java:188 -- the
        # FIELD default; Block.init() resolves it to
        # 40 when health == -1, Block.java:1380-1381,
        # and that resolution lives in
        # SourceBlockInitHealthState, not here),
        # powerBufferRequirement 0f (the uninitialized
        # float field, Accelerator.java:41) and NO
        # requirements (the Block default is the empty
        # array, Block.java:356). The requirements
        # dict is the {item: amount} dict from the def
        # (the SourceAcceleratorBuildState capacities
        # precedent); the catalog carries the same rows
        # as an Array of {item, amount}
        # (content_registry.json,
        # interplanetary-accelerator). Pure-only: the
        # caller reads it; the existing pures are
        # unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_accelerator_per_def_stats_state', accelerator)
        self.assertIn('interplanetaryAccelerator = new Accelerator("interplanetary-accelerator"){{', accelerator)
        self.assertIn('requirements(Category.effect, BuildVisibility.campaignOnly, with(Items.copper, 16000, Items.silicon, 11000, Items.thorium, 13000, Items.titanium, 12000, Items.surgeAlloy, 6000, Items.phaseFabric, 5000));', accelerator)
        self.assertIn('size = 7;', accelerator)
        self.assertIn('scaledHealth = 80;', accelerator)
        self.assertIn('powerBufferRequirement = 1_000_000f;', accelerator)
        self.assertIn('public float powerBufferRequirement;', accelerator)
        self.assertIn('public float scaledHealth = -1;', accelerator)
        self.assertIn('public int size = 1;', accelerator)
        self.assertIn('public ItemStack[] requirements = {};', accelerator)
        self.assertIn('public class Accelerator extends Block{', accelerator)
        self.assertIn('scaledHealth = 40;', accelerator)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2498)', accelerator)
        # The proof's keys drive the per-def stats pure
        # (the interplanetary-accelerator def row, the
        # size + scaled-health values at the def vs the
        # class, the power buffer requirement at the def
        # vs the class, the requirements dict, the class
        # fallback for an unknown def id, and the def
        # rows feeding the N2422 bar pure as live
        # inputs).
        proof = ACCELERATOR_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_accelerator',
            'stats_size_health',
            'stats_power_buffer',
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
        self.assertIn('preload("res://src/game/SourceAcceleratorBuildState.gd")', proof)
        self.assertTrue(ACCELERATOR_STATE.exists())
        self.assertTrue(ACCELERATOR_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07AcceleratorPerDefStatRowsProof.gd', ACCELERATOR_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_accelerator_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_accelerator',
            'stats_size_health',
            'stats_power_buffer',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
