import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorShouldConsumeProof.gd'
PAYLOAD_DECONSTRUCTOR_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorShouldConsumeProof.tscn'


class C07PayloadDeconstructorShouldConsumeTests(unittest.TestCase):
    def test_c07_payload_deconstructor_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2210']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_should_consume_state')
        # N2166 gave the payload-deconstructor its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO deconstructing state on the
        # payload-deconstructor frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- when full power.status reads
        # 1.0 while Java efficiency is 0. PayloadDeconstructorBuild
        # overrides shouldConsume (PayloadDeconstructor.java:219-221):
        # `return deconstructing != null && enabled;`. The
        # deconstructing field is `public @Nullable Payload
        # deconstructing;` (PayloadDeconstructor.java:52), set by
        # the updateTile advance (`deconstructing = payload;`,
        # PayloadDeconstructor.java:199, when moveInPayload
        # succeeds, PayloadDeconstructor.java:197) and cleared on
        # finish (PayloadDeconstructor.java:193). The gate has an
        # `&& enabled` term -- unlike the PayloadLoader /
        # PayloadUnloader gate (`return payload != null;`,
        # PayloadLoader.java:240-242), which has none -- so a
        # disabled deconstructor with a payload in progress still
        # does not consume. N2210 wires the gate into the
        # payload-deconstructor's OWN driver
        # (SourcePayloadDeconstructorBuildState.gd, frame key
        # "source_payload_deconstructor_building"): the frame gets
        # a `deconstructing` key (the Payload being deconstructed,
        # default null, the Java field nullable), the pure gate
        # reads only its null-ness plus the frame enabled flag
        # (tick-preserved, the factory precedent), and the driver
        # feeds `should_consume = deconstructing != null &&
        # enabled` to the machinery, so an idle deconstructor
        # folds efficiency 0 like Java. No live fill sets
        # frame["deconstructing"] yet -- the gate reads the frame
        # as-is, and the live fill (handlePayload / moveInPayload
        # / updateTile advance) waits for its own slice (new
        # deferral). Two new result symbols: the gate and the
        # deconstructing-presence flag it reads.
        self.assertEqual(
            ledger['N2210']['source_symbols'],
            [
                'source_payload_deconstructor_should_consume_state_result.should_consume',
                'source_payload_deconstructor_should_consume_state_result.deconstructing_present',
            ],
        )
        for name in ledger['N2210']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_should_consume_state_result.should_consume': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_should_consume_state',
                    'source_payload_deconstructor_should_consume_state_result.deconstructing_present': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2210']['runtime_proof'], '/root/C07PayloadDeconstructorShouldConsumeProof')
        self.assertEqual(
            ledger['N2210']['tests'],
            [
                'test_c07_payload_deconstructor_should_consume_registration',
                'test_all_c07_payload_deconstructor_should_consume_input_evidence_is_exact',
                'test_payload_deconstructor_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_should_consume',
            ],
        )
        self.assertTrue(ledger['N2210']['deferred_exprs'])
        # This slice resolves the N2166 PayloadDeconstructor gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, accept/handle payload,
        # sense, draw/icons, setBars, read/write, and dump rows
        # stay deferred, and the live deconstructing fill is a
        # new deferral.
        self.assertFalse(any(entry.startswith('PayloadDeconstructor shouldConsume gate (') for entry in ledger['N2210']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor live deconstructing fill (') for entry in ledger['N2210']['deferred_exprs']))

    def test_all_c07_payload_deconstructor_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2210']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_should_consume_state_result.should_consume': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_should_consume_state',
                    'source_payload_deconstructor_should_consume_state_result.deconstructing_present': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2210']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_should_consume_gate_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the payload-deconstructor build state:
        # PayloadDeconstructorBuild.shouldConsume() (PayloadDeconstructor.java:219,
        # `public boolean shouldConsume(){` with `return deconstructing != null && enabled;`,
        # PayloadDeconstructor.java:220) reads the nullable field `public @Nullable Payload
        # deconstructing;` (PayloadDeconstructor.java:52), set by the updateTile advance
        # (`deconstructing = payload;`, PayloadDeconstructor.java:199, when moveInPayload
        # succeeds, PayloadDeconstructor.java:197). PayloadDeconstructorBuild overrides
        # shouldConsume (PayloadDeconstructor.java:51, `public class PayloadDeconstructorBuild
        # extends PayloadBlockBuild<Payload>{`; PayloadDeconstructor.java:17, `public class
        # PayloadDeconstructor extends PayloadBlock{`), so the default (`return enabled;`,
        # BuildingComp.java:755-756) does not apply here. When the gate is false
        # updateConsumption forces efficiency to zero (BuildingComp.java:1960,
        # `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
        # The gate has an `&& enabled` term -- unlike the PayloadLoader / PayloadUnloader
        # gate (`return payload != null;`), so a disabled deconstructor with a payload in
        # progress still does not consume. The frame carries the deconstructing payload
        # (frame["deconstructing"], default null, the Java field nullable); the gate reads
        # only its null-ness. The updateTile progress advance (PayloadDeconstructor.java:142,
        # `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();` with
        # `progress += shift;`) follows the folded efficiency and waits for its own slice,
        # as do the live deconstructing fill (no live fill sets frame["deconstructing"] yet --
        # the gate reads the frame as-is), accept/handle payload, sense, and draw/bars.
        self.assertIn('static func source_payload_deconstructor_should_consume_state', payload_deconstructor)
        self.assertIn('frame.get("deconstructing", null) != null', payload_deconstructor)
        self.assertIn('deconstructing_present and enabled', payload_deconstructor)
        self.assertIn('public boolean shouldConsume(){', payload_deconstructor)
        self.assertIn('return deconstructing != null && enabled;', payload_deconstructor)
        self.assertIn('public @Nullable Payload deconstructing;', payload_deconstructor)
        self.assertIn('public class PayloadDeconstructor extends PayloadBlock{', payload_deconstructor)
        self.assertIn('public class PayloadDeconstructorBuild extends PayloadBlockBuild<Payload>{', payload_deconstructor)
        self.assertIn('boolean update = shouldConsume() && productionValid();', payload_deconstructor)
        self.assertIn('if(!update){', payload_deconstructor)
        self.assertIn('return enabled;', payload_deconstructor)
        self.assertIn('float shift = edelta() * deconstructSpeed / deconstructing.buildTime();', payload_deconstructor)
        self.assertIn('progress += shift;', payload_deconstructor)
        self.assertIn('deconstructing = payload;', payload_deconstructor)
        self.assertIn('consumePower(3f);', payload_deconstructor)
        self.assertIn('consumePower(1f);', payload_deconstructor)
        self.assertIn('"deconstructing": null', payload_deconstructor)
        self.assertIn('frame["deconstructing"]', payload_deconstructor)
        # The driver feeds the live gate to the machinery: the
        # gate call feeds should_consume into the fold.
        self.assertIn('static func source_payload_deconstructor_tick_buildings_state', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_should_consume_state(frame)', payload_deconstructor)
        self.assertIn('bool(gate.get("should_consume", true))', payload_deconstructor)
        # The documented limits record the gate as live; the old
        # N2166 deferral text is gone. The N2166 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        self.assertNotIn('runs with should_consume=true when enabled', payload_deconstructor)
        self.assertNotIn('deconstructing state is not tracked yet', payload_deconstructor)
        self.assertNotIn('no shouldConsume gate yet', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_power_status_row_state', payload_deconstructor)
        # The proof's keys drive the pure gate (true with a
        # deconstructing payload + enabled, false with no
        # deconstructing payload, false when disabled even with a
        # deconstructing payload -- the distinguishing key against
        # Loader/Unloader -- and the frame key defaulting to null
        # on a fresh bind) plus the live tick (efficiency 0 when
        # the gate is false, the N2166 power fold preserved when
        # the gate is true). There are no progress / accum / dump
        # keys: the updateTile advance (PayloadDeconstructor.java:109-204)
        # waits for its own slice, so the progress advance
        # (PayloadDeconstructor.java:142) is what the efficiency
        # keys prove. Static checks: the proof preloads the
        # payload-deconstructor state file that exists, and the
        # scene file references the proof script that exists.
        proof = PAYLOAD_DECONSTRUCTOR_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_deconstructing_and_enabled',
            'gate_false_when_no_deconstructing',
            'gate_false_when_disabled',
            'frame_key_default_null',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_should_consume_state(', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        scene = PAYLOAD_DECONSTRUCTOR_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorShouldConsumeProof.gd', scene)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_payload_deconstructor_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_deconstructing_and_enabled',
            'gate_false_when_no_deconstructing',
            'gate_false_when_disabled',
            'frame_key_default_null',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
