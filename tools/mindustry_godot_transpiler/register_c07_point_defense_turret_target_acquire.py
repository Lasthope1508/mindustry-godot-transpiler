"""Register the PointDefenseTurret target acquisition (N2239).

N2151 wired the power.status live read but deferred the
updateTile advance ("No updateTile advance:
PointDefenseBuild.updateTile()
(PointDefenseTurret.java:62-103, retarget / rotation /
reloadCounter / beam effects) waits for its own slice;
the proof carries no progress keys"). This slice is the
first half of that advance -- the retarget: every
retargetTime (5s) the build re-acquires the nearest
enemy hittable bullet in the range rect
(`if(timer(timerTarget, retargetTime)){` /
`target = Groups.bullet.intersect(x - range, y -
range, range*2, range*2).min(b -> b.team != team &&
b.type().hittable, b -> b.dst2(this));`,
PointDefenseTurret.java:65-67), and a pooled bullet
is nulled (`if(target != null &&
!target.isAdded()){` / `target = null;`,
PointDefenseTurret.java:69-71). The aim / rotation /
reloadCounter / shoot half (PointDefenseTurret.java:
76-101) is NOT this slice -- it waits for its own
slice (the RepairTurret N2212/N2215 split
precedent: target acquisition is the smallest
coherent slice here).

RED decisions (pinned by this slice): (1) One pure
function on SourcePointDefenseTurretBuildState.gd,
source_point_defense_turret_target_acquire_state(frame,
observed_bullets, team_id, x, y, range, delta),
returning `{"target": ..., "has_target": ...,
"target_timer": ..., "reacquired": ...}`, plus one
driver tick line that stamps the acquired target live
(the N2212 precedent). Four new result symbols:
target + has_target + target_timer + reacquired.
(2) The timer is a per-frame accumulator starting
at 0.0 (absent -> 0.0), firing at >= 5.0 and resetting
to 0.0 -- the Interval.get model (Interval.java:29,
`return Time.time - times[id] >= time || Time.time <
times[id];`, times[] init 0, so the first fire is at
Time.time >= 5; reset-to-0 drops overshoot exactly
like Interval.get stamping Time.time); the re-acquire
replaces the target unconditionally on fire, even a
still-valid one. (3) The invalidation reads the
CURRENT bullet record: the stored target is looked up
by `id` in the observed list (the stored dict is a
snapshot, Java holds a live reference over `public
@Nullable Bullet target;`, PointDefenseTurret.java:60;
a target whose id is absent from the list is pooled,
so it is dropped, and a stored target with no id
cannot be re-identified, so it is dropped too -- the
RepairTurret N2212 precedent). (4) The re-acquire is
a point-in-rect test against the Java intersect rect
(x +/- range, y +/- range, range 180f per-def,
Blocks.java:3838, `range = 180f;`, the only
PointDefenseTurret def) with a min-dst2 pick; ties
keep the first bullet (strict `<`, the N2212
precedent). The port models no bullet hitSize, so the
rect overlap is approximated by the bullet point, a
documented limit owned by a later bullet-hitSize
slice (the ShockwaveTower precedent). (5) The driver
stamps target / has_target / target_timer on the
frame every tick, UNCONDITIONAL on power/enabled/
cheating (Java updateTile runs regardless -- only the
aim/shoot half needs efficiency), but ONLY once a
caller provides `observed_bullets` on the frame: the
live `game["bullets"]` dicts carry no team/hittable/id
yet, so the driver maps them in a later wiring step
and stamps nothing until then (the N2190 finding).
(6) No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. The lumped deferred
entry "PointDefenseTurret updateTile advance /
shouldConsume gate; TractorBeamTurret ..." is NOT
dropped here: N2239 is only the retarget half, the
aim/shoot half + shouldConsume gate + coolant still
wait, and TractorBeam is untouched. Shard note:
PointDefenseTurret.java lives under
/world/blocks/defense/turrets/ and no shard
selection is expected to match it (the N2211-N2238
precedent), so the GREEN register run must record
that no source_modules shard changes. SSOT expected
after GREEN: symbols +4, Done +1, contracts +1,
schema +2, 11540/1688/1619/3029 -> 11544/1689/
1620/3031.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_tower_per_def_stats import DEFERRED as N2238_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
INTERVAL = 'arc-core/src/arc/util/Interval.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
GROUP_DEFS = 'core/src/mindustry/entities/GroupDefs.java'
PROOF = '/root/C07PointDefenseTurretTargetAcquireProof'
ACQUIRE_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_target_acquire_state'
TESTS = ['test_c07_point_defense_turret_target_acquire_registration', 'test_all_c07_point_defense_turret_target_acquire_input_evidence_is_exact', 'test_point_defense_turret_target_acquire_state', 'test_reference_graph_and_actual_c07_point_defense_turret_target_acquire']
# The 5 slice sources the N2239 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files. Groups.java is build-generated from
# GroupDefs.java (@GroupDef(value = Bulletc.class, spatial =
# true, collide = true) G bullet;, GroupDefs.java:9), so it
# never exists on disk: the on-disk source is GroupDefs.java.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/entities/comp/TimerComp.java',
    'arc-core/src/arc/util/Interval.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/GroupDefs.java',
]
EXACT_EXPRS = ['public final int timerTarget = timers++;', 'public float retargetTime = 5f;', 'public @Nullable Bullet target;', 'if(timer(timerTarget, retargetTime)){', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'if(target != null && !target.isAdded()){', 'target = null;', 'return super.shouldConsume() && target != null;', 'transient Interval timer = new Interval(6);', 'public boolean timer(int index, float time){', 'if(got) times[id] = Time.time;', 'return Time.time - times[id] >= time || Time.time < times[id];', 'segment = new PointDefenseTurret("segment"){{', 'range = 180f;']

# DEFERRED is carried from the N2238 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the aim/shoot half + shouldConsume gate + coolant, and the
# TractorBeam half is untouched. Only the N2239 Windows-proof
# debt entry is appended.
DEFERRED = list(N2238_DEFERRED) + [
    'PointDefenseTurret target acquisition Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2238: the N2239 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    acquire_inputs = {
        'frame': a('Dictionary', 'public @Nullable Bullet target;', 'The turret frame (PointDefenseTurret.java:60, `public @Nullable Bullet target;` -- the frame carries the current target dict and the target timer accumulator; absent keys read the Java field defaults: target null, timer 0.0).'),
        'observed_bullets': a('Array', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'The bullets the re-acquire scans (PointDefenseTurret.java:66 -- the ShockwaveTower N2190 precedent: an Array of Dictionary bullet records with team/hittable/x/y, world coords, plus an `id` so the stored target can be re-identified across ticks; the live `game["bullets"]` dicts carry no team/hittable/id yet, so the driver maps them in a later wiring step).'),
        'team_id': a('int', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'The turret team id (PointDefenseTurret.java:66, `b.team != team` -- the team whose enemy bullets the query scans; the driver reads it from the frame).'),
        'x': a('float', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'The turret x (PointDefenseTurret.java:66 -- the Building x Java passes to the intersect rect; the driver reads sprite.position.x).'),
        'y': a('float', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'The turret y (PointDefenseTurret.java:66 -- the Building y Java passes to the intersect rect; the driver reads sprite.position.y).'),
        'range': a('float', 'range = 180f;', 'The per-def range (segment 180f, Blocks.java:3838, `range = 180f;`, the only PointDefenseTurret def): the half-side of the intersect rect Java queries (PointDefenseTurret.java:66, `x - range, y - range, range*2, range*2`).', source=BLOCKS),
        'delta': a('float', 'return Time.time - times[id] >= time || Time.time < times[id];', 'The tick delta in seconds (Interval.java:29, `return Time.time - times[id] >= time || Time.time < times[id];` -- the timer fires on elapsed game time; the port accumulates the per-tick delta into target_timer and fires at >= 5.0, resetting to 0.0, which drops overshoot exactly like Interval.get stamping Time.time).', source=INTERVAL),
    }
    acquire_outputs = {
        'target': a('Dictionary', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'The target after this tick: the validated previous target, the freshly re-acquired one on a timer fire, or null (PointDefenseTurret.java:69-71 nulls it when pooled, :66 re-acquires it on fire).'),
        'has_target': a('bool', 'return super.shouldConsume() && target != null;', 'Whether the turret has a target after this tick -- the observation the future shouldConsume gate reads (PointDefenseTurret.java:105-107, `return super.shouldConsume() && target != null;`).'),
        'target_timer': a('float', 'return Time.time - times[id] >= time || Time.time < times[id];', 'The timer accumulator after this tick, 0.0 on a fire (Interval.java:29 -- the port mirror of the per-building Interval slot for timerTarget, PointDefenseTurret.java:20).', source=INTERVAL),
        'reacquired': a('bool', 'if(timer(timerTarget, retargetTime)){', 'Whether the 5s timer fired and re-ran the query this tick (PointDefenseTurret.java:65, `if(timer(timerTarget, retargetTime)){`).'),
    }
    return acquire_inputs, acquire_outputs


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
    acquire_inputs, acquire_outputs = definitions()

    entries = [
        ('N2239', ACQUIRE_OWNER, 'source_point_defense_turret_target_acquire_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.updateTile()', acquire_inputs, acquire_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret target acquisition from PointDefenseTurret.java / TimerComp.java / Interval.java / Blocks.java / GroupDefs.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret target acquisition from PointDefenseTurret.java / TimerComp.java / Interval.java / Blocks.java / GroupDefs.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: target, has_target,
    # target_timer, reacquired.
    by_slice['N2239'] = [
        'source_point_defense_turret_target_acquire_state_result.target',
        'source_point_defense_turret_target_acquire_state_result.has_target',
        'source_point_defense_turret_target_acquire_state_result.target_timer',
        'source_point_defense_turret_target_acquire_state_result.reacquired',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2239', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.updateTile()', godot_owner=ACQUIRE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2239'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
