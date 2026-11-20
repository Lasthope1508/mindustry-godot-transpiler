"""Register the DrillBuild drawPlace() remainder slice (N2351).

DrillBuild.drawPlace() (Drill.java:140-169, `public void
drawPlace(int x, int y, int rotation, boolean valid){`) is a
LEG slice: only the lines listed in the batch-8 scope §2.2
are owned here. `super.drawPlace(x, y, rotation, valid);`
(:141) is owned as call-site evidence (the N1162 Turret
drawPlace precedent); the Block.drawPlace implementation
(Block.java:491-494, drawPotentialLinks + drawOverlay) is
deferred. `Tile tile = world.tile(x, y);` (:143) looks the
tile up; the null-tile guard `if(tile == null) return;`
(:144) is NOT re-owned (owned by N1769/N919/N1821/N2038/
N2330, other methods) -- it arrives as the explicit
has_tile param. `countOre(tile);` (:146) is NOT re-owned
(N2020/N2021/N2071/N2302/N2330) -- its result (returnItem)
arrives as explicit params. The drillspeed text width
`float width = drawPlaceText(Core.bundle.formatFloat(
"bar.drillspeed", 60f / getDrillTime(returnItem) *
returnCount, 2), x, y, valid);` (:149) is NOT re-owned
(N699 source_drill_output_rate) -- it arrives as the
explicit width param, computed by the caller via N699 +
N1780 drawPlaceText. `Draw.mixcol(Color.darkGray, 1f);`
(:151), `Draw.reset();` (:153) and `Draw.color();` (:159)
are NOT re-owned (N570/N2341 and others) -- the commands
carry them as dict entries. The owned geometry is `float dx
= x * tilesize + offset - width/2f - 4f, dy = y * tilesize
+ offset + size * tilesize / 2f + 5, s = iconSmall / 4f;`
(:150) with the two icon rects `Draw.rect(
returnItem.fullIcon, dx, dy - 1, s, s);` (:152) and
`Draw.rect(returnItem.fullIcon, dx, dy, s, s);` (:154),
the drawMineItem branch `if(drawMineItem){` (:156) /
`Draw.color(returnItem.color);` (:157) / `Draw.rect(
itemRegion, tile.worldx() + offset, tile.worldy() +
offset);` (:158), and the else branch `}else{` (:161) with
the linked-tile search `Tile to = tile.getLinkedTilesAs(
this, tempTiles).find(t -> t.drop() != null &&
(t.drop().hardness > tier || (blockedItems != null &&
blockedItems.contains(t.drop()))));` (:162), `Item item =
to == null ? null : to.drop();` (:163), `if(item !=
null){` (:164) and `drawPlaceText(Core.bundle.get(
"bar.drilltierreq"), x, y, valid);` (:165). The search
itself is deferred to the caller as the explicit
linked_item param (the batch-8 scope §2.6). The tier-req
text is returned as a draw_place_text command with the
i18n key "bar.drilltierreq" kept verbatim; its 4-arg
overload picks `valid ? Pal.accent : Pal.remove`
(Block.java:532), carried as the string "Pal.accent" /
"Pal.remove" (the N2342 Radar drawPlace precedent); the
actual text rendering stays with the live N1780 helper.
tile.worldx() is x * tilesize (Tile.java:166-168), so the
mine-item rect sits at (x * tilesize + offset, y * tilesize
+ offset). The classes are `public class Drill extends
Block{` (Drill.java:27) and `public class DrillBuild
extends Building{` (Drill.java:237); BurstDrillBuild
inherits DrillBuild (`public class BurstDrill extends
Drill{`, BurstDrill.java:17). The fields are `protected
@Nullable Item returnItem;` (Drill.java:47), `protected int
returnCount;` (:48), `public boolean drawMineItem = true;`
(:51), `public @Load(value = "@-item", fallback =
"drill-item-@size") TextureRegion itemRegion;` (:74) and
`public float offset = 0f;` (Block.java:217). tilesize is 8
(`public static final int tilesize = 8;`, Vars.java:135)
and iconSmall is 24 (`iconSmall = 8*3f;`, Vars.java:139).
Per-def sizes: impact-drill `size = 4;` (Blocks.java:3073),
eruption-drill `size = 5;` (Blocks.java:3096).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2298 / N2302 / N2325 / N2330 / N2341
built, after source_drill_draw_select_state:
source_drill_draw_place_state(x, y, rotation, valid,
has_tile, has_return_item, return_item_icon,
return_item_color, width, draw_mine_item, item_region,
offset, size, tilesize, icon_small, linked_item)
returning the branch, the icon geometry (dx, dy,
icon_size), the ordered command list, the mine-item and
tier-req flags, super_draw_place_called, and the echoed
rotation/valid (the N2342 Radar drawPlace precedent).
(2) Draw.* calls are returned as command dicts, never
executed -- no Godot Draw API is invented (the N2314/N2325
draw precedent). (3) The drillspeed text draw (:149) and
the countOre call (:146) are NOT re-ported: the caller
passes the already-computed width and the already-bound
returnItem (the N2341 live-helper precedent). (4) There is
NO driver tick line: drawPlace is placement UI, not
per-tick state (the N2311/N2321/N2342 precedent). Ten new
result symbols: branch, dx, dy, icon_size, commands,
mine_item_drawn, tier_req_shown, super_draw_place_called,
rotation, valid. Slice sources: Drill.java + Vars.java +
Block.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07DrillDrawPlaceProof'
DRAW_PLACE_OWNER = 'SourceBurstDrillBuildState.source_drill_draw_place_state'
TESTS = ['test_c07_drill_draw_place_registration', 'test_all_c07_drill_draw_place_input_evidence_is_exact', 'test_drill_draw_place_state', 'test_reference_graph_and_actual_c07_drill_draw_place']
# The 4 slice sources the N2351 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void drawPlace(int x, int y, int rotation, boolean valid){', 'super.drawPlace(x, y, rotation, valid);', 'Tile tile = world.tile(x, y);', 'if(returnItem != null){', 'float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;', 'Draw.rect(returnItem.fullIcon, dx, dy - 1, s, s);', 'Draw.rect(returnItem.fullIcon, dx, dy, s, s);', 'if(drawMineItem){', 'Draw.color(returnItem.color);', 'Draw.rect(itemRegion, tile.worldx() + offset, tile.worldy() + offset);', '}else{', 'Tile to = tile.getLinkedTilesAs(this, tempTiles).find(t -> t.drop() != null && (t.drop().hardness > tier || (blockedItems != null && blockedItems.contains(t.drop()))));', 'Item item = to == null ? null : to.drop();', 'if(item != null){', 'drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, valid);', 'public class Drill extends Block{', 'public class DrillBuild extends Building{', 'protected @Nullable Item returnItem;', 'protected int returnCount;', 'public boolean drawMineItem = true;', 'public static final int tilesize = 8;', 'iconSmall = 8*3f;', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'public float offset = 0f;', 'size = 4;', 'size = 5;']

DEFERRED = [
    'DrillBuild drawPlace() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2351 proof runs headless on Linux here and waits for a Windows Godot run.',
    'DrillBuild drawPlace() super leg (Block.drawPlace, Block.java:491-494: drawPotentialLinks + drawOverlay) is folded as the explicit super_draw_place_called param; the link/overlay drawing itself waits for its own slice (the N2342 Radar drawPlace precedent).',
    'DrillBuild drawPlace() drillspeed text width (Drill.java:149, `float width = drawPlaceText(...)`) stays owned by N699 (PortGame source_drill_output_rate); the caller computes width via N699 + N1780 drawPlaceText and passes it explicitly -- this slice never re-owns :149.',
    'DrillBuild drawPlace() countOre call (Drill.java:146, `countOre(tile);`) stays owned by N2020/N2302; the caller passes the already-bound returnItem as explicit params (has_return_item, return_item_icon, return_item_color) -- this slice never re-owns :146.',
    'DrillBuild drawPlace() null-tile guard (Drill.java:144, `if(tile == null) return;`) and the generic Draw lines (`Draw.mixcol(Color.darkGray, 1f);` :151, `Draw.reset();` :153, `Draw.color();` :159) are owned by other-method slices (N1769/N919/N1821/N2038/N2330, N570/N2341); this slice implements the guard via the explicit has_tile param and carries the Draw calls as command dicts -- it never re-owns those lines.',
    'DrillBuild drawPlace() linked-tile search (Drill.java:162, `tile.getLinkedTilesAs(this, tempTiles).find(...)`) is deferred to the caller as the explicit linked_item param (the batch-8 scope §2.6); this slice never ports the search itself.',
    'DrillBuild drawPlace() tier-req text rendering stays owned by the live N1780 helper (PortGame source_block_draw_place_text_state); this slice only returns the draw_place_text command (text key "bar.drilltierreq", color "Pal.accent" / "Pal.remove" by valid) for the driver to render.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_place_inputs = {
        'x': a('int', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The tile x (Drill.java:140, `public void drawPlace(int x, int y, int rotation, boolean valid){`); the icon geometry converts it to world units with tilesize + offset (Drill.java:150); passed explicitly because drawPlace reads the ghost position.'),
        'y': a('int', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The tile y (Drill.java:140, `public void drawPlace(int x, int y, int rotation, boolean valid){`); the icon geometry converts it to world units with tilesize + offset (Drill.java:150); passed explicitly because drawPlace reads the ghost position.'),
        'rotation': a('int', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The placement rotation (Drill.java:140, `public void drawPlace(int x, int y, int rotation, boolean valid){`); passed to super.drawPlace (:141) and echoed in the result (the N2342 Radar drawPlace precedent); the owned body does not otherwise read it.'),
        'valid': a('bool', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'Whether the placement is valid (Drill.java:140, `public void drawPlace(int x, int y, int rotation, boolean valid){`); the tier-req text color picks `valid ? Pal.accent : Pal.remove` (Block.java:532, the 4-arg drawPlaceText overload); passed explicitly and echoed in the result.'),
        'has_tile': a('bool', 'Tile tile = world.tile(x, y);', 'Whether world.tile(x, y) found a tile (`Tile tile = world.tile(x, y);`, Drill.java:143); the null-tile guard `if(tile == null) return;` (:144) is NOT re-owned (owned by N1769/N919/N1821/N2038/N2330, other methods) -- it arrives as this param and the function returns no commands when there is no tile.'),
        'has_return_item': a('bool', 'if(returnItem != null){', 'Whether the drill has a return item (`if(returnItem != null){`, Drill.java:148); returnItem is `protected @Nullable Item returnItem;` (Drill.java:47), set by the N2020 countOre binding; passed explicitly because the countOre call (:146) is not this slice.'),
        'return_item_icon': a('Variant', 'Draw.rect(returnItem.fullIcon, dx, dy - 1, s, s);', 'The return item icon (`returnItem.fullIcon`, Drill.java:152); passed explicitly as an opaque region because the icon texture is per-item static state, not a live frame key (the N2314 per-def-param precedent).'),
        'return_item_color': a('Variant', 'Draw.color(returnItem.color);', 'The return item color (`returnItem.color`, Drill.java:157); passed explicitly as an opaque color because the item color is per-item static state, not a live frame key.'),
        'width': a('float', 'float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;', 'The drillspeed text width in world units (`width`, Drill.java:150, `dx = x * tilesize + offset - width/2f - 4f`); the width itself is computed by the caller via N699 (:149, `float width = drawPlaceText(...)`, NOT re-owned) + N1780 drawPlaceText and passed explicitly -- this slice never recomputes it.'),
        'draw_mine_item': a('bool', 'if(drawMineItem){', 'Whether the mined item icon is drawn (`if(drawMineItem){`, Drill.java:156); drawMineItem is `public boolean drawMineItem = true;` (Drill.java:51); passed explicitly because it is per-def static state (the N2212 per-def-param precedent).'),
        'item_region': a('Variant', 'Draw.rect(itemRegion, tile.worldx() + offset, tile.worldy() + offset);', 'The drill item region (`itemRegion`, Drill.java:158, `public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;`, Drill.java:74); passed explicitly as an opaque region because it is per-def static state, not a live frame key.'),
        'offset': a('float', 'public float offset = 0f;', 'The block offset in world units (`public float offset = 0f;`, Block.java:217); the icon geometry adds it to x * tilesize / y * tilesize (Drill.java:150) and the mine-item rect adds it to tile.worldx()/worldy() (:158); passed explicitly because it is per-def static state.', source=BLOCK),
        'size': a('int', 'size = 4;', 'The block size in tiles (impact-drill `size = 4;`, Blocks.java:3073; eruption-drill `size = 5;`, Blocks.java:3096); the icon geometry uses size * tilesize / 2f for dy (Drill.java:150); passed explicitly because it is per-def static state (the N2212 per-def-param precedent).', source=BLOCKS),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world units per tile (`public static final int tilesize = 8;`, Vars.java:135); the icon geometry multiplies x/y by it (Drill.java:150) and tile.worldx()/worldy() are x/y * tilesize (Tile.java:166-168); passed explicitly.', source=VARS),
        'icon_small': a('float', 'iconSmall = 8*3f;', 'The small icon size in UI units (`iconSmall = 8*3f;`, Vars.java:139, 24); the icon size is s = iconSmall / 4f (Drill.java:150, 6.0); passed explicitly.', source=VARS),
        'linked_item': a('Variant', 'Item item = to == null ? null : to.drop();', 'The drop of the linked tile found by the tier-req search (`Item item = to == null ? null : to.drop();`, Drill.java:163), or null when no linked tile drops an item; the search itself (`Tile to = tile.getLinkedTilesAs(this, tempTiles).find(...)`, :162) is deferred to the caller (the batch-8 scope §2.6) -- this slice never ports it.'),
    }
    draw_place_outputs = {
        'branch': a('String', 'if(returnItem != null){', 'Which display branch ran: "return_item" when a return item is present (Drill.java:148, `if(returnItem != null){`), "tier_req" when there is none but a linked tile drops an item (:161-164), "none" when there is no tile or no linked item drops anything.'),
        'dx': a('float', 'float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;', 'The icon center x in world units (`dx = x * tilesize + offset - width/2f - 4f`, Drill.java:150); 56.0 at (10, 20), width 40, tilesize 8, offset 0; 0.0 outside the return-item branch.'),
        'dy': a('float', 'float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;', 'The icon center y in world units (`dy = y * tilesize + offset + size * tilesize / 2f + 5`, Drill.java:150); 181.0 at (10, 20), size 4, tilesize 8, offset 0; 185.0 for eruption-drill size 5; 0.0 outside the return-item branch.'),
        'icon_size': a('float', 'float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;', 'The icon size in world units (`s = iconSmall / 4f`, Drill.java:150); 6.0 (iconSmall 24); 0.0 outside the return-item branch.'),
        'commands': a('Array', 'Draw.rect(returnItem.fullIcon, dx, dy - 1, s, s);', 'The draw calls this placement issues, in Java order, one Dictionary per call (`action`, plus `color`/`alpha` for mixcol/color, `region`/`x`/`y`/`w`/`h` for rect, `text_key`/`x`/`y`/`valid`/`color` for draw_place_text): mixcol darkGray 1.0, shadow rect at dy - 1, reset, foreground rect at dy (Drill.java:152-154), plus color + mine-item rect + reset when drawMineItem (:157-159), or the tier-req draw_place_text command (:165) in the else branch. Empty when there is no tile or no linked item drops anything.'),
        'mine_item_drawn': a('bool', 'if(drawMineItem){', 'Whether the mine-item icon was drawn (`if(drawMineItem){`, Drill.java:156): true exactly when the return-item branch ran with drawMineItem true; the rect sits at (x * tilesize + offset, y * tilesize + offset) (Drill.java:158, tile.worldx()/worldy() are x/y * tilesize, Tile.java:166-168).'),
        'tier_req_shown': a('bool', 'drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, valid);', 'Whether the tier-requirement text was shown (`drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, valid);`, Drill.java:165): true exactly when the else branch ran with a linked item (`if(item != null){`, :164); the i18n key "bar.drilltierreq" is kept verbatim, never translated.'),
        'super_draw_place_called': a('bool', 'super.drawPlace(x, y, rotation, valid);', 'Whether the super call ran (`super.drawPlace(x, y, rotation, valid);`, Drill.java:141): always true -- the Block.drawPlace implementation (Block.java:491-494) is deferred and recorded here (the N2342 Radar drawPlace precedent).'),
        'rotation': a('int', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The placement rotation echoed back (Drill.java:140, `public void drawPlace(int x, int y, int rotation, boolean valid){`); passed to super.drawPlace (:141) and echoed in the result (the N2342 Radar drawPlace precedent).'),
        'valid': a('bool', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'Whether the placement is valid, echoed back (Drill.java:140, `public void drawPlace(int x, int y, int rotation, boolean valid){`); the tier-req text color picks `valid ? Pal.accent : Pal.remove` (Block.java:532), carried as the string "Pal.accent" / "Pal.remove" (the N2342 precedent).'),
    }
    return draw_place_inputs, draw_place_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    draw_place_inputs, draw_place_outputs = definitions()

    entries = [
        ('N2351', DRAW_PLACE_OWNER, 'source_drill_draw_place_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'DrillBuild.drawPlace()', draw_place_inputs, draw_place_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild drawPlace() remainder state from Drill.java + Vars.java + Block.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild drawPlace() remainder state from Drill.java + Vars.java + Block.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: branch, dx, dy, icon_size,
    # commands, mine_item_drawn, tier_req_shown,
    # super_draw_place_called, rotation, valid.
    by_slice['N2351'] = [
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
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2351', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill$DrillBuild', java_method='DrillBuild.drawPlace()', godot_owner=DRAW_PLACE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2351'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
