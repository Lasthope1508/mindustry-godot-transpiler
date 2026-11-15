import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldConsumeProof.gd'
REPAIR_TURRET_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldConsumeProof.tscn'


class C07RepairTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_repair_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2212']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state')
        # N2174 gave the repair turret its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO target state on the
        # repair-turret frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- with no target requestedPower
        # is 0 so power.status reads 1.0 while Java efficiency is
        # 0. RepairPointBuild overrides shouldConsume
        # (RepairTurret.java:221-223): `return target != null &&
        # enabled;` -- the gate reads the live target AND the
        # enabled flag. The field is `public Unit target;`
        # (RepairTurret.java:154) on RepairPointBuild (`public
        # class RepairPointBuild extends Building implements
        # Ranged, RotBlock{`, RepairTurret.java:153). N2212 wires
        # the gate into the repair turret's OWN driver
        # (SourceRepairTurretBuildState.gd, frame key
        # "source_repair_turret_building"): the frame gets a
        # `target` key (default null, the Java field default),
        # the pure gate returns `target != null && enabled`
        # plus the null-ness it read, and the driver feeds
        # should_consume to the machinery, so a repair turret
        # with no target folds efficiency 0 like Java. No live
        # fill sets frame["target"] yet -- the gate reads the
        # frame as-is, and the live target acquire
        # (Units.closest + clear when dead / out of range /
        # full health) waits for its own slice (new deferral).
        # Two new result symbols: the gate and the has_target
        # flag it reads.
        self.assertEqual(
            ledger['N2212']['source_symbols'],
            [
                'source_repair_turret_should_consume_state_result.should_consume',
                'source_repair_turret_should_consume_state_result.has_target',
            ],
        )
        for name in ledger['N2212']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTurret.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_should_consume_state_result.should_consume': 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state',
                    'source_repair_turret_should_consume_state_result.has_target': 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2212']['runtime_proof'], '/root/C07RepairTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2212']['tests'],
            [
                'test_c07_repair_turret_should_consume_registration',
                'test_all_c07_repair_turret_should_consume_input_evidence_is_exact',
                'test_repair_turret_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_repair_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2212']['deferred_exprs'])
        # This slice resolves the N2174 RepairTurret gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, coolant row, draw rows,
        # read/write rows, status/range rows, and per-def stat
        # rows stay deferred.
        self.assertFalse(any(entry.startswith('RepairTurret shouldConsume gate (') for entry in ledger['N2212']['deferred_exprs']))

    def test_all_c07_repair_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2212']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_should_consume_state_result.should_consume': 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state',
                    'source_repair_turret_should_consume_state_result.has_target': 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2212']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_should_consume_gate_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the repair-turret build
        # state: RepairPointBuild.shouldConsume()
        # (RepairTurret.java:221, `public boolean
        # shouldConsume(){` with `return target != null &&
        # enabled;`, RepairTurret.java:222) -- the gate reads
        # the live target AND the enabled flag. The field is
        # `public Unit target;` (RepairTurret.java:154) on
        # RepairPointBuild (`public class RepairPointBuild
        # extends Building implements Ranged, RotBlock{`,
        # RepairTurret.java:153); RepairTurret extends Block
        # (RepairTurret.java:25, `public class RepairTurret
        # extends Block{`), so the default (`return enabled;`,
        # BuildingComp.java:755-756) does not apply here.
        # Unlike the UnitCargoLoader gate (N2211) this one HAS
        # `&& enabled` -- the pure gate reads frame["enabled"]
        # too (the ItemBridge N2188 precedent: the override
        # includes the enabled check, so the pure function
        # reads both frame keys). When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries the target
        # (frame["target"], default null for a frame bound
        # before this slice -- the Java field default); no live
        # fill sets it yet -- the live target acquire
        # (Units.closest, RepairTurret.java:216, `target =
        # Units.closest(team, x, y, repairRadius,
        # Unit::damaged);`, every 20 ticks, RepairTurret.java:
        # 214, plus the clear when dead / out of range / full
        # health, RepairTurret.java:193-194) is the updateTile
        # advance (RepairTurret.java:187-218) and waits for its
        # own slice. The heal advance (RepairTurret.java:207,
        # `target.heal(repairSpeed * strength * edelta() *
        # multiplier);`) follows the folded efficiency. The
        # power consumer is conditional: `consumePowerCond(
        # powerUse, (RepairPointBuild entity) -> entity.target
        # != null);` (RepairTurret.java:89) -- the two defs
        # carry powerUse 1f (repair-point, Blocks.java:6391,
        # `powerUse = 1f;`) and 5f (repair-turret,
        # Blocks.java:6402, `powerUse = 5f;`).
        self.assertIn('static func source_repair_turret_should_consume_state', repair_turret)
        self.assertIn('"should_consume": target != null and enabled', repair_turret)
        self.assertIn('"has_target": target != null', repair_turret)
        self.assertIn('public boolean shouldConsume(){', repair_turret)
        self.assertIn('return target != null && enabled;', repair_turret)
        self.assertIn('public Unit target;', repair_turret)
        self.assertIn('public class RepairPointBuild extends Building implements Ranged, RotBlock{', repair_turret)
        self.assertIn('public class RepairTurret extends Block{', repair_turret)
        self.assertIn('return enabled;', repair_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_turret)
        self.assertIn('if(!update){', repair_turret)
        self.assertIn('target = Units.closest(team, x, y, repairRadius, Unit::damaged);', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        self.assertIn('consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);', repair_turret)
        self.assertIn('powerUse = 1f;', repair_turret)
        self.assertIn('powerUse = 5f;', repair_turret)
        self.assertIn('"target": null', repair_turret)
        self.assertIn('frame["target"]', repair_turret)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame target key and the gate call
        # feeds should_consume into the fold.
        self.assertIn('static func source_repair_turret_tick_buildings_state', repair_turret)
        self.assertIn('source_repair_turret_should_consume_state(frame)', repair_turret)
        self.assertIn('bool(gate.get("should_consume", true))', repair_turret)
        # The documented limits record the gate as live; the old
        # N2174 deferral text is gone. The N2174 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2212)', repair_turret)
        self.assertNotIn('runs with should_consume=true when enabled', repair_turret)
        self.assertNotIn('tracks no live target on any placed-building frame', repair_turret)
        self.assertIn('static func source_repair_turret_power_status_row_state', repair_turret)
        # The proof's keys drive the pure gate (true when a
        # target is present and enabled, false when the target
        # is null, false when disabled -- the gate HAS `&&
        # enabled`) plus the live tick (efficiency 0 when the
        # gate is false, the N2174 power fold preserved when
        # the gate is true) plus the fresh frame default
        # (target null on bind). There are no heal / strength /
        # rotation / acquire keys: the updateTile advance
        # (RepairTurret.java:187-218) waits for its own slice,
        # so the heal advance (RepairTurret.java:207) is what
        # the efficiency keys prove. Static checks: the proof
        # preloads the repair-turret state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = REPAIR_TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_target_present',
            'gate_false_when_target_null',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_target_default_null',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRepairTurretBuildState.gd")', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_should_consume_state(', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REPAIR_TURRET_STATE.is_file())
        scene = REPAIR_TURRET_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTurretShouldConsumeProof.gd', scene)
        self.assertTrue(REPAIR_TURRET_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_repair_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_target_present',
            'gate_false_when_target_null',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_target_default_null',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
