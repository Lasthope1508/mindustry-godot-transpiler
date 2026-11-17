import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_RANGE_BUILD_ROTATION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretRangeBuildRotationProof.gd'


class C07RepairTurretRangeBuildRotationTests(unittest.TestCase):
    def test_c07_repair_turret_range_build_rotation_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2233']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_range_state')
        # N2174 / N2188 / N2209 / N2212 / N2213 / N2214 / N2215 /
        # N2217 / N2219 / N2220 / N2221 / N2222 / N2223 / N2224 /
        # N2225 / N2226 / N2227 made the repair turret live
        # (power row, should-consume gate, coolant multiplier,
        # target acquire, heal advance, rotation slerp, strength
        # lerp, read/write persistence, drawBeam, draw, drawSelect
        # /drawPlace, shouldAmbientSound/status, ambient-sound
        # loop, sense range/rotation, setStats, init, icons) --
        # but nothing in the port captured the two one-line
        # accessors of RepairPointBuild: `range()` (`return
        # repairRadius;`, RepairTurret.java:232, from the Ranged
        # interface, Ranged.java:5-6) and `buildRotation()`
        # (`return rotation;`, RepairTurret.java:160, from the
        # RotBlock interface, RotBlock.java:4-5). RED decisions
        # (resolved at RED, recorded in the register docstring):
        # (1) Two pure functions on the same family file, range
        # taking the per-def repair_radius explicitly (per-def
        # static state, not a live frame key -- the N2212 / N2220
        # precedent; resolved by the existing
        # `_repair_radius_for_block_id` helper) and buildRotation
        # reading the live `frame["rotation"]` key (stamped by
        # the N2214 slerp + N2217 read/write, absent folding to
        # 90.0, the Java field init -- the N2223 sense(rotation)
        # precedent). (2) There is NO driver tick line for
        # either accessor: both are pure reads (the N2223 sense
        # / N2230 setStats / N2232 RepairTower range+warmup
        # precedent). (3) The deferred pool entry "RepairTurret
        # status() / range() rows" is dropped -- both halves are
        # now done (status() at N2221, range() here) -- and
        # replaced by the N2233 Windows-proof debt entry.
        # (4) config-display stays deferred: it is
        # BuildingComp-level work (display() BuildingComp.java:
        # 1556, senseObject(config) BuildingComp.java:2139-2146,
        # configSenseable Block.java:809-813), investigated at
        # N2222 RED and N2224, bigger and unpinned. Two new
        # result symbols: range, build_rotation.
        self.assertEqual(
            ledger['N2233']['source_symbols'],
            [
                'source_repair_turret_range_state_result.range',
                'source_repair_turret_build_rotation_state_result.build_rotation',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/logic/Ranged.java',
            'core/src/mindustry/world/blocks/RotBlock.java',
        }
        for name in ledger['N2233']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2233']['runtime_proof'], '/root/C07RepairTurretRangeBuildRotationProof')
        self.assertEqual(
            ledger['N2233']['tests'],
            [
                'test_c07_repair_turret_range_build_rotation_registration',
                'test_all_c07_repair_turret_range_build_rotation_input_evidence_is_exact',
                'test_repair_turret_range_build_rotation_state',
                'test_reference_graph_and_actual_c07_repair_turret_range_build_rotation',
            ],
        )
        self.assertTrue(ledger['N2233']['deferred_exprs'])

    def test_all_c07_repair_turret_range_build_rotation_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2233']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/logic/Ranged.java',
            'core/src/mindustry/world/blocks/RotBlock.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2233']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_range_build_rotation_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairPointBuild.range() (RepairTurret.java:230-233)
        # returns the per-def repairRadius: class default 50f
        # (`public float repairRadius = 50f;`,
        # RepairTurret.java:32), repair-point 60f
        # (`repairRadius = 60f;`, Blocks.java:6389),
        # repair-turret 145f (`repairRadius = 145f;`,
        # Blocks.java:6401) -- from the Ranged interface
        # (`public interface Ranged extends Posc, Teamc{` /
        # `float range();`, Ranged.java:5-6). RepairPointBuild.
        # buildRotation() (RepairTurret.java:158-161) returns
        # the rotation field (`public float strength, rotation
        # = 90;`, RepairTurret.java:156), from the RotBlock
        # interface (`public interface RotBlock{` / `float
        # buildRotation();`, RotBlock.java:4-5). The rotation is
        # the live frame key (stamped by the N2214 slerp +
        # N2217 read/write), absent folding to 90.0, the Java
        # field init (the N2223 sense(rotation) precedent).
        # Neither accessor has a driver tick line: both are pure
        # reads (the N2223 sense / N2232 RepairTower range+
        # warmup precedent).
        self.assertIn('static func source_repair_turret_range_state(repair_radius: float) -> Dictionary:', repair_turret)
        self.assertIn('return {"range": repair_radius}', repair_turret)
        self.assertIn('static func source_repair_turret_build_rotation_state(frame: Dictionary) -> Dictionary:', repair_turret)
        self.assertIn('return {"build_rotation": float(frame.get("rotation", 90.0))}', repair_turret)
        for expr in [
            'public float range(){',
            'return repairRadius;',
            'public float buildRotation(){',
            'return rotation;',
            'public float strength, rotation = 90;',
            'public float repairRadius = 50f;',
            'public class RepairPointBuild extends Building implements Ranged, RotBlock{',
            'public class RepairTurret extends Block{',
            'repairRadius = 60f;',
            'repairRadius = 145f;',
            'public interface Ranged extends Posc, Teamc{',
            'float range();',
            'public interface RotBlock{',
            'float buildRotation();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        driver_start = repair_turret.index('static func source_repair_turret_tick_buildings_state')
        driver_end = repair_turret.find('\nstatic func ', driver_start + 1)
        driver_body = repair_turret[driver_start:driver_end if driver_end != -1 else len(repair_turret)]
        self.assertNotIn('source_repair_turret_range_state', driver_body)
        self.assertNotIn('source_repair_turret_build_rotation_state', driver_body)
        # The proof's keys drive the pure functions with
        # synthetic values: range at the two catalog radii and
        # the class default / build_rotation reading the live
        # frame rotation and defaulting to 90.0 when absent /
        # has no driver tick line (the proof reads the state
        # script source and greps the driver body -- a runtime
        # check, not a hardcoded true).
        proof = REPAIR_TURRET_RANGE_BUILD_ROTATION_PROOF.read_text(encoding='utf-8')
        for key in [
            'range_catalog_repair_point_60',
            'range_catalog_repair_turret_145',
            'range_class_default_50',
            'build_rotation_reads_frame',
            'build_rotation_absent_defaults_90',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_range_build_rotation(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretRangeBuildRotationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_RANGE_BUILD_ROTATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'range_catalog_repair_point_60',
            'range_catalog_repair_turret_145',
            'range_class_default_50',
            'build_rotation_reads_frame',
            'build_rotation_absent_defaults_90',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
