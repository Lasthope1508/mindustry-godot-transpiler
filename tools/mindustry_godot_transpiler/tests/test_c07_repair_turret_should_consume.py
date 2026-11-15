import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldConsumeProof.gd'


class C07RepairTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_repair_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2188']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state')
        # N2174 folded power-only for the repair turret: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # RepairPointBuild DOES override shouldConsume:
        # `return target != null && enabled;`
        # (RepairTurret.java:222), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1993,
        # `if(!update){` / `efficiency = optionalEfficiency =
        # 0f;`). N2174 deferred the gate with a documented limit
        # (the PointDefenseTurret N2151 precedent): the port
        # tracked no live target on any placed-building frame, so
        # with no target requestedPower is 0 so power.status reads
        # 1.0 while Java efficiency is 0 -- the observable gap is
        # efficiency 1.0 vs 0.0 with no target. N2188 closes that
        # gap with one pure function over one new frame key
        # (`has_target`, bool): the gate is the same expression
        # over the observed target, `target != null && enabled`,
        # and the power draw is conditional on the same field --
        # `consumePowerCond(powerUse, (RepairPointBuild entity) ->
        # entity.target != null);` (RepairTurret.java:89) draws 0
        # when there is no target (ConsumePowerCondition.java:17,
        # `return consume.get(entity) ? usage : 0f;`). RED decision
        # (pinned by this slice, the proof's fourth key): when
        # the frame carries NO `has_target` key, preserve the
        # N2174 behavior (`should_consume = enabled`) -- null
        # means "no observation yet", not "no target", because no
        # placed-building frame carries a live target today and
        # defaulting absent to false would zero efficiency for
        # every live repair turret, a live regression against
        # N2174 GREEN. The gate therefore activates when the
        # future target-acquisition slice stamps `has_target`
        # from `Units.closest(team, x, y, repairRadius,
        # Unit::damaged)` (RepairTurret.java:216) plus the
        # null-out conditions (RepairTurret.java:193-195). One
        # new result symbol: the gate itself.
        self.assertEqual(
            ledger['N2188']['source_symbols'],
            [
                'source_repair_turret_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2188']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_should_consume_state_result.should_consume': 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2188']['runtime_proof'], '/root/C07RepairTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2188']['tests'],
            [
                'test_c07_repair_turret_should_consume_registration',
                'test_all_c07_repair_turret_should_consume_input_evidence_is_exact',
                'test_repair_turret_should_consume_state',
                'test_reference_graph_and_actual_c07_repair_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2188']['deferred_exprs'])

    def test_all_c07_repair_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2188']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_should_consume_state_result.should_consume': 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/world/consumers/ConsumePowerCondition.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2188']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_should_consume_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure shouldConsume gate lives on the repair-turret
        # build state: RepairPointBuild overrides shouldConsume
        # (RepairTurret.java:221, `public boolean
        # shouldConsume(){` with `return target != null &&
        # enabled;`, RepairTurret.java:222) over the target field
        # (RepairTurret.java:154, `public Unit target;`), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update
        # = shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The gate matters because
        # the power draw is conditional on the same field
        # (RepairTurret.java:89, `consumePowerCond(powerUse,
        # (RepairPointBuild entity) -> entity.target != null);`)
        # and ConsumePowerCondition only draws when its
        # condition holds (ConsumePowerCondition.java:17,
        # `return consume.get(entity) ? usage : 0f;`), so with no
        # target power.status reads 1.0 (the row read,
        # ConsumePower.java:39, `return build.power.status;`)
        # while Java efficiency is 0 -- the N2174 gap this slice
        # closes. A missing power stamp folds to 1.0 before the
        # first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`), and the
        # power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency * delta();`).
        self.assertIn('static func source_repair_turret_should_consume_state', repair_turret)
        # The four gate cases, pinned as the pure function's
        # decision structure: the frame carries the live target
        # observation as `has_target` (bool); the function reads
        # it with a null default, so an absent key means "no
        # observation yet", not "no target". has_target=false
        # blocks the gate (should_consume false); has_target=true
        # with enabled passes it (should_consume true);
        # has_target=true with enabled=false blocks it
        # (should_consume false) -- all three observed cases run
        # through the one conjunction, `bool(has_target) and
        # enabled`; NO has_target key preserves the N2174
        # behavior, `should_consume = enabled`.
        self.assertIn('frame.get("has_target", null)', repair_turret)
        with self.subTest(case='has_target=false blocks the gate'):
            self.assertIn('bool(has_target) and enabled', repair_turret)
        with self.subTest(case='has_target=true with enabled passes the gate'):
            self.assertIn('bool(has_target) and enabled', repair_turret)
        with self.subTest(case='has_target=true with enabled=false blocks the gate'):
            self.assertIn('bool(has_target) and enabled', repair_turret)
        with self.subTest(case='no has_target key preserves N2174 behavior'):
            self.assertIn('return {"should_consume": enabled}', repair_turret)
        self.assertIn('public boolean shouldConsume(){', repair_turret)
        self.assertIn('return target != null && enabled;', repair_turret)
        self.assertIn('public Unit target;', repair_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_turret)
        self.assertIn('if(!update){', repair_turret)
        self.assertIn('efficiency = optionalEfficiency = 0f;', repair_turret)
        self.assertIn('return efficiency * delta();', repair_turret)
        self.assertIn('consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);', repair_turret)
        self.assertIn('return consume.get(entity) ? usage : 0f;', repair_turret)
        self.assertIn('return build.power.status;', repair_turret)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', repair_turret)
        self.assertIn('hasConsumers = consumers.length > 0;', repair_turret)
        # The proof's keys drive the pure gate (blocks without
        # target / passes with target / blocks when disabled /
        # absent key preserves the power fold / passes with
        # target and no power stamp) plus the live tick (the gate
        # overrides the power fold). There are no heal / strength
        # / rotation / target-acquisition keys: the updateTile
        # advance (RepairTurret.java:187-218) waits for its own
        # slice, and the future target-acquisition slice owns
        # live stamping of `has_target`.
        proof = REPAIR_TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_blocks_without_target',
            'gate_passes_with_target',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_passes_with_target_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

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
            'gate_blocks_without_target',
            'gate_passes_with_target',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_passes_with_target_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
