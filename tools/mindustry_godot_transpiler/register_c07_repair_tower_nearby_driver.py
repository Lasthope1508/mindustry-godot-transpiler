"""Register the RepairTower Units.nearby driver integration (N2211).

N2210 ported the live query that produces the
`nearby_damaged_units` observation
(source_units_nearby_damaged_count_state, the Units.nearby
circle overload, Units.java:445) but wired NO driver tick line
to call it (the N2208/N2209 precedent: a query, not a tick
write), so the N2190 refresh still reads a stale or absent
observation and the N2191 shouldConsume gate still reads a
stale or absent `targets_count`. N2211 is the driver
integration and nothing else: one tick line in the existing
source_repair_tower_tick_buildings_state that calls the N2210
pure function and stamps `nearby_damaged_units` live on the
RepairTower frame, so the refresh block
(`if(potentialEfficiency > 0 && (refresh += Time.delta) >=
refreshInterval){`, RepairTower.java:59) consumes a live
observation at every expiry (`targets.clear();` /
`refresh = 0f;` / `Units.nearby(team, x, y, range, u -> {` /
`if(u.damaged()){` / `targets.add(u);`,
RepairTower.java:60-64).

RED decisions (pinned by this slice): (1) The query runs only
while potentialEfficiency > 0 (the Java gate,
RepairTower.java:59, read from the frame key this tick's
updateConsumption just stamped -- `potentialEfficiency =
efficiency;`, BuildingComp.java:1989 -- so at no power no
observation is stamped and the refresh cannot fire anyway).
(2) The units list is the frame's `units` key
(`frame.get("units", [])`, the N2141/N2144 precedent -- no
live units list is stamped on any frame yet, so the count stays
0 until a unit-list slice lands). (3) The centre is the tower's
world position (`sprite.position`, the turret-targeting
precedent, SourceTurretCombatState.gd:96 -- Java passes the
Building's own x, y). (4) The radius is the per-def range
(`block.properties.get("range", 80.0)` -- 100f for
unit-repair-tower, `range = 100f;`, Blocks.java:6579, falling
back to the class default `public float range = 80f;`,
RepairTower.java:21). (5) The query runs every powered tick,
not only on refresh expiry (Java evaluates it inside the expiry
branch -- the stamped count at expiry is the same value Java
computes, because the refresh consumes the current tick's
observation; the only cost is the per-tick query on non-expiry
ticks). (6) The call sits INSIDE the existing `if
has_power_consumer and enabled and not cheating:` block, AFTER
`apply_update_consumption_state` (the Java order,
updateConsumption :2274 before updateTile :2277) and BEFORE the
refresh call. One new result symbol: the driver-stamped
observation itself, owned by the tick function (the N2109/N2103
precedent: tick-function result symbols). No new pure function,
no new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS
change, no simulate_factory wiring change. Shard note:
RepairTower.java lives under /world/blocks/units/ and no shard
selection is expected to match it (the N2188/N2209 precedent),
so the GREEN register run must record that no source_modules
shard changes -- the generic loop below only touches
api_contracts shards whose selected owners intersect the new
owner.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_units_nearby import DEFERRED as _N2210_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
UNITS = 'core/src/mindustry/entities/Units.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07RepairTowerNearbyDriverProof'
OWNER = 'SourceRepairTowerBuildState.source_repair_tower_tick_buildings_state'
TESTS = ['test_c07_repair_tower_nearby_driver_registration', 'test_all_c07_repair_tower_nearby_driver_input_evidence_is_exact', 'test_repair_tower_nearby_driver_state', 'test_reference_graph_and_actual_c07_repair_tower_nearby_driver']
# The 6 slice sources the N2211 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/entities/Units.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = ['static final float refreshInterval = 6f;', 'public float range = 80f;', 'range = 100f;', 'public void updateTile(){', 'if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', 'targets.clear();', 'refresh = 0f;', 'Units.nearby(team, x, y, range, u -> {', 'if(u.damaged()){', 'targets.add(u);', 'public boolean shouldConsume(){', 'return targets.size > 0;', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'nearby(team, x - radius, y - radius, radius*2f, radius*2f, unit -> {', 'if(unit.within(x, y, radius + unit.hitSize/2f)){', 'cons.get(unit);', 'boolean damaged(){', 'return health < maxHealth - 0.001f;', 'public final Building newBuilding(){', 'return efficiency * delta();', 'potentialEfficiency = efficiency;', 'public void updateConsumption(){']

# DEFERRED is carried from the N2210 register script via import --
# never retyped. The N2210 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2209 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2211's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(_N2210_DEFERRED) + [
    'RepairTower Units.nearby driver integration Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2210: the N2211 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2211_inputs = {
        'game': f('Object', 'public final Building newBuilding(){', 'The game object carrying the placed buildings (Block.java:1002, `public final Building newBuilding();` -- the tick iterates the placed RepairTower builds through the live loop, exactly as the N2109 factory tick does).', source=BLOCK),
        'seconds': f('float', 'return efficiency * delta();', 'The tick delta in seconds (BuildingComp.java:1928, `return efficiency * delta();` -- edelta is efficiency * delta, so the tick seconds is Time.delta, the same delta the refresh block accumulates).', source=BUILDING_COMP),
    }
    n2211_outputs = {
        'nearby_damaged_units': f('int', 'Units.nearby(team, x, y, range, u -> {', 'The live count of damaged units in range, stamped on the RepairTower frame (RepairTower.java:62, `Units.nearby(team, x, y, range, u -> {` -- the query the refresh block runs on expiry; the driver stamps the N2210 pure function result so the refresh consumes a live observation and the N2191 gate reads a live targets_count).'),
    }
    return n2211_inputs, n2211_outputs


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
    n2211_inputs, n2211_outputs = definitions()

    entries = [
        ('N2211', OWNER, 'source_repair_tower_tick_buildings_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.updateTile()', n2211_inputs, n2211_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower Units.nearby driver integration from RepairTower.java / Units.java / HealthComp.java / Blocks.java / Block.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower Units.nearby driver integration from RepairTower.java / Units.java / HealthComp.java / Blocks.java / Block.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the driver-stamped observation, the slice's only result key.
    by_slice['N2211'] = [
        'source_repair_tower_tick_buildings_state_result.nearby_damaged_units',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2211', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2211'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
