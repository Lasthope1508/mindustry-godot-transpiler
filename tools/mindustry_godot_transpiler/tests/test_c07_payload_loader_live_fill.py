import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderLiveFillProof.gd'
PAYLOAD_LOADER_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderLiveFillProof.tscn'


class C07PayloadLoaderLiveFillTests(unittest.TestCase):
    def test_c07_payload_loader_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2278']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state')
        # The payload-loader gate (N2208) reads payload != null,
        # the updateTile advance (N2231) moves the payload in
        # and out and loads it, and the dynamic power value
        # (N2270) prices the battery charge -- but nothing ever
        # SET the payload: handlePayload intake and takePayload
        # clear waited for their own slice, so a live loader
        # never held a payload at all. N2278 is the live fill:
        # handlePayload (PayloadBlock.java:121-127, with the
        # Loader override PayloadLoader.java:104-107 clearing
        # exporting) sets the payload, clamps payVector to
        # +/-size*tilesize/2 around the source offset, and
        # records payRotation from the payload; takePayload
        # (PayloadBlock.java:145-149) returns the held payload
        # and clears it. Six new result symbols: the four
        # handle results plus the two take results.
        self.assertEqual(
            ledger['N2278']['source_symbols'],
            [
                'source_payload_loader_handle_payload_state_result.payload',
                'source_payload_loader_handle_payload_state_result.pay_vector',
                'source_payload_loader_handle_payload_state_result.pay_rotation',
                'source_payload_loader_handle_payload_state_result.exporting',
                'source_payload_loader_take_payload_state_result.payload_taken',
                'source_payload_loader_take_payload_state_result.payload_after',
            ],
        )
        for name in ledger['N2278']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_loader_handle_payload_state_result.payload': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_loader_handle_payload_state_result.pay_vector': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_loader_handle_payload_state_result.pay_rotation': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_loader_handle_payload_state_result.exporting': 'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
                    'source_payload_loader_take_payload_state_result.payload_taken': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_loader_take_payload_state_result.payload_after': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_loader_handle_payload_state_result.payload': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_handle_payload_state_result.pay_vector': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_handle_payload_state_result.pay_rotation': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_handle_payload_state_result.exporting': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_take_payload_state_result.payload_taken': 'SourcePayloadLoaderBuildState.source_payload_loader_take_payload_state',
                    'source_payload_loader_take_payload_state_result.payload_after': 'SourcePayloadLoaderBuildState.source_payload_loader_take_payload_state',
                }[name])
        self.assertEqual(ledger['N2278']['runtime_proof'], '/root/C07PayloadLoaderLiveFillProof')
        self.assertEqual(
            ledger['N2278']['tests'],
            [
                'test_c07_payload_loader_live_fill_registration',
                'test_all_c07_payload_loader_live_fill_input_evidence_is_exact',
                'test_payload_loader_live_fill_state',
                'test_reference_graph_and_actual_c07_payload_loader_live_fill',
            ],
        )
        self.assertTrue(ledger['N2278']['deferred_exprs'])

    def test_all_c07_payload_loader_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2278']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_loader_handle_payload_state_result.payload': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_handle_payload_state_result.pay_vector': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_handle_payload_state_result.pay_rotation': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_handle_payload_state_result.exporting': 'SourcePayloadLoaderBuildState.source_payload_loader_handle_payload_state',
                    'source_payload_loader_take_payload_state_result.payload_taken': 'SourcePayloadLoaderBuildState.source_payload_loader_take_payload_state',
                    'source_payload_loader_take_payload_state_result.payload_after': 'SourcePayloadLoaderBuildState.source_payload_loader_take_payload_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2278']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_live_fill_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The pure handle function ports handlePayload
        # (PayloadBlock.java:121-127): `this.payload =
        # (T)payload;` (:122), `this.payVector.set(source).
        # sub(this).clamp(-size * tilesize / 2f, -size *
        # tilesize / 2f, size * tilesize / 2f, size * tilesize
        # / 2f);` (:123), `this.payRotation =
        # payload.rotation();` (:124), `updatePayload();`
        # (:126) -- plus the Loader override
        # (PayloadLoader.java:104-107): `super.handlePayload
        # (source, payload);` (:105) then `exporting = false;`
        # (:106). updatePayload() only positions the live
        # payload entity (`payload.set(x + payVector.x, y +
        # payVector.y, payRotation);`, PayloadBlock.java:176)
        # and the port has no live payload entity, so it is
        # NOT ported (documented in the driver docstring).
        # The clamp is Vec2.clamp(minx, miny, maxx, maxy)
        # (arc Vec2.java:318-322), clamping each axis to
        # +/-size*tilesize/2: size 3 (the only def,
        # payload-loader, Blocks.java:6682-6689) gives +/-12.0;
        # size 4 would give +/-16.0. There is NO
        # large-payload-loader def (the scope's size-4 note was
        # wrong, caught by the RED grep).
        self.assertIn('static func source_payload_loader_handle_payload_state', payload_loader)
        self.assertIn('this.payload = (T)payload;', payload_loader)
        self.assertIn('this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);', payload_loader)
        self.assertIn('this.payRotation = payload.rotation();', payload_loader)
        self.assertIn('super.handlePayload(source, payload);', payload_loader)
        self.assertIn('exporting = false;', payload_loader)
        self.assertIn('public boolean exporting = false;', payload_loader)
        self.assertIn('public @Nullable T payload;', payload_loader)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_loader)
        self.assertIn('public float payRotation;', payload_loader)
        self.assertIn('payload.set(x + payVector.x, y + payVector.y, payRotation);', payload_loader)
        self.assertIn('public static final int tilesize = 8;', payload_loader)
        self.assertIn('default float rotation(){', payload_loader)
        self.assertIn('public class PayloadLoader extends PayloadBlock{', payload_loader)
        self.assertIn('public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{', payload_loader)
        self.assertIn('public class PayloadBlockBuild<T extends Payload> extends Building{', payload_loader)
        self.assertIn('size = 3;', payload_loader)
        # The pure take function ports takePayload
        # (PayloadBlock.java:145-149): `T t = payload;`
        # (:146), `payload = null;` (:147), `return t;`
        # (:148). It is pure + tested only: the unit-pickup
        # live path waits for live units, and the move-out
        # clear is already live through the N2231 advance, so
        # the driver does NOT call it (no double clear).
        self.assertIn('static func source_payload_loader_take_payload_state', payload_loader)
        self.assertIn('public Payload takePayload(){', payload_loader)
        self.assertIn('T t = payload;', payload_loader)
        self.assertIn('payload = null;', payload_loader)
        self.assertIn('return t;', payload_loader)
        self.assertNotIn('source_payload_loader_take_payload_state(', payload_loader.split('static func source_payload_loader_tick_buildings_state', 1)[1])
        # The driver wires the intake into the live tick BEFORE
        # the consumption fold and the advance call: Java
        # handlePayload is an external call (the source's
        # moveOutPayload or a unit drop), so it lands before
        # the next tick starts. The intake reads the frame
        # inputs incoming_payload / incoming_source_pos /
        # world_pos (no live source pushes them yet -- the
        # front handoff and the unit drop wait for their own
        # slices -- and the port has no live world-position
        # model for placed buildings, so both positions arrive
        # as frame inputs); it applies only when the frame
        # payload is null (acceptPayload returns `this.payload
        # == null`, PayloadBlock.java:117) and consumes the
        # one-tick push either way.
        self.assertIn('static func source_payload_loader_tick_buildings_state', payload_loader)
        self.assertIn('frame["incoming_payload"]', payload_loader)
        self.assertIn('incoming_source_pos', payload_loader)
        self.assertIn('world_pos', payload_loader)
        self.assertIn('source_payload_loader_handle_payload_state(', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_SIZE', payload_loader)
        self.assertIn('source_world_defaults.TILESIZE', payload_loader)
        # The documented limits now record the live fill as
        # live; the N2231 advance and N2208 gate text stays.
        self.assertIn('live payload fill live (N2278)', payload_loader)
        self.assertIn('updateTile advance live (N2231)', payload_loader)
        self.assertIn('shouldConsume gate live (N2208)', payload_loader)
        # The proof's keys drive the pure handle (set + vector,
        # the +/-half-size clamp at size 3 and size 4, the
        # rotation read, the exporting clear) and the pure take
        # (returns the held payload and clears), plus the live
        # tick ignoring a push while a payload is held. Static
        # checks: the proof preloads the family state file that
        # exists, and the scene file references the proof script
        # that exists.
        proof = PAYLOAD_LOADER_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'handle_sets_payload_and_vector',
            'handle_clamps_pay_vector_to_half_size',
            'handle_sets_pay_rotation',
            'handle_clears_exporting',
            'handle_ignored_when_payload_present',
            'take_returns_and_clears_payload',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_handle_payload_state(', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_take_payload_state(', proof)
        self.assertTrue(PAYLOAD_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_LOADER_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadLoaderLiveFillProof.gd', scene)
        self.assertIn('C07PayloadLoaderLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_payload_loader_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'handle_sets_payload_and_vector',
            'handle_clamps_pay_vector_to_half_size',
            'handle_sets_pay_rotation',
            'handle_clears_exporting',
            'handle_ignored_when_payload_present',
            'take_returns_and_clears_payload',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
