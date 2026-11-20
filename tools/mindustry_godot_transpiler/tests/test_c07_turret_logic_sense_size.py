import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
LOGIC_SENSE_SIZE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretLogicSenseSizeProof.gd'

LOGIC_SENSE_SIZE_SIGNATURE = 'static func source_logic_sense_size_state(sensor: String, target_kind: String, string_length: float, seq_size: float) -> Dictionary:'
PROOF_KEYS = [
    'size_string_num',
    'buffer_size_seq_num',
    'size_seq_num',
    'buffer_size_string_num',
    'size_other_target_null',
    'other_sensor_string_null',
]


class C07TurretLogicSenseSizeTests(unittest.TestCase):
    def test_c07_turret_logic_sense_size_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2509']['godot_owner'], 'SourceTurretBuildState.source_logic_sense_size_state')
        # SenseI.run() is `public void run(LExecutor exec){ Object
        # target = from.obj(); Object sense = type.obj(); if(target
        # == null && sense == LAccess.dead){ to.setnum(1); return; }
        # if(target instanceof Senseable se){ if(sense instanceof
        # Content co){ to.setnum(se.sense(co)); }else if(sense
        # instanceof LAccess la){ ... } }else{ if(sense ==
        # LAccess.size || sense == LAccess.bufferSize){ if(target
        # instanceof CharSequence seq){ to.setnum(seq.length());
        # return; }else if(target instanceof Seq<?> seq){
        # to.setnum(seq.size); return; } } to.setobj(null); } }`
        # (LExecutor.java:681-718). This slice ports the
        # non-Senseable else-branch (:705-717) for a duo target
        # that is no building at all: a CharSequence logic var
        # reads seq.length(), a Seq<?> logic var reads seq.size,
        # both written with to.setnum and returned early, and any
        # other sensor or target falls through to to.setobj(null).
        # The null-target dead leg (:685-688) is NOT this slice --
        # it was already done in N2507, checked first, before the
        # else-branch. There is NO driver tick line: the legs are
        # logic reads, not tick writes (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508
        # precedent); the proof calls the pure function directly
        # with synthetic inputs. Four new result symbols: handled,
        # output_kind, output_value, is_null. The ported method is
        # SenseI.run() itself, so the java_source is LExecutor.java
        # and the slice lives in the canonical SSOT only (the N2507
        # precedent -- no shard mirrors it); comp stays 560/464,
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2509']['source_symbols'],
            [
                'source_logic_sense_size_state_result.handled',
                'source_logic_sense_size_state_result.output_kind',
                'source_logic_sense_size_state_result.output_value',
                'source_logic_sense_size_state_result.is_null',
            ],
        )
        for name in ledger['N2509']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/logic/LExecutor.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_size_state')
        self.assertEqual(ledger['N2509']['runtime_proof'], '/root/C07TurretLogicSenseSizeProof')
        self.assertEqual(
            ledger['N2509']['tests'],
            [
                'test_c07_turret_logic_sense_size_registration',
                'test_all_c07_turret_logic_sense_size_input_evidence_is_exact',
                'test_turret_logic_sense_size_state',
                'test_reference_graph_and_actual_c07_turret_logic_sense_size',
            ],
        )
        self.assertTrue(ledger['N2509']['deferred_exprs'])

    def test_all_c07_turret_logic_sense_size_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2509']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_size_state')
        slice_sources = {
            'core/src/mindustry/logic/LExecutor.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2509']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_logic_sense_size_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # SenseI.run() non-Senseable else-branch
        # (LExecutor.java:705-717): a size / bufferSize sensor on
        # a CharSequence target writes seq.length() with to.setnum
        # and returns early (:707-709), on a Seq<?> target writes
        # seq.size with to.setnum and returns early (:710-712),
        # and any other sensor or target falls through to
        # to.setobj(null) (:716). The pure function returns
        # handled + output_kind ("num" / "obj") + output_value +
        # is_null. There is no driver tick line: the legs are
        # logic reads, not tick writes.
        self.assertIn(LOGIC_SENSE_SIZE_SIGNATURE, turret)
        for line in [
            'return {"handled": true, "output_kind": "num", "output_value": string_length, "is_null": false}',
            'return {"handled": true, "output_kind": "num", "output_value": seq_size, "is_null": false}',
            'return {"handled": true, "output_kind": "obj", "output_value": null, "is_null": true}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'if(sense == LAccess.size || sense == LAccess.bufferSize){',
            'if(target instanceof CharSequence seq){',
            'to.setnum(seq.length());',
            '}else if(target instanceof Seq<?> seq){',
            'to.setnum(seq.size);',
            'to.setobj(null);',
            'public static class SenseI implements LInstruction{',
            'if(target instanceof Senseable se){',
            '}else{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_logic_sense_content_state, since the else-branch
        # is the last leg of the same SenseI.run() dispatch,
        # and BEFORE source_turret_progress_state.
        self.assertLess(turret.index('static func source_logic_sense_content_state('), turret.index('static func source_logic_sense_size_state('))
        self.assertLess(turret.index('static func source_logic_sense_size_state('), turret.index('static func source_turret_progress_state('))
        # The proof's keys drive the pure function with synthetic
        # inputs (no live tick: the legs are logic reads of the
        # passed-in string length / sequence size): size and
        # bufferSize both read a string length and a sequence
        # size, a size sensor on a non-string non-sequence target
        # falls through to obj null, and a non-size sensor falls
        # through to obj null even for a string target.
        proof = LOGIC_SENSE_SIZE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_logic_sense_size(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretLogicSenseSizeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_LOGIC_SENSE_SIZE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
