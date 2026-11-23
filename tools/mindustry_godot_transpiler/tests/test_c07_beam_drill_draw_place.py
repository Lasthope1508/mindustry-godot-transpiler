import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_DRAW_PLACE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDrawPlaceProof.gd'


class C07BeamDrillDrawPlaceTests(unittest.TestCase):
    def test_c07_beam_drill_draw_place_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2385']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_draw_place_state')
        # BeamDrillBuild.drawPlace() (BeamDrill.java:138-197, `public
        # void drawPlace(int x, int y, int rotation, boolean valid){`)
        # is the BeamDrill placement preview: one scan ray per
        # footprint side (nearbySide + world.tile), one
        # Drawf.dashLine per side (Pal.remove when nothing found,
        # Pal.placing when a drop was found), the drillspeed text
        # plus the found item's icon (or the tier-requirement text
        # when only an unmineable drop was found). One pure
        # function on the existing SourceBeamDrillBuildState.gd (the
        # N2351 DrillBuild.drawPlace precedent): it returns the
        # computed place state and does NOT touch real Draw / Drawf
        # / drawPlaceText playback. NO driver tick line: drawPlace
        # is placement UI, not per-tick state. The 28
        # distinguishing exprs are the 0-hit lines re-probed at
        # base 1047fc24 in both ledgers (28/40 candidates 0-hit).
        # The 12 HIT exprs are evidence only, NOT distinguishing.
        # nearbySide is reached through its static geometry form
        # (the N2379 updateLasers precedent); world.tile arrives
        # as the explicit world_tile Callable; getDrillTime is
        # BeamDrill's own method (BeamDrill.java:216-217), NOT
        # N2344's BurstDrill.getDrillTime, and arrives as the
        # explicit get_drill_time Callable; drawPlaceText is the
        # already-live N1779/N1780 helper (the text arrives as a
        # command dict, the width as the explicit text_width
        # param). Eleven new result symbols: item,
        # invalid_item, multiple, count, dash_lines,
        # drill_speed, drill_speed_text, icon_rect,
        # icon_shadow_rect, commands, branch.
        self.assertEqual(
            ledger['N2385']['source_symbols'],
            [
                'source_beam_drill_draw_place_state_result.item',
                'source_beam_drill_draw_place_state_result.invalid_item',
                'source_beam_drill_draw_place_state_result.multiple',
                'source_beam_drill_draw_place_state_result.count',
                'source_beam_drill_draw_place_state_result.dash_lines',
                'source_beam_drill_draw_place_state_result.drill_speed',
                'source_beam_drill_draw_place_state_result.drill_speed_text',
                'source_beam_drill_draw_place_state_result.icon_rect',
                'source_beam_drill_draw_place_state_result.icon_shadow_rect',
                'source_beam_drill_draw_place_state_result.commands',
                'source_beam_drill_draw_place_state_result.branch',
            ],
        )
        for name in ledger['N2385']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/Vars.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2385']['runtime_proof'], '/root/C07BeamDrillDrawPlaceProof')
        self.assertEqual(
            ledger['N2385']['tests'],
            [
                'test_c07_beam_drill_draw_place_registration',
                'test_all_c07_beam_drill_draw_place_input_evidence_is_exact',
                'test_beam_drill_draw_place_state',
                'test_reference_graph_and_actual_c07_beam_drill_draw_place',
            ],
        )
        self.assertTrue(ledger['N2385']['deferred_exprs'])

    def test_all_c07_beam_drill_draw_place_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2385']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2385']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_draw_place_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrillBuild.drawPlace() (BeamDrill.java:138-197)
        # returns the computed place state: one dash line per
        # footprint side (Pal.remove / Pal.placing), the found
        # item + invalid item + multiple flag + count, the
        # drillspeed rate + text, the icon rects (or null when
        # multiple), and the draw commands in Java order. The
        # inner scan is a while loop so j keeps Java's
        # post-loop value; len = min(j, range - 1). A null or
        # non-solid tile does NOT stop the ray; the first solid
        # tile stops it whether or not its drop is mineable.
        # NO driver tick line: drawPlace is placement UI.
        self.assertIn('static func source_beam_drill_draw_place_state(x: int, y: int, rotation: int, valid: bool, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable, get_drill_time: Callable, item_icon: Callable, offset: float, tilesize: float, icon_small: float, text_width: float) -> Dictionary:', state)
        self.assertIn('return {"item": item, "invalid_item": invalid_item, "multiple": multiple, "count": count, "dash_lines": dash_lines, "drill_speed": drill_speed, "drill_speed_text": drill_speed_text, "icon_rect": icon_rect, "icon_shadow_rect": icon_shadow_rect, "commands": commands, "branch": branch}', state)
        for expr in [
            'Item item = null, invalidItem = null;',
            'int count = 0;',
            'nearbySide(x, y, rotation, i, Tmp.p1);',
            'int j = 0;',
            'Item found = null;',
            'for(; j < range; j++){',
            'int rx = Tmp.p1.x + Geometry.d4x(rotation)*j, ry = Tmp.p1.y + Geometry.d4y(rotation)*j;',
            'if(other != null && other.solid()){',
            'if(drop != null){',
            'if(drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){',
            'found = drop;',
            'count++;',
            'invalidItem = drop;',
            'if(found != null){',
            'if(item != found && item != null){',
            'item = found;',
            'int len = Math.min(j, range - 1);',
            'Drawf.dashLine(found == null ? Pal.remove : Pal.placing,',
            'Tmp.p1.x * tilesize,',
            'Tmp.p1.y *tilesize,',
            '(Tmp.p1.x + Geometry.d4x(rotation)*len) * tilesize,',
            '(Tmp.p1.y + Geometry.d4y(rotation)*len) * tilesize',
            'float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);',
            'if(!multiple){',
            'Draw.rect(item.fullIcon, dx, dy - 1, s, s);',
            'Draw.rect(item.fullIcon, dx, dy, s, s);',
            '}else if(invalidItem != null){',
            'drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, false);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with synthetic
        # worlds (no live tick): single item found / icon rect
        # geometry / multiple items hide the icon / no drop dash
        # remove / invalid-only tier req / blocked item is
        # invalid / scan steps to a deeper drop / non-solid does
        # not stop the ray / drillspeed formula / dash endpoints
        # / commands order / tier-req command / drillspeed text
        # content / valid-false text color / the eleven-key shape.
        proof = BEAM_DRILL_DRAW_PLACE_PROOF.read_text(encoding='utf-8')
        for key in [
            'single_item_found',
            'icon_rect_geometry',
            'multiple_items_hide_icon',
            'no_drop_dash_remove',
            'invalid_only_tier_req',
            'blocked_item_is_invalid',
            'scan_steps_to_deeper_drop',
            'non_solid_does_not_stop_ray',
            'drill_speed_formula',
            'dash_line_endpoints',
            'commands_order',
            'tier_req_command',
            'drill_speed_text_content',
            'valid_false_text_color',
            'returns_only_eleven_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_draw_place(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDrawPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DRAW_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'single_item_found',
            'icon_rect_geometry',
            'multiple_items_hide_icon',
            'no_drop_dash_remove',
            'invalid_only_tier_req',
            'blocked_item_is_invalid',
            'scan_steps_to_deeper_drop',
            'non_solid_does_not_stop_ray',
            'drill_speed_formula',
            'dash_line_endpoints',
            'commands_order',
            'tier_req_command',
            'drill_speed_text_content',
            'valid_false_text_color',
            'returns_only_eleven_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
