import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretWriteReadProof.gd'


class C07PointDefenseTurretWriteReadTests(unittest.TestCase):
    def test_c07_point_defense_turret_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2245']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_write_state')
        # N2240-N2244 made the point-defense turret live (aim +
        # shoot, shouldConsume, live bullets, team stamp, draw)
        # -- but none of that state survived a save/load:
        # PointDefenseBuild persists exactly ONE field, its
        # rotation (`write.f(rotation);`,
        # PointDefenseTurret.java:121, inside `public void
        # write(Writes write){` / `super.write(write);`,
        # PointDefenseTurret.java:117-119), and restores it
        # UNCONDITIONALLY (`rotation = read.f();`,
        # PointDefenseTurret.java:127, inside `public void
        # read(Reads read, byte revision){` / `super.read(read,
        # revision);`, PointDefenseTurret.java:124-126) -- there
        # is NO `if(revision >= 1){` guard here, unlike
        # RepairTurret.read() (RepairTurret.java:246-248, the
        # N2217 precedent). PointDefenseTurret does NOT override
        # version(), so the save version is the BuildingComp
        # default 0 (`public byte version(){` / `return 0;`,
        # BuildingComp.java:669-671) -- the read ignores the
        # revision it is handed either way. Target is NOT
        # persisted: it is re-acquired by the retarget timer
        # (`if(timer(timerTarget, retargetTime)){` /
        # `target = Groups.bullet.intersect(x - range, y -
        # range, range*2, range*2).min(b -> b.team != team &&
        # b.type().hittable, b -> b.dst2(this));`,
        # PointDefenseTurret.java:65-67). reloadCounter is NOT
        # persisted either: it is recharged every tick
        # (`public float reloadCounter;`,
        # ReloadTurret.java:26; `reloadCounter += edelta();`,
        # PointDefenseTurret.java:79). RED decisions (resolved
        # at RED, recorded in the register docstring): (1) Two
        # pure functions on the same family file N2240-N2244
        # built, plus one save-version const -- write returns
        # {"rotation"} only, read returns {"rotation"} (the
        # saved value, unconditionally -- NO revision parameter,
        # because the Java body never reads `revision`, and NO
        # frame parameter either, because the result never
        # falls back to the frame: unlike N2217's read, there
        # is no revision-0 branch to keep the current
        # rotation). (2) The
        # version is a const, not a function: Java version()
        # takes no parameters, and the SSOT schema validator
        # requires every schema entry to carry non-empty keys,
        # so a zero-input function could not be registered --
        # the const POINT_DEFENSE_TURRET_SAVE_VERSION pins the
        # `return 0;` default. (3) NO driver tick line:
        # persistence is not a per-tick call, and the port has
        # no save/load stream to call these functions yet --
        # wiring them into a save/load path waits for a
        # persistence-integration slice (deferred) -- the N2217
        # precedent, NOT the N2244 draw pattern: the task's
        # "driver tick line" parenthetical does not apply to
        # persistence, and inventing a per-tick save stamp would
        # invent behavior. (4) The rotation default is 90.0,
        # the field default (`public float rotation = 90;`,
        # BaseTurret.java:114). (5) The one def, segment, is the
        # only PointDefenseTurret def (Blocks.java:3835-3845),
        # so one set of functions covers it. Two new result
        # symbols: write.rotation, read.rotation.
        self.assertEqual(
            ledger['N2245']['source_symbols'],
            [
                'source_point_defense_turret_write_state_result.rotation',
                'source_point_defense_turret_read_state_result.rotation',
            ],
        )
        for name in ledger['N2245']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2245']['runtime_proof'], '/root/C07PointDefenseTurretWriteReadProof')
        self.assertEqual(
            ledger['N2245']['tests'],
            [
                'test_c07_point_defense_turret_write_read_registration',
                'test_all_c07_point_defense_turret_write_read_input_evidence_is_exact',
                'test_point_defense_turret_write_read_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_write_read',
            ],
        )
        self.assertTrue(ledger['N2245']['deferred_exprs'])

    def test_all_c07_point_defense_turret_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2245']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2245']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_write_read_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # PointDefenseBuild persists exactly ONE field, its
        # rotation: `public void write(Writes write){` /
        # `super.write(write);` / `write.f(rotation);`
        # (PointDefenseTurret.java:117-121), and restores it
        # unconditionally: `public void read(Reads read, byte
        # revision){` / `super.read(read, revision);` /
        # `rotation = read.f();`
        # (PointDefenseTurret.java:124-127) -- NO
        # `if(revision >= 1){` guard, unlike RepairTurret
        # (RepairTurret.java:246-248, N2217). PointDefenseTurret
        # does NOT override version(), so the save version is
        # the BuildingComp default 0 (`public byte version(){`
        # / `return 0;`, BuildingComp.java:669-671). The rotation
        # default is 90.0 (`public float rotation = 90;`,
        # BaseTurret.java:114). Target is NOT persisted -- it is
        # re-acquired by the retarget timer
        # (PointDefenseTurret.java:65-67) -- and reloadCounter
        # is NOT persisted either -- it is recharged every tick
        # (`reloadCounter += edelta();`,
        # PointDefenseTurret.java:79; `public float
        # reloadCounter;`, ReloadTurret.java:26). The write
        # function returns ONLY rotation (the proof checks the
        # result has exactly one key); the read function takes
        # NO revision parameter and NO frame parameter and
        # returns the saved rotation always. There is NO driver
        # tick line: persistence is not a per-tick call, and the
        # port has no save/load stream to call these functions
        # yet.
        self.assertIn('static func source_point_defense_turret_write_state(frame: Dictionary) -> Dictionary:', point_defense)
        self.assertIn('var rotation: float = float(frame.get("rotation", 90.0))', point_defense)
        self.assertIn('return {"rotation": rotation}', point_defense)
        self.assertIn('static func source_point_defense_turret_read_state(saved_rotation: float) -> Dictionary:', point_defense)
        self.assertIn('return {"rotation": saved_rotation}', point_defense)
        self.assertIn('const POINT_DEFENSE_TURRET_SAVE_VERSION := 0', point_defense)
        for expr in [
            'public void write(Writes write){',
            'super.write(write);',
            'write.f(rotation);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'rotation = read.f();',
            'public byte version(){',
            'return 0;',
            'public float rotation = 90;',
            'public class PointDefenseTurret extends ReloadTurret{',
            'public class PointDefenseBuild extends ReloadTurretBuild{',
            'public @Nullable Bullet target;',
            'if(timer(timerTarget, retargetTime)){',
            'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));',
            'public float reloadCounter;',
            'reloadCounter += edelta();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, point_defense)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick, no save file: the
        # persisted value is one float): write returns the
        # current rotation / write defaults to 90 when the frame
        # carries no rotation / write returns only rotation /
        # read restores the saved rotation unconditionally /
        # read restores a second saved value the same way (the
        # restore is not revision-gated, unlike N2217) / read
        # returns only rotation / write-then-read round-trips
        # the value / the save version is 0. There are no
        # revision keys: PointDefenseTurret.read() has no
        # revision guard, unlike RepairTurret (N2217).
        proof = POINT_DEFENSE_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_returns_current_rotation',
            'write_defaults_to_90_when_absent',
            'write_returns_only_rotation',
            'read_restores_saved_rotation',
            'read_restores_saved_rotation_second_value',
            'read_returns_only_rotation',
            'write_read_round_trip',
            'version_is_0',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_returns_current_rotation',
            'write_defaults_to_90_when_absent',
            'write_returns_only_rotation',
            'read_restores_saved_rotation',
            'read_restores_saved_rotation_second_value',
            'read_returns_only_rotation',
            'write_read_round_trip',
            'version_is_0',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
