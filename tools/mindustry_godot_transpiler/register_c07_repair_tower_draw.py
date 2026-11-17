"""Register the RepairTower draw() / range() / warmup() rows (N2232).

N2190 / N2191 / N2211 / N2228 / N2229 / N2230 / N2231 made the
repair tower live (refresh, should-consume, nearby driver, heal
advance, ozone consumer, setStats, drawSelect/drawPlace) -- but
nothing in the port captured what RepairTowerBuild.draw() draws
every frame: the expanding circle (`Lines.circle(x, y, range *
mod);`, RepairTower.java:103, with `float mod = totalProgress %
1f;`, RepairTower.java:100, gated by `if(warmup <= 0.001f)
return;`, RepairTower.java:97), the spinning square
(`Fill.square(x, y, squareRad * warmup, Time.time /
squareSpinScl);`, RepairTower.java:105) and the additive glow
(`Drawf.additive(glow, glowColor, warmup * (1f - glowMag +
Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f,
Layer.blockAdditive);`, RepairTower.java:108) -- nor the two
one-line accessors `range()` (`return range;`,
RepairTower.java:113) and `warmup()` (`return warmup;`,
RepairTower.java:117-118).

RED decisions (resolved at RED): (1) Three pure functions on
the same family file N2190 / N2191 / N2211 / N2228 / N2229 /
N2230 / N2231 built: draw takes the frame (warmup /
total_progress already stamped live by the N2228 driver) plus
explicit per-def params; the two accessors are pure reads.
(2) Time.time is an explicit `time` float param (the
MendProjector draw_state precedent -- `SourceMendProjectorDisplayState.draw_state(..., source_time_ticks := 0.0, ...)` takes time as an explicit param with default 0.0; no frame key carries global time, PortGame has no time accessor, and no `Time.get_ticks_msec` exists in src/game); the driver accumulates a per-building `frame["game_time"]` clock (`frame["game_time"] = float(frame.get("game_time", 0.0)) + seconds`, right before the draw call in the powered branch) to pass in. The known phase deviation is documented: the per-building clock starts at 0.0 at the first tick after placement while Java Time.time is global, so rotation/pulse phase differs between buildings and from Java -- speed and period are exact, render is outside gameplay per the user boundary, and if the port ever gains a global clock the driver changes its time source while the pure function (time already a param) does not change. (3) The glow region is pinned as the String param `glow_region` ("unit-repair-tower-glow", from `public @Load("@-glow") TextureRegion glow;`, RepairTower.java:25; the driver passes the literal, single def); loading the TextureRegion for real stays deferred (the N2227 icons() precedent -- pin the identifier, do not load the texture). (4) The glow alpha uses the port helper `SourceMathState.source_absin(time, glow_scl, glow_mag)` with the original scl (the port precedent -- MendProjector `source_absin(time, 50/PI2, 1.0)` and ThermalGenerator `source_absin(time, 10.0, 5.0)` both pass the Java scl straight into the helper); the arc formula differs by a 2x period factor and the deviation is documented in the function comment, not worked around with a `*2.0` here (fixing the helper belongs to a math slice of its own); the proof pins the port formula at a nonzero time (time 8.0 -> port absin ~0.4604 -> glow_alpha ~0.4802). (5) There IS one driver tick line, for draw only: draw() runs every frame after updateTile (the N2225 RepairTurret draw precedent), so the driver calls `source_repair_tower_draw_state(...)` right after the N2228 heal advance in the powered branch and stamps the draw keys with the `draw_` prefix; the two accessors have NO driver tick line (pure reads, the N2223 sense() precedent). (6) The draw super call (`super.draw();`, RepairTower.java:95) draws the block itself, not the circle/square/glow -- out of scope. Eighteen new result symbols: draw visible / center / z_layer / mod / circle_stroke / circle_radius / circle_color / square_half_size / square_rotation / square_color / glow_alpha / glow_color / glow_color_alpha / glow_region / glow_rotation / glow_z_layer, range, warmup. SSOT expected after GREEN: symbols +18, Done +1, contracts +3, schema +6, 11504/1681/1609/3009 -> 11522/1682/1612/3015. Caveat (scope section on the SSOT delta): `frame["game_time"]` is a new driver frame key -- if the register counted a schema for it the schema delta would be +7/+8 instead of +6; this register adds no schema for it (it is a driver frame key, not a function input/output), so +6 stands. Slice sources: RepairTower.java + Blocks.java + Pal.java + Layer.java + Ranged.java + BuildingComp.java + Drawf.java. No shard change: RepairTower.java matches no shard (the N2219-N2231 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_tower_draw_select_place import DEFERRED as N2231_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PAL = 'core/src/mindustry/graphics/Pal.java'
LAYER = 'core/src/mindustry/graphics/Layer.java'
RANGED = 'core/src/mindustry/logic/Ranged.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
DRAWF = 'core/src/mindustry/graphics/Drawf.java'
PROOF = '/root/C07RepairTowerDrawProof'
DRAW_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_draw_state'
RANGE_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_range_state'
WARMUP_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_warmup_state'
TESTS = ['test_c07_repair_tower_draw_registration', 'test_all_c07_repair_tower_draw_input_evidence_is_exact', 'test_repair_tower_draw_state', 'test_reference_graph_and_actual_c07_repair_tower_draw']
# The 7 slice sources the N2232 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/graphics/Pal.java',
    'core/src/mindustry/graphics/Layer.java',
    'core/src/mindustry/logic/Ranged.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/graphics/Drawf.java',
]
EXACT_EXPRS = ['public void draw(){', 'super.draw();', 'if(warmup <= 0.001f) return;', 'Draw.z(Layer.effect);', 'float mod = totalProgress % 1f;', 'Draw.color(circleColor);', 'Lines.stroke(circleStroke * (1f - mod) * warmup);', 'Lines.circle(x, y, range * mod);', 'Draw.color(Pal.heal);', 'Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);', 'Draw.reset();', 'Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);', 'public float range(){', 'return range;', 'public float warmup(){', 'return warmup;', 'public float range = 80f;', 'public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'public class RepairTower extends Block{', 'public float warmup = 0f;', 'public float totalProgress = 0f;', 'public @Load("@-glow") TextureRegion glow;', 'range = 100f;', 'heal = Color.valueOf("98ffa9"),', 'effect = 110,', 'blockAdditive = 31,', 'public interface Ranged extends Posc, Teamc{', 'float range();', 'return 0f;', 'public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){', 'Draw.color(color, alpha * color.a);']

# DEFERRED is carried from the N2231 register script via import --
# never retyped. The lumped draw-family entry that N2231 wrote
# (draw / range / warmup) is DROPPED here -- this slice closes
# draw() / range() / warmup() -- and replaced by the new entry
# below, which keeps the Windows-proof debt; every other entry
# is carried verbatim (the N2211/N2228 lesson -- never retype
# the pool). The filter drops only the entry carrying the exact
# lumped phrase, so other RepairTower deferrals (suppression,
# targets, super.draw()) survive untouched.
DEFERRED = [e for e in N2231_DEFERRED if 'draw() / range() / warmup()' not in e] + [
    'RepairTower draw() / range() / warmup() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2231: the N2232 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'frame': a('Dictionary', 'public float warmup = 0f;', 'The tower frame (RepairTower.java:52-53, `public float warmup = 0f;` / `public float totalProgress = 0f;` -- the frame carries warmup and total_progress, both stamped live by the N2228 driver; absent keys read the Java field defaults, warmup 0, total_progress 0).'),
        'x': a('float', 'Lines.circle(x, y, range * mod);', 'The building world x (RepairTower.java:103, `Lines.circle(x, y, range * mod);`): the circle, square and glow are all centered on the building position.'),
        'y': a('float', 'Lines.circle(x, y, range * mod);', 'The building world y (RepairTower.java:103, `Lines.circle(x, y, range * mod);`): the circle, square and glow are all centered on the building position.'),
        'range': a('float', 'public float range = 80f;', 'The circle radius base (RepairTower.java:103, `Lines.circle(x, y, range * mod);`): the per-def range -- unit-repair-tower 100f (Blocks.java:6579), class default 80f (`public float range = 80f;`, RepairTower.java:21) -- passed explicitly because it is per-def static state, not a live frame key (the N2220 / N2230 per-def-param precedent).'),
        'time': a('float', 'Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);', 'The clock driving the square rotation and the glow pulse (RepairTower.java:105, `Time.time / squareSpinScl`, and RepairTower.java:108, `Mathf.absin(Time.time, glowScl, glowMag)`): an explicit float param, the MendProjector draw_state precedent -- no frame key carries global time, so the driver passes its accumulated per-building `frame["game_time"]` clock.'),
        'circle_stroke': a('float', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'The circle stroke base (RepairTower.java:23 -- Blocks does not override it; the driver passes the 3f literal, the N2228 circleSpeed 120.0 literal precedent).'),
        'square_rad': a('float', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'The square half-size base (RepairTower.java:23 -- Blocks does not override it; the driver passes the 3f literal).'),
        'square_spin_scl': a('float', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'The square rotation divisor (RepairTower.java:23 -- Blocks does not override it; the driver passes the 0.8f literal).'),
        'glow_mag': a('float', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'The glow pulse magnitude (RepairTower.java:23 -- Blocks does not override it; the driver passes the 0.5f literal).'),
        'glow_scl': a('float', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'The glow pulse scale (RepairTower.java:23 -- Blocks does not override it; the driver passes the 8f literal, the port helper takes the original scl -- see the glow_alpha output rule for the documented arc deviation).'),
        'glow_region': a('String', 'public @Load("@-glow") TextureRegion glow;', 'The glow region name (RepairTower.java:25, `public @Load("@-glow") TextureRegion glow;` -- block name + "-glow", so "unit-repair-tower-glow"; pinned as a String param, the N2227 icons() precedent -- the driver passes the literal, loading the TextureRegion for real stays deferred).'),
    }
    draw_outputs = {
        'visible': a('bool', 'if(warmup <= 0.001f) return;', 'Whether anything draws this frame (RepairTower.java:97, `if(warmup <= 0.001f) return;`): warmup > 0.001. No early return in the pure function -- the full shape is always returned (the MendProjector draw_state precedent); the values at warmup ~= 0 fall to ~= 0 through the formulas.'),
        'center': a('Vector2', 'Lines.circle(x, y, range * mod);', 'The draw center (RepairTower.java:103, `Lines.circle(x, y, range * mod);`): the building position itself -- the square (:105) and glow (:108) share it.'),
        'z_layer': a('float', 'effect = 110,', 'The circle/square z-layer (RepairTower.java:99, `Draw.z(Layer.effect);`): Layer.effect = 110 (Layer.java:75, `effect = 110,`).', source=LAYER),
        'mod': a('float', 'float mod = totalProgress % 1f;', 'The circle progress (RepairTower.java:100, `float mod = totalProgress % 1f;`): fmod(total_progress, 1.0) -- totalProgress only accumulates (RepairTower.java:85), so it is never negative and fmod matches the Java remainder.'),
        'circle_stroke': a('float', 'Lines.stroke(circleStroke * (1f - mod) * warmup);', 'The circle stroke (RepairTower.java:102, `Lines.stroke(circleStroke * (1f - mod) * warmup);`): fades as the circle expands (mod -> 1) and with warmup.'),
        'circle_radius': a('float', 'Lines.circle(x, y, range * mod);', 'The circle radius (RepairTower.java:103, `Lines.circle(x, y, range * mod);`): range * mod -- 0 at mod 0, full range at mod 1.'),
        'circle_color': a('String', 'Draw.color(circleColor);', 'The circle color (RepairTower.java:101, `Draw.color(circleColor);`): circleColor is Pal.heal (RepairTower.java:22, `public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);`; Pal.heal is Color.valueOf("98ffa9"), Pal.java:77), represented as the string "Pal.heal".'),
        'square_half_size': a('float', 'Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);', 'The square half-size (RepairTower.java:105, `Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);`): squareRad * warmup.'),
        'square_rotation': a('float', 'Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);', 'The square rotation (RepairTower.java:105, `Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);`): time / square_spin_scl, the raw value passed straight through (no unit conversion).'),
        'square_color': a('String', 'Draw.color(Pal.heal);', 'The square color (RepairTower.java:104, `Draw.color(Pal.heal);`): Pal.heal, represented as the string "Pal.heal".'),
        'glow_alpha': a('float', 'Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);', 'The glow alpha (RepairTower.java:108, `Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);`): warmup * (1.0 - glow_mag + SourceMathState.source_absin(time, glow_scl, glow_mag)) -- the port helper `(sin(v/s)*0.5+0.5)*m`, which differs from the arc formula by a 2x period factor; the port precedent (MendProjector, ThermalGenerator) passes the Java scl straight into the helper, so this slice does the same and documents the deviation instead of working around it.'),
        'glow_color': a('String', 'public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);', 'The glow color (RepairTower.java:108, `Drawf.additive(glow, glowColor, ...)`): glowColor is Pal.heal with alpha 0.5 (RepairTower.java:22, `public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);`), represented as the string "Pal.heal" with the alpha in glow_color_alpha.'),
        'glow_color_alpha': a('float', 'public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);', 'The glow color alpha (RepairTower.java:22, `glowColor = Pal.heal.cpy().a(0.5f);`): 0.5 -- the Drawf.additive overload (Drawf.java:183) applies `Draw.color(color, alpha * color.a);` (Drawf.java:186), so the effective alpha drawn is glow_alpha * 0.5.'),
        'glow_region': a('String', 'public @Load("@-glow") TextureRegion glow;', 'The glow region name (RepairTower.java:108, `Drawf.additive(glow, ...)`; the region is `@Load("@-glow")`, RepairTower.java:25): the glow_region param passed through.'),
        'glow_rotation': a('float', 'Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);', 'The glow rotation (RepairTower.java:108, `Drawf.additive(..., x, y, 0f, Layer.blockAdditive);`): the rotation arg is the 0f literal.'),
        'glow_z_layer': a('float', 'blockAdditive = 31,', 'The glow z-layer (RepairTower.java:108, `Drawf.additive(..., x, y, 0f, Layer.blockAdditive);`): Layer.blockAdditive = 31 (Layer.java:36, `blockAdditive = 31,`).', source=LAYER),
    }
    range_inputs = {
        'range': a('float', 'public float range = 80f;', 'The per-def range (RepairTower.java:21, `public float range = 80f;` -- unit-repair-tower 100f, Blocks.java:6579, `range = 100f;`): passed explicitly because it is per-def static state, not a live frame key (the N2220 / N2230 per-def-param precedent).'),
    }
    range_outputs = {
        'range': a('float', 'return range;', 'The range (RepairTower.java:113, `return range;`, inside `public float range(){`, RepairTower.java:112, from the Ranged interface, Ranged.java:5-6, `public interface Ranged extends Posc, Teamc{` / `float range();`).'),
    }
    warmup_inputs = {
        'frame': a('Dictionary', 'public float warmup = 0f;', 'The tower frame (RepairTower.java:52, `public float warmup = 0f;` -- the frame carries warmup, stamped live by the N2228 driver; an absent key reads the Java field default, warmup 0).'),
    }
    warmup_outputs = {
        'warmup': a('float', 'return warmup;', 'The warmup (RepairTower.java:118, `return warmup;`, inside `public float warmup(){`, RepairTower.java:117, overriding the base that returns 0f, BuildingComp.java:608-609, `public float warmup(){` / `return 0f;`).'),
    }
    return draw_inputs, draw_outputs, range_inputs, range_outputs, warmup_inputs, warmup_outputs


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
    draw_inputs, draw_outputs, range_inputs, range_outputs, warmup_inputs, warmup_outputs = definitions()

    entries = [
        ('N2232', DRAW_OWNER, 'source_repair_tower_draw_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.draw()', draw_inputs, draw_outputs, True, 'Dictionary'),
        ('N2232', RANGE_OWNER, 'source_repair_tower_range_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.range()', range_inputs, range_outputs, True, 'Dictionary'),
        ('N2232', WARMUP_OWNER, 'source_repair_tower_warmup_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.warmup()', warmup_inputs, warmup_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower draw/range/warmup state from RepairTower.java + Blocks.java + Pal.java + Layer.java + Ranged.java + BuildingComp.java + Drawf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower draw/range/warmup state from RepairTower.java + Blocks.java + Pal.java + Layer.java + Ranged.java + BuildingComp.java + Drawf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: draw visible / center / z_layer /
    # mod / circle_stroke / circle_radius / circle_color /
    # square_half_size / square_rotation / square_color /
    # glow_alpha / glow_color / glow_color_alpha / glow_region /
    # glow_rotation / glow_z_layer, range, warmup.
    by_slice['N2232'] = [
        'source_repair_tower_draw_state_result.visible',
        'source_repair_tower_draw_state_result.center',
        'source_repair_tower_draw_state_result.z_layer',
        'source_repair_tower_draw_state_result.mod',
        'source_repair_tower_draw_state_result.circle_stroke',
        'source_repair_tower_draw_state_result.circle_radius',
        'source_repair_tower_draw_state_result.circle_color',
        'source_repair_tower_draw_state_result.square_half_size',
        'source_repair_tower_draw_state_result.square_rotation',
        'source_repair_tower_draw_state_result.square_color',
        'source_repair_tower_draw_state_result.glow_alpha',
        'source_repair_tower_draw_state_result.glow_color',
        'source_repair_tower_draw_state_result.glow_color_alpha',
        'source_repair_tower_draw_state_result.glow_region',
        'source_repair_tower_draw_state_result.glow_rotation',
        'source_repair_tower_draw_state_result.glow_z_layer',
        'source_repair_tower_range_state_result.range',
        'source_repair_tower_warmup_state_result.warmup',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2232', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTowerBuild.draw()/RepairTowerBuild.range()/RepairTowerBuild.warmup()', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2232'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
