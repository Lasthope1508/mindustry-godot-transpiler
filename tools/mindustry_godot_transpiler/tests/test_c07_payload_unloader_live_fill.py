import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderLiveFillProof.gd'
PAYLOAD_UNLOADER_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderLiveFillProof.tscn'
PAYLOAD_BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadBlock.java'
PAYLOAD_UNLOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadUnloader.java'
PAYLOAD_LOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadLoader.java'


class C07PayloadUnloaderLiveFillTests(unittest.TestCase):
    def test_c07_payload_unloader_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2279']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_handle_payload_state')
        # N2163 proved the PayloadUnloader family's live power read,
        # N2209 the shouldConsume gate (return payload != null,
        # inherited verbatim from PayloadLoaderBuild, no enabled
        # term) and N2232 the updateTile advance (moveInPayload /
        # moveOutPayload + unload items/liquids + battery unload
        # into lastOutputPower) -- but no live fill ever set the
        # frame payload: a live payload-unloader read payload null
        # and never consumed. N2279 is the live payload fill:
        # handlePayload (PayloadBlock.java:121-127, `this.payload
        # = (T)payload;` + the payVector set/sub/clamp +
        # `this.payRotation = payload.rotation();`) wired live
        # from the frame incoming_payload input before the
        # advance, and takePayload (PayloadBlock.java:145-149,
        # `T t = payload; payload = null; return t;`) ported pure
        # + tested but NOT wired live (the unit-pickup path waits
        # for live units; the move-out clear is already live
        # through the N2232 advance). The Unloader does NOT
        # override handlePayload (grep finds no handlePayload and
        # no exporting flag in PayloadUnloader.java at all) --
        # the exporting = false line lives only in the Loader
        # override (PayloadLoader.java:104-107). Five new result
        # symbols: the handle payload + pay vector + pay rotation,
        # the take payload_taken + payload_after.
        self.assertEqual(
            ledger['N2279']['source_symbols'],
            [
                'source_payload_unloader_handle_payload_state_result.payload',
                'source_payload_unloader_handle_payload_state_result.pay_vector',
                'source_payload_unloader_handle_payload_state_result.pay_rotation',
                'source_payload_unloader_take_payload_state_result.payload_taken',
                'source_payload_unloader_take_payload_state_result.payload_after',
            ],
        )
        owners = {
            'source_payload_unloader_handle_payload_state_result.payload': 'SourcePayloadUnloaderBuildState.source_payload_unloader_handle_payload_state',
            'source_payload_unloader_handle_payload_state_result.pay_vector': 'SourcePayloadUnloaderBuildState.source_payload_unloader_handle_payload_state',
            'source_payload_unloader_handle_payload_state_result.pay_rotation': 'SourcePayloadUnloaderBuildState.source_payload_unloader_handle_payload_state',
            'source_payload_unloader_take_payload_state_result.payload_taken': 'SourcePayloadUnloaderBuildState.source_payload_unloader_take_payload_state',
            'source_payload_unloader_take_payload_state_result.payload_after': 'SourcePayloadUnloaderBuildState.source_payload_unloader_take_payload_state',
        }
        for name in ledger['N2279']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java')
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2279']['runtime_proof'], '/root/C07PayloadUnloaderLiveFillProof')
        self.assertEqual(
            ledger['N2279']['tests'],
            [
                'test_c07_payload_unloader_live_fill_registration',
                'test_all_c07_payload_unloader_live_fill_input_evidence_is_exact',
                'test_payload_unloader_live_fill_state',
                'test_reference_graph_and_actual_c07_payload_unloader_live_fill',
            ],
        )
        self.assertTrue(ledger['N2279']['deferred_exprs'])
        # This slice resolves the live payload fill entry --
        # handlePayload is wired live from the frame
        # incoming_payload input and takePayload is ported pure
        # -- and adds two narrower entries (the takePayload live
        # wiring, which waits for live units, and the live
        # incoming payload source, whose front push / unit drop
        # are not live yet). The accept/handle entry stays
        # verbatim (acceptPayload + acceptItem/acceptLiquid
        # false are a later slice), as do the timer cadence, the
        # dump rows, and the payload entity update entry (which
        # already covers updatePayload()).
        self.assertFalse(any(entry.startswith('PayloadUnloader live payload fill (') for entry in ledger['N2279']['deferred_exprs']))
        for prefix in [
            'PayloadUnloader takePayload live wiring (',
            'PayloadUnloader live incoming payload source (',
            'PayloadUnloader accept/handle payload rows (',
            'PayloadUnloader updateTile timer cadence (',
            'PayloadUnloader dump rows (',
            'PayloadUnloader payload entity update + breakEffect presentation (',
        ]:
            with self.subTest(prefix=prefix):
                self.assertTrue(any(entry.startswith(prefix) for entry in ledger['N2279']['deferred_exprs']))

    def test_all_c07_payload_unloader_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2279']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], (
                    'SourcePayloadUnloaderBuildState.source_payload_unloader_handle_payload_state',
                    'SourcePayloadUnloaderBuildState.source_payload_unloader_take_payload_state',
                ))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/UnitPayload.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        arc_sources = {
            'arc-core/src/arc/math/geom/Vec2.java',
        }
        upstream.update({source: (ROOT / 'arc-upstream' / source).read_text(encoding='utf-8') for source in arc_sources})
        for expr in ledger['N2279']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_live_fill_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The live payload fill (N2279): handlePayload
        # (PayloadBlock.java:121-127) sets the payload, the
        # payVector from source minus self clamped to
        # +/-size*tilesize/2, and the payRotation from
        # payload.rotation(), then updatePayload() (which only
        # positions the live payload entity -- no live payload
        # entity in the port, so it is not ported); takePayload
        # (PayloadBlock.java:145-149) returns the old payload
        # and clears. Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this test).
        # The Unloader does NOT override handlePayload -- the
        # exporting flag lives only on the Loader
        # (PayloadLoader.java:87 `public boolean exporting =
        # false;`, cleared in the Loader override at :104-107),
        # so the handle pure returns no exporting key and the
        # driver carries no exporting frame key. The payVector
        # clamp is the 4-arg Vec2.clamp (Vec2.java:318-322),
        # component-wise, NOT the length clamp: size 3 (the
        # payload-unloader def, Blocks.java:6696) x tilesize 8
        # (Vars.java:135) / 2 = +/-12.0. payload.rotation() is
        # the Payload default 0f (Payload.java:55-57) for a
        # BuildPayload (which does not override it) and
        # unit.rotation for a UnitPayload
        # (UnitPayload.java:94-96), so the pure reads the
        # payload dict rotation with a 0.0 default. The handle
        # applies only when the frame payload is null -- the
        # acceptPayload gate (PayloadBlock.java:116-118, `return
        # this.payload == null;`) -- and the driver consumes
        # the incoming input on apply, before the consumption
        # fold and the advance (handlePayload is an external
        # call, so it lands before the tick).
        self.assertIn('static func source_payload_unloader_handle_payload_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_take_payload_state', payload_unloader)
        self.assertIn('public void handlePayload(Building source, Payload payload){', payload_unloader)
        self.assertIn('this.payload = (T)payload;', payload_unloader)
        self.assertIn('this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);', payload_unloader)
        self.assertIn('this.payRotation = payload.rotation();', payload_unloader)
        self.assertIn('updatePayload();', payload_unloader)
        self.assertIn('public Payload takePayload(){', payload_unloader)
        self.assertIn('T t = payload;', payload_unloader)
        self.assertIn('payload = null;', payload_unloader)
        self.assertIn('return t;', payload_unloader)
        self.assertIn('public @Nullable T payload;', payload_unloader)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_unloader)
        self.assertIn('public float payRotation;', payload_unloader)
        self.assertIn('public boolean acceptPayload(Building source, Payload payload){', payload_unloader)
        self.assertIn('return this.payload == null;', payload_unloader)
        self.assertIn('public void updatePayload(){', payload_unloader)
        self.assertIn('payload.set(x + payVector.x, y + payVector.y, payRotation);', payload_unloader)
        self.assertIn('default float rotation(){', payload_unloader)
        self.assertIn('return 0f;', payload_unloader)
        self.assertIn('public float rotation(){', payload_unloader)
        self.assertIn('return unit.rotation;', payload_unloader)
        self.assertIn('public Vec2 clamp(float minx, float miny, float maxx, float maxy){', payload_unloader)
        self.assertIn('x = Mathf.clamp(x, minx, maxx);', payload_unloader)
        self.assertIn('y = Mathf.clamp(y, miny, maxy);', payload_unloader)
        self.assertIn('public static final int tilesize = 8;', payload_unloader)
        self.assertIn('size = 3;', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('loadPowerDynamic = false;', payload_unloader)
        self.assertIn('public boolean exporting = false;', payload_unloader)
        self.assertIn('super.handlePayload(source, payload);', payload_unloader)
        self.assertIn('exporting = false;', payload_unloader)
        # The driver wires the handle into the live tick: the
        # frame incoming_payload input is applied before the
        # consumption fold and the advance, only when the frame
        # payload is null, and consumed (cleared) on apply.
        # takePayload is NOT wired live -- the pure exists once
        # (its definition) and no call site reads it.
        self.assertIn('source_payload_unloader_handle_payload_state(frame, incoming)', payload_unloader)
        self.assertEqual(payload_unloader.count('source_payload_unloader_handle_payload_state('), 2)
        self.assertEqual(payload_unloader.count('source_payload_unloader_take_payload_state('), 1)
        self.assertIn('frame["incoming_payload"] = null', payload_unloader)
        self.assertIn('"incoming_payload": null', payload_unloader)
        # The fresh frame binds the incoming input at its null
        # default, and the tick preserves a pushed input instead
        # of resetting it.
        self.assertIn('if not frame.has("incoming_payload"):', payload_unloader)
        # No exporting flag anywhere on the Unloader side: the
        # driver carries no exporting frame key, and the Java
        # source has no exporting token at all (grep-verified:
        # PayloadUnloader.java has 0 matches; the flag lives
        # only on PayloadLoaderBuild, PayloadLoader.java:87).
        self.assertNotIn('"exporting"', payload_unloader)
        self.assertNotIn('frame["exporting"]', payload_unloader)
        self.assertNotIn('exporting', PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8'))
        self.assertNotIn('handlePayload', PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8'))
        self.assertIn('exporting', PAYLOAD_LOADER_JAVA.read_text(encoding='utf-8'))
        # The documented limits now record the live fill as done
        # (handlePayload wired live, takePayload pure-only) and
        # the remaining deferrals (the take live wiring, the
        # live incoming source); the shouldConsume gate stays
        # live (N2209) and the N2232 advance is preserved.
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertNotIn('No live payload fill yet', payload_unloader)
        self.assertNotIn('No live fill sets the frame payload yet', payload_unloader)
        self.assertNotIn('no live fill sets it yet', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_power_status_row_state', payload_unloader)
        # The proof's keys drive the pure handle (set + vector +
        # rotation, the +/-12.0 clamp, the rotation default, the
        # ignored-when-present guard), the pure take (returns +
        # clears), the no-exporting-flag check, and the live
        # tick (an incoming push fills the frame payload before
        # the advance, is consumed, and feeds the gate).
        proof = PAYLOAD_UNLOADER_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'handle_sets_payload_and_vector',
            'handle_clamps_pay_vector_to_half_size',
            'handle_sets_pay_rotation',
            'handle_ignored_when_payload_present',
            'take_returns_and_clears_payload',
            'no_exporting_flag_on_unloader',
            'live_tick_fills_payload_from_incoming',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_UNLOADER_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderLiveFillProof.gd', scene)
        self.assertIn('C07PayloadUnloaderLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'handle_sets_payload_and_vector',
            'handle_clamps_pay_vector_to_half_size',
            'handle_sets_pay_rotation',
            'handle_ignored_when_payload_present',
            'take_returns_and_clears_payload',
            'no_exporting_flag_on_unloader',
            'live_tick_fills_payload_from_incoming',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
