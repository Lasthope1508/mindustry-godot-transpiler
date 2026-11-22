"""Register the Turret estimateDps() read (N2528).

TurretBuild.estimateDps() (Turret.java:329-333):
`public float estimateDps(){` /
`if(!hasAmmo()) return 0f;` /
`return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;`.
`shoot.shots` is the ShootPattern field (`public int
shots = 1;`, ShootPattern.java:9 -- the class default;
per-def overrides in Blocks.java: salvo 2, ripple 4,
smite 2, malign 4, :3402/:3823/:3902/:4064), read from
the catalog shoot pattern state
(`shoot_state.get("shots", SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)`,
SourceWeaponShootPatternState.gd:36) -- NOT hardcoded
to 1. `reload` is the per-def reload time (`public float
reload = 10f;`, ReloadTurret.java:10, read from the
catalog `block.properties` with the 10.0 default, the
tick :2665 precedent -- NOT hardcoded to duo). `60f`
is the tick rate (`const TICK_RATE := 60.0`,
SourceTimeDefaults.gd:4 -- NOT a literal 60 in the
function). `potentialEfficiency` is the frame-stamped
efficiency fold (`self_state["potential_efficiency"] =
consumption_state["potential_efficiency"]`,
SourceBuildingEfficiencyState.gd:178; absent folds to
1.0, the N2527 missing-stamp precedent). `timeScale`
is the BuildingComp transient field (`private transient
float timeScale = 1f, timeScaleDuration;`,
BuildingComp.java:98), an explicit float param, NOT
read from the frame (the sense precedent --
source_building_comp_sense_state takes `time_scale`).
`has_ammo` is a bool param, NOT computed in the
function: hasAmmo() MUTATES the ammo stack
(`ammo.swap(ammo.size - 1, i);`, Turret.java:703), so
it cannot be a pure read (the N2527 precedent). The
peek leg (`peekAmmo() == null ? 0f : ...`) arrives as
the `has_peek_ammo` bool param (the N2526 precedent)
plus the `peek_ammo_dps` float param: the DPS value
itself comes from BulletType.estimateDPS() (`public
float estimateDPS(){`, BulletType.java:414 -- the
recursive frag/spawn computation with the cachedDps
cache), which is NOT computed in this slice (that is
the N2529 follow-up); this slice ports the turret
formula with the param. Java has NO divide-by-zero
guard for `reload` (every per-def reload > 0) --
parity keeps none. NO driver tick call site:
estimateDps() is a read function, not per-tick, and no
caller reads it today (HUD / stats display is C11).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_estimate_dps_state(frame, has_ammo,
has_peek_ammo, peek_ammo_dps, shots, reload,
time_scale), placed immediately AFTER
source_turret_status_state (N2527) and BEFORE
source_turret_can_heal_state. It returns exactly one
key, `estimate_dps` (a float). (2) NO tick call site
-- the function is DORMANT live today: the driver tick
never calls it, so live behavior does not change. (3)
`has_ammo` stays a bool param -- the function never
computes hasAmmo() itself, because hasAmmo() mutates
the ammo stack. (4) `peek_ammo_dps` stays a float
param -- BulletType.estimateDPS() is a separate slice
(N2529). SSOT expected after GREEN: symbols +1, Done
+1, contracts +1, schemas +2 (input + result),
11719/1756/1689/3169 -> 11720/1757/1690/3171; defense
shard slices 215 -> 216, contracts 214 -> 215; comp
stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_status import DEFERRED as N2527_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07TurretEstimateDpsProof'
ESTIMATE_DPS_OWNER = 'SourceTurretBuildState.source_turret_estimate_dps_state'
TESTS = ['test_c07_turret_estimate_dps_registration', 'test_all_c07_turret_estimate_dps_input_evidence_is_exact', 'test_turret_estimate_dps_state', 'test_reference_graph_and_actual_c07_turret_estimate_dps']
# The slice sources the N2528 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'public float estimateDps(){',
    'if(!hasAmmo()) return 0f;',
    'return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;',
    'public int shots = 1;',
    'public float reload = 10f;',
    'private transient float timeScale = 1f, timeScaleDuration;',
    'public float estimateDPS(){',
]

# DEFERRED is carried from the N2527 register script via import --
# never retyped. No entry is dropped: the estimateDps read the
# N2527 pool entry deferred is recorded DONE below. New entries
# below record the estimateDps read as DONE by this slice, the
# Windows proof debt, and the BulletType.estimateDPS() live
# computation + the C11 estimateDps consumers that still need wiring.
DEFERRED = N2527_DEFERRED + [
    'Turret estimateDps() (`estimate_dps` frame key) -- DONE by this slice (N2528): `source_turret_estimate_dps_state` ports Turret.java:329-333 for the Turret family (`!hasAmmo()` -> 0.0 first; `peekAmmo() == null ? 0f` leg via the `has_peek_ammo` bool + `peek_ammo_dps` float params; `float(shots) / reload * TICK_RATE * peek_ammo_dps * potential_efficiency * time_scale`, with `shots` the ShootPattern per-def field (default 1, ShootPattern.java:9) read from the catalog shoot pattern state, `reload` the per-def reload time (ReloadTurret.java:10) from `block.properties`, `60f` as SourceTimeDefaults.TICK_RATE, `potential_efficiency` from the frame (default 1.0) and `time_scale` an explicit float param (BuildingComp.java:98)). NO driver tick call site: estimateDps() is a read function, not per-tick, and no caller reads it today (HUD / stats display is C11). Dormant live today: the driver tick never calls the function, so live behavior does not change. Java has NO divide-by-zero guard for `reload` -- parity keeps none.',
    'Turret estimateDps() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527: the N2528 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BulletType.estimateDPS() live computation still DEFERRED (after N2528, candidate N2529): `source_turret_estimate_dps_state` takes `peek_ammo_dps` as a float param because BulletType.estimateDPS() (BulletType.java:414-435) is a recursive computation over the bullet catalog (`sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : clamp(pierceCap, 1, 2) : 1f)` + fragBullet recursion `* fragBullets / 2f` + spawnBullets recursion; the spawnUnit/despawnUnit branches call UnitType.estimateDps(); `cachedDps` is a runtime cache, not part of the pure function) and has not been ported yet; until it lands, callers must supply the peek ammo DPS. The C11 HUD / stats display that reads `estimate_dps` is also a later slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    estimate_dps_inputs = {
        'frame': a('Dictionary', 'return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;', 'The turret frame (the port Building state) the tick stamps every tick (`public void updateTile(){`, Turret.java:490 -- the driver tick for every Turret-family build); it carries `potential_efficiency` (stamped every tick by the driver via apply_update_consumption_state, `self_state["potential_efficiency"] = consumption_state["potential_efficiency"]`, SourceBuildingEfficiencyState.gd:178; absent folds to 1.0, the N2527 missing-stamp precedent).'),
        'has_ammo': a('bool', 'if(!hasAmmo()) return 0f;', 'Whether the turret has ammo (`if(!hasAmmo()) return 0f;`, Turret.java:330 -- the first leg, BEFORE the formula); a bool param, NOT computed in the function, because hasAmmo() MUTATES the ammo stack (`ammo.swap(ammo.size - 1, i);`, Turret.java:703) and cannot be a pure read. The boolean equivalent (no swap) is `canConsume() && size > 0 && (any entry amount >= ammoPerShot || cheating())` -- the swap only moves a sufficient entry to peek, it never changes the boolean; the live computation is a follow-up.'),
        'has_peek_ammo': a('bool', '(peekAmmo() == null ? 0f : peekAmmo().estimateDPS())', 'Whether the peeked ammo exists (`peekAmmo() == null ? 0f : peekAmmo().estimateDPS()`, Turret.java:331 -- the peek leg); a bool param (the N2526 precedent: `peekAmmo() != null` is the ammo stack non-empty, NOT hasAmmo(), which also folds canConsume(), Turret.java:705-708). When false, the DPS term folds to 0.0.'),
        'peek_ammo_dps': a('float', 'public float estimateDPS(){', 'The estimated DPS of the peeked ammo (`peekAmmo().estimateDPS()`, Turret.java:331); a float param, NOT computed in this slice, because BulletType.estimateDPS() (BulletType.java:414-435) is a recursive computation over the bullet catalog (fragBullet / spawnBullets recursion, spawnUnit/despawnUnit branches calling UnitType.estimateDps(), `cachedDps` runtime cache) -- that is the N2529 follow-up. Until it lands, callers supply the peek ammo DPS.', source=BULLET_TYPE),
        'shots': a('int', 'public int shots = 1;', 'The shots per trigger pull (`shoot.shots`, Turret.java:331 -- `public int shots = 1;`, ShootPattern.java:9, the class default; per-def overrides in Blocks.java: salvo 2, ripple 4, smite 2, malign 4, :3402/:3823/:3902/:4064), read from the catalog shoot pattern state (`shoot_state.get("shots", SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)`, SourceWeaponShootPatternState.gd:36) -- NOT hardcoded to 1.', source=SHOOT_PATTERN),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time in ticks (`public float reload = 10f;`, ReloadTurret.java:10 -- the class default; duo 20f, foreshadow 200f, Blocks.java): the `shoot.shots / reload` rate half of the formula, read from the catalog `block.properties` with the 10.0 default (the tick :2665 precedent). Java has NO divide-by-zero guard for `reload` (every per-def reload > 0) -- parity keeps none.', source=RELOAD_TURRET),
        'time_scale': a('float', 'private transient float timeScale = 1f, timeScaleDuration;', 'The Building time scale (`private transient float timeScale = 1f, timeScaleDuration;`, BuildingComp.java:98 -- the `* timeScale` factor of the formula); it arrives as an explicit float param, not from the frame (the sense precedent -- the driver stamps no time_scale key).', source=BUILDING_COMP),
    }
    estimate_dps_outputs = {
        'estimate_dps': a('float', 'public float estimateDps(){', 'The estimated damage per second (`public float estimateDps(){`, Turret.java:329 -- `shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale`, Turret.java:331; 0.0 when the turret has no ammo).'),
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
        ('N2528', ESTIMATE_DPS_OWNER, 'source_turret_estimate_dps_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.estimateDps()', estimate_dps_inputs, estimate_dps_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret estimateDps() read from Turret.java:329-333 + ShootPattern.java:9 + ReloadTurret.java:10 + BuildingComp.java:98 + BulletType.java:414.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret estimateDps() read from Turret.java:329-333 + ShootPattern.java:9 + ReloadTurret.java:10 + BuildingComp.java:98 + BulletType.java:414.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: estimate_dps.
    by_slice['N2528'] = [
        'source_turret_estimate_dps_state_result.estimate_dps',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2528', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.estimateDps()', godot_owner=ESTIMATE_DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2528'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
