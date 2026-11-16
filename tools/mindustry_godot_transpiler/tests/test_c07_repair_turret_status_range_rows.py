import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_STATUS_RANGE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretStatusRangeRowsProof.gd'
REPAIR_TURRET_STATUS_RANGE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretStatusRangeRowsProof.tscn'


class C07RepairTurretStatusRangeRowsTests(unittest.TestCase):
    def test_c07_repair_turret_status_range_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2475']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_status_range_state')
        # status() (RepairTurret.java:226-228)
        # returns BlockStatus.noInput when
        # potentialEfficiency is ~0 (Mathf.equal
        # with tolerance 0.01f, the inclusive
        # |a - b| <= tolerance), else super.
        # status() (BuildingComp.java:632-646).
        # range() (RepairTurret.java:231-233)
        # returns repairRadius (the Ranged
        # interface accessor, Ranged.java:6).
        # N2475 ports both as ONE pure-only
        # pure, the N2435 precedent: the tick
        # never calls status() / range(), so the
        # pure takes caller-supplied inputs (the
        # folded potentialEfficiency, the
        # BuildingComp status result, the def
        # repairRadius) and returns the status
        # token + the range as data. One pure,
        # two new result symbols: the status
        # token and the range value.
        self.assertEqual(
            ledger['N2475']['source_symbols'],
            [
                'source_repair_turret_status_range_state_result.status',
                'source_repair_turret_status_range_state_result.range_value',
            ],
        )
        for name in ledger['N2475']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTurretBuildState.source_repair_turret_'))
        self.assertEqual(ledger['N2475']['runtime_proof'], '/root/C07RepairTurretStatusRangeRowsProof')
        self.assertEqual(
            ledger['N2475']['tests'],
            [
                'test_c07_repair_turret_status_range_rows_registration',
                'test_all_c07_repair_turret_status_range_rows_input_evidence_is_exact',
                'test_repair_turret_status_range_rows_state',
                'test_reference_graph_and_actual_c07_repair_turret_status_range_rows',
            ],
        )
        self.assertTrue(ledger['N2475']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #36 (1-based
        # in the merged advances-31 DEFERRED base,
        # 238 entries): "RepairTurret status() /
        # range() rows (status() noInput when
        # potentialEfficiency ~0, RepairTurret.
        # java:226-228; range() returns
        # repairRadius, RepairTurret.java:231-233)".
        # Net 238 - 1 = 237. No new entry: the
        # pure is complete as a pure -- range() is
        # already consumed by the N2421 draw pure
        # (drawSelect dash circle at repairRadius)
        # and the N2226 advance (repair_radius
        # param), and the status-display call sites
        # that would read status() are renderer/UI
        # work that waits for its own slices (the
        # N2421 draw precedent: no entry added for
        # call sites).
        self.assertFalse(any(entry.startswith('RepairTurret status() / range() rows (') for entry in ledger['N2475']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret read/write rows (') for entry in ledger['N2475']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret per-def stat rows (') for entry in ledger['N2475']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret live target acquire (') for entry in ledger['N2475']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret updateTile live fill (') for entry in ledger['N2475']['deferred_exprs']))
        self.assertEqual(len(ledger['N2475']['deferred_exprs']), 237)

    def test_all_c07_repair_turret_status_range_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2475']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_status_range_state_result.status': 'SourceRepairTurretBuildState.source_repair_turret_status_range_state',
                    'source_repair_turret_status_range_state_result.range_value': 'SourceRepairTurretBuildState.source_repair_turret_status_range_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/meta/BlockStatus.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/logic/Ranged.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2475']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_status_range_rows_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The status/range rows (RepairPointBuild.
        # status(), RepairTurret.java:226-228, and
        # range(), RepairTurret.java:231-233).
        # `return Mathf.equal(potentialEfficiency,
        # 0f, 0.01f) ? BlockStatus.noInput :
        # super.status();` -- noInput when the
        # folded potentialEfficiency is within
        # 0.01f of zero, else the BuildingComp
        # status. Mathf.equal(a, b, tolerance) is
        # `return Math.abs(a - b) <= tolerance;`
        # (arc Mathf.java:554-556) -- INCLUSIVE,
        # so exactly 0.01f still reads noInput.
        # super.status() is BuildingComp.status()
        # (BuildingComp.java:632-646): logicDisable
        # when !enabled, noOutput when
        # !shouldConsume(), noInput when efficiency
        # <= 0 or !productionValid(), else active
        # on the tick-phase gate -- the port
        # computes it as source_building_status_
        # state (SourceBuildingAccessPortBridge.gd)
        # and the caller supplies the result here.
        # potentialEfficiency is the transient
        # field (BuildingComp.java:89) the
        # consumption fold writes (`potential
        # Efficiency = efficiency;`, BuildingComp.
        # java:1989). range() returns repairRadius
        # (the class field, RepairTurret.java:32,
        # 50f; repair-point 60f / repair-turret
        # 145f, Blocks.java:6389/6401) -- the
        # Ranged.range() accessor (Ranged.java:6).
        # Pure-only: the tick never calls status()
        # / range() -- the status display and the
        # range queries wait for their own slices.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_repair_turret_status_range_state', repair_turret)
        self.assertIn('public BlockStatus status(){', repair_turret)
        self.assertIn('return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();', repair_turret)
        self.assertIn('public float range(){', repair_turret)
        self.assertIn('return repairRadius;', repair_turret)
        self.assertIn('public float repairRadius = 50f;', repair_turret)
        self.assertIn('return Math.abs(a - b) <= tolerance;', repair_turret)
        self.assertIn('public static boolean equal(float a, float b, float tolerance){', repair_turret)
        self.assertIn('transient float potentialEfficiency;', repair_turret)
        self.assertIn('potentialEfficiency = efficiency;', repair_turret)
        self.assertIn('return BlockStatus.logicDisable;', repair_turret)
        self.assertIn('if(!shouldConsume()){', repair_turret)
        self.assertIn('return BlockStatus.noOutput;', repair_turret)
        self.assertIn('if(efficiency <= 0 || !productionValid()){', repair_turret)
        self.assertIn('return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;', repair_turret)
        self.assertIn('noInput(Pal.remove),', repair_turret)
        self.assertIn('repairRadius = 60f;', repair_turret)
        self.assertIn('repairRadius = 145f;', repair_turret)
        self.assertIn('float range();', repair_turret)
        self.assertIn('public class RepairPointBuild extends Building implements Ranged, RotBlock{', repair_turret)
        # The documented limits record the
        # status/range rows as live.
        self.assertIn('Status/range rows live (N2475)', repair_turret)
        # The proof's keys drive the pure (the
        # no-input verdict at zero and near zero,
        # the super-status passthrough, the
        # inclusive 0.01 boundary, the just-
        # outside-tolerance verdict, and the
        # class + def range values).
        proof = REPAIR_TURRET_STATUS_RANGE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'status_no_input',
            'status_super',
            'status_boundary',
            'status_tolerance',
            'range_class',
            'range_def',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceRepairTurretBuildState.gd")', proof)
        self.assertTrue(REPAIR_TURRET_STATE.exists())
        self.assertTrue(REPAIR_TURRET_STATUS_RANGE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07RepairTurretStatusRangeRowsProof.gd', REPAIR_TURRET_STATUS_RANGE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_repair_turret_status_range_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretStatusRangeRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_STATUS_RANGE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'status_no_input',
            'status_super',
            'status_boundary',
            'status_tolerance',
            'range_class',
            'range_def',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
