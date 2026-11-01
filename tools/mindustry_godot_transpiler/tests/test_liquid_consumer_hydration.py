import json
import shutil
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools/mindustry_godot_transpiler'))
from mindustry_port import content_registry


class LiquidConsumerHydrationTests(unittest.TestCase):
    def test_source_calls_preserve_order_flags_zero_and_comments(self):
        source = '''{{
            // consumeLiquid(Liquids.fake, 99f).boost();
            consumeLiquid(Liquids.javaField, 3.5f / 60f).boost().update(false);
            /* consumeLiquid(Liquids.fake, 98f); */
            consumeLiquid(Liquids.secondField, 0f).optional(false, true);
        }}'''
        self.assertEqual(content_registry._consume_liquid_descriptors(source), [
            {'liquid': 'javaField', 'amount': 3.5 / 60, 'optional': True, 'booster': True, 'update': False},
            {'liquid': 'secondField', 'amount': 0.0, 'optional': False, 'booster': True},
        ])
        self.assertEqual(content_registry._consume_liquid_descriptors('{{ int x = 1; }}'), [])
        for body in [
            '{{ consumeLiquid(Liquids.water, heating / power); }}',
            '{{ consumeLiquid(Liquids.water, 1f).update(flag); }}',
            '{{ consumeLiquid(Liquids.water, 1f).unknown(); }}',
            '{{ consumeLiquid(Liquids.water, 1f); consumeLiquid(Liquids.oil, unknown); }}',
            '{{ if(enabled){ consumeLiquid(Liquids.water, 1f); } }}',
            '{{ coolant = consumeLiquid(Liquids.water, 1f); }}',
            '{{ consumeLiquid(Liquids.water, 1f).update(!true); }}',
            '{{ consumeLiquid(Liquids.water, 1f); findConsumer(filter).update(false); }}',
        ]:
            with self.subTest(body=body):
                self.assertIsNone(content_registry._consume_liquid_descriptors(body))

    def test_real_source_registry_exports_definitions_without_block_allowlist(self):
        data = json.loads((ROOT / 'godot-mindustry/src/generated/content_registry.json').read_text(encoding='utf-8'))
        blocks = {b['id']: b for b in data['blocks']}
        self.assertEqual(blocks['mechanical-drill']['properties']['consumeLiquid'], [{'liquid': 'water', 'amount': 0.05, 'optional': True, 'booster': True}])
        self.assertAlmostEqual(blocks['pneumatic-drill']['properties']['consumeLiquid'][0]['amount'], 3.5 / 60)
        self.assertNotIn('consumeLiquid', blocks['air']['properties'])
        self.assertGreater(sum('consumeLiquid' in b['properties'] for b in blocks.values()), 20)

    def test_same_slice_contracts_and_placement_binding_are_registered(self):
        base = ROOT / 'godot-mindustry/src/generated'
        contracts = json.loads((base / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for method, slice_id in [('source_liquid_consumer_definitions_state', 'N2002'), ('source_bind_liquid_consumers_state', 'N2003')]:
            with self.subTest(method=method):
                self.assertEqual(contracts['SourceConsumeLiquidState.' + method]['source_slice'], slice_id)
        source = (ROOT / 'godot-mindustry/src/game/PortGame.gd').read_text(encoding='utf-8')
        body = source.split('func record_placed_block(', 1)[1].split('\nfunc ', 1)[0]
        self.assertIn('SourceConsumeLiquidState.source_bind_liquid_consumers_state(block, content_catalog)', body)
        self.assertNotIn('"mechanical-drill"', body)
        self.assertNotIn('0.05', body)

    def test_live_block_shared_consumers_and_optional_efficiency_runtime(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot, 'Godot required for hydration proof')
        run = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/LiquidConsumerHydrationProof.tscn', '--quit-after', '240'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=90)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        self.assertNotIn('SCRIPT ERROR', output)
        rows = [json.loads(x.split(' ', 1)[1]) for x in output.splitlines() if x.startswith('LIQUID_CONSUMER_HYDRATION_PROOF ')]
        self.assertEqual(len(rows), 1, output)
        self.assertTrue(rows[0]['matches'], rows[0])
