import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SENSE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretSenseProof.gd'


class C07TurretSenseTests(unittest.TestCase):
    def test_c07_turret_sense_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2293']['godot_owner'], 'SourceTurretBuildState.source_turret_sense_state')
        # TurretBuild overrides sense (Turret.java:406-419,
        # `public double sense(LAccess sensor){` / `return
        # switch(sensor){` / `case ammo -> totalAmmo;` /
        # `case ammoCapacity -> maxAmmo;` / `case rotation
        # -> rotation;` / `case shootX -> World.conv(
        # targetPos.x);` / `case shootY -> World.conv(
        # targetPos.y);` / `case shooting -> isShooting ? 1
        # : 0;` / `case progress -> progress();` / `default
        # -> super.sense(sensor);`) over the base default
        # BuildingComp.sense (BuildingComp.java:2093,
        # `public double sense(LAccess sensor){`), whose
        # default is `default -> Float.NaN; //gets converted
        # to null in logic` (BuildingComp.java:2123). The
        # inputs are the TurretBuild fields totalAmmo
        # (Turret.java:283, `public int totalAmmo;`), maxAmmo
        # (Turret.java:47, `public int maxAmmo = 30;`),
        # rotation (BaseTurret.java:114, `public float
        # rotation = 90;`), targetPos (Turret.java:290, `public
        # Vec2 targetPos = new Vec2();`), isShooting
        # (Turret.java:292, `public boolean wasShooting,
        # isShooting;`), and the reload pair reloadCounter
        # (ReloadTurret.java:26, `public float
        # reloadCounter;`) / reload (ReloadTurret.java:10,
        # `public float reload = 10f;`) for the progress case
        # (N2254, `return Mathf.clamp(reloadCounter /
        # reload);`, Turret.java:426), plus tilesize
        # (Vars.java:135, `public static final int tilesize
        # = 8;`) for World.conv (World.java:165-166,
        # `public static float conv(float coord){` /
        # `return coord / tilesize;`). The sensor spellings
        # are the LAccess enum names `ammo,` (LAccess.java:18),
        # `ammoCapacity,` (:19), `progress,` (:28),
        # `rotation,` (:30), `shootX,` (:35), `shootY,`
        # (:36), `shooting,` (:49). RED decisions (recorded
        # in the register docstring): (1) one pure function
        # on SourceTurretBuildState.gd next to the N2253
        # shouldConsume / N2254 progress rows, following the
        # N2223 sense precedent exactly: (frame, sensor, ...)
        # and the generic laccess wire shape (`handled` +
        # `sense_value` + `sense_value_is_nan`), so a caller
        # can tell "handled" from "not handled -- fall through
        # to super.sense". (2) All live values arrive as
        # explicit params (the N2188 precedent) --
        # the tick frame tracks only cheating / enabled /
        # power_status / efficiency today. (3) The progress
        # case calls the N2254 pure function with explicit
        # params. (4) NO driver line: sense is a logic read,
        # not a tick write (the N2206 / N2208 / N2223
        # precedent); the logic-processor dispatch hook is
        # its own later slice. Three new result symbols:
        # handled, sense_value, sense_value_is_nan. This
        # closes the deferred item recorded in N2253/N2254.
        self.assertEqual(
            ledger['N2293']['source_symbols'],
            [
                'source_turret_sense_state_result.handled',
                'source_turret_sense_state_result.sense_value',
                'source_turret_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2293']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/logic/LAccess.java',
                    'core/src/mindustry/core/World.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2293']['runtime_proof'], '/root/C07TurretSenseProof')
        self.assertEqual(
            ledger['N2293']['tests'],
            [
                'test_c07_turret_sense_registration',
                'test_all_c07_turret_sense_input_evidence_is_exact',
                'test_turret_sense_state',
                'test_reference_graph_and_actual_c07_turret_sense',
            ],
        )
        self.assertTrue(ledger['N2293']['deferred_exprs'])
        self.assertNotIn(
            'TurretBuild.sense() (Turret.java:406-419)',
            ' '.join(ledger['N2293']['deferred_exprs']),
        )

    def test_all_c07_turret_sense_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2293']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/core/World.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2293']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_sense_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.sense() (Turret.java:406-419):
        # `public double sense(LAccess sensor){`
        # `return switch(sensor){`
        # `case ammo -> totalAmmo;`
        # `case ammoCapacity -> maxAmmo;`
        # `case rotation -> rotation;`
        # `case shootX -> World.conv(targetPos.x);`
        # `case shootY -> World.conv(targetPos.y);`
        # `case shooting -> isShooting ? 1 : 0;`
        # `case progress -> progress();`
        # `default -> super.sense(sensor);`
        # over BuildingComp.sense (BuildingComp.java:2093),
        # whose default is `default -> Float.NaN; //gets
        # converted to null in logic` (BuildingComp.java:2123).
        # World.conv (World.java:165-166, `public static float
        # conv(float coord){` / `return coord / tilesize;`)
        # divides by tilesize (Vars.java:135, `public static
        # final int tilesize = 8;`). rotation is the
        # BaseTurretBuild float rotation (BaseTurret.java:114,
        # `public float rotation = 90;`). The progress case calls the N2254 pure
        # function (`return Mathf.clamp(reloadCounter /
        # reload);`, Turret.java:426) with explicit params
        # (reloadCounter, ReloadTurret.java:26, `public float
        # reloadCounter;`; reload, ReloadTurret.java:10,
        # `public float reload = 10f;`). No driver line:
        # sense is a logic read, not a tick write.
        self.assertIn('static func source_turret_sense_state(frame: Dictionary, sensor: String, total_ammo: int, max_ammo: int, rotation: float, target_pos: Vector2, is_shooting: bool, reload_counter: float, reload: float, tilesize: float) -> Dictionary:', turret)
        self.assertIn('return {"handled": true, "sense_value": float(total_ammo), "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": float(max_ammo), "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": float(rotation), "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": target_pos.x / tilesize, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": target_pos.y / tilesize, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": 1.0 if is_shooting else 0.0, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": false, "sense_value": null, "sense_value_is_nan": true}', turret)
        for expr in [
            'public double sense(LAccess sensor){',
            'case ammo -> totalAmmo;',
            'case ammoCapacity -> maxAmmo;',
            'case rotation -> rotation;',
            'case shootX -> World.conv(targetPos.x);',
            'case shootY -> World.conv(targetPos.y);',
            'case shooting -> isShooting ? 1 : 0;',
            'case progress -> progress();',
            'default -> super.sense(sensor);',
            'public int totalAmmo;',
            'public int maxAmmo = 30;',
            'public Vec2 targetPos = new Vec2();',
            'public boolean wasShooting, isShooting;',
            'public float rotation = 90;',
            'public static float conv(float coord){',
            'return coord / tilesize;',
            'public static final int tilesize = 8;',
            'return Mathf.clamp(reloadCounter / reload);',
            'public float reload = 10f;',
            'public float reloadCounter;',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'default -> Float.NaN; //gets converted to null in logic',
            'ammo,',
            'ammoCapacity,',
            'progress,',
            'rotation,',
            'shootX,',
            'shootY,',
            'shooting,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: ammo reads totalAmmo,
        # ammoCapacity reads maxAmmo, rotation reads the
        # BaseTurret float rotation, shootX/shootY read
        # targetPos / tilesize, shooting reads 1/0 from
        # isShooting, progress reads the N2254 clamp, and
        # an unhandled sensor falls through to super.sense.
        proof = TURRET_SENSE_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_ammo',
            'sense_ammo_capacity',
            'sense_rotation',
            'sense_shoot_x',
            'sense_shoot_y',
            'sense_shooting_true',
            'sense_shooting_false',
            'sense_progress',
            'sense_unhandled_sensor',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_sense(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretSenseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SENSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_ammo',
            'sense_ammo_capacity',
            'sense_rotation',
            'sense_shoot_x',
            'sense_shoot_y',
            'sense_shooting_true',
            'sense_shooting_false',
            'sense_progress',
            'sense_unhandled_sensor',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
