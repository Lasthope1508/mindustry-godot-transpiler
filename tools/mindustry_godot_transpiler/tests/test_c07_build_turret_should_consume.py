import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretShouldConsumeProof.gd'


class C07BuildTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_build_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2201']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_should_consume_state')
        # N2184 folded power-only for the build tower: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # BuildTurretBuild DOES override shouldConsume:
        # `return unit.plans().size > 0 && !isHealSuppressed();`
        # (BuildTurret.java:230), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1993,
        # `if(!update){` / `efficiency = optionalEfficiency =
        # 0f;`). N2184 deferred the gate with a documented limit
        # (the PointDefenseTurret N2151 precedent): the port
        # tracked no live build-plan state on any placed-building
        # frame, so with no plans requestedPower is 0 so
        # power.status reads 1.0 while Java efficiency is 0 --
        # the observable gap is efficiency 1.0 vs 0.0 with no
        # plans. N2201 closes that gap with one pure function
        # over two new frame keys (`plans_count`, int, and
        # `heal_suppressed`, bool): the gate is the same
        # expression over the observed plans,
        # `unit.plans().size > 0 && !isHealSuppressed()`, and the
        # tower's power draw is STATIC (consumePower 3f,
        # Blocks.java:2005), so unlike the repair turret the
        # power row reads 0.5 even with no plans -- the gate is
        # the only thing zeroing efficiency. RED decision (pinned
        # by this slice, the proof's fourth key): when the frame
        # carries NO `plans_count` key, preserve the N2184
        # behavior (`should_consume = enabled`) -- null means "no
        # observation yet", not "no plans", because no
        # placed-building frame carries live build plans today
        # and defaulting absent to false would zero efficiency
        # for every live build tower, a live regression against
        # N2184 GREEN. The gate therefore activates when the
        # future plan-acquisition slice stamps `plans_count`
        # from `unit.plans().size` (BuildTurret.java:230). The
        # `heal_suppressed` observation defaults to false when
        # absent: suppression is a transient timed state
        # (`block.suppressable && Time.time <=
        # healSuppressionTime`, BuildingComp.java:487-489), and
        # no slice stamps it yet -- the future suppression slice
        # owns live stamping of it (the canonical
        # is_heal_suppressed_state already exists in
        # SourceBuildingLifecycleState.gd). One new result
        # symbol: the gate itself.
        self.assertEqual(
            ledger['N2201']['source_symbols'],
            [
                'source_build_turret_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2201']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_build_turret_should_consume_state_result.should_consume': 'SourceBuildTurretBuildState.source_build_turret_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2201']['runtime_proof'], '/root/C07BuildTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2201']['tests'],
            [
                'test_c07_build_turret_should_consume_registration',
                'test_all_c07_build_turret_should_consume_input_evidence_is_exact',
                'test_build_turret_should_consume_state',
                'test_reference_graph_and_actual_c07_build_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2201']['deferred_exprs'])

    def test_all_c07_build_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2201']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_build_turret_should_consume_state_result.should_consume': 'SourceBuildTurretBuildState.source_build_turret_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2201']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_should_consume_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The pure shouldConsume gate lives on the build-turret
        # build state: BuildTurretBuild overrides shouldConsume
        # (BuildTurret.java:229, `public boolean
        # shouldConsume(){` with `return unit.plans().size > 0
        # && !isHealSuppressed();`, BuildTurret.java:230) over
        # the builder unit's plan queue (BuildTurret.java:93,
        # `public BlockUnitc unit =
        # (BlockUnitc)unitType.create(team);`), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update
        # = shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The suppression conjunct
        # is isHealSuppressed() (BuildingComp.java:487, `public
        # boolean isHealSuppressed(){` with `return
        # block.suppressable && Time.time <=
        # healSuppressionTime;`, BuildingComp.java:488); the
        # tower is suppressable (BuildTurret.java:46,
        # `suppressable = true;`). A missing power stamp folds
        # to 1.0 before the first graph update, the assembler
        # fold (UnitAssembler.java:469, `float powerStatus =
        # !enabled ? 0f : power == null ? 1f : power.status;`),
        # and the power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency * delta();`).
        # The default shouldConsume is `return enabled;`
        # (BuildingComp.java:755-756).
        self.assertIn('static func source_build_turret_should_consume_state', build_turret)
        # The gate cases, pinned as the pure function's
        # decision structure: the frame carries the live plans
        # observation as `plans_count` (int) and the suppression
        # observation as `heal_suppressed` (bool); the function
        # reads plans_count with a null default, so an absent key
        # means "no observation yet", not "no plans".
        # plans_count=0 blocks the gate (should_consume false);
        # plans_count>0 with enabled passes it (should_consume
        # true); plans_count>0 with enabled=false blocks it
        # (should_consume false); plans_count>0 with
        # heal_suppressed=true blocks it (should_consume false)
        # -- all observed cases run through the one conjunction,
        # `int(plans_count) > 0 and not heal_suppressed and
        # enabled`; NO plans_count key preserves the N2184
        # behavior, `should_consume = enabled`.
        self.assertIn('frame.get("plans_count", null)', build_turret)
        with self.subTest(case='plans_count=0 blocks the gate'):
            self.assertIn('int(plans_count) > 0', build_turret)
        with self.subTest(case='plans_count>0 with enabled passes the gate'):
            self.assertIn('int(plans_count) > 0 and not heal_suppressed and enabled', build_turret)
        with self.subTest(case='plans_count>0 with enabled=false blocks the gate'):
            self.assertIn('int(plans_count) > 0 and not heal_suppressed and enabled', build_turret)
        with self.subTest(case='plans_count>0 with heal_suppressed=true blocks the gate'):
            self.assertIn('not heal_suppressed', build_turret)
        with self.subTest(case='no plans_count key preserves N2184 behavior'):
            self.assertIn('return {"should_consume": enabled}', build_turret)
        self.assertIn('public boolean shouldConsume(){', build_turret)
        self.assertIn('return unit.plans().size > 0 && !isHealSuppressed();', build_turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)unitType.create(team);', build_turret)
        self.assertIn('public boolean isHealSuppressed(){', build_turret)
        self.assertIn('return block.suppressable && Time.time <= healSuppressionTime;', build_turret)
        self.assertIn('suppressable = true;', build_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', build_turret)
        self.assertIn('if(!update){', build_turret)
        self.assertIn('efficiency = optionalEfficiency = 0f;', build_turret)
        self.assertIn('return efficiency * delta();', build_turret)
        self.assertIn('return build.power.status;', build_turret)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', build_turret)
        self.assertIn('hasConsumers = consumers.length > 0;', build_turret)
        self.assertIn('return enabled;', build_turret)
        # The proof's keys drive the pure gate (blocks without
        # plans / passes with plans / blocks when disabled /
        # absent key preserves the power fold / blocks when heal
        # suppressed) plus the live tick (the gate overrides the
        # power fold). There are no plan-search / mimic /
        # validate / updateBuildLogic keys: the plan advance
        # (BuildTurret.java:156-225) waits for its own slice,
        # and the future plan-acquisition slice owns live
        # stamping of `plans_count`.
        proof = BUILD_TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_blocks_without_plans',
            'gate_passes_with_plans',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_blocks_when_heal_suppressed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_blocks_without_plans',
            'gate_passes_with_plans',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_blocks_when_heal_suppressed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
