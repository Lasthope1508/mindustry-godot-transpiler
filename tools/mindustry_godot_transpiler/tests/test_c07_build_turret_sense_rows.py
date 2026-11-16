import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretSenseRowsProof.gd'
BUILD_TURRET_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretSenseRowsProof.tscn'


class C07BuildTurretSenseRowsTests(unittest.TestCase):
    def test_c07_build_turret_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2437']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_sense_state')
        # The BuildTurret tick is live (N2215 shouldConsume
        # gate + N2243 sync/warmup advance + N2244 plan
        # logic + N2272 updateBuildLogic counter/selection
        # + N2251 nitrogen row + N2431 draw rows) but
        # NOTHING modeled sense() / senseObject():
        # sense() (BuildTurret.java:281-287) delegates
        # buildX / buildY to the builder unit and falls
        # through to super.sense for every other sensor,
        # and senseObject() (BuildTurret.java:289-295)
        # delegates building / breaking to the builder
        # unit and falls through to super.senseObject
        # for every other sensor. The unit is the live
        # BlockUnitc (`public BlockUnitc unit =
        # (BlockUnitc)unitType.create(team);`,
        # BuildTurret.java:93), so the pure NEVER queries
        # it directly: N2437 ports both methods as two
        # pure-only dispatches (the N2387 / N2390 / N2391
        # sense precedent) over caller-supplied unit
        # values -- sense takes unit_build_x /
        # unit_build_y (what unit.sense(buildX/buildY)
        # returns: the plan tile x/y, or -1 when the unit
        # is not building, UnitComp.java:290-291) and
        # senseObject takes unit_building /
        # unit_breaking (what unit.senseObject returns:
        # the plan tile's build, or null when the unit is
        # not building that way, UnitComp.java:323-324)
        # -- plus the caller-supplied super_value (the
        # BuildingComp switch result, already modeled by
        # SourceBuildingSenseState, NOT re-modeled here).
        # A null super_value is the super switch's
        # default branch: Float.NaN for sense (`default
        # -> Float.NaN; //gets converted to null in
        # logic`, BuildingComp.java:2123) and noSensed
        # for senseObject (`default -> noSensed;`,
        # BuildingComp.java:2134; `Object noSensed = new
        # Object();`, Senseable.java:6 -- the port's
        # canonical sense_object_state represents it as
        # value null + no_sensed true, and the
        # noSensed-to-numeric fallback lives in the logic
        # executor, LExecutor.java:697-700, not in this
        # pure). Four new result symbols: the sensed
        # value + the delegated flag for each dispatch.
        self.assertEqual(
            ledger['N2437']['source_symbols'],
            [
                'source_build_turret_sense_state_result.value',
                'source_build_turret_sense_state_result.delegated',
                'source_build_turret_sense_object_state_result.value',
                'source_build_turret_sense_object_state_result.delegated',
            ],
        )
        expected_owners = {
            'source_build_turret_sense_state_result.value': 'SourceBuildTurretBuildState.source_build_turret_sense_state',
            'source_build_turret_sense_state_result.delegated': 'SourceBuildTurretBuildState.source_build_turret_sense_state',
            'source_build_turret_sense_object_state_result.value': 'SourceBuildTurretBuildState.source_build_turret_sense_object_state',
            'source_build_turret_sense_object_state_result.delegated': 'SourceBuildTurretBuildState.source_build_turret_sense_object_state',
        }
        for name in ledger['N2437']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2437']['runtime_proof'], '/root/C07BuildTurretSenseRowsProof')
        self.assertEqual(
            ledger['N2437']['tests'],
            [
                'test_c07_build_turret_sense_rows_registration',
                'test_all_c07_build_turret_sense_rows_input_evidence_is_exact',
                'test_build_turret_sense_rows_state',
                'test_reference_graph_and_actual_c07_build_turret_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2437']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #90 (1-based in
        # the merged advances-26 DEFERRED base): the
        # BuildTurret sense rows entry is REMOVED
        # (resolve by text). No new entry is added: the
        # sense / senseObject pures are pure-only (no
        # tick wiring to defer), the super delegation
        # rides the already-modeled SourceBuildingSenseState
        # pures, the unit values arrive caller-supplied
        # (the live unit query waits under the existing
        # BuildTurret unit rows entry), and the logic
        # call site is a port-wide logic-executor concern
        # (not a BuildTurret deferral). Net 273 - 1 = 272.
        self.assertFalse(any(entry.startswith('BuildTurret sense rows (') for entry in ledger['N2437']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret unit rows (') for entry in ledger['N2437']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret read/write rows (') for entry in ledger['N2437']['deferred_exprs']))
        self.assertEqual(len(ledger['N2437']['deferred_exprs']), 272)

    def test_all_c07_build_turret_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        expected_owners = {
            'source_build_turret_sense_state_result.value': 'SourceBuildTurretBuildState.source_build_turret_sense_state',
            'source_build_turret_sense_state_result.delegated': 'SourceBuildTurretBuildState.source_build_turret_sense_state',
            'source_build_turret_sense_object_state_result.value': 'SourceBuildTurretBuildState.source_build_turret_sense_object_state',
            'source_build_turret_sense_object_state_result.delegated': 'SourceBuildTurretBuildState.source_build_turret_sense_object_state',
        }
        for name in ledger['N2437']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/logic/Senseable.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2437']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_sense_rows_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The sense rows (BuildTurretBuild.sense(),
        # BuildTurret.java:281-287): `public double
        # sense(LAccess sensor){` + `case buildX,
        # buildY -> unit.sense(sensor);` + `default ->
        # super.sense(sensor);`. The senseObject rows
        # (BuildTurretBuild.senseObject(),
        # BuildTurret.java:289-295): `public Object
        # senseObject(LAccess sensor){` + `case
        # building, breaking -> unit.senseObject(
        # sensor);` + `default -> super.senseObject(
        # sensor);`. The unit is the live BlockUnitc
        # (`public BlockUnitc unit = (BlockUnitc)
        # unitType.create(team);`, BuildTurret.java:93)
        # -- the pures NEVER query it directly, they
        # take its sensed values caller-supplied.
        # unit.sense(buildX/buildY) is the plan tile
        # coordinate, or -1 when not building (`case
        # buildX -> isBuilding() ? buildPlan().x : -1;`
        # / `case buildY -> isBuilding() ?
        # buildPlan().y : -1;`, UnitComp.java:290-291).
        # unit.senseObject(building/breaking) is the
        # plan tile's build, or null when the unit is
        # not building that way (`case building ->
        # isBuilding() && !buildPlan().breaking ?
        # buildPlan().tile().build : null;` / `case
        # breaking -> isBuilding() && buildPlan().
        # breaking ? buildPlan().tile().build : null;`,
        # UnitComp.java:323-324). The LAccess tokens are
        # the exact enum names (LAccess.java:54-55, 59-60:
        # buildX, buildY, building, breaking). The super
        # defaults are VERIFIED, not guessed: sense falls
        # back to the BuildingComp switch whose default
        # is Float.NaN (`default -> Float.NaN; //gets
        # converted to null in logic`, BuildingComp.java:
        # 2123), and senseObject falls back to the
        # BuildingComp switch whose default is noSensed
        # (`default -> noSensed;`, BuildingComp.java:
        # 2134; `Object noSensed = new Object();`,
        # Senseable.java:6). The port ALREADY models
        # both super switches (SourceBuildingSenseState),
        # so the pures take the caller's super.sense /
        # super.senseObject result as super_value
        # (default null = the default branch) instead of
        # re-modeling them. Pure-only: the tick never
        # calls sense or senseObject (verified: grep
        # `sense` in this driver finds only comments
        # plus these two pures) -- sense is called by
        # logic, and the logic call site waits for a
        # logic-executor slice (a port-wide concern,
        # not a BuildTurret deferral).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_build_turret_sense_state', build_turret)
        self.assertIn('static func source_build_turret_sense_object_state', build_turret)
        self.assertIn('public double sense(LAccess sensor){', build_turret)
        self.assertIn('case buildX, buildY -> unit.sense(sensor);', build_turret)
        self.assertIn('default -> super.sense(sensor);', build_turret)
        self.assertIn('public Object senseObject(LAccess sensor){', build_turret)
        self.assertIn('case building, breaking -> unit.senseObject(sensor);', build_turret)
        self.assertIn('default -> super.senseObject(sensor);', build_turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)unitType.create(team);', build_turret)
        self.assertIn('case buildX -> isBuilding() ? buildPlan().x : -1;', build_turret)
        self.assertIn('case buildY -> isBuilding() ? buildPlan().y : -1;', build_turret)
        self.assertIn('case building -> isBuilding() && !buildPlan().breaking ? buildPlan().tile().build : null;', build_turret)
        self.assertIn('case breaking -> isBuilding() && buildPlan().breaking ? buildPlan().tile().build : null;', build_turret)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', build_turret)
        self.assertIn('default -> noSensed;', build_turret)
        self.assertIn('Object noSensed = new Object();', build_turret)
        # The documented limits record the sense rows as
        # live, and the old "read / write / sense wait"
        # line is gone (read / write still wait).
        self.assertIn('Sense rows live (N2437)', build_turret)
        self.assertNotIn('Read / write / sense (BuildTurret.java:259-295) wait for their own slices.', build_turret)
        # The proof's keys drive both pures: the buildX /
        # buildY delegation (with the -1 not-building
        # value as caller data), the super.sense
        # delegation for a known sensor and the null
        # default for an unknown sensor, the building /
        # breaking delegation (with the null not-building
        # value as caller data), and the super.
        # senseObject delegation for a known sensor plus
        # the null noSensed default.
        proof = BUILD_TURRET_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_build_x_delegate',
            'sense_build_y_delegate',
            'sense_default_super',
            'sense_object_building_delegate',
            'sense_object_breaking_delegate',
            'sense_object_default_super',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file and the
        # super.sense state file (the N2185 lesson: check
        # the preload targets exist, and the scene file
        # exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(BUILD_TURRET_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(BUILD_TURRET_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BuildTurretSenseRowsProof.gd', BUILD_TURRET_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_build_turret_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_build_x_delegate',
            'sense_build_y_delegate',
            'sense_default_super',
            'sense_object_building_delegate',
            'sense_object_breaking_delegate',
            'sense_object_default_super',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
