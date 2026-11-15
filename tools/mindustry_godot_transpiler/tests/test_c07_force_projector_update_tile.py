import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorUpdateTileProof.gd'
FORCE_PROJECTOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorUpdateTileProof.tscn'


class C07ForceProjectorUpdateTileTests(unittest.TestCase):
    def test_c07_force_projector_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2235']['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_update_tile_advance_state')
        # N2158 gave the force-projector its live power.status
        # read -- but the port tracked no phaseHeat / radscl /
        # warmup / buildup / broken / hit state at all, so a
        # force projector never charged its shield, never
        # cooled down, never broke, never deflected a bullet.
        # N2235 is the updateTile advance
        # (ForceBuild.updateTile(),
        # ForceProjector.java:207-268): the phaseValid /
        # phaseHeat fold (:208-210), the consume gate
        # (:212-214, timer cadence + consume() application
        # deferred, reported as a pure `consumed` result), the
        # radscl fold toward the OLD warmup (:216, before the
        # warmup update at :222), the buildup cooldown with
        # the coolant branch (:224-237, explicit coolant
        # inputs), the broken clear (:239-241) and set
        # (:243-251, threshold folds the NEW phaseHeat), the
        # hit decay (:253-255, Time.delta, not delta()), and
        # deflectBullets (:257-268) through the faithfully
        # ported Intersector.isInRegularPolygon, with the
        # absorbed bullets + buildup delta as pure results
        # (no live bullet is written). Ten new result
        # symbols: the six advanced fields, the consumed
        # flag, the absorbed list, the buildup delta, and the
        # real radius.
        self.assertEqual(
            ledger['N2235']['source_symbols'],
            [
                'source_force_projector_update_tile_advance_state_result.phase_heat',
                'source_force_projector_update_tile_advance_state_result.radscl',
                'source_force_projector_update_tile_advance_state_result.warmup',
                'source_force_projector_update_tile_advance_state_result.buildup',
                'source_force_projector_update_tile_advance_state_result.broken',
                'source_force_projector_update_tile_advance_state_result.hit',
                'source_force_projector_update_tile_advance_state_result.consumed',
                'source_force_projector_update_tile_advance_state_result.absorbed_bullets',
                'source_force_projector_update_tile_advance_state_result.buildup_delta',
                'source_force_projector_update_tile_advance_state_result.real_radius',
            ],
        )
        for name in ledger['N2235']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ForceProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_update_tile_advance_state')
        self.assertEqual(ledger['N2235']['runtime_proof'], '/root/C07ForceProjectorUpdateTileProof')
        self.assertEqual(
            ledger['N2235']['tests'],
            [
                'test_c07_force_projector_update_tile_registration',
                'test_all_c07_force_projector_update_tile_input_evidence_is_exact',
                'test_force_projector_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_force_projector_update_tile',
            ],
        )
        self.assertTrue(ledger['N2235']['deferred_exprs'])
        # This slice resolves the ForceProjector updateTile
        # advance deferral, so the advance entry is gone from
        # DEFERRED -- while the live-fill entry (timer
        # cadence + consume() application + live bullet scan
        # + absorb application + coolant live fill + effects /
        # sound / event) and the absorbExplosion entry (a
        # separate method, ForceProjector.java:271-281) take
        # its place.
        self.assertFalse(any(entry.startswith('ForceProjector updateTile advance (') for entry in ledger['N2235']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector updateTile live fill (') for entry in ledger['N2235']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector absorbExplosion rows (') for entry in ledger['N2235']['deferred_exprs']))

    def test_all_c07_force_projector_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2235']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
            'core/src/mindustry/entities/EntityGroup.java',
            'core/src/mindustry/entities/GroupDefs.java',
            'core/src/mindustry/type/Liquid.java',
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta / num / chanceDelta / isInRegularPolygon
        # / isInPolygon / trns formulas live in Arc, not
        # Mindustry: Mathf.java, Intersector.java, Vec2.java
        # and Time.java under arc-upstream (the N2191
        # precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Intersector.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Intersector.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Vec2.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Vec2.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2235']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_update_tile_advance_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the force-projector build
        # state: ForceBuild.updateTile()
        # (ForceProjector.java:207-268). Keep each Java expr
        # on ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The Arc formulas are
        # lerpDelta(from, to, progress) = lerp(from, to,
        # clamp(progress * Time.delta)) (Mathf.java:430-432),
        # num(boolean) = 1 / 0 (Mathf.java:208-210),
        # chanceDelta(d) = rand < d * Time.delta
        # (Mathf.java:236-238), isInRegularPolygon building
        # its vertices with Vec2.trns (Intersector.java:
        # 111-119, Vec2.java:40-42) and testing them with the
        # float-array isInPolygon ray cast
        # (Intersector.java:180-193). Time.delta in the port
        # is seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x
        # slow). NOTE the ordering traps: radscl lerps toward
        # the OLD warmup (:216 runs before the warmup update
        # at :222); the broken-set threshold folds the NEW
        # phaseHeat (:210 runs before :243); deflectBullets
        # runs LAST, so absorbed buildup cannot break the
        # shield until the next tick; hit decays (:253-255)
        # BEFORE deflect sets it to 1f. NOTE broken defaults
        # TRUE (ForceProjector.java:167, `public boolean
        # broken = true;`) -- a fresh shield starts broken
        # and clears on the first tick once buildup <= 0.
        # NOTE the coolant branch is LIVE-CAPABLE, not dead:
        # the constructor adds ConsumeCoolant when
        # consumeCoolant is true (ForceProjector.java:84-86,
        # class default true, the def does not override it),
        # so coolantConsumer is non-null -- unlike N2230's
        # parallax. The driver just cannot supply live
        # coolant state (no liquids store on the frame), so
        # it passes no-op defaults and the coolant live fill
        # defers. NOTE buildup has NO clamp: the decay can
        # take it negative, and a negative buildup clears
        # broken (:239-241).
        self.assertIn('static func source_force_projector_update_tile_advance_state', force_projector)
        self.assertIn('static func source_force_projector_is_in_regular_polygon', force_projector)
        self.assertIn('boolean phaseValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;', force_projector)
        self.assertIn('phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);', force_projector)
        self.assertIn('if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){', force_projector)
        self.assertIn('consume();', force_projector)
        self.assertIn('radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);', force_projector)
        self.assertIn('if(Mathf.chanceDelta(buildup / shieldHealth * 0.1f)){', force_projector)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);', force_projector)
        self.assertIn('float scale = !broken ? cooldownNormal : cooldownBrokenBase;', force_projector)
        self.assertIn('if(coolantConsumer != null){', force_projector)
        self.assertIn('if(coolantConsumer.efficiency(this) > 0){', force_projector)
        self.assertIn('coolantConsumer.update(this);', force_projector)
        self.assertIn('scale *= (cooldownLiquid * (1f + (liquids.current().heatCapacity - 0.4f) * 0.9f));', force_projector)
        self.assertIn('buildup -= delta() * scale;', force_projector)
        self.assertIn('if(broken && buildup <= 0){', force_projector)
        self.assertIn('broken = false;', force_projector)
        self.assertIn('if(buildup >= shieldHealth + phaseShieldBoost * phaseHeat && !broken){', force_projector)
        self.assertIn('broken = true;', force_projector)
        self.assertIn('buildup = shieldHealth;', force_projector)
        self.assertIn('if(hit > 0f){', force_projector)
        self.assertIn('hit -= 1f / 5f * Time.delta;', force_projector)
        self.assertIn('deflectBullets();', force_projector)
        self.assertIn('float realRadius = realRadius();', force_projector)
        self.assertIn('if(realRadius > 0 && !broken){', force_projector)
        self.assertIn('Groups.bullet.intersect(x - realRadius, y - realRadius, realRadius * 2f, realRadius * 2f, shieldConsumer);', force_projector)
        self.assertIn('if(bullet.team != paramEntity.team && bullet.type.absorbable && !bullet.absorbed &&', force_projector)
        self.assertIn('Intersector.isInRegularPolygon(paramBlock.sides, paramEntity.x, paramEntity.y, paramEntity.realRadius(), paramBlock.shieldRotation, bullet.x, bullet.y)){', force_projector)
        self.assertIn('bullet.absorb();', force_projector)
        self.assertIn('paramEntity.hit = 1f;', force_projector)
        self.assertIn('paramEntity.buildup += bullet.type.shieldDamage(bullet);', force_projector)
        self.assertIn('return (radius + phaseHeat * phaseRadiusBoost) * radscl;', force_projector)
        self.assertIn('public boolean broken = true;', force_projector)
        self.assertIn('public float buildup, radscl, hit, warmup, phaseHeat;', force_projector)
        self.assertIn('public float phaseUseTime = 350f;', force_projector)
        self.assertIn('public float phaseShieldBoost = 400f;', force_projector)
        self.assertIn('shieldHealth = 750f;', force_projector)
        self.assertIn('cooldownNormal = 1.5f;', force_projector)
        self.assertIn('cooldownLiquid = 1.2f;', force_projector)
        self.assertIn('cooldownBrokenBase = 0.35f;', force_projector)
        self.assertIn('consume(coolantConsumer = new ConsumeCoolant(coolantConsumption)).boost().update(false);', force_projector)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', force_projector)
        self.assertIn('return Time.delta * timeScale;', force_projector)
        self.assertIn('public static boolean isInRegularPolygon(int sides, float cx, float cy, float radius, float rotation, float x, float y){', force_projector)
        self.assertIn('s.trns(i * 360f / sides + rotation, radius);', force_projector)
        self.assertIn('return isInPolygon(floatArray.items, 0, floatArray.size, x, y);', force_projector)
        self.assertIn('if((yi < y && yj >= y) || (yj < y && yi >= y)){', force_projector)
        self.assertIn('if(xi + (y - yi) / (yj - yi) * (polygon[j] - xi) < x) oddNodes = !oddNodes;', force_projector)
        self.assertIn('return set(amount, 0).rotate(angle);', force_projector)
        self.assertIn('return b.damage() * shieldDamageMultiplier;', force_projector)
        self.assertIn('public boolean absorbable = true;', force_projector)
        self.assertIn('absorbed = true;', force_projector)
        self.assertIn('set(tile.drawx(), tile.drawy());', force_projector)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', force_projector)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', force_projector)
        self.assertIn('public boolean noUpdateDisabled = false;', force_projector)
        self.assertIn('return block().offset + worldx();', force_projector)
        self.assertIn('return block().offset + worldy();', force_projector)
        self.assertIn('public float heatCapacity = 0.5f;', force_projector)
        self.assertIn('derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),', force_projector)
        # The def values are driver constants (the catalog
        # carries neither shieldHealth nor the cooldowns nor
        # the radius for this family -- the Separator
        # craftTime precedent): the DEF wins over the class
        # defaults (shieldHealth 750f over 700f, cooldownNormal
        # 1.5f over 1.75f, cooldownLiquid 1.2f over 1.5f;
        # cooldownBrokenBase 0.35f, radius 101.7f and
        # phaseRadiusBoost 80f equal the class values).
        self.assertIn('SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH := 750.0', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_COOLDOWN_NORMAL := 1.5', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_COOLDOWN_LIQUID := 1.2', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_COOLDOWN_BROKEN_BASE := 0.35', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_RADIUS := 101.7', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_PHASE_RADIUS_BOOST := 80.0', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_PHASE_SHIELD_BOOST := 400.0', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_SIDES := 6', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_SHIELD_ROTATION := 0.0', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME := 350.0', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS := 0.1', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_RADSCL_LERP_PROGRESS := 0.05', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_WARMUP_LERP_PROGRESS := 0.1', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK := 0.4', force_projector)
        # The shared math helper does the lerpDelta work; the
        # regular-polygon test is a local faithful
        # transliteration (the port has no isInRegularPolygon
        # helper, no separate symbol -- the N2230 closestEnemy
        # precedent).
        self.assertIn('source_math_state.source_lerp_delta(', force_projector)
        self.assertIn('source_force_projector_is_in_regular_polygon(SOURCE_FORCE_PROJECTOR_SIDES, building_x, building_y, real_radius, SOURCE_FORCE_PROJECTOR_SHIELD_ROTATION,', force_projector)
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
        # (Block.java:761). The driver passes an EMPTY bullet
        # list with the computed consume_tick (live since
        # N2326: the frame-local timerUse cadence, 350f /
        # timeScale): no live bullet query exists in the port,
        # so no live deflect happens (the live-fill entry
        # stays deferred); the item / coolant inputs are live
        # since N2261 / N2258 (the driver stamps them onto
        # the frame before the call).
        self.assertIn('game_source_delta(game, seconds)', force_projector)
        self.assertIn('time_scale(sprite', force_projector)
        self.assertIn('source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, [], consume_tick)', force_projector)
        self.assertIn('tile_drawx_state(', force_projector)
        self.assertIn('tile_drawy_state(', force_projector)
        self.assertIn('source_world_defaults.TILESIZE', force_projector)
        self.assertIn('frame["phase_heat"]', force_projector)
        self.assertIn('frame["radscl"]', force_projector)
        self.assertIn('frame["warmup"]', force_projector)
        self.assertIn('frame["buildup"]', force_projector)
        self.assertIn('frame["broken"]', force_projector)
        self.assertIn('frame["hit"]', force_projector)
        self.assertIn('frame["consumed"]', force_projector)
        self.assertIn('frame["absorbed_bullets"]', force_projector)
        self.assertIn('frame["buildup_delta"]', force_projector)
        self.assertIn('frame["real_radius"]', force_projector)
        # The frame reads carry the Java field defaults:
        # phaseHeat / radscl / warmup / buildup / hit 0.0 and
        # broken TRUE (ForceProjector.java:167-168),
        # efficiency 0.0 (BuildingComp.java:85). The initial
        # frame seeds the same six keys.
        self.assertIn('frame.get("phase_heat", 0.0)', force_projector)
        self.assertIn('frame.get("radscl", 0.0)', force_projector)
        self.assertIn('frame.get("warmup", 0.0)', force_projector)
        self.assertIn('frame.get("buildup", 0.0)', force_projector)
        self.assertIn('frame.get("broken", true)', force_projector)
        self.assertIn('frame.get("hit", 0.0)', force_projector)
        self.assertIn('frame.get("efficiency", 0.0)', force_projector)
        self.assertIn('"phase_heat": 0.0', force_projector)
        self.assertIn('"broken": true', force_projector)
        # The documented limits now record the advance as done
        # and the remaining deferrals (timer cadence, consume()
        # application, live bullet scan, coolant live fill);
        # the phase-radius / phase-shield folds are live too.
        self.assertIn('updateTile advance live (N2235)', force_projector)
        self.assertNotIn('No updateTile advance', force_projector)
        # The proof's keys drive the pure advance (phaseHeat
        # tracks the booster and the consume gate reports
        # through the pure consumed result, radscl follows the
        # OLD warmup while warmup follows efficiency, buildup
        # cools down with the coolant fold and clears broken,
        # broken sets at shieldHealth + phaseShieldBoost *
        # phaseHeat, deflect absorbs an enemy bullet inside
        # the regular polygon and ignores the rest) plus the
        # live tick (a placed force-projector writes the
        # advance keys onto the frame).
        proof = FORCE_PROJECTOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'phase_heat_tracks_booster',
            'radscl_follows_warmup',
            'buildup_cools_down',
            'broken_sets_at_shield_health',
            'deflect_absorbs_bullet_in_polygon',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceForceProjectorBuildState.gd")', proof)
        self.assertIn('force_projector_build_state.source_force_projector_update_tile_advance_state(', proof)
        self.assertIn('force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(FORCE_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FORCE_PROJECTOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorUpdateTileProof.gd', scene)
        self.assertIn('C07ForceProjectorUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_force_projector_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'phase_heat_tracks_booster',
            'radscl_follows_warmup',
            'buildup_cools_down',
            'broken_sets_at_shield_health',
            'deflect_absorbs_bullet_in_polygon',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
