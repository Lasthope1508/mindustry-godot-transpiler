import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_SENSE_RANGE_ROTATION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretSenseRangeRotationProof.gd'


class C07RepairTurretSenseRangeRotationTests(unittest.TestCase):
    def test_c07_repair_turret_sense_range_rotation_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2223']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_sense_state')
        # N2222 captured the ambient-sound live-loop gate, but a
        # logic processor reading `range` or `rotation` on a
        # repair turret still gets the BuildingComp default: the
        # sense switch has no RepairTurret override
        # (RepairTurret.java carries NO sense override), so the
        # two RepairTurret-specific legs come from the super
        # switch itself (BuildingComp.java:2093, `public double
        # sense(LAccess sensor){`): `case range -> this
        # instanceof Ranged r ? r.range() / tilesize : 0;`
        # (BuildingComp.java:2105) and `case rotation ->
        # rotation;` (BuildingComp.java:2106).
        # RepairPointBuild implements Ranged
        # (RepairTurret.java:153, `public class
        # RepairPointBuild extends Building implements Ranged,
        # RotBlock{`) with range() returning repairRadius
        # (RepairTurret.java:231-232, `public float range(){` /
        # `return repairRadius;`), and its rotation field
        # defaults to 90 (RepairTurret.java:156, `public float
        # strength, rotation = 90;`, read by buildRotation(),
        # RepairTurret.java:158-161, `return rotation;`). The
        # sensor spellings are the LAccess enum names `range,`
        # (LAccess.java:48) and `rotation,` (LAccess.java:30);
        # tilesize is 8 (Vars.java:135, `public static final int
        # tilesize = 8;`). Any other sensor falls through to
        # the switch default (BuildingComp.java:2123, `default
        # -> Float.NaN; //gets converted to null in logic`).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on the
        # same family file N2174 / N2188 / N2209 / N2212-N2215 /
        # N2217 / N2219-N2222 built, following the N2206
        # launch-pad / N2208 mass-driver sense precedent
        # exactly: (frame, sensor, ...) and the generic
        # laccess wire shape (`handled` + `sense_value` +
        # `sense_value_is_nan`,
        # SourceBlockSenseState.laccess_state), so a caller can
        # tell "handled" from "not handled -- fall through to
        # super.sense". (2) repair_radius and tilesize are
        # explicit float params (the N2212 acquire / N2220
        # draw-place per-def-param precedent -- repairRadius
        # is per-def static state, not a live frame key:
        # repair-point 60f, repair-turret 145f, class default
        # 50f, RepairTurret.java:32 / Blocks.java:6389,
        # :6401); rotation is the live frame key (stamped by
        # the N2214 slerp + N2217 read/write, absent folds to
        # 90.0, the Java field init). (3) An absent `rotation`
        # key reads 90.0, NOT NaN: `public float strength,
        # rotation = 90;` is the Java init value, so a freshly
        # built turret senses 90.0 -- the only observable Java
        # behavior at init. (4) There is NO driver tick line:
        # sense is a logic read, not a tick write (the
        # N2206/N2208 precedent); the proof calls
        # source_repair_turret_sense_state(frame, sensor,
        # repair_radius, tilesize) directly with synthetic
        # frames, and the logic-processor dispatch hook is its
        # own later slice. Three new result symbols: handled,
        # sense_value, sense_value_is_nan.
        self.assertEqual(
            ledger['N2223']['source_symbols'],
            [
                'source_repair_turret_sense_state_result.handled',
                'source_repair_turret_sense_state_result.sense_value',
                'source_repair_turret_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2223']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/logic/LAccess.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2223']['runtime_proof'], '/root/C07RepairTurretSenseRangeRotationProof')
        self.assertEqual(
            ledger['N2223']['tests'],
            [
                'test_c07_repair_turret_sense_range_rotation_registration',
                'test_all_c07_repair_turret_sense_range_rotation_input_evidence_is_exact',
                'test_repair_turret_sense_range_rotation_state',
                'test_reference_graph_and_actual_c07_repair_turret_sense_range_rotation',
            ],
        )
        self.assertTrue(ledger['N2223']['deferred_exprs'])

    def test_all_c07_repair_turret_sense_range_rotation_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2223']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2223']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_sense_range_rotation_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense reads the two RepairTurret-specific
        # legs (BuildingComp.java:2093, `public double
        # sense(LAccess sensor){`): `case range -> this
        # instanceof Ranged r ? r.range() / tilesize : 0;`
        # (BuildingComp.java:2105) with range() returning
        # repairRadius (RepairTurret.java:231-232, `public float
        # range(){` / `return repairRadius;`), and `case
        # rotation -> rotation;` (BuildingComp.java:2106) over
        # the rotation field (RepairTurret.java:156, `public
        # float strength, rotation = 90;`, read by
        # buildRotation(), RepairTurret.java:158-161, `return
        # rotation;`). The sensor spellings are the LAccess
        # enum names `range,` (LAccess.java:48) and `rotation,`
        # (LAccess.java:30); tilesize is 8 (Vars.java:135,
        # `public static final int tilesize = 8;`); any other
        # sensor falls through to the switch default
        # (BuildingComp.java:2123, `default -> Float.NaN;
        # //gets converted to null in logic`). repair_radius
        # and tilesize are explicit float params (the N2212 /
        # N2220 per-def-param precedent); rotation is the live
        # frame key, absent folding to 90.0. There is no driver
        # tick line: sense is a logic read, not a tick write.
        self.assertIn('static func source_repair_turret_sense_state(frame: Dictionary, sensor: String, repair_radius: float, tilesize: float) -> Dictionary:', repair_turret)
        self.assertIn('return {"handled": true, "sense_value": range_value, "sense_value_is_nan": false}', repair_turret)
        self.assertIn('return {"handled": true, "sense_value": rotation_value, "sense_value_is_nan": false}', repair_turret)
        self.assertIn('return {"handled": false, "sense_value": null, "sense_value_is_nan": true}', repair_turret)
        for expr in [
            'case range -> this instanceof Ranged r ? r.range() / tilesize : 0;',
            'case rotation -> rotation;',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'public float range(){',
            'return repairRadius;',
            'public float strength, rotation = 90;',
            'return rotation;',
            'public float repairRadius = 50f;',
            'public static final int tilesize = 8;',
            'public class RepairPointBuild extends Building implements Ranged, RotBlock{',
            'range,',
            'rotation,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: sense is a logic
        # read of the frame + the per-def params): range at
        # the class-default radius / repair-point radius /
        # repair-turret radius, rotation at the default /
        # a custom frame value, and an unhandled sensor.
        proof = REPAIR_TURRET_SENSE_RANGE_ROTATION_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_range_default_radius',
            'sense_range_repair_point',
            'sense_range_repair_turret',
            'sense_rotation_default',
            'sense_rotation_custom',
            'sense_unhandled_sensor',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_sense_range_rotation(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretSenseRangeRotationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_SENSE_RANGE_ROTATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_range_default_radius',
            'sense_range_repair_point',
            'sense_range_repair_turret',
            'sense_rotation_default',
            'sense_rotation_custom',
            'sense_unhandled_sensor',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
