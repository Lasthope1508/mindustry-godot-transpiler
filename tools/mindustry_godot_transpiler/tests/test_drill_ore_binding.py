import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools/mindustry_godot_transpiler'))
from mindustry_port import content_registry


class DrillOreBindingTests(unittest.TestCase):
    def test_ancestry_constructor_overrides_and_unresolved_descendants(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sources = root / 'core/src/mindustry/world/blocks/production'
            sources.mkdir(parents=True)
            definitions = {
                'Drill': 'public class Drill extends Block { public @Nullable Item blockedItem; public @Nullable Seq<Item> blockedItems; public Drill(String name){} }',
                'Custom': 'public class Custom extends Drill { public Custom(String name){ blockedItem = Items.alpha; } }',
                'Leaf': 'public class Leaf extends Custom { public Leaf(String name){ blockedItems = Seq.with(Items.beta, Items.alpha); } }',
                'Unknown': 'public class Unknown extends Custom { public Unknown(String name){ if(enabled){ blockedItem = choose(); } } }',
                'UnknownChild': 'public class UnknownChild extends Unknown {}',
                'Other': 'public class Other extends Block { public @Nullable Item blockedItem; public @Nullable Seq<Item> blockedItems; }',
            }
            for name, source in definitions.items():
                (sources / (name + '.java')).write_text(source)
            actual = content_registry._drill_blocked_defaults(root)
            self.assertEqual(actual, {'Drill': {'blockedItem': None, 'blockedItems': None}, 'Custom': {'blockedItem': 'alpha', 'blockedItems': None}, 'Leaf': {'blockedItem': 'alpha', 'blockedItems': ['beta', 'alpha']}})

    def test_blocked_item_parser_preserves_fields_null_and_order(self):
        self.assertEqual(content_registry._drill_blocked_definitions('{{ blockedItem = Items.thorium; }}'), {'blockedItem': 'thorium'})
        self.assertEqual(content_registry._drill_blocked_definitions('{{ blockedItems = Seq.with(Items.alpha, Items.beta); blockedItem = null; }}'), {'blockedItems': ['alpha', 'beta'], 'blockedItem': None})
        self.assertEqual(content_registry._drill_blocked_definitions('{{ /* blockedItem = Items.fake; */ int x = 0; }}'), {})
        self.assertEqual(content_registry._drill_blocked_definitions('{{ blockedItems = Seq.with(); }}'), {'blockedItems': []})
        for value in ['{{ if(enabled){ blockedItem = Items.thorium; } }}', '{{ blockedItem = choose(); }}', '{{ blockedItems = custom; }}', '{{ blockedItems.add(Items.thorium); }}', '{{ blockedItem = Items.thorium; blockedItem = choose(); }}', '{{ blockedItem = Items.thorium; blockedItems = new Seq<>(); }}']:
            with self.subTest(value=value):
                self.assertIsNone(content_registry._drill_blocked_definitions(value))

    def test_real_registry_exports_drill_ancestry_and_blocked_fields(self):
        data = json.loads((ROOT / 'godot-mindustry/src/generated/content_registry.json').read_text(encoding='utf-8'))
        blocks = {b['id']: b for b in data['blocks']}
        self.assertEqual(blocks['impact-drill']['properties']['blockedItem'], 'thorium')
        self.assertIsNone(blocks['impact-drill']['properties']['blockedItems'])
        self.assertIsNone(blocks['mechanical-drill']['properties']['blockedItem'])
        self.assertIsNone(blocks['mechanical-drill']['properties']['blockedItems'])
        self.assertNotIn('blockedItem', blocks['air']['properties'])
        defaults = content_registry._drill_blocked_defaults(ROOT / 'mindustry-upstream')
        self.assertIn('Drill', defaults)
        self.assertIn('BurstDrill', defaults)
        self.assertNotIn('BeamDrill', defaults)

    def test_item_registration_order_and_source_priority_survive_export(self):
        items = content_registry.extract_items(ROOT / 'mindustry-upstream', ROOT / 'godot-mindustry')
        generated = json.loads((ROOT / 'godot-mindustry/src/generated/content_registry.json').read_text(encoding='utf-8'))['items']
        self.assertEqual([i['field'] for i in items], [i['field'] for i in generated])
        sand = next(i for i in generated if i['field'] == 'sand')
        self.assertIs(sand['properties']['lowPriority'], True)

    def test_ore_binding_contracts_are_registered_in_own_slices(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for owner, slice_id in [('SourceContentRegistryRuntimeState.source_item_catalog_state', 'N2011'), ('SourceDrillRuntimeState.source_init_blocked_items_state', 'N2012'), ('SourceDrillRuntimeState.source_bind_ore_items_state', 'N2013')]:
            with self.subTest(owner=owner):
                self.assertTrue(owner in contracts, owner)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)

    def test_real_catalog_drill_binding_in_godot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/DrillOreBindingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=100)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('DRILL_ORE_BINDING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
