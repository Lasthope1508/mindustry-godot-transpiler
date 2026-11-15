import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_INTAKE_GATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorIntakeGateProof.gd'
PAYLOAD_DECONSTRUCTOR_INTAKE_GATE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorIntakeGateProof.tscn'


class C07PayloadDeconstructorIntakeGateTests(unittest.TestCase):
    def test_c07_payload_deconstructor_intake_gate_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2308']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state')
        # The payload-deconstructor intake (N2291) applied
        # the frame incoming_payload push when the frame
        # payload was null -- the base gate only
        # (acceptPayload returns `this.payload == null`,
        # PayloadBlock.java:117) -- while the Deconstructor's
        # own acceptance gates (N2297) sat wired to the
        # frame verdicts but never consulted by the intake.
        # Java only ever calls handlePayload after
        # acceptPayload returns true (the pusher checks
        # first, BuildingComp.java:822-824 movePayload and
        # :844-845 dumpPayload), so the port's intake must
        # consult the gate too. N2308 is wiring only: no
        # new pure, no new symbols -- the tick computes the
        # N2297 verdict from the incoming dict itself and
        # applies the push only when it accepts. The ledger
        # entry references the reused N2297 acceptPayload
        # pure's five result symbols (shared ownership is
        # allowed -- the registry already carries symbols
        # claimed by more than one slice).
        self.assertEqual(
            ledger['N2308']['source_symbols'],
            [
                'source_payload_deconstructor_accept_payload_state_result.accepts',
                'source_payload_deconstructor_accept_payload_state_result.deconstructing_empty',
                'source_payload_deconstructor_accept_payload_state_result.payload_empty',
                'source_payload_deconstructor_accept_payload_state_result.has_requirements',
                'source_payload_deconstructor_accept_payload_state_result.fits',
            ],
        )
        for name in ledger['N2308']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_deconstructor_accept_payload_state_result.accepts': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_payload_state_result.deconstructing_empty': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_payload_state_result.payload_empty': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_accept_payload_state_result.has_requirements': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_accept_payload_state_result.fits': 'core/src/mindustry/world/blocks/payloads/Payload.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state')
        self.assertEqual(ledger['N2308']['runtime_proof'], '/root/C07PayloadDeconstructorIntakeGateProof')
        self.assertEqual(
            ledger['N2308']['tests'],
            [
                'test_c07_payload_deconstructor_intake_gate_registration',
                'test_all_c07_payload_deconstructor_intake_gate_input_evidence_is_exact',
                'test_payload_deconstructor_intake_gate_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_intake_gate',
            ],
        )
        self.assertTrue(ledger['N2308']['deferred_exprs'])

    def test_all_c07_payload_deconstructor_intake_gate_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2308']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_accept_payload_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2308']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_intake_gate_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The intake (N2308) consults the full
        # acceptPayload gate (PayloadDeconstructor.java:
        # 104-106) through the reused N2297 pure, computed
        # from the incoming dict itself -- Java only ever
        # calls handlePayload after acceptPayload returns
        # true (the pusher checks first:
        # BuildingComp.java:822-824, `if(next != null &&
        # next.build != null && next.build.team == team &&
        # next.build.acceptPayload(self(), todump)){` then
        # `next.build.handlePayload(self(), todump);`, and
        # the dumpPayload twin at :844-845). The incoming
        # dict carries its requirements as the N2233 array,
        # so the intake derives requirements_length from
        # the array length; the dict contract gains the
        # block_size key (the payload size in tiles) and a
        # push without it rejects (the pure defaults
        # block_size to maxPayloadSize + 1, so fits is
        # false) -- as does a non-dict push, which carries
        # neither. The push is consumed either way (the
        # N2278 Loader precedent). The pure's own
        # payload_empty / deconstructing_empty terms
        # subsume the old frame null check, so the verdict
        # IS the guard now.
        self.assertIn('source_payload_deconstructor_accept_payload_state(incoming_descriptor, frame.get("payload", null) != null, frame.get("deconstructing", null) != null)', payload_deconstructor)
        self.assertIn('var incoming_reqs: Array = incoming_payload.get("requirements", [])', payload_deconstructor)
        self.assertIn('var incoming_descriptor: Dictionary = {"requirements_length": incoming_reqs.size()}', payload_deconstructor)
        self.assertIn('if incoming_payload.has("block_size"):', payload_deconstructor)
        self.assertIn('incoming_descriptor["block_size"] = incoming_payload.get("block_size")', payload_deconstructor)
        self.assertIn('var intake_accepts: bool = false', payload_deconstructor)
        self.assertIn('if intake_accepts:', payload_deconstructor)
        self.assertIn('if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){', payload_deconstructor)
        self.assertIn('next.build.handlePayload(self(), todump);', payload_deconstructor)
        self.assertIn('if(other.acceptPayload(self(), todump)){', payload_deconstructor)
        self.assertIn('other.handlePayload(self(), todump);', payload_deconstructor)
        # The offered-payload path (N2297 wiring) stays
        # as-is: when BOTH an offer and a push are present,
        # the verdict from the offer governs
        # frame["accepts_payload"] (tick_frame_state, from
        # the offered descriptor) and the intake verdict
        # decides the push alone -- the intake never
        # overwrites frame["accepts_payload"].
        self.assertIn('the offer verdict governs the frame key', payload_deconstructor)
        self.assertIn('the intake never overwrites', payload_deconstructor)
        self.assertIn('frame["accepts_payload"]', payload_deconstructor)
        # The handle pure is untouched: it still sets
        # unconditionally, like Java -- the gate lives in
        # the driver, and the intake still converts the
        # pay_vector dict to the frame Vector2 at the
        # boundary.
        self.assertIn('static func source_payload_deconstructor_handle_payload_state', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_handle_payload_state(incoming_payload, float(incoming_source.get("x", 0.0)), float(incoming_source.get("y", 0.0)), float(world_pos.get("x", 0.0)), float(world_pos.get("y", 0.0)), incoming_rotation, _deconstructor_size_for_block(block_id), source_world_defaults.TILESIZE)', payload_deconstructor)
        # The documented limits now record the intake gate
        # as wired (N2308); the N2291 live fill, the N2297
        # acceptance gates, the N2233 advance and the N2210
        # gate text stays.
        self.assertIn('Intake full-gate wiring live (N2308)', payload_deconstructor)
        self.assertIn('Live deconstructing fill live (N2291)', payload_deconstructor)
        self.assertIn('Acceptance gates live (N2297)', payload_deconstructor)
        self.assertIn('updateTile advance (N2233)', payload_deconstructor)
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        # The proof's keys drive the live tick through the
        # gate: accepts when the verdict is true, drops
        # when it is false (oversize), drops when the push
        # carries no block_size, drops when deconstructing
        # is busy, the live tick wires the gate (the offer
        # verdict governs the frame key while the push is
        # gated by its own verdict), and a null push is
        # still consumed. Static checks: the proof preloads
        # the family state file that exists, and the scene
        # file references the proof script that exists.
        proof = PAYLOAD_DECONSTRUCTOR_INTAKE_GATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'intake_accepts_when_verdict_true',
            'intake_drops_when_verdict_false',
            'intake_drops_without_block_size',
            'intake_drops_when_deconstructing_busy',
            'live_tick_wires_the_gate',
            'null_push_still_consumed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_DECONSTRUCTOR_INTAKE_GATE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorIntakeGateProof.gd', scene)
        self.assertIn('C07PayloadDeconstructorIntakeGateProof', scene)

    def test_reference_graph_and_actual_c07_payload_deconstructor_intake_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorIntakeGateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_INTAKE_GATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'intake_accepts_when_verdict_true',
            'intake_drops_when_verdict_false',
            'intake_drops_without_block_size',
            'intake_drops_when_deconstructing_busy',
            'live_tick_wires_the_gate',
            'null_push_still_consumed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
