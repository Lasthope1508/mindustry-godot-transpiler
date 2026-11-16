import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_PLACE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillCanPlaceOnDrawPlaceProof.gd'
BEAM_DRILL_PLACE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillCanPlaceOnDrawPlaceProof.tscn'


class C07BeamDrillCanPlaceOnDrawPlaceRowsTests(unittest.TestCase):
    def test_c07_beam_drill_can_place_on_draw_place_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2478']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_can_place_on_state')
        # N2478 is the BeamDrill canPlaceOn / drawPlace
        # rows (DEFERRED #234): two pure-only pures, NO
        # tick wiring. canPlaceOn (BeamDrill.java:198-214)
        # walks size lasers x range tiles from the
        # nearbySide origins and returns true on the first
        # mineable drop (`if(drop != null && drop.hardness
        # <= tier && (blockedItems == null ||
        # !blockedItems.contains(drop))){`, :205); the
        # break sits OUTSIDE the drop check, so the first
        # solid tile ends the laser's walk either way.
        # drawPlace (BeamDrill.java:137-195) walks the
        # same rays, records one dash line per laser
        # (`int len = Math.min(j, range - 1);`, :172;
        # `Drawf.dashLine(found == null ? Pal.remove :
        # Pal.placing,`, :173), the speed text
        # (`float width = drawPlaceText(Core.bundle.
        # formatFloat("bar.drillspeed", 60f /
        # getDrillTime(item) * count, 2), x, y, valid);`,
        # :183) when an item was found, the single-item
        # icon (`s = iconSmall / 4f`, :185) when
        # !multiple, and the tier-req text
        # (`drawPlaceText(Core.bundle.get("bar.drilltierreq"),
        # x, y, false);`, :192) when no item was found
        # but an invalid drop was. Five new result
        # symbols, one per result key (the brief's +3
        # estimate miscounted: drawPlace returns FOUR
        # keys, not two).
        self.assertEqual(
            ledger['N2478']['source_symbols'],
            [
                'source_beam_drill_can_place_on_state_result.can_place_on',
                'source_beam_drill_draw_place_state_result.dash_lines',
                'source_beam_drill_draw_place_state_result.speed_text',
                'source_beam_drill_draw_place_state_result.icon',
                'source_beam_drill_draw_place_state_result.tier_req_text',
            ],
        )
        for name in ledger['N2478']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertIn(symbol['godot_owner'], ('SourceBeamDrillBuildState.source_beam_drill_can_place_on_state', 'SourceBeamDrillBuildState.source_beam_drill_draw_place_state'))
        self.assertEqual(ledger['N2478']['runtime_proof'], '/root/C07BeamDrillCanPlaceOnDrawPlaceProof')
        self.assertEqual(
            ledger['N2478']['tests'],
            [
                'test_c07_beam_drill_can_place_on_draw_place_rows_registration',
                'test_all_c07_beam_drill_can_place_on_draw_place_rows_input_evidence_is_exact',
                'test_beam_drill_can_place_on_draw_place_rows_state',
                'test_reference_graph_and_actual_c07_beam_drill_can_place_on_draw_place_rows',
            ],
        )
        self.assertTrue(ledger['N2478']['deferred_exprs'])
        # This slice RESOLVES the canPlaceOn / drawPlace
        # entry (#234) by text: the old entry is gone. A
        # NEW entry records the live placement call site
        # (the pures are live since N2478 but no
        # placement path calls them yet -- the UAM N2345
        # precedent). The facing / laser binding entry
        # and the drop-loop entry stay.
        self.assertFalse(any(entry.startswith('BeamDrill canPlaceOn / drawPlace rows (') for entry in ledger['N2478']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill canPlaceOn / drawPlace live placement call site (') for entry in ledger['N2478']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') for entry in ledger['N2478']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2478']['deferred_exprs']))

    def test_all_c07_beam_drill_can_place_on_draw_place_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2478']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceBeamDrillBuildState.source_beam_drill_can_place_on_state', 'SourceBeamDrillBuildState.source_beam_drill_draw_place_state'))
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/Vars.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Items.java'),
            ('mindustry-upstream', 'core/src/mindustry/graphics/Pal.java'),
            ('mindustry-upstream', 'core/assets/bundles/bundle.properties'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Geometry.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2478']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_can_place_on_draw_place_rows_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # canPlaceOn (BeamDrill.java:198-214) and
        # drawPlace (BeamDrill.java:137-195). The walks
        # (each Java expr on ONE comment line, the N2148
        # shootWarmup lesson: a split line fails this
        # test):
        # `public boolean canPlaceOn(Tile tile, Team team, int rotation){`
        # `nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);`
        # `Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);`
        # `public void drawPlace(int x, int y, int rotation, boolean valid){`
        # `nearbySide(x, y, rotation, i, Tmp.p1);`
        # `int rx = Tmp.p1.x + Geometry.d4x(rotation)*j, ry = Tmp.p1.y + Geometry.d4y(rotation)*j;`
        # `Tile other = world.tile(rx, ry);`
        # `if(other != null && other.solid()){`
        # `Item drop = other.wallDrop();`
        # `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
        # `if(drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
        # `found = drop;`
        # `count++;`
        # `invalidItem = drop;`
        # `if(item != found && item != null){`
        # `multiple = true;`
        # `item = found;`
        # `int len = Math.min(j, range - 1);`
        # `Drawf.dashLine(found == null ? Pal.remove : Pal.placing,`
        # `(Tmp.p1.x + Geometry.d4x(rotation)*len) * tilesize,`
        # `(Tmp.p1.y + Geometry.d4y(rotation)*len) * tilesize`
        # `float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);`
        # `float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;`
        # `Draw.mixcol(Color.darkGray, 1f);`
        # `Draw.rect(item.fullIcon, dx, dy - 1, s, s);`
        # `Draw.rect(item.fullIcon, dx, dy, s, s);`
        # `drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, false);`
        # `public float getDrillTime(Item item){`
        # `return drillTime / drillMultipliers.get(item, 1f);`
        # `public float drillTime = 200f;`
        # `drillTime = 160f;`
        # `drillTime = 100f;`
        # `for(int i = 0; i < size; i++){`
        # `for(int j = 0; j < range; j++){`
        # `for(; j < range; j++){`
        # nearbySide (Block.java:936-944):
        # `public void nearbySide(int x, int y, int rotation, int index, Point2 out){`
        # `int cornerX = x - (size-1)/2, cornerY = y - (size-1)/2, s = size;`
        # `case 0 -> out.set(cornerX + s, cornerY + index);`
        # `case 1 -> out.set(cornerX + index, cornerY + s);`
        # `case 2 -> out.set(cornerX - 1, cornerY + index);`
        # `case 3 -> out.set(cornerX + index, cornerY - 1);`
        # drawPlaceText (Block.java:531-532):
        # `public float drawPlaceText(String text, int x, int y, boolean valid){`
        # `return drawPlaceText(text, x, y, valid ? Pal.accent : Pal.remove, true);`
        # `offset = ((size + 1) % 2) * tilesize / 2f;`
        # (Block.java:761). tilesize + iconSmall
        # (Vars.java:135/139):
        # `public static final int tilesize = 8;`
        # `public static final float iconXLarge = 8*6f, iconLarge = 8*5f, iconMed = 8*4f, iconSmall = 8*3f;`
        # Geometry.d4 (arc Geometry.java:23-24):
        # `public final static int[] d4x = {1, 0, -1, 0};`
        # `public final static int[] d4y = {0, 1, 0, -1};`
        # Bundle keys (bundle.properties:1279/1273):
        # `bar.drillspeed = Drill Speed: {0}/s`
        # `bar.drilltierreq = Better Drill Required`
        # Pal colors (Pal.java:95/86):
        # `placing = accent,`
        # `remove = Color.valueOf("e55454"),`
        # Item hardness (Items.java: copper :17, thorium
        # :56, tungsten :113; default 0, Item.java:30):
        # `hardness = 1;`
        # `hardness = 4;`
        # `hardness = 5;`
        # Defs (Blocks.java:3042-3045 / 3055-3059):
        # plasma-bore `tier = 3;` / `size = 2;` /
        # `range = 5;`, large-plasma-bore `tier = 5;` /
        # `size = 3;` / `range = 6;`.
        # VERIFY-FIRST findings (Java wins): (a) the
        # brief's "invalidItem = the FIRST unmineable
        # drop" is WRONG -- `invalidItem = drop;`
        # overwrites on every unmineable drop, so it is
        # the LAST one; (b) `len = min(j, range-1)` has
        # NO off-by-one -- j is the solid tile's own
        # index at the break, so the dash ends ON the
        # solid tile, or on the last walked tile
        # (j == range -> len range-1) when nothing is
        # found; (c) the tier-req text passes valid=false
        # HARDCODED, not the placement valid flag.
        self.assertIn('static func source_beam_drill_can_place_on_state', beam_drill)
        self.assertIn('static func source_beam_drill_draw_place_state', beam_drill)
        self.assertIn('public boolean canPlaceOn(Tile tile, Team team, int rotation){', beam_drill)
        self.assertIn('nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);', beam_drill)
        self.assertIn('Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);', beam_drill)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', beam_drill)
        self.assertIn('nearbySide(x, y, rotation, i, Tmp.p1);', beam_drill)
        self.assertIn('int rx = Tmp.p1.x + Geometry.d4x(rotation)*j, ry = Tmp.p1.y + Geometry.d4y(rotation)*j;', beam_drill)
        self.assertIn('Tile other = world.tile(rx, ry);', beam_drill)
        self.assertIn('if(other != null && other.solid()){', beam_drill)
        self.assertIn('Item drop = other.wallDrop();', beam_drill)
        self.assertIn('if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){', beam_drill)
        self.assertIn('if(drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){', beam_drill)
        self.assertIn('found = drop;', beam_drill)
        self.assertIn('count++;', beam_drill)
        self.assertIn('invalidItem = drop;', beam_drill)
        self.assertIn('if(item != found && item != null){', beam_drill)
        self.assertIn('multiple = true;', beam_drill)
        self.assertIn('item = found;', beam_drill)
        self.assertIn('int len = Math.min(j, range - 1);', beam_drill)
        self.assertIn('Drawf.dashLine(found == null ? Pal.remove : Pal.placing,', beam_drill)
        self.assertIn('(Tmp.p1.x + Geometry.d4x(rotation)*len) * tilesize,', beam_drill)
        self.assertIn('(Tmp.p1.y + Geometry.d4y(rotation)*len) * tilesize', beam_drill)
        self.assertIn('float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);', beam_drill)
        self.assertIn('float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;', beam_drill)
        self.assertIn('Draw.mixcol(Color.darkGray, 1f);', beam_drill)
        self.assertIn('Draw.rect(item.fullIcon, dx, dy - 1, s, s);', beam_drill)
        self.assertIn('Draw.rect(item.fullIcon, dx, dy, s, s);', beam_drill)
        self.assertIn('drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, false);', beam_drill)
        self.assertIn('public float getDrillTime(Item item){', beam_drill)
        self.assertIn('return drillTime / drillMultipliers.get(item, 1f);', beam_drill)
        self.assertIn('public float drillTime = 200f;', beam_drill)
        self.assertIn('drillTime = 160f;', beam_drill)
        self.assertIn('drillTime = 100f;', beam_drill)
        self.assertIn('for(int i = 0; i < size; i++){', beam_drill)
        self.assertIn('for(int j = 0; j < range; j++){', beam_drill)
        self.assertIn('for(; j < range; j++){', beam_drill)
        self.assertIn('public void nearbySide(int x, int y, int rotation, int index, Point2 out){', beam_drill)
        self.assertIn('int cornerX = x - (size-1)/2, cornerY = y - (size-1)/2, s = size;', beam_drill)
        self.assertIn('case 0 -> out.set(cornerX + s, cornerY + index);', beam_drill)
        self.assertIn('case 1 -> out.set(cornerX + index, cornerY + s);', beam_drill)
        self.assertIn('case 2 -> out.set(cornerX - 1, cornerY + index);', beam_drill)
        self.assertIn('case 3 -> out.set(cornerX + index, cornerY - 1);', beam_drill)
        self.assertIn('public float drawPlaceText(String text, int x, int y, boolean valid){', beam_drill)
        self.assertIn('return drawPlaceText(text, x, y, valid ? Pal.accent : Pal.remove, true);', beam_drill)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', beam_drill)
        self.assertIn('public static final int tilesize = 8;', beam_drill)
        self.assertIn('public static final float iconXLarge = 8*6f, iconLarge = 8*5f, iconMed = 8*4f, iconSmall = 8*3f;', beam_drill)
        self.assertIn('public final static int[] d4x = {1, 0, -1, 0};', beam_drill)
        self.assertIn('public final static int[] d4y = {0, 1, 0, -1};', beam_drill)
        self.assertIn('bar.drillspeed = Drill Speed: {0}/s', beam_drill)
        self.assertIn('bar.drilltierreq = Better Drill Required', beam_drill)
        self.assertIn('placing = accent,', beam_drill)
        self.assertIn('remove = Color.valueOf("e55454"),', beam_drill)
        self.assertIn('hardness = 1;', beam_drill)
        self.assertIn('hardness = 4;', beam_drill)
        self.assertIn('hardness = 5;', beam_drill)
        self.assertIn('tier = 3;', beam_drill)
        self.assertIn('size = 2;', beam_drill)
        self.assertIn('range = 5;', beam_drill)
        self.assertIn('tier = 5;', beam_drill)
        self.assertIn('size = 3;', beam_drill)
        self.assertIn('range = 6;', beam_drill)
        # The two pures: can_place_on returns exactly its
        # one key (true on the first mineable drop, false
        # otherwise); draw_place returns exactly its four
        # keys (dash lines + speed text + icon + tier-req
        # text, each a call record or null). Both reuse
        # the N2346 laser-origins pure for the nearbySide
        # geometry (no second copy of the switch) and the
        # N2352 world_tiles frame input (Dict keyed "x,y"
        # to {solid, wall_drop}).
        self.assertIn('static func source_beam_drill_can_place_on_state(tile_x: int, tile_y: int, rotation: int, size: int, beam_range: int, tier: int, blocked_items: Variant, world_tiles: Dictionary) -> Dictionary:', beam_drill)
        self.assertIn('static func source_beam_drill_draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, size: int, beam_range: int, tier: int, blocked_items: Variant, world_tiles: Dictionary, drill_time_base: float, drill_multipliers: Dictionary, text_width: float) -> Dictionary:', beam_drill)
        self.assertIn('return {"can_place_on": true}', beam_drill)
        self.assertIn('return {"can_place_on": false}', beam_drill)
        self.assertIn('return {"dash_lines": dash_lines, "speed_text": speed_text, "icon": icon, "tier_req_text": tier_req_text}', beam_drill)
        self.assertEqual(beam_drill.count('source_beam_drill_laser_origins_state(tile_x, tile_y, rotation, size)'), 2)
        # Pure-only: NO tick wiring -- the tick never
        # calls either pure (placement runs from the
        # placement UI, and the placement call site waits
        # for its own slice). The documented limits now
        # record the rows as live since N2478, and the
        # N2473 blocked-items docstring no longer claims
        # drawPlace / canPlaceOn are unported.
        self.assertEqual(beam_drill.count('source_beam_drill_can_place_on_state('), 1)
        self.assertEqual(beam_drill.count('source_beam_drill_draw_place_state('), 1)
        self.assertIn('canPlaceOn / drawPlace rows are live since', beam_drill)
        self.assertIn('drawPlace / canPlaceOn are live since N2478', beam_drill)
        self.assertIn('N2478', beam_drill)
        self.assertIn('(3) Partial updateTile', beam_drill)
        self.assertIn('advance (N2195)', beam_drill)
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        self.assertIn('timerDump dump is live since N2289', beam_drill)
        self.assertIn('time grows unbounded', beam_drill)
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('static func source_beam_drill_facing_scan_state', beam_drill)
        self.assertIn('static func source_beam_drill_laser_origins_state', beam_drill)
        self.assertIn('static func source_beam_drill_facing_tiles_fill_state', beam_drill)
        self.assertIn('static func source_beam_drill_blocked_items_state', beam_drill)
        self.assertIn('static func source_beam_drill_drill_multiplier_state', beam_drill)
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        self.assertIn('static func source_beam_drill_timer_dump_state', beam_drill)
        # The pure N2195 advance is untouched: its return
        # dict keeps exactly the four N2195 keys.
        self.assertIn('return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}', beam_drill)
        # The proof's keys drive both pures (the
        # mineable-first case, the break-on-solid case,
        # the dash colors, the speed text, the multiple
        # case, the tier-req case).
        proof = BEAM_DRILL_PLACE_PROOF.read_text(encoding='utf-8')
        for key in [
            'place_first_mineable',
            'place_break_on_solid',
            'place_dash_colors',
            'place_speed_text',
            'place_multiple_items',
            'place_tier_req',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('beam_drill_build_state.source_beam_drill_can_place_on_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_draw_place_state(', proof)
        scene = BEAM_DRILL_PLACE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillCanPlaceOnDrawPlaceProof.gd', scene)
        self.assertIn('C07BeamDrillCanPlaceOnDrawPlaceProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_can_place_on_draw_place_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillCanPlaceOnDrawPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_CAN_PLACE_ON_DRAW_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'place_first_mineable',
            'place_break_on_solid',
            'place_dash_colors',
            'place_speed_text',
            'place_multiple_items',
            'place_tier_req',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
