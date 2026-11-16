import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIGHT_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourceLightBlockBuildState.gd'
LIGHT_BLOCK_CONFIG_COLOR_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockConfigColorRowsProof.gd'
LIGHT_BLOCK_CONFIG_COLOR_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockConfigColorRowsProof.tscn'
SENSE_OWNER = 'SourceLightBlockBuildState.source_light_block_sense_color_state'
CONFIG_OWNER = 'SourceLightBlockBuildState.source_light_block_config_color_state'
COLOR_JAVA = 'arc-core/src/arc/graphics/Color.java'


class C07LightBlockConfigColorRowsTests(unittest.TestCase):
    def test_c07_light_block_config_color_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2443']['godot_owner'], SENSE_OWNER)
        # config(Integer) is live since N2185 only as a
        # comment, but NOTHING modeled the config / color
        # rows: config(Integer) (:35, tile.color = value),
        # configured (:72-76, super + minimap update when
        # !headless), control (:78-88, LAccess.color ->
        # color = Tmp.c1.fromDouble(p1).rgba8888() +
        # minimap update when !headless, then super),
        # sense (:90-94, LAccess.color ->
        # Tmp.c1.set(color).toDoubleBits(), else
        # super.sense), buildConfiguration (:109-115,
        # the pencil button 40f opening the color picker
        # at alpha 0.5f), onConfigureBuildTapped
        # (:117-127, self tap deselects + returns false,
        # other tap returns true) and config() (:132-133,
        # returns color). N2443 ports all eight as TWO
        # pure-only pures (the N2387/N2437 sense + action
        # precedent): the sense pure dispatches on the
        # LAccess.color token (mindustry.logic.LAccess,
        # NOT arc -- the N2437 lesson) and returns the
        # double denormal float(rgba8888) * 2^-1074,
        # whose raw bits are the color int
        # zero-extended (arc Color.java:166-168); the
        # config pure folds the configure / control
        # action into the post-action color, the
        # minimap update flag, the tap result, the
        # picker CALL record and the config() value.
        # Seven new result symbols: the sensed value +
        # the delegate flag, then the post-action color,
        # the minimap flag, the tap result, the picker
        # call and the config value. The super sense /
        # super control calls are caller-supplied, not
        # symbols (the N2437 super_value precedent);
        # the picker UI itself is a CALL record, not a
        # ported UI (the N2396 CALL precedent).
        self.assertEqual(
            ledger['N2443']['source_symbols'],
            [
                'source_light_block_sense_color_state_result.value',
                'source_light_block_sense_color_state_result.delegated',
                'source_light_block_config_color_state_result.color',
                'source_light_block_config_color_state_result.minimap_updated',
                'source_light_block_config_color_state_result.tapped_result',
                'source_light_block_config_color_state_result.picker_call',
                'source_light_block_config_color_state_result.config_value',
            ],
        )
        owners = {
            'source_light_block_sense_color_state_result.value': SENSE_OWNER,
            'source_light_block_sense_color_state_result.delegated': SENSE_OWNER,
            'source_light_block_config_color_state_result.color': CONFIG_OWNER,
            'source_light_block_config_color_state_result.minimap_updated': CONFIG_OWNER,
            'source_light_block_config_color_state_result.tapped_result': CONFIG_OWNER,
            'source_light_block_config_color_state_result.picker_call': CONFIG_OWNER,
            'source_light_block_config_color_state_result.config_value': CONFIG_OWNER,
        }
        sources = {
            'source_light_block_sense_color_state_result.value': COLOR_JAVA,
            'source_light_block_sense_color_state_result.delegated': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_config_color_state_result.color': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_config_color_state_result.minimap_updated': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_config_color_state_result.tapped_result': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_config_color_state_result.picker_call': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_config_color_state_result.config_value': 'core/src/mindustry/world/blocks/power/LightBlock.java',
        }
        for name in ledger['N2443']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], sources[name])
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2443']['runtime_proof'], '/root/C07LightBlockConfigColorRowsProof')
        self.assertEqual(
            ledger['N2443']['tests'],
            [
                'test_c07_light_block_config_color_rows_registration',
                'test_all_c07_light_block_config_color_rows_input_evidence_is_exact',
                'test_light_block_config_color_rows_state',
                'test_reference_graph_and_actual_c07_light_block_config_color_rows',
            ],
        )
        self.assertTrue(ledger['N2443']['deferred_exprs'])
        # This slice RESOLVES the config / color rows
        # (#91 in the merged advances-27 DEFERRED base):
        # the config handler, configured, control, sense,
        # buildConfiguration, onConfigureBuildTapped and
        # config() are all live in the two pures. No new
        # entry is added: the pures are pure-only (no
        # tick wiring to defer), the init / read-write /
        # env rows stay deferred under their own entries.
        # Net -1+0 = 265.
        self.assertFalse(any(entry.startswith('LightBlock config / color rows (') for entry in ledger['N2443']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock init rows (') for entry in ledger['N2443']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock read/write rows (') for entry in ledger['N2443']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock env / placement flag rows (') for entry in ledger['N2443']['deferred_exprs']))
        self.assertEqual(len(ledger['N2443']['deferred_exprs']), 265)

    def test_all_c07_light_block_config_color_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_light_block_sense_color_state_result.value': SENSE_OWNER,
            'source_light_block_sense_color_state_result.delegated': SENSE_OWNER,
            'source_light_block_config_color_state_result.color': CONFIG_OWNER,
            'source_light_block_config_color_state_result.minimap_updated': CONFIG_OWNER,
            'source_light_block_config_color_state_result.tapped_result': CONFIG_OWNER,
            'source_light_block_config_color_state_result.picker_call': CONFIG_OWNER,
            'source_light_block_config_color_state_result.config_value': CONFIG_OWNER,
        }
        for name in ledger['N2443']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], owners[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/power/LightBlock.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/graphics/Pal.java',
            'arc-core/src/arc/graphics/Color.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2443']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_light_block_config_color_rows_state(self):
        light_block = LIGHT_BLOCK_STATE.read_text(encoding='utf-8')
        # The config / color rows (LightBlock.java:35,
        # 68, 72-94, 109-127, 132-133). config(Integer)
        # is `config(Integer.class, (LightBuild tile,
        # Integer value) -> tile.color = value);` (:35);
        # the color field is `public int color =
        # Pal.accent.rgba();` (:68), Pal.accent being
        # `accent = Color.valueOf("ffd37f"),`
        # (Pal.java:79 -- a 6-digit hex, so valueOf
        # defaults alpha to 255, Color.java:128, and the
        # default color is 0xffd37fff). configured()
        # (:72-76) is `super.configured(player,
        # value);` + `if(!headless)
        # renderer.minimap.update(tile);` -- the super
        # runs the config handler (BuildingComp.java
        # :1429, `block.configurations.get(type).get(
        # this, value);`) with NO equality check anywhere
        # in the chain (InputHandler.tileConfig,
        # InputHandler.java:706-728, calls configured
        # unconditionally), so a configure updates the
        # minimap even when the new color equals the old
        # one -- the pure records minimap_updated =
        # action != "none" && !headless, with NO
        # color-changed condition (a brief-formula
        # deviation, Java-verified). control() (:78-88)
        # is `if(type == LAccess.color){` + `color =
        # Tmp.c1.fromDouble(p1).rgba8888();` + the
        # !headless minimap update + `super.control(
        # type, p1, p2, p3, p4);` -- fromDouble takes the
        # LOW 32 bits of the double's raw bits
        # (Color.java:174-176, `return rgba8888((int)(
        # Double.doubleToRawLongBits(value)));`) and the
        # set->rgba8888 round-trip is EXACT (verified in
        # float32 for every channel 0-255), so the
        # control color IS the raw low 32 bits, supplied
        # caller-side because GDScript has no double
        # bitcast (the N2435 caller-supplied precedent;
        # the logic executor owns the bitcast). sense()
        # (:90-94) is `if(sensor == LAccess.color)
        # return Tmp.c1.set(color).toDoubleBits();` else
        # `return super.sense(sensor);` -- toDoubleBits
        # is `return Double.longBitsToDouble(
        # Color.rgba8888(r, g, b, a) &
        # 0x00000000_ffffffffL);` (Color.java:166-168),
        # i.e. a double denormal whose raw bits are the
        # rgba8888 int zero-extended, which is exactly
        # float(rgba) * 2^-1074 (verified for 200k random
        # 32-bit values + endpoints; the set(int) byte
        # order puts R in the top byte, Color.java:286,
        # `r = ((value & 0xff000000) >>> 24) / 255f;`).
        # buildConfiguration (:109-115) is the pencil
        # button (`table.button(Icon.pencil,
        # Styles.cleari, () -> {` + `}).size(40f);`)
        # opening `ui.picker.show(Tmp.c1.set(color).a(
        # 0.5f), false, res -> configure(res.rgba()));`
        # then `deselect();` -- recorded as a CALL, the
        # UI itself is NOT ported. onConfigureBuildTapped
        # (:117-127) is `if(this == other){` +
        # deselect() + `return false;`, else `return
        # true;`. config() (:132-133) is `return color;`.
        # The LAccess token is the exact enum name
        # `color("to");` (LAccess.java:84 -- LAccess is
        # mindustry.logic.LAccess, NOT arc, the N2437
        # lesson). Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_light_block_sense_color_state', light_block)
        self.assertIn('static func source_light_block_config_color_state', light_block)
        self.assertIn('config(Integer.class, (LightBuild tile, Integer value) -> tile.color = value);', light_block)
        self.assertIn('public int color = Pal.accent.rgba();', light_block)
        self.assertIn('accent = Color.valueOf("ffd37f"),', light_block)
        self.assertIn('public void configured(Unit player, Object value){', light_block)
        self.assertIn('super.configured(player, value);', light_block)
        self.assertIn('if(!headless) renderer.minimap.update(tile);', light_block)
        self.assertIn('block.configurations.get(type).get(this, value);', light_block)
        self.assertIn('public void control(LAccess type, double p1, double p2, double p3, double p4){', light_block)
        self.assertIn('if(type == LAccess.color){', light_block)
        self.assertIn('color = Tmp.c1.fromDouble(p1).rgba8888();', light_block)
        self.assertIn('super.control(type, p1, p2, p3, p4);', light_block)
        self.assertIn('public double sense(LAccess sensor){', light_block)
        self.assertIn('if(sensor == LAccess.color) return Tmp.c1.set(color).toDoubleBits();', light_block)
        self.assertIn('return super.sense(sensor);', light_block)
        self.assertIn('public void buildConfiguration(Table table){', light_block)
        self.assertIn('table.button(Icon.pencil, Styles.cleari, () -> {', light_block)
        self.assertIn('ui.picker.show(Tmp.c1.set(color).a(0.5f), false, res -> configure(res.rgba()));', light_block)
        self.assertIn('deselect();', light_block)
        self.assertIn('}).size(40f);', light_block)
        self.assertIn('public boolean onConfigureBuildTapped(Building other){', light_block)
        self.assertIn('if(this == other){', light_block)
        self.assertIn('return false;', light_block)
        self.assertIn('return true;', light_block)
        self.assertIn('public Integer config(){', light_block)
        self.assertIn('return color;', light_block)
        self.assertIn('color("to");', light_block)
        self.assertIn('return Double.longBitsToDouble(Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);', light_block)
        self.assertIn('return rgba8888((int)(Double.doubleToRawLongBits(value)));', light_block)
        self.assertIn('return ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255);', light_block)
        self.assertIn('public Color set(int rgba){', light_block)
        self.assertIn('return rgba8888(rgba);', light_block)
        self.assertIn('public double toDoubleBits(){', light_block)
        self.assertIn('return toDoubleBits(r, g, b, a);', light_block)
        self.assertIn('r = ((value & 0xff000000) >>> 24) / 255f;', light_block)
        # The documented limits record the config/color
        # rows as live (the draw-place rows stay live
        # since N2439).
        self.assertIn('Config/color rows live (N2443)', light_block)
        self.assertIn('DrawPlace rows live (N2439)', light_block)
        # The proof's keys drive the two pures (the
        # sense color double-bits, the sense delegate,
        # the configure set, the control bits, the tap
        # self/other and the minimap | 0xff fold of a
        # configured color).
        proof = LIGHT_BLOCK_CONFIG_COLOR_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_color_double_bits',
            'sense_delegate',
            'configure_set',
            'control_bits',
            'tapped_self_other',
            'minimap_color_or_ff',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceLightBlockBuildState.gd")', proof)
        self.assertTrue(LIGHT_BLOCK_STATE.exists())
        self.assertTrue(LIGHT_BLOCK_CONFIG_COLOR_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LightBlockConfigColorRowsProof.gd', LIGHT_BLOCK_CONFIG_COLOR_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_light_block_config_color_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LightBlockConfigColorRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIGHT_BLOCK_CONFIG_COLOR_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_color_double_bits',
            'sense_delegate',
            'configure_set',
            'control_bits',
            'tapped_self_other',
            'minimap_color_or_ff',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
