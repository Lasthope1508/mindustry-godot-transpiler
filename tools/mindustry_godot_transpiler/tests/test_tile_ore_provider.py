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


class TileOreProviderTests(unittest.TestCase):
    def test_item_constructor_uses_source_name_not_field_slug(self):
        blocks = {b['field']: b for b in content_registry.extract_blocks(ROOT / 'mindustry-upstream')}
        self.assertIn('oreCopper', blocks)
        self.assertEqual(blocks['oreCopper']['id'], 'ore-copper')
        self.assertEqual(blocks['oreScrap']['properties']['itemDrop'], 'scrap')
        self.assertEqual(blocks['oreCrystalThorium']['properties']['itemDrop'], 'thorium')
        self.assertEqual(blocks['wallOreBeryllium']['properties']['itemDrop'], 'beryllium')
        self.assertEqual(blocks['sand']['id'], 'sand-floor')
        self.assertEqual(blocks['sand']['properties']['itemDrop'], 'sand')

    def test_source_ancestry_static_and_explicit_null(self):
        blocks = {b['id']: b for b in content_registry.extract_blocks(ROOT / 'mindustry-upstream')}
        self.assertEqual(blocks['stone-wall']['properties']['cacheLayer'], 'walls')
        self.assertEqual(blocks['cliff']['properties']['cacheLayer'], 'walls')
        self.assertEqual(blocks['shallow-water']['properties']['cacheLayer'], 'water')
        self.assertEqual(blocks['mechanical-drill']['properties']['cacheLayer'], 'normal')
        self.assertIsNone(blocks['air']['properties']['itemDrop'])
        self.assertEqual(blocks['graphitic-wall']['properties']['itemDrop'], 'graphite')
        # set() replaces this cache layer after construction: never fabricate normal.
        self.assertNotIn('cacheLayer', blocks['sand-water']['properties'])

    def test_creators_keep_source_positions_after_java_text_block(self):
        from mindustry_port.terrain_content import anonymous_body, block_creators
        source = 'class Blocks { void load(){ palette = """\nabc\ndef\n"""; /* ghost = new Floor("fake"); */ real = new Floor("real"){{ itemDrop = Items.lead; }}; } }'
        creators = list(block_creators(source))
        self.assertEqual(len(creators), 1)
        field, implementation, arguments, end = creators[0]
        self.assertEqual((field, implementation, arguments), ('real', 'Floor', '"real"'))
        self.assertEqual(anonymous_body(source, end), '{{ itemDrop = Items.lead; }}')

    def test_constructor_evaluation_and_unresolved_writes(self):
        from mindustry_port.terrain_content import TerrainContentResolver
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            world = root / 'core/src/mindustry/world'
            env = world / 'blocks/environment'
            env.mkdir(parents=True)
            (world / 'Block.java').write_text('public class Block { public Item itemDrop = null; public CacheLayer cacheLayer = CacheLayer.normal; public Block(String name){ super(name); } }')
            definitions = {
                'Floor': 'public class Floor extends Block { public Floor(String name){ super(name); } }',
                'NamedOre': 'public class NamedOre extends Floor { public NamedOre(Item ore){ this("deposit-" + ore.name, ore); } public NamedOre(String name, Item ore){ super(name); this.itemDrop = ore; } }',
                'Static': 'public class Static extends Block { public Static(String name){ super(name); cacheLayer = CacheLayer.walls; } }',
                'Unknown': 'public class Unknown extends Static { public Unknown(String name){ super(name); if(flag){ cacheLayer = choose(); } } }',
                'Leaf': 'public class Leaf extends Unknown { public Leaf(String name){ super(name); } }',
                'Late': 'public class Late extends Floor { public Late(String name){ super(name); } public void set(){ itemDrop = choose(); } }',
            }
            for name, text in definitions.items():
                (env / (name + '.java')).write_text(text)
            resolver = TerrainContentResolver(root, [{'field': 'oddField', 'id': 'actual-item-name'}])
            self.assertEqual(resolver.resolve('NamedOre', 'Items.oddField'), {'name': 'deposit-actual-item-name', 'itemDrop': 'oddField', 'cacheLayer': 'normal'})
            self.assertEqual(resolver.resolve('Static', '"wall"')['cacheLayer'], 'walls')
            for name in ['Unknown', 'Leaf']:
                with self.subTest(name=name):
                    self.assertNotIn('cacheLayer', resolver.resolve(name, '"unknown"'))
            self.assertNotIn('itemDrop', resolver.resolve('Late', '"late"'))
            self.assertEqual(resolver.resolve('NamedOre', 'pickItem()'), {})
            from mindustry_port.terrain_content import UNKNOWN
            self.assertIs(resolver.overrides('{{ if(flag){ itemDrop = Items.oddField; } }}')['itemDrop'], UNKNOWN)
            self.assertIs(resolver.overrides('{{ cacheLayer = choose(); }}')['cacheLayer'], UNKNOWN)
            self.assertIs(resolver.overrides('{{ other = cacheLayer = CacheLayer.walls; }}')['cacheLayer'], UNKNOWN)
            self.assertIs(resolver.overrides('{ public void init(){ itemDrop = Items.oddField; } }')['itemDrop'], UNKNOWN)
            self.assertEqual(resolver.overrides('{{ /* itemDrop = Items.fake; */ this.itemDrop = Items.oddField; cacheLayer = CacheLayer.walls; }}'), {'itemDrop': ('item', 'oddField', 'actual-item-name'), 'cacheLayer': ('layer', 'walls')})

    def test_terrain_contracts_registered(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text())['contracts']
        for owner, slice_id in [('SourceWorldTerrainRuntimeState.source_tile_ore_state', 'N2015'), ('SourceWorldTerrainRuntimeState.source_linked_ore_tiles_state', 'N2016')]:
            with self.subTest(owner=owner):
                self.assertTrue(owner in contracts, owner)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)

    def test_actual_tile_and_linked_provider_in_godot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/TileOreProviderProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=100)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('TILE_ORE_PROVIDER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])

    def test_missing_tile_metadata_is_rejected(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/TileOreProviderProof.tscn', '--quit-after', '3', '--', '--missing-metadata'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=100)
        output = result.stdout + result.stderr
        self.assertIn('Tile ore source definitions are unresolved', output)
        self.assertNotIn('TILE_ORE_PROVIDER_PROOF ', output)


if __name__ == '__main__':
    unittest.main()
