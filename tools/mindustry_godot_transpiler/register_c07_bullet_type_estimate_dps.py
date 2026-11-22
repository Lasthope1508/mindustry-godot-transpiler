"""Register the BulletType estimateDPS() read (N2529).

BulletType.estimateDPS() (BulletType.java:414-435):
`public float estimateDPS(){` /
`if(cachedDps >= 0f) return cachedDps;` /
`if(spawnUnit != null){` / `return spawnUnit.estimateDps();` /
`if(despawnUnit != null){` / `return despawnUnit.estimateDps();` /
`float sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : Mathf.clamp(pierceCap, 1, 2) : 1f);` /
`if(fragBullet != null && fragBullet != this){` /
`sum += fragBullet.estimateDPS() * fragBullets / 2f;` /
`for(var other : spawnBullets){` / `sum += other.estimateDPS();` /
`return cachedDps = sum;`.
The legs run in exact Java order: the cache hit returns
`cachedDps` first; the spawnUnit / despawnUnit legs return
the unit DPS WITHOUT writing the cache (Java returns before
the `cachedDps = sum` line); only the computed leg writes
the cache, and the pure function returns the new cache value
through the `cached_dps` key (it never mutates state
outside). `damage` is the BulletType field (`public float
damage = 1f;`, BulletType.java:41 -- the class default).
`splash_damage` is the field (`public float splashDamage
= 0f;`, BulletType.java:109). `pierce` is the field
(`public boolean pierce;`, BulletType.java:53 -- false by
default). `pierce_cap` is the field (`public int pierceCap
= -1;`, BulletType.java:57). `cached_dps` is the runtime
cache (`protected float cachedDps = -1;`,
BulletType.java:377 -- -1 means "not computed yet").
`has_spawn_unit` / `spawn_unit_dps` and `has_despawn_unit`
/ `despawn_unit_dps` are bool + float param pairs:
UnitType.estimateDps() (UnitType.java:1132-1144,
`weapons.sumf(Weapon::dps)` + `/ 15f` on suicide) is NOT
ported yet, so the unit DPS arrives as a param (the N2528
precedent). The frag guard (`fragBullet != this`,
BulletType.java:425) arrives as the `has_frag_bullet` bool
param: the caller passes false when the frag bullet is the
bullet itself (self-frag), the function cannot tell identity
from a float param. `frag_bullets` is the field (`public
int fragBullets = 9;`, BulletType.java:212).
`spawn_bullets_dps_sum` is the caller-summed `estimateDPS()`
of every `spawnBullets` entry (`for(var other :
spawnBullets){ sum += other.estimateDPS(); }`,
BulletType.java:429-431 -- the recursion over the bullet
catalog is the caller's sum, NOT recomputed in the
function). Java doc: "this can be very inaccurate" -- the
function keeps the exact Java formula including that
inaccuracy (the N2128 +/-2 deg precedent). NO driver tick
call site: estimateDPS() is a read/estimate, not per-tick,
and no caller reads it today (the N2528 turret function
still takes `peek_ammo_dps` as a param; wiring N2528 ->
N2529 is a separate consumer slice; HUD / stats display is
C11).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceBulletTypeDamageState.gd,
source_bullet_type_estimate_dps_state(damage,
splash_damage, pierce, pierce_cap, cached_dps,
has_spawn_unit, spawn_unit_dps, has_despawn_unit,
despawn_unit_dps, has_frag_bullet, frag_bullet_dps,
frag_bullets, spawn_bullets_dps_sum), placed immediately
AFTER shield_damage_state (the last function in the file).
It returns exactly three keys, `estimate_dps`,
`cached_dps`, `branch` (the N2526 precedent -- every
return key is a symbol). (2) NO tick call site -- the
function is DORMANT live today: no caller reads it, so
live behavior does not change. (3) `spawn_unit_dps` /
`despawn_unit_dps` stay float params -- UnitType.estimateDps()
is a separate later slice. (4) `spawn_bullets_dps_sum`
stays a float param -- the spawnBullets recursion is the
caller's sum. SSOT expected after GREEN: symbols +3, Done
+1, contracts +1, schemas +2 (input + result),
11720/1757/1690/3171 -> 11723/1758/1691/3173; bullet
shard slices 93 -> 94, contracts 93 -> 94; comp stays
572/475. (The handoff's "+1 symbols" estimate was short:
the three return keys are three symbols, the N2526
precedent.)
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_estimate_dps import DEFERRED as N2528_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07BulletTypeEstimateDpsProof'
ESTIMATE_DPS_OWNER = 'SourceBulletTypeDamageState.source_bullet_type_estimate_dps_state'
TESTS = ['test_c07_bullet_type_estimate_dps_registration', 'test_all_c07_bullet_type_estimate_dps_input_evidence_is_exact', 'test_bullet_type_estimate_dps_state', 'test_reference_graph_and_actual_c07_bullet_type_estimate_dps']
# The slice sources the N2529 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'public float estimateDPS(){',
    'if(cachedDps >= 0f) return cachedDps;',
    'if(spawnUnit != null){',
    'return spawnUnit.estimateDps();',
    'if(despawnUnit != null){',
    'return despawnUnit.estimateDps();',
    'float sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : Mathf.clamp(pierceCap, 1, 2) : 1f);',
    'if(fragBullet != null && fragBullet != this){',
    'sum += fragBullet.estimateDPS() * fragBullets / 2f;',
    'for(var other : spawnBullets){',
    'sum += other.estimateDPS();',
    'return cachedDps = sum;',
    'public float damage = 1f;',
    'public boolean pierce;',
    'public int pierceCap = -1;',
    'public float splashDamage = 0f;',
    'public int fragBullets = 9;',
    'protected float cachedDps = -1;',
]

# DEFERRED is carried from the N2528 register script via import --
# never retyped. No entry is dropped: the BulletType.estimateDPS()
# computation the N2528 pool entry deferred is recorded DONE below.
# New entries below record the estimateDPS read as DONE by this
# slice, the Windows proof debt, and the wiring + consumers that
# still need a later slice.
DEFERRED = N2528_DEFERRED + [
    'BulletType.estimateDPS() (`estimate_dps` / `cached_dps` / `branch` frame keys) -- DONE by this slice (N2529): `source_bullet_type_estimate_dps_state` ports BulletType.java:414-435 for the BulletType family (cache hit `cachedDps >= 0f` first; spawnUnit / despawnUnit legs return the unit DPS WITHOUT writing the cache; computed leg `sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : clamp(pierceCap, 1, 2) : 1f)` + fragBullet recursion `* fragBullets / 2f` + the caller-summed spawnBullets DPS, returning the new cache value through `cached_dps`; `spawn_unit_dps` / `despawn_unit_dps` are float params because UnitType.estimateDps() (UnitType.java:1132-1144) is not ported yet; `has_frag_bullet` is the caller-side `fragBullet != this` guard; `spawn_bullets_dps_sum` is the caller-summed spawnBullets recursion). NO driver tick call site: estimateDPS() is a read/estimate, not per-tick, and no caller reads it today (the N2528 turret function still takes `peek_ammo_dps` as a param; HUD / stats display is C11). Dormant live today: no caller reads the function, so live behavior does not change. Java doc says "this can be very inaccurate" -- the function keeps the exact Java formula including that inaccuracy.',
    'BulletType.estimateDPS() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528: the N2529 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Wiring N2528 -> N2529 still DEFERRED (consumer slice after N2529): `source_turret_estimate_dps_state` still takes `peek_ammo_dps` as a float param; the consumer slice must call `source_bullet_type_estimate_dps_state` on the peeked ammo and pass the returned `estimate_dps` instead. The C11 HUD / stats display that reads `estimate_dps` is also a later slice.',
    'UnitType.estimateDps() (UnitType.java:1132-1144, `weapons.sumf(Weapon::dps)` + `/ 15f` on suicide via `bullet.killShooter`) still DEFERRED (slice after N2530): until it lands, `source_bullet_type_estimate_dps_state` takes `spawn_unit_dps` / `despawn_unit_dps` as float params.',
]


def definitions():
    def a(typ, expr, rule, source=BULLET_TYPE, **extra):
        return backed(typ, source, expr, rule, **extra)

    estimate_dps_inputs = {
        'damage': a('float', 'public float damage = 1f;', 'The base damage per hit (`public float damage = 1f;`, BulletType.java:41 -- the class default; per-def overrides in Blocks.java), the `damage` term of the sum.'),
        'splash_damage': a('float', 'public float splashDamage = 0f;', 'The splash damage (`public float splashDamage = 0f;`, BulletType.java:109 -- the class default), folded into the sum at 0.75x (`splashDamage*0.75f`, BulletType.java:424).'),
        'pierce': a('bool', 'public boolean pierce;', 'Whether the bullet pierces units (`public boolean pierce;`, BulletType.java:53 -- false by default); when false the pierce multiplier is 1.'),
        'pierce_cap': a('int', 'public int pierceCap = -1;', 'The maximum number of pierced objects (`public int pierceCap = -1;`, BulletType.java:57 -- -1 means uncapped, which doubles the sum; otherwise clamped to 1..2, `Mathf.clamp(pierceCap, 1, 2)`, BulletType.java:424).'),
        'cached_dps': a('float', 'protected float cachedDps = -1;', 'The runtime cache (`protected float cachedDps = -1;`, BulletType.java:377 -- -1 means "not computed yet"); `cachedDps >= 0f` is the cache-hit leg that returns first, and the computed leg returns the new cache value through the `cached_dps` result key (the pure function never mutates state outside).'),
        'has_spawn_unit': a('bool', 'if(spawnUnit != null){', 'Whether the bullet spawns a unit on hit (`if(spawnUnit != null){`, BulletType.java:417 -- the spawnUnit leg, BEFORE the computed sum).'),
        'spawn_unit_dps': a('float', 'return spawnUnit.estimateDps();', 'The spawned unit DPS (`return spawnUnit.estimateDps();`, BulletType.java:418); a float param, NOT computed in this slice, because UnitType.estimateDps() (UnitType.java:1132-1144) is not ported yet -- that is a later slice. The spawnUnit leg returns this value WITHOUT writing the cache.'),
        'has_despawn_unit': a('bool', 'if(despawnUnit != null){', 'Whether the bullet spawns a unit on despawn (`if(despawnUnit != null){`, BulletType.java:420 -- the despawnUnit leg, AFTER the spawnUnit leg).'),
        'despawn_unit_dps': a('float', 'return despawnUnit.estimateDps();', 'The despawned unit DPS (`return despawnUnit.estimateDps();`, BulletType.java:421); a float param, NOT computed in this slice, because UnitType.estimateDps() (UnitType.java:1132-1144) is not ported yet. The despawnUnit leg returns this value WITHOUT writing the cache.'),
        'has_frag_bullet': a('bool', 'if(fragBullet != null && fragBullet != this){', 'Whether a frag bullet exists and is not the bullet itself (`if(fragBullet != null && fragBullet != this){`, BulletType.java:425 -- the `fragBullet != this` guard); a bool param: the caller passes false when the frag bullet is the bullet itself (self-frag), the function cannot tell identity from a float param. When false, the frag term is skipped.'),
        'frag_bullet_dps': a('float', 'sum += fragBullet.estimateDPS() * fragBullets / 2f;', 'The frag bullet DPS (`sum += fragBullet.estimateDPS() * fragBullets / 2f;`, BulletType.java:426 -- the recursive frag computation); a float param, NOT computed in this slice: the caller supplies the frag bullet DPS (the recursion over the bullet catalog is the caller\'s value).'),
        'frag_bullets': a('int', 'public int fragBullets = 9;', 'The number of frag bullets (`public int fragBullets = 9;`, BulletType.java:212 -- the class default); the frag term is `frag_bullet_dps * frag_bullets / 2f`.'),
        'spawn_bullets_dps_sum': a('float', 'sum += other.estimateDPS();', 'The caller-summed `estimateDPS()` of every `spawnBullets` entry (`for(var other : spawnBullets){ sum += other.estimateDPS(); }`, BulletType.java:429-431 -- the recursion over the bullet catalog); a float param, NOT recomputed in the function: the caller sums the spawn bullets first.'),
    }
    estimate_dps_outputs = {
        'estimate_dps': a('float', 'public float estimateDPS(){', 'The estimated damage per shot (`public float estimateDPS(){`, BulletType.java:414 -- `@return estimated damage per shot. this can be very inaccurate.`; the cached value on the cache-hit leg, the unit DPS on the spawn/despawn legs, the computed sum otherwise).'),
        'cached_dps': a('float', 'return cachedDps = sum;', 'The cache value Java would store (`return cachedDps = sum;`, BulletType.java:433 -- the computed leg writes the cache; the cache-hit leg returns the input cache unchanged; the spawnUnit / despawnUnit legs return the input cache unchanged, because Java returns before the cache-write line).'),
        'branch': a('String', 'public float estimateDPS(){', 'Which leg of estimateDPS() fired (`public float estimateDPS(){`, BulletType.java:414 -- the four legs of the method): `cached` (cache hit), `spawn_unit`, `despawn_unit`, or `computed`. A port-side discriminator, not a Java field; it names the method leg, so it is backed by the method signature.'),
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
        ('N2529', ESTIMATE_DPS_OWNER, 'source_bullet_type_estimate_dps_state', BULLET_TYPE, 'mindustry.entities.bullet.BulletType', 'BulletType.estimateDPS()', estimate_dps_inputs, estimate_dps_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BulletType estimateDPS() read from BulletType.java:414-435.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BulletType estimateDPS() read from BulletType.java:414-435.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: estimate_dps, cached_dps, branch.
    by_slice['N2529'] = [
        'source_bullet_type_estimate_dps_state_result.estimate_dps',
        'source_bullet_type_estimate_dps_state_result.cached_dps',
        'source_bullet_type_estimate_dps_state_result.branch',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2529', dict(status='done', java_source=BULLET_TYPE, java_class='mindustry.entities.bullet.BulletType', java_method='BulletType.estimateDPS()', godot_owner=ESTIMATE_DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2529'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
