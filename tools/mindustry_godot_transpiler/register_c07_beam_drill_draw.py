"""Register the BeamDrillBuild.draw() slice (N2382).

BeamDrillBuild.draw() (BeamDrill.java:275-361, `public void
draw(){`) is the BeamDrillBuild render method on `public class
BeamDrillBuild extends Building{` (BeamDrill.java:220) inside
`public class BeamDrill extends Block{` (BeamDrill.java:25): the
base + top rects, the per-face laser (center rects when the laser
point sits on the face tile, Drawf.laser beams otherwise), the
Lod.l2 spark loop driven by the build rand, and the additive glow
rect. One pure function on the existing
SourceBeamDrillBuildState.gd (created by N2155, extended by
N2378/N2379), following the N2314/N2325 draw precedent: it returns
the computed draw state (rects, laser endpoints, spark lines,
glow) and does NOT touch real Draw / Drawf / Lines playback.
There is NO driver tick line: draw() is per-frame render state,
not per-tick state.

RED decisions (resolved at RED): (1) The 42 distinguishing
exprs are the 27 scope exprs (re-probed at HEAD 0ac2993f in
both ledgers, 27/31 0-hit) plus 15 extra 0-hit exprs from the
same method body (the boost gates, the alpha/scl calls, the
spark-loop locals, the spark loop header), re-probed in the
same run. The 4 SHARE exprs (`if(glowRegion.found()){` hit
local [N2184, N2314], remote [N2184]; `Draw.z(Layer.
blockAdditive);` hit local [N2181, N2314], remote [N2181];
`Draw.blend(Blending.additive);` hit local [N2181, N2314,
N2325], remote [N2181]; `Draw.reset();` hit 13 slices local /
12 remote) are evidence/context only, NOT distinguishing
exprs, and are NOT in EXACT_EXPRS. `Draw.z(Layer.effect);`
hits N2232, `Draw.color();` / `Draw.mixcol();` /
`Draw.blend();` / `for(int i = 0; i < size; i++){` (N2379) /
`public void draw(){` (16 slices) are likewise excluded.
(2) Time.time arrives as the explicit time_ticks param (pin
in the proof frame, the N2314/N2325 draw precedent); the
per-building clock phase deviation is documented in the GD
comment. (3) rand.setState(i, id) seeds the arc xorshift Rand
directly with the two longs (no murmur hash -- setState is a
direct assignment, Rand.java); the three draws per spark
(random(sparkRecurrence + 1f), range(2f),
range(sparkSpread)) come from one shared state threaded
through the loop; the helpers are re-implemented file-local
in SourceBeamDrillBuildState.gd from the RepairTurret-proven
logic (N2289/N2290) instead of calling across families, so
this file does not depend on the Windows line's RepairTurret
file. An independent Python oracle (arc Rand from the Java
source) hard-codes the expected first draws in the proof.
(4) Tmp.c1/c3/v1 are scratch only, never registered.
(5) absin goes through the port helper
SourceMathState.source_absin with the original scl (the
MendProjector / RepairTower draw precedent); the arc formula
(N485) differs by a 2x period factor and the deviation is
documented, not worked around. (6) Mathf.slope(fin) is the
triangle 0 at 0, 1 at 0.5, 0 at 1 -- no slice owns slope
yet, so it is computed inline in the GD function, not
registered as a math slice. (7) The payload early return
(`if(isPayload()) return;`) leaves base/top rects drawn
and skips lasers + glow: the pure function always returns
the full shape with is_payload set, an empty lasers list
and glow_visible false when payload (the RepairTower draw
visible-flag precedent). (8) A face with no drop is skipped
(`if(drop == null) continue;`); a missing laser point
leaves its face skipped -- Java would throw there; the
guard is documented, not a behavior change for any frame
updateLasers built (the N2379 guard precedent). (9) The
per-def values (laserWidth 0.65f class default, 0.7f
large-plasma-bore, Blocks.java:3062; tier 3/5, size 2/3,
range 5/6, Blocks.java:3038-3065) arrive as explicit params
(the N2212 / N2248 per-def-param precedent). (10) Layers:
Layer.power - 1 = 69 (power = 70, Layer.java:57),
Layer.effect = 110 (Layer.java:75), Layer.blockAdditive = 31
(Layer.java:36). (11) Tile.worldx() = x * tilesize
(Tile.java:166-168, no +tilesize/2); rotdeg() = rotation *
90; Geometry.d4(rotation) is the (d4x, d4y) unit vector
(Geometry.java:23-24, 47-51, read with posmod).
Eight new result symbols: base_rect, top_rect, is_payload,
lasers, glow_visible, glow_alpha, glow_color, glow_rect.
Slice source: BeamDrill.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_update_facing import DEFERRED as N2379_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
PROOF = '/root/C07BeamDrillDrawProof'
DRAW_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_draw_state'
TESTS = ['test_c07_beam_drill_draw_registration', 'test_all_c07_beam_drill_draw_input_evidence_is_exact', 'test_beam_drill_draw_state', 'test_reference_graph_and_actual_c07_beam_drill_draw']
# The 1 slice source the N2382 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
]
EXACT_EXPRS = [
    'Draw.rect(block.region, x, y);',
    'Draw.rect(topRegion, x, y, rotdeg());',
    'if(isPayload()) return;',
    'var dir = Geometry.d4(rotation);',
    'int ddx = Geometry.d4x(rotation + 1), ddy = Geometry.d4y(rotation + 1);',
    'Tile face = facing[i];',
    'Item drop = face.wallDrop();',
    'Point2 p = lasers[i];',
    'float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;',
    'float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;',
    'Draw.z(Layer.power - 1);',
    'Draw.mixcol(glowColor, Mathf.absin(Time.time + i*5 + id*9, glowScl, glowIntensity));',
    'if(Math.abs(p.x - face.x) + Math.abs(p.y - face.y) == 0){',
    'Draw.scl(width);',
    'Draw.rect(laserCenter, lx, ly);',
    'Draw.rect(laserCenterBoost, lx, ly);',
    'float lsx = (p.x - dir.x/2f) * tilesize, lsy = (p.y - dir.y/2f) * tilesize;',
    'Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);',
    'Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);',
    'Draw.color(Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup), warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))));',
    'Draw.rect(glowRegion, x, y, rotdeg());',
    'if(Lod.l2){',
    'Lines.stroke(warmup);',
    'rand.setState(i, id);',
    'Color spark = Tmp.c3.set(sparkColor).lerp(boostHeatColor, boostWarmup);',
    'float fin = (Time.time / sparkLife + rand.random(sparkRecurrence + 1f)) % sparkRecurrence;',
    'if(fin <= 1f) Lines.lineAngle(lx + px + or * ddx, ly + py + or * ddy, Angles.angle(px, py), Mathf.slope(fin) * sparkSize);',
    'if(face != null){',
    'if(drop == null) continue;',
    'if(boostWarmup < 0.99f){',
    'Draw.alpha(1f - boostWarmup);',
    'if(boostWarmup > 0.01f){',
    'Draw.alpha(boostWarmup);',
    'Draw.scl();',
    'if(boostWarmup > 0.001f){',
    'Color col = drop.color;',
    'float or = rand.range(2f);',
    'Tmp.v1.set(sparkRange * fin, 0).rotate(rotdeg() + rand.range(sparkSpread));',
    'Color result = Tmp.c1.set(spark).lerp(col, fin);',
    'Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);',
    'float px = Tmp.v1.x, py = Tmp.v1.y;',
    'for(int j = 0; j < sparks; j++){',
]

# DEFERRED is carried from the N2379 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (draw touches no updateTile advance, shouldConsume gate, liquid
# row, drillMultipliers row, or facing binding), so all are carried
# verbatim. Four entries are added: N2382's Windows proof debt,
# the concrete-rendering boundary, the absin 2x period deviation,
# and the Time.time phase note.
DEFERRED = list(N2379_DEFERRED) + [
    'BeamDrill draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2155: the N2382 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BeamDrill draw() concrete rect/laser rendering (Draw.rect / Drawf.laser / Lines.lineAngle with live TextureRegions) stays owned by Godot rendering integration; this helper preserves rects, laser endpoints, spark lines and glow state.',
    'BeamDrill draw() absin 2x period deviation -- the port helper SourceMathState.source_absin differs from the arc formula (N485: (sin(in, scl*2f, mag) + mag) / 2f) by a 2x period factor; fixing the helper belongs to a math slice of its own.',
    'BeamDrill draw() Time.time phase -- the proof pins time as an explicit param; the live driver has no global clock yet, so per-building pulse phase differs from Java until a global-clock slice lands.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    base_expr = 'Draw.rect(block.region, x, y);'
    top_expr = 'Draw.rect(topRegion, x, y, rotdeg());'
    width_expr = 'float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;'
    laser_expr = 'Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);'
    laser_boost_expr = 'Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);'
    glow_color_expr = 'Draw.color(Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup), warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))));'
    spark_fields_expr = 'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;'
    draw_inputs = {
        'x': a('float', base_expr, 'The building world x (BeamDrill.java:276, `Draw.rect(block.region, x, y);`); passed explicitly because draw() reads the live building position.'),
        'y': a('float', base_expr, 'The building world y (BeamDrill.java:276, `Draw.rect(block.region, x, y);`); passed explicitly because draw() reads the live building position.'),
        'region': a('Variant', base_expr, 'The block region (BeamDrill.java:276, `Draw.rect(block.region, x, y);`, Block.region); passed explicitly because it is per-def static state, not a live frame key (the N2212 per-def-param precedent).'),
        'top_region': a('Variant', top_expr, 'The BeamDrill top region (BeamDrill.java:38, `public @Load("@-top") TextureRegion topRegion;`, drawn BeamDrill.java:277, `Draw.rect(topRegion, x, y, rotdeg());`); passed explicitly because it is per-def static state.'),
        'laser': a('Variant', laser_expr, 'The beam region (BeamDrill.java:28, `public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;`, drawn BeamDrill.java:312, `Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);`); passed explicitly because it is per-def static state.'),
        'laser_end': a('Variant', laser_expr, 'The beam end region (BeamDrill.java:29, `public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;`, drawn BeamDrill.java:312); passed explicitly because it is per-def static state.'),
        'laser_center': a('Variant', 'Draw.rect(laserCenter, lx, ly);', 'The beam center region (BeamDrill.java:30, `public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;`, drawn BeamDrill.java:298, `Draw.rect(laserCenter, lx, ly);`); passed explicitly because it is per-def static state.'),
        'laser_boost': a('Variant', laser_boost_expr, 'The boosted beam region (BeamDrill.java:32, `public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;`, drawn BeamDrill.java:317, `Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);`); passed explicitly because it is per-def static state.'),
        'laser_end_boost': a('Variant', laser_boost_expr, 'The boosted beam end region (BeamDrill.java:33, `public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;`, drawn BeamDrill.java:317); passed explicitly because it is per-def static state.'),
        'laser_center_boost': a('Variant', 'Draw.rect(laserCenterBoost, lx, ly);', 'The boosted beam center region (BeamDrill.java:34, `public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;`, drawn BeamDrill.java:303, `Draw.rect(laserCenterBoost, lx, ly);`); passed explicitly because it is per-def static state.'),
        'glow_region': a('Variant', 'Draw.rect(glowRegion, x, y, rotdeg());', 'The glow region (BeamDrill.java:39, `public @Load("@-glow") TextureRegion glowRegion;`, drawn BeamDrill.java:352, `Draw.rect(glowRegion, x, y, rotdeg());`); passed explicitly because it is per-def static state.'),
        'glow_region_found': a('bool', 'if(glowRegion.found()){', 'Whether the @-glow region exists (BeamDrill.java:347, `if(glowRegion.found()){`); passed explicitly because region presence is load-time state.'),
        'rotation': a('int', 'var dir = Geometry.d4(rotation);', 'The build rotation 0-3 (BeamDrill.java:283, `var dir = Geometry.d4(rotation);`): it picks the faced side, the top-rect angle (rotdeg() = rotation * 90) and the spark rotation.'),
        'size': a('int', 'for(int i = 0; i < size; i++){', 'The block size (BeamDrill.java:285, `for(int i = 0; i < size; i++){`): the facing / lasers arrays are sized `size` (plasma-bore 2, large-plasma-bore 3, Blocks.java:3049-3065); passed explicitly (the N2212 / N2248 per-def-param precedent).'),
        'build_id': a('int', width_expr, 'The build id (BeamDrill.java:293, `float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;`): it phases the width pulse and seeds the spark rand (`rand.setState(i, id);`, BeamDrill.java:328).'),
        'warmup': a('float', width_expr, 'The drill warmup (BeamDrill.java:226, `public float warmup, boostWarmup;`, folded BeamDrill.java:293, `... * warmup;`): it scales the laser width, the spark stroke and the glow alpha.'),
        'boost_warmup': a('float', 'if(boostWarmup < 0.99f){', 'The boost warmup (BeamDrill.java:226, `public float warmup, boostWarmup;`): it gates the center/beam vs boost rects/lasers (BeamDrill.java:296-317, `if(boostWarmup < 0.99f){` / `if(boostWarmup > 0.01f){` / `if(boostWarmup > 0.001f){`) and lerps the spark/glow colors toward boostHeatColor.'),
        'is_payload': a('bool', 'if(isPayload()) return;', 'Whether the build is carried as a payload (BeamDrill.java:280, `if(isPayload()) return;`): a payload build draws only the base + top rects, no lasers or glow.'),
        'facing': a('Array', 'Tile face = facing[i];', 'The facing tiles per footprint side (BeamDrill.java:221, `public Tile[] facing = new Tile[size];`, read BeamDrill.java:286, `Tile face = facing[i];`): each entry is null or a tile Dictionary {"x", "y", "wall_drop", "drop_color"} (the N2379 tile-Dictionary precedent, extended with the drop color draw() reads as `drop.color`).'),
        'lasers': a('Array', 'Point2 p = lasers[i];', 'The laser side points per footprint side (BeamDrill.java:222, `public Point2[] lasers = new Point2[size];`, read BeamDrill.java:292, `Point2 p = lasers[i];`): one Vector2i per side, built by updateLasers (N2379).'),
        'laser_width': a('float', 'public float laserWidth = 0.65f;', 'The base laser width (BeamDrill.java:44, `public float laserWidth = 0.65f;`, class default; large-plasma-bore overrides `laserWidth = 0.7f;`, Blocks.java:3062); passed explicitly (the N2212 per-def-param precedent).'),
        'glow_scl': a('float', 'public float glowScl = 3f;', 'The glow pulse scale (BeamDrill.java:57, `public float glowScl = 3f;`): the absin period for the width pulse and the mixcol amount.'),
        'pulse_intensity': a('float', 'public float glowIntensity = 0.2f, pulseIntensity = 0.07f;', 'The width pulse magnitude (BeamDrill.java:56, `public float glowIntensity = 0.2f, pulseIntensity = 0.07f;`): the absin magnitude in the width formula (BeamDrill.java:293).'),
        'glow_color': a('Variant', 'public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;', 'The glow color (BeamDrill.java:55, `public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;`): the mixcol target (BeamDrill.java:295, `Draw.mixcol(glowColor, ...)`).'),
        'glow_intensity': a('float', 'public float glowIntensity = 0.2f, pulseIntensity = 0.07f;', 'The mixcol pulse magnitude (BeamDrill.java:56, `public float glowIntensity = 0.2f, pulseIntensity = 0.07f;`): the absin magnitude for the mixcol amount (BeamDrill.java:295).'),
        'spark_color': a('Variant', 'public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;', 'The spark base color (BeamDrill.java:55, `public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;`, "fd9e81"): the spark color before the boost lerp (BeamDrill.java:330, `Color spark = Tmp.c3.set(sparkColor).lerp(boostHeatColor, boostWarmup);`).'),
        'boost_heat_color': a('Variant', 'public Color boostHeatColor = Color.sky.cpy().mul(0.87f);', 'The boosted heat color (BeamDrill.java:62, `public Color boostHeatColor = Color.sky.cpy().mul(0.87f);`): the spark and glow colors lerp toward it by boostWarmup.'),
        'heat_color': a('Variant', 'public Color heatColor = new Color(1f, 0.35f, 0.35f, 0.9f);', 'The glow heat color (BeamDrill.java:63, `public Color heatColor = new Color(1f, 0.35f, 0.35f, 0.9f);`, alpha 0.9): the glow color before the boost lerp, and its alpha scales the glow alpha (BeamDrill.java:351).'),
        'heat_pulse': a('float', 'public float heatPulse = 0.3f, heatPulseScl = 7f;', 'The glow pulse depth (BeamDrill.java:64, `public float heatPulse = 0.3f, heatPulseScl = 7f;`): the glow alpha is warmup * heatColor.a * (1 - heatPulse + absin) (BeamDrill.java:351).'),
        'heat_pulse_scl': a('float', 'public float heatPulse = 0.3f, heatPulseScl = 7f;', 'The glow pulse scale (BeamDrill.java:64, `public float heatPulse = 0.3f, heatPulseScl = 7f;`): the absin scale for the glow alpha pulse (BeamDrill.java:351, `Mathf.absin(heatPulseScl, heatPulse)` is the Time.time overload).'),
        'sparks': a('int', 'public int sparks = 7;', 'How many sparks per face (BeamDrill.java:58, `public int sparks = 7;`): the spark loop count (BeamDrill.java:332, `for(int j = 0; j < sparks; j++){`).'),
        'spark_life': a('float', spark_fields_expr, 'The spark life divisor (BeamDrill.java:59, `public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;`): fin advances as Time.time / sparkLife (BeamDrill.java:333).'),
        'spark_recurrence': a('float', spark_fields_expr, 'The spark recurrence modulus (BeamDrill.java:59): fin wraps mod sparkRecurrence (BeamDrill.java:333, `float fin = (Time.time / sparkLife + rand.random(sparkRecurrence + 1f)) % sparkRecurrence;`).'),
        'spark_range': a('float', spark_fields_expr, 'The spark travel range (BeamDrill.java:59): the spark offset is (sparkRange * fin, 0) rotated (BeamDrill.java:335).'),
        'spark_spread': a('float', spark_fields_expr, 'The spark angle spread (BeamDrill.java:59): the spark rotation draws rand.range(sparkSpread) (BeamDrill.java:335).'),
        'spark_size': a('float', spark_fields_expr, 'The spark line size (BeamDrill.java:59): the line length is Mathf.slope(fin) * sparkSize (BeamDrill.java:341).'),
        'time_ticks': a('float', width_expr, 'Time.time in ticks (BeamDrill.java:293, `Mathf.absin(Time.time + i*5 + (id % 9)*9, ...)`): the absolute clock draw() pulses against; passed explicitly (the N2314/N2325 draw precedent -- no frame key carries global time).'),
        'lod_l2': a('bool', 'if(Lod.l2){', 'The level-of-detail flag (BeamDrill.java:324, `if(Lod.l2){`, Lod.java: l2 default true): the spark loop runs only when it holds; passed explicitly because the live zoom value is not a frame key.'),
        'lod_alpha2': a('float', 'Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);', 'The Lod alpha2 fade (BeamDrill.java:340, `Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);`, Lod.java: alpha2 default 1f): it scales the spark draw alpha; passed explicitly with lod_l2.'),
        'tilesize': a('float', 'float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;', 'The world tilesize (BeamDrill.java:294, `float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;`, Vars.tilesize 8): tile-to-world conversion for the laser endpoints.'),
    }
    draw_outputs = {
        'base_rect': a('Dictionary', base_expr, 'The base rect {region, x, y}, always drawn (BeamDrill.java:276, `Draw.rect(block.region, x, y);`).'),
        'top_rect': a('Dictionary', top_expr, 'The top rect {region, x, y, rotation_deg}, always drawn (BeamDrill.java:277, `Draw.rect(topRegion, x, y, rotdeg());`, rotdeg() = rotation * 90).'),
        'is_payload': a('bool', 'if(isPayload()) return;', 'Whether the build is a payload (BeamDrill.java:280, `if(isPayload()) return;`): when true the lasers list is empty and the glow is hidden.'),
        'lasers': a('Array', 'float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;', 'The per-face computed draw state (BeamDrill.java:285-344): index, drop, lx/ly, width, mix_amount, z 69, centered flag, the center/beam rects or laser endpoints with their boost-gated alphas, and the spark list with stroke + z 110.'),
        'glow_visible': a('bool', 'if(glowRegion.found()){', 'Whether the glow is drawn: true exactly when the glow region exists and the build is not a payload (BeamDrill.java:347, `if(glowRegion.found()){`, after the BeamDrill.java:280 payload return).'),
        'glow_alpha': a('float', glow_color_expr, 'The glow draw alpha: warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))) (BeamDrill.java:351) -- the Draw.color second argument; the lerped glow color carries its own .a separately (the RepairTower glow precedent).'),
        'glow_color': a('Variant', glow_color_expr, 'The glow color: heatColor lerped toward boostHeatColor by boostWarmup (BeamDrill.java:351, `Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup)`).'),
        'glow_rect': a('Variant', 'Draw.rect(glowRegion, x, y, rotdeg());', 'The glow rect {region, x, y, rotation_deg} when visible, else null (BeamDrill.java:352, `Draw.rect(glowRegion, x, y, rotdeg());`, z 31 additive).'),
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
    (draw_inputs, draw_outputs) = definitions()

    entries = [
        ('N2382', DRAW_OWNER, 'source_beam_drill_draw_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.draw', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.draw() state from BeamDrill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.draw() state from BeamDrill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: base_rect, top_rect,
    # is_payload, lasers, glow_visible, glow_alpha,
    # glow_color, glow_rect.
    by_slice['N2382'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2382', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.draw', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2382'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
