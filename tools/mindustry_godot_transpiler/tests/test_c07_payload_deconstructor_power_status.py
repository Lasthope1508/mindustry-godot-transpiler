import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorPowerStatusProof.gd'


class C07PayloadDeconstructorPowerStatusTests(unittest.TestCase):
    def test_c07_payload_deconstructor_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2166']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165 proved the pure
        # power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump, beam-drill,
        # mend-projector, overdrive-projector, force-projector,
        # base-shield, regen-projector, constructor,
        # payload-loader, payload-unloader, payload-mass-driver
        # and unit-cargo-loader
        # drivers -- but PayloadDeconstructor (PayloadDeconstructor.java:17,
        # `public class PayloadDeconstructor extends PayloadBlock{`) has NO
        # placed-buildings driver at all, so deconstructor
        # (consumePower 3f, Blocks.java:6653; small-deconstructor 1f,
        # Blocks.java:6644) would deconstruct as
        # if power.status were 1.0. N2166 is the PayloadDeconstructor
        # family's live read: a new deconstructor driver
        # with a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency
        # is build.power.status) and the progress advance
        # (PayloadDeconstructor.java:142, `float shift = edelta() *
        # deconstructSpeed / deconstructing.buildTime();`) follows
        # it. PayloadDeconstructor extends PayloadBlock, not a drill or
        # factory, so it cannot reuse an existing frame key; it
        # gets its own family frame key
        # ("source_payload_deconstructor_building", the
        # mechanical-pump / beam-drill / mend-projector /
        # overdrive-projector / force-projector / base-shield /
        # regen-projector / constructor / payload-loader /
        # payload-unloader / payload-mass-driver /
        # unit-cargo-loader precedent). Two
        # new result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2166']['source_symbols'],
            [
                'source_payload_deconstructor_power_status_row_state_result.row',
                'source_payload_deconstructor_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2166']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_power_status_row_state_result.row': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_power_status_row_state',
                    'source_payload_deconstructor_power_status_row_state_result.has_power_row': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2166']['runtime_proof'], '/root/C07PayloadDeconstructorPowerStatusProof')
        self.assertEqual(
            ledger['N2166']['tests'],
            [
                'test_c07_payload_deconstructor_power_status_registration',
                'test_all_c07_payload_deconstructor_power_status_input_evidence_is_exact',
                'test_payload_deconstructor_power_status_row_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_power_status',
            ],
        )
        self.assertTrue(ledger['N2166']['deferred_exprs'])

    def test_all_c07_payload_deconstructor_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2166']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_power_status_row_state_result.row': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_power_status_row_state',
                    'source_payload_deconstructor_power_status_row_state_result.has_power_row': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2166']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_power_status_row_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the deconstructor
        # build state: the live frame value is
        # ConsumePower.efficiency (ConsumePower.java:39, `return
        # build.power.status;`), folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency;
        # a missing stamp folds to 1.0 before the first graph
        # update, the assembler fold (UnitAssembler.java:469,
        # `float powerStatus = !enabled ? 0f : power == null ?
        # 1f : power.status;`).
        self.assertIn('static func source_payload_deconstructor_power_status_row_state', payload_deconstructor)
        self.assertIn('return build.power.status;', payload_deconstructor)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', payload_deconstructor)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # deconstructor (3f) power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The progress advance follows the
        # folded efficiency (PayloadDeconstructor.java:142, `float shift =
        # edelta() * deconstructSpeed / deconstructing.buildTime();`,
        # keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test), with the shouldConsume
        # override returning deconstructing != null && enabled
        # (PayloadDeconstructor.java:220, `return deconstructing != null &&
        # enabled;`, default BuildingComp.java:755, `public boolean
        # shouldConsume(){`). The deconstructor has no liquid
        # consumer; the folded efficiency is the min over the
        # modeled consumers (power only).
        self.assertIn('"is_power": true', payload_deconstructor)
        self.assertIn('block.properties.has("consumePower")', payload_deconstructor)
        self.assertIn('hasConsumers = consumers.length > 0;', payload_deconstructor)
        self.assertIn('float shift = edelta() * deconstructSpeed / deconstructing.buildTime();', payload_deconstructor)
        self.assertIn('progress += shift;', payload_deconstructor)
        self.assertIn('return deconstructing != null && enabled;', payload_deconstructor)
        self.assertIn('public boolean shouldConsume(){', payload_deconstructor)
        self.assertIn('public class PayloadDeconstructor extends PayloadBlock{', payload_deconstructor)
        self.assertIn('public float deconstructSpeed = 2.5f;', payload_deconstructor)
        self.assertIn('public float maxPayloadSize = 4;', payload_deconstructor)
        self.assertIn('consumePower(3f);', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_tick_buildings_state', payload_deconstructor)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress / accum /
        # deconstructing / sense / draw keys: the deconstructor tick
        # advances no deconstruction progress / accum / payload
        # intake yet (PayloadDeconstructor.java:109-204 waits for
        # its own slice), so the progress advance
        # (PayloadDeconstructor.java:142) is what the efficiency
        # keys prove.
        proof = PAYLOAD_DECONSTRUCTOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'payload_deconstructor_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_deconstructor_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'payload_deconstructor_has_power_consumer',
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
