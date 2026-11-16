import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_READ_WRITE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretReadWriteProof.gd'


class C07RepairTurretReadWriteTests(unittest.TestCase):
    def test_c07_repair_turret_read_write_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2217']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_write_state')
        # N2212-N2215 made the repair turret live (target acquire,
        # heal advance, rotation slerp, strength lerp) -- but none
        # of that state survived a save/load: RepairPointBuild
        # persists exactly ONE field, its rotation (`write.f(
        # rotation);`, RepairTurret.java:239, inside `public void
        # write(Writes write){` / `super.write(write);`,
        # RepairTurret.java:236-238), and restores it only for
        # saves written at revision >= 1 (`if(revision >= 1){` /
        # `rotation = read.f();`, RepairTurret.java:246-248, inside
        # `public void read(Reads read, byte revision){` /
        # `super.read(read, revision);`, RepairTurret.java:243-245),
        # because `public byte version(){` returns 1
        # (RepairTurret.java:252-254). Strength is NOT persisted:
        # it is re-lerped every tick (`strength =
        # Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f *
        # Time.delta);`, RepairTurret.java:212), so a loaded
        # turret rebuilds it from 0. Target is NOT persisted
        # either: it is re-acquired by the 20-tick timer (`target
        # = Units.closest(team, x, y, repairRadius,
        # Unit::damaged);`, RepairTurret.java:216). RED decisions
        # (resolved at RED, recorded in the register docstring):
        # (1) Two pure functions on the same family file N2174 /
        # N2188 / N2209 / N2212-N2215 built, plus one save-version
        # const -- write returns {"rotation"} only, read returns
        # {"rotation"} (saved value when revision >= 1, the
        # frame's current rotation otherwise). (2) The version is
        # a const, not a function: Java version() takes no
        # parameters, and the SSOT schema validator requires every
        # schema entry to carry non-empty keys, so a zero-input
        # function could not be registered -- the const
        # REPAIR_TURRET_SAVE_VERSION pins the `return 1;` fact.
        # (3) NO driver tick line: persistence is not a per-tick
        # call, and the port has no save/load stream to call
        # these functions yet -- wiring them into a save/load path
        # waits for a persistence-integration slice (deferred).
        # (4) The rotation default is 90.0, the field default
        # (`public float strength, rotation = 90;`,
        # RepairTurret.java:156). (5) Both defs share
        # RepairPointBuild (repair-point, powerUse 1f,
        # Blocks.java:6391; repair-turret, powerUse 5f,
        # Blocks.java:6402), so one set of functions covers both.
        # (6) drawBeam is rendering only, not persistence -- it
        # waits for its own slice (deferred). Two new result
        # symbols: write.rotation, read.rotation.
        self.assertEqual(
            ledger['N2217']['source_symbols'],
            [
                'source_repair_turret_write_state_result.rotation',
                'source_repair_turret_read_state_result.rotation',
            ],
        )
        for name in ledger['N2217']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2217']['runtime_proof'], '/root/C07RepairTurretReadWriteProof')
        self.assertEqual(
            ledger['N2217']['tests'],
            [
                'test_c07_repair_turret_read_write_registration',
                'test_all_c07_repair_turret_read_write_input_evidence_is_exact',
                'test_repair_turret_read_write_state',
                'test_reference_graph_and_actual_c07_repair_turret_read_write',
            ],
        )
        self.assertTrue(ledger['N2217']['deferred_exprs'])

    def test_all_c07_repair_turret_read_write_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2217']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2217']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_read_write_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairPointBuild persists exactly ONE field, its
        # rotation: `public void write(Writes write){` /
        # `super.write(write);` / `write.f(rotation);`
        # (RepairTurret.java:236-239), and restores it only for
        # saves at revision >= 1: `public void read(Reads read,
        # byte revision){` / `super.read(read, revision);` /
        # `if(revision >= 1){` / `rotation = read.f();`
        # (RepairTurret.java:243-248), because `public byte
        # version(){` returns 1 (RepairTurret.java:252-254). The
        # rotation default is 90.0 (`public float strength,
        # rotation = 90;`, RepairTurret.java:156). Strength is NOT
        # persisted -- it is re-lerped every tick (`strength =
        # Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f *
        # Time.delta);`, RepairTurret.java:212) -- and target is
        # NOT persisted either -- it is re-acquired by the 20-tick
        # timer (`target = Units.closest(team, x, y,
        # repairRadius, Unit::damaged);`,
        # RepairTurret.java:216). The write function returns ONLY
        # rotation (the proof checks the result has exactly one
        # key); the read function returns the saved rotation when
        # revision >= 1 and the frame's current rotation (default
        # 90.0) otherwise, so a revision-0 save leaves the turret
        # pointing where it already points. There is NO driver
        # tick line: persistence is not a per-tick call, and the
        # port has no save/load stream to call these functions yet.
        self.assertIn('static func source_repair_turret_write_state(frame: Dictionary) -> Dictionary:', repair_turret)
        self.assertIn('var rotation: float = float(frame.get("rotation", 90.0))', repair_turret)
        self.assertIn('return {"rotation": rotation}', repair_turret)
        self.assertIn('static func source_repair_turret_read_state(frame: Dictionary, saved_rotation: float, revision: int) -> Dictionary:', repair_turret)
        self.assertIn('if revision >= 1:', repair_turret)
        self.assertIn('rotation = saved_rotation', repair_turret)
        self.assertIn('const REPAIR_TURRET_SAVE_VERSION := 1', repair_turret)
        for expr in [
            'public void write(Writes write){',
            'super.write(write);',
            'write.f(rotation);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'if(revision >= 1){',
            'rotation = read.f();',
            'public byte version(){',
            'return 1;',
            'public float strength, rotation = 90;',
            'strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);',
            'target = Units.closest(team, x, y, repairRadius, Unit::damaged);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure functions with synthetic
        # frames (no live tick, no save file: the persisted value
        # is one float): write returns the current rotation / write
        # defaults to 90 when the frame carries no rotation / write
        # returns only rotation / read restores the saved rotation
        # at revision 1 / read restores it at revision 2 / read
        # keeps the current rotation at revision 0 / read defaults
        # to 90 when the frame has no rotation and revision is 0 /
        # the save version is 1. There are no drawBeam / live-tick
        # keys: the beam is rendering, the tick is N2212-N2215.
        proof = REPAIR_TURRET_READ_WRITE_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_returns_current_rotation',
            'write_defaults_to_90_when_absent',
            'write_returns_only_rotation',
            'read_restores_saved_rotation_at_revision_1',
            'read_restores_saved_rotation_at_revision_2',
            'read_keeps_current_rotation_at_revision_0',
            'read_defaults_to_90_when_absent_and_revision_0',
            'version_is_1',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_read_write(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretReadWriteProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_READ_WRITE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_returns_current_rotation',
            'write_defaults_to_90_when_absent',
            'write_returns_only_rotation',
            'read_restores_saved_rotation_at_revision_1',
            'read_restores_saved_rotation_at_revision_2',
            'read_keeps_current_rotation_at_revision_0',
            'read_defaults_to_90_when_absent_and_revision_0',
            'version_is_1',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
