import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
CONSUME_ITEMS_STATE = ROOT / 'godot-mindustry/src/game/SourceConsumeItemsState.gd'


class C06UnitFactoryConsumeTriggerTests(unittest.TestCase):
    def test_c06_unit_factory_consume_trigger_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2128']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_consume_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceUnitFactoryBuildState.source_unit_factory_consume_state', 'source_unit_factory_consume_state_input', 'Dictionary', ['triggered', 'removed'], 'N2128'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceUnitFactoryBuildState.source_unit_factory_consume_state']['params']],
            ['frame', 'consumers', 'rows'],
        )
        self.assertEqual(len(ledger['N2128']['source_symbols']), 5)
        self.assertTrue(ledger['N2128']['deferred_exprs'])

    def test_all_c06_unit_factory_consume_trigger_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_unit_factory_consume_state_': 'SourceUnitFactoryBuildState.source_unit_factory_consume_state',
        }
        for name in ledger['N2128']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                prefix = next(p for p in owners if name.startswith(p))
                self.assertEqual(symbol['godot_owner'], owners[prefix])
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/blocks/units/UnitFactory.java',
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2128']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_consume_trigger_removes_only_item_rows(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_unit_factory_consume_state(frame: Dictionary, consumers: Array, rows: Array) -> Dictionary:', factory)
        consume = factory.split('static func source_unit_factory_consume_state')[1]
        self.assertIn('actor.trigger(frame)', consume)
        self.assertIn('row.has("liquid")', consume)
        self.assertIn('removed[item_name]', consume)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_CONSUME_STATE', factory)
        self.assertIn('Math.round(stack.amount * multiplier.get(build))', consume)
        consume_items = CONSUME_ITEMS_STATE.read_text(encoding='utf-8')
        self.assertIn('func trigger(build: Dictionary) -> void:', consume_items)
        # The trigger runs only at unit completion (UnitFactory /
        # Reconstructor updateTile, UnitAssembler spawned()), never
        # in the per-tick consumption passes: the tick driver must
        # call it only under a production-completion guard (N2137:
        # UnitFactoryBuild.updateTile, UnitFactory.java:392-442 —
        # consume() after payload = new UnitPayload(unit); N2138:
        # ReconstructorBuild.updateTile, Reconstructor.java:317-356
        # — consume() after the upgrade call).
        tick = factory.split('static func source_unit_factory_tick_buildings_state')[1].split('static func source_unit_factory_plan_requirements_state')[0]
        guard = 'if bool(production.get("completed", false)):'
        self.assertIn(guard, tick)
        before_guard, after_guard = tick.split(guard, 1)
        self.assertNotIn('source_unit_factory_consume_state(', before_guard)
        # One completion-guarded call per live production branch:
        # UnitFactory (N2137) + Reconstructor (N2138); UnitAssembler
        # keeps the consumption-only tick until N2139. Each call
        # site must sit under its own completion guard.
        self.assertEqual(after_guard.count('source_unit_factory_consume_state('), 2)
        segments = after_guard.split('source_unit_factory_consume_state(')
        self.assertIn('get("completed", false)):', segments[1])

    def test_reference_graph_and_actual_c06_unit_factory_consume_trigger(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06UnitFactoryConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_UNIT_FACTORY_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
