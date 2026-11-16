import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_DRAW_BEAM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawBeamProof.gd'


class C07RepairTurretDrawBeamTests(unittest.TestCase):
    def test_c07_repair_turret_draw_beam_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2219']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_draw_beam_state')
        # N2212-N2215 made the repair turret live (target acquire,
        # heal advance, rotation slerp, strength lerp) and N2217
        # persisted its rotation -- but nothing in the port captured
        # what draw() draws each frame: RepairPointBuild.draw()
        # calls the static drawBeam (RepairTurret.java:171-173,
        # inside `public void draw(){`, RepairTurret.java:164-174),
        # which computes the beam origin from the turret position,
        # rotation and length (`originX = x +
        # Angles.trnsx(rotation, length),` / `originY = y +
        # Angles.trnsy(rotation, length);`,
        # RepairTurret.java:115-116), moves the beam endpoint to
        # the target and clamps it to at least 2f from the origin
        # (`lastEnd.set(target).sub(originX, originY);` /
        # `lastEnd.setLength(Math.max(2f, lastEnd.len()));`,
        # RepairTurret.java:118-119), and draws the laser only
        # while the beam is strong (`if(strength > 0.01f){`,
        # RepairTurret.java:129) with width `strength * beamWidth`
        # (`Drawf.laser(laser, laserEnd, originX, originY,
        # lastEnd.x, lastEnd.y, strength * beamWidth);`,
        # RepairTurret.java:145) and pulse stroke `strength *
        # pulseStroke` (`Lines.stroke(strength * pulseStroke);`,
        # RepairTurret.java:141). RED decisions (resolved at RED,
        # recorded in the register docstring): (1) One pure
        # function on the same family file N2174 / N2188 / N2209 /
        # N2212-N2215 / N2217 built, returning the deterministic
        # beam state: beam_origin, beam_end, beam_visible,
        # beam_width, pulse_stroke, has_target. Rendering itself
        # stays out of the game -- only the state the beam depends
        # on is captured, per the user boundary. (2) beam_end is
        # the PRE-JITTER endpoint: the random jitter
        # (`lastEnd.add(offset.trns(...))`,
        # RepairTurret.java:121-124, three rand.random calls plus
        # Time.time) and the pulse phase (`float f = (Time.time /
        # 85f + rand.random(1f)) % 1f;`, RepairTurret.java:138,
        # driving the pulse alpha and circle radius,
        # RepairTurret.java:140-142) need arc Rand modeling and
        # wait for a Rand-modeling slice -- they are deferred, not
        # guessed. (3) With no target the endpoint is STALE: Java
        # leaves lastEnd untouched (`if(target != null){`,
        # RepairTurret.java:113, guards the whole endpoint branch),
        # so the function returns the frame's stored last_end
        # (Vector2.ZERO when the frame carries none, the `new
        # Vec2()` field default, RepairTurret.java:155). (4) The
        # driver calls the pure function once per tick AFTER the
        # N2215 strength lerp (draw() runs after updateTile in the
        # frame loop, so the beam reads the tick's final
        # target/rotation/strength), stamping beam_origin,
        # last_end (= beam_end), beam_visible, beam_width and
        # pulse_stroke on the frame. (5) length / beamWidth are
        # per-def params resolved by the driver (repair-point
        # length 5f class default, beamWidth 0.73f,
        # Blocks.java:6390; repair-turret length 6f,
        # Blocks.java:6399, beamWidth 1.1f, Blocks.java:6403;
        # class defaults `public float length = 5f;` /
        # `public float beamWidth = 1f;`,
        # RepairTurret.java:35-36); pulseStroke is the 2f class
        # default (`public float pulseStroke = 2f;`,
        # RepairTurret.java:38), overridden by neither def, so the
        # driver passes the 2.0 literal. (6) drawSelect /
        # drawPlace dash circles (`Drawf.dashCircle(x, y,
        # repairRadius, Pal.accent);`, RepairTurret.java:178 and
        # :98) are selection/placement rendering, not the beam --
        # deferred to their own slice. Six new result symbols:
        # beam_origin, beam_end, beam_visible, beam_width,
        # pulse_stroke, has_target.
        self.assertEqual(
            ledger['N2219']['source_symbols'],
            [
                'source_repair_turret_draw_beam_state_result.beam_origin',
                'source_repair_turret_draw_beam_state_result.beam_end',
                'source_repair_turret_draw_beam_state_result.beam_visible',
                'source_repair_turret_draw_beam_state_result.beam_width',
                'source_repair_turret_draw_beam_state_result.pulse_stroke',
                'source_repair_turret_draw_beam_state_result.has_target',
            ],
        )
        for name in ledger['N2219']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2219']['runtime_proof'], '/root/C07RepairTurretDrawBeamProof')
        self.assertEqual(
            ledger['N2219']['tests'],
            [
                'test_c07_repair_turret_draw_beam_registration',
                'test_all_c07_repair_turret_draw_beam_input_evidence_is_exact',
                'test_repair_turret_draw_beam_state',
                'test_reference_graph_and_actual_c07_repair_turret_draw_beam',
            ],
        )
        self.assertTrue(ledger['N2219']['deferred_exprs'])

    def test_all_c07_repair_turret_draw_beam_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2219']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2219']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_draw_beam_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairPointBuild.draw() calls the static drawBeam
        # (RepairTurret.java:171-173, inside `public void draw(){`,
        # RepairTurret.java:164-174): the beam origin is the
        # turret position plus the rotated length (`originX = x +
        # Angles.trnsx(rotation, length),` / `originY = y +
        # Angles.trnsy(rotation, length);`,
        # RepairTurret.java:115-116); with a target the endpoint
        # is the target position relative to the origin, clamped
        # to at least 2f (`lastEnd.set(target).sub(originX,
        # originY);` / `lastEnd.setLength(Math.max(2f,
        # lastEnd.len()));`, RepairTurret.java:118-119); with no
        # target the endpoint stays stale -- Java leaves lastEnd
        # untouched (`if(target != null){`,
        # RepairTurret.java:113), so the function returns the
        # frame's stored last_end (Vector2.ZERO when absent, the
        # `new Vec2()` field default, `public Vec2 offset = new
        # Vec2(), lastEnd = new Vec2();`,
        # RepairTurret.java:155). The laser draws only while the
        # beam is strong (`if(strength > 0.01f){`,
        # RepairTurret.java:129, STRICT -- 0.01f itself does not
        # draw) with width `strength * beamWidth`
        # (RepairTurret.java:145) and pulse stroke `strength *
        # pulseStroke` (`Lines.stroke(strength * pulseStroke);`,
        # RepairTurret.java:141). The random jitter
        # (`lastEnd.add(offset.trns(`, /
        # `rand.random(360f) + Time.time/2f,` /
        # `Mathf.sin(Time.time + rand.random(200f), 55f,
        # rand.random(target.hitSize() * 0.2f, target.hitSize() *
        # 0.45f))`, RepairTurret.java:121-123) and the pulse phase
        # (`float f = (Time.time / 85f + rand.random(1f)) % 1f;` /
        # `Draw.alpha(1f - Interp.pow5In.apply(f));` /
        # `Lines.circle(lastEnd.x, lastEnd.y, 1f + f *
        # pulseRadius);`, RepairTurret.java:138-142) are DEFERRED
        # -- they need arc Rand modeling, so the endpoint this
        # slice returns is the pre-jitter position and there is no
        # pulse-circle radius key. The driver calls the pure
        # function once per tick AFTER the N2215 strength lerp
        # (draw() runs after updateTile), stamping beam_origin,
        # last_end, beam_visible, beam_width and pulse_stroke;
        # length / beamWidth are per-def driver params
        # (repair-point 5f / 0.73f, repair-turret 6f / 1.1f,
        # Blocks.java:6390/6399/6403; class defaults `public float
        # length = 5f;` / `public float beamWidth = 1f;`,
        # RepairTurret.java:35-36) and pulseStroke is the 2f class
        # default (`public float pulseStroke = 2f;`,
        # RepairTurret.java:38), overridden by neither def.
        self.assertIn('static func source_repair_turret_draw_beam_state(frame: Dictionary, x: float, y: float, rotation: float, length: float, beam_width: float, pulse_stroke: float) -> Dictionary:', repair_turret)
        self.assertIn('var beam_origin: Vector2 = Vector2(x + cos(deg_to_rad(rotation)) * length, y + sin(deg_to_rad(rotation)) * length)', repair_turret)
        self.assertIn('var strength: float = float(frame.get("strength", 0.0))', repair_turret)
        self.assertIn('var target: Variant = frame.get("target", null)', repair_turret)
        self.assertIn('var has_target: bool = target is Dictionary', repair_turret)
        self.assertIn('var beam_end: Vector2 = frame.get("last_end", Vector2.ZERO)', repair_turret)
        self.assertIn('if has_target:', repair_turret)
        self.assertIn('var rel: Vector2 = Vector2(float(target.get("x", 0.0)), float(target.get("y", 0.0))) - beam_origin', repair_turret)
        self.assertIn('if rel.length() > 0.0:', repair_turret)
        self.assertIn('rel = rel.normalized() * maxf(2.0, rel.length())', repair_turret)
        self.assertIn('beam_end = beam_origin + rel', repair_turret)
        self.assertIn('return {"beam_origin": beam_origin, "beam_end": beam_end, "beam_visible": strength > 0.01, "beam_width": strength * beam_width, "pulse_stroke": strength * pulse_stroke, "has_target": has_target}', repair_turret)
        self.assertIn('var beam: Dictionary = source_repair_turret_draw_beam_state(frame, sprite.position.x, sprite.position.y, float(frame.get("rotation", 90.0)), _beam_length_for_block_id(block_id), _beam_width_for_block_id(block_id), 2.0)', repair_turret)
        self.assertIn('frame["beam_origin"] = beam.get("beam_origin", Vector2.ZERO)', repair_turret)
        self.assertIn('frame["last_end"] = beam.get("beam_end", Vector2.ZERO)', repair_turret)
        self.assertIn('frame["beam_visible"] = beam.get("beam_visible", false)', repair_turret)
        self.assertIn('frame["beam_width"] = beam.get("beam_width", 0.0)', repair_turret)
        self.assertIn('frame["pulse_stroke"] = beam.get("pulse_stroke", 0.0)', repair_turret)
        for expr in [
            'public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,',
            'float strength, float pulseStroke, float pulseRadius, float beamWidth,',
            'Vec2 lastEnd, Vec2 offset,',
            'rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));',
            'if(target != null){',
            'originX = x + Angles.trnsx(rotation, length),',
            'originY = y + Angles.trnsy(rotation, length);',
            'lastEnd.set(target).sub(originX, originY);',
            'lastEnd.setLength(Math.max(2f, lastEnd.len()));',
            'lastEnd.add(offset.trns(',
            'rand.random(360f) + Time.time/2f,',
            'Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))',
            'lastEnd.add(originX, originY);',
            'if(strength > 0.01f){',
            'float f = (Time.time / 85f + rand.random(1f)) % 1f;',
            'Draw.alpha(1f - Interp.pow5In.apply(f));',
            'Lines.stroke(strength * pulseStroke);',
            'Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);',
            'Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);',
            'drawBeam(x, y, rotation, length, id, target, team, strength,',
            'public float strength, rotation = 90;',
            'public float length = 5f;',
            'public float beamWidth = 1f;',
            'public float pulseRadius = 6f;',
            'public float pulseStroke = 2f;',
            'public Vec2 offset = new Vec2(), lastEnd = new Vec2();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function with synthetic
        # frames (no live tick: the beam state is pure geometry
        # from frame values -- target, strength, last_end -- plus
        # explicit per-def params): origin at rotation 90 / origin
        # at rotation 0 / endpoint clamps to min length 2 / endpoint
        # uses the target position / endpoint stays stale without
        # a target / beam visible above the strength threshold /
        # beam hidden at the threshold / widths scale with
        # strength (repair-turret per-def values). There are no
        # jitter / pulse-phase keys: the Rand sequence waits for
        # its own slice. There is no live-tick key: the driver
        # wiring is pinned by the call + stamp asserts above.
        proof = REPAIR_TURRET_DRAW_BEAM_PROOF.read_text(encoding='utf-8')
        for key in [
            'beam_origin_at_rotation_90',
            'beam_origin_at_rotation_0',
            'beam_end_clamps_to_min_length_2',
            'beam_end_uses_target_position',
            'beam_end_stale_without_target',
            'beam_visible_above_threshold',
            'beam_hidden_at_threshold',
            'beam_width_scales_with_strength',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_draw_beam(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretDrawBeamProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_DRAW_BEAM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'beam_origin_at_rotation_90',
            'beam_origin_at_rotation_0',
            'beam_end_clamps_to_min_length_2',
            'beam_end_uses_target_position',
            'beam_end_stale_without_target',
            'beam_visible_above_threshold',
            'beam_hidden_at_threshold',
            'beam_width_scales_with_strength',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
