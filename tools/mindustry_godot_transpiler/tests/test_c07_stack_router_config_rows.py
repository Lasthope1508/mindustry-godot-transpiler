import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_CONFIG_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterConfigRowsProof.gd'
STACK_ROUTER_CONFIG_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterConfigRowsProof.tscn'


class C07StackRouterConfigRowsTests(unittest.TestCase):
    def test_c07_stack_router_config_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2449']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_config_state')
        # The StackRouter tick is live (N2181 power.status
        # row + N2240 updateTile advance + N2324 target()
        # selection + N2332 acceptItem gate), the draw
        # rows are live (N2433 draw / drawCached / glow /
        # drawSelect / icons) and the stats / plan rows
        # are live (N2442 setStats / drawPlanRegion /
        # minimapColor / rotatedOutput) but NOTHING
        # modeled the config / sortItem rows:
        # config(Item) sets sortItem (DuctRouter.
        # java:44), configClear clears it (:45),
        # buildConfiguration opens the item picker
        # (:124-127) and configured() runs super +
        # recache() + the minimap update when
        # !headless (:128-135). StackRouter inherits
        # all four from DuctRouter (StackRouter.
        # java:11, `public class StackRouter extends
        # DuctRouter{`) and overrides NONE of them.
        # N2449 ports them as ONE pure-only pure (the
        # N2443 discriminated-action precedent): the
        # action is "set" / "clear" / "none", the item
        # is null or a Dict {name, color} (the N2433
        # precedent), and the pure returns the
        # post-action sort item + the recache flag +
        # the minimap flag + the buildConfiguration
        # CALL record. Four new result symbols.
        self.assertEqual(
            ledger['N2449']['source_symbols'],
            [
                'source_stack_router_config_state_result.sort_item',
                'source_stack_router_config_state_result.recache_called',
                'source_stack_router_config_state_result.minimap_updated',
                'source_stack_router_config_state_result.configure_call',
            ],
        )
        expected_sources = {
            'source_stack_router_config_state_result.sort_item': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_config_state_result.recache_called': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_config_state_result.minimap_updated': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_config_state_result.configure_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
        }
        for name in ledger['N2449']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_stack_router_'))
        self.assertEqual(ledger['N2449']['runtime_proof'], '/root/C07StackRouterConfigRowsProof')
        self.assertEqual(
            ledger['N2449']['tests'],
            [
                'test_c07_stack_router_config_rows_registration',
                'test_all_c07_stack_router_config_rows_input_evidence_is_exact',
                'test_stack_router_config_rows_state',
                'test_reference_graph_and_actual_c07_stack_router_config_rows',
            ],
        )
        self.assertTrue(ledger['N2449']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #65 (1-based in
        # the merged advances-28 DEFERRED base): the
        # StackRouter config / sortItem rows entry is
        # REMOVED -- config(Item), configClear,
        # buildConfiguration and configured() are all
        # live now (the pure's sort_item IS the
        # post-action config() value, DuctRouter.
        # java:187-189). Net 258 - 1 = 257. The
        # read/write entry STAYS.
        self.assertFalse(any(entry.startswith('StackRouter config / sortItem rows (') for entry in ledger['N2449']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter read/write rows (') for entry in ledger['N2449']['deferred_exprs']))
        self.assertEqual(len(ledger['N2449']['deferred_exprs']), 257)

    def test_all_c07_stack_router_config_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2449']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_stack_router_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/input/InputHandler.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2449']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_config_rows_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The config rows (DuctRouter config(Item),
        # DuctRouter.java:44; configClear, :45;
        # buildConfiguration, :124-127; configured,
        # :128-135): config(Item) sets sortItem,
        # configClear clears it, buildConfiguration
        # opens the ItemSelection picker and
        # configured() runs super (the handler) +
        # recache() + renderer.minimap.update(tile)
        # when !headless. The dispatch: configClear
        # registers under void.class (Block.
        # java:922-924) and BuildingComp.configured
        # dispatches null values to void.class
        # (BuildingComp.java:1414-1416), so a null
        # configure clears; a non-null Item
        # dispatches to Item.class (BuildingComp.
        # java:1418). InputHandler.tileConfig calls
        # build.configured unconditionally
        # (InputHandler.java:728), so a configure
        # with the SAME item still recaches +
        # updates the minimap when !headless (the
        # N2443 lesson: NO equality condition).
        # recache() is BuildingComp.recache()
        # (BuildingComp.java:1285-1287), a
        # renderer-side cache invalidation with no
        # pure state of its own -- verified first,
        # so it is a CALL flag. config() returns
        # sortItem (DuctRouter.java:187-189), so
        # the pure's sort_item IS the post-action
        # config() value. The block is
        # configurable = true + saveConfig = true
        # (DuctRouter.java:33-34). Pure-only: the
        # tick never calls config / configured /
        # buildConfiguration. Keep each Java expr
        # on ONE comment line (the N2148 lesson: a
        # split line fails this test).
        self.assertIn('static func source_stack_router_config_state', stack_router)
        self.assertIn('config(Item.class, (DuctRouterBuild tile, Item item) -> tile.sortItem = item);', stack_router)
        self.assertIn('configClear((DuctRouterBuild tile) -> tile.sortItem = null);', stack_router)
        self.assertIn('public void buildConfiguration(Table table){', stack_router)
        self.assertIn('ItemSelection.buildTable(DuctRouter.this, table, content.items(), () -> sortItem, this::configure);', stack_router)
        self.assertIn('public void configured(Unit player, Object value){', stack_router)
        self.assertIn('super.configured(player, value);', stack_router)
        self.assertIn('if(!headless){', stack_router)
        self.assertIn('recache();', stack_router)
        self.assertIn('renderer.minimap.update(tile);', stack_router)
        self.assertIn('public @Nullable Item sortItem;', stack_router)
        self.assertIn('configurable = true;', stack_router)
        self.assertIn('saveConfig = true;', stack_router)
        self.assertIn('public void recache(){', stack_router)
        self.assertIn('if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);', stack_router)
        self.assertIn('public Item config(){', stack_router)
        self.assertIn('return sortItem;', stack_router)
        self.assertIn('public class StackRouter extends DuctRouter{', stack_router)
        self.assertIn('public class DuctRouterBuild extends Building{', stack_router)
        self.assertIn('configurations.put(void.class, (tile, value) -> cons.get((E)tile));', stack_router)
        self.assertIn('Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();', stack_router)
        self.assertIn('if(value instanceof Item) type = Item.class;', stack_router)
        self.assertIn('block.configurations.get(type).get(this, value);', stack_router)
        self.assertIn('build.configured(player == null || player.dead() ? null : player.unit(), value);', stack_router)
        # The documented limits record the config
        # rows as live.
        self.assertIn('Config rows live (N2449)', stack_router)
        # The proof's keys drive the pure (set /
        # clear / none, the headless guard, the
        # same-item minimap update, and the
        # buildConfiguration CALL record).
        proof = STACK_ROUTER_CONFIG_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'config_set',
            'config_clear',
            'config_none',
            'configured_headless',
            'configured_minimap',
            'build_configuration_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertTrue(STACK_ROUTER_STATE.exists())
        self.assertTrue(STACK_ROUTER_CONFIG_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackRouterConfigRowsProof.gd', STACK_ROUTER_CONFIG_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_router_config_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterConfigRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_CONFIG_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'config_set',
            'config_clear',
            'config_none',
            'configured_headless',
            'configured_minimap',
            'build_configuration_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
