import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_CAMERA_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSenseCameraProof.gd'

BUILDING_COMP_SENSE_CAMERA_SIGNATURE = 'static func source_building_comp_sense_camera_state(sensor: String, is_control_block: bool, unit_sense_value: float) -> Dictionary:'
PROOF_KEYS = [
    'camera_not_control_num',
    'camera_x_num',
    'camera_y_num',
    'camera_width_num',
    'camera_height_num',
    'camera_zero_num',
    'camera_handled_true',
    'camera_value_not_nan',
]


class C07BuildingCompSenseCameraTests(unittest.TestCase):
    def test_c07_building_comp_sense_camera_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2518']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_camera_state')
        # BuildingComp.sense() `cameraX/cameraY/cameraWidth/cameraHeight` legs are
        # `case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof
        # ControlBlock c ? c.unit().sense(sensor) : 0;`
        # (BuildingComp.java:2122, the last leg of `public double sense(LAccess
        # sensor){`, :2093-2126), with the sensor spellings the LAccess enum
        # names (`cameraX,` `cameraY,` `cameraWidth,` `cameraHeight,`,
        # LAccess.java:37-40). The four legs share ONE Java case line and
        # ONE delegation expression, so one slice ports all four as one
        # pure function with a `sensor` param (splitting into four
        # slices would quadruple near-identical functions for zero
        # additional Java coverage). The delegation target already
        # exists in the port: `SourceUnitSensorState.laccess_state`
        # (SourceUnitSensorState.gd:41-44) ports the UnitComp.sense
        # camera legs (`case cameraX -> controller instanceof Player
        # player ? World.conv(player.con == null ? Core.camera.position.x
        # : player.con.viewX) : 0;`, UnitComp.java:283-286, and
        # cameraY/cameraWidth/cameraHeight analogously) -- 0 when the
        # controller is not a Player, else `World.conv` of the player
        # view / core camera value. This slice ports ONLY the
        # BuildingComp gate (`instanceof ControlBlock` + fallback 0 +
        # pass-through of the unit sense value); it does NOT re-port
        # the unit-side camera math. N2284 ported 23 handled legs of
        # BuildingComp.sense (BuildingComp.java:2093-2126) and left
        # dead/health/totalItems/camera*/powerNet* deferred.
        # N2511 ported `dead`, N2512 ported `health`, N2513 ported
        # `totalItems`, N2514 ported `powerNetIn`, N2515 ported
        # `powerNetOut`, N2516 ported `powerNetStored`, N2517 ported
        # `powerNetCapacity`. This slice ports exactly the camera*
        # case, the last leg of sense(). The three params are the live
        # input a future frame-stamp/wiring slice will supply (the
        # N2212/N2220 per-def-param precedent): `sensor` is one of the
        # four camera labels, `is_control_block` is `this instanceof
        # ControlBlock` (:2122, the gate of the ternary) and
        # `unit_sense_value` is `c.unit().sense(sensor)` -- the
        # already-ported unit sense result for this sensor. `sense_value`
        # is 0.0 when not a control block, else `unit_sense_value`
        # exactly (Java `sense()` returns double; the float widens
        # exactly), no clamping, no rounding, no World.conv here (the
        # conv already happened inside the unit sense call).
        # `handled` is true always (this function IS the camera case;
        # the sensor is one of the four camera labels) and
        # `sense_value_is_nan` is false always (the leg never yields
        # NaN; the key stays in the wire shape for consistency with
        # N2283/N2284/N2511/N2512/N2513/N2514/N2515/N2516/N2517).
        # Three new result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire shape). The
        # ported method is BuildingComp.sense, so the java_source is
        # BuildingComp.java and the slice mirrors into the comp shard
        # (567/471 -> 568/472); defense stays 210/209.
        self.assertEqual(
            ledger['N2518']['source_symbols'],
            [
                'source_building_comp_sense_camera_state_result.handled',
                'source_building_comp_sense_camera_state_result.sense_value',
                'source_building_comp_sense_camera_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2518']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_camera_state')
        self.assertEqual(ledger['N2518']['runtime_proof'], '/root/C07BuildingCompSenseCameraProof')
        self.assertEqual(
            ledger['N2518']['tests'],
            [
                'test_c07_building_comp_sense_camera_registration',
                'test_all_c07_building_comp_sense_camera_input_evidence_is_exact',
                'test_building_comp_sense_camera_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_camera',
            ],
        )
        self.assertTrue(ledger['N2518']['deferred_exprs'])

    def test_all_c07_building_comp_sense_camera_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2518']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_camera_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2518']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_camera_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense() `cameraX/cameraY/cameraWidth/cameraHeight` legs
        # (BuildingComp.java:2122): `case cameraX, cameraY, cameraWidth,
        # cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`
        # -- the pure function returns 0.0 when not a control block,
        # else `unit_sense_value` exactly (Java `sense()` returns
        # double; the float widens exactly), no clamping, no rounding,
        # no World.conv here (the conv already happened inside the unit
        # sense call, UnitComp.java:283-286, already ported in
        # `SourceUnitSensorState.laccess_state`), with handled true and
        # sense_value_is_nan false always (the N2283/N2284 sense wire
        # shape). There is no driver tick line: the leg is a logic
        # read, not a tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517
        # precedent); the proof calls the pure function directly with
        # synthetic inputs.
        self.assertIn(BUILDING_COMP_SENSE_CAMERA_SIGNATURE, turret)
        for line in [
            'var camera_value: float = 0.0 if not is_control_block else unit_sense_value',
            'return {"handled": true, "sense_value": camera_value, "sense_value_is_nan": false}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
            'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'cameraX,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_power_net_capacity_state and
        # BEFORE source_turret_sense_object_state, mirroring
        # the sense()/senseObject() order in
        # BuildingComp.java (:2093 / :2128) and, inside
        # sense(), dead :2098 -> health :2101 -> totalItems
        # :2107 -> powerNetIn :2114 -> powerNetOut :2115 ->
        # powerNetStored :2116 -> powerNetCapacity :2117 ->
        # camera* :2122 (the last leg of sense()). It
        # does NOT modify
        # source_building_comp_sense_state: camera* stay
        # handled:false in the big dispatch until a later
        # wiring slice connects this leg (same as N2511's
        # dead leg, N2512's health leg, N2513's totalItems
        # leg, N2514's powerNetIn leg, N2515's powerNetOut
        # leg, N2516's powerNetStored leg and N2517's
        # powerNetCapacity leg living beside N2284).
        self.assertLess(turret.index('static func source_building_comp_sense_power_net_capacity_state('), turret.index('static func source_building_comp_sense_camera_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_camera_state('), turret.index('static func source_turret_sense_object_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the leg is a logic
        # read of the passed-in unit sense value): not a
        # control block reads 0.0 (any sensor); cameraX with
        # a control block passes 12.5 through as 12.5,
        # cameraY 7.25 as 7.25, cameraWidth 40.0 as 40.0,
        # cameraHeight 22.5 as 22.5; zero unit value reads
        # 0.0; handled true, never NaN.
        proof = BUILDING_COMP_SENSE_CAMERA_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_camera(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSenseCameraProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_CAMERA_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
