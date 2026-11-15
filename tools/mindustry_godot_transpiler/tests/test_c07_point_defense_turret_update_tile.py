import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_TURRET_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseUpdateTileProof.gd'
POINT_DEFENSE_TURRET_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseUpdateTileProof.tscn'


class C07PointDefenseTurretUpdateTileTests(unittest.TestCase):
    def test_c07_point_defense_turret_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2229']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_update_tile_advance_state')
        # N2151 gave the segment its live power.status read and
        # N2217 the shouldConsume gate (enabled && target !=
        # null) -- but the port tracked no rotation /
        # reloadCounter / shot state at all, so a segment never
        # retargeted a bullet, never rotated toward one, never
        # fired. N2229 is the updateTile advance
        # (PointDefenseBuild.updateTile(),
        # PointDefenseTurret.java:62-103): the timer retarget
        # (:65-67) -- Groups.bullet RECTANGLE intersect + min
        # raw dst2, ported as a pure selection over an explicit
        # bullet list with a retarget_tick bool -- the pooled
        # clear when the bullet is no longer added (:70-72),
        # the coolant branch (:74-76, updateCooling,
        # ReloadTurret.java:28-41, modeled with explicit
        # coolant params, a no-op for the segment whose def has
        # no ConsumeCoolant consumer), and the look-at branch
        # (:78-103) -- the within / team / type / hittable
        # guard, rotation moveToward at rotateSpeed * edelta(),
        # reloadCounter += edelta(), and the shot when within
        # the cone and reloaded: realDamage = bulletDamage *
        # blockDamage(team), damage > realDamage returns the
        # remaining damage as a pure result, otherwise the
        # bullet is removed (as a pure result -- the port never
        # writes into a live bullet frame). Six new result
        # symbols: the advanced target / rotation /
        # reload_counter, the pure remaining damage, the
        # removed flag, and the fired flag.
        self.assertEqual(
            ledger['N2229']['source_symbols'],
            [
                'source_point_defense_turret_update_tile_advance_state_result.target',
                'source_point_defense_turret_update_tile_advance_state_result.rotation',
                'source_point_defense_turret_update_tile_advance_state_result.reload_counter',
                'source_point_defense_turret_update_tile_advance_state_result.target_damage_remaining',
                'source_point_defense_turret_update_tile_advance_state_result.target_removed',
                'source_point_defense_turret_update_tile_advance_state_result.fired',
            ],
        )
        for name in ledger['N2229']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_update_tile_advance_state')
        self.assertEqual(ledger['N2229']['runtime_proof'], '/root/C07PointDefenseUpdateTileProof')
        self.assertEqual(
            ledger['N2229']['tests'],
            [
                'test_c07_point_defense_turret_update_tile_registration',
                'test_all_c07_point_defense_turret_update_tile_input_evidence_is_exact',
                'test_point_defense_turret_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_update_tile',
            ],
        )
        self.assertTrue(ledger['N2229']['deferred_exprs'])
        # This slice resolves the N2217 PointDefenseTurret live
        # bullet-target retarget + updateTile advance
        # deferral, so the advance entry is gone from DEFERRED
        # -- while the live-fill entry (timer cadence + live
        # bullet scan fill + coolant live fill + damage
        # application on the live bullet + effects/sound) takes
        # its place.
        self.assertFalse(any(entry.startswith('PointDefenseTurret live bullet-target retarget + updateTile advance (') for entry in ledger['N2229']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PointDefenseTurret updateTile live fill (') for entry in ledger['N2229']['deferred_exprs']))

    def test_all_c07_point_defense_turret_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2229']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/EntityComp.java',
            'core/src/mindustry/entities/EntityGroup.java',
            'core/src/mindustry/entities/GroupDefs.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/game/Team.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The within / angleTo / moveToward / Seq.min / QuadTree
        # formulas live in Arc, not Mindustry: Position.java,
        # Angles.java, Seq.java and QuadTree.java under
        # arc-upstream (the N2191 precedent).
        upstream['arc-core/src/arc/math/geom/Position.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Angles.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Angles.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/struct/Seq.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/struct/Seq.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/QuadTree.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/QuadTree.java').read_text(encoding='utf-8')
        for expr in ledger['N2229']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_update_tile_advance_state(self):
        point_defense_turret = POINT_DEFENSE_TURRET_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the point-defense-turret
        # build state: PointDefenseBuild.updateTile()
        # (PointDefenseTurret.java:62-103). Keep each Java expr
        # on ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The retarget is a
        # RECTANGLE intersect (EntityGroup.java:207), NOT a
        # circle, and the min is over dst2 RAW with Seq.min's
        # `if(val <= min){` (Seq.java:329), so the LAST
        # candidate wins a tie -- NOT the first (unlike
        # Units.closest's strict <, the N2226 precedent). The
        # look-at guard's within is STRICT (Position.java:
        # 44-46, dst2 < range^2): exactly at range is OUT.
        # dest is angleTo (Position.java:12-14); moveToward
        # snaps when the angleDist is under the speed
        # (Angles.java:38-39); within is angleDist <= margin
        # (Angles.java:19-20). Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        # DEF BEATS CLASS: the segment def (Blocks.java:
        # 3835-3847) sets range 180f, bulletDamage 30f, reload
        # 8f, shootLength 5f over the class defaults
        # (bulletDamage 10f, shootLength 3f, reload 30f in the
        # ctor, 10f on ReloadTurret).
        self.assertIn('static func source_point_defense_turret_update_tile_advance_state', point_defense_turret)
        self.assertIn('public @Nullable Bullet target;', point_defense_turret)
        self.assertIn('public float rotation = 90;', point_defense_turret)
        self.assertIn('public float reloadCounter;', point_defense_turret)
        self.assertIn('if(timer(timerTarget, retargetTime)){', point_defense_turret)
        self.assertIn('target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', point_defense_turret)
        self.assertIn('if(target != null && !target.isAdded()){', point_defense_turret)
        self.assertIn('if(coolant != null){', point_defense_turret)
        self.assertIn('updateCooling();', point_defense_turret)
        self.assertIn('if(target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable){', point_defense_turret)
        self.assertIn('float dest = angleTo(target);', point_defense_turret)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());', point_defense_turret)
        self.assertIn('reloadCounter += edelta();', point_defense_turret)
        self.assertIn('if(Angles.within(rotation, dest, shootCone) && reloadCounter >= reload){', point_defense_turret)
        self.assertIn('float realDamage = bulletDamage * state.rules.blockDamage(team);', point_defense_turret)
        self.assertIn('if(target.damage() > realDamage){', point_defense_turret)
        self.assertIn('target.damage(target.damage() - realDamage);', point_defense_turret)
        self.assertIn('target.remove();', point_defense_turret)
        self.assertIn('reloadCounter = 0;', point_defense_turret)
        self.assertIn('public float retargetTime = 5f;', point_defense_turret)
        self.assertIn('public float shootCone = 5f;', point_defense_turret)
        self.assertIn('public float bulletDamage = 10f;', point_defense_turret)
        self.assertIn('public float shootLength = 3f;', point_defense_turret)
        self.assertIn('rotateSpeed = 20f;', point_defense_turret)
        self.assertIn('reload = 30f;', point_defense_turret)
        self.assertIn('coolantMultiplier = 2f;', point_defense_turret)
        self.assertIn('range = 180f;', point_defense_turret)
        self.assertIn('shootLength = 5f;', point_defense_turret)
        self.assertIn('bulletDamage = 30f;', point_defense_turret)
        self.assertIn('reload = 8f;', point_defense_turret)
        self.assertIn('public float reload = 10f;', point_defense_turret)
        self.assertIn('if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){', point_defense_turret)
        self.assertIn('float amount = coolant.amount * coolant.efficiency(this);', point_defense_turret)
        self.assertIn('reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();', point_defense_turret)
        self.assertIn('return reloadCounter < reload;', point_defense_turret)
        self.assertIn('coolant = findConsumer(c -> c instanceof ConsumeCoolant);', point_defense_turret)
        self.assertIn('return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;', point_defense_turret)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', point_defense_turret)
        self.assertIn('return Angles.angle(getX(), getY(), other.getX(), other.getY());', point_defense_turret)
        self.assertIn('if(val <= min){', point_defense_turret)
        self.assertIn('if(tmp.overlaps(x, y, width, height)){', point_defense_turret)
        self.assertIn('public boolean hittable = true;', point_defense_turret)
        self.assertIn('return Time.delta * timeScale;', point_defense_turret)
        self.assertIn('return efficiency * delta();', point_defense_turret)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', point_defense_turret)
        self.assertIn('public boolean noUpdateDisabled = false;', point_defense_turret)
        self.assertIn('set(tile.drawx(), tile.drawy());', point_defense_turret)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', point_defense_turret)
        # The segment def values are driver constants (the
        # catalog carries neither range nor bulletDamage nor
        # reload for this family -- the Separator craftTime
        # precedent), alongside the class values and the
        # rotation field default.
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_RANGE := 180.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_BULLET_DAMAGE := 30.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_RELOAD := 8.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_ROTATE_SPEED := 20.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_SHOOT_CONE := 5.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_COOLANT_MULTIPLIER := 2.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_RETARGET_TIME := 5.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_ROTATION_DEFAULT := 90.0', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_COOLANT_CAPACITY_FALLBACK := 0.4', point_defense_turret)
        # The shared math helpers do the angle / moveToward /
        # within work; the min tie-break is the Seq.min `<=`
        # (last wins) and the within is the STRICT dst2 <
        # range^2.
        self.assertIn('source_math_state.source_angles_angle(', point_defense_turret)
        self.assertIn('source_math_state.source_angles_move_toward(', point_defense_turret)
        self.assertIn('source_math_state.source_angles_within(', point_defense_turret)
        self.assertIn('bullet_dst2 <= best_dst2', point_defense_turret)
        self.assertIn('target_dst2 < turret_range * turret_range', point_defense_turret)
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
        # (Block.java:761) -- 4 for the size-2 segment. The
        # driver passes the N2316 timer's retarget_tick and an
        # EMPTY bullet list: no live bullet query exists in
        # the port, so a fire with no bullets clears the
        # target to null (Java's unconditional assignment,
        # PointDefenseTurret.java:66); only the pooled clear /
        # rotation / reload / shot lines ran live before N2316
        # wired the cadence.
        self.assertIn('game_source_delta(game, seconds)', point_defense_turret)
        self.assertIn('time_scale(sprite', point_defense_turret)
        self.assertIn('source_point_defense_turret_update_tile_advance_state(frame, source_delta, time_scale, SOURCE_POINT_DEFENSE_TURRET_RANGE, SOURCE_POINT_DEFENSE_TURRET_BULLET_DAMAGE, SOURCE_POINT_DEFENSE_TURRET_RELOAD, advance_building_x, advance_building_y, [], retarget_tick)', point_defense_turret)
        self.assertIn('tile_drawx_state(', point_defense_turret)
        self.assertIn('tile_drawy_state(', point_defense_turret)
        self.assertIn('source_world_defaults.TILESIZE', point_defense_turret)
        self.assertIn('frame["target"]', point_defense_turret)
        self.assertIn('frame["rotation"]', point_defense_turret)
        self.assertIn('frame["reload_counter"]', point_defense_turret)
        self.assertIn('frame["target_damage_remaining"]', point_defense_turret)
        self.assertIn('frame["target_removed"]', point_defense_turret)
        self.assertIn('frame["fired"]', point_defense_turret)
        # The frame reads carry the Java field defaults: target
        # null (PointDefenseTurret.java:59), rotation 90
        # (BaseTurret.java:114), reloadCounter 0.0
        # (ReloadTurret.java:26), efficiency 0.0
        # (BuildingComp.java:85), team_id derelict (the tick
        # wiring default). A target dict without a team is
        # never an enemy; a target without an `added` flag is
        # added (the live bullet default).
        self.assertIn('frame.get("target", null)', point_defense_turret)
        self.assertIn('frame.get("rotation", SOURCE_POINT_DEFENSE_TURRET_ROTATION_DEFAULT)', point_defense_turret)
        self.assertIn('frame.get("reload_counter", 0.0)', point_defense_turret)
        self.assertIn('frame.get("efficiency", 0.0)', point_defense_turret)
        self.assertIn('frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID)', point_defense_turret)
        self.assertIn('target.get("added", true)', point_defense_turret)
        # The documented limits now record the advance as done
        # and the remaining deferrals (timer cadence, live
        # bullet scan fill, coolant live fill, damage
        # application on the live bullet, effects/sound); the
        # shouldConsume gate stays live (N2217).
        self.assertIn('updateTile advance live (N2229)', point_defense_turret)
        self.assertNotIn('No updateTile advance', point_defense_turret)
        self.assertIn('shouldConsume gate live (N2217)', point_defense_turret)
        # The proof's keys drive the pure advance (retarget
        # picks the closest hittable enemy bullet in the rect
        # with last-wins ties, the pooled target clears, the
        # rotation moves toward the target at rotateSpeed *
        # edelta, the reload counter charges and fires, the
        # shot reduces a strong bullet's damage, the shot
        # removes a weak bullet) plus the live tick (a placed
        # segment with a seeded target charges and fires and
        # writes the advance keys onto the frame).
        proof = POINT_DEFENSE_TURRET_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'retarget_picks_closest_hittable_bullet',
            'pooled_target_clears',
            'rotation_moves_toward_target',
            'reload_counter_charges_and_fires',
            'shot_reduces_bullet_damage',
            'shot_removes_weak_bullet',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePointDefenseTurretBuildState.gd")', proof)
        self.assertIn('point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state(', proof)
        self.assertIn('point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(POINT_DEFENSE_TURRET_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = POINT_DEFENSE_TURRET_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PointDefenseUpdateTileProof.gd', scene)
        self.assertIn('C07PointDefenseUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_point_defense_turret_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'retarget_picks_closest_hittable_bullet',
            'pooled_target_clears',
            'rotation_moves_toward_target',
            'reload_counter_charges_and_fires',
            'shot_reduces_bullet_damage',
            'shot_removes_weak_bullet',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
