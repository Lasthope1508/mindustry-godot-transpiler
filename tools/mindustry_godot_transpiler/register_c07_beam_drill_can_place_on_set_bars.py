"""Register the BeamDrill canPlaceOn() + setBars() slice (N2391).

BeamDrill.canPlaceOn() (BeamDrill.java:198-214, `public
boolean canPlaceOn(Tile tile, Team team, int rotation){`)
is the BeamDrill placement predicate (`public class
BeamDrill extends Block{`, BeamDrill.java:25): one scan
ray per footprint side (`nearbySide(tile.x, tile.y,
rotation, i, Tmp.p1);` (:200) with `for(int j = 0; j <
range; j++){` (:201) and `Tile other = world.tile(
Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y +
Geometry.d4y(rotation)*j);` (:202)), true on the first
mineable wall drop (`if(drop != null && drop.hardness
<= tier && (blockedItems == null ||
!blockedItems.contains(drop))){` with `return true;`,
:204-206), false otherwise (`return false;`, :212);
the first solid tile stops its ray whether or not its
drop is mineable (`if(other != null &&
other.solid()){` (:203) with `break;` (:208), the
break sitting inside the solid check). The solid check
is N2385 (BeamDrillBuild.drawPlace) -- NOT this slice:
the caller-side scan reuses the same tile Dictionary
shape; the size loop, wallDrop call and hardness check
are N2379 (BeamDrillBuild.updateFacing) -- NOT this
slice. nearbySide() is Block.nearbySide()
(Block.java:936-947, `public void nearbySide(int x,
int y, int rotation, int index, Point2 out){`) -- the
N1762 callee (PortGame.source_block_nearby_side_state),
reached through its static geometry form (the N2379
updateLasers precedent), NOT re-ported. `other.solid()`
is Tile.java:457; `other.wallDrop()` is Tile.java:575.

BeamDrill.setBars() (BeamDrill.java:90-97, `public void
setBars(){`) is the BeamDrill bar spec:
`super.setBars();` (:91) is Block.setBars()
(Block.java:696-746, the health bar `addBar("health",
entity -> new Bar("stat.health", Pal.health,
entity::healthf).blink(Color.white));` plus power /
items / liquid bars) -- NOT this slice: the caller
passes the already-built super bars. Then
`addBar("drillspeed", (BeamDrillBuild e) ->` (:93)
with `new Bar(() -> Core.bundle.format(
"bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60,
2)), () -> Pal.ammo, () -> e.warmup));` (:94) adds
the drillspeed bar. The bundle value is
`bar.drillspeed = Drill Speed: {0}/s`
(bundle.properties:1279); the fixed text is
Strings.fixed truncation at 2 decimals (arc
Strings.java:729-760, `dec.append((int)(float)(d *
Math.pow(10, decimalPlaces) + 0.0001f));` with `int
decimalPosition = len - decimalPlaces;`). The BeamDrill
rate has NO timeScale factor (unlike Drill.setBars
N2330): BeamDrill folds timeScale into lastDrillSpeed
itself (`lastDrillSpeed = (facingAmount * multiplier *
timeScale) / drillTime * efficiency;`,
BeamDrill.java:249). Pal.ammo is `ammo =
Color.valueOf("ff8947"),` (Pal.java:64). The Bar
constructor is `public Bar(Prov<CharSequence> name,
Prov<Color> color, Floatp fraction){` with `lastValue
= value = Mathf.clamp(fraction.get());`
(Bar.java:31-33). `lastDrillSpeed` is the BeamDrillBuild
field (`public float lastDrillSpeed;`,
BeamDrill.java:227); `warmup` is the BeamDrillBuild
field (`public float warmup, boostWarmup;`,
BeamDrill.java:226). This slice ports only the new bar
spec (key, text, color, fraction) as a pure function
and does NOT touch real Bar/UI playback. Five new
result symbols: can_place_on, bar_key, bar_text,
bar_color, bar_fraction. Slice sources: BeamDrill.java
+ Block.java + Pal.java + Bar.java + arc Strings.java.
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
PAL = 'core/src/mindustry/graphics/Pal.java'
BAR = 'core/src/mindustry/ui/Bar.java'
STRINGS = 'arc-core/src/arc/util/Strings.java'
PROOF = '/root/C07BeamDrillCanPlaceOnSetBarsProof'
CAN_PLACE_ON_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_can_place_on_state'
SET_BARS_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_set_bars_state'
TESTS = ['test_c07_beam_drill_can_place_on_set_bars_registration', 'test_all_c07_beam_drill_can_place_on_set_bars_input_evidence_is_exact', 'test_beam_drill_can_place_on_set_bars_state', 'test_reference_graph_and_actual_c07_beam_drill_can_place_on_set_bars']
# The 5 slice sources the N2391 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/graphics/Pal.java',
    'core/src/mindustry/ui/Bar.java',
    'arc-core/src/arc/util/Strings.java',
]
EXACT_EXPRS = [
    'nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);',
    'for(int j = 0; j < range; j++){',
    'Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);',
    'addBar("drillspeed", (BeamDrillBuild e) ->',
    'new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60, 2)), () -> Pal.ammo, () -> e.warmup));',
]

# DEFERRED is carried from the N2382 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (canPlaceOn touches no draw tick, updateTile advance,
# shouldConsume gate, liquid row, drillMultipliers row, or
# facing binding; setBars touches no Bar UI playback), so all
# are carried verbatim. Three entries are added: N2391's
# Windows proof debt, the concrete-scan boundary, and the
# concrete-Bar boundary.
DEFERRED = list(N2382_DEFERRED) + [
    'BeamDrill canPlaceOn() + setBars() Windows Godot proof -- debt in GOAL.md section 5, same as N2155: the N2391 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BeamDrill canPlaceOn() concrete world scan (world.tile / nearbySide with live Tiles) stays owned by Godot world integration; this helper preserves the placement predicate over a caller-supplied world_tile Callable and the static nearbySide geometry form.',
    'BeamDrill setBars() concrete Bar UI wiring (addBar barMap + Bar blink/update lambdas) stays owned by Godot UI integration; this helper preserves the bar spec (key, text, color, fraction).',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    nearby_expr = 'nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);'
    can_place_on_inputs = {
        'frame': a('Dictionary', 'public boolean canPlaceOn(Tile tile, Team team, int rotation){', 'The beam-drill frame (BeamDrill.canPlaceOn, BeamDrill.java:198): carries no live keys for this block-level placement predicate -- size, tier, blockedItems are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'tile_x': a('int', nearby_expr, 'The placement tile x (BeamDrill.java:200, `nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);`): the scan starts at the footprint side of (tile_x, tile_y).'),
        'tile_y': a('int', nearby_expr, 'The placement tile y (BeamDrill.java:200, `nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);`): the scan starts at the footprint side of (tile_x, tile_y).'),
        'rotation': a('int', nearby_expr, 'The placement rotation 0-3 (BeamDrill.java:200, `nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);`): it picks the faced side per footprint index and the d4 scan direction (Geometry.d4x/d4y).'),
        'size': a('int', 'for(int i = 0; i < size; i++){', 'The block size (BeamDrill.java:199, `for(int i = 0; i < size; i++){`): the scan runs one ray per footprint side (plasma-bore 2, large-plasma-bore 3, Blocks.java:3049-3065); passed explicitly (the N2212 per-def-param precedent).'),
        'range_value': a('int', 'public int range = 5;', 'The scan range in tiles (BeamDrill.java:40, `public int range = 5;`, class default; plasma-bore 5, large-plasma-bore 6, Blocks.java:3049-3065): the inner scan runs `for(int j = 0; j < range; j++)` (BeamDrill.java:201).'),
        'tier': a('int', 'public int tier = 1;', 'The drill tier (BeamDrill.java:41, `public int tier = 1;`, class default; plasma-bore 3, large-plasma-bore 5, Blocks.java:3049-3065): a drop counts only when `drop.hardness <= tier` (BeamDrill.java:205).'),
        'blocked_items': a('Variant', 'public @Nullable Seq<Item> blockedItems;', 'The blocked items (BeamDrill.java:51, `public @Nullable Seq<Item> blockedItems;`, null or an Array of item names): a drop counts only when it is not blocked (BeamDrill.java:205, `blockedItems == null || !blockedItems.contains(drop)`).'),
        'world_tile': a('Callable', 'Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);', 'The world tile lookup (BeamDrill.java:202, `Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);`): world_tile.call(rx, ry) returns null or a tile Dictionary {"solid", "wall_drop", "wall_drop_hardness"} (the N2379 param precedent -- the live world is not a frame key).'),
    }
    can_place_on_outputs = {
        'can_place_on': a('bool', 'public boolean canPlaceOn(Tile tile, Team team, int rotation){', 'Whether the drill can be placed: true on the first mineable wall drop found on any side ray (`if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){` with `return true;`, BeamDrill.java:205-206), false when no side finds one (`return false;`, BeamDrill.java:212); a null or non-solid tile does NOT stop a ray, the first solid tile stops it whether or not its drop is mineable.'),
    }
    set_bars_inputs = {
        'frame': a('Dictionary', 'public void setBars(){', 'The beam-drill frame (BeamDrill.setBars, BeamDrill.java:90): carries no live keys for this block-level bar spec -- lastDrillSpeed and warmup are live build state passed explicitly, not frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'super_set_bars': a('Variant', 'super.setBars();', 'The already-built Block.setBars() bars (BeamDrill.java:91, `super.setBars();`): the health bar `addBar("health", entity -> new Bar("stat.health", Pal.health, entity::healthf).blink(Color.white));` plus power / items / liquid bars (Block.java:696-746) -- NOT this slice: the caller passes the already-built super bars (the N2317/N2323 super-as-param precedent); this slice only adds the drillspeed bar spec.'),
        'last_drill_speed': a('float', 'public float lastDrillSpeed;', 'The last drill speed: the BeamDrillBuild field (`public float lastDrillSpeed;`, BeamDrill.java:227), set by updateTile (`lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`, BeamDrill.java:249); the bar text rate is `lastDrillSpeed * 60` (BeamDrill.java:94, `Strings.fixed(e.lastDrillSpeed * 60, 2)`, with NO timeScale factor -- BeamDrill folds timeScale into lastDrillSpeed itself); passed explicitly because it is live build state, not a frame key.'),
        'warmup': a('float', 'public float warmup, boostWarmup;', 'The drill warmup: the BeamDrillBuild field (`public float warmup, boostWarmup;`, BeamDrill.java:226), approached in updateTile (N2379); the bar fraction is `() -> e.warmup` (BeamDrill.java:94), clamped to 0..1 by the Bar constructor (`lastValue = value = Mathf.clamp(fraction.get());`, Bar.java:33); passed explicitly because it is live build state, not a frame key.'),
    }
    set_bars_outputs = {
        'bar_key': a('String', 'addBar("drillspeed", (BeamDrillBuild e) ->', 'The bar key: "drillspeed" (BeamDrill.java:93, `addBar("drillspeed", (BeamDrillBuild e) ->`); registered by `public <T extends Building> void addBar(String name, Func<T, Bar> sup){` (Block.java:667).'),
        'bar_text': a('String', 'new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60, 2)), () -> Pal.ammo, () -> e.warmup));', 'The bar text: Core.bundle.format("bar.drillspeed", fixed) over the bundle value `bar.drillspeed = Drill Speed: {0}/s` (bundle.properties:1279), with fixed = Strings.fixed(lastDrillSpeed * 60, 2) -- fixedBuilder truncation at 2 decimals (arc Strings.java:729-760, `dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));`); lastDrillSpeed is non-negative so the negative branch never fires.'),
        'bar_color': a('Variant', 'ammo = Color.valueOf("ff8947"),', 'The bar color: Pal.ammo (BeamDrill.java:94, `() -> Pal.ammo`), `ammo = Color.valueOf("ff8947"),` (Pal.java:64, "ff8947"); passed as the Bar color provider (`public Bar(Prov<CharSequence> name, Prov<Color> color, Floatp fraction){`, Bar.java:31).', source=PAL),
        'bar_fraction': a('float', 'lastValue = value = Mathf.clamp(fraction.get());', 'The bar fraction: warmup (BeamDrill.java:94, `() -> e.warmup`), clamped to 0..1 by the Bar constructor (`lastValue = value = Mathf.clamp(fraction.get());`, Bar.java:33); this slice returns the warmup value, the clamp is Bar-side.', source=BAR),
    }
    return (can_place_on_inputs, can_place_on_outputs), (set_bars_inputs, set_bars_outputs)


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                text = (upstream_root / source).read_text(encoding='utf-8')
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
    (can_place_on_inputs, can_place_on_outputs), (set_bars_inputs, set_bars_outputs) = definitions()

    entries = [
        ('N2391', CAN_PLACE_ON_OWNER, 'source_beam_drill_can_place_on_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.canPlaceOn(Tile tile, Team team, int rotation)', can_place_on_inputs, can_place_on_outputs, True, 'Dictionary'),
        ('N2391', SET_BARS_OWNER, 'source_beam_drill_set_bars_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.setBars()', set_bars_inputs, set_bars_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill canPlaceOn() / setBars() state from BeamDrill.java + Block.java + Pal.java + Bar.java + arc Strings.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill canPlaceOn() / setBars() state from BeamDrill.java + Block.java + Pal.java + Bar.java + arc Strings.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_place_on, bar_key,
    # bar_text, bar_color, bar_fraction.
    by_slice['N2391'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2391', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrill.canPlaceOn(Tile tile, Team team, int rotation)/BeamDrill.setBars()', godot_owner=CAN_PLACE_ON_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2391'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
