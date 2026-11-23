"""Register the Drill canPlaceOn() + setBars() + drawPlanConfig() slice (N2330).

Drill.canPlaceOn() (Drill.java:126-137, `public boolean
canPlaceOn(Tile tile, Team team, int rotation){`) is the
Drill placement predicate (`public class Drill extends
Block{`, Drill.java:27): `if(isMultiblock()){` (:127)
with `for(Tile other : tile.getLinkedTilesAs(this,
tempTiles)){` (:128) and `if(canMine(other)){` (:129)
then `return true;` (:130), else `return false;`
(:133); the single-tile leg is `return canMine(tile);`
(:135). isMultiblock() is Block.isMultiblock()
(Block.java:1014-1016, `public boolean
isMultiblock(){` with `return size > 1;`); all four
Drill defs are multiblock (mechanical/pneumatic-drill
`size = 2;`, laser-drill `size = 3;`, blast-drill
`size = 4;`, Blocks.java:2865-2915), so the multiblock
leg is the live one and the single-tile leg is kept
for the Java shape. canMine() is N2010
(SourceDrillRuntimeState.source_can_mine_state) --
NOT this slice: the caller passes the already-computed
canMine result per tile (the N2317/N2323 super-as-param
precedent).

Drill.setBars() (Drill.java:114-121, `public void
setBars(){`) is the Drill bar spec: `super.setBars();`
(:115) is Block.setBars() (Block.java:696-746, the
health bar `addBar("health", entity -> new Bar(
"stat.health", Pal.health, entity::healthf).blink(
Color.white));` plus power / items / liquid bars) --
NOT this slice: the caller passes the already-built
super bars. Then `addBar("drillspeed", (DrillBuild e)
->` (:117) with `new Bar(() -> Core.bundle.format(
"bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60
* e.timeScale(), 2)), () -> Pal.ammo, () -> e.warmup)
);` (:118) adds the drillspeed bar. The bundle value
is `bar.drillspeed = Drill Speed: {0}/s`
(bundle.properties:1279); the fixed text is
Strings.fixedBuilder truncation at 2 decimals (arc
Strings.java:729-760, `dec.append((int)(float)(d *
Math.pow(10, decimalPlaces) + 0.0001f));` with
`int decimalPosition = len - decimalPlaces;`).
Pal.ammo is `ammo = Color.valueOf("ff8947"),`
(Pal.java:64). The Bar constructor is `public Bar(Prov
<CharSequence> name, Prov<Color> color, Floatp
fraction){` with `lastValue = value = Mathf.clamp(
fraction.get());` (Bar.java:31-33). `lastDrillSpeed`
is the DrillBuild field (`public float
lastDrillSpeed;`, Drill.java:241); `timeScale()` is
BuildingComp.timeScale() (BuildingComp.java:599-601,
`public float timeScale(){` with `return timeScale;`,
field `private transient float timeScale = 1f,
timeScaleDuration;`, BuildingComp.java:98);
`warmup` is the DrillBuild field (`public float
warmup;`, Drill.java:239). This slice ports only the
new bar spec (key, text, color, fraction) as a pure
function and does NOT touch real Bar/UI playback.

Drill.drawPlanConfig() (Drill.java:100-111, `public
void drawPlanConfig(BuildPlan plan, Eachable<BuildPlan>
list){`) is the Drill plan-config render state:
`if(!plan.worldContext) return;` (:101),
`Tile tile = plan.tile();` (:102), `if(tile == null)
return;` (:103), `countOre(tile);` (:105),
`if(returnItem == null || !drawMineItem) return;`
(:106), `Draw.tint(returnItem.color);` (:108),
`Draw.rect(itemRegion, plan.drawx(), plan.drawy());`
(:109), `Draw.color();` (:110). `worldContext` is
the BuildPlan flag (`public boolean worldContext =
true;`, BuildPlan.java:30); `plan.tile()` is
`public @Nullable Tile tile(){` with `return
world.tile(x, y);` (BuildPlan.java:161-163);
`plan.drawx()` / `plan.drawy()` are `public float
drawx(){` with `return x*tilesize + (block == null ?
0 : block.offset);` (BuildPlan.java:142-144) and the
y twin. countOre() is N2010
(SourceDrillRuntimeState.source_count_ore_state) --
NOT this slice: the caller passes the already-computed
returnItem (`returnItem = itemArray.peek();`,
Drill.java:227). `returnItem` is `protected @Nullable
Item returnItem;` (Drill.java:47); `drawMineItem` is
`public boolean drawMineItem = true;` (Drill.java:51);
`itemRegion` is `public @Load(value = "@-item",
fallback = "drill-item-@size") TextureRegion
itemRegion;` (Drill.java:74); the tint color is
`public Color color;` (Item.java:19). This slice
ports only the tint + rect state as a pure function
and does NOT touch real Draw playback. Eight new
result symbols: can_place_on, bar_key, bar_text,
bar_color, bar_fraction, visible, tint_color,
item_rect. Slice sources: Drill.java + Block.java +
BuildingComp.java + BuildPlan.java + Item.java +
Pal.java + Bar.java + arc Strings.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BUILD_PLAN = 'core/src/mindustry/entities/units/BuildPlan.java'
ITEM = 'core/src/mindustry/type/Item.java'
PAL = 'core/src/mindustry/graphics/Pal.java'
BAR = 'core/src/mindustry/ui/Bar.java'
STRINGS = 'arc-core/src/arc/util/Strings.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07DrillCanPlaceOnSetBarsDrawPlanConfigProof'
CAN_PLACE_ON_OWNER = 'SourceBurstDrillBuildState.source_drill_can_place_on_state'
SET_BARS_OWNER = 'SourceBurstDrillBuildState.source_drill_set_bars_state'
DRAW_PLAN_CONFIG_OWNER = 'SourceBurstDrillBuildState.source_drill_draw_plan_config_state'
TESTS = ['test_c07_drill_can_place_on_set_bars_draw_plan_config_registration', 'test_all_c07_drill_can_place_on_set_bars_draw_plan_config_input_evidence_is_exact', 'test_drill_can_place_on_set_bars_draw_plan_config_state', 'test_reference_graph_and_actual_c07_drill_can_place_on_set_bars_draw_plan_config']
# The 9 slice sources the N2330 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/units/BuildPlan.java',
    'core/src/mindustry/type/Item.java',
    'core/src/mindustry/graphics/Pal.java',
    'core/src/mindustry/ui/Bar.java',
    'arc-core/src/arc/util/Strings.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public class Drill extends Block{', 'public class DrillBuild extends Building{', 'public void drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list){', 'if(!plan.worldContext) return;', 'Tile tile = plan.tile();', 'if(tile == null) return;', 'countOre(tile);', 'if(returnItem == null || !drawMineItem) return;', 'Draw.tint(returnItem.color);', 'Draw.rect(itemRegion, plan.drawx(), plan.drawy());', 'Draw.color();', 'public void setBars(){', 'super.setBars();', 'addBar("drillspeed", (DrillBuild e) ->', 'new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60 * e.timeScale(), 2)), () -> Pal.ammo, () -> e.warmup));', 'public boolean canPlaceOn(Tile tile, Team team, int rotation){', 'if(isMultiblock()){', 'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){', 'if(canMine(other)){', 'return true;', 'return false;', 'return canMine(tile);', 'protected @Nullable Item returnItem;', 'public boolean drawMineItem = true;', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'public float lastDrillSpeed;', 'public float warmup;', 'protected void countOre(Tile tile){', 'returnItem = itemArray.peek();', 'public boolean canMine(Tile tile){', 'public boolean isMultiblock(){', 'return size > 1;', 'public int size = 1;', 'addBar("health", entity -> new Bar("stat.health", Pal.health, entity::healthf).blink(Color.white));', 'public <T extends Building> void addBar(String name, Func<T, Bar> sup){', 'public boolean worldContext = true;', 'public float drawx(){', 'return x*tilesize + (block == null ? 0 : block.offset);', 'public float drawy(){', 'public @Nullable Tile tile(){', 'return world.tile(x, y);', 'public float timeScale(){', 'return timeScale;', 'private transient float timeScale = 1f, timeScaleDuration;', 'public Color color;', 'ammo = Color.valueOf("ff8947"),', 'public Bar(Prov<CharSequence> name, Prov<Color> color, Floatp fraction){', 'lastValue = value = Mathf.clamp(fraction.get());', 'public static String fixed(float d, int decimalPlaces){', 'return fixedBuilder(d, decimalPlaces).toString();', 'public static StringBuilder fixedBuilder(float d, int decimalPlaces){', 'boolean negative = d < 0;', 'd = Math.abs(d);', 'dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));', 'int decimalPosition = len - decimalPlaces;', 'size = 2;', 'size = 3;', 'size = 4;']

DEFERRED = [
    'Drill canPlaceOn() / setBars() / drawPlanConfig() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227/N2314: the N2330 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Drill setBars() concrete Bar UI wiring (addBar barMap + Bar blink/update lambdas) stays owned by Godot UI integration; this helper preserves the bar spec (key, text, color, fraction).',
    'Drill drawPlanConfig() concrete Draw playback (Draw.tint / Draw.rect with live TextureRegions) stays owned by Godot rendering integration; this helper preserves the tint + rect state.',
    'Drill canPlaceOn() Tile.getLinkedTilesAs linked-tile enumeration is caller input (canMine per tile from N2010); the Tile linked-tile table itself is not this slice.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    can_place_on_inputs = {
        'frame': a('Dictionary', 'public boolean canPlaceOn(Tile tile, Team team, int rotation){', 'The drill frame (Drill.canPlaceOn, Drill.java:126): carries no live keys for this block-level placement predicate -- size, tier, blockedItems are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'is_multiblock': a('bool', 'return size > 1;', 'Whether the drill is multiblock: Block.isMultiblock() (Block.java:1014-1016, `public boolean isMultiblock(){` with `return size > 1;`); per-def sizes: mechanical/pneumatic-drill `size = 2;`, laser-drill `size = 3;`, blast-drill `size = 4;` (Blocks.java:2865-2915), so every Drill def is multiblock; passed explicitly because it is per-def static state.', source=BLOCK),
        'linked_tiles_can_mine': a('Array', 'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){', 'The canMine() result per linked tile, in `tile.getLinkedTilesAs(this, tempTiles)` order (Drill.java:128, `for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){`): canMine() itself is N2010 (SourceDrillRuntimeState.source_can_mine_state) -- NOT this slice: the caller passes the already-computed results (the N2317/N2323 super-as-param precedent).'),
        'tile_can_mine': a('bool', 'return canMine(tile);', 'The canMine() result for the single tile (Drill.java:135, `return canMine(tile);`): canMine() itself is N2010 (SourceDrillRuntimeState.source_can_mine_state) -- NOT this slice: the caller passes the already-computed result.'),
    }
    can_place_on_outputs = {
        'can_place_on': a('bool', 'public boolean canPlaceOn(Tile tile, Team team, int rotation){', 'Whether the drill can be placed: true on the first minable linked tile for a multiblock drill (`if(canMine(other)){` with `return true;`, Drill.java:129-130), false when none mines (`return false;`, Drill.java:133); a single-tile drill returns canMine(tile) directly (Drill.java:135).'),
    }
    set_bars_inputs = {
        'frame': a('Dictionary', 'public void setBars(){', 'The drill frame (Drill.setBars, Drill.java:114): carries no live keys for this block-level bar spec -- lastDrillSpeed, timeScale and warmup are live build state passed explicitly, not frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'super_set_bars': a('Variant', 'super.setBars();', 'The already-built Block.setBars() bars (Drill.java:115, `super.setBars();`): the health bar `addBar("health", entity -> new Bar("stat.health", Pal.health, entity::healthf).blink(Color.white));` plus power / items / liquid bars (Block.java:696-746) -- NOT this slice: the caller passes the already-built super bars (the N2317/N2323 super-as-param precedent); this slice only adds the drillspeed bar spec.'),
        'last_drill_speed': a('float', 'public float lastDrillSpeed;', 'The last drill speed: the DrillBuild field (`public float lastDrillSpeed;`, Drill.java:241), set by the updateTile speed fold (N2294); the bar text rate is `lastDrillSpeed * 60 * timeScale` (Drill.java:118, `Strings.fixed(e.lastDrillSpeed * 60 * e.timeScale(), 2)`); passed explicitly because it is live build state, not a frame key.'),
        'time_scale': a('float', 'public float timeScale(){', 'The building time scale: BuildingComp.timeScale() (BuildingComp.java:599-601, `public float timeScale(){` with `return timeScale;`, field `private transient float timeScale = 1f, timeScaleDuration;`, BuildingComp.java:98); the bar text rate is `lastDrillSpeed * 60 * timeScale` (Drill.java:118); passed explicitly because it is live build state, not a frame key.', source=BUILDING_COMP),
        'warmup': a('float', 'public float warmup;', 'The drill warmup: the DrillBuild field (`public float warmup;`, Drill.java:239), approached in updateTile (N2294); the bar fraction is `() -> e.warmup` (Drill.java:118), clamped to 0..1 by the Bar constructor (`lastValue = value = Mathf.clamp(fraction.get());`, Bar.java:33); passed explicitly because it is live build state, not a frame key.'),
    }
    set_bars_outputs = {
        'bar_key': a('String', 'addBar("drillspeed", (DrillBuild e) ->', 'The bar key: "drillspeed" (Drill.java:117, `addBar("drillspeed", (DrillBuild e) ->`); registered by `public <T extends Building> void addBar(String name, Func<T, Bar> sup){` (Block.java:667).'),
        'bar_text': a('String', 'new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60 * e.timeScale(), 2)), () -> Pal.ammo, () -> e.warmup));', 'The bar text: Core.bundle.format("bar.drillspeed", fixed) over the bundle value `bar.drillspeed = Drill Speed: {0}/s` (bundle.properties:1279), with fixed = Strings.fixed(lastDrillSpeed * 60 * timeScale, 2) -- fixedBuilder truncation at 2 decimals (arc Strings.java:729-760, `dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));`); lastDrillSpeed and timeScale are non-negative so the negative branch never fires.'),
        'bar_color': a('Variant', 'ammo = Color.valueOf("ff8947"),', 'The bar color: Pal.ammo (Drill.java:118, `() -> Pal.ammo`), `ammo = Color.valueOf("ff8947"),` (Pal.java:64, "ff8947"); passed as the Bar color provider (`public Bar(Prov<CharSequence> name, Prov<Color> color, Floatp fraction){`, Bar.java:31).', source=PAL),
        'bar_fraction': a('float', 'lastValue = value = Mathf.clamp(fraction.get());', 'The bar fraction: warmup (Drill.java:118, `() -> e.warmup`), clamped to 0..1 by the Bar constructor (`lastValue = value = Mathf.clamp(fraction.get());`, Bar.java:33); this slice returns the warmup value, the clamp is Bar-side.', source=BAR),
    }
    draw_plan_config_inputs = {
        'frame': a('Dictionary', 'public void drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list){', 'The drill frame (Drill.drawPlanConfig, Drill.java:100): carries no live keys for this block-level plan render state -- worldContext, the plan tile, returnItem and drawMineItem are passed explicitly, not frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'world_context': a('bool', 'public boolean worldContext = true;', 'Whether the plan is in world context: the BuildPlan flag (`public boolean worldContext = true;`, BuildPlan.java:30, default true); the first guard is `if(!plan.worldContext) return;` (Drill.java:101); passed explicitly because it is plan state, not a frame key.', source=BUILD_PLAN),
        'has_tile': a('bool', 'public @Nullable Tile tile(){', 'Whether the plan has a tile: `plan.tile()` (`public @Nullable Tile tile(){` with `return world.tile(x, y);`, BuildPlan.java:161-163) is non-null; the guard is `if(tile == null) return;` (Drill.java:103); passed explicitly because it is plan state, not a frame key.', source=BUILD_PLAN),
        'return_item': a('Variant', 'returnItem = itemArray.peek();', 'The counted ore item: countOre() sets `returnItem = itemArray.peek();` (Drill.java:227) -- countOre() itself is N2010 (SourceDrillRuntimeState.source_count_ore_state), NOT this slice: the caller passes the already-computed returnItem (null when no ore); the guard is `if(returnItem == null || !drawMineItem) return;` (Drill.java:106).'),
        'return_item_color': a('Variant', 'public Color color;', 'The return item color: `public Color color;` (Item.java:19); the tint is `Draw.tint(returnItem.color);` (Drill.java:108); passed explicitly with the return item.', source=ITEM),
        'draw_mine_item': a('bool', 'public boolean drawMineItem = true;', 'The block flag for drawing the mined item (Drill.java:51, `public boolean drawMineItem = true;`, default true); the guard is `if(returnItem == null || !drawMineItem) return;` (Drill.java:106); passed explicitly because it is per-def static state.'),
        'item_region': a('Variant', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'The Drill item region (Drill.java:74, `public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;`); the rect is `Draw.rect(itemRegion, plan.drawx(), plan.drawy());` (Drill.java:109); passed explicitly because it is per-def static state, not a live frame key.'),
        'draw_x': a('float', 'public float drawx(){', 'The plan draw x: `plan.drawx()` (`public float drawx(){` with `return x*tilesize + (block == null ? 0 : block.offset);`, BuildPlan.java:142-144); passed explicitly because it is plan state, not a frame key.', source=BUILD_PLAN),
        'draw_y': a('float', 'public float drawy(){', 'The plan draw y: `plan.drawy()` (`public float drawy(){`, BuildPlan.java:146-148, the y twin of drawx); passed explicitly because it is plan state, not a frame key.', source=BUILD_PLAN),
    }
    draw_plan_config_outputs = {
        'visible': a('bool', 'if(returnItem == null || !drawMineItem) return;', 'Whether the plan-config item is drawn: true exactly when worldContext and the plan has a tile and countOre found an item and drawMineItem (Drill.java:101-106, `if(!plan.worldContext) return;`, `if(tile == null) return;`, `if(returnItem == null || !drawMineItem) return;`).'),
        'tint_color': a('Variant', 'Draw.tint(returnItem.color);', 'The tint color: returnItem.color when visible, else null (Drill.java:108, `Draw.tint(returnItem.color);`).'),
        'item_rect': a('Dictionary', 'Draw.rect(itemRegion, plan.drawx(), plan.drawy());', 'The item rect {region, x, y} when visible, else null (Drill.java:109, `Draw.rect(itemRegion, plan.drawx(), plan.drawy());`, reset by `Draw.color();`, Drill.java:110).'),
    }
    return (can_place_on_inputs, can_place_on_outputs), (set_bars_inputs, set_bars_outputs), (draw_plan_config_inputs, draw_plan_config_outputs)


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
    (can_place_on_inputs, can_place_on_outputs), (set_bars_inputs, set_bars_outputs), (draw_plan_config_inputs, draw_plan_config_outputs) = definitions()

    entries = [
        ('N2330', CAN_PLACE_ON_OWNER, 'source_drill_can_place_on_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.canPlaceOn(Tile tile, Team team, int rotation)', can_place_on_inputs, can_place_on_outputs, True, 'Dictionary'),
        ('N2330', SET_BARS_OWNER, 'source_drill_set_bars_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.setBars()', set_bars_inputs, set_bars_outputs, True, 'Dictionary'),
        ('N2330', DRAW_PLAN_CONFIG_OWNER, 'source_drill_draw_plan_config_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list)', draw_plan_config_inputs, draw_plan_config_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Drill canPlaceOn() / setBars() / drawPlanConfig() state from Drill.java + Block.java + BuildingComp.java + BuildPlan.java + Item.java + Pal.java + Bar.java + arc Strings.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Drill canPlaceOn() / setBars() / drawPlanConfig() state from Drill.java + Block.java + BuildingComp.java + BuildPlan.java + Item.java + Pal.java + Bar.java + arc Strings.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_place_on, bar_key,
    # bar_text, bar_color, bar_fraction, visible,
    # tint_color, item_rect.
    by_slice['N2330'] = [
        'source_drill_can_place_on_state_result.can_place_on',
        'source_drill_set_bars_state_result.bar_key',
        'source_drill_set_bars_state_result.bar_text',
        'source_drill_set_bars_state_result.bar_color',
        'source_drill_set_bars_state_result.bar_fraction',
        'source_drill_draw_plan_config_state_result.visible',
        'source_drill_draw_plan_config_state_result.tint_color',
        'source_drill_draw_plan_config_state_result.item_rect',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2330', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.canPlaceOn(Tile tile, Team team, int rotation)/Drill.setBars()/Drill.drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list)', godot_owner=CAN_PLACE_ON_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2330'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
