import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
RULES_DEFAULTS = ROOT / 'godot-mindustry/src/game/SourceRulesDefaults.gd'
REGISTRY = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'


class UnitFactoryShouldConsumeTests(unittest.TestCase):
    def test_unit_factory_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2124']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceUnitFactoryBuildState.source_unit_factory_should_consume_state', 'source_unit_factory_should_consume_state_input', 'Dictionary', ['should_consume', 'enabled', 'current_plan', 'has_payload', 'activate_unit_factories', 'unit_activation_delay', 'tick', 'constructing', 'has_upgrade', 'upgrade_unit', 'was_occupied', 'plan_unit', 'can_create', 'payload_efficiency', 'item_efficiency'], 'N2124'),
            ('SourceUnitFactoryBuildState.source_unit_factory_activate_state', 'source_unit_factory_activate_state_input', 'Dictionary', ['activate_unit_factories', 'unit_activation_delay', 'tick'], 'N2124'),
            ('SourceUnitFactoryBuildState.source_unit_factory_has_upgrade_state', 'source_unit_factory_has_upgrade_state_input', 'Dictionary', ['has_upgrade', 'upgrade_unit', 'unlocked', 'is_ai', 'banned'], 'N2124'),
            ('SourceUnitFactoryBuildState.source_unit_factory_assembler_plan_state', 'source_unit_factory_assembler_plan_state_input', 'Dictionary', ['unit', 'time', 'requirements', 'item_req', 'liquid_req'], 'N2124'),
            ('SourceUnitFactoryBuildState.source_unit_factory_assembler_cons_item_efficiency_state', 'source_unit_factory_assembler_cons_item_efficiency_state_input', 'Dictionary', ['item_efficiency'], 'N2124'),
            ('SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state', 'source_unit_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell'], 'N2109'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state']['params']],
            ['game', 'seconds'],
        )
        self.assertEqual(len(ledger['N2124']['source_symbols']), 42)
        self.assertTrue(ledger['N2124']['deferred_exprs'])

    def test_all_unit_factory_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2124']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceUnitFactoryBuildState.source_unit_factory_should_consume_state', 'SourceUnitFactoryBuildState.source_unit_factory_activate_state', 'SourceUnitFactoryBuildState.source_unit_factory_has_upgrade_state', 'SourceUnitFactoryBuildState.source_unit_factory_assembler_plan_state', 'SourceUnitFactoryBuildState.source_unit_factory_assembler_cons_item_efficiency_state', 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitFactory.java',
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/game/Team.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/core/GameState.java',
            'core/src/mindustry/ctype/UnlockableContent.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2124']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_uses_per_class_should_consume_for_unit_factory(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_unit_factory_should_consume_state(frame: Dictionary, block: Object, game: Object) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_activate_state(rules_state: Variant, team_id: int) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_has_upgrade_state(block: Object, payload_unit: String, rules_state: Variant, team_id: int) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_assembler_plan_state(block: Object, tier: int) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_assembler_cons_item_efficiency_state(frame: Dictionary, plan: Dictionary) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', factory)
        tick = factory.split('static func source_unit_factory_tick_buildings_state')[1]
        self.assertIn('source_unit_factory_should_consume_state(frame, block, game)', tick)
        self.assertNotIn("shouldConsume is the\n\t\t# frame's enabled flag until", tick)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_SHOULD_CONSUME_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ACTIVATE_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_HAS_UPGRADE_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PLAN_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CONS_ITEM_EFFICIENCY_STATE', factory)
        self.assertIn('UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT', RULES_DEFAULTS.read_text(encoding='utf-8'))
        registry = REGISTRY.read_text(encoding='utf-8')
        self.assertIn('def _reconstructor_upgrades(initializer: str)', registry)
        self.assertIn('def _assembler_plans(initializer: str)', registry)
        self.assertIn('properties["upgrades"] = upgrades', registry)
        self.assertIn('properties["assemblerPlans"] = assembler_plans', registry)

    def test_reference_graph_and_actual_unit_factory_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_UNIT_FACTORY_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
