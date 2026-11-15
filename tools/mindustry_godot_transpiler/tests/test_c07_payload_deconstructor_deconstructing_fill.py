import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_DECONSTRUCTING_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDeconstructingFillProof.gd'
PAYLOAD_DECONSTRUCTOR_DECONSTRUCTING_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDeconstructingFillProof.tscn'


class C07PayloadDeconstructorDeconstructingFillTests(unittest.TestCase):
    def test_c07_payload_deconstructor_deconstructing_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2291']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state')
        # The payload-deconstructor gate (N2210) reads
        # deconstructing != null and the updateTile advance
        # (N2233) moves a held payload into deconstructing
        # and deconstructs it -- but nothing ever SET the
        # held payload: handlePayload intake waited for its
        # own slice, so a live deconstructor never held a
        # payload at all and the gate never opened. N2291 is
        # the live fill: handlePayload
        # (PayloadBlock.java:121-127, with the Deconstructor
        # override PayloadDeconstructor.java:98-101 clearing
        # accum) sets the payload, clamps payVector to
        # +/-size*tilesize/2 around the source offset, and
        # records payRotation from the payload; the
        # moveInPayload handoff (PayloadDeconstructor.java:
        # 197-202, moveInPayload(false) -- no rotate) is a
        # registered pure of its own. Ten new result
        # symbols: the four handle results plus the six
        # move-in results.
        self.assertEqual(
            ledger['N2291']['source_symbols'],
            [
                'source_payload_deconstructor_handle_payload_state_result.payload',
                'source_payload_deconstructor_handle_payload_state_result.pay_vector',
                'source_payload_deconstructor_handle_payload_state_result.pay_rotation',
                'source_payload_deconstructor_handle_payload_state_result.accum',
                'source_payload_deconstructor_move_in_payload_state_result.arrived',
                'source_payload_deconstructor_move_in_payload_state_result.pay_vector_after',
                'source_payload_deconstructor_move_in_payload_state_result.deconstructing',
                'source_payload_deconstructor_move_in_payload_state_result.payload_after',
                'source_payload_deconstructor_move_in_payload_state_result.progress_after',
                'source_payload_deconstructor_move_in_payload_state_result.accum_after',
            ],
        )
        for name in ledger['N2291']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_deconstructor_handle_payload_state_result.payload': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_handle_payload_state_result.pay_vector': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_handle_payload_state_result.pay_rotation': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_handle_payload_state_result.accum': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_move_in_payload_state_result.arrived': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_move_in_payload_state_result.pay_vector_after': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_deconstructor_move_in_payload_state_result.deconstructing': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_move_in_payload_state_result.payload_after': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_move_in_payload_state_result.progress_after': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'source_payload_deconstructor_move_in_payload_state_result.accum_after': 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_handle_payload_state_result.payload': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_handle_payload_state_result.pay_vector': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_handle_payload_state_result.pay_rotation': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_handle_payload_state_result.accum': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.arrived': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.pay_vector_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.deconstructing': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.payload_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.progress_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.accum_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                }[name])
        self.assertEqual(ledger['N2291']['runtime_proof'], '/root/C07PayloadDeconstructorDeconstructingFillProof')
        self.assertEqual(
            ledger['N2291']['tests'],
            [
                'test_c07_payload_deconstructor_deconstructing_fill_registration',
                'test_all_c07_payload_deconstructor_deconstructing_fill_input_evidence_is_exact',
                'test_payload_deconstructor_deconstructing_fill_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_deconstructing_fill',
            ],
        )
        self.assertTrue(ledger['N2291']['deferred_exprs'])

    def test_all_c07_payload_deconstructor_deconstructing_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2291']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_deconstructor_handle_payload_state_result.payload': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_handle_payload_state_result.pay_vector': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_handle_payload_state_result.pay_rotation': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_handle_payload_state_result.accum': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_handle_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.arrived': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.pay_vector_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.deconstructing': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.payload_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.progress_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                    'source_payload_deconstructor_move_in_payload_state_result.accum_after': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_move_in_payload_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2291']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_deconstructing_fill_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure handle function ports handlePayload
        # (PayloadBlock.java:121-127): `this.payload =
        # (T)payload;` (:122), `this.payVector.set(source).
        # sub(this).clamp(-size * tilesize / 2f, -size *
        # tilesize / 2f, size * tilesize / 2f, size * tilesize
        # / 2f);` (:123), `this.payRotation =
        # payload.rotation();` (:124), `updatePayload();`
        # (:126) -- plus the Deconstructor override
        # (PayloadDeconstructor.java:98-101): `super.
        # handlePayload(source, payload);` (:99) then
        # `accum = null;` (:100). updatePayload() only
        # positions the live payload entity
        # (`payload.set(x + payVector.x, y + payVector.y,
        # payRotation);`, PayloadBlock.java:176) and the port
        # has no live payload entity, so it is NOT ported
        # (documented in the driver docstring). The clamp is
        # Vec2.clamp(minx, miny, maxx, maxy) (arc
        # Vec2.java:318-322), clamping each axis to
        # +/-size*tilesize/2: size 5 (deconstructor,
        # Blocks.java:6654) gives +/-20.0; size 3
        # (small-deconstructor, Blocks.java:6645) gives
        # +/-12.0.
        self.assertIn('static func source_payload_deconstructor_handle_payload_state', payload_deconstructor)
        self.assertIn('this.payload = (T)payload;', payload_deconstructor)
        self.assertIn('this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);', payload_deconstructor)
        self.assertIn('this.payRotation = payload.rotation();', payload_deconstructor)
        self.assertIn('super.handlePayload(source, payload);', payload_deconstructor)
        self.assertIn('accum = null;', payload_deconstructor)
        self.assertIn('public @Nullable float[] accum;', payload_deconstructor)
        self.assertIn('public @Nullable T payload;', payload_deconstructor)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_deconstructor)
        self.assertIn('public float payRotation;', payload_deconstructor)
        self.assertIn('payload.set(x + payVector.x, y + payVector.y, payRotation);', payload_deconstructor)
        self.assertIn('public static final int tilesize = 8;', payload_deconstructor)
        self.assertIn('default float rotation(){', payload_deconstructor)
        self.assertIn('public class PayloadDeconstructor extends PayloadBlock{', payload_deconstructor)
        self.assertIn('public class PayloadDeconstructorBuild extends PayloadBlockBuild<Payload>{', payload_deconstructor)
        self.assertIn('public class PayloadBlockBuild<T extends Payload> extends Building{', payload_deconstructor)
        self.assertIn('size = 5;', payload_deconstructor)
        self.assertIn('size = 3;', payload_deconstructor)
        # The pure move-in function ports the updateTile
        # else-if handoff (PayloadDeconstructor.java:197-202):
        # `}else if(moveInPayload(false) && payload !=
        # null){` (:197), `accum = new float[payload.
        # requirements().length];` (:198), `deconstructing =
        # payload;` (:199), `payload = null;` (:200),
        # `progress = 0f;` (:201). moveInPayload(false)
        # (PayloadBlock.java:186-197): null payload returns
        # false BEFORE any movement (:187); rotate is FALSE
        # so the rotation branch (:191-193) never runs;
        # `payVector.approach(Vec2.ZERO, payloadSpeed *
        # delta());` (:194) moves the offset toward zero at
        # payloadSpeed * delta() -- the SCALED delta
        # (BuildingComp.java:1922-1924, `return Time.delta *
        # timeScale;`), NOT edelta(); `return hasArrived();`
        # (:196) with `return payVector.isZero(0.01f);`
        # (:242-244, Vec2.java:679-681, `return len2() <
        # margin;`) -- the SQUARED length against 0.01.
        self.assertIn('static func source_payload_deconstructor_move_in_payload_state', payload_deconstructor)
        self.assertIn('public boolean moveInPayload(boolean rotate){', payload_deconstructor)
        self.assertIn('if(payload == null) return false;', payload_deconstructor)
        self.assertIn('payVector.approach(Vec2.ZERO, payloadSpeed * delta());', payload_deconstructor)
        self.assertIn('return hasArrived();', payload_deconstructor)
        self.assertIn('return payVector.isZero(0.01f);', payload_deconstructor)
        self.assertIn('return len2() < margin;', payload_deconstructor)
        self.assertIn('}else if(moveInPayload(false) && payload != null){', payload_deconstructor)
        self.assertIn('accum = new float[payload.requirements().length];', payload_deconstructor)
        self.assertIn('deconstructing = payload;', payload_deconstructor)
        self.assertIn('payload = null;', payload_deconstructor)
        self.assertIn('progress = 0f;', payload_deconstructor)
        self.assertIn('public @Nullable Payload deconstructing;', payload_deconstructor)
        self.assertIn('public float progress;', payload_deconstructor)
        self.assertIn('return Time.delta * timeScale;', payload_deconstructor)
        self.assertIn('payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());', payload_deconstructor)
        self.assertIn('payloadSpeed = 1f;', payload_deconstructor)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', payload_deconstructor)
        # The N2233 advance calls the registered move-in
        # pure from its else-if branch (the Java order),
        # converting the frame Vector2 pay_vector to the
        # pure's {x, y} dict at the boundary and back; the
        # pure delegates the approach + arrival core to the
        # N2233 helper, so the math is unchanged.
        self.assertIn('source_payload_deconstructor_move_in_payload_state(payload, pay_dict, accum, progress, delta, SOURCE_PAYLOAD_DECONSTRUCTOR_PAYLOAD_SPEED)', payload_deconstructor)
        self.assertIn('_deconstructor_move_in_payload(Vector2(float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0))), delta, payload_speed)', payload_deconstructor)
        # The driver wires the intake into the live tick
        # BEFORE the consumption fold and the advance call:
        # Java handlePayload is an external call (the
        # source's moveOutPayload or a unit drop), so it
        # lands before the next tick starts. The intake reads
        # the frame inputs incoming_payload /
        # incoming_source_pos / world_pos (no live source
        # pushes them yet -- the front handoff and the unit
        # drop wait for their own slices -- and the port has
        # no live world-position model for placed buildings,
        # so both positions arrive as frame inputs); it
        # applies only when the frame payload is null
        # (acceptPayload returns `this.payload == null`,
        # PayloadBlock.java:117) and consumes the one-tick
        # push either way (the N2278 Loader precedent).
        self.assertIn('static func source_payload_deconstructor_tick_buildings_state', payload_deconstructor)
        self.assertIn('frame["incoming_payload"]', payload_deconstructor)
        self.assertIn('incoming_source_pos', payload_deconstructor)
        self.assertIn('world_pos', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_handle_payload_state(', payload_deconstructor)
        self.assertIn('_deconstructor_size_for_block(block_id)', payload_deconstructor)
        self.assertIn('source_world_defaults.TILESIZE', payload_deconstructor)
        # The documented limits now record the live fill as
        # live; the N2233 advance and N2210 gate text stays,
        # and handlePayload leaves the deferred list (the
        # full acceptPayload gate still waits).
        self.assertIn('Live deconstructing fill live (N2291)', payload_deconstructor)
        self.assertIn('handlePayload live fill is live since N2291', payload_deconstructor)
        self.assertIn('updateTile advance (N2233)', payload_deconstructor)
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        # The proof's keys drive the pure handle (set +
        # vector + the +/-half-size clamp at size 5 and size
        # 3 + the rotation read + the accum clear), the pure
        # move-in (approach at payloadSpeed * delta, the
        # 0.01f squared-length arrival, the handoff on
        # arrival, no handoff before arrival, no handoff
        # without a payload) and the live tick (one tick
        # fills deconstructing from the push). Static checks:
        # the proof preloads the family state file that
        # exists, and the scene file references the proof
        # script that exists.
        proof = PAYLOAD_DECONSTRUCTOR_DECONSTRUCTING_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'handle_sets_payload_and_clears_accum',
            'move_in_approaches_zero',
            'handoff_sets_deconstructing_on_arrival',
            'no_handoff_before_arrival',
            'no_handoff_without_payload',
            'live_tick_fills_deconstructing',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_DECONSTRUCTOR_DECONSTRUCTING_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorDeconstructingFillProof.gd', scene)
        self.assertIn('C07PayloadDeconstructorDeconstructingFillProof', scene)

    def test_reference_graph_and_actual_c07_payload_deconstructor_deconstructing_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorDeconstructingFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_DECONSTRUCTING_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'handle_sets_payload_and_clears_accum',
            'move_in_approaches_zero',
            'handoff_sets_deconstructing_on_arrival',
            'no_handoff_before_arrival',
            'no_handoff_without_payload',
            'live_tick_fills_deconstructing',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
