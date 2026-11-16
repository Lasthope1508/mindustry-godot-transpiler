"""Register the RepairTurret target acquisition (N2212).

N2188 wired the shouldConsume gate on the live `has_target`
observation but no slice stamped it yet ("The gate activates
when the future target-acquisition slice stamps `has_target`
from `Units.closest(team, x, y, repairRadius, Unit::damaged)`
(RepairTurret.java:216) plus the null-out conditions
(RepairTurret.java:193-195)"); N2209 then ported the coolant
multiplier the heal advance multiplies by. This slice is the
target acquisition itself: RepairPointBuild.updateTile nulls
the target when it dies, walks out of range, or is fully
healed (`if(target != null && (target.dead() ||
target.dst(this) - target.hitSize/2f > repairRadius ||
target.health() >= target.maxHealth())){` /
`target = null;`, RepairTurret.java:193-195), zeroes the beam
offset when there is no target (`if(target == null){` /
`offset.setZero();`, RepairTurret.java:197-199), and
re-acquires every 20s through the closest damaged ally in
range (`if(timer(timerTarget, 20)){` /
`rect.setSize(repairRadius * 2).setCenter(x, y);` /
`target = Units.closest(team, x, y, repairRadius,
Unit::damaged);`, RepairTurret.java:214-217).
Units.closest (the range overload, Units.java:358) runs the
circle nearby (`nearby(team, x, y, range, e -> {`,
Units.java:363), keeps only valid damaged units
(`if(!e.isValid() || !predicate.get(e)) return;`,
Units.java:364), and takes the minimum squared distance
(`float dist = e.dst2(x, y);` /
`if(result == null || dist < cdist){` / `result = e;` /
`cdist = dist;`, Units.java:366-369). The heal advance
itself (angle gate, `target.heal(...)`, rotation slerp,
strength lerp, RepairTurret.java:200-212) is NOT this slice
-- it waits for its own slice (the N2188/N2202 split
precedent: target acquisition is the smallest coherent slice
here).

RED decisions (pinned by this slice): (1) Two pure
functions: the Units query lives on SourceUnitRuntimeState.gd
(the N2210 precedent: Units.* statics live there) as
source_units_closest_damaged_state(units, team_id, x, y,
radius) returning `{"target": <unit dict or null>,
"has_target": bool}`, and the acquire lives on
SourceRepairTurretBuildState.gd as
source_repair_turret_target_acquire_state(frame, units,
team_id, x, y, repair_radius, delta) returning `{"target":
..., "has_target": ..., "target_timer": ...,
"offset": Vector2, "reacquired": ...}`. (2) The query's
circle test is the N2210 one (`if(unit.within(x, y, radius +
unit.hitSize/2f)){`, Units.java:449, STRICT dst2 < (radius +
hitSize/2)^2, with the rect pre-filter as the cheap early
skip); isValid is `!dead && isAdded()`
(HealthComp.java:16-18) but listed units are present by
construction, so the port checks only `dead` (absent ->
false); damaged is `health < maxHealth - 0.001f`
(HealthComp.java:48); ties keep the first unit (strict `<`,
Units.java:367). (3) The acquire validates the CURRENT
unit record: the stored target is looked up by `id` in the
units list (the stored dict is a snapshot, Java holds a live
reference; a target whose id is absent from the list is
gone, so it is dropped, and a stored target with no id
cannot be re-identified, so it is dropped too); the health
check is PLAIN `health >= maxHealth` (no 0.001 epsilon,
unlike damaged()); the distance check is Euclidean dst minus
hitSize/2, STRICTLY greater than repairRadius. (4) The
timer is a per-frame accumulator starting at 0.0 (absent ->
0.0), firing at >= 20.0 and resetting to 0.0 -- the
Interval.get model (Interval.java: `return Time.time -
times[id] >= time || Time.time < times[id];`, times[] init
0, so the first fire is at Time.time >= 20; reset-to-0
drops overshoot exactly like Interval.get stamping
Time.time); the re-acquire replaces the target
unconditionally on fire, even a still-valid one. (5) The
driver stamps target / has_target / target_timer / offset
on the frame every tick, UNCONDITIONAL on power/enabled/
cheating: Java updateTile runs regardless -- only the heal
needs efficiency > 0 (RepairTurret.java:203); the radius is
per-def (repair-point 60f, repair-turret 145f,
Blocks.java:6388/6400; class default 50f,
RepairTurret.java:31 -- the catalog carries no repairRadius,
so the driver resolves it from the block id, the N2209
per-def-param precedent). (6) No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory
wiring change. Shard note: RepairTurret.java lives under
/world/blocks/units/ and Units.java under /entities/, and no
shard selection is expected to match them (the N2188/N2209
precedent), so the GREEN register run must record that no
source_modules shard changes -- the generic loop below only
touches api_contracts shards whose selected owners intersect
the new owners.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_tower_nearby_driver import DEFERRED as _N2211_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
UNITS = 'core/src/mindustry/entities/Units.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
INTERVAL = 'arc-core/src/arc/util/Interval.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
PROOF = '/root/C07RepairTurretTargetAcquireProof'
QUERY_OWNER = 'SourceUnitRuntimeState.source_units_closest_damaged_state'
ACQUIRE_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_target_acquire_state'
TESTS = ['test_c07_repair_turret_target_acquire_registration', 'test_all_c07_repair_turret_target_acquire_input_evidence_is_exact', 'test_repair_turret_target_acquire_state', 'test_reference_graph_and_actual_c07_repair_turret_target_acquire']
# The 8 slice sources the N2212 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/entities/Units.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'core/src/mindustry/entities/comp/TimerComp.java',
    'arc-core/src/arc/util/Interval.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/type/UnitType.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
]
EXACT_EXPRS = ['public class RepairTurret extends Block{', 'public float repairRadius = 50f;', 'public int timerTarget = timers++;', 'public Unit target;', 'public Vec2 offset = new Vec2(), lastEnd = new Vec2();', 'public void updateTile(){', 'if(target != null && (target.dead() || target.dst(this) - target.hitSize/2f > repairRadius || target.health() >= target.maxHealth())){', 'target = null;', 'if(target == null){', 'offset.setZero();', 'if(timer(timerTarget, 20)){', 'rect.setSize(repairRadius * 2).setCenter(x, y);', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'public boolean shouldConsume(){', 'return target != null && enabled;', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'public static Unit closest(Team team, float x, float y, float range, Boolf<Unit> predicate){', 'nearby(team, x, y, range, e -> {', 'if(!e.isValid() || !predicate.get(e)) return;', 'float dist = e.dst2(x, y);', 'if(result == null || dist < cdist){', 'result = e;', 'cdist = dist;', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'nearby(team, x - radius, y - radius, radius*2f, radius*2f, unit -> {', 'if(unit.within(x, y, radius + unit.hitSize/2f)){', 'cons.get(unit);', 'boolean damaged(){', 'return health < maxHealth - 0.001f;', 'boolean isValid(){', 'return !dead && isAdded();', 'transient boolean dead;', 'transient float maxHealth = 1f;', 'public boolean timer(int index, float time){', 'if(Float.isInfinite(time)) return false;', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);', 'boolean got = check(id, time);', 'if(got) times[id] = Time.time;', 'return Time.time - times[id] >= time || Time.time < times[id];', 'repairRadius = 60f;', 'repairRadius = 145f;', 'repairPoint = new RepairTurret("repair-point"){{', 'repairTurret = new RepairTurret("repair-turret"){{', 'hitSize = 6f,', '@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;']

# DEFERRED is carried from the N2211 register script via import --
# never retyped. The N2211 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2210 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2212's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# heal advance itself (RepairTurret.java:200-212) is NOT carried
# as deferred here beyond the docstring above -- it waits for its
# own slice, as this script's docstring records.
DEFERRED = list(_N2211_DEFERRED) + [
    'RepairTurret target acquisition Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2211: the N2212 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def q(typ, expr, rule, source=UNITS, **extra):
        return backed(typ, source, expr, rule, **extra)

    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    query_inputs = {
        'units': q('Array', 'team.data().tree().intersect(x, y, width, height, cons);', 'The units the query scans (Units.java:436, `team.data().tree().intersect(x, y, width, height, cons);` -- the rect overload materialized as an Array of Dictionary unit records, the N2141 pattern; non-Dictionary entries are skipped). The caller supplies the enumeration; no driver stamps a live units list on any frame yet (the N2190 finding).'),
        'team_id': q('Variant', 'public static Unit closest(Team team, float x, float y, float range, Boolf<Unit> predicate){', 'The team filter (Units.java:358, `@Nullable Team team` by the nearby overload it calls): null reads ALL teams (the null branch of the rect overload, Units.java:438-440), an int reads only that team (Units.java:436).'),
        'x': q('float', 'public static Unit closest(Team team, float x, float y, float range, Boolf<Unit> predicate){', 'The query centre x (Units.java:358) -- the turret x the caller passes in.'),
        'y': q('float', 'public static Unit closest(Team team, float x, float y, float range, Boolf<Unit> predicate){', 'The query centre y (Units.java:358) -- the turret y the caller passes in.'),
        'radius': q('float', 'public static Unit closest(Team team, float x, float y, float range, Boolf<Unit> predicate){', 'The query radius (Units.java:358) -- the turret repairRadius the caller passes in (class default `public float repairRadius = 50f;`, RepairTurret.java:31).'),
    }
    query_outputs = {
        'target': q('Dictionary', 'result = e;', 'The closest damaged unit in range, or null when none qualifies (Units.java:368, `result = e;` -- the minimum-dst2 unit the lambda keeps; the result the RepairTurret timer block assigns to `target`, RepairTurret.java:216).'),
        'has_target': q('bool', 'return result;', 'Whether a closest damaged unit was found (Units.java:371, `return result;` -- null means no unit passed the valid + damaged + in-range filters).'),
    }
    acquire_inputs = {
        'frame': a('Dictionary', 'public Unit target;', 'The turret frame (RepairTurret.java:154, `public Unit target;` -- the frame carries the current target dict, the target timer accumulator, and the beam offset; absent keys read the Java field defaults).'),
        'units': a('Array', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'The units the re-acquire scans (RepairTurret.java:216 -- the same N2141 Array of Dictionary unit records the query takes; no driver stamps a live units list on any frame yet, the N2190 finding).'),
        'team_id': a('int', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'The turret team id (RepairTurret.java:216, `team` -- the team whose damaged units the query scans; the driver reads it from the frame).'),
        'x': a('float', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'The turret x (RepairTurret.java:216 -- the Building x Java passes to the query; the driver reads sprite.position.x).'),
        'y': a('float', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'The turret y (RepairTurret.java:216 -- the Building y Java passes to the query; the driver reads sprite.position.y).'),
        'repair_radius': a('float', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'The per-def repairRadius (RepairTurret.java:216 -- class default `public float repairRadius = 50f;`, RepairTurret.java:31; repair-point 60f, repair-turret 145f, Blocks.java:6388/6400).'),
        'delta': a('float', 'return Time.time - times[id] >= time || Time.time < times[id];', 'The tick delta in seconds (Interval.java:32, `return Time.time - times[id] >= time || Time.time < times[id];` -- the timer fires on elapsed game time; the port accumulates the per-tick delta into target_timer and fires at >= 20.0, resetting to 0.0, which drops overshoot exactly like Interval.get stamping Time.time).', source=INTERVAL),
    }
    acquire_outputs = {
        'target': a('Dictionary', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);', 'The target after this tick: the validated previous target, the freshly re-acquired one on a timer fire, or null (RepairTurret.java:193-195 nulls it when invalid, :216 re-acquires it on fire).'),
        'has_target': a('bool', 'return target != null && enabled;', 'Whether the turret has a target after this tick -- the observation the N2188 shouldConsume gate reads (RepairTurret.java:222, `return target != null && enabled;`).'),
        'target_timer': a('float', 'return Time.time - times[id] >= time || Time.time < times[id];', 'The timer accumulator after this tick, 0.0 on a fire (Interval.java:32 -- the port mirror of the per-building Interval slot for timerTarget, RepairTurret.java:29).', source=INTERVAL),
        'offset': a('Vector2', 'offset.setZero();', 'The beam offset after this tick: zeroed whenever there is no target (RepairTurret.java:197-199, `if(target == null){` / `offset.setZero();`), otherwise the frame offset carried forward for the heal advance.'),
        'reacquired': a('bool', 'if(timer(timerTarget, 20)){', 'Whether the 20s timer fired and re-ran the query this tick (RepairTurret.java:214, `if(timer(timerTarget, 20)){`).'),
    }
    return query_inputs, query_outputs, acquire_inputs, acquire_outputs


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
    query_inputs, query_outputs, acquire_inputs, acquire_outputs = definitions()

    entries = [
        ('N2212', QUERY_OWNER, 'source_units_closest_damaged_state', UNITS, 'mindustry.entities.Units', 'Units.closest(Team, float, float, float, Boolf)', query_inputs, query_outputs, True, 'Dictionary'),
        ('N2212', ACQUIRE_OWNER, 'source_repair_turret_target_acquire_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.updateTile()', acquire_inputs, acquire_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret target acquisition from RepairTurret.java / Units.java / HealthComp.java / TimerComp.java / Interval.java / Blocks.java / UnitType.java / UnitComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret target acquisition from RepairTurret.java / Units.java / HealthComp.java / TimerComp.java / Interval.java / Blocks.java / UnitType.java / UnitComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the query's target + has_target,
    # then the acquire's target + has_target + target_timer +
    # offset + reacquired.
    by_slice['N2212'] = [
        'source_units_closest_damaged_state_result.target',
        'source_units_closest_damaged_state_result.has_target',
        'source_repair_turret_target_acquire_state_result.target',
        'source_repair_turret_target_acquire_state_result.has_target',
        'source_repair_turret_target_acquire_state_result.target_timer',
        'source_repair_turret_target_acquire_state_result.offset',
        'source_repair_turret_target_acquire_state_result.reacquired',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2212', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.updateTile()', godot_owner=ACQUIRE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2212'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
