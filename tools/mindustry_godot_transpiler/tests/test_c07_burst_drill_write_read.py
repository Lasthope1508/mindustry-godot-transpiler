import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillWriteReadProof.gd'


class C07BurstDrillWriteReadTests(unittest.TestCase):
    def test_c07_burst_drill_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2286']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_write_state')
        # DrillBuild persists exactly TWO fields, its drill
        # progress and its warmup (`write.f(progress);` /
        # `write.f(warmup);`, Drill.java:386-387, inside
        # `public void write(Writes write){` /
        # `super.write(write);`, Drill.java:384-385), and
        # restores them only for saves at revision >= 1
        # (`if(revision >= 1){ progress = read.f();
        # warmup = read.f(); }`, Drill.java:391-394, inside
        # `public void read(Reads read, byte revision){` /
        # `super.read(read, revision);`, Drill.java:389-390).
        # version() returns 1 (`public byte version(){ return
        # 1; }`, Drill.java:380-382); the BuildingComp base
        # returns 0 (BuildingComp.java:669-671). RED decisions
        # (resolved at RED, recorded in the register
        # docstring): (1) Three pure functions -- write reads
        # both values from the frame (the N2217 RepairTurret
        # precedent: write takes the frame only), read takes
        # the two stored values + revision and applies them
        # only at revision >= 1, version returns the constant
        # 1. (2) The frame keys are the DrillBuild float
        # fields (`public float progress;` /
        # `public float warmup;`, Drill.java:238-239),
        # already tracked frame keys advanced by updateTile
        # (N2294). (3) Defaults are the Java field defaults:
        # progress 0.0 and warmup 0.0 (plain float fields, no
        # explicit init). (4) super.write/read are empty
        # BuildingComp bodies ("overriden by subclasses!") --
        # only the marker is recorded. (5) DrillBuild has NO
        # readSync override, so there is no readSync
        # follow-up slice (contrast N2276 Turret). (6) NO
        # driver tick line: persistence is not a per-tick
        # call, and the port has no save/load stream to call
        # these functions yet. (7) Java write.f is a 32-bit
        # float while GDScript float is 64-bit -- the pure
        # functions add NO rounding epsilon; the proof
        # round-trips float32-safe values exactly and checks
        # the inexact value 0.1 with is_equal_approx. Five
        # new result symbols: write.progress, write.warmup,
        # read.progress, read.warmup, version.version.
        self.assertEqual(
            ledger['N2286']['source_symbols'],
            [
                'source_drill_write_state_result.progress',
                'source_drill_write_state_result.warmup',
                'source_drill_read_state_result.progress',
                'source_drill_read_state_result.warmup',
                'source_drill_version_state_result.version',
            ],
        )
        for name in ledger['N2286']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2286']['runtime_proof'], '/root/C07BurstDrillWriteReadProof')
        self.assertEqual(
            ledger['N2286']['tests'],
            [
                'test_c07_burst_drill_write_read_registration',
                'test_all_c07_burst_drill_write_read_input_evidence_is_exact',
                'test_burst_drill_write_read_state',
                'test_reference_graph_and_actual_c07_burst_drill_write_read',
            ],
        )
        self.assertTrue(ledger['N2286']['deferred_exprs'])

    def test_all_c07_burst_drill_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2286']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2286']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_write_read_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild persists exactly TWO fields, its drill
        # progress and its warmup: `public void write(
        # Writes write){` / `super.write(write);` /
        # `write.f(progress);` / `write.f(warmup);`
        # (Drill.java:384-387), and restores them only at
        # revision >= 1: `public void read(Reads read, byte
        # revision){` / `super.read(read, revision);` /
        # `if(revision >= 1){` / `progress = read.f();`
        # / `warmup = read.f();` (Drill.java:389-394).
        # version() returns 1: `public byte version(){` /
        # `return 1;` (Drill.java:380-382). The persisted
        # fields are the DrillBuild float fields
        # (`public float progress;` /
        # `public float warmup;`, Drill.java:238-239),
        # already tracked frame keys. super.write/read are
        # empty BuildingComp bodies. DrillBuild has NO
        # readSync override. There is NO driver tick line:
        # persistence is not a per-tick call, and the port
        # has no save/load stream to call these functions yet.
        self.assertIn('static func source_drill_write_state(frame: Dictionary) -> Dictionary:', burst_drill)
        self.assertIn('return {"progress": float(frame.get("progress", 0.0)), "warmup": float(frame.get("warmup", 0.0))}', burst_drill)
        self.assertIn('static func source_drill_read_state(frame: Dictionary, stored_progress: float, stored_warmup: float, revision: int) -> Dictionary:', burst_drill)
        self.assertIn('if revision >= 1:', burst_drill)
        self.assertIn('progress = stored_progress', burst_drill)
        self.assertIn('warmup = stored_warmup', burst_drill)
        self.assertIn('return {"progress": progress, "warmup": warmup}', burst_drill)
        self.assertIn('static func source_drill_version_state(frame: Dictionary) -> Dictionary:', burst_drill)
        self.assertIn('return {"version": 1}', burst_drill)
        for expr in [
            'public void write(Writes write){',
            'super.write(write);',
            'write.f(progress);',
            'write.f(warmup);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'if(revision >= 1){',
            'progress = read.f();',
            'warmup = read.f();',
            'public byte version(){',
            'return 1;',
            'public float progress;',
            'public float warmup;',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick, no save file: the
        # persisted values are two floats): write 0.0/0.0
        # (the Java field defaults) / write 12.5/0.75
        # round-trips through read at revision 1 / write
        # returns only the two keys / read returns only the
        # two keys / read at revision 0 keeps the frame's
        # current values and ignores the stored values / read
        # at revision 1 applies the stored values / version
        # returns 1 / the inexact float32 value 0.1
        # round-trips within float32 tolerance.
        proof = BURST_DRILL_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_defaults_zero',
            'write_round_trips',
            'write_returns_only_two_keys',
            'read_returns_only_two_keys',
            'read_ignores_old_revision',
            'read_applies_at_revision_one',
            'version_returns_one',
            'round_trip_inexact_float32_value',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_defaults_zero',
            'write_round_trips',
            'write_returns_only_two_keys',
            'read_returns_only_two_keys',
            'read_ignores_old_revision',
            'read_applies_at_revision_one',
            'version_returns_one',
            'round_trip_inexact_float32_value',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
