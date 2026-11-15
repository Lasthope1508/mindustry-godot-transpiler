import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretShouldConsumeProof.gd'
BUILD_TURRET_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretShouldConsumeProof.tscn'


class C07BuildTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_build_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2215']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_should_consume_state')
        # N2184 gave the build tower its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO build-plan state on the
        # build-turret frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- with no plans requestedPower
        # is 0 so power.status reads 1.0 while Java efficiency is
        # 0. BuildTurretBuild overrides shouldConsume
        # (BuildTurret.java:229-231): `return unit.plans().size >
        # 0 && !isHealSuppressed();` -- TWO conditions: the
        # builder unit's plan queue must be non-empty AND the
        # building must not be heal-suppressed.
        # isHealSuppressed() (BuildingComp.java:487-489) returns
        # `block.suppressable && Time.time <=
        # healSuppressionTime;`, set through applyHealSuppression
        # (BuildingComp.java:482-485); BuildTurret has
        # `suppressable = true;` (BuildTurret.java:46), so the
        # second term is live, not dead. N2215 wires the gate
        # into the build turret's OWN driver
        # (SourceBuildTurretBuildState.gd, frame key
        # "source_build_turret_building"): the frame gets a
        # `plans` key (default [], the builder unit's plan queue
        # mirrored as an Array of plan dicts) and a
        # `heal_suppressed` key (default false, the
        # isHealSuppressed() mirror), the pure gate returns
        # `plans.size() > 0 and not heal_suppressed` plus the
        # plan count it read, and the driver feeds
        # should_consume to the machinery, so a build tower with
        # no plans (or while heal-suppressed) folds efficiency 0
        # like Java. `heal_suppressed` is read internal, NOT a
        # result symbol (the N2212 precedent: `enabled` is read
        # internal). No live fill sets frame["plans"] or
        # frame["heal_suppressed"] yet -- the gate reads the
        # frame as-is, and the live plan search / mimic /
        # validate (BuildTurret.java:156-225) plus the heal
        # suppression application (BuildingComp.java:482-485)
        # wait for their own slice (new deferral). Two new
        # result symbols: the gate and the plan_count it reads.
        self.assertEqual(
            ledger['N2215']['source_symbols'],
            [
                'source_build_turret_should_consume_state_result.should_consume',
                'source_build_turret_should_consume_state_result.plan_count',
            ],
        )
        for name in ledger['N2215']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_build_turret_should_consume_state_result.should_consume': 'SourceBuildTurretBuildState.source_build_turret_should_consume_state',
                    'source_build_turret_should_consume_state_result.plan_count': 'SourceBuildTurretBuildState.source_build_turret_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2215']['runtime_proof'], '/root/C07BuildTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2215']['tests'],
            [
                'test_c07_build_turret_should_consume_registration',
                'test_all_c07_build_turret_should_consume_input_evidence_is_exact',
                'test_build_turret_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_build_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2215']['deferred_exprs'])
        # This slice resolves the N2184 BuildTurret gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, liquid consumer row,
        # suppression rows, unit rows, plan search / mimic /
        # validation rows, draw / read / write / sense rows, and
        # per-def stat rows stay deferred.
        self.assertFalse(any(entry.startswith('BuildTurret shouldConsume gate (') for entry in ledger['N2215']['deferred_exprs']))

    def test_all_c07_build_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2215']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_build_turret_should_consume_state_result.should_consume': 'SourceBuildTurretBuildState.source_build_turret_should_consume_state',
                    'source_build_turret_should_consume_state_result.plan_count': 'SourceBuildTurretBuildState.source_build_turret_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2215']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_should_consume_gate_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the build-turret build
        # state: BuildTurretBuild.shouldConsume()
        # (BuildTurret.java:229, `public boolean
        # shouldConsume(){` with `return unit.plans().size > 0
        # && !isHealSuppressed();`, BuildTurret.java:230) --
        # TWO conditions: the builder unit's plan queue must be
        # non-empty AND the building must not be
        # heal-suppressed. The unit is `public BlockUnitc unit
        # = (BlockUnitc)unitType.create(team);`
        # (BuildTurret.java:93) on BuildTurretBuild (`public
        # class BuildTurretBuild extends BaseTurretBuild
        # implements ControlBlock, RotBlock{`,
        # BuildTurret.java:92); BuildTurret extends BaseTurret
        # (BuildTurret.java:27, `public class BuildTurret
        # extends BaseTurret{`), so the default (`return
        # enabled;`, BuildingComp.java:755-756) does not apply
        # here -- and unlike the RepairTurret gate (N2212)
        # this one has NO `&& enabled` term, so the pure gate
        # does NOT read frame["enabled"] at all (the driver
        # already runs the machinery only when enabled).
        # isHealSuppressed() (BuildingComp.java:487, `public
        # boolean isHealSuppressed(){` with `return
        # block.suppressable && Time.time <=
        # healSuppressionTime;`, BuildingComp.java:488) is set
        # through applyHealSuppression (BuildingComp.java:482,
        # `public void applyHealSuppression(float amount, Color
        # suppressColor){` with `healSuppressionTime =
        # Math.max(healSuppressionTime, Time.time + amount);`,
        # BuildingComp.java:483); BuildTurret has
        # `suppressable = true;` (BuildTurret.java:46), so the
        # second term is live. NOTE: checkSuppression() in
        # updateTile (BuildTurret.java:132,
        # `if(checkSuppression()){` with `efficiency =
        # potentialEfficiency = 0f;`, BuildTurret.java:133) is
        # a DIFFERENT gate -- it zeroes efficiency directly
        # and is NOT part of this slice. When the shouldConsume
        # gate is false updateConsumption forces efficiency to
        # zero (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries the plans
        # (frame["plans"], default [] for a frame bound before
        # this slice -- the unit's plan queue starts empty)
        # and the suppression mirror (frame["heal_suppressed"],
        # default false); no live fill sets either yet -- the
        # plan search / mimic / validate (BuildTurret.java:
        # 156-225) and the heal suppression application
        # (BuildingComp.java:482-485) are the updateTile
        # advance and wait for their own slice. The single def
        # is build-tower (size 3, range 200f, buildSpeed 1.5f,
        # consumePower 3f, consumeLiquid nitrogen 3f/60f,
        # Blocks.java:1997-2006) -- nitrogen is a second
        # consumer and NOT part of this slice.
        self.assertIn('static func source_build_turret_should_consume_state', build_turret)
        self.assertIn('"should_consume": plans.size() > 0 and not heal_suppressed', build_turret)
        self.assertIn('"plan_count": plans.size()', build_turret)
        self.assertIn('public boolean shouldConsume(){', build_turret)
        self.assertIn('return unit.plans().size > 0 && !isHealSuppressed();', build_turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)unitType.create(team);', build_turret)
        self.assertIn('public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{', build_turret)
        self.assertIn('public class BuildTurret extends BaseTurret{', build_turret)
        self.assertIn('public boolean isHealSuppressed(){', build_turret)
        self.assertIn('return block.suppressable && Time.time <= healSuppressionTime;', build_turret)
        self.assertIn('suppressable = true;', build_turret)
        self.assertIn('public void applyHealSuppression(float amount, Color suppressColor){', build_turret)
        self.assertIn('healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);', build_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', build_turret)
        self.assertIn('if(!update){', build_turret)
        self.assertIn('return enabled;', build_turret)
        self.assertIn('consumePower(3f);', build_turret)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 3f / 60f);', build_turret)
        self.assertIn('buildSpeed = 1.5f;', build_turret)
        self.assertIn('range = 200f;', build_turret)
        self.assertIn('if(checkSuppression()){', build_turret)
        self.assertIn('efficiency = potentialEfficiency = 0f;', build_turret)
        self.assertIn('"plans": []', build_turret)
        self.assertIn('"heal_suppressed": false', build_turret)
        self.assertIn('frame["plans"]', build_turret)
        self.assertIn('frame["heal_suppressed"]', build_turret)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame plans key and the
        # heal_suppressed key and the gate call feeds
        # should_consume into the fold.
        self.assertIn('static func source_build_turret_tick_buildings_state', build_turret)
        self.assertIn('source_build_turret_should_consume_state(frame)', build_turret)
        self.assertIn('bool(gate.get("should_consume", true))', build_turret)
        # The documented limits record the gate as live; the old
        # N2184 deferral text is gone. The N2184 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2215)', build_turret)
        self.assertNotIn('fold power-only and defer the gate', build_turret)
        self.assertNotIn('tracks no live build-plan state on any placed-building frame', build_turret)
        self.assertNotIn('on live build plans, which the port tracks on no placed-building frame', build_turret)
        self.assertIn('static func source_build_turret_power_status_row_state', build_turret)
        # The proof's keys drive the pure gate (true when plans
        # are present and not suppressed, false when the plan
        # list is empty, false when heal-suppressed -- the gate
        # has TWO conditions) plus the live tick (efficiency 0
        # when the gate is false, the N2184 power fold preserved
        # when the gate is true) plus the fresh frame defaults
        # (plans [] and heal_suppressed false on bind). There
        # are no plan search / mimic / validate / build keys:
        # the updateTile advance (BuildTurret.java:156-225)
        # waits for its own slice, so the build-speed fold
        # (BuildTurret.java:136) is what the efficiency keys
        # prove. Static checks: the proof preloads the
        # build-turret state file that exists, and the scene
        # file references the proof script that exists.
        proof = BUILD_TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_plans_nonempty',
            'gate_false_when_plans_empty',
            'gate_false_when_heal_suppressed',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_plans_default_empty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertIn('build_turret_build_state.source_build_turret_should_consume_state(', proof)
        self.assertIn('build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(BUILD_TURRET_STATE.is_file())
        scene = BUILD_TURRET_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BuildTurretShouldConsumeProof.gd', scene)
        self.assertTrue(BUILD_TURRET_SHOULD_CONSUME_PROOF.is_file())

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
            'gate_true_when_plans_nonempty',
            'gate_false_when_plans_empty',
            'gate_false_when_heal_suppressed',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_plans_default_empty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
