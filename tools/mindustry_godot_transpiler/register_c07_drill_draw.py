"""Register the DrillBuild draw() BASE slice (N2325).

DrillBuild.draw() (Drill.java:346-379, `public void
draw(){`) is the DrillBuild BASE (`public class Drill
extends Block{`, Drill.java:27, `public class DrillBuild
extends Building{`, Drill.java:237): `float s = 0.3f;`
(:347), `float ts = 0.6f;` (:348), `Draw.rect(region, x,
y);` (:350), `Draw.z(Layer.blockCracks);` (:351),
`drawDefaultCracks();` (:352), `Draw.z(Layer.
blockAfterCracks);` (:354), `if(drawRim){` (:355) with
`Draw.color(heatColor);` (:356), `Draw.alpha(warmup * ts
* (1f - s + Mathf.absin(Time.time, 3f, s)));` (:357),
`Draw.blend(Blending.additive);` (:358) and `Draw.rect(
rimRegion, x, y);` (:359), `if(drawSpinSprite){` (:364)
with `Drawf.spinSprite(rotatorRegion, x, y, timeDrilled
* rotateSpeed);` (:365), else `Draw.rect(rotatorRegion,
x, y, timeDrilled * rotateSpeed);` (:367), `Draw.rect(
topRegion, x, y);` (:370), `if(dominantItem != null &&
drawMineItem){` (:372) with `Draw.color(dominantItem.
color);` (:373) and `Draw.rect(itemRegion, x, y);`
(:374). drawCracks() (Drill.java:339, `public void
drawCracks(){}`) is an EMPTY override: the DrillBuild
never draws BuildingComp cracks directly. drawDefaultCracks()
(Drill.java:341-343, `public void drawDefaultCracks(){`
with `super.drawCracks();`) invokes BuildingComp.
drawCracks() (BuildingComp.java:1231-1239): `if(!
block.drawCracks || !damaged() || block.size >
BlockRenderer.maxCrackSize) return;`, `int id = pos();`,
the crack region `renderer.blocks.cracks[block.size -
1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.
crackRegions), 0, BlockRenderer.crackRegions-1)]`,
`Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);`,
`Draw.rect(region, x, y, (id%4)*90);` -- THIS slice ports
that computation, so it supplies the already-computed
cracks dict the N2314 BurstDrillBuild.draw() OVERRIDE
takes as an explicit param. One pure function on the
family file (the N2341 drawSelect / N2314 draw
precedents): it returns the computed draw state (rects,
colors, alpha, z, blend, spin) and does NOT touch real
Draw/Drawf playback. Eleven new result symbols:
base_rect, cracks_z, cracks, after_cracks_z,
rim_visible, rim_alpha, rim_rect, rotator, top_rect,
mine_item_visible, mine_item_rect. Four Drill defs
(Blocks.java): mechanical-drill and pneumatic-drill
`size = 2;`, laser-drill `size = 3;`, blast-drill
`size = 4;` with `drawRim = true;` and `rotateSpeed =
6f;` (class default `rotateSpeed = 2f;`). Formulas:
Mathf.absin(t, 3, s) = (sin(t / 6) * s + s) / 2 (arc
Mathf.java:78-80, absin(in, scl, mag) = (sin(in, scl *
2, mag) + mag) / 2 with sin(radians, scl, mag) =
sin(radians / scl) * mag); Drawf.spinSprite
(Drawf.java:602-609) takes r = Mathf.mod(r, 90f)
(((r % 90) + 90) % 90, arc Mathf.java:574-576), draws
rect(r) at the current alpha, then rect(r - 90) at
alpha r / 90 * a; Draw.colorl(l, a) draws gray (l, l,
l) at alpha a (arc Draw.java:256-258); healthf() =
health / maxHealth and damaged() = health < maxHealth
- 0.001f (HealthComp.java:20-22, 47-49); Layer.
blockCracks = 30 + 0.1, Layer.blockAfterCracks = 30 +
0.2 (Layer.java:30,33); BlockRenderer.crackRegions = 8,
maxCrackSize = 7 (BlockRenderer.java:31). Slice sources:
Drill.java + BuildingComp.java + HealthComp.java +
Block.java + Blocks.java + Layer.java + Drawf.java +
BlockRenderer.java.
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
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
LAYER = 'core/src/mindustry/graphics/Layer.java'
DRAWF = 'core/src/mindustry/graphics/Drawf.java'
BLOCK_RENDERER = 'core/src/mindustry/graphics/BlockRenderer.java'
PROOF = '/root/C07DrillDrawProof'
DRAW_OWNER = 'SourceBurstDrillBuildState.source_drill_draw_state'
TESTS = ['test_c07_drill_draw_registration', 'test_all_c07_drill_draw_input_evidence_is_exact', 'test_drill_draw_state', 'test_reference_graph_and_actual_c07_drill_draw']
# The 8 slice sources the N2325 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/graphics/Layer.java',
    'core/src/mindustry/graphics/Drawf.java',
    'core/src/mindustry/graphics/BlockRenderer.java',
]
EXACT_EXPRS = ['public class Drill extends Block{', 'public class DrillBuild extends Building{', 'public float rotateSpeed = 2f;', 'public boolean drawRim = false;', 'public boolean drawSpinSprite = true;', 'public Color heatColor = Color.valueOf("ff5512");', 'public @Load("@-rim") TextureRegion rimRegion;', 'public @Load("@-rotator") TextureRegion rotatorRegion;', 'public @Load("@-top") TextureRegion topRegion;', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'public boolean drawMineItem = true;', 'public Item dominantItem;', 'public float warmup;', 'public float timeDrilled;', 'public void drawCracks(){}', 'public void drawDefaultCracks(){', 'super.drawCracks();', 'public void draw(){', 'float s = 0.3f;', 'float ts = 0.6f;', 'Draw.rect(region, x, y);', 'Draw.z(Layer.blockCracks);', 'drawDefaultCracks();', 'Draw.z(Layer.blockAfterCracks);', 'if(drawRim){', 'Draw.color(heatColor);', 'Draw.alpha(warmup * ts * (1f - s + Mathf.absin(Time.time, 3f, s)));', 'Draw.blend(Blending.additive);', 'Draw.rect(rimRegion, x, y);', 'Draw.blend();', 'Draw.color();', 'if(drawSpinSprite){', 'Drawf.spinSprite(rotatorRegion, x, y, timeDrilled * rotateSpeed);', 'Draw.rect(rotatorRegion, x, y, timeDrilled * rotateSpeed);', 'Draw.rect(topRegion, x, y);', 'if(dominantItem != null && drawMineItem){', 'Draw.color(dominantItem.color);', 'Draw.rect(itemRegion, x, y);', 'public void drawCracks(){', 'if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;', 'int id = pos();', 'TextureRegion region = renderer.blocks.cracks[block.size - 1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)];', 'Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);', 'Draw.rect(region, x, y, (id%4)*90);', 'float healthf(){', 'return health / maxHealth;', 'boolean damaged(){', 'return health < maxHealth - 0.001f;', 'public boolean drawCracks = true;', 'public TextureRegion region;', 'size = 2;', 'size = 3;', 'size = 4;', 'drawRim = true;', 'rotateSpeed = 6f;', 'blockCracks = 30f + 0.1f,', 'blockAfterCracks = 30f + 0.2f,', 'public static void spinSprite(TextureRegion region, float x, float y, float r){', 'float a = Draw.getColorAlpha();', 'r = Mathf.mod(r, 90f);', 'Draw.rect(region, x, y, r);', 'Draw.alpha(r / 90f*a);', 'Draw.rect(region, x, y, r - 90f);', 'Draw.alpha(a);', 'public static final int crackRegions = 8, maxCrackSize = 7, chunkSize = 30, maxSpritesPerCacheTile = 3;']

DEFERRED = [
    'DrillBuild draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227/N2314: the N2325 proof runs headless on Linux here and waits for a Windows Godot run.',
    'DrillBuild draw() concrete rect rendering (Draw.rect / Drawf.spinSprite with live TextureRegions) stays owned by Godot rendering integration; this helper preserves rects, colors, alpha, z, blend and spin state.',
    'DrillBuild draw() BlockRenderer.cracks region table (BlockRenderer.java:87-88, cracks[size][index]) is load-time renderer state -- the caller passes the size row as crack_regions; the table itself is not this slice.',
    'DrillBuild draw() caller wiring: passing source_drill_draw_state()["cracks"] into the N2314 source_burst_drill_draw_state(draw_default_cracks=...) param is a later render-integration slice, not this one; this slice only provides the pure function.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'x': a('float', 'Draw.rect(region, x, y);', 'The building world x (Drill.java:350, `Draw.rect(region, x, y);`); passed explicitly because draw() reads the live building position.'),
        'y': a('float', 'Draw.rect(region, x, y);', 'The building world y (Drill.java:350, `Draw.rect(region, x, y);`); passed explicitly because draw() reads the live building position.'),
        'region': a('Variant', 'public TextureRegion region;', 'The inherited block region (Block.java:427, `public TextureRegion region;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=BLOCK),
        'rim_region': a('Variant', 'public @Load("@-rim") TextureRegion rimRegion;', 'The Drill rim region (Drill.java:71, `public @Load("@-rim") TextureRegion rimRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'rotator_region': a('Variant', 'public @Load("@-rotator") TextureRegion rotatorRegion;', 'The Drill rotator region (Drill.java:72, `public @Load("@-rotator") TextureRegion rotatorRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'top_region': a('Variant', 'public @Load("@-top") TextureRegion topRegion;', 'The Drill top region (Drill.java:73, `public @Load("@-top") TextureRegion topRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'item_region': a('Variant', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'The Drill item region (Drill.java:74, `public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'block_draw_cracks': a('bool', 'public boolean drawCracks = true;', 'The block flag for drawing cracks (Block.java:208, `public boolean drawCracks = true;`, default true); the drawCracks guard is `if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;` (BuildingComp.java:1232); passed explicitly because it is per-def static state.', source=BLOCK),
        'damaged': a('bool', 'return health < maxHealth - 0.001f;', 'Whether the building is damaged: HealthComp.damaged() (HealthComp.java:47-49, `return health < maxHealth - 0.001f;`); the drawCracks guard is `if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;` (BuildingComp.java:1232); passed explicitly because health is live build state, not a frame key.', source=HEALTH_COMP),
        'block_size': a('int', 'if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;', 'The block size: the drawCracks guard rejects `block.size > BlockRenderer.maxCrackSize` (7) and indexes `renderer.blocks.cracks[block.size - 1][...]` (BuildingComp.java:1232-1234); per-def sizes: mechanical/pneumatic-drill `size = 2;`, laser-drill `size = 3;`, blast-drill `size = 4;` (Blocks.java); passed explicitly because it is per-def static state.', source=BUILDING_COMP),
        'healthf': a('float', 'return health / maxHealth;', 'The health fraction: HealthComp.healthf() (HealthComp.java:20-22, `return health / maxHealth;`); the crack index is `Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)` and the crack alpha is `0.1f + (1f - healthf())* 0.6f` (BuildingComp.java:1234-1235); passed explicitly because health is live build state, not a frame key.', source=HEALTH_COMP),
        'pos_id': a('int', 'int id = pos();', 'The tile position id: `int id = pos();` (BuildingComp.java:1233, `public int pos(){ return tile.pos(); }`, BuildingComp.java:578-580); the crack rect rotates `(id%4)*90` (BuildingComp.java:1237); passed explicitly because it is live tile state, not a frame key.', source=BUILDING_COMP),
        'crack_regions': a('Array', 'TextureRegion region = renderer.blocks.cracks[block.size - 1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)];', 'The crack region row for this block size: `renderer.blocks.cracks[block.size - 1]` (BuildingComp.java:1234), 8 entries (BlockRenderer.crackRegions = 8, BlockRenderer.java:31); the function indexes it by the clamped health index; passed explicitly because the region table is load-time renderer state, not a frame key.', source=BUILDING_COMP),
        'draw_rim': a('bool', 'public boolean drawRim = false;', 'The block flag for the heat rim (Drill.java:68, `public boolean drawRim = false;`, default false); blast-drill overrides `drawRim = true;` (Blocks.java:2903); the draw guard is `if(drawRim){` (Drill.java:355); passed explicitly because it is per-def static state.'),
        'heat_color': a('Variant', 'public Color heatColor = Color.valueOf("ff5512");', 'The rim heat color (Drill.java:70, `public Color heatColor = Color.valueOf("ff5512");`, "ff5512"); the rim draws `Draw.color(heatColor);` (Drill.java:356); passed explicitly because it is per-def static state.'),
        'warmup': a('float', 'public float warmup;', 'The drill warmup (Drill.java:239, `public float warmup;`), approached in updateTile (N2294); the rim alpha is `warmup * ts * (1f - s + Mathf.absin(Time.time, 3f, s))` (Drill.java:357); passed explicitly because it is live build state, not a frame key.'),
        'time_now': a('float', 'Draw.alpha(warmup * ts * (1f - s + Mathf.absin(Time.time, 3f, s)));', 'The current game time (Time.time in `Mathf.absin(Time.time, 3f, s)`, Drill.java:357); passed explicitly because draw() reads live time, not a frame key.'),
        'draw_spin_sprite': a('bool', 'public boolean drawSpinSprite = true;', 'The block flag for the spin-sprite rotator (Drill.java:69, `public boolean drawSpinSprite = true;`, default true); the draw branch is `if(drawSpinSprite){` (Drill.java:364); passed explicitly because it is per-def static state.'),
        'time_drilled': a('float', 'public float timeDrilled;', 'The accumulated drill time (Drill.java:240, `public float timeDrilled;`), accumulated in updateTile (N2294); the rotator angle is `timeDrilled * rotateSpeed` (Drill.java:365, :367); passed explicitly because it is live build state, not a frame key.'),
        'rotate_speed': a('float', 'public float rotateSpeed = 2f;', 'The rotator speed (Drill.java:59, `public float rotateSpeed = 2f;`, default 2f); blast-drill overrides `rotateSpeed = 6f;` (Blocks.java:2911); the rotator angle is `timeDrilled * rotateSpeed` (Drill.java:365, :367); passed explicitly because it is per-def static state.'),
        'draw_alpha': a('float', 'float a = Draw.getColorAlpha();', 'The current Draw color alpha entering the rotator: Drawf.spinSprite reads `float a = Draw.getColorAlpha();` (Drawf.java:603) and restores it with `Draw.alpha(a);` (:608); passed explicitly because it is live draw-batch state, not a frame key.', source=DRAWF),
        'has_dominant_item': a('bool', 'public Item dominantItem;', 'Whether the drill has a dominant item: dominantItem is `public Item dominantItem;` (Drill.java:244), set by the N2302 ore/dominant binding; the draw guard is `if(dominantItem != null && drawMineItem){` (Drill.java:372); passed explicitly because the binding is not this slice.'),
        'dominant_item_color': a('Variant', 'Draw.color(dominantItem.color);', 'The dominant item color (Drill.java:373, `Draw.color(dominantItem.color);`); passed explicitly with the dominant item.'),
        'draw_mine_item': a('bool', 'public boolean drawMineItem = true;', 'The block flag for drawing the mined item (Drill.java:51, `public boolean drawMineItem = true;`, default true); the draw guard is `if(dominantItem != null && drawMineItem){` (Drill.java:372); passed explicitly because it is per-def static state.'),
    }
    draw_outputs = {
        'base_rect': a('Dictionary', 'Draw.rect(region, x, y);', 'The base rect {region, x, y}, always drawn (Drill.java:350, `Draw.rect(region, x, y);`).'),
        'cracks_z': a('float', 'blockCracks = 30f + 0.1f,', 'The cracks layer: Layer.blockCracks = 30 + 0.1 = 30.1 (Layer.java:30, `blockCracks = 30f + 0.1f,`), set by `Draw.z(Layer.blockCracks);` (Drill.java:351).', source=LAYER),
        'cracks': a('Variant', 'Draw.rect(region, x, y, (id%4)*90);', 'The default-cracks rect {region, x, y, rotation_deg, color_lightness, color_alpha, crack_index, z} when the BuildingComp.drawCracks() guard passes (block.drawCracks and damaged and block.size <= 7), else null (BuildingComp.java:1231-1239). The region is crack_regions[clamp(int((1 - healthf) * 8), 0, 7)], the color is Draw.colorl(0.2, 0.1 + (1 - healthf) * 0.6), the rotation is (pos_id % 4) * 90.', source=BUILDING_COMP),
        'after_cracks_z': a('float', 'blockAfterCracks = 30f + 0.2f,', 'The after-cracks layer: Layer.blockAfterCracks = 30 + 0.2 = 30.2 (Layer.java:33, `blockAfterCracks = 30f + 0.2f,`), set by `Draw.z(Layer.blockAfterCracks);` (Drill.java:354) for the rim, rotator, top and mine-item rects.', source=LAYER),
        'rim_visible': a('bool', 'if(drawRim){', 'Whether the heat rim is drawn: true exactly when drawRim (Drill.java:355, `if(drawRim){`).'),
        'rim_alpha': a('float', 'Draw.alpha(warmup * ts * (1f - s + Mathf.absin(Time.time, 3f, s)));', 'The rim alpha: warmup * 0.6 * (1 - 0.3 + absin(time_now, 3, 0.3)) when visible, else 0.0, where absin(t, 3, 0.3) = (sin(t / 6) * 0.3 + 0.3) / 2 (Drill.java:357; arc Mathf.java:78-80).'),
        'rim_rect': a('Variant', 'Draw.rect(rimRegion, x, y);', 'The rim rect {region, x, y, color, alpha, blend, z} when visible, else null (Drill.java:359, `Draw.rect(rimRegion, x, y);`, additive blend, z 30.2).'),
        'rotator': a('Dictionary', 'Drawf.spinSprite(rotatorRegion, x, y, timeDrilled * rotateSpeed);', 'The rotator {spin, rotation_deg, rects}: when drawSpinSprite, Drawf.spinSprite (Drawf.java:602-609) with r = mod(rotation, 90) draws rect(r) at draw_alpha then rect(r - 90) at alpha r / 90 * draw_alpha; otherwise a single plain rect at the full rotation (Drill.java:367, `Draw.rect(rotatorRegion, x, y, timeDrilled * rotateSpeed);`).'),
        'top_rect': a('Dictionary', 'Draw.rect(topRegion, x, y);', 'The top rect {region, x, y}, always drawn (Drill.java:370, `Draw.rect(topRegion, x, y);`).'),
        'mine_item_visible': a('bool', 'if(dominantItem != null && drawMineItem){', 'Whether the mine-item overlay is drawn: true exactly when a dominant item is bound and drawMineItem (Drill.java:372, `if(dominantItem != null && drawMineItem){`).'),
        'mine_item_rect': a('Variant', 'Draw.rect(itemRegion, x, y);', 'The mine-item rect {region, x, y, color} when visible, else null (Drill.java:374, `Draw.rect(itemRegion, x, y);`).'),
    }
    return draw_inputs, draw_outputs


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
    draw_inputs, draw_outputs = definitions()

    entries = [
        ('N2325', DRAW_OWNER, 'source_drill_draw_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'DrillBuild.draw()', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild draw() base state from Drill.java + BuildingComp.java + HealthComp.java + Block.java + Blocks.java + Layer.java + Drawf.java + BlockRenderer.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild draw() base state from Drill.java + BuildingComp.java + HealthComp.java + Block.java + Blocks.java + Layer.java + Drawf.java + BlockRenderer.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: base_rect, cracks_z, cracks,
    # after_cracks_z, rim_visible, rim_alpha, rim_rect,
    # rotator, top_rect, mine_item_visible, mine_item_rect.
    by_slice['N2325'] = [
        'source_drill_draw_state_result.base_rect',
        'source_drill_draw_state_result.cracks_z',
        'source_drill_draw_state_result.cracks',
        'source_drill_draw_state_result.after_cracks_z',
        'source_drill_draw_state_result.rim_visible',
        'source_drill_draw_state_result.rim_alpha',
        'source_drill_draw_state_result.rim_rect',
        'source_drill_draw_state_result.rotator',
        'source_drill_draw_state_result.top_rect',
        'source_drill_draw_state_result.mine_item_visible',
        'source_drill_draw_state_result.mine_item_rect',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2325', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill$DrillBuild', java_method='DrillBuild.draw()', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2325'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
