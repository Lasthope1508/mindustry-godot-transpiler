"""Register the BuildingComp.sense() `powerNetIn` leg (N2514).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). Its `powerNetIn` leg is `case
powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`
(:2114), with `power` the building's power module (`@Nullable
PowerModule power;`, BuildingComp.java:80) and
`power.graph.getLastScaledPowerIn()` the graph's last scaled
power-in per tick (`public float getLastScaledPowerIn(){`,
PowerGraph.java:45-47 -- returns float; updated :233
`lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta`).
The `* 60` converts the per-tick value to a per-second rate.
N2284 ported 23 handled legs of sense() and left
dead/health/totalItems/camera*/powerNet* deferred -- powerNetIn
deferred because the live graph values are not stamped in the
frame (note inside `source_building_comp_sense_state`,
SourceTurretBuildState.gd:404). N2511 ported `dead`, N2512 ported
`health`, N2513 ported `totalItems`. This slice ports exactly the
`powerNetIn` leg, next in Java switch order after `totalItems`
(:2107 -> :2114). powerNetOut / powerNetStored / powerNetCapacity
/ camera* stay deferred (separate later slices, in Java switch
order).

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_building_comp_sense_power_net_in_state(power_is_null,
last_scaled_power_in), returning `handled` + `sense_value` +
`sense_value_is_nan` (the N2283/N2284 sense wire shape). The two
params are the live input a future frame-stamp slice will supply
(the N2212/N2220 per-def-param precedent): `power_is_null` is
`power == null` (:2114, first branch of the ternary) and
`last_scaled_power_in` is `power.graph.getLastScaledPowerIn()`.
`sense_value` is 0.0 when power is null, else
`last_scaled_power_in * 60.0` exactly (Java `sense()` returns
double; the float widens exactly), no clamping, no rounding.
`handled` is true always (this function IS the powerNetIn leg;
the sensor is fixed `powerNetIn`, so no `sensor` param) and
`sense_value_is_nan` is false always (the leg never yields NaN;
the key stays in the wire shape for consistency with
N2283/N2284/N2511/N2512/N2513). It sits immediately AFTER
source_building_comp_sense_total_items_state and BEFORE
source_turret_sense_object_state, mirroring the sense() /
senseObject() order in BuildingComp.java (:2093 / :2128) and,
inside sense(), dead :2098 -> health :2101 -> totalItems :2107 ->
powerNetIn :2114. It does NOT modify
`source_building_comp_sense_state`: powerNetIn stays
handled:false in the big dispatch until a later wiring slice
connects this leg (same as N2511's dead leg, N2512's health leg
and N2513's totalItems leg living beside N2284). (2) There is NO
driver tick line: the leg is a logic read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513
precedent); the proof calls the pure function directly with
synthetic inputs, and wiring the leg into a live logic-executor
driver is its own later slice (the logic executor is not in the
driver yet). (3) No legacy
`source_building_comp_sense_power_net_in_result` schema exists, so
the contract validator falls through to the new
source_building_comp_sense_power_net_in_state_result schema and no
alias is needed. (4) Shard routing: the ported method is
BuildingComp.sense, so the java_source is BuildingComp.java
(NOT LExecutor.java -- the N2510 precedent is the reverse:
there the dispatched method WAS SenseI.run itself), and the
slice mirrors into the comp shard: comp 563/467 -> 564/468;
defense stays 210/209. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schema +2, 11692/1742/1676/3143 ->
11695/1743/1677/3145.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_building_comp_sense_total_items import DEFERRED as N2513_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07BuildingCompSensePowerNetInProof'
POWER_NET_IN_OWNER = 'SourceTurretBuildState.source_building_comp_sense_power_net_in_state'
TESTS = ['test_c07_building_comp_sense_power_net_in_registration', 'test_all_c07_building_comp_sense_power_net_in_input_evidence_is_exact', 'test_building_comp_sense_power_net_in_state', 'test_reference_graph_and_actual_c07_building_comp_sense_power_net_in']
# The slice sources the N2514 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/power/PowerGraph.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = [
    'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
    'public float getLastScaledPowerIn(){',
    'public double sense(LAccess sensor){',
    'default -> Float.NaN; //gets converted to null in logic',
    'powerNetIn,',
]

# DEFERRED is carried from the N2513 register script via import --
# never retyped. No entry names the powerNetIn leg specifically
# (only the generic `powerNet*` group), so nothing is dropped
# here -- the powerNetIn-leg entry below is ADDED as DONE. Every
# other entry is carried verbatim (the N2211/N2228 lesson --
# never retype the pool).
DEFERRED = [e for e in N2513_DEFERRED if 'sense() powerNetIn leg' not in e] + [
    'BuildingComp sense() powerNetIn leg (`case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`, BuildingComp.java:2114) -- DONE by this slice (N2514); the pure function returns 0.0 when power is null (`@Nullable PowerModule power;`, BuildingComp.java:80), else `last_scaled_power_in * 60.0` exactly (the `* 60` converts the per-tick value to a per-second rate; `public float getLastScaledPowerIn(){`, PowerGraph.java:45-47 -- returns float, updated :233 `lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta`, widened exactly to the double sense wire), with handled true and sense_value_is_nan false always. powerNetIn stays handled:false in `source_building_comp_sense_state` until a later wiring slice connects this leg. powerNetOut / powerNetStored / powerNetCapacity / camera* stay deferred (separate later slices, in Java switch order).',
    'BuildingComp sense() powerNetIn Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513: the N2514 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    power_net_in_inputs = {
        'power_is_null': a('bool', 'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;', 'Whether `power == null` (`case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`, BuildingComp.java:2114, first branch of the ternary): the building has no power module (`@Nullable PowerModule power;`, BuildingComp.java:80); passed explicitly because the live graph values are not stamped in the frame yet (the N2212/N2220 per-def-param precedent).'),
        'last_scaled_power_in': a('float', 'public float getLastScaledPowerIn(){', 'The graph\'s last scaled power-in per tick (`public float getLastScaledPowerIn(){`, PowerGraph.java:45-47 -- returns float; updated :233 `lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta`): the value `case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;` (BuildingComp.java:2114) scales by 60 when power is not null; passed explicitly because the live graph values are not stamped in the frame yet (the N2212/N2220 per-def-param precedent).', source=POWER_GRAPH),
    }
    power_net_in_outputs = {
        'handled': a('bool', 'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;', 'Whether the leg resolved to a logic-variable write (`case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`, BuildingComp.java:2114): true always, because this function IS the powerNetIn leg and the sensor is fixed `powerNetIn`.'),
        'sense_value': a('Variant', 'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;', 'The numeric value written to the logic variable (`case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`, BuildingComp.java:2114): 0.0 when power is null, else `last_scaled_power_in * 60.0` exactly (the `* 60` converts the per-tick value to a per-second rate; Java `sense()` returns double; the float widens exactly), no clamping, no rounding.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether Java returns Float.NaN for this sensor (`default -> Float.NaN; //gets converted to null in logic`, BuildingComp.java:2123); false always for the powerNetIn leg, which never yields NaN -- the key stays in the wire shape for consistency with N2283/N2284/N2511/N2512/N2513.'),
    }
    return power_net_in_inputs, power_net_in_outputs


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
    power_net_in_inputs, power_net_in_outputs = definitions()

    entries = [
        ('N2514', POWER_NET_IN_OWNER, 'source_building_comp_sense_power_net_in_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', power_net_in_inputs, power_net_in_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildingComp.sense() powerNetIn leg from BuildingComp.java:2114 + PowerGraph.java:45-47.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildingComp.sense() powerNetIn leg from BuildingComp.java:2114 + PowerGraph.java:45-47.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value, sense_value_is_nan.
    by_slice['N2514'] = [
        'source_building_comp_sense_power_net_in_state_result.handled',
        'source_building_comp_sense_power_net_in_state_result.sense_value',
        'source_building_comp_sense_power_net_in_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2514', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=POWER_NET_IN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2514'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
