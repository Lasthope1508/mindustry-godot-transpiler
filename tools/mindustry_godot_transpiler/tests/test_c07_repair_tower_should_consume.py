import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerShouldConsumeProof.gd'
REPAIR_TOWER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerShouldConsumeProof.tscn'


class C07RepairTowerShouldConsumeTests(unittest.TestCase):
    def test_c07_repair_tower_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2213']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state')
        # N2176 gave the repair tower its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO target state on the
        # repair-tower frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- with no targets power.status
        # reads 1.0 while Java efficiency is 0. RepairTowerBuild
        # overrides shouldConsume (RepairTower.java:89-91):
        # `return targets.size > 0;` -- the tower consumes only
        # while it has at least one damaged unit in range. The
        # field is `public Seq<Unit> targets = new Seq<>();`
        # (RepairTower.java:54) on RepairTowerBuild (`public class
        # RepairTowerBuild extends Building implements Ranged{`,
        # RepairTower.java:46). N2213 wires the gate into the
        # repair-tower's OWN driver
        # (SourceRepairTowerBuildState.gd, frame key
        # "source_repair_tower_building"): the frame gets a
        # `targets` key (default [], the Java field initializer),
        # the pure gate returns `targets.size > 0` plus the target
        # count it read, and the driver feeds `should_consume =
        # targets.size > 0` to the machinery, so a tower with no
        # targets folds efficiency 0 like Java. No live refresh
        # fills frame["targets"] yet -- the gate reads the frame
        # as-is, and the periodic Units.nearby refresh waits for
        # its own slice (new deferral). Two new result symbols:
        # the gate and the target count it reads.
        self.assertEqual(
            ledger['N2213']['source_symbols'],
            [
                'source_repair_tower_should_consume_state_result.should_consume',
                'source_repair_tower_should_consume_state_result.target_count',
            ],
        )
        for name in ledger['N2213']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTower.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_should_consume_state_result.should_consume': 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state',
                    'source_repair_tower_should_consume_state_result.target_count': 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2213']['runtime_proof'], '/root/C07RepairTowerShouldConsumeProof')
        self.assertEqual(
            ledger['N2213']['tests'],
            [
                'test_c07_repair_tower_should_consume_registration',
                'test_all_c07_repair_tower_should_consume_input_evidence_is_exact',
                'test_repair_tower_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_repair_tower_should_consume',
            ],
        )
        self.assertTrue(ledger['N2213']['deferred_exprs'])
        # This slice resolves the N2176 RepairTower gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, liquid ozone row,
        # suppression, draw, and per-def stat rows stay deferred.
        self.assertFalse(any(entry.startswith('RepairTower shouldConsume gate (') for entry in ledger['N2213']['deferred_exprs']))

    def test_all_c07_repair_tower_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2213']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_should_consume_state_result.should_consume': 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state',
                    'source_repair_tower_should_consume_state_result.target_count': 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2213']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_should_consume_gate_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the repair-tower build
        # state: RepairTowerBuild.shouldConsume()
        # (RepairTower.java:89, `public boolean
        # shouldConsume(){` with `return targets.size > 0;`,
        # RepairTower.java:90) -- the tower consumes only
        # while at least one damaged unit is in range. The
        # field is `public Seq<Unit> targets = new Seq<>();`
        # (RepairTower.java:54) on RepairTowerBuild
        # (`public class RepairTowerBuild extends Building
        # implements Ranged{`, RepairTower.java:46);
        # RepairTower extends Block (RepairTower.java:18,
        # `public class RepairTower extends Block{`), so the
        # default (`return enabled;`, BuildingComp.java:755-756)
        # does not apply here. Unlike the Separator/Drill
        # gates this one has NO `&& enabled` -- Java returns
        # the bare size check, so the pure gate does NOT read
        # frame["enabled"] at all (the driver already runs the
        # machinery only when enabled). When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries the targets
        # (frame["targets"], default [] for a frame bound
        # before this slice -- the Java field initializer is
        # `new Seq<>()`); no live refresh fills it yet -- the
        # periodic refresh (RepairTower.java:59, `if
        # (potentialEfficiency > 0 && (refresh += Time.delta)
        # >= refreshInterval){` with `static final float
        # refreshInterval = 6f;`, RepairTower.java:19, and
        # `Units.nearby(team, x, y, range, damaged)`) is the
        # updateTile advance (RepairTower.java:57-86) and
        # waits for its own slice. The heal advance
        # (RepairTower.java:78, `target.heal(healAmount *
        # edelta());`) follows the folded efficiency. The def
        # consumes power 1f (`consumePower(1f);`,
        # Blocks.java:6582) plus liquid ozone 3f/60f
        # (`consumeLiquid(Liquids.ozone, 3f / 60f);`,
        # Blocks.java:6583) -- the liquid row waits for its own
        # slice.
        self.assertIn('static func source_repair_tower_should_consume_state', repair_tower)
        self.assertIn('"should_consume": targets.size() > 0', repair_tower)
        self.assertIn('"target_count": targets.size()', repair_tower)
        self.assertIn('public boolean shouldConsume(){', repair_tower)
        self.assertIn('return targets.size > 0;', repair_tower)
        self.assertIn('public Seq<Unit> targets = new Seq<>();', repair_tower)
        self.assertIn('public class RepairTowerBuild extends Building implements Ranged{', repair_tower)
        self.assertIn('public class RepairTower extends Block{', repair_tower)
        self.assertIn('return enabled;', repair_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_tower)
        self.assertIn('if(!update){', repair_tower)
        self.assertIn('static final float refreshInterval = 6f;', repair_tower)
        self.assertIn('if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', repair_tower)
        self.assertIn('target.heal(healAmount * edelta());', repair_tower)
        self.assertIn('consumePower(1f);', repair_tower)
        self.assertIn('consumeLiquid(Liquids.ozone, 3f / 60f);', repair_tower)
        self.assertIn('"targets": []', repair_tower)
        self.assertIn('frame["targets"]', repair_tower)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame targets key and the gate call
        # feeds should_consume into the fold.
        self.assertIn('static func source_repair_tower_tick_buildings_state', repair_tower)
        self.assertIn('source_repair_tower_should_consume_state(frame)', repair_tower)
        self.assertIn('bool(gate.get("should_consume", true))', repair_tower)
        # The documented limits record the gate as live; the old
        # N2176 deferral text is gone. The N2176 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2213)', repair_tower)
        self.assertNotIn('runs with should_consume=true when enabled', repair_tower)
        self.assertNotIn('the port tracks no live target on any placed-building frame', repair_tower)
        self.assertIn('static func source_repair_tower_power_status_row_state', repair_tower)
        # The proof's keys drive the pure gate (true when the
        # targets list is non-empty, false when it is empty, and
        # independent of enabled) plus the live tick (efficiency
        # 0 when the gate is false, the N2176 power fold
        # preserved when the gate is true) plus the fresh frame
        # default (targets [] on bind). There are no
        # warmup / progress / refresh / liquid keys: the
        # updateTile advance (RepairTower.java:57-86) waits for
        # its own slice, so the heal advance (RepairTower.java:78)
        # is what the efficiency keys prove. Static checks: the
        # proof preloads the repair-tower state file that
        # exists, and the scene file references the proof script
        # that exists.
        proof = REPAIR_TOWER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_targets_nonempty',
            'gate_false_when_targets_empty',
            'gate_independent_of_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_targets_default_empty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRepairTowerBuildState.gd")', proof)
        self.assertIn('repair_tower_build_state.source_repair_tower_should_consume_state(', proof)
        self.assertIn('repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REPAIR_TOWER_STATE.is_file())
        scene = REPAIR_TOWER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTowerShouldConsumeProof.gd', scene)
        self.assertTrue(REPAIR_TOWER_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_repair_tower_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_targets_nonempty',
            'gate_false_when_targets_empty',
            'gate_independent_of_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_targets_default_empty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
