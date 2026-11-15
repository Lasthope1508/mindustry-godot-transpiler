import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretUpdateTileProof.gd'
REPAIR_TURRET_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretUpdateTileProof.tscn'


class C07RepairTurretUpdateTileTests(unittest.TestCase):
    def test_c07_repair_turret_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2226']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_update_tile_advance_state')
        # N2174 gave the repair turret its live power.status read
        # and N2212 the shouldConsume gate (target != null &&
        # enabled) -- but the port tracked no strength /
        # rotation / offset / heal state at all, so a repair
        # turret never cleared a dead target, never rotated
        # toward one, never healed anything. N2226 is the
        # updateTile advance (RepairPointBuild.updateTile(),
        # RepairTurret.java:187-218): the target clear when
        # dead / out of range / full health
        # (RepairTurret.java:193-194), the offset zero when the
        # target is null (:197-199), the heal branch (:203-210)
        # -- angle from Angles.angle, the 30-degree angleDist
        # gate, heal amount repairSpeed * strength * edelta()
        # * multiplier, rotation slerpDelta toward the angle at
        # 0.5f * efficiency * timeScale -- the strength
        # lerpDelta toward (healed ? 1 : 0) at 0.08f *
        # Time.delta (:212), and the timer re-acquire selection
        # (:214-217) as a pure function over an explicit
        # candidate list (Units.closest = min dst2 among the
        # damaged, valid, in-range candidates, Units.java:
        # 358-372 + nearby :445-451 + within :44-46). The
        # multiplier is 1.0 (power-only first pass; the
        # acceptCoolant branch, RepairTurret.java:189-191,
        # waits for the coolant row). The heal APPLICATION
        # (target.heal writes into another unit's health)
        # defers -- the advance returns heal_amount as a pure
        # result; the timer cadence (every 20 ticks) defers
        # too (no timer helper in the port, the N2193
        # precedent), so the driver passes an empty candidate
        # list and no live re-acquire happens until the
        # live-fill slice lands. Six new result symbols: the
        # advanced target / offset / strength / rotation, the
        # pure heal amount, and the healed flag.
        self.assertEqual(
            ledger['N2226']['source_symbols'],
            [
                'source_repair_turret_update_tile_advance_state_result.target',
                'source_repair_turret_update_tile_advance_state_result.offset',
                'source_repair_turret_update_tile_advance_state_result.strength',
                'source_repair_turret_update_tile_advance_state_result.rotation',
                'source_repair_turret_update_tile_advance_state_result.heal_amount',
                'source_repair_turret_update_tile_advance_state_result.healed',
            ],
        )
        for name in ledger['N2226']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTurret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_update_tile_advance_state')
        self.assertEqual(ledger['N2226']['runtime_proof'], '/root/C07RepairTurretUpdateTileProof')
        self.assertEqual(
            ledger['N2226']['tests'],
            [
                'test_c07_repair_turret_update_tile_registration',
                'test_all_c07_repair_turret_update_tile_input_evidence_is_exact',
                'test_repair_turret_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_repair_turret_update_tile',
            ],
        )
        self.assertTrue(ledger['N2226']['deferred_exprs'])
        # This slice resolves the N2174 RepairTurret updateTile
        # advance deferral, so the advance entry is gone from
        # DEFERRED -- while the live-fill entry (heal
        # application + timer re-acquire cadence + coolant
        # multiplier + draw offset/lastEnd mutation) takes its
        # place. The N2212 "RepairTurret live target acquire"
        # entry STAYS: no live fill sets frame["target"] yet
        # (the driver passes no candidates), so it is still
        # true.
        self.assertFalse(any(entry.startswith('RepairTurret updateTile advance (') for entry in ledger['N2226']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret updateTile live fill (') for entry in ledger['N2226']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret live target acquire (') for entry in ledger['N2226']['deferred_exprs']))

    def test_all_c07_repair_turret_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2226']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta / slerpDelta / angle / within formulas
        # live in Arc, not Mindustry: Mathf.java, Angles.java
        # and Position.java under arc-upstream (the N2191
        # precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Angles.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Angles.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Position.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8')
        for expr in ledger['N2226']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_update_tile_advance_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the repair-turret build
        # state: RepairPointBuild.updateTile()
        # (RepairTurret.java:187-218). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The Arc formulas are
        # lerpDelta(from, to, progress) = lerp(from, to,
        # clamp(progress * Time.delta)) and slerpDelta(from,
        # to, progress) = slerp(from, to, clamp(progress *
        # Time.delta)) with slerp the wrapped angle lerp
        # (Mathf.java:425-462); angleDist is the shortest
        # absolute arc between two angles (Angles.java:23-28);
        # angle(x, y, x2, y2) is atan2 in degrees
        # (Angles.java:56-60). Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        # NOTE the strength trap: Java passes `0.08f *
        # Time.delta` as the lerpDelta progress, and lerpDelta
        # multiplies by Time.delta AGAIN -- the port passes
        # 0.08 * source_delta as the progress to the shared
        # lerp_delta helper, so the double delta is exact.
        # The rotation slerp progress (0.5f * efficiency *
        # timeScale) carries NO Time.delta in Java -- the
        # local slerp helper multiplies once.
        self.assertIn('static func source_repair_turret_update_tile_advance_state', repair_turret)
        self.assertIn('float multiplier = 1f;', repair_turret)
        self.assertIn('multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', repair_turret)
        self.assertIn('if(target != null && (target.dead() || target.dst(this) - target.hitSize/2f > repairRadius || target.health() >= target.maxHealth())){', repair_turret)
        self.assertIn('offset.setZero();', repair_turret)
        self.assertIn('float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', repair_turret)
        self.assertIn('if(Angles.angleDist(angle, rotation) < 30f){', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        self.assertIn('rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);', repair_turret)
        self.assertIn('strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', repair_turret)
        self.assertIn('if(timer(timerTarget, 20)){', repair_turret)
        self.assertIn('target = Units.closest(team, x, y, repairRadius, Unit::damaged);', repair_turret)
        self.assertIn('public Unit target;', repair_turret)
        self.assertIn('public Vec2 offset = new Vec2(), lastEnd = new Vec2();', repair_turret)
        self.assertIn('public float strength, rotation = 90;', repair_turret)
        self.assertIn('public float repairRadius = 50f;', repair_turret)
        self.assertIn('public float repairSpeed = 0.3f;', repair_turret)
        self.assertIn('repairSpeed = 0.45f;', repair_turret)
        self.assertIn('repairRadius = 60f;', repair_turret)
        self.assertIn('repairSpeed = 3f;', repair_turret)
        self.assertIn('repairRadius = 145f;', repair_turret)
        self.assertIn('return Time.delta * timeScale;', repair_turret)
        self.assertIn('return efficiency * delta();', repair_turret)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', repair_turret)
        self.assertIn('public boolean noUpdateDisabled = false;', repair_turret)
        self.assertIn('return health < maxHealth - 0.001f;', repair_turret)
        self.assertIn('if(unit.within(x, y, radius + unit.hitSize/2f)){', repair_turret)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', repair_turret)
        self.assertIn('float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;', repair_turret)
        self.assertIn('return (fromDegrees + delta * progress + 360) % 360;', repair_turret)
        self.assertIn('set(tile.drawx(), tile.drawy());', repair_turret)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', repair_turret)
        # The per-def values are driver constants (the catalog
        # carries neither repairSpeed nor repairRadius for this
        # family -- the Separator craftTime precedent): the
        # repair-point def is the fallback for an unknown id.
        self.assertIn('SOURCE_REPAIR_POINT_REPAIR_SPEED := 0.45', repair_turret)
        self.assertIn('SOURCE_REPAIR_POINT_REPAIR_RADIUS := 60.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_REPAIR_SPEED := 3.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_REPAIR_RADIUS := 145.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_HEAL_ANGLE_MARGIN := 30.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_ROTATION_SLERP_PROGRESS := 0.5', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_STRENGTH_LERP_PROGRESS := 0.08', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_ROTATION_DEFAULT := 90.0', repair_turret)
        self.assertIn('_repair_speed_for_block(block_id)', repair_turret)
        self.assertIn('_repair_radius_for_block(block_id)', repair_turret)
        # The shared math helpers do the angle / angleDist /
        # lerpDelta work; the slerpDelta is a local
        # transliteration (the N2191 precedent -- the port has
        # no slerp helper, no separate symbol).
        self.assertIn('source_math_state.source_angles_angle(', repair_turret)
        self.assertIn('source_math_state.source_angles_angle_dist(', repair_turret)
        self.assertIn('source_math_state.source_lerp_delta(', repair_turret)
        self.assertIn('_repair_turret_slerp_delta(', repair_turret)
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
        # list: no live unit query exists in the port, so no
        # live re-acquire happens (the N2212 live-acquire entry
        # stays deferred); only the clear / heal / rotation /
        # strength lines run live.
        self.assertIn('game_source_delta(game, seconds)', repair_turret)
        self.assertIn('time_scale(sprite', repair_turret)
        self.assertIn('source_repair_turret_update_tile_advance_state(frame, source_delta, time_scale, advance_repair_speed, advance_repair_radius, advance_building_x, advance_building_y, [])', repair_turret)
        self.assertIn('tile_drawx_state(', repair_turret)
        self.assertIn('tile_drawy_state(', repair_turret)
        self.assertIn('source_world_defaults.TILESIZE', repair_turret)
        self.assertIn('frame["target"]', repair_turret)
        self.assertIn('frame["offset"]', repair_turret)
        self.assertIn('frame["strength"]', repair_turret)
        self.assertIn('frame["rotation"]', repair_turret)
        self.assertIn('frame["heal_amount"]', repair_turret)
        self.assertIn('frame["healed"]', repair_turret)
        # The frame reads carry the Java field defaults: target
        # null (RepairTurret.java:154), strength 0.0 / rotation
        # 90 (RepairTurret.java:156), efficiency 0.0
        # (BuildingComp.java:85). The health branch of the
        # clear fires only when the target dict carries BOTH
        # health and max_health -- a dict without health data
        # is not known to be full.
        self.assertIn('frame.get("target", null)', repair_turret)
        self.assertIn('frame.get("strength", 0.0)', repair_turret)
        self.assertIn('frame.get("rotation", SOURCE_REPAIR_TURRET_ROTATION_DEFAULT)', repair_turret)
        self.assertIn('frame.get("efficiency", 0.0)', repair_turret)
        self.assertIn('target.has("health") and target.has("max_health")', repair_turret)
        # The documented limits now record the advance as done
        # and the remaining deferrals (heal application, timer
        # re-acquire cadence, coolant multiplier); the
        # shouldConsume gate stays live (N2212).
        self.assertIn('updateTile advance live (N2226)', repair_turret)
        self.assertNotIn('No updateTile heal advance', repair_turret)
        self.assertIn('shouldConsume gate live (N2212)', repair_turret)
        # The proof's keys drive the pure advance (target clear
        # on dead / out-of-range / full health, rotation slerp
        # toward the target with the wrap, strength lerp toward
        # 1 while healing and toward 0 while not, the heal
        # amount fold repairSpeed * strength * edelta() *
        # multiplier, the re-acquire picking the closest
        # damaged valid in-range candidate) plus the live tick
        # (a placed repair-point with a seeded target heals by
        # the folded efficiency and writes the advance keys
        # onto the frame; with no target nothing heals and
        # strength decays).
        proof = REPAIR_TURRET_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'target_clears_when_dead_or_out_of_range',
            'rotation_slerps_toward_target',
            'strength_approaches_one_when_healing',
            'heal_amount_folds_repair_speed_strength',
            'reacquire_picks_closest_damaged_candidate',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRepairTurretBuildState.gd")', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_update_tile_advance_state(', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REPAIR_TURRET_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REPAIR_TURRET_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTurretUpdateTileProof.gd', scene)
        self.assertIn('C07RepairTurretUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_repair_turret_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'target_clears_when_dead_or_out_of_range',
            'rotation_slerps_toward_target',
            'strength_approaches_one_when_healing',
            'heal_amount_folds_repair_speed_strength',
            'reacquire_picks_closest_damaged_candidate',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
