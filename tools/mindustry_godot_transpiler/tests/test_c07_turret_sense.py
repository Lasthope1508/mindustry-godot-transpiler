import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SENSE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretSenseProof.gd'


class C07TurretSenseTests(unittest.TestCase):
    def test_c07_turret_sense_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2283']['godot_owner'], 'SourceTurretBuildState.source_turret_sense_state')
        # sense() is `public double sense(LAccess sensor){ return
        # switch(sensor){ case ammo -> totalAmmo; case
        # ammoCapacity -> maxAmmo; case rotation -> rotation;
        # case shootX -> World.conv(targetPos.x); case shootY
        # -> World.conv(targetPos.y); case shooting ->
        # isShooting ? 1 : 0; case progress -> progress();
        # default -> super.sense(sensor); }; }`
        # (Turret.java:405-419). Every Turret case has a live
        # or catalog input: ammo reads totalAmmo (`public int
        # totalAmmo;`, Turret.java:283, live in the driver as
        # duo_total from the game dict -- passed as an explicit
        # int param because the frame carries no total_ammo
        # key); ammoCapacity reads maxAmmo (`public int maxAmmo
        # = 30;`, Turret.java:47, duo never overrides it --
        # explicit int param); rotation reads the live frame
        # key stamped every tick by the aim call (absent folds
        # to 90.0, `public float rotation = 90;`,
        # BaseTurret.java:114); shootX/shootY read
        # World.conv(targetPos) (`public Vec2 targetPos = new
        # Vec2();`, Turret.java:290, default (0,0); `public
        # static float conv(float coord){` / `return coord /
        # tilesize;`, World.java:165-166; `public static final
        # int tilesize = 8;`, Vars.java:135) over the live
        # frame target_pos dict (null counts as (0,0));
        # shooting reads the live frame is_shooting (N2277
        # tick, `public boolean wasShooting, isShooting;`,
        # Turret.java:292); progress reads the live frame
        # progress (N2282 tick, `public float progress(){` /
        # `return Mathf.clamp(reloadCounter / reload);`,
        # Turret.java:425-427). The default falls through to
        # super.sense (BuildingComp.java:2093-2126, ~25 cases)
        # -- its own later slice -- so the pure function
        # reports handled false + NaN and the caller knows to
        # fall through. There is NO driver tick line: sense is
        # a logic read, not a tick write (the N2206/N2208/N2223
        # precedent); the proof calls the pure function
        # directly with synthetic frames, and the
        # logic-processor dispatch hook is its own later slice.
        # Three new result symbols: handled, sense_value,
        # sense_value_is_nan.
        self.assertEqual(
            ledger['N2283']['source_symbols'],
            [
                'source_turret_sense_state_result.handled',
                'source_turret_sense_state_result.sense_value',
                'source_turret_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2283']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_sense_state')
        self.assertEqual(ledger['N2283']['runtime_proof'], '/root/C07TurretSenseProof')
        self.assertEqual(
            ledger['N2283']['tests'],
            [
                'test_c07_turret_sense_registration',
                'test_all_c07_turret_sense_input_evidence_is_exact',
                'test_turret_sense_state',
                'test_reference_graph_and_actual_c07_turret_sense',
            ],
        )
        self.assertTrue(ledger['N2283']['deferred_exprs'])

    def test_all_c07_turret_sense_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2283']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_sense_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/core/World.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2283']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_sense_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # sense() (Turret.java:405-419) dispatches the seven
        # Turret cases over live frame keys and catalog params
        # (see the registration test above); any other sensor
        # falls through to super.sense (BuildingComp.java:2093,
        # `default -> super.sense(sensor);`, Turret.java:415),
        # whose own default is NaN (`default -> Float.NaN;
        # //gets converted to null in logic`,
        # BuildingComp.java:2123). The sensor spellings are
        # the LAccess enum names (`ammo,` LAccess.java:18,
        # `ammoCapacity,` :19, `progress,` :28, `rotation,`
        # :30, `shootX,` :35, `shootY,` :36, `shooting,` :49).
        # The pure function takes (frame, sensor, total_ammo,
        # max_ammo, tilesize) and returns the N2206/N2208/N2223
        # sense wire shape (handled + sense_value +
        # sense_value_is_nan). There is no driver tick line:
        # sense is a logic read, not a tick write.
        self.assertIn('static func source_turret_sense_state(frame: Dictionary, sensor: String, total_ammo: int, max_ammo: int, tilesize: float) -> Dictionary:', turret)
        self.assertIn('return {"handled": true, "sense_value": ammo_value, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": ammo_capacity_value, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": rotation_value, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": shoot_x_value, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": shoot_y_value, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": shooting_value, "sense_value_is_nan": false}', turret)
        self.assertIn('return {"handled": true, "sense_value": progress_value, "sense_value_is_nan": false}', turret)
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
            'public int maxAmmo = 30;',
            'public int totalAmmo;',
            'public Vec2 targetPos = new Vec2();',
            'public boolean wasShooting, isShooting;',
            'public float rotation = 90;',
            'public static float conv(float coord){',
            'return coord / tilesize;',
            'public static final int tilesize = 8;',
            'public float progress(){',
            'return Mathf.clamp(reloadCounter / reload);',
            'ammo,',
            'ammoCapacity,',
            'rotation,',
            'shootX,',
            'shootY,',
            'shooting,',
            'progress,',
            'default -> Float.NaN; //gets converted to null in logic',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately BEFORE
        # source_turret_progress_state, since Java order is
        # sense :405-419 before progress :425-427.
        self.assertLess(turret.index('static func source_turret_sense_state('), turret.index('static func source_turret_progress_state('))
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: sense is a logic
        # read of the frame + the live total_ammo / catalog
        # max_ammo params): ammo at a live total, capacity at
        # the duo default, rotation at the default / a custom
        # frame value, shootX/shootY converted through
        # World.conv, shooting true/false, progress live, and
        # an unhandled sensor.
        proof = TURRET_SENSE_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_ammo_live_total',
            'sense_ammo_capacity_default',
            'sense_rotation_default',
            'sense_rotation_custom',
            'sense_shoot_x_converted',
            'sense_shoot_y_converted',
            'sense_shooting_true',
            'sense_shooting_false',
            'sense_progress_live',
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
            'sense_ammo_live_total',
            'sense_ammo_capacity_default',
            'sense_rotation_default',
            'sense_rotation_custom',
            'sense_shoot_x_converted',
            'sense_shoot_y_converted',
            'sense_shooting_true',
            'sense_shooting_false',
            'sense_progress_live',
            'sense_unhandled_sensor',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
