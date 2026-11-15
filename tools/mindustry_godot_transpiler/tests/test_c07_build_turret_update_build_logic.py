import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_UPDATE_BUILD_LOGIC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretUpdateBuildLogicProof.gd'
BUILD_TURRET_UPDATE_BUILD_LOGIC_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretUpdateBuildLogicProof.tscn'
BUILDER_COMP = 'core/src/mindustry/entities/comp/BuilderComp.java'
COUNTER_OWNER = 'SourceBuildTurretBuildState.source_build_turret_build_counter_state'
SELECTION_OWNER = 'SourceBuildTurretBuildState.source_build_turret_build_plan_selection_state'


class C07BuildTurretUpdateBuildLogicTests(unittest.TestCase):
    def test_c07_build_turret_update_build_logic_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2272']['godot_owner'], COUNTER_OWNER)
        # N2244 gave the build tower its plan logic (search /
        # mimic / validate / suicide removal,
        # BuildTurret.java:141-225) but the driver never called
        # `unit.updateBuildLogic();` (BuildTurret.java:225) --
        # the build simulation on the builder unit
        # (BuilderComp.updateBuildLogic(), BuilderComp.java:76+)
        # waited for its own slice. N2272 is that simulation
        # minus placement: pure function 1 advances the build
        # counter (`buildCounter += Time.delta;`, NaN/Inf guard
        # to 0f, clamp 10f, the instant/maxPerFrame/run gate)
        # and pure function 2 validates the plans
        # (validatePlans, :57-74) and selects the next plan
        # (the size > 1 rotation loop, :114-146, with
        # shouldSkip, :246-251). Placement
        # (Call.beginPlace / Call.beginBreak / ConstructBuild,
        # :148-222) defers -- world mutation + net + entities
        # the port does not model -- so the driver runs one
        # plan per tick and consumes the counter only when a
        # plan is selected. Eight new result symbols.
        self.assertEqual(
            ledger['N2272']['source_symbols'],
            [
                'source_build_turret_build_counter_state_result.build_counter',
                'source_build_turret_build_counter_state_result.run_build_loop',
                'source_build_turret_build_counter_state_result.iterations_available',
                'source_build_turret_build_counter_state_result.max_per_frame',
                'source_build_turret_build_plan_selection_state_result.plans',
                'source_build_turret_build_plan_selection_state_result.selected',
                'source_build_turret_build_plan_selection_state_result.found_any',
                'source_build_turret_build_plan_selection_state_result.best_index',
            ],
        )
        owners = {
            'source_build_turret_build_counter_state_result.build_counter': COUNTER_OWNER,
            'source_build_turret_build_counter_state_result.run_build_loop': COUNTER_OWNER,
            'source_build_turret_build_counter_state_result.iterations_available': COUNTER_OWNER,
            'source_build_turret_build_counter_state_result.max_per_frame': COUNTER_OWNER,
            'source_build_turret_build_plan_selection_state_result.plans': SELECTION_OWNER,
            'source_build_turret_build_plan_selection_state_result.selected': SELECTION_OWNER,
            'source_build_turret_build_plan_selection_state_result.found_any': SELECTION_OWNER,
            'source_build_turret_build_plan_selection_state_result.best_index': SELECTION_OWNER,
        }
        for name in ledger['N2272']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], BUILDER_COMP)
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2272']['java_source'], BUILDER_COMP)
        self.assertEqual(ledger['N2272']['runtime_proof'], '/root/C07BuildTurretUpdateBuildLogicProof')
        self.assertEqual(
            ledger['N2272']['tests'],
            [
                'test_c07_build_turret_update_build_logic_registration',
                'test_all_c07_build_turret_update_build_logic_input_evidence_is_exact',
                'test_build_turret_update_build_logic_state',
                'test_reference_graph_and_actual_c07_build_turret_update_build_logic',
            ],
        )
        self.assertTrue(ledger['N2272']['deferred_exprs'])
        # DEFERRED: 290 (dynamic-special base) - 1 (the
        # updateBuildLogic rows entry, partially resolved) + 2
        # (the placement-rows rewrite + the live frame inputs
        # entry) = 291.
        self.assertEqual(len(ledger['N2272']['deferred_exprs']), 291)
        self.assertFalse(any(entry.startswith('BuildTurret updateBuildLogic rows (') for entry in ledger['N2272']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret updateBuildLogic placement rows (') for entry in ledger['N2272']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret updateBuildLogic live frame inputs (') for entry in ledger['N2272']['deferred_exprs']))

    def test_all_c07_build_turret_update_build_logic_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2272']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
        slice_sources = {
            'core/src/mindustry/entities/comp/BuilderComp.java',
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/entities/units/BuildPlan.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2272']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_update_build_logic_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The build simulation -- updateBuildLogic live (N2272):
        # BuilderComp.updateBuildLogic() (BuilderComp.java:76+),
        # called from BuildTurret.java:225
        # (`unit.updateBuildLogic();`). The counter half: early
        # return on `if(type.buildSpeed <= 0f) return;` (:77);
        # `validatePlans();` (:89); the
        # `if(!updateBuilding || !canBuild()){` guard (:90);
        # `float finalPlaceDst = state.rules.infiniteResources ?
        # Float.MAX_VALUE : type.buildRange;` (:94);
        # `boolean infinite = state.rules.infiniteResources ||
        # team().rules().infiniteResources;` (:95);
        # `buildCounter += Time.delta;` (:97) with the NaN/Inf
        # guard (:98) and the 10f clamp (:99);
        # `boolean instant = state.rules.instantBuild &&
        # state.rules.infiniteResources;` (:101);
        # `int maxPerFrame = instant ? plans.size : 10, count =
        # 0;` (:104); `var core = core();` (:106) with the
        # `if((core == null && !infinite)) return;` guard
        # (:108); the
        # `while((buildCounter >= 1 || instant) && count++ <
        # maxPerFrame && plans.size > 0){` loop (:110) with
        # `buildCounter -= 1f;` (:111) per iteration. The
        # selection half: `if(plans.size > 1){` (:114),
        # `float dst = plan.dst2(this);` (:123) in world units
        # from the plan draw position (`return x*tilesize +
        # (block == null ? 0 : block.offset);`,
        # BuildPlan.java:143 -- the offset is 0 for odd-size
        # blocks and 4 for even-size ones, Block.java:761, NOT
        # the tile-center +4), `boolean within = dst <=
        # finalPlaceDst*finalPlaceDst;` (:124, NON-strict),
        # `if(within && !shouldSkip(plan, core)){` (:126),
        # the bestIndex fallback
        # `if(!foundAny && bestIndex > 0 && !within(buildPlan(),
        # finalPlaceDst)){` (:140, strict within), `BuildPlan
        # current = buildPlan();` (:148) and `lastActive =
        # current;` (:151). validatePlans (:57-74): `Tile tile
        # = world.tile(plan.x, plan.y);` (:62), the derelict
        # check (:63), the three remove branches (:64-68).
        # shouldSkip (:246-251): the early-false guard (:247)
        # and the stuck / missing-stack disjunction (:249-250).
        # Placement (:148-222) defers, so the driver runs one
        # plan per tick and consumes the counter only when a
        # plan is selected (Java subtracts before selection).
        self.assertIn('static func source_build_turret_build_counter_state', build_turret)
        self.assertIn('static func source_build_turret_build_plan_selection_state', build_turret)
        self.assertIn('"build_counter": ', build_turret)
        self.assertIn('"run_build_loop": ', build_turret)
        self.assertIn('"iterations_available": ', build_turret)
        self.assertIn('"max_per_frame": ', build_turret)
        self.assertIn('"plans": plans', build_turret)
        self.assertIn('"selected": selected', build_turret)
        self.assertIn('"found_any": found_any', build_turret)
        self.assertIn('"best_index": best_index', build_turret)
        self.assertIn('"build_counter": 0.0', build_turret)
        self.assertIn('updateBuildLogic live (N2272)', build_turret)
        self.assertIn('one plan per tick', build_turret)
        self.assertIn('buildCounter += Time.delta;', build_turret)
        self.assertIn('if(Float.isNaN(buildCounter) || Float.isInfinite(buildCounter)) buildCounter = 0f;', build_turret)
        self.assertIn('buildCounter = Math.min(buildCounter, 10f);', build_turret)
        self.assertIn('boolean instant = state.rules.instantBuild && state.rules.infiniteResources;', build_turret)
        self.assertIn('int maxPerFrame = instant ? plans.size : 10, count = 0;', build_turret)
        self.assertIn('while((buildCounter >= 1 || instant) && count++ < maxPerFrame && plans.size > 0){', build_turret)
        self.assertIn('buildCounter -= 1f;', build_turret)
        self.assertIn('float dst = plan.dst2(this);', build_turret)
        self.assertIn('boolean within = dst <= finalPlaceDst*finalPlaceDst;', build_turret)
        self.assertIn('if(within && !shouldSkip(plan, core)){', build_turret)
        self.assertIn('if(!foundAny && bestIndex > 0 && !within(buildPlan(), finalPlaceDst)){', build_turret)
        self.assertIn('lastActive = current;', build_turret)
        self.assertIn('Tile tile = world.tile(plan.x, plan.y);', build_turret)
        self.assertIn('if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;', build_turret)
        self.assertIn('return x*tilesize + (block == null ? 0 : block.offset);', build_turret)
        self.assertIn('unit.updateBuildLogic();', build_turret)
        self.assertIn('buildSpeed = 1.5f;', build_turret)
        self.assertIn('range = 200f;', build_turret)
        # The driver wires updateBuildLogic AFTER the N2244 plan
        # logic in Java order (BuildTurret.java:225 after
        # :141-225) and UNGATED on enabled, like the plan logic
        # (BuildTurret sets no noUpdateDisabled, Java runs
        # updateTile even when disabled, BuildingComp.java:
        # 2274-2277): the counter pure runs every tick and its
        # result persists on the frame; the selection pure runs
        # only when the loop gate opens; the counter is consumed
        # (minus 1.0) and last_plan is set only when a plan is
        # selected. The plan logic N2244 is untouched.
        self.assertIn('static func source_build_turret_tick_buildings_state', build_turret)
        self.assertIn('source_build_turret_build_counter_state(', build_turret)
        self.assertIn('source_build_turret_build_plan_selection_state(', build_turret)
        self.assertIn('frame["build_counter"] = counter_state["build_counter"]', build_turret)
        self.assertIn('frame["plans"] = selection["plans"]', build_turret)
        self.assertIn('frame["last_plan"] = selected', build_turret)
        self.assertIn('float(counter_state["build_counter"]) - 1.0', build_turret)
        self.assertIn('static func source_build_turret_plan_logic_state', build_turret)
        # The N2184 power row and the N2215 gate are preserved.
        self.assertIn('static func source_build_turret_power_status_row_state', build_turret)
        self.assertIn('static func source_build_turret_should_consume_state', build_turret)
        self.assertIn('shouldConsume gate live (N2215)', build_turret)
        # The proof's keys drive the two pure functions: the
        # counter accumulates the tick delta and clamps at 10,
        # a NaN counter resets to 0, validation removes a plan
        # with no tile and keeps a valid plan, selection picks
        # the first in-range plan that is not skipped, and the
        # fallback rotates to the nearest in-range plan when
        # every plan is skipped. Static checks: the proof
        # preloads the build-turret state file that exists, and
        # the scene file references the proof script that
        # exists.
        proof = BUILD_TURRET_UPDATE_BUILD_LOGIC_PROOF.read_text(encoding='utf-8')
        for key in [
            'counter_accumulates_and_clamps',
            'counter_nan_resets_to_zero',
            'validate_removes_null_tile_plan',
            'validate_keeps_valid_plan',
            'selection_picks_first_valid_in_range',
            'selection_fallback_rotates_to_nearest',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertIn('build_turret_build_state.source_build_turret_build_counter_state(', proof)
        self.assertIn('build_turret_build_state.source_build_turret_build_plan_selection_state(', proof)
        self.assertTrue(BUILD_TURRET_STATE.is_file())
        scene = BUILD_TURRET_UPDATE_BUILD_LOGIC_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BuildTurretUpdateBuildLogicProof.gd', scene)
        self.assertTrue(BUILD_TURRET_UPDATE_BUILD_LOGIC_PROOF.is_file())

    def test_reference_graph_and_actual_c07_build_turret_update_build_logic(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretUpdateBuildLogicProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_UPDATE_BUILD_LOGIC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'counter_accumulates_and_clamps',
            'counter_nan_resets_to_zero',
            'validate_removes_null_tile_plan',
            'validate_keeps_valid_plan',
            'selection_picks_first_valid_in_range',
            'selection_fallback_rotates_to_nearest',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
