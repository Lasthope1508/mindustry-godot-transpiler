"""Register the RepairTurret drawBeam jitter rows (N2251).

N2219 captured the deterministic beam state but left the endpoint
PRE-JITTER: the random jitter (`lastEnd.add(offset.trns(` with
`rand.random(360f) + Time.time/2f,` and `Mathf.sin(Time.time +
rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f,
target.hitSize() * 0.45f))`, RepairTurret.java:121-124) needs arc
Rand modeling (rand.setSeed(id + target id),
RepairTurret.java:111) plus Time.time. arc Rand is xorshift128+
(Rand.java: the class doc names the xorshift128+ algorithm, two
long words seed0/seed1, murmurHash3 seeding), deterministic per
call via setSeed; Time.time is the tick counter (Time.java:15,
`public static float time, globalTime;`, 60fps units). The
GDScript int64 xorshift was verified live in Godot BEFORE this
slice was built (throwaway probe N2251RandProbe, deleted after
the run): seed-10 draws r1=257.980828 / r2=38.301969 /
r3=3.008420 / r4=0.350668 and randomSeed-float-max(123, 360) =
348.595226, matching the Python oracle vectors (5/5 pass,
r1=257.9808, r2=38.3020, r3=3.0084, r4=0.35067,
randomSeed(123,360f)=348.5952) to float32-vs-double noise.

RED decisions (resolved at RED): (1) One pure function on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217 /
N2219-N2227 built, plus five xorshift helper statics on that
file (the helper FIRST, per the slice brief): setSeed /
nextLong / nextFloat / random(max) / random(min, max), all
direct int64 xorshift128+ with logical shifts emulated by
masking (GDScript >> is arithmetic, Java >>> is logical).
The existing SourceMathState._source_arc_rand_* helpers are
NOT reused: they are a murmur hash-chain, not xorshift -- they
give 34.82 where the oracle says 348.5952 for
randomSeed(123,360f). (2) The jitter amplitude reuses the
port's canonical table sin, SourceMathState.
source_arc_mathf_sin_scaled (Mathf.sin(radians, scl, mag) =
sin(radians / scl) * mag, Mathf.java:90-91); the two Vec2
rotates use Vector2.rotated, the N2219 exact-trig precedent
(the beam origin already uses cos/sin directly). (3) Pure
functions take explicit params -- building_id, target_id,
time_ticks, target_hit_size, target_rotation_deg -- because the
frame today carries no building id, target id, target rotation
or absolute tick; no id is invented. (4) NO driver tick line:
with no frame fields to feed it, the jitter cannot be stamped
live yet -- the N2219 draw_beam_state still returns the
pre-jitter beam_end until a wiring slice adds those frame
fields. (5) The pulse phase (RepairTurret.java:138,
`float f = (Time.time / 85f + rand.random(1f)) % 1f;`) is a
separate later slice (N2252): it is the FOURTH draw from the
SAME seeded Rand sequence, after the three jitter draws, so it
must reuse this slice's sequence, not re-seed. Six new result
symbols: rand_angle_draw, rand_time_draw, rand_hit_draw,
jitter_angle_deg, jitter_amplitude, jitter_offset. Slice
sources: RepairTurret.java + Rand.java + Mathf.java + Vec2.java
+ Time.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
RAND = 'arc-core/src/arc/math/Rand.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
VEC2 = 'arc-core/src/arc/math/geom/Vec2.java'
TIME = 'arc-core/src/arc/util/Time.java'
PROOF = '/root/C07RepairTurretDrawBeamJitterProof'
JITTER_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_draw_beam_jitter_state'
TESTS = ['test_c07_repair_turret_draw_beam_jitter_registration', 'test_all_c07_repair_turret_draw_beam_jitter_input_evidence_is_exact', 'test_repair_turret_draw_beam_jitter_state', 'test_reference_graph_and_actual_c07_repair_turret_draw_beam_jitter']
# The 5 slice sources the N2251 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'arc-core/src/arc/math/Rand.java',
    'arc-core/src/arc/math/Mathf.java',
    'arc-core/src/arc/math/geom/Vec2.java',
    'arc-core/src/arc/util/Time.java',
]
EXACT_EXPRS = ['public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,', 'rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));', 'if(target != null){', 'lastEnd.add(offset.trns(', 'rand.random(360f) + Time.time/2f,', 'Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))', ').rotate(target instanceof Rotc rot ? rot.rotation() : 0f));', 'public long nextLong(){', 's1 ^= s1 << 23;', 'return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;', 'long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE : seed);', 'x ^= x >>> 33;', 'x *= 0xff51afd7ed558ccdL;', 'x *= 0xc4ceb9fe1a85ec53L;', 'public float nextFloat(){', 'return (float)((nextLong() >>> 40) * NORM_FLOAT);', 'public float random(float max){', 'return nextFloat() * max;', 'public float random(float min, float max){', 'return min + (max - min) * nextFloat();', 'public static float sin(float radians, float scl, float mag){', 'return sin(radians / scl) * mag;', 'public Vec2 trns(float angle, float amount){', 'return set(amount, 0).rotate(angle);', 'public Vec2 rotate(float degrees){', 'public static float time, globalTime;']

# DEFERRED is carried from the N2227 register script via import --
# never retyped. The N2227 script's DEFERRED is a computed
# expression (list comprehension over the N2226 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. Round 3: the N2247
# (ex-N2229) senseObject(config) register is DROPPED -- remote
# N2234 covers that leg -- so the chain skips it and imports
# N2227 directly. NOTE for the next slice: N2251's DEFERRED is
# likewise a computed list comprehension + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
# One carried entry is DROPPED here, not carried: the N2227
# entry deferring the RepairTurret drawBeam() jitter/pulse to a
# Rand-modeling slice -- N2251 IS the jitter slice, so carrying
# it would leave a stale "still deferred" row for done work. The
# pulse half is re-recorded below as its own entry, since the
# pulse phase still waits for N2252.
DEFERRED = [e for e in N2227_DEFERRED if 'RepairTurret drawBeam() jitter/pulse' not in e] + [
    'RepairTurret drawBeam pulse phase (RepairTurret.java:138, `float f = (Time.time / 85f + rand.random(1f)) % 1f;`, :140 `Draw.alpha(1f - Interp.pow5In.apply(f));`, :142 `Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);`) -- the FOURTH Rand draw from the SAME seeded sequence as the N2251 jitter draws, so N2252 must reuse this slice\'s Rand state, not re-seed; pulseRadius per-def repair-point 5f / repair-turret 6.1f (Blocks.java:6391/6405), class default 6f (RepairTurret.java:37) -- no pulse-circle radius key exists yet.',
    'RepairTurret drawBeam jitter driver wiring -- the jitter is NOT stamped live yet: the frame carries no building id, target id, target rotation or absolute tick, so the N2219 draw_beam_state still returns the pre-jitter beam_end; wiring waits for a slice that adds those frame fields.',
    'RepairTurret drawBeam jitter Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2227: the N2251 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    jitter_inputs = {
        'building_id': a('int', 'rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));', 'The building entity id (RepairTurret.java:111, `rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));`): the first half of the Rand seed; passed explicitly because the frame carries no building id yet -- no id is invented.'),
        'target_id': a('int', 'rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));', 'The target entity id (RepairTurret.java:111, `rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));`): the second half of the Rand seed (0 when the target is not an Entityc); passed explicitly because the frame carries no target id yet.'),
        'time_ticks': a('float', 'rand.random(360f) + Time.time/2f,', 'Time.time at draw time (Time.java:15, `public static float time, globalTime;`, the tick counter in 60fps units): the jitter angle is rand.random(360f) + Time.time/2f (RepairTurret.java:122); passed explicitly because the frame carries no absolute tick yet.'),
        'target_hit_size': a('float', 'rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f)', 'The target hitSize (Sized.hitSize(), Sized.java:6): the third Rand draw ranges over hitSize * 0.2f to hitSize * 0.45f (RepairTurret.java:123); passed explicitly because the frame carries no target hitSize yet.'),
        'target_rotation_deg': a('float', ').rotate(target instanceof Rotc rot ? rot.rotation() : 0f));', 'The target rotation in degrees (RepairTurret.java:124, `).rotate(target instanceof Rotc rot ? rot.rotation() : 0f));`): the jitter offset rotates by the target rotation when the target is a Rotc, else 0f; passed explicitly because the frame carries no target rotation yet.'),
    }
    jitter_outputs = {
        'rand_angle_draw': a('float', 'rand.random(360f) + Time.time/2f,', 'The first Rand draw (RepairTurret.java:122, `rand.random(360f) + Time.time/2f,`): nextFloat() * 360f from the seeded xorshift sequence (Rand.java, `public float random(float max){` / `return nextFloat() * max;`).'),
        'rand_time_draw': a('float', 'Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))', 'The second Rand draw (RepairTurret.java:123, `Time.time + rand.random(200f)`): nextFloat() * 200f from the seeded xorshift sequence, the time offset inside the table-sin amplitude.'),
        'rand_hit_draw': a('float', 'rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f)', 'The third Rand draw (RepairTurret.java:123, `rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f)`): the magnitude of the table-sin amplitude, ranging over hitSize * 0.2f to hitSize * 0.45f (Rand.java, `public float random(float min, float max){` / `return min + (max - min) * nextFloat();`).'),
        'jitter_angle_deg': a('float', 'rand.random(360f) + Time.time/2f,', 'The jitter angle in degrees (RepairTurret.java:122, `rand.random(360f) + Time.time/2f,`): the first Rand draw plus half the tick counter.'),
        'jitter_amplitude': a('float', 'Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))', 'The jitter amplitude (RepairTurret.java:123, `Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))`): the arc table sin of (Time.time + second draw) / 55f scaled by the third draw (Mathf.java:90-91, `public static float sin(float radians, float scl, float mag){` / `return sin(radians / scl) * mag;`).'),
        'jitter_offset': a('Vector2', 'lastEnd.add(offset.trns(', 'The jitter offset added to the pre-jitter endpoint (RepairTurret.java:121-124, `lastEnd.add(offset.trns(` ... `).rotate(target instanceof Rotc rot ? rot.rotation() : 0f));`): Vec2.trns(angle, amplitude) -- set(amplitude, 0) rotated by the jitter angle (Vec2.java, `public Vec2 trns(float angle, float amount){` / `return set(amount, 0).rotate(angle);`) -- then rotated by the target rotation.'),
    }
    return jitter_inputs, jitter_outputs


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
    jitter_inputs, jitter_outputs = definitions()

    entries = [
        ('N2251', JITTER_OWNER, 'source_repair_turret_draw_beam_jitter_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.draw()/drawBeam()', jitter_inputs, jitter_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret drawBeam jitter state from RepairTurret.java + Rand.java + Mathf.java + Vec2.java + Time.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret drawBeam jitter state from RepairTurret.java + Rand.java + Mathf.java + Vec2.java + Time.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rand_angle_draw, rand_time_draw,
    # rand_hit_draw, jitter_angle_deg, jitter_amplitude,
    # jitter_offset.
    by_slice['N2251'] = [
        'source_repair_turret_draw_beam_jitter_state_result.rand_angle_draw',
        'source_repair_turret_draw_beam_jitter_state_result.rand_time_draw',
        'source_repair_turret_draw_beam_jitter_state_result.rand_hit_draw',
        'source_repair_turret_draw_beam_jitter_state_result.jitter_angle_deg',
        'source_repair_turret_draw_beam_jitter_state_result.jitter_amplitude',
        'source_repair_turret_draw_beam_jitter_state_result.jitter_offset',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2251', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.draw()/drawBeam()', godot_owner=JITTER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2251'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
