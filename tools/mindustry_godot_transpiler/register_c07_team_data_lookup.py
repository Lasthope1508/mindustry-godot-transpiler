"""Register TeamData lookup group (N2390).

TeamData.getBuildings()+getCount()+getUnits()+unitCache()
(Teams.java:318-320 + :322-325 + :418-420 + :422-426,
`public Seq<Building> getBuildings(Block block){` /
`return buildingTypes.get(block, () -> new Seq<>(false));` /
`public int getCount(Block block){` /
`var res = buildingTypes.get(block);` /
`return res == null ? 0 : res.size;` /
`public Seq<Unit> getUnits(UnitType type){` /
`return unitCache(type);` /
`public Seq<Unit> unitCache(UnitType type){` /
`if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;` /
`return unitsByType[type.id];`) is one grouped slice: four
one-to-two-line read-only lookup methods on TeamData
(`buildingTypes` + `unitsByType`) -- main-thread decision
2026-11-21 (the N2380 seven-method / N2374 five-accessor
group precedent). Four GD functions on
SourceTeamsRuntimeState.gd, one ledger entry, one owner per
function (the N2380 multi-function precedent; the N2378
lesson: a contract owner must be an actual GD function, so
the group label `source_team_data_lookup_state` is NOT
registered as an owner -- the ledger godot_owner is the
first function owner, `source_team_data_get_buildings_state`).

Callees -- NOT re-registered as distinguishing exprs:
- `unitCache` in getUnits() -- INSIDE the group (an
  internal self-reference, not an outside expr); the file's
  `source_team_data_unit_cache_state` is that callee.
- `new Seq<>(false)` -- no Seq constructor ported; the
  `() -> new Seq<>(false)` default supplier arrives as a
  Callable param, called only when the block is missing.
- `buildingTypes` / `unitsByType` -- TeamData fields
  (Teams.java:304, 311), explicit params (Dictionary /
  Array-or-null in).

All four functions are read-only: getBuildings does NOT
store the default (ObjectMap.get with a default never
puts), getCount only reads, getUnits/unitCache only read.
Four new result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_update_team_stats import DEFERRED as N2383_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamDataLookupProof'
GET_BUILDINGS_OWNER = 'SourceTeamsRuntimeState.source_team_data_get_buildings_state'
GET_COUNT_OWNER = 'SourceTeamsRuntimeState.source_team_data_get_count_state'
GET_UNITS_OWNER = 'SourceTeamsRuntimeState.source_team_data_get_units_state'
UNIT_CACHE_OWNER = 'SourceTeamsRuntimeState.source_team_data_unit_cache_state'
TESTS = ['test_c07_team_data_lookup_registration', 'test_all_c07_team_data_lookup_input_evidence_is_exact', 'test_team_data_lookup_state', 'test_reference_graph_and_actual_c07_team_data_lookup']
# The 1 slice source the N2390 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public static class TeamData{',
    'public Seq<Building> getBuildings(Block block){',
    'return buildingTypes.get(block, () -> new Seq<>(false));',
    'public int getCount(Block block){',
    'var res = buildingTypes.get(block);',
    'return res == null ? 0 : res.size;',
    'public Seq<Unit> getUnits(UnitType type){',
    'return unitCache(type);',
    'public Seq<Unit> unitCache(UnitType type){',
    'if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;',
    'return unitsByType[type.id];',
]

# DEFERRED is carried from the N2383 register script via import --
# never retyped. All N2383 entries are carried verbatim (the
# Game chain, the B/C notes, the unitTree QuadTree model, the
# Team.all / Groups frame notes, and N2383's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2390's Windows proof debt.
DEFERRED = list(N2383_DEFERRED) + [
    'TeamData.getBuildings()+getCount()+getUnits()+unitCache() Windows Godot proof -- debt in GOAL.md section 5, same as N2383: the N2390 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_buildings_inputs = {
        'building_types': a('Dictionary', 'return buildingTypes.get(block, () -> new Seq<>(false));', 'The buildingTypes map (TeamData.getBuildings, Teams.java:319, `return buildingTypes.get(block, () -> new Seq<>(false));`): the ObjectMap<Block, Seq<Building>> (Teams.java:304) as a Dictionary keyed by block key -- read-only here, ObjectMap.get with a default never stores the default, so a missing block leaves the map untouched.'),
        'block_key': a('Variant', 'public Seq<Building> getBuildings(Block block){', 'The block asking (Teams.java:318, `public Seq<Building> getBuildings(Block block){`): Block is not ported, so the block arrives as its key into the buildingTypes map.'),
        'default_buildings': a('Callable', 'return buildingTypes.get(block, () -> new Seq<>(false));', 'The default supplier (Teams.java:319, `return buildingTypes.get(block, () -> new Seq<>(false));`): the `() -> new Seq<>(false)` lambda as a Callable param (the N2386 Callable precedent) -- called only when the block has no entry, returning a fresh empty Array (Seq<>(false) is the unordered Seq, the empty Array is the GD shape).'),
    }
    get_buildings_outputs = {
        'buildings': a('Array', 'return buildingTypes.get(block, () -> new Seq<>(false));', 'The buildings for the block (Teams.java:319, `return buildingTypes.get(block, () -> new Seq<>(false));`): the stored Seq for a known block (the same Seq reference Java returns, never a copy), or the fresh empty Seq from the default supplier when the block is missing.'),
    }
    get_count_inputs = {
        'building_types': a('Dictionary', 'var res = buildingTypes.get(block);', 'The buildingTypes map (TeamData.getCount, Teams.java:323, `var res = buildingTypes.get(block);`): the same ObjectMap as getBuildings (Teams.java:304) as a Dictionary keyed by block key -- read-only here, getCount never writes.'),
        'block_key': a('Variant', 'public int getCount(Block block){', 'The block asking (Teams.java:322, `public int getCount(Block block){`): Block is not ported, so the block arrives as its key into the buildingTypes map.'),
    }
    get_count_outputs = {
        'count': a('int', 'return res == null ? 0 : res.size;', 'The building count for the block (Teams.java:324, `return res == null ? 0 : res.size;`): the stored Seq size for a known block, or 0 on the `res == null` branch when the block is missing.'),
    }
    get_units_inputs = {
        'units_by_type': a('Variant', 'return unitCache(type);', 'The unitsByType table (TeamData.getUnits, Teams.java:419, `return unitCache(type);`): the @Nullable Seq<Unit>[] (Teams.java:311) as an Array of unit Arrays (or null) -- passed through to the unitCache callee inside this group, which may return null.'),
        'type_id': a('int', 'public Seq<Unit> getUnits(UnitType type){', 'The unit type asking (Teams.java:418, `public Seq<Unit> getUnits(UnitType type){`): type.id arrives as the type_id param (UnitType is not ported).'),
    }
    get_units_outputs = {
        'units': a('Variant', 'return unitCache(type);', 'The units of the type (Teams.java:419, `return unitCache(type);`): whatever unitCache returns -- the cached Array, or null (the @Nullable return, Teams.java:419) when the table is null, the type id is out of range, or the slot is null.'),
    }
    unit_cache_inputs = {
        'units_by_type': a('Variant', 'if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;', 'The unitsByType table (TeamData.unitCache, Teams.java:424, `if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;`): the @Nullable Seq<Unit>[] (Teams.java:311) as an Array of unit Arrays (or null) -- all three null guards run before the index.'),
        'type_id': a('int', 'public Seq<Unit> unitCache(UnitType type){', 'The unit type asking (Teams.java:423, `public Seq<Unit> unitCache(UnitType type){`): type.id arrives as the type_id param (UnitType is not ported) -- the `unitsByType.length <= type.id` guard makes an out-of-range id return null.'),
    }
    unit_cache_outputs = {
        'units': a('Variant', 'return unitsByType[type.id];', 'The cached units of the type (Teams.java:425, `return unitsByType[type.id];`): the slot Array when every guard passes, else null (the @Nullable return, Teams.java:421).'),
    }
    return (get_buildings_inputs, get_buildings_outputs), (get_count_inputs, get_count_outputs), (get_units_inputs, get_units_outputs), (unit_cache_inputs, unit_cache_outputs)


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
    pairs = definitions()

    entries = [
        ('N2390', GET_BUILDINGS_OWNER, 'source_team_data_get_buildings_state', TEAMS, 'mindustry.game.Teams', 'TeamData.getBuildings(Block)', pairs[0][0], pairs[0][1], True, 'Dictionary'),
        ('N2390', GET_COUNT_OWNER, 'source_team_data_get_count_state', TEAMS, 'mindustry.game.Teams', 'TeamData.getCount(Block)', pairs[1][0], pairs[1][1], True, 'Dictionary'),
        ('N2390', GET_UNITS_OWNER, 'source_team_data_get_units_state', TEAMS, 'mindustry.game.Teams', 'TeamData.getUnits(UnitType)', pairs[2][0], pairs[2][1], True, 'Dictionary'),
        ('N2390', UNIT_CACHE_OWNER, 'source_team_data_unit_cache_state', TEAMS, 'mindustry.game.Teams', 'TeamData.unitCache(UnitType)', pairs[3][0], pairs[3][1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamData.getBuildings()/getCount()/getUnits()/unitCache() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamData.getBuildings()/getCount()/getUnits()/unitCache() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: getBuildings buildings;
    # getCount count; getUnits units; unitCache units.
    by_slice['N2390'] = [
        'source_team_data_get_buildings_state_result.buildings',
        'source_team_data_get_count_state_result.count',
        'source_team_data_get_units_state_result.units',
        'source_team_data_unit_cache_state_result.units',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2390', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='TeamData.getBuildings(Block)/TeamData.getCount(Block)/TeamData.getUnits(UnitType)/TeamData.unitCache(UnitType)', godot_owner=GET_BUILDINGS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2390'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
