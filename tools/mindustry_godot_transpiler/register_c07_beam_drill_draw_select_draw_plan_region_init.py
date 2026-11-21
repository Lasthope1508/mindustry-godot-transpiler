"""Register the BeamDrill drawSelect() + drawPlanRegion() + init() slice (N2394).

BeamDrillBuild.drawSelect() (BeamDrill.java:231-234, `public
void drawSelect(){`) is the whole method in one line:
`drawItemSelection(lastItem);` (:233) -- the BuildingComp
selection icon for the last mined item
(`public void drawItemSelection(@Nullable
UnlockableContent selection){`, BuildingComp.java:1249,
which draws the item icon at the top-left of the block
when the selection is not null and is a no-op
otherwise). `lastItem` is the BeamDrillBuild field
(`public @Nullable Item lastItem;`, BeamDrill.java:223),
set by updateTile (`lastItem = drop;`, BeamDrill.java:396)
and cleared when the facing changes (`lastItem = null;`,
BeamDrill.java:376, :409).

BeamDrill.drawPlanRegion() (BeamDrill.java:113-117,
`public void drawPlanRegion(BuildPlan plan,
Eachable<BuildPlan> list){`) draws the block region
(`Draw.rect(region, plan.drawx(), plan.drawy());`,
:115) and the top region rotated by the plan rotation
(`Draw.rect(topRegion, plan.drawx(), plan.drawy(),
plan.rotation * 90);`, :116). `region` is the Block base
region; `topRegion` is `public @Load("@-top")
TextureRegion topRegion;` (BeamDrill.java:36) -- the
icons() pair (`return new TextureRegion[]{region,
topRegion};`, BeamDrill.java:108).

BeamDrill.init() (BeamDrill.java:81-89, `public void
init(){`) widens the clip radius
(`updateClipRadius((range + 2) * tilesize);`, :82) so
the drill keeps drawing its lasers past the block
bounds, then runs the generic `super.init();` (:83)
plus the blockedItems fill (`if(blockedItems == null
&& blockedItem != null){` / `blockedItems =
Seq.with(blockedItem);`, :84-86). updateClipRadius is
the Block callee (`public void updateClipRadius(float
radiusInWorldUnits){`, Block.java:1006, with `clipSize
= Math.max(clipSize, this.size * tilesize +
radiusInWorldUnits * 2f);`, Block.java:1007). `range`
is the BeamDrill field (`public int range = 5;`,
BeamDrill.java:40; plasma-bore 5, large-plasma-bore 6,
Blocks.java:3049-3065) and `tilesize` is (`public
static final int tilesize = 8;`, Vars.java:135).

Three pure functions on the existing
SourceBeamDrillBuildState.gd (the N2391
canPlaceOn+setBars precedent, the N2393 drawSelect
drawer precedent): drawItemSelection / Draw.rect /
updateClipRadius arrive as explicit Callable params
and are NOT re-ported; `lastItem` / `plan` /
`range` / `tilesize` arrive as explicit params; the
functions return the computed frame data and do NOT
touch real Draw / Drawf playback. NO driver tick
line: drawSelect / drawPlanRegion are selection /
placement UI, init is load-time clip setup. Seven new
result symbols: draw_item_selection_called,
last_item, draw_rect_called, top_region_rotation,
plan_position, clip_radius,
update_clip_radius_called. Slice sources:
BeamDrill.java + Block.java + BuildingComp.java +
Vars.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_can_place_on_set_bars import DEFERRED as N2391_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
VARS = 'core/src/mindustry/Vars.java'
PROOF = '/root/C07BeamDrillDrawSelectDrawPlanRegionInitProof'
DRAW_SELECT_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_draw_select_state'
DRAW_PLAN_REGION_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_draw_plan_region_state'
INIT_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_init_state'
TESTS = ['test_c07_beam_drill_draw_select_draw_plan_region_init_registration', 'test_all_c07_beam_drill_draw_select_draw_plan_region_init_input_evidence_is_exact', 'test_beam_drill_draw_select_draw_plan_region_init_state', 'test_reference_graph_and_actual_c07_beam_drill_draw_select_draw_plan_region_init']
# The 3 slice sources the N2394 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/Vars.java',
]
EXACT_EXPRS = [
    'drawItemSelection(lastItem);',
    'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);',
    'updateClipRadius((range + 2) * tilesize);',
]

# DEFERRED is carried from the N2391 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (drawSelect / drawPlanRegion are selection / placement UI, not
# the draw tick, updateTile advance, shouldConsume gate, liquid
# row, drillMultipliers row, or facing binding; init is a
# load-time clip setup, not the world scan or Bar UI), so all
# are carried verbatim. One entry is added: N2394's Windows
# proof debt.
DEFERRED = list(N2391_DEFERRED) + [
    'BeamDrill drawSelect() + drawPlanRegion() + init() Windows Godot proof -- debt in GOAL.md section 5, same as N2391: the N2394 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_select_inputs = {
        'frame': a('Dictionary', 'public void drawSelect(){', 'The beam-drill frame (BeamDrillBuild.drawSelect, BeamDrill.java:231): carries no live keys for this selection UI -- lastItem is live build state passed explicitly, not a frame key (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'last_item': a('Variant', 'public @Nullable Item lastItem;', 'The last mined item: the BeamDrillBuild field (`public @Nullable Item lastItem;`, BeamDrill.java:223), set by updateTile (`lastItem = drop;`, BeamDrill.java:396) and cleared when the facing changes (`lastItem = null;`, BeamDrill.java:376, :409); passed explicitly because it is live build state, not a frame key.'),
        'draw_item_selection': a('Callable', 'drawItemSelection(lastItem);', 'The drawItemSelection delegate (BeamDrill.java:233, `drawItemSelection(lastItem);`): the BuildingComp callee (`public void drawItemSelection(@Nullable UnlockableContent selection){`, BuildingComp.java:1249, which draws the item icon at the top-left of the block when the selection is not null and is a no-op otherwise) -- NOT re-ported here: it arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call(last_item)); an invalid callable is reported via draw_item_selection_called false.'),
    }
    draw_select_outputs = {
        'draw_item_selection_called': a('bool', 'drawItemSelection(lastItem);', 'Whether the drawItemSelection delegate was invoked (BeamDrill.java:233, `drawItemSelection(lastItem);`): true when the draw_item_selection Callable is valid, false otherwise (the N2377 drawer_called precedent).'),
        'last_item': a('Variant', 'public @Nullable Item lastItem;', 'The last mined item, read through (BeamDrill.java:233, `drawItemSelection(lastItem);` over `public @Nullable Item lastItem;`, BeamDrill.java:223): the item whose selection icon the delegate draws, or null when nothing was mined yet.'),
    }
    draw_plan_region_inputs = {
        'frame': a('Dictionary', 'public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){', 'The beam-drill frame (BeamDrill.drawPlanRegion, BeamDrill.java:113): carries no live keys for this placement UI -- the plan coordinates and rotation are passed explicitly, not as frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'plan_drawx': a('float', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The plan draw x (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): the placement-plan draw position x, from `plan.drawx()`.'),
        'plan_drawy': a('float', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The plan draw y (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): the placement-plan draw position y, from `plan.drawy()`.'),
        'plan_rotation': a('int', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The plan rotation 0-3 (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): the placement-plan rotation in quarter turns, so the top region draws at plan_rotation * 90 degrees.'),
        'top_region': a('Variant', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The top region (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): `public @Load("@-top") TextureRegion topRegion;` (BeamDrill.java:36), the top half of the icons() pair (`return new TextureRegion[]{region, topRegion};`, BeamDrill.java:108); the plain region rect is N1411, not this slice.'),
        'draw_rect': a('Callable', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The Draw.rect delegate (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): Draw is NOT ported, so the rect draw arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call(top_region, plan_drawx, plan_drawy, plan_rotation * 90)); an invalid callable is reported via draw_rect_called false.'),
    }
    draw_plan_region_outputs = {
        'draw_rect_called': a('bool', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'Whether the Draw.rect delegate was invoked (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): true when the draw_rect Callable is valid, false otherwise (the N2377 drawer_called precedent).'),
        'top_region_rotation': a('float', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The top-region draw rotation in degrees (BeamDrill.java:116, `plan.rotation * 90`): plan_rotation * 90, so rotation 0-3 draws at 0/90/180/270 degrees.'),
        'plan_position': a('Vector2', 'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', 'The plan draw position (BeamDrill.java:116, `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`): Vector2(plan_drawx, plan_drawy), the placement-plan draw position the top region is drawn at.'),
    }
    init_inputs = {
        'frame': a('Dictionary', 'public void init(){', 'The beam-drill frame (BeamDrill.init, BeamDrill.java:81): carries no live keys for this load-time setup -- range and tilesize are per-def values passed explicitly, not frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'range_value': a('int', 'public int range = 5;', 'The drill range in tiles (BeamDrill.java:40, `public int range = 5;`, class default; plasma-bore 5, large-plasma-bore 6, Blocks.java:3049-3065): the clip radius is `(range + 2) * tilesize` (BeamDrill.java:82).'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The tile size in world units (Vars.java:135, `public static final int tilesize = 8;`): the clip radius is `(range + 2) * tilesize` (BeamDrill.java:82).', source=VARS),
        'update_clip_radius': a('Callable', 'updateClipRadius((range + 2) * tilesize);', 'The updateClipRadius delegate (BeamDrill.java:82, `updateClipRadius((range + 2) * tilesize);`): the Block callee (`public void updateClipRadius(float radiusInWorldUnits){`, Block.java:1006, with `clipSize = Math.max(clipSize, this.size * tilesize + radiusInWorldUnits * 2f);`, Block.java:1007) -- NOT re-ported here: it arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call(clip_radius)); an invalid callable is reported via update_clip_radius_called false.'),
    }
    init_outputs = {
        'clip_radius': a('float', 'updateClipRadius((range + 2) * tilesize);', 'The clip radius in world units (BeamDrill.java:82, `updateClipRadius((range + 2) * tilesize);`): (range_value + 2) * tilesize -- 56.0 for the plasma-bore defaults (range 5, tilesize 8), 64.0 for large-plasma-bore (range 6).'),
        'update_clip_radius_called': a('bool', 'updateClipRadius((range + 2) * tilesize);', 'Whether the updateClipRadius delegate was invoked (BeamDrill.java:82, `updateClipRadius((range + 2) * tilesize);`): true when the update_clip_radius Callable is valid, false otherwise (the N2377 drawer_called precedent).'),
    }
    return (draw_select_inputs, draw_select_outputs), (draw_plan_region_inputs, draw_plan_region_outputs), (init_inputs, init_outputs)


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
        for pair in keys:
            total += len(pair)
            for field, meta in pair.items():
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
    (draw_select_inputs, draw_select_outputs), (draw_plan_region_inputs, draw_plan_region_outputs), (init_inputs, init_outputs) = definitions()

    entries = [
        ('N2394', DRAW_SELECT_OWNER, 'source_beam_drill_draw_select_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.drawSelect()', draw_select_inputs, draw_select_outputs, True, 'Dictionary'),
        ('N2394', DRAW_PLAN_REGION_OWNER, 'source_beam_drill_draw_plan_region_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list)', draw_plan_region_inputs, draw_plan_region_outputs, True, 'Dictionary'),
        ('N2394', INIT_OWNER, 'source_beam_drill_init_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.init()', init_inputs, init_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill drawSelect() / drawPlanRegion() / init() state from BeamDrill.java + Block.java + BuildingComp.java + Vars.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill drawSelect() / drawPlanRegion() / init() state from BeamDrill.java + Block.java + BuildingComp.java + Vars.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: draw_item_selection_called,
    # last_item, draw_rect_called, top_region_rotation,
    # plan_position, clip_radius, update_clip_radius_called.
    by_slice['N2394'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2394', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.drawSelect()/BeamDrill.drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list)/BeamDrill.init()', godot_owner=DRAW_SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2394'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
