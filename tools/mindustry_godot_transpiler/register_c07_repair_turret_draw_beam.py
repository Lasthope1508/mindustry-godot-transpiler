"""Register the RepairTurret drawBeam rows (N2219).

N2212-N2215 made the repair turret live (target acquire, heal
advance, rotation slerp, strength lerp) and N2217 persisted its
rotation -- but nothing in the port captured what draw() draws
each frame: RepairPointBuild.draw() calls the static drawBeam
(`drawBeam(x, y, rotation, length, id, target, team, strength,`,
RepairTurret.java:171, inside `public void draw(){`,
RepairTurret.java:164), which computes the beam origin from the
turret position, rotation and length (`originX = x +
Angles.trnsx(rotation, length),` / `originY = y +
Angles.trnsy(rotation, length);`, RepairTurret.java:115-116),
moves the beam endpoint to the target and clamps it to at least
2f from the origin (`lastEnd.set(target).sub(originX, originY);`
/ `lastEnd.setLength(Math.max(2f, lastEnd.len()));`,
RepairTurret.java:118-119), and draws the laser only while the
beam is strong (`if(strength > 0.01f){`,
RepairTurret.java:129) with width `strength * beamWidth`
(`Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x,
lastEnd.y, strength * beamWidth);`, RepairTurret.java:145) and
pulse stroke `strength * pulseStroke` (`Lines.stroke(strength *
pulseStroke);`, RepairTurret.java:141).

RED decisions (resolved at RED): (1) One pure function on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217
built, returning the deterministic beam state: beam_origin,
beam_end, beam_visible, beam_width, pulse_stroke, has_target.
Rendering itself stays out of the game -- only the state the
beam depends on is captured, per the user boundary. (2) beam_end
is the PRE-JITTER endpoint: the random jitter
(`lastEnd.add(offset.trns(...))`, RepairTurret.java:121-124,
three rand.random calls plus Time.time) and the pulse phase
(`float f = (Time.time / 85f + rand.random(1f)) % 1f;`,
RepairTurret.java:138, driving the pulse alpha and circle
radius, RepairTurret.java:140-142) need arc Rand modeling and
wait for a Rand-modeling slice -- they are deferred, not
guessed. (3) With no target the endpoint is STALE: Java leaves
lastEnd untouched (`if(target != null){`,
RepairTurret.java:113, guards the whole endpoint branch), so
the function returns the frame's stored last_end (Vector2.ZERO
when the frame carries none, the `new Vec2()` field default,
RepairTurret.java:155). (4) The driver calls the pure function
once per tick AFTER the N2215 strength lerp (draw() runs after
updateTile in the frame loop, so the beam reads the tick's
final target/rotation/strength), stamping beam_origin, last_end
(= beam_end), beam_visible, beam_width and pulse_stroke on the
frame. (5) length / beamWidth are per-def params resolved by
the driver (repair-point length 5f class default, beamWidth
0.73f, Blocks.java:6390; repair-turret length 6f,
Blocks.java:6399, beamWidth 1.1f, Blocks.java:6403; class
defaults `public float length = 5f;` / `public float beamWidth
= 1f;`, RepairTurret.java:35-36); pulseStroke is the 2f class
default (`public float pulseStroke = 2f;`,
RepairTurret.java:38), overridden by neither def, so the driver
passes the 2.0 literal. (6) drawSelect / drawPlace dash circles
(`Drawf.dashCircle(x, y, repairRadius, Pal.accent);`,
RepairTurret.java:178 and :98) are selection/placement
rendering, not the beam -- deferred to their own slice. Six new
result symbols: beam_origin, beam_end, beam_visible,
beam_width, pulse_stroke, has_target. Single slice source:
RepairTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_read_write import DEFERRED as N2217_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
PROOF = '/root/C07RepairTurretDrawBeamProof'
DRAW_BEAM_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_draw_beam_state'
TESTS = ['test_c07_repair_turret_draw_beam_registration', 'test_all_c07_repair_turret_draw_beam_input_evidence_is_exact', 'test_repair_turret_draw_beam_state', 'test_reference_graph_and_actual_c07_repair_turret_draw_beam']
# The 1 slice source the N2219 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
]
EXACT_EXPRS = ['public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,', 'float strength, float pulseStroke, float pulseRadius, float beamWidth,', 'Vec2 lastEnd, Vec2 offset,', 'rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));', 'if(target != null){', 'originX = x + Angles.trnsx(rotation, length),', 'originY = y + Angles.trnsy(rotation, length);', 'lastEnd.set(target).sub(originX, originY);', 'lastEnd.setLength(Math.max(2f, lastEnd.len()));', 'lastEnd.add(offset.trns(', 'rand.random(360f) + Time.time/2f,', 'Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))', 'lastEnd.add(originX, originY);', 'if(strength > 0.01f){', 'float f = (Time.time / 85f + rand.random(1f)) % 1f;', 'Draw.alpha(1f - Interp.pow5In.apply(f));', 'Lines.stroke(strength * pulseStroke);', 'Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);', 'Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);', 'drawBeam(x, y, rotation, length, id, target, team, strength,', 'public float strength, rotation = 90;', 'public float length = 5f;', 'public float beamWidth = 1f;', 'public float pulseRadius = 6f;', 'public float pulseStroke = 2f;', 'public Vec2 offset = new Vec2(), lastEnd = new Vec2();']

# DEFERRED is carried from the N2217 register script via import --
# never retyped. The N2217 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2216 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2219's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
# NOTE: the N2217 pool entry claiming the drawBeam rows "are pure
# rendering ... no frame key, waits for a rendering slice" is
# SUPERSEDED by this slice -- the beam state now has frame keys
# (beam_origin / beam_end as last_end / beam_visible / beam_width /
# pulse_stroke). The pool is cumulative history, so the old entry
# stays; the new entries below pin what is still deferred.
DEFERRED = list(N2217_DEFERRED) + [
    'RepairTurret drawBeam random jitter (RepairTurret.java:121-124, `lastEnd.add(offset.trns(` with `rand.random(360f) + Time.time/2f,` and `Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))`) needs arc Rand modeling (rand.setSeed(id + target id), RepairTurret.java:111) plus Time.time -- the N2219 beam endpoint is the pre-jitter position; the jitter waits for a Rand-modeling slice.',
    'RepairTurret drawBeam pulse phase (RepairTurret.java:138, `float f = (Time.time / 85f + rand.random(1f)) % 1f;`, :140 `Draw.alpha(1f - Interp.pow5In.apply(f));`, :142 `Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);`) needs the same Rand + Time.time modeling; pulseRadius per-def repair-point 5f / repair-turret 6.1f (Blocks.java:6391/6405), class default 6f (RepairTurret.java:37) -- no pulse-circle radius key exists yet.',
    'RepairTurret drawSelect / drawPlace dash circles (RepairTurret.java:177-179, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`, :95-99) are selection/placement rendering, not the beam -- wait for their own slice.',
    'RepairTurret drawBeam Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2218: the N2219 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_beam_inputs = {
        'frame': a('Dictionary', 'public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,', 'The repair-turret frame carrying the live target (stamped by the N2212 acquire), strength (stamped by the N2215 lerp) and last_end (the persisted beam endpoint, `public Vec2 offset = new Vec2(), lastEnd = new Vec2();`, RepairTurret.java:155; absent reads Vector2.ZERO, the `new Vec2()` field default) -- with no target the endpoint stays stale, so the function returns the stored last_end.'),
        'x': a('float', 'originX = x + Angles.trnsx(rotation, length),', 'The turret world x (RepairTurret.java:115, `originX = x + Angles.trnsx(rotation, length),`): the beam origin starts at the turret position.'),
        'y': a('float', 'originY = y + Angles.trnsy(rotation, length);', 'The turret world y (RepairTurret.java:116, `originY = y + Angles.trnsy(rotation, length);`): the beam origin starts at the turret position.'),
        'rotation': a('float', 'originX = x + Angles.trnsx(rotation, length),', 'The turret rotation in degrees (RepairTurret.java:115-116, `Angles.trnsx(rotation, length)` / `Angles.trnsy(rotation, length)`): the beam origin is the turret position plus the length rotated by this angle; the driver reads the frame rotation stamped by the N2214 slerp (default 90.0, `public float strength, rotation = 90;`, RepairTurret.java:156).'),
        'length': a('float', 'originX = x + Angles.trnsx(rotation, length),', 'The beam origin offset (RepairTurret.java:115-116, `Angles.trnsx(rotation, length)`): the per-def length -- repair-point 5f (class default, `public float length = 5f;`, RepairTurret.java:35), repair-turret 6f (Blocks.java:6399) -- resolved by the driver.'),
        'beam_width': a('float', 'Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);', 'The laser width factor (RepairTurret.java:145, `strength * beamWidth`): the per-def beamWidth -- repair-point 0.73f (Blocks.java:6390), repair-turret 1.1f (Blocks.java:6403), class default 1f (`public float beamWidth = 1f;`, RepairTurret.java:36) -- resolved by the driver.'),
        'pulse_stroke': a('float', 'Lines.stroke(strength * pulseStroke);', 'The pulse circle stroke factor (RepairTurret.java:141, `strength * pulseStroke`): the 2f class default (`public float pulseStroke = 2f;`, RepairTurret.java:38), overridden by neither def, so the driver passes the 2.0 literal.'),
    }
    draw_beam_outputs = {
        'beam_origin': a('Vector2', 'originX = x + Angles.trnsx(rotation, length),', 'The beam origin (RepairTurret.java:115-116, `originX = x + Angles.trnsx(rotation, length),` / `originY = y + Angles.trnsy(rotation, length);`): the turret position plus the rotated length -- the muzzle the laser starts from.'),
        'beam_end': a('Vector2', 'lastEnd.setLength(Math.max(2f, lastEnd.len()));', 'The beam endpoint (RepairTurret.java:118-119, `lastEnd.set(target).sub(originX, originY);` / `lastEnd.setLength(Math.max(2f, lastEnd.len()));`): the target position relative to the origin, clamped to at least 2f, re-added to the origin -- the PRE-JITTER position (the rand jitter, RepairTurret.java:121-124, is deferred); with no target this is the frame stored last_end, left stale by Java (`if(target != null){`, RepairTurret.java:113).'),
        'beam_visible': a('bool', 'if(strength > 0.01f){', 'Whether the laser draws this frame (RepairTurret.java:129, `if(strength > 0.01f){`): STRICT -- strength 0.01f itself does not draw.'),
        'beam_width': a('float', 'Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);', 'The laser width (RepairTurret.java:145, `strength * beamWidth`): strength scaled by the per-def beamWidth.'),
        'pulse_stroke': a('float', 'Lines.stroke(strength * pulseStroke);', 'The pulse circle stroke width (RepairTurret.java:141, `strength * pulseStroke`): strength scaled by the 2f pulseStroke default.'),
        'has_target': a('bool', 'if(target != null){', 'Whether a target drives the endpoint this frame (RepairTurret.java:113, `if(target != null){`): the gate the endpoint branch reads -- false means the endpoint is the stale stored last_end.'),
    }
    return draw_beam_inputs, draw_beam_outputs


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
    draw_beam_inputs, draw_beam_outputs = definitions()

    entries = [
        ('N2219', DRAW_BEAM_OWNER, 'source_repair_turret_draw_beam_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.draw()/drawBeam()', draw_beam_inputs, draw_beam_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret drawBeam state from RepairTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret drawBeam state from RepairTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: beam_origin, beam_end,
    # beam_visible, beam_width, pulse_stroke, has_target.
    by_slice['N2219'] = [
        'source_repair_turret_draw_beam_state_result.beam_origin',
        'source_repair_turret_draw_beam_state_result.beam_end',
        'source_repair_turret_draw_beam_state_result.beam_visible',
        'source_repair_turret_draw_beam_state_result.beam_width',
        'source_repair_turret_draw_beam_state_result.pulse_stroke',
        'source_repair_turret_draw_beam_state_result.has_target',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2219', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.draw()/drawBeam()', godot_owner=DRAW_BEAM_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2219'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
