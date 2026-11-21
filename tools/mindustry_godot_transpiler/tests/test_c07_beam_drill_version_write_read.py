import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_VERSION_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillVersionWriteReadProof.gd'


class C07BeamDrillVersionWriteReadTests(unittest.TestCase):
    def test_c07_beam_drill_version_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2378']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_write_state')
        # BeamDrillBuild.version()
        # (BeamDrill.java:414-416):
        # `public byte version(){`
        # `return 1;`
        # `}`
        # BeamDrillBuild.write()
        # (BeamDrill.java:419-424):
        # `public void write(Writes write){`
        # `super.write(write);`
        # `write.f(time);`
        # `write.f(warmup);`
        # `}`
        # BeamDrillBuild.read()
        # (BeamDrill.java:426-433):
        # `public void read(Reads read, byte revision){`
        # `super.read(read, revision);`
        # `if(revision >= 1){`
        # `time = read.f();`
        # `warmup = read.f();`
        # `}`
        # `}`
        # on `public class BeamDrillBuild extends Building{`
        # (BeamDrill.java:220) inside
        # `public class BeamDrill extends Block{`. The
        # three methods are one persistence record (the N2322
        # TurretBuild / N2286 DrillBuild / N2375
        # ContinuousTurret merged-slice precedent): version()
        # stamps the save revision, write() persists the two
        # own fields time and warmup, read() restores them
        # only at revision >= 1. The name `version` shares
        # text with 8 other-class slices -- registered under
        # this java_method with the class prefix, and
        # `super.write(write);` / `super.read(read, revision);`
        # each EXACT-hit 9 slices -- they are callee/context
        # only, NOT distinguishing exprs (the super layer is
        # DrillBuild.write/read, owned by N2286).
        # `write.f(warmup);` / `warmup = read.f();` EXACT-hit
        # only N2286 (DrillBuild.write/read also persists
        # warmup) -- text-share across class/method, the
        # registry precedent (N632-N639 trùng N1078-N1085);
        # the distinguishing exprs are `write.f(time);` and
        # `time = read.f();`, EXACT 0-hit in both ledgers.
        # Five new result symbols: version, write_time,
        # write_warmup, time, warmup. time is the
        # BeamDrillBuild field (BeamDrill.java:225, `public
        # float time;`); warmup is the BeamDrillBuild field
        # (BeamDrill.java:226, `public float warmup,
        # boostWarmup;`); the save revision 1 is the gate
        # for `if(revision >= 1)`.
        self.assertEqual(
            ledger['N2378']['source_symbols'],
            [
                'source_beam_drill_write_state_result.version',
                'source_beam_drill_write_state_result.write_time',
                'source_beam_drill_write_state_result.write_warmup',
                'source_beam_drill_write_state_result.time',
                'source_beam_drill_write_state_result.warmup',
            ],
        )
        for name in ledger['N2378']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2378']['runtime_proof'], '/root/C07BeamDrillVersionWriteReadProof')
        self.assertEqual(
            ledger['N2378']['tests'],
            [
                'test_c07_beam_drill_version_write_read_registration',
                'test_all_c07_beam_drill_version_write_read_input_evidence_is_exact',
                'test_beam_drill_version_write_read_state',
                'test_reference_graph_and_actual_c07_beam_drill_version_write_read',
            ],
        )
        self.assertTrue(ledger['N2378']['deferred_exprs'])

    def test_all_c07_beam_drill_version_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2378']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2378']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_version_write_read_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrillBuild.version() returns 1
        # (`public byte version(){ return 1; }`,
        # BeamDrill.java:414-416); write() persists the two
        # own fields time and warmup (`write.f(time);` /
        # `write.f(warmup);`, :421-422, inside `public void
        # write(Writes write){` / `super.write(write);`,
        # :419-420); read() restores them only at revision
        # >= 1 (`if(revision >= 1){ time = read.f();
        # warmup = read.f(); }`, :428-431, inside `public
        # void read(Reads read, byte revision){` /
        # `super.read(read, revision);`, :426-427). The super
        # layer is DrillBuild.write/read (N2286), a callee,
        # not re-ported here. The port has no save/load
        # stream, so the values read.f() would return arrive
        # as the explicit stored_time / stored_warmup params
        # (the N2330 param precedent); a revision below 1
        # leaves time and warmup where they already are. NO
        # driver tick line: persistence is not a per-tick
        # call.
        self.assertIn('static func source_beam_drill_version_write_read_state(time: float, warmup: float, revision: int, stored_time: float, stored_warmup: float) -> Dictionary:', state)
        self.assertIn('return {"version": version, "write_time": write_time, "write_warmup": write_warmup, "time": read_time, "warmup": read_warmup}', state)
        for expr in [
            'public class BeamDrill extends Block{',
            'public class BeamDrillBuild extends Building{',
            '@Override',
            'public byte version(){',
            'return 1;',
            'public void write(Writes write){',
            'write.f(time);',
            'write.f(warmup);',
            'public void read(Reads read, byte revision){',
            'if(revision >= 1){',
            'time = read.f();',
            'warmup = read.f();',
            'public float time;',
            'public float warmup, boostWarmup;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): version is
        # always 1 / write persists time and warmup whatever
        # the revision / read restores the stored values at
        # revision 1 and above / read keeps the current values
        # at revision 0 / write then read round-trips /
        # each result carries only its five keys.
        proof = BEAM_DRILL_VERSION_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'version_returns_one',
            'write_persists_time',
            'write_persists_warmup',
            'write_ignores_revision',
            'read_restores_at_revision_one',
            'read_restores_above_revision_one',
            'read_keeps_current_at_revision_zero',
            'write_then_read_round_trips',
            'version_matches_revision_gate',
            'returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_version_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillVersionWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_VERSION_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'version_returns_one',
            'write_persists_time',
            'write_persists_warmup',
            'write_ignores_revision',
            'read_restores_at_revision_one',
            'read_restores_above_revision_one',
            'read_keeps_current_at_revision_zero',
            'write_then_read_round_trips',
            'version_matches_revision_gate',
            'returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
