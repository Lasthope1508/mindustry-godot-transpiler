"""Register the UnitType weapons.sumf(Weapon::dps) wiring leg (N2536).

The sum leg of UnitType.estimateDps() (UnitType.java:1132-1144):
`public float estimateDps(){` /
`dpsEstimate = weapons.sumf(Weapon::dps);` /
`return dpsEstimate;`.
`weapons` is `public Seq<Weapon> weapons = new Seq<>();`
(UnitType.java:288). The sum is over one dps value per weapon,
each computed by the caller with `source_weapon_dps_state`
(N2534, Weapon.dps(), Weapon.java:188-190, `(bullet.
estimateDPS() / reload) * shoot.shots * 60f`): this function
does NOT call Weapon.dps() directly (the N2528/N2529/N2533
param-driven precedent -- calling it here would force the 13
bullet params into the UnitType signature). `weapons_dps` is an
Array of floats, one per weapon; an empty Seq sums to 0.0 (arc
Seq.sumf starts from 0 -- arc is a Gradle dependency, not
vendored under mindustry-upstream, so only the UnitType.java
exprs are verified verbatim here). NO driver tick call site:
the sum is a read/estimate, not per-tick, and no caller reads
it today (N2533 still takes `weapons_dps_sum` as a float param;
the consumer that calls this sum and passes it into
`source_unit_type_estimate_dps_state` is a later slice; C11
HUD / stats display is C11).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceUnitTypeState.gd,
source_unit_type_weapons_dps_sum_state(weapons_dps), placed
immediately AFTER source_unit_type_estimate_dps_state (the last
pure function in the file) and BEFORE the generated bridges.
It returns exactly one key, `weapons_dps_sum` (the N2526
precedent -- every return key is a symbol). (2) NO tick call
site -- the function is DORMANT live today: no caller reads it,
so live behavior does not change. (3) `weapons_dps` stays an
Array param of caller-computed per-weapon dps values --
Weapon.dps() is ported (N2534) but the per-weapon call is the
caller's job. SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schemas +2 (input + result),
11731/1764/1697/3185 -> 11732/1765/1698/3187; type shard
slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_shots_per_sec import DEFERRED as N2535_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
PROOF = '/root/C07UnitTypeWeaponsDpsSumProof'
WEAPONS_DPS_SUM_OWNER = 'SourceUnitTypeState.source_unit_type_weapons_dps_sum_state'
TESTS = ['test_c07_unit_type_weapons_dps_sum_registration', 'test_all_c07_unit_type_weapons_dps_sum_input_evidence_is_exact', 'test_unit_type_weapons_dps_sum_state', 'test_reference_graph_and_actual_c07_unit_type_weapons_dps_sum']
# The slice sources the N2536 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/UnitType.java',
]
EXACT_EXPRS = [
    'public float estimateDps(){',
    'dpsEstimate = weapons.sumf(Weapon::dps);',
    'public Seq<Weapon> weapons = new Seq<>();',
    'return dpsEstimate;',
]

# DEFERRED is carried from the N2535 register script via import --
# never retyped. No entry is dropped: the Wiring N2533 -> N2534
# entry the N2534 pool recorded deferred is recorded DONE below.
# New entries below record the sumf read as DONE by this slice,
# the Windows proof debt, and the consumer that still needs a
# later slice.
DEFERRED = N2535_DEFERRED + [
    'Wiring N2533 -> N2534 (`weapons_dps_sum` frame key) -- DONE by this slice (N2536): `source_unit_type_weapons_dps_sum_state` ports the `dpsEstimate = weapons.sumf(Weapon::dps);` leg (UnitType.java:1136) for the UnitType family (total starts at 0.0, so an empty weapons Seq sums to 0.0; each element is the caller-computed per-weapon `source_weapon_dps_state` dps, N2534; the function does NOT call Weapon.dps() directly). NO driver tick call site: the sum is a read/estimate, not per-tick, and no caller reads it today (N2533 still takes `weapons_dps_sum` as a float param; the consumer that calls this sum and passes it into `source_unit_type_estimate_dps_state` is a later slice; HUD / stats display is C11). Dormant live today: no caller reads the function, so live behavior does not change.',
    'UnitType weapons.sumf(Weapon::dps) Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535: the N2536 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Wiring sum -> estimateDps still DEFERRED (consumer slice after N2536): `source_unit_type_estimate_dps_state` still takes `weapons_dps_sum` as a float param; the consumer slice must call `source_unit_type_weapons_dps_sum_state` on the caller-computed per-weapon dps values and pass the returned `weapons_dps_sum` into `source_unit_type_estimate_dps_state`. The C11 HUD / stats display that reads `weapons_dps_sum` is also a later slice.',
]


def definitions():
    def a(typ, expr, rule, source=UNIT_TYPE, **extra):
        return backed(typ, source, expr, rule, **extra)

    weapons_dps_sum_inputs = {
        'weapons_dps': a('Array', 'dpsEstimate = weapons.sumf(Weapon::dps);', 'The per-weapon dps values to sum (`dpsEstimate = weapons.sumf(Weapon::dps);`, UnitType.java:1136 -- one float per weapon in `public Seq<Weapon> weapons = new Seq<>();`, UnitType.java:288; each value is the caller-computed `source_weapon_dps_state` dps, N2534, Weapon.dps() Weapon.java:188-190); an Array param, NOT computed in this slice, because the per-weapon Weapon.dps() call is the caller\'s job.'),
    }
    weapons_dps_sum_outputs = {
        'weapons_dps_sum': a('float', 'dpsEstimate = weapons.sumf(Weapon::dps);', 'The summed weapons DPS (`dpsEstimate = weapons.sumf(Weapon::dps);`, UnitType.java:1136 -- "calculate estimated DPS for one target based on weapons", the value estimateDps() caches into `dpsEstimate` before the suicide leg; an empty weapons Seq sums to 0.0).'),
    }
    return weapons_dps_sum_inputs, weapons_dps_sum_outputs


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
    weapons_dps_sum_inputs, weapons_dps_sum_outputs = definitions()

    entries = [
        ('N2536', WEAPONS_DPS_SUM_OWNER, 'source_unit_type_weapons_dps_sum_state', UNIT_TYPE, 'mindustry.type.UnitType', 'UnitType.estimateDps()', weapons_dps_sum_inputs, weapons_dps_sum_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitType weapons.sumf(Weapon::dps) read from UnitType.java:1136.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitType weapons.sumf(Weapon::dps) read from UnitType.java:1136.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: weapons_dps_sum.
    by_slice['N2536'] = [
        'source_unit_type_weapons_dps_sum_state_result.weapons_dps_sum',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2536', dict(status='done', java_source=UNIT_TYPE, java_class='mindustry.type.UnitType', java_method='UnitType.estimateDps()', godot_owner=WEAPONS_DPS_SUM_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2536'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
