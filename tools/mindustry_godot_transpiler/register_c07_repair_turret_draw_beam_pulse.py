"""Register the RepairTurret drawBeam pulse rows (N2252).

N2219 captured the deterministic beam state but left the pulse
circle unmodeled, and N2251 modeled the jitter (the first three
Rand draws) but left the pulse phase for this slice: the pulse
phase (`float f = (Time.time / 85f + rand.random(1f)) % 1f;`,
RepairTurret.java:138) is the FOURTH draw from the SAME seeded
Rand sequence as the N2251 jitter draws, so it reuses that
slice's xorshift helpers, not a re-seed. `Draw.alpha(1f -
Interp.pow5In.apply(f));` (RepairTurret.java:140) fades the
pulse circle with pow5In -- Interp.pow5In is PowIn(5)
(Interp.java:45), apply(a) = pow(a, 5)
(Interp.java:119-121), so alpha = 1 - f^5.
`Lines.stroke(strength * pulseStroke);`
(RepairTurret.java:141) and `Lines.circle(lastEnd.x,
lastEnd.y, 1f + f * pulseRadius);` (RepairTurret.java:142)
draw the circle. The pulse block sits inside the strength
guard (`if(strength > 0.01f){`, RepairTurret.java:129) -- the
same guard the N2219 draw_beam_state already returns as
beam_visible. Time.time is the tick counter (Time.java:15,
`public static float time, globalTime;`, 60fps units).

RED decisions (resolved at RED): (1) One pure function on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217 /
N2219-N2227 / N2251 built, reusing the N2251 xorshift helpers
(setSeed / nextLong / nextFloat / random(max) /
random(min, max)) -- the helpers are NOT duplicated here.
(2) The fourth Rand draw is taken as an explicit float param
rand_draw (0..1): the caller supplies the fourth draw, so the
function does not re-seed and invents no building id; the
proof replays the N2251 seeded sequence (seed 10: r1
257.980828 / r2 38.301969 / r3 3.008420 / r4 0.350668) to
show the linkage. (3) pulseStroke / pulseRadius are explicit
params because the per-def values differ (class defaults
pulseRadius 6f / pulseStroke 2f, RepairTurret.java:37-38;
repair-point 5f / repair-turret 6.1f, Blocks.java:6392/6404).
(4) NO driver tick line: with no frame fields for the
absolute tick or the fourth Rand draw, the pulse cannot be
stamped live yet -- the N2219 draw_beam_state still returns
the pre-pulse beam (pulse_stroke only) until a wiring slice
adds those frame fields. (5) The laser drawing itself stays
with N2219: this slice models only the pulse phase (f /
alpha / stroke / circle radius). Four new result symbols: f,
alpha, stroke, circle_radius. Slice sources:
RepairTurret.java + Interp.java + Rand.java + Time.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_draw_beam_jitter import DEFERRED as N2251_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
INTERP = 'arc-core/src/arc/math/Interp.java'
RAND = 'arc-core/src/arc/math/Rand.java'
TIME = 'arc-core/src/arc/util/Time.java'
PROOF = '/root/C07RepairTurretDrawBeamPulseProof'
PULSE_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_draw_beam_pulse_state'
TESTS = ['test_c07_repair_turret_draw_beam_pulse_registration', 'test_all_c07_repair_turret_draw_beam_pulse_input_evidence_is_exact', 'test_repair_turret_draw_beam_pulse_state', 'test_reference_graph_and_actual_c07_repair_turret_draw_beam_pulse']
# The 4 slice sources the N2252 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'arc-core/src/arc/math/Interp.java',
    'arc-core/src/arc/math/Rand.java',
    'arc-core/src/arc/util/Time.java',
]
EXACT_EXPRS = ['public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,', 'float strength, float pulseStroke, float pulseRadius, float beamWidth,', 'if(strength > 0.01f){', 'float f = (Time.time / 85f + rand.random(1f)) % 1f;', 'Draw.alpha(1f - Interp.pow5In.apply(f));', 'Lines.stroke(strength * pulseStroke);', 'Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);', 'PowIn pow5In = new PowIn(5);', 'return (float)Math.pow(a, power);', 'public float random(float max){', 'return nextFloat() * max;', 'public static float time, globalTime;']

# DEFERRED is carried from the N2251 register script via import --
# never retyped. The N2251 script's DEFERRED is a computed
# expression (list comprehension over the N2227 import + [...]),
# (round 3: N2251's chain skips dropped N2247, imports N2227).
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. NOTE for the next
# slice: N2252's DEFERRED is likewise a computed list
# comprehension + [...] expression, so carry it forward by
# import too, not by ast.literal_eval.
# One carried entry is DROPPED here, not carried: the N2251
# entry deferring the RepairTurret drawBeam() pulse phase to
# N2252 -- N2252 IS the pulse slice, so carrying it would leave
# a stale "still deferred" row for done work. Two new entries
# are recorded below: the pulse driver wiring (the pulse is not
# stamped live yet) and the pulse Windows Godot proof debt.
DEFERRED = [e for e in N2251_DEFERRED if 'RepairTurret drawBeam pulse phase' not in e] + [
    'RepairTurret drawBeam pulse driver wiring -- the pulse is NOT stamped live yet: the frame carries no absolute tick or fourth Rand draw, so the N2219 draw_beam_state still returns the pre-pulse beam (pulse_stroke only); wiring waits for a slice that adds those frame fields.',
    'RepairTurret drawBeam pulse Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2227, N2251: the N2252 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    pulse_inputs = {
        'strength': a('float', 'float strength, float pulseStroke, float pulseRadius, float beamWidth,', 'The beam strength (drawBeam param, RepairTurret.java:107, `float strength, float pulseStroke, float pulseRadius, float beamWidth,`): the pulse stroke scales with it (`Lines.stroke(strength * pulseStroke);`, RepairTurret.java:141); passed explicitly because the pure function takes the draw-time strength, not the frame-stamped lerp.'),
        'pulse_stroke': a('float', 'Lines.stroke(strength * pulseStroke);', 'The pulse stroke width (drawBeam param, RepairTurret.java:107): the class default is 2f (RepairTurret.java:38, `public float pulseStroke = 2f;`), overridden by neither def; passed explicitly because the pure function takes the draw-time value.'),
        'pulse_radius': a('float', 'Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);', 'The pulse circle radius (drawBeam param, RepairTurret.java:107): the class default is 6f (RepairTurret.java:37, `public float pulseRadius = 6f;`), repair-point 5f (Blocks.java:6392) / repair-turret 6.1f (Blocks.java:6404); passed explicitly because the per-def values differ.'),
        'time_ticks': a('float', 'public static float time, globalTime;', 'Time.time at draw time (Time.java:15, `public static float time, globalTime;`, the tick counter in 60fps units): the pulse phase is Time.time / 85f (RepairTurret.java:138); passed explicitly because the frame carries no absolute tick yet.', source=TIME),
        'rand_draw': a('float', 'public float random(float max){', 'The fourth Rand draw (RepairTurret.java:138, `rand.random(1f)`): nextFloat() * 1f from the seeded xorshift sequence (Rand.java, `public float random(float max){` / `return nextFloat() * max;`), after the three N2251 jitter draws; passed explicitly because the pure function does not re-seed and invents no building id.', source=RAND),
    }
    pulse_outputs = {
        'f': a('float', 'float f = (Time.time / 85f + rand.random(1f)) % 1f;', 'The pulse phase (RepairTurret.java:138, `float f = (Time.time / 85f + rand.random(1f)) % 1f;`): the tick counter over 85 plus the fourth Rand draw, wrapped mod 1, so f stays in [0, 1).'),
        'alpha': a('float', 'Draw.alpha(1f - Interp.pow5In.apply(f));', 'The pulse circle alpha (RepairTurret.java:140, `Draw.alpha(1f - Interp.pow5In.apply(f));`): Interp.pow5In is PowIn(5) (Interp.java:45, `PowIn pow5In = new PowIn(5);`), apply(a) = pow(a, 5) (Interp.java:119-121, `return (float)Math.pow(a, power);`), so alpha = 1 - f^5.'),
        'stroke': a('float', 'Lines.stroke(strength * pulseStroke);', 'The pulse circle stroke width (RepairTurret.java:141, `Lines.stroke(strength * pulseStroke);`): the strength-scaled pulse stroke.'),
        'circle_radius': a('float', 'Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);', 'The pulse circle radius (RepairTurret.java:142, `Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);`): 1 plus the phase times the pulse radius.'),
    }
    return pulse_inputs, pulse_outputs


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
        total += len(keys)
        for field, meta in keys.items():
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
    pulse_inputs, pulse_outputs = definitions()

    entries = [
        ('N2252', PULSE_OWNER, 'source_repair_turret_draw_beam_pulse_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.draw()/drawBeam()', pulse_inputs, pulse_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret drawBeam pulse state from RepairTurret.java + Interp.java + Rand.java + Time.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret drawBeam pulse state from RepairTurret.java + Interp.java + Rand.java + Time.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: f, alpha, stroke,
    # circle_radius.
    by_slice['N2252'] = [
        'source_repair_turret_draw_beam_pulse_state_result.f',
        'source_repair_turret_draw_beam_pulse_state_result.alpha',
        'source_repair_turret_draw_beam_pulse_state_result.stroke',
        'source_repair_turret_draw_beam_pulse_state_result.circle_radius',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2252', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.draw()/drawBeam()', godot_owner=PULSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2252'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
