"""Register the BeamDrillBuild.drawPlace() slice (N2385).

BeamDrillBuild.drawPlace() (BeamDrill.java:138-197, `public void
drawPlace(int x, int y, int rotation, boolean valid){`) is the
BeamDrill placement preview on `public class BeamDrillBuild
extends Building{` (BeamDrill.java:220) inside `public class
BeamDrill extends Block{` (BeamDrill.java:25): one scan ray per
footprint side (nearbySide + world.tile), one Drawf.dashLine
per side (Pal.remove when nothing found, Pal.placing when a
drop was found), the drillspeed text plus the found item's
icon (or the tier-requirement text when only an unmineable
drop was found). One pure function on the existing
SourceBeamDrillBuildState.gd (created by N2155, extended by
N2378/N2379/N2382), following the N2351 DrillBuild.drawPlace
precedent: it returns the computed place state (dash lines,
text content, icon rects, command list) and does NOT touch
real Draw / Drawf / drawPlaceText playback. There is NO driver
tick line: drawPlace is placement UI, not per-tick state.

RED decisions (resolved at RED): (1) The 28 distinguishing
exprs are the 0-hit lines re-probed at base 1047fc24 in both
ledgers (28/40 candidates 0-hit). The 12 HIT exprs
(`boolean multiple = false;` / `for(int i = 0; i < size;
i++){` / `Tile other = world.tile(rx, ry);` / `Item drop =
other.wallDrop();` / `multiple = true;` all N2379
updateFacing; `if(item != null){` [N1465, N2351]; the
dx/dy/s line [N2351]; `Draw.mixcol(Color.darkGray, 1f);`
[N570, N2341]; `public void drawPlace(int x, int y, int
rotation, boolean valid){` [11 drawPlace slices];
`}else{` / `break;` / `Draw.reset();` generic) are
evidence/context only, NOT distinguishing exprs, and are NOT
in EXACT_EXPRS. (2) nearbySide is the N1762 callee reached
through its static geometry form (the N2379 updateLasers
precedent), NOT re-ported; world.tile arrives as the explicit
world_tile Callable (the N2379 param precedent). (3)
getDrillTime is BeamDrill's OWN method (BeamDrill.java:216-217,
`public float getDrillTime(Item item){` / `return drillTime /
drillMultipliers.get(item, 1f);`), NOT N2344's
BurstDrill.getDrillTime (different class, same formula shape):
it arrives as the explicit get_drill_time Callable (item name
-> drill time), driven in the proof by the N2344 pure function
applied to BeamDrill's own per-def drillTime. (4)
drawPlaceText is the already-live N1779/N1780 helper: this
function returns the text as a command dict (the N2351
commands precedent) instead of rendering it, and the text
width arrives as the explicit text_width param (the N2351
width precedent -- the caller computes it via the N1779
helper; the proof pins a fixed width and asserts dx against
it). The i18n keys "bar.drillspeed" / "bar.drilltierreq" are
kept verbatim, never translated. (5) The inner scan is a
while loop so j keeps Java's post-loop value (a GDScript for
loop would leave j at range - 1); len = min(j, range - 1).
(6) The dash-line color is "Pal.remove" when found == null
else "Pal.placing" (the N2351 string-carried Pal precedent).
(7) The icon rects follow the N2351 formula exactly (dx = x *
tilesize + offset - width/2 - 4, dy = y * tilesize + offset +
size * tilesize/2 + 5, s = iconSmall/4, shadow at dy - 1).
(8) Per-def values: plasma-bore drillTime 160f, tier 3, size
2, range 5; large-plasma-bore drillTime 100f, tier 5, size 3,
range 6 (Blocks.java:3038-3065); class defaults drillTime
200f (BeamDrill.java:39), range 5 (:40), tier 1 (:41).
Eleven new result symbols: item, invalid_item, multiple,
count, dash_lines, drill_speed, drill_speed_text, icon_rect,
icon_shadow_rect, commands, branch. Slice sources:
BeamDrill.java + Block.java + Vars.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_draw import DEFERRED as N2382_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
VARS = 'core/src/mindustry/Vars.java'
PROOF = '/root/C07BeamDrillDrawPlaceProof'
DRAW_PLACE_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_draw_place_state'
TESTS = ['test_c07_beam_drill_draw_place_registration', 'test_all_c07_beam_drill_draw_place_input_evidence_is_exact', 'test_beam_drill_draw_place_state', 'test_reference_graph_and_actual_c07_beam_drill_draw_place']
# The 3 slice sources the N2385 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/Vars.java',
]
EXACT_EXPRS = [
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
]

# DEFERRED is carried from the N2382 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (drawPlace touches no draw tick, updateTile advance,
# shouldConsume gate, liquid row, drillMultipliers row, or
# facing binding), so all are carried verbatim. Three entries
# are added: N2385's Windows proof debt, the concrete-rendering
# boundary, and the BeamDrill getDrillTime callee note.
DEFERRED = list(N2382_DEFERRED) + [
    'BeamDrill drawPlace() Windows Godot proof -- debt in GOAL.md section 5, same as N2155: the N2385 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BeamDrill drawPlace() concrete dash-line / text / icon rendering (Drawf.dashLine / drawPlaceText / Draw.rect with live TextureRegions) stays owned by Godot rendering integration; this helper preserves dash endpoints, text content and icon rects.',
    'BeamDrill drawPlace() getDrillTime callee -- BeamDrill.getDrillTime (BeamDrill.java:216-217) is a separate method from N2344 BurstDrill.getDrillTime; the Callable param is driven here by the N2344 pure function applied to BeamDrill per-def values, a BeamDrill-owned getDrillTime slice may pin the method itself later.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    nearby_expr = 'nearbySide(x, y, rotation, i, Tmp.p1);'
    width_expr = 'float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);'
    dash_expr = 'Drawf.dashLine(found == null ? Pal.remove : Pal.placing,'
    icon_expr = 'Draw.rect(item.fullIcon, dx, dy, s, s);'
    shadow_expr = 'Draw.rect(item.fullIcon, dx, dy - 1, s, s);'
    item_expr = 'Item item = null, invalidItem = null;'
    draw_place_inputs = {
        'x': a('int', nearby_expr, 'The placement tile x (BeamDrill.java:143, `nearbySide(x, y, rotation, i, Tmp.p1);`): the scan starts at the footprint side of (x, y).'),
        'y': a('int', nearby_expr, 'The placement tile y (BeamDrill.java:143, `nearbySide(x, y, rotation, i, Tmp.p1);`): the scan starts at the footprint side of (x, y).'),
        'rotation': a('int', nearby_expr, 'The placement rotation 0-3 (BeamDrill.java:143, `nearbySide(x, y, rotation, i, Tmp.p1);`): it picks the faced side per footprint index and the d4 scan direction (Geometry.d4x/d4y).'),
        'valid': a('bool', width_expr, 'Whether the placement is valid (BeamDrill.java:183, `float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);`): it picks the drillspeed text color (valid ? Pal.accent : Pal.remove, Block.java:532).'),
        'size': a('int', 'for(int i = 0; i < size; i++){', 'The block size (BeamDrill.java:142, `for(int i = 0; i < size; i++){`): the scan runs one ray per footprint side (plasma-bore 2, large-plasma-bore 3, Blocks.java:3049-3065); passed explicitly (the N2212 per-def-param precedent).'),
        'range_value': a('int', 'public int range = 5;', 'The scan range in tiles (BeamDrill.java:40, `public int range = 5;`, class default; plasma-bore 5, large-plasma-bore 6, Blocks.java:3049-3065): the inner scan runs `for(; j < range; j++)` (BeamDrill.java:149).'),
        'tier': a('int', 'public int tier = 1;', 'The drill tier (BeamDrill.java:41, `public int tier = 1;`, class default; plasma-bore 3, large-plasma-bore 5, Blocks.java:3049-3065): a drop counts only when `drop.hardness <= tier` (BeamDrill.java:154).'),
        'blocked_items': a('Variant', 'public @Nullable Seq<Item> blockedItems;', 'The blocked items (BeamDrill.java:51, `public @Nullable Seq<Item> blockedItems;`, null or an Array of item names): a drop counts only when it is not blocked (BeamDrill.java:154, `blockedItems == null || !blockedItems.contains(drop)`).'),
        'world_tile': a('Callable', 'Tile other = world.tile(rx, ry);', 'The world tile lookup (BeamDrill.java:151, `Tile other = world.tile(rx, ry);`): world_tile.call(rx, ry) returns null or a tile Dictionary {"solid", "wall_drop", "wall_drop_hardness"} (the N2379 param precedent -- the live world is not a frame key).'),
        'get_drill_time': a('Callable', 'public float getDrillTime(Item item){', 'The drill-time lookup for the found item (BeamDrill.java:216, `public float getDrillTime(Item item){`, `return drillTime / drillMultipliers.get(item, 1f);`): get_drill_time.call(item) returns the drill time in ticks; driven in the proof by the N2344 pure function applied to BeamDrill per-def values.'),
        'item_icon': a('Callable', icon_expr, 'The item icon lookup (BeamDrill.java:187, `Draw.rect(item.fullIcon, dx, dy, s, s);`, Item.fullIcon): item_icon.call(item) returns the region Variant for the found item; passed explicitly because regions are load-time state.'),
        'offset': a('float', 'public float offset = 0f;', 'The block draw offset (Block.java:217, `public float offset = 0f;`): it shifts the icon rect (BeamDrill.java:184, `float dx = x * tilesize + offset - width/2f - 4f, ...`).', source=BLOCK),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize (Vars.java:135, `public static final int tilesize = 8;`): tile-to-world conversion for the dash lines and the icon rect.', source=VARS),
        'icon_small': a('float', 'iconSmall = 8*3f;', 'The small icon size (Vars.java:139, `iconSmall = 8*3f;`, 24): the icon size is s = iconSmall / 4f (BeamDrill.java:184).', source=VARS),
        'text_width': a('float', width_expr, 'The drillspeed text width as laid out by the drawPlaceText helper (BeamDrill.java:183, `float width = drawPlaceText(...);`): the caller computes it via the N1779/N1780 helper; the icon dx is x * tilesize + offset - width/2 - 4 (the N2351 width precedent).'),
    }
    draw_place_outputs = {
        'item': a('Variant', item_expr, 'The found item name, or null when no side found a mineable drop (BeamDrill.java:139, `Item item = null, invalidItem = null;`, set BeamDrill.java:174, `item = found;`).'),
        'invalid_item': a('Variant', item_expr, 'The unmineable drop name, or null when no side hit a too-hard or blocked drop (BeamDrill.java:139, set BeamDrill.java:158, `invalidItem = drop;`).'),
        'multiple': a('bool', 'boolean multiple = false;', 'Whether more than one distinct item will be drilled (BeamDrill.java:140, `boolean multiple = false;`, set BeamDrill.java:170-172, `if(item != found && item != null){ multiple = true; }`): when true the icon is hidden.'),
        'count': a('int', 'int count = 0;', 'How many sides found a mineable drop (BeamDrill.java:141, `int count = 0;`, incremented BeamDrill.java:156, `count++;`): the drillspeed rate is 60 / getDrillTime(item) * count.'),
        'dash_lines': a('Array', dash_expr, 'One dash line per footprint side {color, x1, y1, x2, y2} (BeamDrill.java:178-182, `Drawf.dashLine(found == null ? Pal.remove : Pal.placing, ...`): the color is "Pal.remove" when the side found nothing, "Pal.placing" otherwise; the end is (p1 + d4 * len) * tilesize with len = min(j, range - 1).'),
        'drill_speed': a('Variant', width_expr, 'The drillspeed rate 60 / getDrillTime(item) * count, or null when no item was found (BeamDrill.java:183, `60f / getDrillTime(item) * count`).'),
        'drill_speed_text': a('Variant', width_expr, 'The drillspeed text {key "bar.drillspeed", value, decimals 2}, or null when no item was found (BeamDrill.java:183, `Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2)`): the i18n key is kept verbatim, never translated.'),
        'icon_rect': a('Variant', icon_expr, 'The found item icon rect {region, x, y, w, h}, or null when there is no item or multiple items (BeamDrill.java:188, `Draw.rect(item.fullIcon, dx, dy, s, s);`).'),
        'icon_shadow_rect': a('Variant', shadow_expr, 'The icon shadow rect {region, x, y - 1, w, h}, or null when there is no item or multiple items (BeamDrill.java:187, `Draw.rect(item.fullIcon, dx, dy - 1, s, s);`, after `Draw.mixcol(Color.darkGray, 1f);`).'),
        'commands': a('Array', dash_expr, 'The draw commands in Java order (the N2351 commands precedent): one dash_line per side, then the drillspeed draw_place_text, then (when a single item) mixcol / rect / reset / rect for the icon, or (when only an invalid drop) the tier-req draw_place_text.'),
        'branch': a('String', '}else if(invalidItem != null){', 'Which tail branch ran: "item" when an item was found, "tier_req" when only an invalid drop was found (BeamDrill.java:190, `}else if(invalidItem != null){`), "none" otherwise.'),
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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (draw_place_inputs, draw_place_outputs) = definitions()

    entries = [
        ('N2385', DRAW_PLACE_OWNER, 'source_beam_drill_draw_place_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.drawPlace', draw_place_inputs, draw_place_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.drawPlace() state from BeamDrill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.drawPlace() state from BeamDrill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: item, invalid_item,
    # multiple, count, dash_lines, drill_speed,
    # drill_speed_text, icon_rect, icon_shadow_rect,
    # commands, branch.
    by_slice['N2385'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2385', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.drawPlace', godot_owner=DRAW_PLACE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2385'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
