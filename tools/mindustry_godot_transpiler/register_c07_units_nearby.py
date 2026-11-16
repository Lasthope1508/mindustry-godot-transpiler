"""Register the Units.nearby live query (N2210).

The live query that produces the `nearby_damaged_units`
observation N2190's RepairTower refresh consumes. The refresh
block (`if(potentialEfficiency > 0 && (refresh += Time.delta)
>= refreshInterval){`, RepairTower.java:59) clears the targets
(`targets.clear();`, RepairTower.java:60), resets the timer
(`refresh = 0f;`, RepairTower.java:61) and re-queries
(`Units.nearby(team, x, y, range, u -> {`,
RepairTower.java:62) for damaged units (`if(u.damaged()){`,
RepairTower.java:63 / `targets.add(u);`,
RepairTower.java:64). The circle overload (`public static
void nearby(@Nullable Team team, float x, float y, float
radius, Cons<Unit> cons){`, Units.java:445) first intersects
the rect (`nearby(team, x - radius, y - radius, radius*2f,
radius*2f, unit -> {`, Units.java:446) then keeps only units
within the effective radius (`if(unit.within(x, y, radius +
unit.hitSize/2f)){`, Units.java:449). The rect overload
(`public static void nearby(@Nullable Team team, float x,
float y, float width, float height, Cons<Unit> cons){`,
Units.java:434) filters by team: a non-null team reads only
that team's tree (`team.data().tree().intersect(x, y, width,
height, cons);`, Units.java:436), a null team reads every
present team's tree (`for(var other : state.teams.present){`,
Units.java:438 / `other.tree().intersect(x, y, width, height,
cons);`, Units.java:439). Damaged is the HealthComp predicate
(`boolean damaged(){`, HealthComp.java:47 / `return health <
maxHealth - 0.001f;`, HealthComp.java:48) -- health strictly
below maxHealth minus 0.001, NOT plain `health < maxHealth`.

RED decisions (pinned by this slice): (1) The pure function
lives on SourceUnitRuntimeState.gd (the N2140 precedent:
Units.* statics live there) as
source_units_nearby_damaged_count_state(units, team_id, x, y,
radius) and returns the single-key dict
`{"nearby_damaged_units": count}` -- the int observation the
N2190 refresh reads via `int(observed)`; no unit list is
returned (the targets list on the tower frame is the later
integration slice's business). (2) Team filter: team_id null
reads ALL teams, an int reads only that team -- the @Nullable
Team of the rect overload. (3) Circle test: the rect
pre-filter (unit hitbox overlapping the query rect,
QuadTree.intersect over `rect.setCentered(x, y, hitSize,
hitSize);`, HitboxComp.java:65-67, with the STRICT overlap
`return x < rx + rwidth && x + width > rx && y < ry +
rheight && y + height > ry;`, Rect.java:274-276 -- i.e.
|dx| < radius + hitSize/2 and |dy| < radius + hitSize/2) is
kept as the cheap early skip Java performs, but the circle
test subsumes it (dst2 < (radius + hitSize/2)^2 implies
both), so the rect can never change the count; the circle
test itself is STRICT (`return Mathf.dst2(getX(), getY(), x,
y) < dst*dst;`, Position.java:44-46): a unit exactly on the
effective radius is NOT counted. (4) Damaged predicate:
`health < maxHealth - 0.001f` exactly (HealthComp.java:48).
(5) Absent-key defaults follow the Java field defaults:
`team_id` -1 (matches no team when the filter is set), `x` /
`y` 0.0, `hit_size` 6.0 (the UnitType default, `hitSize =
6f,`, UnitType.java:70 -- `this.hitSize = type.hitSize;`,
UnitComp.java:536), `health` 0.0 (no initializer,
HealthComp.java:11 `float health;`), `max_health` 1.0
(`transient float maxHealth = 1f;`, HealthComp.java:13) -- so
a record with no health observation counts as damaged (0.0 <
1.0 - 0.001). (6) NO driver tick line for this function: no
driver can supply a live units list (the N2190 finding --
PortGame.gd exposes no unit-listing accessor,
SourceTeamsRuntimeState teams carry empty "units" arrays,
SourceEnemyUnitRuntimeState holds enemy dicts of the wrong
team), so the integration that calls the query is its own
later slice -- the N2208/N2209 precedent. No new frame meta
key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: Units.java lives
under /entities/ and RepairTower.java under
/world/blocks/units/ and no shard selection is expected to
match them (the N2188/N2209 precedent), so the GREEN register
run must record that no source_modules shard changes -- the
generic loop below only touches api_contracts shards whose
selected owners intersect the new owner.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_turret_coolant import DEFERRED as _N2209_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
UNITS = 'core/src/mindustry/entities/Units.java'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
PROOF = '/root/C07UnitsNearbyProof'
OWNER = 'SourceUnitRuntimeState.source_units_nearby_damaged_count_state'
TESTS = ['test_c07_units_nearby_registration', 'test_all_c07_units_nearby_input_evidence_is_exact', 'test_units_nearby_damaged_count_state', 'test_reference_graph_and_actual_c07_units_nearby']
# The 5 slice sources the N2210 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/entities/Units.java',
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'core/src/mindustry/type/UnitType.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
]
EXACT_EXPRS = ['public static void nearby(@Nullable Team team, float x, float y, float width, float height, Cons<Unit> cons){', 'if(team != null){', 'team.data().tree().intersect(x, y, width, height, cons);', 'for(var other : state.teams.present){', 'other.tree().intersect(x, y, width, height, cons);', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'nearby(team, x - radius, y - radius, radius*2f, radius*2f, unit -> {', 'if(unit.within(x, y, radius + unit.hitSize/2f)){', 'cons.get(unit);', 'public class RepairTowerBuild extends Building implements Ranged{', 'static final float refreshInterval = 6f;', 'public float range = 80f;', 'targets.clear();', 'refresh = 0f;', 'Units.nearby(team, x, y, range, u -> {', 'if(u.damaged()){', 'targets.add(u);', 'public boolean shouldConsume(){', 'return targets.size > 0;', 'if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', 'boolean damaged(){', 'return health < maxHealth - 0.001f;', 'transient float maxHealth = 1f;', 'hitSize = 6f,', '@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;', 'this.hitSize = type.hitSize;']

# DEFERRED is carried from the N2209 register script via import --
# never retyped. The N2209 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2188 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2210's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# Units.nearby query itself is NOT carried as deferred: it is THIS
# slice (N2210) -- the inherited N2190 entry still names it as
# waiting, which is stale history, superseded by this slice (the
# driver integration that CALLS the query still waits for its own
# slice, as this script's docstring records).
DEFERRED = list(_N2209_DEFERRED) + [
    'Units.nearby Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2209: the N2210 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=UNITS, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2210_inputs = {
        'units': f('Array', 'team.data().tree().intersect(x, y, width, height, cons);', 'The units the query scans (Units.java:436, `team.data().tree().intersect(x, y, width, height, cons);` -- the rect overload materialized as an Array of Dictionary unit records, the N2141 pattern; non-Dictionary entries are skipped). The caller supplies the enumeration; no driver stamps a live units list on any frame yet (the N2190 finding).'),
        'team_id': f('Variant', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'The team filter (Units.java:445, `@Nullable Team team`): null reads ALL teams (the null branch of the rect overload, Units.java:438-440), an int reads only that team (Units.java:436).'),
        'x': f('float', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'The query centre x (Units.java:445) -- the tower x the caller passes in.'),
        'y': f('float', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'The query centre y (Units.java:445) -- the tower y the caller passes in.'),
        'radius': f('float', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'The query radius (Units.java:445) -- the tower range the caller passes in (RepairTower class default `public float range = 80f;`, RepairTower.java:21).'),
    }
    n2210_outputs = {
        'nearby_damaged_units': f('int', 'cons.get(unit);', 'The count of damaged units in range (Units.java:450, `cons.get(unit);` -- one cons.get call per unit the circle test yields; the count is the number of units the query yields to the damaged filter, i.e. targets.size after the RepairTower refresh block, RepairTower.java:59-66). This is the `nearby_damaged_units` observation the N2190 refresh reads via `int(observed)`.'),
    }
    return n2210_inputs, n2210_outputs


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
    inputs, outputs = definitions()
    for keys in [inputs, outputs]:
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + len(inputs) + len(outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    n2210_inputs, n2210_outputs = definitions()

    entries = [
        ('N2210', OWNER, 'source_units_nearby_damaged_count_state', UNITS, 'mindustry.entities.Units', 'Units.nearby(Team, float, float, float, Cons)', n2210_inputs, n2210_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Units.nearby live query from Units.java / RepairTower.java / HealthComp.java / UnitType.java / UnitComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Units.nearby live query from Units.java / RepairTower.java / HealthComp.java / UnitType.java / UnitComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the nearby damaged count, the slice's only result key.
    by_slice['N2210'] = [
        'source_units_nearby_damaged_count_state_result.nearby_damaged_units',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2210', dict(status='done', java_source=UNITS, java_class='mindustry.entities.Units', java_method='Units.nearby(Team, float, float, float, Cons)', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2210'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
