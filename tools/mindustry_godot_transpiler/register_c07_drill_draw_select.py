"""Register the DrillBuild drawSelect() slice (N2283).

DrillBuild.drawSelect() (Drill.java:262-264, `public void
drawSelect(){`) calls `drawItemSelection(dominantItem);`
(:263) -- the dominant item's icon is drawn above the
building through the live BuildingComp.drawItemSelection
helper (BuildingComp.java:1249-1257, `public void
drawItemSelection(@Nullable UnlockableContent selection){`):
`if(selection != null){` (:1250), then `float dx = x -
block.size * tilesize/2f, dy = y + block.size *
tilesize/2f, s = iconSmall / 4f *
selection.fullIcon.ratio(), h = iconSmall / 4f;` (:1251),
`Draw.mixcol(Color.darkGray, 1f);` (:1252),
`Draw.rect(selection.fullIcon, dx, dy - 1, s, h);`
(:1253), `Draw.reset();` (:1254),
`Draw.rect(selection.fullIcon, dx, dy, s, h);` (:1255).
The helper is ALREADY LIVE as PortGame N570
(source_building_draw_item_selection_state, owner PortGame,
in the ledger) -- this slice does NOT re-port it: the
pure function source_drill_draw_select_state calls the
live helper with dominantItem passed as explicit params
(has_dominant_item, dominant_item_icon_ratio), following
the N2220 RepairTurret drawSelect / N2281 Radar drawSelect
precedent (one pure function on the family file, no driver
tick line -- drawSelect is selection UI, not per-tick
state). The helper returns the nine result keys visible,
dx, dy, shadow_color, shadow_alpha, shadow_y, foreground_y,
selection_width, selection_height (only visible when there
is no dominant item). The classes are `public class Drill
extends Block{` (Drill.java:27) and `public class
DrillBuild extends Building{` (Drill.java:237);
BurstDrillBuild inherits DrillBuild (`public class
BurstDrill extends Drill{`, BurstDrill.java:17). The
dominant item is `public Item dominantItem;`
(Drill.java:244), set by the N2262 ore/dominant binding.
tilesize is 8 (`public static final int tilesize = 8;`,
Vars.java:135) and iconSmall is 24 (`iconSmall = 8*3f;`,
Vars.java:139). Per-def sizes: impact-drill `size = 4;`
(Blocks.java:3073), eruption-drill `size = 5;`
(Blocks.java:3096).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 / N2256 / N2258 / N2269 / N2262 /
N2266 / N2271 / N2277 / N2280 built, after
source_drill_set_stats_state:
source_drill_draw_select_state(x, y, block_size, tilesize,
icon_small, has_dominant_item, dominant_item_icon_ratio)
returning the live helper's dict verbatim. (2)
drawItemSelection is NOT re-ported: the caller passes the
already-bound dominantItem (the N2262 binding) and the
already-live N570 helper renders it. (3) There is NO
driver tick line: drawSelect is selection UI (the N2220 /
N2281 lifecycle precedent); the proof calls the pure
function directly with per-def params. Nine new result
symbols: visible, dx, dy, shadow_color, shadow_alpha,
shadow_y, foreground_y, selection_width,
selection_height. Two defs share the function
(impact-drill, Blocks.java:3070, size 4; eruption-drill,
Blocks.java:3093, size 5); they differ only in the
per-def params the caller passes. Slice sources:
Drill.java + BuildingComp.java + Vars.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07DrillDrawSelectProof'
DRAW_SELECT_OWNER = 'SourceBurstDrillBuildState.source_drill_draw_select_state'
TESTS = ['test_c07_drill_draw_select_registration', 'test_all_c07_drill_draw_select_input_evidence_is_exact', 'test_drill_draw_select_state', 'test_reference_graph_and_actual_c07_drill_draw_select']
# The 4 slice sources the N2283 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void drawSelect(){', 'drawItemSelection(dominantItem);', 'public void drawItemSelection(@Nullable UnlockableContent selection){', 'if(selection != null){', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'Draw.mixcol(Color.darkGray, 1f);', 'Draw.rect(selection.fullIcon, dx, dy - 1, s, h);', 'Draw.reset();', 'Draw.rect(selection.fullIcon, dx, dy, s, h);', 'public Item dominantItem;', 'public class Drill extends Block{', 'public class DrillBuild extends Building{', 'public static final int tilesize = 8;', 'iconSmall = 8*3f;', 'size = 4;', 'size = 5;']

DEFERRED = [
    'DrillBuild drawSelect() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2283 proof runs headless on Linux here and waits for a Windows Godot run.',
    'DrillBuild drawSelect() concrete icon rendering (Draw.rect(selection.fullIcon, ...) with the live TextureRegion, BuildingComp.java:1253/1255) stays owned by Godot rendering integration; this helper preserves visibility, geometry, shadow, reset, and foreground state.',
    'DrillBuild drawSelect() dominantItem binding (the N2302 ore/dominant binding sets dominantItem from the mined ore) -- the caller passes the already-bound dominantItem; the binding itself is not this slice.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_select_inputs = {
        'x': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The building world x (BuildingComp.drawItemSelection, BuildingComp.java:1251: `dx = x - block.size * tilesize/2f`); passed explicitly because drawSelect reads the live building position.', source=BUILDING_COMP),
        'y': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The building world y (BuildingComp.drawItemSelection, BuildingComp.java:1251: `dy = y + block.size * tilesize/2f`); passed explicitly because drawSelect reads the live building position.', source=BUILDING_COMP),
        'block_size': a('int', 'size = 4;', 'The block size in tiles (impact-drill `size = 4;`, Blocks.java:3073; eruption-drill `size = 5;`, Blocks.java:3096); the helper offsets dx/dy by block.size * tilesize/2f (BuildingComp.java:1251); passed explicitly because it is per-def static state (the N2212 per-def-param precedent).', source=BLOCKS),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world units per tile (`public static final int tilesize = 8;`, Vars.java:135); the helper multiplies block.size * tilesize/2f (BuildingComp.java:1251); passed explicitly.', source=VARS),
        'icon_small': a('float', 'iconSmall = 8*3f;', 'The small icon size in UI units (`iconSmall = 8*3f;`, Vars.java:139, 24); the helper sizes the icon s = iconSmall / 4f * ratio, h = iconSmall / 4f (BuildingComp.java:1251); passed explicitly.', source=VARS),
        'has_dominant_item': a('bool', 'public Item dominantItem;', 'Whether the drill has a dominant item: dominantItem is `public Item dominantItem;` (Drill.java:244), set by the N2262 ore/dominant binding; drawSelect passes it to drawItemSelection (Drill.java:263), whose guard is `if(selection != null){` (BuildingComp.java:1250); passed explicitly because the binding is not this slice.'),
        'dominant_item_icon_ratio': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The dominant item icon aspect ratio (`selection.fullIcon.ratio()`, BuildingComp.java:1251); the helper sizes the icon width s = iconSmall / 4f * ratio; passed explicitly with the dominant item.', source=BUILDING_COMP),
    }
    draw_select_outputs = {
        'visible': a('bool', 'if(selection != null){', 'Whether the dominant-item icon is drawn: true exactly when a dominant item is present (BuildingComp.java:1250, `if(selection != null){`); the helper returns only {visible: false} when there is none.', source=BUILDING_COMP),
        'dx': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The icon center x in world units (`dx = x - block.size * tilesize/2f`, BuildingComp.java:1251); impact-drill 84.0 at x 100 (size 4, tilesize 8), eruption-drill 80.0 (size 5).', source=BUILDING_COMP),
        'dy': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The icon center y in world units (`dy = y + block.size * tilesize/2f`, BuildingComp.java:1251); impact-drill 216.0 at y 200 (size 4, tilesize 8), eruption-drill 220.0 (size 5).', source=BUILDING_COMP),
        'shadow_color': a('String', 'Draw.mixcol(Color.darkGray, 1f);', 'The shadow rect color (`Draw.mixcol(Color.darkGray, 1f);`, BuildingComp.java:1252): the helper pins "darkGray" (SourceBuildingDefaults DRAW_ITEM_SELECTION_SHADOW_COLOR).', source=BUILDING_COMP),
        'shadow_alpha': a('float', 'Draw.mixcol(Color.darkGray, 1f);', 'The shadow rect alpha (`Draw.mixcol(Color.darkGray, 1f);`, BuildingComp.java:1252): the helper pins 1.0 (SourceBuildingDefaults DRAW_ITEM_SELECTION_SHADOW_ALPHA).', source=BUILDING_COMP),
        'shadow_y': a('float', 'Draw.rect(selection.fullIcon, dx, dy - 1, s, h);', 'The shadow rect y (`Draw.rect(selection.fullIcon, dx, dy - 1, s, h);`, BuildingComp.java:1253): dy - 1 (SourceBuildingDefaults DRAW_ITEM_SELECTION_SHADOW_Y_OFFSET 1.0); impact-drill 215.0 at dy 216.0.', source=BUILDING_COMP),
        'foreground_y': a('float', 'Draw.rect(selection.fullIcon, dx, dy, s, h);', 'The foreground rect y (`Draw.rect(selection.fullIcon, dx, dy, s, h);`, BuildingComp.java:1255): dy + 0 (SourceBuildingDefaults DRAW_ITEM_SELECTION_FOREGROUND_Y_OFFSET 0.0); impact-drill 216.0 at dy 216.0.', source=BUILDING_COMP),
        'selection_width': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The icon width in world units (`s = iconSmall / 4f * selection.fullIcon.ratio()`, BuildingComp.java:1251); 6.0 at ratio 1.0, 12.0 at ratio 2.0 (iconSmall 24).', source=BUILDING_COMP),
        'selection_height': a('float', 'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', 'The icon height in world units (`h = iconSmall / 4f`, BuildingComp.java:1251); 6.0 (iconSmall 24).', source=BUILDING_COMP),
    }
    return draw_select_inputs, draw_select_outputs


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
    draw_select_inputs, draw_select_outputs = definitions()

    entries = [
        ('N2283', DRAW_SELECT_OWNER, 'source_drill_draw_select_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'DrillBuild.drawSelect()', draw_select_inputs, draw_select_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild drawSelect() state from Drill.java + BuildingComp.java + Vars.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild drawSelect() state from Drill.java + BuildingComp.java + Vars.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: visible, dx, dy, shadow_color,
    # shadow_alpha, shadow_y, foreground_y, selection_width,
    # selection_height.
    by_slice['N2283'] = [
        'source_drill_draw_select_state_result.visible',
        'source_drill_draw_select_state_result.dx',
        'source_drill_draw_select_state_result.dy',
        'source_drill_draw_select_state_result.shadow_color',
        'source_drill_draw_select_state_result.shadow_alpha',
        'source_drill_draw_select_state_result.shadow_y',
        'source_drill_draw_select_state_result.foreground_y',
        'source_drill_draw_select_state_result.selection_width',
        'source_drill_draw_select_state_result.selection_height',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2283', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill$DrillBuild', java_method='DrillBuild.drawSelect()', godot_owner=DRAW_SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2283'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
