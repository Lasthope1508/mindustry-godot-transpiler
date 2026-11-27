import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
SENSE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretSenseProof.gd'

PROOF_KEYS = [
    'build_x_comes_from_unit',
    'build_y_comes_from_unit',
    'ammo_falls_through_to_super',
    'super_nan_passes_through',
    'build_x_minus_one_when_not_building',
    'parent_sense_differs_on_ammo',
    'returns_only_three_keys',
    'idempotent_second_call',
]


class C07BuildTurretSenseTests(unittest.TestCase):
    def test_c07_build_turret_sense_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2484']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_sense_state')
        # BuildTurretBuild.sense() (BuildTurret.java:281-287):
        #     public double sense(LAccess sensor){
        #         return switch(sensor){
        #             case buildX, buildY -> unit.sense(sensor);
        #             default -> super.sense(sensor);
        #         };
        #     }
        # on `public class BuildTurretBuild extends
        # BaseTurretBuild implements ControlBlock, RotBlock{`
        # (BuildTurret.java:92). The `unit` here is the
        # FIELD `public BlockUnitc unit =
        # (BlockUnitc)unitType.create(team);`
        # (BuildTurret.java:93) -- NOT the `unit()`
        # accessor (:113-119, excluded for its side-effect:
        # `unit.tile(this); unit.team(team);`). The unit leg
        # reads Unit.sense (UnitComp.java:264): buildX ->
        # `isBuilding() ? buildPlan().x : -1;` (:290) and
        # buildY -> `isBuilding() ? buildPlan().y : -1;`
        # (:291). The default leg is `super.sense(sensor)`
        # -- BaseTurretBuild does NOT override sense, so
        # super resolves to BuildingComp.sense
        # (BuildingComp.java:2093, default `default ->
        # Float.NaN; //gets converted to null in logic`,
        # :2123). TRAP: a port delegating EVERY sensor to
        # unit is WRONG -- only buildX/buildY go to unit;
        # a port dropping the default branch is WRONG --
        # every other sensor falls through to super.
        # TRAP: this is NOT TurretBuild.sense() (N2293,
        # Turret.java:406-418, a 7-case switch: ammo /
        # ammoCapacity / rotation / shootX / shootY /
        # shooting / progress) -- the two switches are
        # different, parent vs child class.
        # TWIN-REGISTER (main thread approved explicitly
        # 2026-11-27): the case line `case buildX, buildY
        # -> unit.sense(sensor);` has exactly ONE hit in
        # the ledger's exact_exprs -- N2184
        # (BuildTurretBuild.updateTile), which cites it
        # only as dependency evidence and ports NO sense
        # function; N2184's own deferred_exprs say
        # "BuildTurret sense rows (sense buildX/buildY +
        # senseObject building/breaking delegate to unit,
        # BuildTurret.java:281-295) -- logic sensing waits
        # for its own slice." Precedent: N2474, N2477,
        # N2480, N2482, N2421, N2389, N2418. The model
        # follows N2298 (DrillBuild.sense) exactly: the
        # handled leg returns handled=true with the
        # caller-pre-resolved unit value; the fallthrough
        # leg returns handled=false with the
        # caller-pre-resolved super value + its is-nan
        # flag (the N2317/N2323 super-as-param precedent).
        # Five inputs (frame + sensor + unit_sense_value
        # + super_sense_value + super_sense_value_is_nan)
        # and three result symbols, following the N2293 /
        # N2298 sense precedent (result symbols only).
        self.assertEqual(
            ledger['N2484']['java_method'],
            'BuildTurretBuild.sense(LAccess)',
        )
        self.assertEqual(
            ledger['N2484']['source_symbols'],
            [
                'source_build_turret_sense_state_result.handled',
                'source_build_turret_sense_state_result.sense_value',
                'source_build_turret_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2484']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                # The sense_value_is_nan symbol's expr lives
                # in BuildingComp.java (the super default),
                # the other two in BuildTurret.java -- all
                # four are slice sources (the N2293 pattern).
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                    'core/src/mindustry/entities/comp/UnitComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/logic/LAccess.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_sense_state'))
        self.assertEqual(ledger['N2484']['runtime_proof'], '/root/C07BuildTurretSenseProof')
        self.assertEqual(
            ledger['N2484']['tests'],
            [
                'test_c07_build_turret_sense_registration',
                'test_all_c07_build_turret_sense_input_evidence_is_exact',
                'test_build_turret_sense_state',
                'test_reference_graph_and_actual_c07_build_turret_sense',
            ],
        )
        self.assertTrue(ledger['N2484']['deferred_exprs'])

    def test_all_c07_build_turret_sense_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2484']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_sense_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2484']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_sense_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.sense() (BuildTurret.java:281-287):
        #     case buildX, buildY -> unit.sense(sensor);
        #     default -> super.sense(sensor);
        # TRAP: a port routing every sensor to unit is
        # wrong -- only buildX/buildY take the unit leg.
        # TRAP: a port dropping the default branch is
        # wrong -- every other sensor returns the
        # caller-passed super result with handled=false.
        # TRAP: this is NOT TurretBuild.sense() (N2293) --
        # the parent switch handles ammo itself; this
        # slice falls through to super for ammo.
        self.assertIn('static func source_build_turret_sense_state(frame: Dictionary, sensor: String, unit_sense_value: float, super_sense_value: Variant, super_sense_value_is_nan: bool) -> Dictionary:', build_turret)
        self.assertIn('if sensor == "buildX" or sensor == "buildY":', build_turret)
        self.assertIn('return {"handled": true, "sense_value": unit_sense_value, "sense_value_is_nan": false}', build_turret)
        self.assertIn('return {"handled": false, "sense_value": super_sense_value, "sense_value_is_nan": super_sense_value_is_nan}', build_turret)
        # Function order follows Java order: sense()
        # (:281-287) comes after read() (:266-278, N2429,
        # source_build_turret_read_plans_state) in the same
        # class, so the new function sits after read_plans
        # in this file (senseObject :289-295 inserts after
        # sense in its own later slice).
        self.assertLess(
            build_turret.index('static func source_build_turret_read_plans_state('),
            build_turret.index('static func source_build_turret_sense_state('),
        )
        # The proof drives the pure function with
        # pre-resolved unit + super values (no live tick,
        # no game state): buildX/buildY must come from the
        # unit value, every other sensor from the super
        # value, a NaN super must pass through, and the
        # parent TurretBuild.sense() (N2293) must differ
        # on ammo (it handles ammo itself); the result has
        # exactly three keys; a second call with the same
        # input gives the same output.
        proof = SENSE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_sense(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretSenseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_SENSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
