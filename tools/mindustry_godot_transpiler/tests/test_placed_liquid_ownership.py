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


class PlacedLiquidOwnershipTests(unittest.TestCase):
    def test_explicit_liquid_flags_follow_constructor_inheritance_and_initializer(self):
        with tempfile.TemporaryDirectory() as tmp:
            world = Path(tmp) / 'core/src/mindustry/world'
            folder = world / 'blocks/production'
            folder.mkdir(parents=True)
            (world / 'Block.java').write_text('public class Block { public boolean hasLiquids; }', encoding='utf-8')
            (folder / 'Drill.java').write_text('public class Drill extends Block { public Drill(String name){ hasLiquids = true; } }', encoding='utf-8')
            (folder / 'Child.java').write_text('public class Child extends Drill { public Child(String name){} }', encoding='utf-8')
            (folder / 'Off.java').write_text('public class Off extends Drill { public Off(String name){ hasLiquids = false; } }', encoding='utf-8')
            defaults = content_registry._power_defaults(Path(tmp))
            self.assertNotIn('hasLiquids', defaults['Block'])
            self.assertTrue(defaults['Drill']['hasLiquids'])
            self.assertTrue(defaults['Child']['hasLiquids'])
            self.assertFalse(defaults['Off']['hasLiquids'])
            source = 'drill = new Child("drill"){{ hasLiquids = false; }};'
            result = content_registry._block_properties(source, source.index('"drill"') + len('"drill"'), 'Child', power_defaults=defaults)
            self.assertFalse(result['hasLiquids'])

    def test_real_registry_drill_liquid_flag_and_registered_owner_contracts(self):
        base = ROOT / 'godot-mindustry/src/generated'
        data = json.loads((base / 'content_registry.json').read_text(encoding='utf-8'))
        drill = next(b for b in data['blocks'] if b['id'] == 'mechanical-drill')
        self.assertTrue(drill['properties']['hasLiquids'])
        contracts = json.loads((base / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for owner, slice_id in [
            ('SourceContentRegistryRuntimeState.source_liquid_catalog_state', 'N1999'),
            ('SourcePlacedBlockState.source_block_has_liquids_state', 'N2000'),
            ('SourcePlacedBlockState.source_initialize_building_liquids_state', 'N2001'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], slice_id)

    def test_liquid_owner_is_bound_on_real_placement_path(self):
        source = (ROOT / 'godot-mindustry/src/game/PortGame.gd').read_text(encoding='utf-8')
        body = source.split('func record_placed_block(', 1)[1].split('\nfunc ', 1)[0]
        self.assertIn('source_initialize_building_liquids_state', body)
        self.assertIn('content_catalog', body)
        self.assertNotIn('"mechanical-drill"', body)
        self.assertNotIn('range(11)', body)

    def test_live_building_storage_and_typed_catalog_runtime(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        if not godot:
            self.skipTest('Godot unavailable; native MCP remains required')
        run = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/PlacedLiquidOwnershipProof.tscn', '--quit-after', '240'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=90)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        self.assertNotIn('SCRIPT ERROR', output)
        proofs = [json.loads(s.split(' ', 1)[1]) for s in output.splitlines() if s.startswith('PLACED_LIQUID_OWNERSHIP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        self.assertTrue(proofs[0]['live_drill_owned'])
        self.assertTrue(proofs[0]['owned_consumption_matches'])
