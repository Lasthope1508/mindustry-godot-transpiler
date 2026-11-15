import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_INTAKE_GATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderIntakeGateProof.gd'
PAYLOAD_LOADER_INTAKE_GATE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderIntakeGateProof.tscn'


class C07PayloadLoaderIntakeGateTests(unittest.TestCase):
    def test_c07_payload_loader_intake_gate_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2315']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_accept_payload_state')
        # The payload-loader intake (N2278) applied the
        # frame incoming_payload push when the frame
        # payload was null -- the base gate only
        # (acceptPayload returns `this.payload == null`,
        # PayloadBlock.java:117) -- while the Loader's own
        # acceptance gate (N2295) sat wired to the frame
        # verdict but never consulted by the intake. Java
        # only ever calls handlePayload after acceptPayload
        # returns true (the pusher checks first,
        # BuildingComp.java:822-824 movePayload and
        # :844-845 dumpPayload, and the unit drop at
        # InputHandler.java:667-669), so the port's intake
        # must consult the gate too. N2315 is wiring
        # only: no new pure, no new symbols -- the tick
        # computes the N2295 verdict from the incoming
        # dict itself and applies the push only when it
        # accepts. The ledger entry references the reused
        # N2295 acceptPayload pure's five result symbols
        # (shared ownership is allowed -- the registry
        # already carries symbols claimed by more than
        # one slice). No DEFERRED entry existed for this
        # gap (the N2295 worker added #311 live sources +
        # #312 descriptor contract but no intake-guard
        # entry, while the N2296 worker DID add #313 for
        # the Unloader), so DEFERRED stays unchanged in
        # count -- no entry is resolved, none invented.
        self.assertEqual(
            ledger['N2315']['source_symbols'],
            [
                'source_payload_loader_accept_payload_state_result.accepts',
                'source_payload_loader_accept_payload_state_result.fits',
                'source_payload_loader_accept_payload_state_result.is_item_container',
                'source_payload_loader_accept_payload_state_result.is_liquid_container',
                'source_payload_loader_accept_payload_state_result.is_battery',
            ],
        )
        for name in ledger['N2315']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadLoader.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_accept_payload_state')
        self.assertEqual(ledger['N2315']['runtime_proof'], '/root/C07PayloadLoaderIntakeGateProof')
        self.assertEqual(
            ledger['N2315']['tests'],
            [
                'test_c07_payload_loader_intake_gate_registration',
                'test_all_c07_payload_loader_intake_gate_input_evidence_is_exact',
                'test_payload_loader_intake_gate_state',
                'test_reference_graph_and_actual_c07_payload_loader_intake_gate',
            ],
        )
        self.assertTrue(ledger['N2315']['deferred_exprs'])

    def test_all_c07_payload_loader_intake_gate_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2315']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_accept_payload_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/input/InputHandler.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2315']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_intake_gate_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The intake (N2315) consults the full
        # acceptPayload gate (PayloadLoader.java:90-101)
        # through the reused N2295 pure, computed from
        # the incoming dict itself -- Java only ever
        # calls handlePayload after acceptPayload returns
        # true (the pusher checks first:
        # BuildingComp.java:822-824, `if(next != null &&
        # next.build != null && next.build.team == team &&
        # next.build.acceptPayload(self(), todump)){` then
        # `next.build.handlePayload(self(), todump);`,
        # the dumpPayload twin at :844-845, and the unit
        # drop at InputHandler.java:667-669). The incoming
        # dict IS the N2295 descriptor (is_build_payload /
        # block_size / has_items / unloadable /
        # item_capacity / has_liquids / liquid_capacity /
        # has_cons_power / cons_power_buffered); the pure
        # defaults every missing key to the rejecting value
        # EXCEPT block_size, which defaults to 0 (fits) --
        # so the intake injects the rejecting default
        # (maxBlockSize + 1) when the push carries no
        # block_size, the N2308 missing-block_size
        # precedent. A non-dict push carries no descriptor
        # and rejects too. The push is consumed either way
        # (the N2278 drop). The pure's has_payload term
        # subsumes the old frame null check, so the verdict
        # IS the guard now.
        self.assertIn('var intake_accepts: bool = false', payload_loader)
        self.assertIn('var incoming_descriptor: Dictionary = incoming_payload.duplicate()', payload_loader)
        self.assertIn('if not incoming_descriptor.has("block_size"):', payload_loader)
        self.assertIn('incoming_descriptor["block_size"] = SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE + 1', payload_loader)
        self.assertIn('source_payload_loader_accept_payload_state(incoming_descriptor, frame.get("payload", null) != null)', payload_loader)
        self.assertIn('if intake_accepts:', payload_loader)
        self.assertIn('if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){', payload_loader)
        self.assertIn('next.build.handlePayload(self(), todump);', payload_loader)
        self.assertIn('if(other.acceptPayload(self(), todump)){', payload_loader)
        self.assertIn('other.handlePayload(self(), todump);', payload_loader)
        self.assertIn('if(build.acceptPayload(build, unitPay)){', payload_loader)
        self.assertIn('build.handlePayload(build, unitPay);', payload_loader)
        # The offered-payload path (N2295 wiring) stays
        # as-is: when BOTH an offer and a push are present,
        # the verdict from the offer governs
        # frame["accepts_payload"] (stamped from the
        # offered descriptor) and the intake verdict
        # decides the push alone -- the intake never
        # overwrites frame["accepts_payload"].
        self.assertIn('the offer verdict governs the frame key', payload_loader)
        self.assertIn('the intake never overwrites', payload_loader)
        self.assertIn('frame["accepts_payload"]', payload_loader)
        # The handle pure is untouched: it still sets
        # unconditionally, like Java -- the gate lives in
        # the driver. The handle call still passes the
        # Loader's own size (3) as block_size -- that is
        # the BUILDING's size, not the payload's (the
        # descriptor's block_size comes from the incoming
        # dict); the size is the driver const and tilesize
        # is SourceWorldDefaults.
        self.assertIn('static func source_payload_loader_handle_payload_state', payload_loader)
        self.assertIn('source_payload_loader_handle_payload_state(incoming_payload, float(incoming_source.get("x", 0.0)), float(incoming_source.get("y", 0.0)), float(world_pos.get("x", 0.0)), float(world_pos.get("y", 0.0)), incoming_rotation, SOURCE_PAYLOAD_LOADER_SIZE, source_world_defaults.TILESIZE)', payload_loader)
        # The documented limits now record the intake gate
        # as wired (N2315); the N2295 acceptPayload rows,
        # the N2278 live fill, the N2231 advance and the
        # N2208 gate text stays.
        self.assertIn('Intake full-gate wiring live (N2315)', payload_loader)
        self.assertIn('acceptPayload rows live (N2295)', payload_loader)
        self.assertIn('live payload fill live (N2278)', payload_loader)
        self.assertIn('updateTile advance live (N2231)', payload_loader)
        self.assertIn('shouldConsume gate live (N2208)', payload_loader)
        # The proof's keys drive the live tick through the
        # gate: accepts when the verdict is true, drops
        # when it is false (oversize), drops when the push
        # carries no block_size, drops when a payload is
        # already held, the live tick wires the gate (the
        # offer verdict governs the frame key while the
        # push is gated by its own verdict), and a null
        # push is still consumed. Static checks: the proof
        # preloads the family state file that exists, and
        # the scene file references the proof script that
        # exists.
        proof = PAYLOAD_LOADER_INTAKE_GATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'intake_accepts_when_verdict_true',
            'intake_drops_when_verdict_false',
            'intake_drops_without_block_size',
            'intake_drops_when_payload_present',
            'live_tick_wires_the_gate',
            'null_push_still_consumed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_tick_buildings_state(', proof)
        self.assertTrue(PAYLOAD_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_LOADER_INTAKE_GATE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadLoaderIntakeGateProof.gd', scene)
        self.assertIn('C07PayloadLoaderIntakeGateProof', scene)

    def test_reference_graph_and_actual_c07_payload_loader_intake_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderIntakeGateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_INTAKE_GATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'intake_accepts_when_verdict_true',
            'intake_drops_when_verdict_false',
            'intake_drops_without_block_size',
            'intake_drops_when_payload_present',
            'live_tick_wires_the_gate',
            'null_push_still_consumed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
