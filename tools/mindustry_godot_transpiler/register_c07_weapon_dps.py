"""Register the Weapon dps() read (N2534).

Weapon.dps() (Weapon.java:188-190):
`public float dps(){` /
`return (bullet.estimateDPS() / reload) * shoot.shots * 60f;`.
`bullet.estimateDPS()` is already ported (N2529,
`source_bullet_type_estimate_dps_state`, 13 params), so
it arrives as the float param `bullet_estimate_dps`
instead of being called directly -- calling N2529 from
inside the new function would force all 13 bullet params
into the Weapon signature (the N2528/N2529/N2533
param-driven precedent). `reload` is a float param
(Weapon.java:75, `public float reload = 1;` --
`RELOAD_DEFAULT := 1.0` already in
SourceWeaponDefaults.gd). `shoot_shots` is an int param
(ShootPattern.java:9, `public int shots = 1;` --
`SHOTS_DEFAULT := 1` already in
SourceShootPatternDefaults.gd). dps() has NO cache (no
`cachedDps` / `dpsEstimate` field in Weapon.java --
unlike BulletType `cachedDps` and UnitType
`dpsEstimate`): it recomputes on every call, so there is
NO `cached_dps` return key and NO `branch` key -- the
single return key is `dps`. dps() has NO `reload == 0`
guard (only `addStats()` Weapon.java:180 guards
`reload > 0` for display): the faithful port does not add
one -- Java float / 0 is Infinity, not a throw. NO
driver tick call site: dps() is a read/estimate, not
per-tick, and no caller reads it today (N2533 still takes
`weapons_dps_sum` as a float param; wiring N2533 ->
N2534 is a separate consumer slice; C11 HUD / stats
display reads `dps` in a later slice). The only callers
in Java today are `UnitType.estimateDps()` via
`weapons.sumf(Weapon::dps)` (UnitType.java:1136) and
`addStats()` (Weapon.java:180-182, an inline display
formula, not a dps() call).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_dps_state(bullet_estimate_dps, reload,
shoot_shots), placed immediately AFTER setup_mounts_state
(the first function in the file) and BEFORE
set_rotation_state, plus a one-line delegate of the same
name on SourceWeaponsState.gd (the setup_mounts_state
facade precedent). It returns exactly one key, `dps`
(the N2526 precedent -- every return key is a symbol).
(2) NO tick call site -- the function is DORMANT live
today: no caller reads it, so live behavior does not
change. (3) `bullet_estimate_dps` stays a float param --
the caller calls N2529 first and passes the returned
`estimate_dps`. (4) `reload` and `shoot_shots` stay
field params (defaults 1 / 1). SSOT expected after
GREEN: symbols +1, Done +1, contracts +1, schemas +2
(input + result), 11729/1762/1695/3181 ->
11730/1763/1696/3183; type shard slices +1, contracts
+1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_unit_type_estimate_dps import DEFERRED as N2533_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
PROOF = '/root/C07WeaponDpsProof'
DPS_OWNER = 'SourceWeaponsCoreState.source_weapon_dps_state'
TESTS = ['test_c07_weapon_dps_registration', 'test_all_c07_weapon_dps_input_evidence_is_exact', 'test_weapon_dps_state', 'test_reference_graph_and_actual_c07_weapon_dps']
# The slice sources the N2534 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
]
EXACT_EXPRS = [
    'public float dps(){',
    'return (bullet.estimateDPS() / reload) * shoot.shots * 60f;',
    'public float reload = 1;',
    'public ShootPattern shoot = new ShootPattern();',
    'public int shots = 1;',
]

# DEFERRED is carried from the N2533 register script via import --
# never retyped. No entry is dropped: the Weapon.dps() read the
# N2533 pool entry deferred is recorded DONE below. New entries
# below record the dps() read as DONE by this slice, the Windows
# proof debt, and the wiring + consumers that still need a later
# slice.
DEFERRED = N2533_DEFERRED + [
    'Weapon.dps() (`dps` frame key) -- DONE by this slice (N2534): `source_weapon_dps_state` ports Weapon.java:188-190 for the Weapon family (`(bullet.estimateDPS() / reload) * shoot.shots * 60f`); `bullet_estimate_dps` is a float param because calling N2529 directly would force all 13 bullet params into the Weapon signature (the N2528/N2529/N2533 param-driven precedent); `reload` is a float param (default 1, Weapon.java:75); `shoot_shots` is an int param (ShootPattern.shots default 1, ShootPattern.java:9). dps() has NO cache (no `cachedDps` / `dpsEstimate` field in Weapon.java) and NO `reload == 0` guard (only `addStats()` guards `reload > 0` for display), so the single return key is `dps` with no `cached_dps` / `branch`. NO driver tick call site: dps() is a read/estimate, not per-tick, and no caller reads it today (N2533 still takes `weapons_dps_sum` as a float param; C11 HUD / stats display is a later slice). Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.dps() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533: the N2534 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Wiring N2533 -> N2534 still DEFERRED (consumer slice after N2534): `source_unit_type_estimate_dps_state` still takes `weapons_dps_sum` as a float param; the consumer slice must call `source_weapon_dps_state` for each weapon and sum the returned `dps` values (Java `weapons.sumf(Weapon::dps)`, UnitType.java:1136). The C11 HUD / stats display that reads `dps` is also a later slice.',
    'Weapon.shotsPerSec() (Weapon.java:192-194, `return shoot.shots * 60f / reload;`) still DEFERRED (slice after N2534): same reload + shoot_shots inputs as dps(), minus the bullet DPS, one line, pure, NO driver tick.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    dps_inputs = {
        'bullet_estimate_dps': a('float', 'return (bullet.estimateDPS() / reload) * shoot.shots * 60f;', 'The caller-computed `bullet.estimateDPS()` (Weapon.java:189 -- the first factor of dps()); a float param, NOT computed in this slice, because calling N2529 (`source_bullet_type_estimate_dps_state`, 13 params) directly would force all 13 bullet params into the Weapon signature (the N2528/N2529/N2533 param-driven precedent).'),
        'reload': a('float', 'public float reload = 1;', 'The weapon reload in frames (`public float reload = 1;`, Weapon.java:75 -- "weapon reload in frames"); a float param, default 1 (`RELOAD_DEFAULT := 1.0` in SourceWeaponDefaults.gd).'),
        'shoot_shots': a('int', 'public int shots = 1;', 'The ShootPattern shot count (`public int shots = 1;`, ShootPattern.java:9 -- "amount of shots per \\"trigger pull\\""); an int param, default 1 (`SHOTS_DEFAULT := 1` in SourceShootPatternDefaults.gd); the weapon holds the pattern as `public ShootPattern shoot = new ShootPattern();` (Weapon.java:97).', source=SHOOT_PATTERN),
    }
    dps_outputs = {
        'dps': a('float', 'public float dps(){', 'The estimated DPS of this weapon (`public float dps(){`, Weapon.java:188 -- `(bullet.estimateDPS() / reload) * shoot.shots * 60f`, in damage per second); recomputed on every call -- dps() has NO cache field in Weapon.java, so there is no `cached_dps` return key.'),
    }
    return dps_inputs, dps_outputs


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
    dps_inputs, dps_outputs = definitions()

    entries = [
        ('N2534', DPS_OWNER, 'source_weapon_dps_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.dps()', dps_inputs, dps_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon dps() read from Weapon.java:188-190.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon dps() read from Weapon.java:188-190.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: dps.
    by_slice['N2534'] = [
        'source_weapon_dps_state_result.dps',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2534', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.dps()', godot_owner=DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2534'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
