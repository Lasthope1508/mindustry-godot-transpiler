import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_DRAW_PLACE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillDrawPlaceProof.gd'


class C07DrillDrawPlaceTests(unittest.TestCase):
    def test_c07_drill_draw_place_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2351']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_draw_place_state')
        # DrillBuild.drawPlace() (Drill.java:140-169,
        # `public void drawPlace(int x, int y, int rotation,
        # boolean valid){`) is a LEG slice: only the lines
        # listed in the batch-8 scope §2.2 are owned here.
        # `Tile tile = world.tile(x, y);` (:143) looks the
        # tile up; the null-tile guard `if(tile == null)
        # return;` (:144) is NOT re-owned (owned by
        # N1769/N919/N1821/N2038/N2330, other methods) --
        # it arrives as the explicit has_tile param.
        # `countOre(tile);` (:146) is NOT re-owned (N2020 /
        # N2021 / N2071 / N2302 / N2330) -- its result
        # (returnItem) arrives as explicit params
        # (has_return_item, return_item_icon,
        # return_item_color). The drillspeed text width
        # `float width = drawPlaceText(...)` (:149) is NOT
        # re-owned (N699 source_drill_output_rate) -- it
        # arrives as the explicit width param, computed by
        # the caller via N699 + N1780 drawPlaceText.
        # `Draw.mixcol(Color.darkGray, 1f);` (:151),
        # `Draw.reset();` (:153) and `Draw.color();` (:159)
        # are NOT re-owned (N570/N2341 and others) -- the
        # commands carry them as dict entries. The owned
        # geometry is `float dx = x * tilesize + offset -
        # width/2f - 4f, dy = y * tilesize + offset + size *
        # tilesize / 2f + 5, s = iconSmall / 4f;` (:150) with
        # the two icon rects `Draw.rect(
        # returnItem.fullIcon, dx, dy - 1, s, s);` (:152)
        # and `Draw.rect(returnItem.fullIcon, dx, dy, s,
        # s);` (:154), the drawMineItem branch
        # `if(drawMineItem){` (:156) /
        # `Draw.color(returnItem.color);` (:157) /
        # `Draw.rect(itemRegion, tile.worldx() + offset,
        # tile.worldy() + offset);` (:158), and the else
        # branch `}else{` (:161) with the linked-tile
        # search `Tile to = tile.getLinkedTilesAs(this,
        # tempTiles).find(t -> t.drop() != null &&
        # (t.drop().hardness > tier || (blockedItems !=
        # null && blockedItems.contains(t.drop()))));`
        # (:162), `Item item = to == null ? null :
        # to.drop();` (:163), `if(item != null){` (:164)
        # and `drawPlaceText(Core.bundle.get(
        # "bar.drilltierreq"), x, y, valid);` (:165). The
        # search itself is deferred to the caller as the
        # explicit linked_item param (the batch-8 scope
        # §2.6 precedent). The super call
        # `super.drawPlace(x, y, rotation, valid);` (:141)
        # is owned as call-site evidence (the N1162 Turret
        # drawPlace precedent); the Block.drawPlace
        # implementation is deferred. Ten new result
        # symbols: branch, dx, dy, icon_size, commands,
        # mine_item_drawn, tier_req_shown,
        # super_draw_place_called, rotation, valid. There
        # is NO driver tick line: drawPlace is placement
        # UI, not per-tick state (the accessor precedent
        # N2311/N2321/N2342).
        self.assertEqual(
            ledger['N2351']['source_symbols'],
            [
                'source_drill_draw_place_state_result.branch',
                'source_drill_draw_place_state_result.dx',
                'source_drill_draw_place_state_result.dy',
                'source_drill_draw_place_state_result.icon_size',
                'source_drill_draw_place_state_result.commands',
                'source_drill_draw_place_state_result.mine_item_drawn',
                'source_drill_draw_place_state_result.tier_req_shown',
                'source_drill_draw_place_state_result.super_draw_place_called',
                'source_drill_draw_place_state_result.rotation',
                'source_drill_draw_place_state_result.valid',
            ],
        )
        for name in ledger['N2351']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2351']['runtime_proof'], '/root/C07DrillDrawPlaceProof')
        self.assertEqual(
            ledger['N2351']['tests'],
            [
                'test_c07_drill_draw_place_registration',
                'test_all_c07_drill_draw_place_input_evidence_is_exact',
                'test_drill_draw_place_state',
                'test_reference_graph_and_actual_c07_drill_draw_place',
            ],
        )
        self.assertTrue(ledger['N2351']['deferred_exprs'])

    def test_all_c07_drill_draw_place_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2351']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2351']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_draw_place_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild.drawPlace() (Drill.java:140-169,
        # `public void drawPlace(int x, int y, int rotation,
        # boolean valid){`) with `super.drawPlace(x, y,
        # rotation, valid);` (:141, Block base -- deferred,
        # recorded as super_draw_place_called) and `Tile
        # tile = world.tile(x, y);` (:143). The return-item
        # branch `if(returnItem != null){` (:148) draws the
        # drillspeed text (width from N699 :149, NOT
        # re-owned -- explicit width param), then the icon
        # geometry `float dx = x * tilesize + offset -
        # width/2f - 4f, dy = y * tilesize + offset + size *
        # tilesize / 2f + 5, s = iconSmall / 4f;` (:150),
        # the shadow rect `Draw.rect(returnItem.fullIcon,
        # dx, dy - 1, s, s);` (:152) and the foreground rect
        # `Draw.rect(returnItem.fullIcon, dx, dy, s, s);`
        # (:154). The drawMineItem branch `if(drawMineItem){`
        # (:156) tints `Draw.color(returnItem.color);`
        # (:157) and draws `Draw.rect(itemRegion,
        # tile.worldx() + offset, tile.worldy() + offset);`
        # (:158) -- tile.worldx() is x * tilesize
        # (Tile.java:166-168), so the rect sits at (x *
        # tilesize + offset, y * tilesize + offset). The
        # else branch `}else{` (:161) searches linked tiles
        # `Tile to = tile.getLinkedTilesAs(this,
        # tempTiles).find(t -> t.drop() != null &&
        # (t.drop().hardness > tier || (blockedItems !=
        # null && blockedItems.contains(t.drop()))));`
        # (:162) -- deferred to the caller as the explicit
        # linked_item param -- then `Item item = to == null
        # ? null : to.drop();` (:163), `if(item != null){`
        # (:164) and `drawPlaceText(Core.bundle.get(
        # "bar.drilltierreq"), x, y, valid);` (:165), whose
        # 4-arg overload picks `valid ? Pal.accent :
        # Pal.remove` (Block.java:532) -- the color is
        # carried as the string "Pal.accent" / "Pal.remove"
        # (the N2342 Radar drawPlace precedent). tilesize is
        # 8 (`public static final int tilesize = 8;`,
        # Vars.java:135) and iconSmall is 24 (`iconSmall =
        # 8*3f;`, Vars.java:139). Per-def sizes:
        # impact-drill `size = 4;` (Blocks.java:3073),
        # eruption-drill `size = 5;` (Blocks.java:3096).
        # The classes are `public class Drill extends
        # Block{` (Drill.java:27) and `public class
        # DrillBuild extends Building{` (Drill.java:237);
        # BurstDrillBuild inherits DrillBuild (`public class
        # BurstDrill extends Drill{`, BurstDrill.java:17).
        # The fields are `protected @Nullable Item
        # returnItem;` (Drill.java:47), `protected int
        # returnCount;` (:48), `public boolean drawMineItem
        # = true;` (:51), `public @Load(value = "@-item",
        # fallback = "drill-item-@size") TextureRegion
        # itemRegion;` (:74) and `public float offset = 0f;`
        # (Block.java:217). There is NO driver tick line:
        # drawPlace is placement UI.
        self.assertIn('static func source_drill_draw_place_state(x: int, y: int, rotation: int, valid: bool, has_tile: bool, has_return_item: bool, return_item_icon: Variant, return_item_color: Variant, width: float, draw_mine_item: bool, item_region: Variant, offset: float, size: int, tilesize: float, icon_small: float, linked_item: Variant) -> Dictionary:', burst_drill)
        for expr in [
            'public void drawPlace(int x, int y, int rotation, boolean valid){',
            'super.drawPlace(x, y, rotation, valid);',
            'Tile tile = world.tile(x, y);',
            'if(returnItem != null){',
            'float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;',
            'Draw.rect(returnItem.fullIcon, dx, dy - 1, s, s);',
            'Draw.rect(returnItem.fullIcon, dx, dy, s, s);',
            'if(drawMineItem){',
            'Draw.color(returnItem.color);',
            'Draw.rect(itemRegion, tile.worldx() + offset, tile.worldy() + offset);',
            '}else{',
            'Tile to = tile.getLinkedTilesAs(this, tempTiles).find(t -> t.drop() != null && (t.drop().hardness > tier || (blockedItems != null && blockedItems.contains(t.drop()))));',
            'Item item = to == null ? null : to.drop();',
            'if(item != null){',
            'drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, valid);',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
            'protected @Nullable Item returnItem;',
            'protected int returnCount;',
            'public boolean drawMineItem = true;',
            'public static final int tilesize = 8;',
            'iconSmall = 8*3f;',
            'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;',
            'public float offset = 0f;',
            'size = 4;',
            'size = 5;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly:
        # null tile draws nothing; the return-item branch
        # geometry at (10, 20), size 4, tilesize 8, width
        # 40 (dx 56, dy 181, s 6) with 4 icon commands and
        # the mine-item rect at (80, 160); eruption size 5
        # (dy 185); tilesize 1.0 (dx -14, dy 27); the
        # tier-req branch shows "bar.drilltierreq" in
        # Pal.accent when valid, Pal.remove when invalid,
        # and nothing when no linked item drops.
        proof = DRILL_DRAW_PLACE_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_place_null_tile_no_commands',
            'draw_place_return_item_geometry',
            'draw_place_return_item_commands',
            'draw_place_mine_item_drawn',
            'draw_place_mine_item_hidden',
            'draw_place_eruption_geometry',
            'draw_place_tilesize_one_geometry',
            'draw_place_tier_req_shown',
            'draw_place_tier_req_invalid_color',
            'draw_place_no_linked_item_empty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_draw_place(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillDrawPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_DRAW_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_place_null_tile_no_commands',
            'draw_place_return_item_geometry',
            'draw_place_return_item_commands',
            'draw_place_mine_item_drawn',
            'draw_place_mine_item_hidden',
            'draw_place_eruption_geometry',
            'draw_place_tilesize_one_geometry',
            'draw_place_tier_req_shown',
            'draw_place_tier_req_invalid_color',
            'draw_place_no_linked_item_empty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
