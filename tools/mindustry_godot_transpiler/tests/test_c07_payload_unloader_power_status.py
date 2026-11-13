import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderPowerStatusProof.gd'


class C07PayloadUnloaderPowerStatusTests(unittest.TestCase):
    def test_c07_payload_unloader_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2163']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162 proved the pure power-row pattern
        # on the factory, adjacent-factory, drill, turret,
        # burst-drill, solid-pump, point-defense, tractor-beam,
        # fracker, mechanical-pump, beam-drill, mend-projector,
        # overdrive-projector, force-projector, base-shield,
        # regen-projector, constructor and payload-loader drivers -- but
        # PayloadUnloader (PayloadUnloader.java:8, `public class
        # PayloadUnloader extends PayloadLoader{`) has NO
        # placed-buildings driver at all, so payload-unloader
        # (consumePower 2f, Blocks.java:6695) would load as if
        # power.status were 1.0. N2163 is the PayloadUnloader
        # family's live read: a new payload-unloader driver with a
        # pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency
        # is build.power.status) and the load gate
        # (PayloadUnloader.java:69, `if(efficiency > 0.01f &&
        # timer(timerLoad, loadTime / efficiency)){`) follows
        # it. PayloadUnloader extends PayloadLoader, not a drill or
        # factory, so it cannot reuse an existing frame key; it
        # gets its own family frame key
        # ("source_payload_unloader_building", the mechanical-pump /
        # beam-drill / mend-projector / overdrive-projector /
        # force-projector / base-shield / regen-projector /
        # constructor precedent). Two new result symbols: the row
        # and its presence flag.
        self.assertEqual(
            ledger['N2163']['source_symbols'],
            [
                'source_payload_unloader_power_status_row_state_result.row',
                'source_payload_unloader_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2163']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_unloader_power_status_row_state_result.row': 'SourcePayloadUnloaderBuildState.source_payload_unloader_power_status_row_state',
                    'source_payload_unloader_power_status_row_state_result.has_power_row': 'SourcePayloadUnloaderBuildState.source_payload_unloader_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2163']['runtime_proof'], '/root/C07PayloadUnloaderPowerStatusProof')
        self.assertEqual(
            ledger['N2163']['tests'],
            [
                'test_c07_payload_unloader_power_status_registration',
                'test_all_c07_payload_unloader_power_status_input_evidence_is_exact',
                'test_payload_unloader_power_status_row_state',
                'test_reference_graph_and_actual_c07_payload_unloader_power_status',
            ],
        )
        self.assertTrue(ledger['N2163']['deferred_exprs'])

    def test_all_c07_payload_unloader_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2163']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_unloader_power_status_row_state_result.row': 'SourcePayloadUnloaderBuildState.source_payload_unloader_power_status_row_state',
                    'source_payload_unloader_power_status_row_state_result.has_power_row': 'SourcePayloadUnloaderBuildState.source_payload_unloader_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2163']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_power_status_row_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the payload-unloader build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_payload_unloader_power_status_row_state', payload_unloader)
        self.assertIn('return build.power.status;', payload_unloader)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', payload_unloader)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # payload-unloader (2f) power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The load gate follows the
        # folded efficiency (PayloadUnloader.java:69,
        # `if(efficiency > 0.01f && timer(timerLoad, loadTime /
        # efficiency)){`, keep on ONE comment line, the N2148
        # shootWarmup lesson: a split line fails this test), with
        # the battery unload (PayloadUnloader.java:98, `float
        # total = payload.build.power.status * cap;`) and the
        # shouldConsume override returning payload != null
        # (PayloadLoader.java:241, inherited by
        # PayloadUnloaderBuild, `return payload != null;`, default
        # BuildingComp.java:755, `public boolean shouldConsume(){`).
        self.assertIn('"is_power": true', payload_unloader)
        self.assertIn('block.properties.has("consumePower")', payload_unloader)
        self.assertIn('hasConsumers = consumers.length > 0;', payload_unloader)
        self.assertIn('if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){', payload_unloader)
        self.assertIn('float total = payload.build.power.status * cap;', payload_unloader)
        self.assertIn('return payload != null;', payload_unloader)
        self.assertIn('public boolean shouldConsume(){', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('public float maxPowerUnload = 80f;', payload_unloader)
        self.assertIn('static func source_payload_unloader_tick_buildings_state', payload_unloader)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no load / export /
        # battery keys: the payload-unloader tick advances no
        # moveInPayload / moveOutPayload / battery charge yet
        # (PayloadUnloader.java:50-110 wait for their own slices),
        # so the load gate (PayloadUnloader.java:69) is what the
        # efficiency keys prove.
        proof = PAYLOAD_UNLOADER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'payload_unloader_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_unloader_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'payload_unloader_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
