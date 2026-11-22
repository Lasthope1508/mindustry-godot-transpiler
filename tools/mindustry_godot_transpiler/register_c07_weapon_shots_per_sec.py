"""Register the Weapon shotsPerSec() read (N2535).

Weapon.shotsPerSec() (Weapon.java:192-194):
`public float shotsPerSec(){` /
`return shoot.shots * 60f / reload;`.
`reload` is a float param (Weapon.java:75, `public float
reload = 1;` -- `RELOAD_DEFAULT := 1.0` already in
SourceWeaponDefaults.gd). `shoot_shots` is an int param
(ShootPattern.java:9, `public int shots = 1;` --
`SHOTS_DEFAULT := 1` already in
SourceShootPatternDefaults.gd). shotsPerSec() has NO
cache (no `cachedDps` / `dpsEstimate` field in
Weapon.java -- unlike BulletType `cachedDps` and
UnitType `dpsEstimate`): it recomputes on every call,
so there is NO `cached_shots_per_sec` return key and
NO `branch` key -- the single return key is
`shots_per_sec`. shotsPerSec() has NO `reload == 0`
guard (only `addStats()` Weapon.java:180 guards
`reload > 0` for display): the faithful port does not
add one -- Java float / 0 is Infinity, not a throw.
NO driver tick call site: shotsPerSec() is a
read/estimate, not per-tick, and no caller reads it
today (no Java caller outside Weapon itself; C11 HUD /
stats display is a later slice). The only other
formula sharing these inputs is dps() (N2534), which
multiplies by the bullet DPS as well.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_shots_per_sec_state(reload, shoot_shots),
placed immediately AFTER source_weapon_dps_state (the
N2534 function) and BEFORE set_rotation_state, plus a
one-line delegate of the same name on
SourceWeaponsState.gd (the setup_mounts_state facade
precedent). It returns exactly one key,
`shots_per_sec` (the N2526 precedent -- every return
key is a symbol). (2) NO tick call site -- the
function is DORMANT live today: no caller reads it,
so live behavior does not change. (3) `reload` and
`shoot_shots` stay field params (defaults 1 / 1).
SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schemas +2 (input + result),
11730/1763/1696/3183 -> 11731/1764/1697/3185; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_dps import DEFERRED as N2534_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
PROOF = '/root/C07WeaponShotsPerSecProof'
SPS_OWNER = 'SourceWeaponsCoreState.source_weapon_shots_per_sec_state'
TESTS = ['test_c07_weapon_shots_per_sec_registration', 'test_all_c07_weapon_shots_per_sec_input_evidence_is_exact', 'test_weapon_shots_per_sec_state', 'test_reference_graph_and_actual_c07_weapon_shots_per_sec']
# The slice sources the N2535 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
]
EXACT_EXPRS = [
    'public float shotsPerSec(){',
    'return shoot.shots * 60f / reload;',
    'public float reload = 1;',
    'public ShootPattern shoot = new ShootPattern();',
    'public int shots = 1;',
]

# DEFERRED is carried from the N2534 register script via import --
# never retyped. No entry is dropped: the Weapon.shotsPerSec()
# read the N2534 pool entry deferred is recorded DONE below.
# New entries below record the shotsPerSec() read as DONE by
# this slice, the Windows proof debt, and the consumers that
# still need a later slice.
DEFERRED = N2534_DEFERRED + [
    'Weapon.shotsPerSec() (`shots_per_sec` frame key) -- DONE by this slice (N2535): `source_weapon_shots_per_sec_state` ports Weapon.java:192-194 for the Weapon family (`shoot.shots * 60f / reload`); `reload` is a float param (default 1, Weapon.java:75); `shoot_shots` is an int param (ShootPattern.shots default 1, ShootPattern.java:9). shotsPerSec() has NO cache (no `cachedDps` / `dpsEstimate` field in Weapon.java) and NO `reload == 0` guard (only `addStats()` guards `reload > 0` for display), so the single return key is `shots_per_sec` with no `cached_shots_per_sec` / `branch`. NO driver tick call site: shotsPerSec() is a read/estimate, not per-tick, and no caller reads it today (no Java caller outside Weapon itself; C11 HUD / stats display is a later slice). Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.shotsPerSec() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534: the N2535 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.shotsPerSec() consumers still DEFERRED (later slices): the C11 HUD / stats display that reads `shots_per_sec` (and the `addStats()` Weapon.java:180 inline display formula `60f / reload * shoot.shots`, which is not a shotsPerSec() call) is a later slice.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    sps_inputs = {
        'reload': a('float', 'public float reload = 1;', 'The weapon reload in frames (`public float reload = 1;`, Weapon.java:75 -- "weapon reload in frames"); a float param, default 1 (`RELOAD_DEFAULT := 1.0` in SourceWeaponDefaults.gd).'),
        'shoot_shots': a('int', 'public int shots = 1;', 'The ShootPattern shot count (`public int shots = 1;`, ShootPattern.java:9 -- "amount of shots per \\\\"trigger pull\\\\""); an int param, default 1 (`SHOTS_DEFAULT := 1` in SourceShootPatternDefaults.gd); the weapon holds the pattern as `public ShootPattern shoot = new ShootPattern();` (Weapon.java:97).', source=SHOOT_PATTERN),
    }
    sps_outputs = {
        'shots_per_sec': a('float', 'public float shotsPerSec(){', 'The shots per second of this weapon (`public float shotsPerSec(){`, Weapon.java:192 -- `shoot.shots * 60f / reload`, in shots per second); recomputed on every call -- shotsPerSec() has NO cache field in Weapon.java, so there is no `cached_shots_per_sec` return key.'),
    }
    return sps_inputs, sps_outputs


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
    sps_inputs, sps_outputs = definitions()

    entries = [
        ('N2535', SPS_OWNER, 'source_weapon_shots_per_sec_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.shotsPerSec()', sps_inputs, sps_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon shotsPerSec() read from Weapon.java:192-194.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon shotsPerSec() read from Weapon.java:192-194.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: shots_per_sec.
    by_slice['N2535'] = [
        'source_weapon_shots_per_sec_state_result.shots_per_sec',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2535', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.shotsPerSec()', godot_owner=SPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2535'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
