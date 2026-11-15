import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TRACTOR_BEAM_STATE = ROOT / 'godot-mindustry/src/game/SourceTractorBeamTurretBuildState.gd'
TRACTOR_BEAM_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamUpdateTileProof.gd'
TRACTOR_BEAM_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamUpdateTileProof.tscn'


class C07TractorBeamUpdateTileTests(unittest.TestCase):
    def test_c07_tractor_beam_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2230']['godot_owner'], 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_update_tile_advance_state')
        # N2152 gave the parallax its live power.status read and
        # N2218 the shouldConsume gate (target != null &&
        # enabled) -- but the port tracked no rotation /
        # strength / last-target / coolant-multiplier /
        # activation state at all, so a parallax never
        # re-acquired a target, never rotated toward one, never
        # pulled anything. N2230 is the updateTile advance
        # (TractorBeamBuild.updateTile(),
        # TractorBeamTurret.java:78-139): the activation early
        # return (:79-82), the eff/edelta fold (:84), the
        # retarget through Units.closestEnemy with its PRIORITY
        # semantics (:87-90, Units.java:296-313 -- a higher
        # priority wins even when farther; equal priority needs
        # strictly closer; dst2 subtracts hitSize squared), the
        # coolant consume (:92-106, null for parallax, modeled
        # with explicit inputs), the look-at guard (:111), the
        # rotation moveToward + lastX/lastY + strength lerpDelta
        # (:116-120), the shoot cone (:123) with the damage /
        # status / impulse as PURE RESULTS (no live unit is
        # written), and the strength decay (:134-136). Eleven
        # new result symbols: the advanced target /
        # activation_timer / coolant_multiplier / rotation /
        # strength / last-target position, the pure coolant
        # used / damage dealt / status applied / impulse
        # vector, and the any flag.
        self.assertEqual(
            ledger['N2230']['source_symbols'],
            [
                'source_tractor_beam_turret_update_tile_advance_state_result.target',
                'source_tractor_beam_turret_update_tile_advance_state_result.activation_timer',
                'source_tractor_beam_turret_update_tile_advance_state_result.coolant_multiplier',
                'source_tractor_beam_turret_update_tile_advance_state_result.coolant_used',
                'source_tractor_beam_turret_update_tile_advance_state_result.rotation',
                'source_tractor_beam_turret_update_tile_advance_state_result.strength',
                'source_tractor_beam_turret_update_tile_advance_state_result.last_target_position',
                'source_tractor_beam_turret_update_tile_advance_state_result.damage_dealt',
                'source_tractor_beam_turret_update_tile_advance_state_result.status_applied',
                'source_tractor_beam_turret_update_tile_advance_state_result.impulse',
                'source_tractor_beam_turret_update_tile_advance_state_result.any',
            ],
        )
        for name in ledger['N2230']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_update_tile_advance_state')
        self.assertEqual(ledger['N2230']['runtime_proof'], '/root/C07TractorBeamUpdateTileProof')
        self.assertEqual(
            ledger['N2230']['tests'],
            [
                'test_c07_tractor_beam_update_tile_registration',
                'test_all_c07_tractor_beam_update_tile_input_evidence_is_exact',
                'test_tractor_beam_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_tractor_beam_update_tile',
            ],
        )
        self.assertTrue(ledger['N2230']['deferred_exprs'])
        # This slice resolves the TractorBeamTurret updateTile
        # advance deferral, so the advance entry is gone from
        # DEFERRED -- while the live-fill entry (timer cadence
        # + live enemy scan + coolant live fill + damage /
        # impulse / status application + sound / laser draw)
        # takes its place.
        self.assertFalse(any(entry.startswith('TractorBeamTurret live target retarget + coolant rows + updateTile advance (') for entry in ledger['N2230']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('TractorBeamTurret updateTile live fill (') for entry in ledger['N2230']['deferred_exprs']))

    def test_all_c07_tractor_beam_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2230']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta / moveToward / within / angle / limit /
        # within / dst formulas live in Arc, not Mindustry:
        # Mathf.java, Angles.java, Position.java, Vec2.java and
        # Time.java under arc-upstream (the N2191 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Angles.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Angles.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Position.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Vec2.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Vec2.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2230']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tractor_beam_update_tile_advance_state(self):
        tractor_beam = TRACTOR_BEAM_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the tractor-beam build
        # state: TractorBeamBuild.updateTile()
        # (TractorBeamTurret.java:78-139). Keep each Java expr
        # on ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The Arc formulas are
        # lerpDelta(from, to, progress) = lerp(from, to,
        # clamp(progress * Time.delta)) (Mathf.java:430-432),
        # moveToward stepping at most speed toward the target
        # angle (Angles.java:38-49), within as angleDist <=
        # margin (Angles.java:19-21), angle as atan2 in degrees
        # (Angles.java:56-60), Vec2.limit clamping the length
        # to AT MOST the limit (Vec2.java:274-285), within as
        # a STRICT dst2 < dst^2 (Position.java:44-46), and
        # angleTo as Angles.angle (Position.java:12-14).
        # Time.delta in the port is seconds * 60 through
        # game_source_delta (arc Time.java:26), never raw
        # seconds (the N2186/N2187/N2191 lesson: raw seconds
        # run 60x slow). NOTE the eff ordering trap: Java
        # computes eff/edelta at :84 BEFORE the coolant branch
        # (:92-106) updates coolantMultiplier, so this tick's
        # rotation / damage / impulse use the INCOMING
        # multiplier and the new multiplier only affects the
        # next tick. NOTE the coolant reset: there is no
        # separate reset -- the :105 formula itself yields 1f
        # when used is 0, and the branch only runs when the
        # target is non-null and coolant is present; with no
        # target the multiplier persists.
        self.assertIn('static func source_tractor_beam_turret_update_tile_advance_state', tractor_beam)
        self.assertIn('if(activationTimer > 0){', tractor_beam)
        self.assertIn('activationTimer -= Time.delta;', tractor_beam)
        self.assertIn('float eff = efficiency * coolantMultiplier, edelta = eff * delta();', tractor_beam)
        self.assertIn('if(timer(timerTarget, retargetTime)){', tractor_beam)
        self.assertIn('target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));', tractor_beam)
        self.assertIn('if(target != null && coolant != null){', tractor_beam)
        self.assertIn('float maxUsed = coolant.amount;', tractor_beam)
        self.assertIn('Liquid liquid = liquids.current();', tractor_beam)
        self.assertIn('float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));', tractor_beam)
        self.assertIn('liquids.remove(liquid, used);', tractor_beam)
        self.assertIn('coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);', tractor_beam)
        self.assertIn('any = false;', tractor_beam)
        self.assertIn('if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){', tractor_beam)
        self.assertIn('float dest = angleTo(target);', tractor_beam)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);', tractor_beam)
        self.assertIn('lastX = target.x;', tractor_beam)
        self.assertIn('lastY = target.y;', tractor_beam)
        self.assertIn('strength = Mathf.lerpDelta(strength, 1f, 0.1f);', tractor_beam)
        self.assertIn('if(Angles.within(rotation, dest, shootCone)){', tractor_beam)
        self.assertIn('target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));', tractor_beam)
        self.assertIn('if(status != StatusEffects.none){', tractor_beam)
        self.assertIn('target.apply(status, statusDuration);', tractor_beam)
        self.assertIn('any = true;', tractor_beam)
        self.assertIn('target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));', tractor_beam)
        self.assertIn('strength = Mathf.lerpDelta(strength, 0, 0.1f);', tractor_beam)
        self.assertIn('public @Nullable Unit target;', tractor_beam)
        self.assertIn('public float lastX, lastY, strength;', tractor_beam)
        self.assertIn('public boolean any;', tractor_beam)
        self.assertIn('public float coolantMultiplier = 1f;', tractor_beam)
        self.assertIn('public float rotation = 90;', tractor_beam)
        self.assertIn('public float activationTimer = 0;', tractor_beam)
        self.assertIn('force = 16f;', tractor_beam)
        self.assertIn('scaledForce = 9f;', tractor_beam)
        self.assertIn('range = 300f;', tractor_beam)
        self.assertIn('damage = 0.5f;', tractor_beam)
        self.assertIn('rotateSpeed = 12;', tractor_beam)
        self.assertIn('public float retargetTime = 5f;', tractor_beam)
        self.assertIn('public float shootCone = 6f;', tractor_beam)
        self.assertIn('public boolean targetAir = true, targetGround = false;', tractor_beam)
        self.assertIn('return Time.delta * timeScale;', tractor_beam)
        self.assertIn('return efficiency * delta();', tractor_beam)
        self.assertIn('if(team == Team.derelict) return null;', tractor_beam)
        self.assertIn('float dst2 = e.dst2(x, y) - (e.hitSize * e.hitSize);', tractor_beam)
        self.assertIn('if(dst2 < range*range && (result == null || dst2 < cdist || e.type.targetPriority > cpriority) && e.type.targetPriority >= cpriority){', tractor_beam)
        self.assertIn('return (isGrounded() && targetGround) || (isFlying() && targetAir);', tractor_beam)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', tractor_beam)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', tractor_beam)
        self.assertIn('return angleDist(a, b) <= margin;', tractor_beam)
        self.assertIn('return limit2(limit * limit);', tractor_beam)
        self.assertIn('set(tile.drawx(), tile.drawy());', tractor_beam)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', tractor_beam)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', tractor_beam)
        self.assertIn('public boolean noUpdateDisabled = false;', tractor_beam)
        self.assertIn('return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;', tractor_beam)
        self.assertIn('targetPriority = 0f,', tractor_beam)
        # The parallax def values are driver constants (the
        # catalog carries neither force nor scaledForce nor
        # damage for this family -- the Separator craftTime
        # precedent): the DEF wins over the class defaults
        # (force 0.3f, scaledForce 0f, damage 0f, rotateSpeed
        # 10f, range 80f).
        self.assertIn('SOURCE_TRACTOR_BEAM_FORCE := 16.0', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_SCALED_FORCE := 9.0', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_RANGE := 300.0', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_DAMAGE := 0.5', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_ROTATE_SPEED := 12.0', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_SHOOT_CONE := 6.0', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_ROTATION_DEFAULT := 90.0', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_STRENGTH_LERP_PROGRESS := 0.1', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_EFFICIENCY_MIN := 0.02', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_TARGET_AIR := true', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_TARGET_GROUND := false', tractor_beam)
        # The shared math helpers do the angle / moveToward /
        # within / lerpDelta / dst / limit work; the
        # closestEnemy priority selection is a local
        # transliteration (the port has no closestEnemy
        # helper, no separate symbol).
        self.assertIn('source_math_state.source_angles_move_toward(', tractor_beam)
        self.assertIn('source_math_state.source_angles_within(', tractor_beam)
        self.assertIn('source_math_state.source_angles_angle(', tractor_beam)
        self.assertIn('source_math_state.source_lerp_delta(', tractor_beam)
        self.assertIn('source_math_state.source_vec2_limit(', tractor_beam)
        self.assertIn('source_math_state.source_dst(', tractor_beam)
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
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing. The building position comes from the origin
        # cell: Building x/y are tile.drawx()/drawy()
        # (BuildingComp.java:124) with the block offset
        # (Block.java:761). The driver passes an EMPTY candidate
        # list with retarget_tick false: no live unit query
        # exists in the port and there is no timer helper, so
        # no live retarget happens (the live-fill entry stays
        # deferred); the coolant inputs are all default
        # no-op (parallax has no ConsumeCoolant consumer, so
        # coolant is null); blockDamage is the 1.0 default
        # (Rules.java:113/:367, no rules helper reads it in
        # the port); status is none for parallax, so
        # status_present is false.
        self.assertIn('game_source_delta(game, seconds)', tractor_beam)
        self.assertIn('time_scale(sprite', tractor_beam)
        self.assertIn('source_tractor_beam_turret_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, team_id, [], false, false, 0.0, 0.0, 0.0, 1.0, false)', tractor_beam)
        self.assertIn('tile_drawx_state(', tractor_beam)
        self.assertIn('tile_drawy_state(', tractor_beam)
        self.assertIn('source_world_defaults.TILESIZE', tractor_beam)
        self.assertIn('frame["target"]', tractor_beam)
        self.assertIn('frame["activation_timer"]', tractor_beam)
        self.assertIn('frame["coolant_multiplier"]', tractor_beam)
        self.assertIn('frame["coolant_used"]', tractor_beam)
        self.assertIn('frame["rotation"]', tractor_beam)
        self.assertIn('frame["strength"]', tractor_beam)
        self.assertIn('frame["last_x"]', tractor_beam)
        self.assertIn('frame["last_y"]', tractor_beam)
        self.assertIn('frame["damage_dealt"]', tractor_beam)
        self.assertIn('frame["status_applied"]', tractor_beam)
        self.assertIn('frame["impulse"]', tractor_beam)
        self.assertIn('frame["any"]', tractor_beam)
        # The frame reads carry the Java field defaults: target
        # null (TractorBeamTurret.java:72), activationTimer 0
        # (BaseTurret.java:115), coolantMultiplier 1f
        # (TractorBeamTurret.java:75), rotation 90
        # (BaseTurret.java:114), strength / lastX / lastY 0.0
        # (TractorBeamTurret.java:73), any false
        # (TractorBeamTurret.java:74), efficiency 0.0
        # (BuildingComp.java:85).
        self.assertIn('frame.get("target", null)', tractor_beam)
        self.assertIn('frame.get("activation_timer", 0.0)', tractor_beam)
        self.assertIn('frame.get("coolant_multiplier", 1.0)', tractor_beam)
        self.assertIn('frame.get("rotation", SOURCE_TRACTOR_BEAM_ROTATION_DEFAULT)', tractor_beam)
        self.assertIn('frame.get("strength", 0.0)', tractor_beam)
        self.assertIn('frame.get("efficiency", 0.0)', tractor_beam)
        self.assertIn('frame.get("last_x", 0.0)', tractor_beam)
        self.assertIn('frame.get("last_y", 0.0)', tractor_beam)
        self.assertIn('frame.get("any", false)', tractor_beam)
        # The documented limits now record the advance as done
        # and the remaining deferrals (timer cadence, live
        # enemy scan, coolant live fill, damage / impulse /
        # status application); the shouldConsume gate stays
        # live (N2218).
        self.assertIn('updateTile advance live (N2230)', tractor_beam)
        self.assertNotIn('No updateTile advance', tractor_beam)
        self.assertIn('shouldConsume gate live (N2218)', tractor_beam)
        # The proof's keys drive the pure advance (retarget
        # picks the closest flying enemy, priority beats
        # distance, rotation moves toward the target and
        # strength rises, the impulse folds force and range,
        # the coolant consume folds heat capacity, strength
        # decays without a target, the activation timer
        # blocks the update) plus the live tick (a placed
        # parallax with a seeded target pulls by the folded
        # efficiency and writes the advance keys onto the
        # frame; with no target nothing pulls and strength
        # decays). Eight keys, not the scope's six: the live
        # tick (the N2226/N2228 precedent -- the driver
        # wiring needs proof coverage) and the coolant
        # consume (a third of the Java method) each earn
        # their own key.
        proof = TRACTOR_BEAM_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'retarget_picks_closest_flying_enemy',
            'priority_beats_distance',
            'rotation_moves_and_strength_rises',
            'impulse_folds_force_and_range',
            'coolant_consume_folds_heat_capacity',
            'strength_decays_without_target',
            'activation_timer_blocks_update',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceTractorBeamTurretBuildState.gd")', proof)
        self.assertIn('tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state(', proof)
        self.assertIn('tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(TRACTOR_BEAM_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = TRACTOR_BEAM_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07TractorBeamUpdateTileProof.gd', scene)
        self.assertIn('C07TractorBeamUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_tractor_beam_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TractorBeamUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TRACTOR_BEAM_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'retarget_picks_closest_flying_enemy',
            'priority_beats_distance',
            'rotation_moves_and_strength_rises',
            'impulse_folds_force_and_range',
            'coolant_consume_folds_heat_capacity',
            'strength_decays_without_target',
            'activation_timer_blocks_update',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
