"""Register the PayloadTurret limitRange()+limitRange(float)+setStats() group (N2384).

PayloadTurret limitRange()+limitRange(float)+setStats()
(PayloadAmmoTurret.java:40-42/:45-49/:51-56,
`public void limitRange(){` / `limitRange(1f);` /
`public void limitRange(float margin){` /
`for(var entry : ammoTypes.copy().entries()){` /
`entry.value.lifetime = (range + margin) / entry.value.speed;` /
`public void setStats(){` / `super.setStats();` /
`stats.remove(Stat.itemCapacity);` /
`stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`)
is one grouped pure-function slice on the existing
SourcePayloadAmmoTurretBuildPortBridge.gd (created by N2358
for currentAmmo), following the grouped multi-function
precedent (N2330, `Drill.canPlaceOn(Tile tile, Team team,
int rotation)/Drill.setBars()/Drill.drawPlanConfig(BuildPlan
plan, Eachable<BuildPlan> list)` -- one slice record, one
owner per function, several java_method entries joined by
"/") and the grouped version/write/read precedent (N2375).

RED decisions (resolved at RED): (1) The functions live
in the existing PortBridge file: these are class methods
of PayloadAmmoTurret, not Build methods, and there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owners are PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2358 PortGame.source_payload_ammo_turret_build_current_ammo_state,
N2363 PortGame.source_payload_ammo_turret_build_use_ammo_state,
N2368 PortGame.source_payload_ammo_turret_build_get_ammo_content_state,
N2371 PortGame.source_payload_turret_build_peek_ammo_state,
N2376 PortGame.source_payload_ammo_turret_build_write_read_state,
N2381 PortGame.source_payload_ammo_turret_build_display_bars_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame. The slice record owner is
the limitRange owner
(PortGame.source_payload_ammo_turret_limit_range_state);
limitRange() and setStats each carry their own owner and
contract, exactly like N2330's three owners -- one contract
per owner, because contracts are keyed by owner and a
single contract could not carry the three functions'
return keys (the N2378 lesson: contract name == function
name).
(2) limitRange() alone is one distinguishing line
(`limitRange(1f);`), so it groups with limitRange(float)
(two distinguishing lines) and setStats (one
distinguishing line) into one slice of four distinguishing
exprs, same class, same `ammoTypes` / `range` / `stats`
concern -- the N2330 grouping precedent, main thread
approved as batch 19 slot 3 over the LaserTurret
setStats+init group (2 exprs).
(3) `ammoTypes` (ObjectMap<UnlockableContent, BulletType>,
PayloadAmmoTurret.java:22) arrives as the explicit
ammo_entries param (one dict per ammo entry: content /
lifetime / speed -- the N2330 param precedent); the Java
copy (`ammoTypes.copy()`) means the original bullets are
never touched, so the result returns fresh dicts.
`range` is the BaseTurret field (`public float range = 80f;`,
BaseTurret.java:21) and arrives as the explicit range_value
param; `margin` arrives as an explicit float param (1.0 for
the no-arg form, which delegates by GD call -- the N2379
sibling-call precedent). `stats` (Stats UI API) arrives as
the explicit stats param (rows of stat dicts -- the N2330
param precedent); `StatValues.ammo(ammoTypes, true)` is NOT
ported -- the ammo row spec carries the ammo types list and
the showUnit flag (`show_unit: true`, StatValues.java:606-607
`ammo(map, boolean showUnit)`).
(4) `super.setStats();` is callee/context -- NOT a
distinguishing expr. `stats.remove(Stat.itemCapacity);`
hits N1175 in both ledgers -- evidence only, NOT a
distinguishing expr. The distinguishing lines are
`limitRange(1f);`,
`for(var entry : ammoTypes.copy().entries()){`,
`entry.value.lifetime = (range + margin) / entry.value.speed;`
and `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`
(all 0-hit in both ledgers at HEAD 0ac2993f, re-probed at
the new base).
(5) Content refs are plain strings (content names);
the limitRange results carry exactly one key, the setStats
result exactly one key. NO driver line: limitRange is a
def-time setup call, setStats is a UI spec -- the caller
wiring waits for its own slice.
(6) Evidence, not ownership: `@Override` also appears
at PayloadAmmoTurret.java:50 and on every other override
in the file. Three new result symbols: ammo_entries (x2),
stats. Slice source: PayloadAmmoTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_turret_display_bars import DEFERRED as N2381_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadTurretLimitRangeProof'
LIMIT_RANGE_OWNER = 'PortGame.source_payload_ammo_turret_limit_range_state'
LIMIT_RANGE_DEFAULT_OWNER = 'PortGame.source_payload_ammo_turret_limit_range_default_state'
SET_STATS_OWNER = 'PortGame.source_payload_ammo_turret_set_stats_state'
TESTS = ['test_c07_payload_turret_limit_range_registration', 'test_all_c07_payload_turret_limit_range_input_evidence_is_exact', 'test_payload_turret_limit_range_set_stats_state', 'test_reference_graph_and_actual_c07_payload_turret_limit_range']
# The 1 slice source the N2384 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    'public void limitRange(){',
    'limitRange(1f);',
    'public void limitRange(float margin){',
    'for(var entry : ammoTypes.copy().entries()){',
    'entry.value.lifetime = (range + margin) / entry.value.speed;',
    '@Override',
    'public void setStats(){',
    'super.setStats();',
    'stats.remove(Stat.itemCapacity);',
    'stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));',
]

# DEFERRED is carried from the N2381 register script via import --
# never retyped. This slice closes none of the carried entries;
# it only adds its own Windows-proof debt entry.
DEFERRED = list(N2381_DEFERRED) + [
    'PayloadTurret limitRange/limitRange(float)/setStats Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2384 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    limit_range_inputs = {
        'ammo_entries': a('Array', 'for(var entry : ammoTypes.copy().entries()){', 'The ammo entries to limit (PayloadAmmoTurret.java:46, `for(var entry : ammoTypes.copy().entries()){`): one dict per ammo entry (content / lifetime / speed) from the `public ObjectMap<UnlockableContent, BulletType> ammoTypes` field (PayloadAmmoTurret.java:22) -- the Java copy (`ammoTypes.copy()`) means the original bullets are never touched, so the entries arrive as an explicit param (the N2330 param precedent).'),
        'range_value': a('float', 'entry.value.lifetime = (range + margin) / entry.value.speed;', 'The turret range (PayloadAmmoTurret.java:47, `entry.value.lifetime = (range + margin) / entry.value.speed;`): the BaseTurret field (`public float range = 80f;`, BaseTurret.java:21) -- arrives as an explicit float param.'),
        'margin': a('float', 'public void limitRange(float margin){', 'The range margin (PayloadAmmoTurret.java:45, `public void limitRange(float margin){`): added to range before dividing by speed; 1.0 for the no-arg form (`limitRange(1f);`, PayloadAmmoTurret.java:41).'),
    }
    limit_range_outputs = {
        'ammo_entries': a('Array', 'entry.value.lifetime = (range + margin) / entry.value.speed;', 'The limited ammo entries (PayloadAmmoTurret.java:47, `entry.value.lifetime = (range + margin) / entry.value.speed;`): fresh dicts with lifetime rewritten to (range + margin) / speed, other fields kept, input order kept -- the input is never mutated.'),
    }
    limit_range_default_inputs = {
        'ammo_entries': a('Array', 'for(var entry : ammoTypes.copy().entries()){', 'The ammo entries to limit (PayloadAmmoTurret.java:46, `for(var entry : ammoTypes.copy().entries()){`): one dict per ammo entry (content / lifetime / speed) from the ammoTypes field (PayloadAmmoTurret.java:22) -- arrives as an explicit param (the N2330 param precedent).'),
        'range_value': a('float', 'entry.value.lifetime = (range + margin) / entry.value.speed;', 'The turret range (PayloadAmmoTurret.java:47, `entry.value.lifetime = (range + margin) / entry.value.speed;`): the BaseTurret field (`public float range = 80f;`, BaseTurret.java:21) -- arrives as an explicit float param.'),
    }
    limit_range_default_outputs = {
        'ammo_entries': a('Array', 'limitRange(1f);', 'The limited ammo entries (PayloadAmmoTurret.java:41, `limitRange(1f);`): the no-arg form delegates to limitRange(float) with margin 1f, so each lifetime is (range + 1.0) / speed -- fresh dicts, input never mutated.'),
    }
    set_stats_inputs = {
        'stats': a('Array', 'stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));', 'The current stat rows (PayloadAmmoTurret.java:55, `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`): rows of stat dicts -- the Stats UI API itself is NOT ported, its rows arrive as an explicit param (the N2330 param precedent).'),
        'ammo_types': a('Array', 'stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));', 'The ammo types for the ammo row (PayloadAmmoTurret.java:55, `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`): content names from the ammoTypes field (PayloadAmmoTurret.java:22) -- StatValues.ammo itself is NOT ported, the row spec carries the list plus the showUnit flag.'),
    }
    set_stats_outputs = {
        'stats': a('Array', 'stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));', 'The updated stat rows (PayloadAmmoTurret.java:54-55, `stats.remove(Stat.itemCapacity);` / `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`): the input rows minus any itemCapacity row, plus the ammo row `{"stat": "ammo", "ammo_types": [...], "show_unit": true}` appended -- a fresh copy, the input is never mutated.'),
    }
    return (limit_range_inputs, limit_range_outputs), (limit_range_default_inputs, limit_range_default_outputs), (set_stats_inputs, set_stats_outputs)


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
    inputs_outputs = list(definitions())
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
    (limit_range_inputs, limit_range_outputs), (limit_range_default_inputs, limit_range_default_outputs), (set_stats_inputs, set_stats_outputs) = definitions()

    entries = [
        ('N2384', LIMIT_RANGE_OWNER, 'source_payload_ammo_turret_limit_range_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurret.limitRange(float)', limit_range_inputs, limit_range_outputs, True, 'Dictionary'),
        ('N2384', LIMIT_RANGE_DEFAULT_OWNER, 'source_payload_ammo_turret_limit_range_default_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurret.limitRange()', limit_range_default_inputs, limit_range_default_outputs, True, 'Dictionary'),
        ('N2384', SET_STATS_OWNER, 'source_payload_ammo_turret_set_stats_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurret.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurret.limitRange()+limitRange(float)+setStats() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurret.limitRange()+limitRange(float)+setStats() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: limit_range ammo_entries,
    # limit_range_default ammo_entries, set_stats stats.
    by_slice['N2384'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2384', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', java_method='PayloadAmmoTurret.limitRange(); PayloadAmmoTurret.limitRange(float); PayloadAmmoTurret.setStats()', godot_owner=LIMIT_RANGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2384'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
