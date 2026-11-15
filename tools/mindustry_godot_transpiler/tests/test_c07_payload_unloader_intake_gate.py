import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_INTAKE_GATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderIntakeGateProof.gd'
PAYLOAD_UNLOADER_INTAKE_GATE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderIntakeGateProof.tscn'


class C07PayloadUnloaderIntakeGateTests(unittest.TestCase):
    def test_c07_payload_unloader_intake_gate_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2313']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_accept_payload_state')
        # The payload-unloader intake (N2279) applied
        # the frame incoming_payload push when the frame
        # payload was null -- the base gate only
        # (acceptPayload returns `this.payload == null`,
        # PayloadBlock.java:117) -- while the Unloader's
        # own acceptance gate (N2296, the Loader override
        # PayloadLoader.java:90-101) sat wired to the
        # frame verdicts but never consulted by the
        # intake. Java only ever calls handlePayload after
        # acceptPayload returns true (the pusher checks
        # first, BuildingComp.java:822-824 movePayload and
        # :844-845 dumpPayload), so the port's intake must
        # consult the gate too. N2313 is wiring only: no
        # new pure, no new symbols -- the tick builds the
        # N2296 descriptor from the incoming dict itself
        # and applies the push only when it accepts. The
        # ledger entry references the reused N2296
        # acceptPayload pure's three result symbols (shared
        # ownership is allowed -- the registry already
        # carries symbols claimed by more than one slice).
        self.assertEqual(
            ledger['N2313']['source_symbols'],
            [
                'source_payload_unloader_accept_payload_state_result.accept_payload',
                'source_payload_unloader_accept_payload_state_result.accept_item',
                'source_payload_unloader_accept_payload_state_result.accept_liquid',
            ],
        )
        for name in ledger['N2313']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_unloader_accept_payload_state_result.accept_payload': 'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
                    'source_payload_unloader_accept_payload_state_result.accept_item': 'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'source_payload_unloader_accept_payload_state_result.accept_liquid': 'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_accept_payload_state')
        self.assertEqual(ledger['N2313']['runtime_proof'], '/root/C07PayloadUnloaderIntakeGateProof')
        self.assertEqual(
            ledger['N2313']['tests'],
            [
                'test_c07_payload_unloader_intake_gate_registration',
                'test_all_c07_payload_unloader_intake_gate_input_evidence_is_exact',
                'test_payload_unloader_intake_gate_state',
                'test_reference_graph_and_actual_c07_payload_unloader_intake_gate',
            ],
        )
        self.assertTrue(ledger['N2313']['deferred_exprs'])

    def test_all_c07_payload_unloader_intake_gate_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2313']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_accept_payload_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2313']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_intake_gate_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The intake (N2313) consults the full
        # acceptPayload gate (the Loader override,
        # PayloadLoader.java:90-101, inherited by the
        # Unloader) through the reused N2296 pure,
        # computed from the incoming dict itself -- Java
        # only ever calls handlePayload after
        # acceptPayload returns true (the pusher checks
        # first: BuildingComp.java:822-824,
        # `if(next != null && next.build != null &&
        # next.build.team == team && next.build.acceptPayload(self(), todump)){`
        # then `next.build.handlePayload(self(), todump);`,
        # and the dumpPayload twin at :844-845). The
        # incoming payload dict gains the is_build_payload
        # / size keys (the N2296 descriptor contract);
        # the intake builds the descriptor from the
        # incoming dict (the block flags ride the payload
        # dict's block), and a push without the keys
        # rejects (the pure defaults is_build_payload to
        # false and fits to false without a size) -- as
        # does a non-dict push, which carries neither.
        # Occupancy and rejection differ: an input that
        # arrives while a payload is held STAYS for a
        # later tick (the N2279 keep-for-retry,
        # preserved -- the verdict is only evaluated when
        # the frame is empty), while a rejected push is
        # DROPPED, still consumed -- a non-container /
        # oversize / non-BuildPayload push would retry
        # forever.
        self.assertIn('source_payload_unloader_accept_payload_state(frame.get("payload", null) != null, incoming_descriptor)', payload_unloader)
        self.assertIn('var incoming_descriptor: Dictionary = {"is_build_payload": bool((incoming_payload_dict as Dictionary).get("is_build_payload", false)), "block": (incoming_payload_dict as Dictionary).get("block", {})}', payload_unloader)
        self.assertIn('if (incoming_payload_dict as Dictionary).has("size"):', payload_unloader)
        self.assertIn('incoming_descriptor["size"] = (incoming_payload_dict as Dictionary).get("size")', payload_unloader)
        self.assertIn('var intake_accepts: bool = false', payload_unloader)
        self.assertIn('if intake_accepts:', payload_unloader)
        self.assertIn('if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){', payload_unloader)
        self.assertIn('next.build.handlePayload(self(), todump);', payload_unloader)
        self.assertIn('if(other.acceptPayload(self(), todump)){', payload_unloader)
        self.assertIn('other.handlePayload(self(), todump);', payload_unloader)
        self.assertIn('keep-for-retry', payload_unloader)
        self.assertIn('would retry forever', payload_unloader)
        # The offered-payload path (N2296 wiring) stays
        # as-is: when BOTH an offer and a push are present,
        # the verdict from the offer governs
        # frame["accepts_payload"] and the intake verdict
        # decides the push alone -- the intake never
        # overwrites frame["accepts_payload"].
        self.assertIn('the offer verdict governs the frame key', payload_unloader)
        self.assertIn('the intake never overwrites', payload_unloader)
        self.assertIn('frame["accepts_payload"]', payload_unloader)
        # The handle pure is untouched: it still sets
        # unconditionally, like Java -- the gate lives in
        # the driver, and the intake still calls it once
        # with the frame + the incoming push.
        self.assertIn('static func source_payload_unloader_handle_payload_state', payload_unloader)
        self.assertIn('source_payload_unloader_handle_payload_state(frame, incoming)', payload_unloader)
        # The documented limits now record the intake gate
        # as wired (N2313); the N2279 live fill, the N2296
        # acceptance gate, the N2232 advance and the N2209
        # gate text stays.
        self.assertIn('Intake full-gate wiring live (N2313)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertIn('acceptPayload rows live (N2296)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        # The proof's keys drive the live tick through the
        # gate: accepts when the verdict is true, drops
        # when it is false (oversize), drops when the push
        # carries no descriptor keys, keeps the push when
        # the frame is occupied, the live tick wires the
        # gate (the offer verdict governs the frame key
        # while the push is gated by its own verdict), and
        # a null push is still consumed. Static checks: the
        # proof preloads the family state file that exists,
        # and the scene file references the proof script
        # that exists.
        proof = PAYLOAD_UNLOADER_INTAKE_GATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'intake_accepts_when_verdict_true',
            'intake_drops_when_verdict_false',
            'intake_drops_without_descriptor',
            'intake_keeps_when_occupied',
            'live_tick_wires_the_gate',
            'null_push_still_consumed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertIn('payload_unloader_build_state.source_payload_unloader_tick_buildings_state(', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_UNLOADER_INTAKE_GATE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderIntakeGateProof.gd', scene)
        self.assertIn('C07PayloadUnloaderIntakeGateProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_intake_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderIntakeGateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_INTAKE_GATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'intake_accepts_when_verdict_true',
            'intake_drops_when_verdict_false',
            'intake_drops_without_descriptor',
            'intake_keeps_when_occupied',
            'live_tick_wires_the_gate',
            'null_push_still_consumed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
