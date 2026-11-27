import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
SENSE_OBJECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretSenseObjectProof.gd'

PROOF_KEYS = [
    'building_comes_from_unit',
    'breaking_comes_from_unit',
    'building_null_when_not_building',
    'type_falls_through_to_super',
    'super_null_passes_through',
    'parent_sense_object_differs_on_building_and_type',
    'returns_only_three_keys',
    'idempotent_second_call',
]


class C07BuildTurretSenseObjectTests(unittest.TestCase):
    def test_c07_build_turret_sense_object_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2485']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_sense_object_state')
        # BuildTurretBuild.senseObject() (BuildTurret.java:289-295):
        #     public Object senseObject(LAccess sensor){
        #         return switch(sensor){
        #             case building, breaking -> unit.senseObject(sensor);
        #             default -> super.senseObject(sensor);
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
        # reads Unit.senseObject (UnitComp.java:313):
        # building -> `isBuilding() &&
        # !buildPlan().breaking ? buildPlan().tile().build :
        # null;` (:324) and breaking -> `isBuilding() &&
        # buildPlan().breaking ? buildPlan().tile().build :
        # null;` (:325) -- the build object when the builder
        # unit has a plan of that kind, null otherwise. The
        # default leg is `super.senseObject(sensor)` --
        # BaseTurretBuild does NOT override senseObject, so
        # super resolves to BuildingComp.senseObject
        # (BuildingComp.java:2128, `case type -> block;` /
        # `case firstItem -> ...` / `case config -> ...` /
        # `case payloadType -> ...` / `default ->
        # noSensed;`, :2129-2135). TRAP: a port delegating
        # EVERY sensor to unit is WRONG -- only
        # building/breaking go to unit; a port dropping the
        # default branch is WRONG -- every other sensor
        # falls through to super. TRAP: this is NOT the
        # turret senseObject bridge (N2506,
        # source_turret_sense_object_state, which models the
        # BuildingComp rows type/firstItem/config/payloadType
        # itself) and NOT DrillBuild.senseObject (N2298,
        # firstItem -> dominantItem) -- the two switches are
        # different, sibling vs child class.
        # TWIN-REGISTER (main thread approved explicitly
        # 2026-11-27): the case line `case building,
        # breaking -> unit.senseObject(sensor);` has exactly
        # ONE hit in the ledger's exact_exprs -- N2184
        # (BuildTurretBuild.updateTile), which cites it
        # only as dependency evidence and ports NO
        # senseObject function; N2184's own deferred_exprs
        # say "BuildTurret sense rows (sense buildX/buildY
        # + senseObject building/breaking delegate to unit,
        # BuildTurret.java:281-295) -- logic sensing waits
        # for its own slice." Precedent: N2484 (sense, same
        # N2184 owner and same deferred sentence), N2474,
        # N2477, N2480, N2482, N2421, N2389, N2418. The
        # model follows N2484 (sense) + N2298
        # (DrillBuild.senseObject) exactly: the handled leg
        # returns handled=true with the caller-pre-resolved
        # unit value; the fallthrough leg returns
        # handled=false with the caller-pre-resolved super
        # value + its is-null flag (the N2317/N2323
        # super-as-param precedent). Five inputs (frame +
        # sensor + unit_sense_object_value +
        # super_sense_object_value +
        # super_sense_object_value_is_null) and three result
        # symbols, following the N2484 sense precedent
        # (result symbols only).
        self.assertEqual(
            ledger['N2485']['java_method'],
            'BuildTurretBuild.senseObject(LAccess)',
        )
        self.assertEqual(
            ledger['N2485']['source_symbols'],
            [
                'source_build_turret_sense_object_state_result.handled',
                'source_build_turret_sense_object_state_result.sense_object_value',
                'source_build_turret_sense_object_state_result.sense_object_value_is_null',
            ],
        )
        for name in ledger['N2485']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                # The sense_object_value_is_null symbol's
                # expr lives in BuildingComp.java (the super
                # default), the others in BuildTurret.java /
                # UnitComp.java -- all four are slice sources
                # (the N2293 pattern).
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                    'core/src/mindustry/entities/comp/UnitComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/logic/LAccess.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_sense_object_state'))
        self.assertEqual(ledger['N2485']['runtime_proof'], '/root/C07BuildTurretSenseObjectProof')
        self.assertEqual(
            ledger['N2485']['tests'],
            [
                'test_c07_build_turret_sense_object_registration',
                'test_all_c07_build_turret_sense_object_input_evidence_is_exact',
                'test_build_turret_sense_object_state',
                'test_reference_graph_and_actual_c07_build_turret_sense_object',
            ],
        )
        self.assertTrue(ledger['N2485']['deferred_exprs'])

    def test_all_c07_build_turret_sense_object_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2485']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_sense_object_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2485']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_sense_object_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.senseObject() (BuildTurret.java:289-295):
        #     case building, breaking -> unit.senseObject(sensor);
        #     default -> super.senseObject(sensor);
        # TRAP: a port routing every sensor to unit is
        # wrong -- only building/breaking take the unit leg.
        # TRAP: a port dropping the default branch is
        # wrong -- every other sensor returns the
        # caller-passed super result with handled=false.
        # TRAP: this is NOT the turret senseObject bridge
        # (N2506) -- that one handles type itself; this
        # slice falls through to super for type.
        self.assertIn('static func source_build_turret_sense_object_state(frame: Dictionary, sensor: String, unit_sense_object_value: Variant, super_sense_object_value: Variant, super_sense_object_value_is_null: bool) -> Dictionary:', build_turret)
        self.assertIn('if sensor == "building" or sensor == "breaking":', build_turret)
        self.assertIn('return {"handled": true, "sense_object_value": unit_sense_object_value, "sense_object_value_is_null": unit_sense_object_value == null}', build_turret)
        self.assertIn('return {"handled": false, "sense_object_value": super_sense_object_value, "sense_object_value_is_null": super_sense_object_value_is_null}', build_turret)
        # Function order follows Java order: senseObject()
        # (:289-295) comes after sense() (:281-287, N2484,
        # source_build_turret_sense_state) in the same
        # class, so the new function sits after sense in
        # this file.
        self.assertLess(
            build_turret.index('static func source_build_turret_sense_state('),
            build_turret.index('static func source_build_turret_sense_object_state('),
        )
        # The proof drives the pure function with
        # pre-resolved unit + super values (no live tick,
        # no game state): building/breaking must come from
        # the unit value, every other sensor from the super
        # value, a null unit value must pass through with
        # handled=true, a null super must pass through with
        # handled=false, and the turret senseObject bridge
        # (N2506) must differ on building (it does not
        # handle it) and on type (it handles it itself);
        # the result has exactly three keys; a second call
        # with the same input gives the same output.
        proof = SENSE_OBJECT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_sense_object(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretSenseObjectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_SENSE_OBJECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
