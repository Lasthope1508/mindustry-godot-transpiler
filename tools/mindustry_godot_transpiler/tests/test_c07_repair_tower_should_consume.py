import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerShouldConsumeProof.gd'


class C07RepairTowerShouldConsumeTests(unittest.TestCase):
    def test_c07_repair_tower_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2191']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state')
        # N2176 folded power-only for the repair tower: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # RepairTowerBuild DOES override shouldConsume:
        # `return targets.size > 0;`
        # (RepairTower.java:90), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1993,
        # `if(!update){` / `efficiency = optionalEfficiency =
        # 0f;`). N2176 deferred the gate with a documented limit
        # (the PointDefenseTurret N2151 precedent): the port
        # tracked no live target on any placed-building frame, so
        # with no targets requestedPower is 0 so power.status reads
        # 1.0 while Java efficiency is 0 -- the observable gap is
        # efficiency 1.0 vs 0.0 with no targets. N2190 stamped the
        # prerequisite count: the refresh block is the ONLY writer
        # of `targets` (RepairTower.java:59-66) and stamps
        # `targets_count` on refresh expiry when a
        # `nearby_damaged_units` observation exists. N2191 closes
        # the gap with one pure function over that one frame key
        # (`targets_count`, int): the gate is the same expression
        # over the observed count, `targets.size > 0`, read as
        # `targets_count > 0 && enabled`. RED decision (pinned by
        # this slice, the proof's fourth key -- the N2188
        # `has_target` precedent): when the frame carries NO
        # `targets_count` key, preserve the N2176 behavior
        # (`should_consume = enabled`) -- null means "no
        # observation yet", not "no targets", because no
        # placed-building frame carries a live targets count until
        # the live-units query slice stamps
        # `nearby_damaged_units`, and defaulting absent to false
        # would zero efficiency for every live repair tower, a
        # live regression against N2176 GREEN. The gate therefore
        # activates when a refresh expiry stamps `targets_count`
        # from the observed count. One new result symbol: the gate
        # itself.
        self.assertEqual(
            ledger['N2191']['source_symbols'],
            [
                'source_repair_tower_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2191']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_should_consume_state_result.should_consume': 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2191']['runtime_proof'], '/root/C07RepairTowerShouldConsumeProof')
        self.assertEqual(
            ledger['N2191']['tests'],
            [
                'test_c07_repair_tower_should_consume_registration',
                'test_all_c07_repair_tower_should_consume_input_evidence_is_exact',
                'test_repair_tower_should_consume_state',
                'test_reference_graph_and_actual_c07_repair_tower_should_consume',
            ],
        )
        self.assertTrue(ledger['N2191']['deferred_exprs'])

    def test_all_c07_repair_tower_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2191']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_should_consume_state_result.should_consume': 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2191']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_should_consume_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The pure shouldConsume gate lives on the repair-tower
        # build state: RepairTowerBuild overrides shouldConsume
        # (RepairTower.java:89, `public boolean
        # shouldConsume(){` with `return targets.size > 0;`,
        # RepairTower.java:90) over the target list
        # (RepairTower.java:49, `public Seq<Unit> targets = new
        # Seq<>();`), which the refresh block alone writes
        # (RepairTower.java:59-66, `targets.clear();` /
        # `refresh = 0f;` / `targets.add(u);`), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update
        # = shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The gate matters because
        # with no targets Java efficiency is 0 while the port
        # folds power-only and reports 1.0 -- the N2176 gap this
        # slice closes once the frame carries the N2190 stamped
        # count. A missing power stamp folds to 1.0 before the
        # first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`), and the
        # power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency * delta();`).
        # The repair tower's power draw is STATIC, not
        # conditional: `consumePower(1f);` (Blocks.java:6582)
        # registers a plain ConsumePower, so the row read is the
        # plain one (ConsumePower.java:39, `return
        # build.power.status;`) -- no RepairTurret-style
        # ConsumePowerCondition adaptation. The gate reads the
        # potentialEfficiency stamped by THIS tick's
        # updateConsumption (BuildingComp.java:1989,
        # `potentialEfficiency = efficiency;`) only through the
        # refresh, not directly: the shouldConsume gate reads
        # the targets list the refresh last stamped, so the
        # driver calls the pure gate BEFORE the consumption
        # setup (the Java order, updateConsumption :2274 reads
        # shouldConsume() at :1960) and AFTER the previous
        # tick's refresh stamped `targets_count`.
        self.assertIn('static func source_repair_tower_should_consume_state', repair_tower)
        # The four gate cases, pinned as the pure function's
        # decision structure: the frame carries the live targets
        # observation as `targets_count` (int, stamped by the
        # N2190 refresh on expiry when an observation exists);
        # the function reads it with a null default, so an absent
        # key means "no observation yet", not "no targets".
        # targets_count=0 blocks the gate (should_consume false);
        # targets_count>0 with enabled passes it (should_consume
        # true); targets_count>0 with enabled=false blocks it
        # (should_consume false) -- all three observed cases run
        # through the one conjunction, `int(observed) > 0 and
        # enabled`; NO targets_count key preserves the N2176
        # behavior, `should_consume = enabled`.
        self.assertIn('frame.get("targets_count", null)', repair_tower)
        with self.subTest(case='targets_count=0 blocks the gate'):
            self.assertIn('int(observed) > 0 and enabled', repair_tower)
        with self.subTest(case='targets_count>0 with enabled passes the gate'):
            self.assertIn('int(observed) > 0 and enabled', repair_tower)
        with self.subTest(case='targets_count>0 with enabled=false blocks the gate'):
            self.assertIn('int(observed) > 0 and enabled', repair_tower)
        with self.subTest(case='no targets_count key preserves N2176 behavior'):
            self.assertIn('return {"should_consume": enabled}', repair_tower)
        self.assertIn('public boolean shouldConsume(){', repair_tower)
        self.assertIn('return targets.size > 0;', repair_tower)
        self.assertIn('public Seq<Unit> targets = new Seq<>();', repair_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_tower)
        self.assertIn('if(!update){', repair_tower)
        self.assertIn('efficiency = optionalEfficiency = 0f;', repair_tower)
        self.assertIn('return efficiency * delta();', repair_tower)
        self.assertIn('return build.power.status;', repair_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', repair_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', repair_tower)
        self.assertIn('consumePower(1f);', repair_tower)
        self.assertIn('targets.clear();', repair_tower)
        self.assertIn('refresh = 0f;', repair_tower)
        self.assertIn('targets.add(u);', repair_tower)
        self.assertIn('potentialEfficiency = efficiency;', repair_tower)
        self.assertIn('source_repair_tower_should_consume_state(frame)', repair_tower)
        # The proof's keys drive the pure gate (blocks without
        # targets / passes with targets / blocks when disabled /
        # absent key preserves the power fold / passes with
        # targets and no power stamp) plus the live tick (the gate
        # overrides the power fold). There are no heal / warmup /
        # totalProgress / Units.nearby-query keys: the heal loop +
        # warmup lerp + totalProgress advance (RepairTower.java:67-86)
        # and the live query (RepairTower.java:61-65) wait for
        # their own slices, and the future live-units query slice
        # owns live stamping of `nearby_damaged_units`.
        proof = REPAIR_TOWER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_blocks_without_targets',
            'gate_passes_with_targets',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_passes_with_targets_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

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
            'gate_blocks_without_targets',
            'gate_passes_with_targets',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_passes_with_targets_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
