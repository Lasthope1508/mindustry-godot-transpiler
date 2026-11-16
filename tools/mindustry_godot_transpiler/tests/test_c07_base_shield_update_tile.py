import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE_SHIELD_STATE = ROOT / 'godot-mindustry/src/game/SourceBaseShieldBuildState.gd'
BASE_SHIELD_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldUpdateTileProof.gd'
BASE_SHIELD_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldUpdateTileProof.tscn'


class C07BaseShieldUpdateTileTests(unittest.TestCase):
    def test_c07_base_shield_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2236']['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_update_tile_advance_state')
        # N2159 gave the shield-projector / large-shield-projector
        # its live power.status read -- but the port tracked no
        # smoothRadius at all, so a shield never grew, never
        # absorbed a bullet, never repelled a unit. N2236 is the
        # updateTile advance (BaseShieldBuild.updateTile(),
        # BaseShield.java:88-99): the smoothRadius lerpDelta
        # toward radius * efficiency (:89), the rad > 1 engage
        # gate (:93), the Groups.bullet RECTANGLE intersect +
        # bulletConsumer (:27-37, enemy team + absorbable +
        # strict within radius() -- the hit/buildup lines :33-34
        # are COMMENTED OUT, so absorb is effect-only and there
        # is no buildup field at all), and the
        # Units.nearbyEnemies (rad + 10f) + unitConsumer
        # (:38-53, overlapDst = hitSize/2 + radius() - dst; the
        # instakill branch overlapDst > hitSize * 1.5f kills,
        # otherwise vel.setZero + move away overlapDst + 0.01f
        # -- both as PURE RESULTS, never applied to a live
        # bullet or unit). broken/hit are NEVER set live: the
        # only broken writes are the false field init (:83) and
        # the save read (:167), and hit is set only in the
        # commented-out line (:33) -- so the advance tracks no
        # broken/hit keys. Four new result symbols: the advanced
        # smooth radius, the absorbed bullets, the repelled
        # units (with repel vectors), and the killed units.
        self.assertEqual(
            ledger['N2236']['source_symbols'],
            [
                'source_base_shield_update_tile_advance_state_result.smooth_radius',
                'source_base_shield_update_tile_advance_state_result.absorbed_bullets',
                'source_base_shield_update_tile_advance_state_result.repelled_units',
                'source_base_shield_update_tile_advance_state_result.killed_units',
            ],
        )
        for name in ledger['N2236']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BaseShield.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_update_tile_advance_state')
        self.assertEqual(ledger['N2236']['runtime_proof'], '/root/C07BaseShieldUpdateTileProof')
        self.assertEqual(
            ledger['N2236']['tests'],
            [
                'test_c07_base_shield_update_tile_registration',
                'test_all_c07_base_shield_update_tile_input_evidence_is_exact',
                'test_base_shield_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_base_shield_update_tile',
            ],
        )
        self.assertTrue(ledger['N2236']['deferred_exprs'])
        # This slice resolves the BaseShield updateTile advance
        # deferral, so the advance entry is gone from DEFERRED
        # -- while the live-fill entry (live bullet scan fill +
        # live enemy-unit scan fill + absorb/repel/kill
        # application + spark effect) takes its place.
        self.assertFalse(any(entry.startswith('BaseShield updateTile advance (') for entry in ledger['N2236']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BaseShield updateTile live fill (') for entry in ledger['N2236']['deferred_exprs']))

    def test_all_c07_base_shield_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2236']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BaseShield.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/EntityGroup.java',
            'core/src/mindustry/entities/GroupDefs.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/game/Team.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta / within / dst / setLength / Time.delta
        # formulas live in Arc, not Mindustry: Mathf.java,
        # Position.java, Vec2.java and Time.java under
        # arc-upstream (the N2229 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Position.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Vec2.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Vec2.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2236']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_shield_update_tile_advance_state(self):
        base_shield = BASE_SHIELD_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the base-shield build state:
        # BaseShieldBuild.updateTile() (BaseShield.java:88-99).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # The smoothRadius fold is lerpDelta (Mathf.java:430-432,
        # `return lerp(fromValue, toValue, clamp(progress *
        # Time.delta));` -- progress * delta CLAMPED, not the pow
        # form), toward radius * efficiency with the block
        # radius (200f shield-projector, the class default,
        # BaseShield.java:20 / 400f large-shield-projector,
        # Blocks.java:2060). rad is radius() = smoothRadius
        # (BaseShield.java:101-103) -- the SCAN and the absorb /
        # repel checks use the SMOOTH radius, not the block
        # radius field (the scope-correction grep: the
        # bulletConsumer within and the unitConsumer overlapDst
        # both read paramBuild.radius()). The bullet within is
        # STRICT (Position.java:44-46, dst2 < rad^2): exactly at
        # the radius is OUT. The unit overlap uses the REAL dst
        # (Position.java:28-32, sqrt), not dst2. The repel
        # vector is (unit - build) setLength(overlapDst +
        # 0.01f), and setLength on a ZERO vector stays zero
        # (Vec2.java:304-308, oldLen2 == 0 returns this) -- a
        # unit exactly on the building gets a (0, 0) repel. The
        # instakill boundary is STRICT (overlapDst > hitSize *
        # 1.5f): exactly 1.5x repels. Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        # broken/hit are NEVER set live (grep: broken only at
        # the :83 false init and the :167 save read; hit only
        # in the commented-out :33 line), so there are no
        # broken/hit frame keys and no buildup anywhere.
        self.assertIn('static func source_base_shield_update_tile_advance_state', base_shield)
        self.assertIn('public float radius = 200f;', base_shield)
        self.assertIn('public int sides = 24;', base_shield)
        self.assertIn('public boolean broken = false;', base_shield)
        self.assertIn('public float hit = 0f;', base_shield)
        self.assertIn('public float smoothRadius;', base_shield)
        self.assertIn('smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);', base_shield)
        self.assertIn('float rad = radius();', base_shield)
        self.assertIn('if(rad > 1){', base_shield)
        self.assertIn('paramBuild = this;', base_shield)
        self.assertIn('Groups.bullet.intersect(x - rad, y - rad, rad * 2f, rad * 2f, bulletConsumer);', base_shield)
        self.assertIn('Units.nearbyEnemies(team, x, y, rad + 10f, unitConsumer);', base_shield)
        self.assertIn('public float radius(){', base_shield)
        self.assertIn('return smoothRadius;', base_shield)
        self.assertIn('if(bullet.team != paramBuild.team && bullet.type.absorbable && bullet.within(paramBuild, paramBuild.radius())){', base_shield)
        self.assertIn('bullet.absorb();', base_shield)
        self.assertIn('//paramBuild.hit = 1f;', base_shield)
        self.assertIn('//paramBuild.buildup += bullet.damage;', base_shield)
        self.assertIn('float overlapDst = (unit.hitSize/2f + paramBuild.radius()) - unit.dst(paramBuild);', base_shield)
        self.assertIn('if(overlapDst > 0){', base_shield)
        self.assertIn('if(overlapDst > unit.hitSize * 1.5f){', base_shield)
        self.assertIn('unit.kill();', base_shield)
        self.assertIn('unit.vel.setZero();', base_shield)
        self.assertIn('unit.move(Tmp.v1.set(unit).sub(paramBuild).setLength(overlapDst + 0.01f));', base_shield)
        self.assertIn('if(Mathf.chanceDelta(0.12f * Time.delta)){', base_shield)
        self.assertIn('broken = read.bool();', base_shield)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', base_shield)
        self.assertIn('return fromValue + (toValue - fromValue) * progress;', base_shield)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', base_shield)
        self.assertIn('return Mathf.sqrt(xd * xd + yd * yd);', base_shield)
        self.assertIn('return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));', base_shield)
        self.assertIn('private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);', base_shield)
        self.assertIn('shieldProjector = new BaseShield("shield-projector"){{', base_shield)
        self.assertIn('largeShieldProjector = new BaseShield("large-shield-projector"){{', base_shield)
        self.assertIn('requirements(Category.effect, BuildVisibility.editorOnly, with());', base_shield)
        self.assertIn('radius = 400f;', base_shield)
        self.assertIn('consumePower(5f);', base_shield)
        self.assertIn('transient boolean enabled = true;', base_shield)
        self.assertIn('transient float efficiency;', base_shield)
        self.assertIn('updateConsumption();', base_shield)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', base_shield)
        self.assertIn('set(tile.drawx(), tile.drawy());', base_shield)
        self.assertIn('public boolean noUpdateDisabled = false;', base_shield)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', base_shield)
        self.assertIn('return block().offset + worldx();', base_shield)
        self.assertIn('return block().offset + worldy();', base_shield)
        self.assertIn('public static void nearbyEnemies(Team team, float x, float y, float radius, Cons<Unit> cons){', base_shield)
        self.assertIn('if(u.within(x, y, radius + u.hitSize/2f)){', base_shield)
        self.assertIn('public void intersect(float x, float y, float width, float height, Cons<? super T> out){', base_shield)
        self.assertIn('@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;', base_shield)
        self.assertIn('public void absorb(){', base_shield)
        self.assertIn('absorbed = true;', base_shield)
        self.assertIn('public boolean absorbable = true;', base_shield)
        self.assertIn('public void kill(){', base_shield)
        self.assertIn('if(dead || net.client() || !killable()) return;', base_shield)
        # The def radii are driver constants (the catalog
        # carries neither radius -- the Separator craftTime
        # precedent): 200f for the shield-projector (the class
        # default, BaseShield.java:20) and 400f for the
        # large-shield-projector (Blocks.java:2060), selected
        # by block id (the _separator_craft_time_for_block
        # precedent).
        self.assertIn('SOURCE_BASE_SHIELD_RADIUS := 200.0', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_LARGE_RADIUS := 400.0', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_SMOOTH_RADIUS_DEFAULT := 0.0', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_SMOOTH_RADIUS_LERP := 0.05', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_ENGAGE_RADIUS := 1.0', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_NEARBY_MARGIN := 10.0', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_KILL_MULTIPLIER := 1.5', base_shield)
        self.assertIn('SOURCE_BASE_SHIELD_REPEL_EPSILON := 0.01', base_shield)
        self.assertIn('static func _base_shield_radius_for_block(block_id: String) -> float:', base_shield)
        self.assertIn('if block_id == "large-shield-projector":', base_shield)
        # The shared math helper does the lerpDelta work; the
        # bullet within is the STRICT dst2 < rad^2; the unit
        # overlap uses the real dst.
        self.assertIn('source_math_state.source_lerp_delta(', base_shield)
        self.assertIn('bullet_dst2 < rad * rad', base_shield)
        # N2337: the unit overlap uses the real dst via the
        # GDScript global sqrt() -- NOT sqrtf(), which does not
        # exist in GDScript and blocked the N2236 proof from
        # starting (the FIRST real Godot error, found by the
        # user running Godot 4.6.2 on wave-13; the sqrtf call
        # came from N2236 itself). The formula is Java-exact:
        # unit.dst(paramBuild) is Mathf.sqrt(xd*xd + yd*yd)
        # (Position.java:28-32), so only the function name
        # changes. The pure distance logic is not separable at
        # the Python layer (it lives in the GDScript advance),
        # so the grep pin below plus the Java read is the RED
        # evidence for this fix slice.
        self.assertIn('sqrt(unit_dx * unit_dx + unit_dy * unit_dy)', base_shield)
        self.assertNotIn('sqrtf(', base_shield)
        self.assertIn('overlap_dst > hit_size * SOURCE_BASE_SHIELD_KILL_MULTIPLIER', base_shield)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds); the
        # advance runs after consumption, like Java's
        # Building.update() (BuildingComp.java:2274
        # updateConsumption(), then the updateTile gate
        # `if(enabled || !block.noUpdateDisabled){` at
        # BuildingComp.java:2276-2277; noUpdateDisabled
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
        # (Block.java:761) -- 0 for the size-3 shield-projector,
        # 4 for the size-4 large-shield-projector. The driver
        # passes the N2328 SCANNED bullet and enemy-unit lists
        # (the frame candidates filtered by the rect /
        # nearbyEnemies scan pures, gated on scan_rad > 1 --
        # the tick computes scan_rad with the same lerpDelta
        # helper + const the advance uses); with no supplied
        # candidates the lists are empty and only the
        # smoothRadius fold runs live (the live Groups.bullet /
        # Units queries still defer).
        self.assertIn('game_source_delta(game, seconds)', base_shield)
        self.assertIn('source_base_shield_update_tile_advance_state(frame, source_delta, advance_shield_radius, advance_building_x, advance_building_y, scanned_bullets, scanned_enemy_units)', base_shield)
        self.assertIn('tile_drawx_state(', base_shield)
        self.assertIn('tile_drawy_state(', base_shield)
        self.assertIn('source_world_defaults.TILESIZE', base_shield)
        self.assertIn('frame["smooth_radius"]', base_shield)
        self.assertIn('frame["absorbed_bullets"]', base_shield)
        self.assertIn('frame["repelled_units"]', base_shield)
        self.assertIn('frame["killed_units"]', base_shield)
        # The frame reads carry the Java field defaults:
        # smoothRadius 0.0 (BaseShield.java:85, no initializer),
        # efficiency 0.0 (BuildingComp.java:85), team_id
        # derelict (the tick wiring default). A bullet without
        # a team is never an enemy; a bullet without an
        # absorbable flag defaults to absorbable
        # (BulletType.java:147); a unit without a hit_size
        # defaults to 0.0 (the N2226 repair-turret precedent).
        self.assertIn('frame.get("smooth_radius", SOURCE_BASE_SHIELD_SMOOTH_RADIUS_DEFAULT)', base_shield)
        self.assertIn('frame.get("efficiency", 0.0)', base_shield)
        self.assertIn('frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID)', base_shield)
        self.assertIn('bullet.get("team", team_id)', base_shield)
        self.assertIn('bullet.get("absorbable", true)', base_shield)
        self.assertIn('unit.get("hit_size", 0.0)', base_shield)
        # The documented limits now record the advance as done
        # and the remaining deferrals (live bullet scan fill,
        # live enemy-unit scan fill, absorb/repel/kill
        # application, spark effect); the shouldConsume default
        # (return enabled) still applies.
        self.assertIn('updateTile advance live (N2236)', base_shield)
        self.assertNotIn('No updateTile advance', base_shield)
        # The proof's keys drive the pure advance (the
        # smooth radius tracks efficiency toward radius *
        # efficiency, an enemy bullet inside the radius is
        # absorbed, a same-team bullet is ignored, an enemy
        # unit overlapping the radius is repelled -- and
        # instakilled past hitSize * 1.5 -- and a unit outside
        # the radius is untouched) plus the live tick (a placed
        # shield-projector and a large-shield-projector advance
        # their smooth radius and write the advance keys onto
        # the frame).
        proof = BASE_SHIELD_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'smooth_radius_tracks_efficiency',
            'absorb_blocks_enemy_bullet',
            'absorb_ignores_same_team',
            'repel_pushes_enemy_unit',
            'no_repel_outside_radius',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBaseShieldBuildState.gd")', proof)
        self.assertIn('base_shield_build_state.source_base_shield_update_tile_advance_state(', proof)
        self.assertIn('base_shield_build_state.source_base_shield_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(BASE_SHIELD_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = BASE_SHIELD_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BaseShieldUpdateTileProof.gd', scene)
        self.assertIn('C07BaseShieldUpdateTileProof', scene)

    def test_no_c_style_float_math_functions_in_gdscript(self):
        # N2337 sweep: GDScript has NO C-style float-suffixed
        # math functions (sinf/cosf/tanf/powf/expf/logf/asinf/
        # acosf/atanf/sinhf/coshf/tanhf/fmodf/sqrtf) -- the
        # globals are sqrt/sin/cos/tan/pow/exp/log/asin/acos/
        # atan/sinh/cosh/tanh/fmod. The f-suffixed clampf/minf/
        # maxf/absf/lerpf/floorf/ceilf DO exist in Godot 4 and
        # must NOT be flagged. The N2236 sqrtf() at
        # SourceBaseShieldBuildState.gd:121 was the only hit
        # in the whole godot-mindustry tree (verified by grep
        # 2026-11-16); this pin keeps the sweep durable so a
        # future slice cannot reintroduce one.
        import re

        banned = re.compile(r'\b(sinf|cosf|tanf|powf|expf|logf|log2f|asinf|acosf|atanf|atan2f|sinhf|coshf|tanhf|fmodf|sqrtf)\(')
        hits = []
        for gd_file in sorted((ROOT / 'godot-mindustry').rglob('*.gd')):
            for line_no, line in enumerate(gd_file.read_text(encoding='utf-8').splitlines(), 1):
                if banned.search(line):
                    hits.append(f'{gd_file.relative_to(ROOT)}:{line_no}:{line.strip()}')
        self.assertEqual(hits, [])

    def test_reference_graph_and_actual_c07_base_shield_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseShieldUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_SHIELD_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'smooth_radius_tracks_efficiency',
            'absorb_blocks_enemy_bullet',
            'absorb_ignores_same_team',
            'repel_pushes_enemy_unit',
            'no_repel_outside_radius',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
