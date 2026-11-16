import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorSenseRowsProof.gd'
PAYLOAD_DECONSTRUCTOR_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorSenseRowsProof.tscn'
SENSE_OWNERS = {
    'source_payload_deconstructor_sense_state_result.value': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_sense_state',
    'source_payload_deconstructor_sense_state_result.is_progress': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_sense_state',
    'source_payload_deconstructor_sense_content_state_result.value': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_sense_content_state',
    'source_payload_deconstructor_sense_content_state_result.is_unit_payload': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_sense_content_state',
}


class C07PayloadDeconstructorSenseRowsTests(unittest.TestCase):
    def test_c07_payload_deconstructor_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2387']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_sense_state')
        # The PayloadDeconstructor tick is live (N2166 power
        # row + N2210 shouldConsume gate + N2233 updateTile
        # advance + N2276 dump + N2291 handlePayload fill +
        # N2297 accept gates + N2308 intake gate + N2368
        # dump write-back) but NOTHING modeled sense():
        # sense(Content) returns 1 when the deconstructing
        # payload's unit type / block matches the queried
        # content, 0 otherwise, and super.sense(content)
        # when nothing is deconstructing
        # (PayloadDeconstructor.java:206-210); sense(LAccess
        # .progress) returns the frame progress AS-IS -- NO
        # clamp, unlike the MendProjector clamp
        # (PayloadDeconstructor.java:213-216). N2387 ports
        # sense() as TWO pures -- one per Java overload,
        # because the signatures differ (Content vs LAccess):
        # source_payload_deconstructor_sense_state (the
        # LAccess dispatch: progress returns the frame
        # progress untouched, any other sensor returns the
        # caller-supplied super_value -- the super.sense
        # result computed through the already-modeled
        # SourceBuildingSenseState pures, NOT re-modeled
        # here -- and a null super_value is the super
        # switch's default branch (`default -> Float.NaN;
        # //gets converted to null in logic`,
        # BuildingComp.java:2121)) and source_payload_
        # deconstructor_sense_content_state (the Content
        # dispatch: the deconstructing descriptor's kind
        # key -- "unit" / "build", the N2233 contract --
        # runs the instanceof dispatch, and the caller-
        # supplied payload_content_id (the unit type id /
        # block id, an explicit input -- the descriptor
        # carries NO identity key, so the equality operand
        # cannot come from the frame) is compared against
        # the queried content id; a null deconstructing
        # falls through to the caller-supplied super_value,
        # the super.sense(content) result). Pure-only, like
        # the N2383 sense pures: the tick never calls sense
        # (grep finds only comment defers in the driver) --
        # sense is called by logic (the processor), not the
        # tick, and the logic call site waits for a logic-
        # executor slice. Four new result symbols: the
        # sensed value + the progress dispatch flag, and
        # the content value + the unit-payload dispatch
        # flag.
        self.assertEqual(
            ledger['N2387']['source_symbols'],
            [
                'source_payload_deconstructor_sense_state_result.value',
                'source_payload_deconstructor_sense_state_result.is_progress',
                'source_payload_deconstructor_sense_content_state_result.value',
                'source_payload_deconstructor_sense_content_state_result.is_unit_payload',
            ],
        )
        owners = SENSE_OWNERS
        for name in ledger['N2387']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java')
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2387']['runtime_proof'], '/root/C07PayloadDeconstructorSenseRowsProof')
        self.assertEqual(
            ledger['N2387']['tests'],
            [
                'test_c07_payload_deconstructor_sense_rows_registration',
                'test_all_c07_payload_deconstructor_sense_rows_input_evidence_is_exact',
                'test_payload_deconstructor_sense_rows_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2387']['deferred_exprs'])
        # This slice RESOLVES the PayloadDeconstructor sense
        # rows (#6 in the merged advances-20 DEFERRED base):
        # the entry is REMOVED (resolve by text). No new
        # entry is added: the sense pures are pure-only (no
        # tick wiring to defer), the super.sense delegation
        # rides the already-modeled SourceBuildingSenseState
        # pures, the payload-identity input waits on the
        # payload-contract slice (not a Deconstructor
        # deferral of its own), and the logic call site is
        # a port-wide logic-executor concern, not a
        # Deconstructor deferral. Net 306 - 1 = 305.
        self.assertFalse(any(entry.startswith('PayloadDeconstructor sense rows (') for entry in ledger['N2387']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor draw / icons rows (') for entry in ledger['N2387']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor setBars row (') for entry in ledger['N2387']['deferred_exprs']))
        self.assertEqual(len(ledger['N2387']['deferred_exprs']), 305)

    def test_all_c07_payload_deconstructor_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2387']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], SENSE_OWNERS[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2387']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_sense_rows_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The sense rows (PayloadDeconstructorBuild.sense(),
        # PayloadDeconstructor.java:206-216): `public double
        # sense(Content content){` + `if(deconstructing
        # instanceof UnitPayload up) return up.unit.type ==
        # content ? 1 : 0;` + `if(deconstructing instanceof
        # BuildPayload bp) return bp.build.block == content
        # ? 1 : 0;` + `return super.sense(content);`, and
        # `public double sense(LAccess sensor){` +
        # `if(sensor == LAccess.progress) return progress;`
        # + `return super.sense(sensor);`. progress is the
        # frame value the N2233 advance tracks (`public
        # float progress;`, :54) and Java returns it AS-IS
        # -- NO clamp (unlike the MendProjector clamp).
        # The deconstructing descriptor format (VERIFIED,
        # the N2233 payload dict contract, decision 8):
        # kind ("build" / "unit"), requirements (ItemStack
        # list), build_time -- kind runs the instanceof
        # dispatch (UnitPayload vs BuildPayload), but the
        # descriptor carries NO identity key: neither the
        # unit type nor the block is in the frame, so the
        # equality operand (up.unit.type / bp.build.block)
        # arrives as the caller-supplied payload_content_id
        # explicit input (the N2383 reload_value /
        # super_value precedent) -- NO descriptor key is
        # invented here. super.sense is the BuildingComp
        # switch (BuildingComp.java:2093-2122, `return
        # switch(sensor){`) for LAccess and the content
        # switch (BuildingComp.java:2139-2147, `public
        # double sense(Content content){` + `if(content
        # instanceof Item i && items != null) return
        # items.get(i);` + `return Float.NaN; //invalid
        # sense`) for Content. The port already models both
        # (SourceBuildingSenseState -- sense_position_state,
        # sense_health_process_state, sense_totals_state,
        # sense_capacity_power_net_state, sense_enabled_
        # controlled_state, sense_payload_size_state,
        # sense_camera_default_state, sense_content_state),
        # so both pures take the caller's super.sense result
        # as super_value instead of re-modeling them; null
        # is the default branch. Pure-only: the tick never
        # calls sense (verified: grep finds only comment
        # defers in the driver) -- sense is called by logic,
        # and the logic call site waits for a logic-executor
        # slice.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_payload_deconstructor_sense_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_sense_content_state', payload_deconstructor)
        self.assertIn('public double sense(Content content){', payload_deconstructor)
        self.assertIn('if(deconstructing instanceof UnitPayload up) return up.unit.type == content ? 1 : 0;', payload_deconstructor)
        self.assertIn('if(deconstructing instanceof BuildPayload bp) return bp.build.block == content ? 1 : 0;', payload_deconstructor)
        self.assertIn('return super.sense(content);', payload_deconstructor)
        self.assertIn('public double sense(LAccess sensor){', payload_deconstructor)
        self.assertIn('if(sensor == LAccess.progress) return progress;', payload_deconstructor)
        self.assertIn('return super.sense(sensor);', payload_deconstructor)
        self.assertIn('public @Nullable Payload deconstructing;', payload_deconstructor)
        self.assertIn('public float progress;', payload_deconstructor)
        self.assertIn('return switch(sensor){', payload_deconstructor)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', payload_deconstructor)
        self.assertIn('case health -> health;', payload_deconstructor)
        self.assertIn('case efficiency -> efficiency;', payload_deconstructor)
        self.assertIn('if(content instanceof Item i && items != null) return items.get(i);', payload_deconstructor)
        self.assertIn('return Float.NaN; //invalid sense', payload_deconstructor)
        # The documented limits record the sense rows as
        # live (the old "No sense / draw / icons" deferral
        # text is gone; the draw / icons / setBars /
        # read-write rows still defer).
        self.assertIn('Sense rows live (N2387)', payload_deconstructor)
        self.assertNotIn('No sense / draw / icons / setBars / read-write rows', payload_deconstructor)
        # The proof's keys drive the sense pures (the
        # progress 0.0 / 0.5 as-is cases -- including a
        # progress past 1.0 staying unclamped -- the
        # super.sense delegation for a known sensor and
        # the null default for an unknown sensor / a null
        # deconstructing payload, the content unit match /
        # build match cases, plus the live frame progress
        # + deconstructing feeding both pures).
        proof = PAYLOAD_DECONSTRUCTOR_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_zero',
            'sense_progress_partial',
            'sense_super_sensor',
            'sense_super_default',
            'sense_content_unit_match',
            'sense_content_build_match',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file and the
        # super.sense state file (the N2185 lesson: check
        # the preload targets exist, and the scene file
        # exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07PayloadDeconstructorSenseRowsProof.gd', PAYLOAD_DECONSTRUCTOR_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_payload_deconstructor_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_zero',
            'sense_progress_partial',
            'sense_super_sensor',
            'sense_super_default',
            'sense_content_unit_match',
            'sense_content_build_match',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
