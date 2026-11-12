import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'


class C06UnitAssemblerPayloadTriggerTests(unittest.TestCase):
    def test_c06_unit_assembler_payload_trigger_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2130']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state', 'source_unit_factory_assembler_payload_trigger_state_input', 'Dictionary', ['triggered', 'removed', 'cleared', 'blocks', 'total'], 'N2130'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state']['params']],
            ['frame', 'plan'],
        )
        self.assertEqual(len(ledger['N2130']['source_symbols']), 7)
        self.assertTrue(ledger['N2130']['deferred_exprs'])

    def test_all_c06_unit_assembler_payload_trigger_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_unit_factory_assembler_payload_trigger_state_': 'SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state',
        }
        for name in ledger['N2130']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                prefix = next(p for p in owners if name.startswith(p))
                self.assertEqual(symbol['godot_owner'], owners[prefix])
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/type/PayloadSeq.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2130']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_assembler_payload_trigger_removes_plan_stacks_then_clears(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_unit_factory_assembler_payload_trigger_state(frame: Dictionary, plan: Dictionary) -> Dictionary:', factory)
        trigger = factory.split('static func source_unit_factory_assembler_payload_trigger_state')[1]
        self.assertIn('round(float(stack.get("amount", 0)) * multiplier)', trigger)
        self.assertIn('Math.round(stack.amount * mult)', trigger)
        self.assertIn('build.getPayloads().remove(stack.item, Math.round(stack.amount * mult));', trigger)
        self.assertIn('blocks.clear()', trigger)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PAYLOAD_TRIGGER_STATE', factory)
        # The trigger + clear run only at unit completion
        # (UnitAssemblerBuild.spawned()), never in the per-tick
        # consumption passes: the tick driver must not call it, and
        # the shouldConsume gate keeps reading the frame default
        # until the wiring slice lands.
        tick = factory.split('static func source_unit_factory_tick_buildings_state')[1].split('static func source_unit_factory_plan_requirements_state')[0]
        self.assertNotIn('source_unit_factory_assembler_payload_trigger_state(', tick)
        gate = factory.split('static func source_unit_factory_should_consume_state')[1].split('static func source_unit_factory_tick_buildings_state')[0]
        self.assertNotIn('source_unit_factory_assembler_payload_trigger_state(', gate)

    def test_reference_graph_and_actual_c06_unit_assembler_payload_trigger(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06UnitAssemblerPayloadTriggerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_UNIT_ASSEMBLER_PAYLOAD_TRIGGER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
