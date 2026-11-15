import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretUpdateTileProof.gd'
BUILD_TURRET_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretUpdateTileProof.tscn'


class C07BuildTurretUpdateTileTests(unittest.TestCase):
    def test_c07_build_turret_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2243']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_update_tile_advance_state')
        # N2184 proved the BuildTurret family's live power read and
        # N2215 the shouldConsume gate (unit.plans().size > 0 &&
        # !isHealSuppressed(), no enabled term) -- but the port
        # tracked no rotation / warmup / multiplier state at all,
        # so a build tower never synced its facing to the builder
        # unit, never zeroed efficiency under suppression, never
        # scaled the unit by potentialEfficiency and never warmed
        # up. N2243 is the updateTile advance part 1, sync +
        # warmup (BuildTurretBuild.updateTile(),
        # BuildTurret.java:121-140): rotation = unit.rotation()
        # (:126), lookAt(angleTo(unit.buildPlan())) while
        # actively building (:128-130), checkSuppression() zeroes
        # efficiency + potentialEfficiency (:132-134),
        # buildSpeedMultiplier / speedMultiplier =
        # potentialEfficiency * timeScale (:136-137), warmup =
        # lerpDelta(warmup, activelyBuilding ? efficiency : 0,
        # 0.1) (:139). The port has no Unit object, so the pure
        # advance takes the unit state as EXPLICIT frame inputs
        # (unit_rotation, default 90.0, the init block
        # `unit.rotation(90f);`, BuildTurret.java:99-101;
        # actively_building, default false; build_plan_angle,
        # default 0.0) and the suppression as the frame
        # heal_suppressed mirror (checkSuppression() returns
        # true iff isHealSuppressed(), BuildingComp.java:
        # 1336-1337; the Fx particle defers). The plan logic
        # (:141-231: controlled branch, follower validation,
        # plan search, mimic, plan validation, break-plan
        # discard, suicide-plan removal) belongs to N2244 and
        # updateBuildLogic (:231) defers to its own slice --
        # neither is in this slice. Seven new result symbols:
        # the synced rotation, the lookAt angle, the
        # post-suppression efficiency pair, both multipliers
        # and the lerped warmup.
        self.assertEqual(
            ledger['N2243']['source_symbols'],
            [
                'source_build_turret_update_tile_advance_state_result.rotation',
                'source_build_turret_update_tile_advance_state_result.unit_look_angle',
                'source_build_turret_update_tile_advance_state_result.efficiency',
                'source_build_turret_update_tile_advance_state_result.potential_efficiency',
                'source_build_turret_update_tile_advance_state_result.build_speed_multiplier',
                'source_build_turret_update_tile_advance_state_result.speed_multiplier',
                'source_build_turret_update_tile_advance_state_result.warmup',
            ],
        )
        for name in ledger['N2243']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_update_tile_advance_state')
        self.assertEqual(ledger['N2243']['runtime_proof'], '/root/C07BuildTurretUpdateTileProof')
        self.assertEqual(
            ledger['N2243']['tests'],
            [
                'test_c07_build_turret_update_tile_registration',
                'test_all_c07_build_turret_update_tile_input_evidence_is_exact',
                'test_build_turret_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_build_turret_update_tile',
            ],
        )
        self.assertTrue(ledger['N2243']['deferred_exprs'])
        # This slice REWORDS (not removes) the BuildTurret
        # updateTile advance deferral: the sync/warmup part is
        # done, the plan logic belongs to N2244 and
        # updateBuildLogic defers to its own slice -- so the
        # entry keeps its prefix and the DEFERRED count stays
        # 283 (the unification base).
        self.assertEqual(len(ledger['N2243']['deferred_exprs']), 283)
        advance_entries = [entry for entry in ledger['N2243']['deferred_exprs'] if entry.startswith('BuildTurret updateTile advance (')]
        self.assertEqual(len(advance_entries), 1)
        self.assertIn('N2243', advance_entries[0])
        self.assertIn('N2244', advance_entries[0])
        self.assertIn('updateBuildLogic', advance_entries[0])
        # The "BuildTurret suppression rows" entry is kept
        # verbatim (the N2227/N2228 precedent): its wording
        # "needs suppression state the tick does not track yet"
        # is now partly stale -- the zeroing IS live through
        # the heal_suppressed mirror -- but its core claim (no
        # live suppression application) is still true.
        self.assertTrue(any(entry.startswith('BuildTurret suppression rows (') for entry in ledger['N2243']['deferred_exprs']))

    def test_all_c07_build_turret_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2243']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2243']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_update_tile_advance_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the build-turret build
        # state: rotation follow (BuildTurret.java:126), the
        # lookAt while actively building (BuildTurret.java:
        # 128-130), the suppression zeroing (BuildTurret.java:
        # 132-134), the multipliers (BuildTurret.java:136-137)
        # and the warmup lerp (BuildTurret.java:139). Keep each
        # Java expr on ONE comment line (the N2148 shootWarmup
        # lesson: a split line fails this test). Java order
        # matters: rotation is read BEFORE the lookAt (:126
        # precedes :128-130), so this tick's rotation is the
        # pre-lookAt unit rotation and the lookAt only shows up
        # as unit_look_angle (the unit's facing next tick); the
        # warmup reads efficiency AFTER the suppression zeroing
        # (:139 after :133), so a suppressed tower's warmup
        # decays toward 0 even while actively building. The
        # lerpDelta formula is lerp(from, to, clamp(progress *
        # Time.delta)) with the UNSCALED Time.delta (arc
        # Mathf.java:430-432) -- only the multipliers use the
        # scaled timeScale, never the lerp. Time.delta in the
        # port is seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        # The unit sync lines (:122-123, `unit.tile(this);` /
        # `unit.team(team);`) have no port effect: the port has
        # no Unit object to sync, the frame inputs ARE the
        # unit's state for this building. isControlled() is NOT
        # read here -- the controlled branch (:141/:223-225)
        # belongs to N2244 (scope correction: the brief listed
        # `controlled` among the unit-state inputs, but :121-140
        # never reads it).
        self.assertIn('static func source_build_turret_update_tile_advance_state', build_turret)
        self.assertIn('unit.tile(this);', build_turret)
        self.assertIn('unit.team(team);', build_turret)
        self.assertIn('rotation = unit.rotation();', build_turret)
        self.assertIn('if(unit.activelyBuilding()){', build_turret)
        self.assertIn('unit.lookAt(angleTo(unit.buildPlan()));', build_turret)
        self.assertIn('if(checkSuppression()){', build_turret)
        self.assertIn('efficiency = potentialEfficiency = 0f;', build_turret)
        self.assertIn('unit.buildSpeedMultiplier(potentialEfficiency * timeScale);', build_turret)
        self.assertIn('unit.speedMultiplier(potentialEfficiency * timeScale);', build_turret)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);', build_turret)
        self.assertIn('public float warmup;', build_turret)
        self.assertIn('unit.rotation(90f);', build_turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)unitType.create(team);', build_turret)
        self.assertIn('public boolean checkSuppression(){', build_turret)
        self.assertIn('if(isHealSuppressed()){', build_turret)
        self.assertIn('return block.suppressable && Time.time <= healSuppressionTime;', build_turret)
        self.assertIn('transient float potentialEfficiency;', build_turret)
        self.assertIn('potentialEfficiency = efficiency;', build_turret)
        self.assertIn('public float rotation = 90;', build_turret)
        # The warmup lerp progress is the Java 0.1f
        # (BuildTurret.java:139) and the initial rotation is
        # the Java 90 -- BOTH the BaseTurretBuild field default
        # (`public float rotation = 90;`, BaseTurret.java:114)
        # and the unit init block (`unit.rotation(90f);`,
        # BuildTurret.java:99-101) -- so a fresh frame and a
        # fresh unit agree on the facing.
        self.assertIn('SOURCE_BUILD_TURRET_WARMUP_LERP_PROGRESS := 0.1', build_turret)
        self.assertIn('SOURCE_BUILD_TURRET_INITIAL_ROTATION := 90.0', build_turret)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption, like Java's Building.update()
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        self.assertIn('game_source_delta(game, seconds)', build_turret)
        self.assertIn('time_scale(sprite', build_turret)
        self.assertIn('source_build_turret_update_tile_advance_state(frame, source_delta, time_scale)', build_turret)
        self.assertIn('frame["rotation"]', build_turret)
        self.assertIn('frame["unit_look_angle"]', build_turret)
        self.assertIn('frame["efficiency"]', build_turret)
        self.assertIn('frame["potential_efficiency"]', build_turret)
        self.assertIn('frame["build_speed_multiplier"]', build_turret)
        self.assertIn('frame["speed_multiplier"]', build_turret)
        self.assertIn('frame["warmup"]', build_turret)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', build_turret)
        # The lerp reuses the shared SourceMathState helper,
        # which already implements lerp(from, to, clamp(progress
        # * Time.delta)) exactly (the N2191 accelerator
        # precedent); the advance does not re-implement it.
        self.assertIn('source_lerp_delta(', build_turret)
        # The unit-state inputs arrive as frame inputs with
        # Java-faithful defaults: the unit starts facing 90
        # (the init block), not building, with no plan angle;
        # suppression reads the heal_suppressed mirror
        # (default false, the N2215 gate key -- NOT a new
        # `suppressed` synonym, the N2228 coordinator-fix
        # precedent); potential_efficiency defaults to the
        # folded efficiency (BuildingComp.java:1989,
        # `potentialEfficiency = efficiency;`, the N2227
        # precedent).
        self.assertIn('frame.get("unit_rotation", SOURCE_BUILD_TURRET_INITIAL_ROTATION)', build_turret)
        self.assertIn('frame.get("actively_building", false)', build_turret)
        self.assertIn('frame.get("build_plan_angle", 0.0)', build_turret)
        self.assertIn('frame.get("heal_suppressed", false)', build_turret)
        self.assertIn('frame.get("potential_efficiency", efficiency)', build_turret)
        # The documented limits now record the sync/warmup
        # advance as live and the remaining deferrals (plan
        # logic N2244, updateBuildLogic, the live unit-state
        # fill, the nitrogen second consumer); the shouldConsume
        # gate stays live (N2215).
        self.assertIn('updateTile sync/warmup advance live (N2243)', build_turret)
        self.assertNotIn('No updateTile plan / mimic / validate advance', build_turret)
        self.assertIn('shouldConsume gate live (N2215)', build_turret)
        # The proof's keys drive the pure advance (rotation
        # follow, lookAt while building, suppression zeroing,
        # multipliers scaling with potential, warmup lerping
        # up while building and decaying while idle) plus the
        # live tick (folded into rotation_follows_unit: a
        # placed build-tower ticks rotation + warmup +
        # multipliers from the folded efficiency).
        proof = BUILD_TURRET_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'rotation_follows_unit',
            'look_at_when_building',
            'suppression_zeroes_efficiency',
            'multipliers_scale_with_potential',
            'warmup_lerps_when_building',
            'warmup_decays_when_idle',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertTrue(BUILD_TURRET_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('build_turret_build_state.source_build_turret_update_tile_advance_state(', proof)
        self.assertIn('build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BUILD_TURRET_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BuildTurretUpdateTileProof.gd', scene)
        self.assertIn('C07BuildTurretUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_build_turret_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rotation_follows_unit',
            'look_at_when_building',
            'suppression_zeroes_efficiency',
            'multipliers_scale_with_potential',
            'warmup_lerps_when_building',
            'warmup_decays_when_idle',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
