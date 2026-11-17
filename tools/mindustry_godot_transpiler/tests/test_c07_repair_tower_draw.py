import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerDrawProof.gd'


class C07RepairTowerDrawTests(unittest.TestCase):
    def test_c07_repair_tower_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2232']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_draw_state')
        # N2190 / N2191 / N2211 / N2228 / N2229 / N2230 / N2231
        # made the repair tower live (refresh, should-consume,
        # nearby driver, heal advance, ozone consumer, setStats,
        # drawSelect/drawPlace) -- but nothing in the port
        # captured what RepairTowerBuild.draw() draws every
        # frame: the expanding circle (`Lines.circle(x, y,
        # range * mod);`, RepairTower.java:103, with `float mod
        # = totalProgress % 1f;`, RepairTower.java:100, gated
        # by `if(warmup <= 0.001f) return;`,
        # RepairTower.java:97), the spinning square
        # (`Fill.square(x, y, squareRad * warmup, Time.time /
        # squareSpinScl);`, RepairTower.java:105) and the
        # additive glow (`Drawf.additive(glow, glowColor,
        # warmup * (1f - glowMag + Mathf.absin(Time.time,
        # glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);`,
        # RepairTower.java:108) -- nor the two one-line
        # accessors `range()` (`return range;`,
        # RepairTower.java:113) and `warmup()` (`return
        # warmup;`, RepairTower.java:118). RED decisions
        # (resolved at RED, recorded in the register
        # docstring): (1) Three pure functions on the same
        # family file, draw taking the frame (warmup /
        # total_progress already stamped live by the N2228
        # driver) plus explicit per-def params; the two
        # accessors are pure reads with no driver tick line.
        # (2) Time.time is an explicit `time` float param (the
        # MendProjector draw_state precedent -- no frame key
        # carries global time); the driver accumulates a
        # per-building `frame["game_time"]` clock to pass in.
        # (3) The glow region is pinned as the String param
        # `glow_region` ("unit-repair-tower-glow", from
        # `@Load("@-glow")`, RepairTower.java:25); loading the
        # TextureRegion for real stays deferred. (4) The glow
        # alpha uses the port helper
        # `SourceMathState.source_absin(time, glow_scl,
        # glow_mag)` with the original scl (the port precedent
        # -- two shipped slices pass the Java scl straight
        # into the helper); the arc-formula deviation is
        # documented, and the proof pins the port formula at a
        # nonzero time. (5) There IS one driver tick line,
        # for draw only (draw runs every frame after
        # updateTile -- the N2225 RepairTurret draw precedent);
        # the accessors have none. (6) The draw super call
        # (`super.draw();`, RepairTower.java:95) draws the
        # block itself -- out of scope. Eighteen new result
        # symbols: draw visible / center / z_layer / mod /
        # circle_stroke / circle_radius / circle_color /
        # square_half_size / square_rotation / square_color /
        # glow_alpha / glow_color / glow_color_alpha /
        # glow_region / glow_rotation / glow_z_layer, range,
        # warmup.
        self.assertEqual(
            ledger['N2232']['source_symbols'],
            [
                'source_repair_tower_draw_state_result.visible',
                'source_repair_tower_draw_state_result.center',
                'source_repair_tower_draw_state_result.z_layer',
                'source_repair_tower_draw_state_result.mod',
                'source_repair_tower_draw_state_result.circle_stroke',
                'source_repair_tower_draw_state_result.circle_radius',
                'source_repair_tower_draw_state_result.circle_color',
                'source_repair_tower_draw_state_result.square_half_size',
                'source_repair_tower_draw_state_result.square_rotation',
                'source_repair_tower_draw_state_result.square_color',
                'source_repair_tower_draw_state_result.glow_alpha',
                'source_repair_tower_draw_state_result.glow_color',
                'source_repair_tower_draw_state_result.glow_color_alpha',
                'source_repair_tower_draw_state_result.glow_region',
                'source_repair_tower_draw_state_result.glow_rotation',
                'source_repair_tower_draw_state_result.glow_z_layer',
                'source_repair_tower_range_state_result.range',
                'source_repair_tower_warmup_state_result.warmup',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/logic/Ranged.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/graphics/Drawf.java',
        }
        for name in ledger['N2232']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2232']['runtime_proof'], '/root/C07RepairTowerDrawProof')
        self.assertEqual(
            ledger['N2232']['tests'],
            [
                'test_c07_repair_tower_draw_registration',
                'test_all_c07_repair_tower_draw_input_evidence_is_exact',
                'test_repair_tower_draw_state',
                'test_reference_graph_and_actual_c07_repair_tower_draw',
            ],
        )
        self.assertTrue(ledger['N2232']['deferred_exprs'])

    def test_all_c07_repair_tower_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2232']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/logic/Ranged.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/graphics/Drawf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2232']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_draw_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # RepairTowerBuild.draw() (RepairTower.java:94-109)
        # draws every frame after updateTile: the warmup gate
        # (`if(warmup <= 0.001f) return;`, RepairTower.java:97)
        # becomes the `visible` key (no early return in the
        # pure function -- the full shape is always returned,
        # the MendProjector draw_state precedent); `float mod
        # = totalProgress % 1f;` (RepairTower.java:100) is the
        # circle progress; `Lines.stroke(circleStroke * (1f -
        # mod) * warmup);` (RepairTower.java:102) fades the
        # stroke as the circle expands; `Lines.circle(x, y,
        # range * mod);` (RepairTower.java:103) is the circle;
        # `Fill.square(x, y, squareRad * warmup, Time.time /
        # squareSpinScl);` (RepairTower.java:105) is the
        # spinning square (rotation is the explicit `time`
        # param over square_spin_scl); `Drawf.additive(glow,
        # glowColor, warmup * (1f - glowMag + Mathf.absin(
        # Time.time, glowScl, glowMag)), x, y, 0f,
        # Layer.blockAdditive);` (RepairTower.java:108) is the
        # glow, with the port helper `SourceMathState.
        # source_absin(time, glow_scl, glow_mag)` and the
        # effective alpha glow_alpha * 0.5 (Drawf.java:186,
        # `Draw.color(color, alpha * color.a);`, with
        # glowColor.a = 0.5f, RepairTower.java:22). The
        # z-layers are Layer.effect = 110 (Layer.java:75,
        # `effect = 110,`) and Layer.blockAdditive = 31
        # (Layer.java:36, `blockAdditive = 31,`). The
        # accessors are one-line returns: `range()` (`return
        # range;`, RepairTower.java:113, from the Ranged
        # interface, Ranged.java:5-6) and `warmup()` (`return
        # warmup;`, RepairTower.java:118, overriding the base
        # that returns 0f, BuildingComp.java:608-609). The
        # range is the per-def range -- unit-repair-tower 100f
        # (Blocks.java:6579), class default 80f (`public float
        # range = 80f;`, RepairTower.java:21). There IS a
        # driver tick line for draw only (the N2225 precedent);
        # the accessors have none. The expected glow alpha at
        # time 0 is 0.375 (port absin (sin(0/8)*0.5+0.5)*0.5
        # = 0.25, so 0.5*(1-0.5+0.25)); at time 8.0 it is
        # ~0.4802 (port absin (sin(1.0)*0.5+0.5)*0.5 ~
        # 0.4604, so 0.5*(0.5+0.4604)) -- the port formula,
        # NOT the arc formula.
        self.assertIn('static func source_repair_tower_draw_state(frame: Dictionary, x: float, y: float, range: float, time: float, circle_stroke: float, square_rad: float, square_spin_scl: float, glow_mag: float, glow_scl: float, glow_region: String) -> Dictionary:', repair_tower)
        self.assertIn('static func source_repair_tower_range_state(range: float) -> Dictionary:', repair_tower)
        self.assertIn('return {"range": range}', repair_tower)
        self.assertIn('static func source_repair_tower_warmup_state(frame: Dictionary) -> Dictionary:', repair_tower)
        self.assertIn('return {"warmup": float(frame.get("warmup", 0.0))}', repair_tower)
        for fragment in [
            '"visible": visible',
            '"center": Vector2(x, y)',
            '"z_layer": 110.0',
            '"mod": mod',
            '"circle_stroke": circle_stroke * (1.0 - mod) * warmup',
            '"circle_radius": range * mod',
            '"circle_color": "Pal.heal"',
            '"square_half_size": square_rad * warmup',
            '"square_rotation": time / square_spin_scl',
            '"square_color": "Pal.heal"',
            '"glow_alpha": warmup * (1.0 - glow_mag + SourceMathState.source_absin(time, glow_scl, glow_mag))',
            '"glow_color": "Pal.heal"',
            '"glow_color_alpha": 0.5',
            '"glow_region": glow_region',
            '"glow_rotation": 0.0',
            '"glow_z_layer": 31.0',
        ]:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, repair_tower)
        for expr in [
            'public void draw(){',
            'super.draw();',
            'if(warmup <= 0.001f) return;',
            'Draw.z(Layer.effect);',
            'float mod = totalProgress % 1f;',
            'Draw.color(circleColor);',
            'Lines.stroke(circleStroke * (1f - mod) * warmup);',
            'Lines.circle(x, y, range * mod);',
            'Draw.color(Pal.heal);',
            'Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);',
            'Draw.reset();',
            'Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);',
            'public float range(){',
            'return range;',
            'public float warmup(){',
            'return warmup;',
            'public float range = 80f;',
            'public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);',
            'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;',
            'public class RepairTower extends Block{',
            'public float warmup = 0f;',
            'public float totalProgress = 0f;',
            'public @Load("@-glow") TextureRegion glow;',
            'range = 100f;',
            'heal = Color.valueOf("98ffa9"),',
            'effect = 110,',
            'blockAdditive = 31,',
            'public interface Ranged extends Posc, Teamc{',
            'float range();',
            'return 0f;',
            'public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){',
            'Draw.color(color, alpha * color.a);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_tower)
        driver_start = repair_tower.index('static func source_repair_tower_tick_buildings_state')
        driver_end = repair_tower.find('\nstatic func ', driver_start + 1)
        driver_body = repair_tower[driver_start:driver_end if driver_end != -1 else len(repair_tower)]
        self.assertIn('source_repair_tower_draw_state', driver_body)
        self.assertIn('frame["game_time"]', driver_body)
        self.assertNotIn('source_repair_tower_range_state', driver_body)
        self.assertNotIn('source_repair_tower_warmup_state', driver_body)
        # The proof's keys drive the pure functions with
        # synthetic values (time passed explicitly) plus
        # through the driver tick, at the sample position
        # x=100, y=200 with the catalog range 100f: hidden at
        # the warmup gate / visible above it / mod wraps /
        # circle stroke scales / circle radius catalog 100 /
        # square half size and rotation / glow alpha at time
        # zero / glow alpha at nonzero time pins the port
        # formula / layers / range accessor / warmup accessor
        # reads the frame / has driver tick line (the proof
        # reads the state script source and greps the driver
        # body -- a runtime check, not a hardcoded true).
        proof = REPAIR_TOWER_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_hidden_at_warmup_gate',
            'draw_visible_above_gate',
            'draw_mod_wraps',
            'draw_circle_stroke_scales',
            'draw_circle_radius_catalog_100',
            'draw_square_half_size_and_rotation',
            'draw_glow_alpha_at_time_zero',
            'draw_glow_alpha_nonzero_time_pins_port_formula',
            'draw_layers',
            'draw_range_accessor',
            'draw_warmup_accessor_reads_frame',
            'has_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_hidden_at_warmup_gate',
            'draw_visible_above_gate',
            'draw_mod_wraps',
            'draw_circle_stroke_scales',
            'draw_circle_radius_catalog_100',
            'draw_square_half_size_and_rotation',
            'draw_glow_alpha_at_time_zero',
            'draw_glow_alpha_nonzero_time_pins_port_formula',
            'draw_layers',
            'draw_range_accessor',
            'draw_warmup_accessor_reads_frame',
            'has_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
