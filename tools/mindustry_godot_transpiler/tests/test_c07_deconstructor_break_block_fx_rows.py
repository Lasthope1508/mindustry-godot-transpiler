import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
DECONSTRUCTOR_BREAK_BLOCK_FX_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DeconstructorBreakBlockFxProof.gd'
DECONSTRUCTOR_BREAK_BLOCK_FX_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DeconstructorBreakBlockFxProof.tscn'


class C07DeconstructorBreakBlockFxRowsTests(unittest.TestCase):
    def test_c07_deconstructor_break_block_fx_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2480']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_break_block_fx_state')
        # The PayloadDeconstructor updateTile STATE is live
        # (N2233 advance): the deconstruct branch + the
        # finish branch clear deconstructing / accum on
        # finish -- but SILENTLY (pure result only): the
        # Fx.breakBlock finish effect (:191) was never
        # modeled. N2480 ports it as ONE pure-only pure
        # (the N2469 precedent, NO tick wiring):
        # source_payload_deconstructor_break_block_fx_
        # state(finish, deconstructing_size, x, y)
        # returns break_block_call {effect
        # "Fx.breakBlock", x, y, scale:
        # deconstructing_size / 8.0} when finish is
        # true, null otherwise. NO effect is spawned
        # -- the audio/effect call site waits for its
        # own slice. The finish flag is the caller-
        # evaluated N2233 finished verdict (the
        # advance exposes it as a return key) and the
        # size is the caller-supplied Payload.size()
        # in pixels (BuildPayload: block.size * 8,
        # UnitPayload: hitSize), captured BEFORE the
        # advance clears deconstructing -- the N2233
        # deconstructing descriptor (kind /
        # requirements / build_time) carries no size
        # key. The divisor is the JAVA tilesize 8.0
        # (Vars.java:135), NOT the game tile_size 32
        # (the N2364 lesson). One new result symbol.
        self.assertEqual(
            ledger['N2480']['source_symbols'],
            [
                'source_payload_deconstructor_break_block_fx_state_result.break_block_call',
            ],
        )
        expected_owners = {
            'source_payload_deconstructor_break_block_fx_state_result.break_block_call': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_break_block_fx_state',
        }
        for name in ledger['N2480']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2480']['runtime_proof'], '/root/C07DeconstructorBreakBlockFxProof')
        self.assertEqual(
            ledger['N2480']['tests'],
            [
                'test_c07_deconstructor_break_block_fx_rows_registration',
                'test_all_c07_deconstructor_break_block_fx_rows_input_evidence_is_exact',
                'test_deconstructor_break_block_fx_rows_state',
                'test_reference_graph_and_actual_c07_deconstructor_break_block_fx_rows',
            ],
        )
        self.assertTrue(ledger['N2480']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #95 (1-based in
        # DEFERRED-after-advances-32.py): the
        # PayloadDeconstructor Fx.breakBlock finish
        # effect entry is REMOVED -- the effect is
        # live now as a pure call record, so nothing
        # of the entry remains. Net 234 - 1 = 233.
        # (The puddles liquid dump entry still stands:
        # the port has no Puddles / floor-liquid
        # model, and it is NOT in this slice's scope.)
        self.assertFalse(any(entry.startswith('PayloadDeconstructor Fx.breakBlock finish effect (') for entry in ledger['N2480']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor puddles liquid dump (') for entry in ledger['N2480']['deferred_exprs']))
        self.assertEqual(len(ledger['N2480']['deferred_exprs']), 233)

    def test_all_c07_deconstructor_break_block_fx_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2480']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadDeconstructorBuildState.source_payload_deconstructor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/blocks/payloads/UnitPayload.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Fx.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2480']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_deconstructor_break_block_fx_rows_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The breakBlock finish effect row
        # (PayloadDeconstructorBuild.updateTile(),
        # PayloadDeconstructor.java:179-195): the
        # STATE is live since N2233 (the deconstruct
        # branch + the finish branch clearing
        # deconstructing / accum), so this pure
        # consumes the caller-evaluated finish gate
        # (the N2233 finished verdict) and reports
        # the breakBlock effect as a pure call record
        # (the N2469 precedent -- no effect spawned):
        # `if(progress >= 1f){` + `if(canProgress){`
        # + `Fx.breakBlock.at(x, y, deconstructing.
        # size() / tilesize);` + `deconstructing =
        # null;` + `accum = null;`. Payload.size()
        # is the hitbox size in pixels (`float
        # size();`, Payload.java:27): a BuildPayload
        # is `return build.block.size * tilesize;`
        # (BuildPayload.java:86-88), a UnitPayload is
        # `return unit.hitSize;` (UnitPayload.java:
        # 99-101) -- so size() / tilesize is the
        # block size in tiles for a build payload and
        # hitSize / 8 for a unit payload. The
        # divisor is the JAVA tilesize (`public static
        # final int tilesize = 8;`, Vars.java:135),
        # NOT the game tile_size 32 (the N2364
        # lesson). The effect is Fx.breakBlock
        # (`breakBlock = new Effect(12, e -> {`,
        # Fx.java:285), and its renderer reads the
        # third .at arg (e.rotation) as the size
        # scale (`Lines.square(e.x, e.y, tilesize /
        # 2f * e.rotation + e.fin() * 3f);`,
        # Fx.java:288) -- so the record carries the
        # value under the "scale" key. The N2233
        # deconstructing descriptor (kind /
        # requirements / build_time) carries no size
        # key, so the size is a caller-supplied
        # float input, captured BEFORE the advance
        # clears deconstructing. Keep each Java expr
        # on ONE comment line (the N2148 lesson: a
        # split line fails this test).
        self.assertIn('static func source_payload_deconstructor_break_block_fx_state', payload_deconstructor)
        self.assertIn('if(progress >= 1f){', payload_deconstructor)
        self.assertIn('if(canProgress){', payload_deconstructor)
        self.assertIn('Fx.breakBlock.at(x, y, deconstructing.size() / tilesize);', payload_deconstructor)
        self.assertIn('deconstructing = null;', payload_deconstructor)
        self.assertIn('accum = null;', payload_deconstructor)
        self.assertIn('float size();', payload_deconstructor)
        self.assertIn('return build.block.size * tilesize;', payload_deconstructor)
        self.assertIn('return unit.hitSize;', payload_deconstructor)
        self.assertIn('public static final int tilesize = 8;', payload_deconstructor)
        self.assertIn('breakBlock = new Effect(12, e -> {', payload_deconstructor)
        self.assertIn('Lines.square(e.x, e.y, tilesize / 2f * e.rotation + e.fin() * 3f);', payload_deconstructor)
        # The documented limits record the break-block
        # FX row as live.
        self.assertIn('Break-block FX row live (N2480)', payload_deconstructor)
        # The proof's keys drive the break-block pure
        # (the finish gate + the null case + the
        # size-1 / size-2 scales + the tilesize-8
        # divisor + the live N2233 finished verdict).
        proof = DECONSTRUCTOR_BREAK_BLOCK_FX_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'fx_on_finish',
            'fx_null_when_not_finished',
            'fx_scale_size_1',
            'fx_scale_size_2',
            'fx_tilesize_8',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.exists())
        self.assertTrue(DECONSTRUCTOR_BREAK_BLOCK_FX_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07DeconstructorBreakBlockFxProof.gd', DECONSTRUCTOR_BREAK_BLOCK_FX_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_deconstructor_break_block_fx_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DeconstructorBreakBlockFxProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DECONSTRUCTOR_BREAK_BLOCK_FX_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fx_on_finish',
            'fx_null_when_not_finished',
            'fx_scale_size_1',
            'fx_scale_size_2',
            'fx_tilesize_8',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
