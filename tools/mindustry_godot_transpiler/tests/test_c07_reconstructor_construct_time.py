import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
OWNER_REGISTRY = ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd'
EXTRACTOR = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'
REGISTRY_JSON = ROOT / 'godot-mindustry/src/generated/content_registry.json'
CONSTRUCT_TIME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ReconstructorConstructTimeProof.gd'


class C07ReconstructorConstructTimeTests(unittest.TestCase):
    def test_c07_reconstructor_construct_time_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2143']['godot_owner'], 'SourceUnitFactoryBuildState.source_reconstructor_construct_time_state')
        # N2138 wired the reconstructor production tick and its
        # pure function takes construct_time as an input (backed
        # by the class default, Reconstructor.java:36 `public
        # float constructTime = 60 * 2;`), but the content
        # catalog never captured the per-block override, so the
        # tick driver reads block.properties.get("constructTime",
        # 120.0) and an additive-reconstructor upgrades on the
        # 120.0 default instead of its real 600.0
        # (Blocks.java:6310 `constructTime = 60f * 10f;`) -- and
        # a multiplicative-reconstructor on 120.0 instead of
        # 1800.0 (Blocks.java:6330 `constructTime = 60f * 30f;`).
        # N2143 is that catalog capture (the craftTime pattern,
        # N2117: the initializer's own assignment, else the class
        # default), exposed through one pure read on the block so
        # the driver stops inlining the fold: one new result
        # symbol, the construct_time the tick completes against.
        self.assertEqual(
            ledger['N2143']['source_symbols'],
            [
                'source_reconstructor_construct_time_state_result.construct_time',
            ],
        )
        for name in ledger['N2143']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/Reconstructor.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_reconstructor_construct_time_state')
        self.assertEqual(ledger['N2143']['runtime_proof'], '/root/C07ReconstructorConstructTimeProof')
        self.assertEqual(
            ledger['N2143']['tests'],
            [
                'test_c07_reconstructor_construct_time_registration',
                'test_all_c07_reconstructor_construct_time_input_evidence_is_exact',
                'test_reconstructor_construct_time_state',
                'test_reference_graph_and_actual_c07_reconstructor_construct_time',
            ],
        )
        self.assertTrue(ledger['N2143']['deferred_exprs'])

    def test_all_c07_reconstructor_construct_time_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2143']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_reconstructor_construct_time_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2143']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_reconstructor_construct_time_state(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        owner_registry = OWNER_REGISTRY.read_text(encoding='utf-8')
        extractor = EXTRACTOR.read_text(encoding='utf-8')
        # The pure read lives on the unit-factory build state,
        # following the has_upgrade / plan-requirements pattern
        # (block: Object, null-safe): the class default
        # (Reconstructor.java:36) when the catalog carries no
        # override, the per-block value otherwise
        # (Blocks.java:6310 additive 600.0, Blocks.java:6330
        # multiplicative 1800.0). The tick driver calls it instead
        # of inlining the fold.
        self.assertIn('static func source_reconstructor_construct_time_state', factory)
        self.assertIn('public float constructTime = 60 * 2;', factory)
        self.assertIn('constructTime = 60f * 10f;', factory)
        self.assertIn('source_reconstructor_construct_time_state(block)', factory)
        self.assertIn('PORT_GAME_SOURCE_RECONSTRUCTOR_CONSTRUCT_TIME_STATE', owner_registry)
        # The extractor captures constructTime for Reconstructor
        # blocks (the craftTime pattern, N2117): the block
        # initializer's own assignment, else the class default.
        self.assertIn('"constructTime"', extractor)
        # The regenerated catalog carries the real values, so the
        # driver no longer falls back to 120.0 for either block.
        registry = json.loads(REGISTRY_JSON.read_text(encoding='utf-8'))
        by_id = {block['id']: block for block in registry['blocks']}
        self.assertEqual(by_id['additive-reconstructor']['properties'].get('constructTime'), 600.0)
        self.assertEqual(by_id['multiplicative-reconstructor']['properties'].get('constructTime'), 1800.0)
        # The proof's keys drive the catalog values (both blocks),
        # the read's default + catalog paths, and the tick
        # completing exactly at the catalog time.
        proof = CONSTRUCT_TIME_PROOF.read_text(encoding='utf-8')
        for key in [
            'additive_construct_time_600',
            'multiplicative_construct_time_1800',
            'read_default_120',
            'read_additive_600',
            'tick_completes_at_600',
            'tick_incomplete_below_600',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_reconstructor_construct_time(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ReconstructorConstructTimeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RECONSTRUCTOR_CONSTRUCT_TIME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'additive_construct_time_600',
            'multiplicative_construct_time_1800',
            'read_default_120',
            'read_additive_600',
            'tick_completes_at_600',
            'tick_incomplete_below_600',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
