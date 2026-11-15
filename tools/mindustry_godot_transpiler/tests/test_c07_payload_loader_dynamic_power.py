import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_DYNAMIC_POWER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderDynamicPowerProof.gd'


class C07PayloadLoaderDynamicPowerTests(unittest.TestCase):
    def test_c07_payload_loader_dynamic_power_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2270']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_dynamic_power_usage_state')
        # The payload-loader power row (N2162) folds the static
        # consumePower(2f) def, the shouldConsume gate (N2208)
        # reads payload != null, and the updateTile advance
        # (N2231) charges the battery -- but the power consumer
        # itself is DYNAMIC (consumePowerDynamic,
        # PayloadLoader.java:80): the graph queries
        # requestedPower, which returns usage.get(entity)
        # (ConsumePowerDynamic.java:25), and the lambda charges
        # 0f with no payload, basePowerUse + maxPowerConsumption
        # (42f) while charging a battery, basePowerUse (2f)
        # otherwise. N2270 is the dynamic usage value: a pure
        # function over (should_consume, has_battery, exporting,
        # base 2f, max 40f) plus the driver stamping frame
        # power_usage every tick at fold time. Two new result
        # symbols: the usage and the charging flag.
        self.assertEqual(
            ledger['N2270']['source_symbols'],
            [
                'source_payload_loader_dynamic_power_usage_state_result.usage',
                'source_payload_loader_dynamic_power_usage_state_result.charging',
            ],
        )
        for name in ledger['N2270']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadLoader.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_loader_dynamic_power_usage_state_result.usage': 'SourcePayloadLoaderBuildState.source_payload_loader_dynamic_power_usage_state',
                    'source_payload_loader_dynamic_power_usage_state_result.charging': 'SourcePayloadLoaderBuildState.source_payload_loader_dynamic_power_usage_state',
                }[name])
        self.assertEqual(ledger['N2270']['runtime_proof'], '/root/C07PayloadLoaderDynamicPowerProof')
        self.assertEqual(
            ledger['N2270']['tests'],
            [
                'test_c07_payload_loader_dynamic_power_registration',
                'test_all_c07_payload_loader_dynamic_power_input_evidence_is_exact',
                'test_payload_loader_dynamic_power_usage_state',
                'test_reference_graph_and_actual_c07_payload_loader_dynamic_power',
            ],
        )
        self.assertTrue(ledger['N2270']['deferred_exprs'])

    def test_all_c07_payload_loader_dynamic_power_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2270']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_loader_dynamic_power_usage_state_result.usage': 'SourcePayloadLoaderBuildState.source_payload_loader_dynamic_power_usage_state',
                    'source_payload_loader_dynamic_power_usage_state_result.charging': 'SourcePayloadLoaderBuildState.source_payload_loader_dynamic_power_usage_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/consumers/ConsumePowerDynamic.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2270']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_dynamic_power_usage_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The pure dynamic usage function lives on the
        # payload-loader build state: init() registers the
        # dynamic consumer (PayloadLoader.java:77-84, guarded by
        # `if(loadPowerDynamic){` with `public boolean
        # loadPowerDynamic = true;`, PayloadLoader.java:27) with
        # the lambda (PayloadLoader.java:80, keep on ONE comment
        # line, the N2148 shootWarmup lesson: a split line fails
        # this test). basePowerUse is consPower.usage = 2f
        # (PayloadLoader.java:79, `basePowerUse = consPower !=
        # null ? consPower.usage : 0f;`, from the def
        # `consumePower(2f);`, Blocks.java:6686); the max is the
        # class constant `public float maxPowerConsumption =
        # 40f;` (PayloadLoader.java:26). The graph queries
        # requestedPower (ConsumePowerDynamic.java:24-25,
        # `public float requestedPower(Building entity){` with
        # `return usage.get(entity);`).
        self.assertIn('static func source_payload_loader_dynamic_power_usage_state', payload_loader)
        self.assertIn('consumePowerDynamic(basePowerUse, (PayloadLoaderBuild loader) -> loader.shouldConsume() ? (loader.hasBattery() && !loader.exporting ? maxPowerConsumption + basePowerUse : basePowerUse) : 0f);', payload_loader)
        self.assertIn('public boolean loadPowerDynamic = true;', payload_loader)
        self.assertIn('public float maxPowerConsumption = 40f;', payload_loader)
        self.assertIn('basePowerUse = consPower != null ? consPower.usage : 0f;', payload_loader)
        self.assertIn('return usage.get(entity);', payload_loader)
        self.assertIn('public float requestedPower(Building entity){', payload_loader)
        self.assertIn('return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;', payload_loader)
        self.assertIn('public boolean exporting = false;', payload_loader)
        # The driver stamps frame power_usage every tick at fold
        # time (before the advance call, so exporting is the
        # previous tick's value, matching the Java graph query);
        # the base reads the catalog consumePower (2.0 for
        # payload-loader) with the driver const as fallback, and
        # has_battery reads the payload dict's
        # block_cons_power_buffered flag (the N2231 contract).
        self.assertIn('frame["power_usage"]', payload_loader)
        self.assertIn('block.properties.get("consumePower"', payload_loader)
        self.assertIn('block_cons_power_buffered', payload_loader)
        self.assertIn('static func source_payload_loader_tick_buildings_state', payload_loader)
        # The proof's keys drive the pure function (zero / base /
        # charging / exporting branches) plus the catalog base
        # read and the live per-tick frame stamp. There are no
        # graph-demand keys: the port graph builds demand from
        # the static catalog consPower, so the per-building
        # dynamic value waits for a distribution-runtime slice
        # (the N2232 Unloader last_output_power precedent).
        proof = PAYLOAD_LOADER_DYNAMIC_POWER_PROOF.read_text(encoding='utf-8')
        for key in [
            'usage_zero_when_no_payload',
            'usage_base_when_no_battery',
            'usage_charging_when_battery_and_not_exporting',
            'usage_base_when_exporting',
            'usage_reads_catalog_base_power',
            'usage_stored_on_frame_each_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)

    def test_reference_graph_and_actual_c07_payload_loader_dynamic_power(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderDynamicPowerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_DYNAMIC_POWER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'usage_zero_when_no_payload',
            'usage_base_when_no_battery',
            'usage_charging_when_battery_and_not_exporting',
            'usage_base_when_exporting',
            'usage_reads_catalog_base_power',
            'usage_stored_on_frame_each_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
