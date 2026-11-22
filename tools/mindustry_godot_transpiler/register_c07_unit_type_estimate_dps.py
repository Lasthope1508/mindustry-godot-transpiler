"""Register the UnitType estimateDps() read (N2533).

UnitType.estimateDps() (UnitType.java:1132-1144):
`public float estimateDps(){` /
`if(dpsEstimate < 0){` /
`dpsEstimate = weapons.sumf(Weapon::dps);` /
`if(weapons.contains(w -> w.bullet.killShooter)){` /
`dpsEstimate /= 15f;` /
`return dpsEstimate;`.
The cache check is `dpsEstimate < 0` (NOT `>= 0f`): a
cached value of 0.0 IS a hit (0 is not < 0), and a negative
cache (-1, the `dpsEstimate = -1,` init, or any other
negative) recomputes. The suicide leg divides the SAME
field that was just summed (`dpsEstimate /= 15f;`), so the
divided value is what gets cached -- the pure function
returns the divided value through both `estimate_dps` and
`cached_dps` on the "computed_suicide" branch.
`cached_dps` is the runtime cache (`dpsEstimate = -1,`,
UnitType.java:104 -- -1 means "not computed yet"; the field
doc says "a VERY ROUGH estimate of unit DPS; initialized in
init()"). `weapons_dps_sum` is the caller-summed
`weapons.sumf(Weapon::dps)` (UnitType.java:1136):
Weapon.dps() (Weapon.java:188-190, `(bullet.estimateDPS()
/ reload) * shoot.shots * 60f`) is NOT ported yet, so the
sum arrives as a float param (the N2529 precedent -- the
spawn unit DPS was a param until this slice).
`has_kill_shooter_weapon` is the caller-side
`weapons.contains(w -> w.bullet.killShooter)` guard
(UnitType.java:1139): the caller scans the weapons for a
bullet with `killShooter` (BulletType.java:105); the
function cannot scan weapons from a float param. NO driver
tick call site: estimateDps() is a read/estimate, not
per-tick, and no caller reads it today (the N2529 bullet
function still takes `spawn_unit_dps` / `despawn_unit_dps`
as float params; wiring N2529 -> N2533 is a separate
consumer slice; HUD / stats display is C11).
`estimateDps()` is also called from `UnitType.init()`
(UnitType.java:1129) -- that is a content-init call site,
not a per-tick driver, and this slice does not wire init().

GREEN decisions (pinned by this slice): (1) One pure
function on SourceUnitTypeState.gd,
source_unit_type_estimate_dps_state(cached_dps,
weapons_dps_sum, has_kill_shooter_weapon), placed
immediately AFTER landed_state (the last pure function in
the file) and BEFORE the generated bridges. It returns
exactly three keys, `estimate_dps`, `cached_dps`, `branch`
(the N2526 precedent -- every return key is a symbol). (2)
NO tick call site -- the function is DORMANT live today: no
caller reads it, so live behavior does not change. (3)
`weapons_dps_sum` stays a float param -- Weapon.dps() is a
separate later slice. (4) `has_kill_shooter_weapon` stays a
bool param -- the weapons scan for `bullet.killShooter` is
the caller's job. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schemas +2 (input + result),
11726/1761/1694/3179 -> 11729/1762/1695/3181; type shard
slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_drawrot import DEFERRED as N2532_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
PROOF = '/root/C07UnitTypeEstimateDpsProof'
ESTIMATE_DPS_OWNER = 'SourceUnitTypeState.source_unit_type_estimate_dps_state'
TESTS = ['test_c07_unit_type_estimate_dps_registration', 'test_all_c07_unit_type_estimate_dps_input_evidence_is_exact', 'test_unit_type_estimate_dps_state', 'test_reference_graph_and_actual_c07_unit_type_estimate_dps']
# The slice sources the N2533 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/UnitType.java',
]
EXACT_EXPRS = [
    'public float estimateDps(){',
    'if(dpsEstimate < 0){',
    'dpsEstimate = weapons.sumf(Weapon::dps);',
    'if(weapons.contains(w -> w.bullet.killShooter)){',
    'dpsEstimate /= 15f;',
    'return dpsEstimate;',
    'dpsEstimate = -1,',
]

# DEFERRED is carried from the N2532 register script via import --
# never retyped. No entry is dropped: the Turret drawrot() read
# the N2532 pool entry deferred is recorded DONE below. New
# entries below record the estimateDps read as DONE by this
# slice, the Windows proof debt, and the wiring + consumers that
# still need a later slice.
DEFERRED = N2532_DEFERRED + [
    'UnitType.estimateDps() (`estimate_dps` / `cached_dps` / `branch` frame keys) -- DONE by this slice (N2533): `source_unit_type_estimate_dps_state` ports UnitType.java:1132-1144 for the UnitType family (cache check `dpsEstimate < 0` first, so a cached 0.0 IS a hit and a negative cache recomputes; computed leg `dpsEstimate = weapons.sumf(Weapon::dps)`; suicide leg `dpsEstimate /= 15f` on `weapons.contains(w -> w.bullet.killShooter)`, the divided value is what gets cached; `weapons_dps_sum` is a float param because Weapon.dps() (Weapon.java:188-190) is not ported yet; `has_kill_shooter_weapon` is the caller-side killShooter scan). NO driver tick call site: estimateDps() is a read/estimate, not per-tick, and no caller reads it today (the N2529 bullet function still takes `spawn_unit_dps` / `despawn_unit_dps` as float params; HUD / stats display is C11). Dormant live today: no caller reads the function, so live behavior does not change.',
    'UnitType.estimateDps() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532: the N2533 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Wiring N2529 -> N2533 still DEFERRED (consumer slice after N2533): `source_bullet_type_estimate_dps_state` still takes `spawn_unit_dps` / `despawn_unit_dps` as float params; the consumer slice must call `source_unit_type_estimate_dps_state` on the spawned / despawned unit type and pass the returned `estimate_dps` instead. The C11 HUD / stats display that reads `estimate_dps` is also a later slice.',
    'Weapon.dps() (Weapon.java:188-190, `(bullet.estimateDPS() / reload) * shoot.shots * 60f`) still DEFERRED (slice after N2533): until it lands, `source_unit_type_estimate_dps_state` takes `weapons_dps_sum` as a float param (the caller sums Weapon.dps() over the weapons), and `has_kill_shooter_weapon` stays a bool param (the caller scans the weapons for `bullet.killShooter`).',
]


def definitions():
    def a(typ, expr, rule, source=UNIT_TYPE, **extra):
        return backed(typ, source, expr, rule, **extra)

    estimate_dps_inputs = {
        'cached_dps': a('float', 'dpsEstimate = -1,', 'The runtime cache (`dpsEstimate = -1,`, UnitType.java:104 -- -1 means "not computed yet"; the field doc says "a VERY ROUGH estimate of unit DPS; initialized in init()"); the cache check is `dpsEstimate < 0`, so a cached 0.0 IS a hit and a negative cache recomputes, and the computed leg returns the new cache value through the `cached_dps` result key (the pure function never mutates state outside).'),
        'weapons_dps_sum': a('float', 'dpsEstimate = weapons.sumf(Weapon::dps);', 'The caller-summed `weapons.sumf(Weapon::dps)` (UnitType.java:1136); a float param, NOT computed in this slice, because Weapon.dps() (Weapon.java:188-190, `(bullet.estimateDPS() / reload) * shoot.shots * 60f`) is not ported yet -- that is a later slice.'),
        'has_kill_shooter_weapon': a('bool', 'if(weapons.contains(w -> w.bullet.killShooter)){', 'Whether any weapon bullet kills its shooter (`if(weapons.contains(w -> w.bullet.killShooter)){`, UnitType.java:1139 -- the suicide leg, which scales the DPS down to be insignificant); a bool param: the caller scans the weapons for a bullet with `killShooter` (BulletType.java:105), the function cannot scan weapons from a float param.'),
    }
    estimate_dps_outputs = {
        'estimate_dps': a('float', 'public float estimateDps(){', 'The estimated DPS for one target based on weapons (`public float estimateDps(){`, UnitType.java:1132 -- "calculate estimated DPS for one target based on weapons"; the cached value on the cache-hit leg, the summed weapons DPS otherwise, divided by 15f on the suicide leg).'),
        'cached_dps': a('float', 'return dpsEstimate;', 'The cache value Java would store (`return dpsEstimate;`, UnitType.java:1143 -- the computed leg writes `dpsEstimate` (divided by 15f on the suicide leg); the cache-hit leg returns the input cache unchanged).'),
        'branch': a('String', 'public float estimateDps(){', 'Which leg of estimateDps() fired (`public float estimateDps(){`, UnitType.java:1132 -- the three legs of the method): `cached` (cache hit, `dpsEstimate >= 0`), `computed` (fresh sum), or `computed_suicide` (fresh sum divided by 15f). A port-side discriminator, not a Java field; it names the method leg, so it is backed by the method signature.'),
    }
    return estimate_dps_inputs, estimate_dps_outputs


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
    estimate_dps_inputs, estimate_dps_outputs = definitions()

    entries = [
        ('N2533', ESTIMATE_DPS_OWNER, 'source_unit_type_estimate_dps_state', UNIT_TYPE, 'mindustry.type.UnitType', 'UnitType.estimateDps()', estimate_dps_inputs, estimate_dps_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitType estimateDps() read from UnitType.java:1132-1144.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitType estimateDps() read from UnitType.java:1132-1144.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: estimate_dps, cached_dps, branch.
    by_slice['N2533'] = [
        'source_unit_type_estimate_dps_state_result.estimate_dps',
        'source_unit_type_estimate_dps_state_result.cached_dps',
        'source_unit_type_estimate_dps_state_result.branch',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2533', dict(status='done', java_source=UNIT_TYPE, java_class='mindustry.type.UnitType', java_method='UnitType.estimateDps()', godot_owner=ESTIMATE_DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2533'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
