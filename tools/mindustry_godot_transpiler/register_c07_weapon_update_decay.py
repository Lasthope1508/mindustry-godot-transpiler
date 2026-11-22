"""Register the Weapon update() leg 1 decay (N2540).

Weapon.update() leg 1 (Weapon.java:293-306):
`boolean can = unit.canShoot();` /
`float lastReload = mount.reload;` /
`mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);` /
`mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);` /
`if(recoils > 0){` /
`if(mount.recoils == null) mount.recoils = new float[recoils];` /
`for(int i = 0; i < recoils; i++){` /
`mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);` /
`}` /
`}` /
`mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);` /
`mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;` /
`float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;` /
`if(linearWarmup){` /
`mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);` /
`}` /
`mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);`.
update() is a large tick method, so it is ported leg by
leg in source order; leg 1 is the pure decay head. `can`
is the `unit.canShoot()` frame bool, taken as an input
(canShoot() itself is NOT re-ported here). `lastReload`
(:294) is NOT returned by leg 1 -- the side-flip leg
(Weapon.java:427-432) captures the pre-decay reload in a
later slice. NO driver tick call site: update() has no
driver in the port yet, and no caller reads the new
function today.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_update_decay_state(20 params), placed
immediately AFTER source_weapon_range_state (the N2539
function) and BEFORE set_rotation_state, plus a one-line
delegate of the same name on SourceWeaponsState.gd (the
setup_mounts_state facade precedent). It returns the six
keys `reload` / `recoil` / `recoils` / `smooth_reload` /
`charge` / `warmup` on every call (the N2526 precedent --
every return key is a symbol). (2) NO tick call site --
the function is DORMANT live today: no caller reads it,
so live behavior does not change. (3) Order traps kept:
smoothReload lerps toward the UPDATED reload
(`reload' / reload`, :302 runs after :294); recoilTime
default -1f is passed through unchanged, NOT clamped or
defaulted; an empty `mount_recoils` Array is the GDScript
representation of Java `mount.recoils == null` (allocate
zeros of length `recoils`, then decay each element);
`recoils <= 0` skips the block and returns the input
array untouched; the charge else-branch returns exactly
0 (the old charge is NOT kept); warmupTarget is the
3-leg OR in source order.
SSOT expected after GREEN: symbols +6, Done +1,
contracts +1, schemas +2 (input + result),
11751/1768/1701/3193 -> 11757/1769/1702/3195; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_range import DEFERRED as N2539_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
PROOF = '/root/C07WeaponUpdateDecayProof'
UPDATE_DECAY_OWNER = 'SourceWeaponsCoreState.source_weapon_update_decay_state'
TESTS = ['test_c07_weapon_update_decay_registration', 'test_all_c07_weapon_update_decay_input_evidence_is_exact', 'test_weapon_update_decay_state', 'test_reference_graph_and_actual_c07_weapon_update_decay']
# The slice sources the N2540 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
]
EXACT_EXPRS = [
    'boolean can = unit.canShoot();',
    'mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);',
    'mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);',
    'if(mount.recoils == null) mount.recoils = new float[recoils];',
    'mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);',
    'mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;',
    'float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;',
    'mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);',
    'mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);',
]

# DEFERRED is carried from the N2539 register script via import --
# never retyped. No entry is dropped: the Weapon.range()
# consumer entry the N2539 pool recorded deferred stays
# deferred below (it is a UnitType.init / shootLength
# consumer, not this slice), and the DrawPart subsystem +
# Windows proof debt stay deferred below.
# New entries below record the update() leg 1 decay as DONE
# by this slice, the Windows proof debt, and the remaining
# update() legs that still need later slices.
DEFERRED = N2539_DEFERRED + [
    'Weapon.update() leg 1 decay (`reload` / `recoil` / `recoils` / `smooth_reload` / `charge` / `warmup` frame keys) -- DONE by this slice (N2540): `source_weapon_update_decay_state` ports Weapon.java:293-306 for the Weapon family. `can` is the `unit.canShoot()` frame bool, taken as an input (canShoot() itself is NOT re-ported here). `lastReload` (:294) is NOT returned by leg 1 -- the side-flip leg (Weapon.java:427-432) captures the pre-decay reload in a later slice. NO driver tick call site: update() has no driver in the port yet, and no caller reads the function today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.update() leg 1 Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/N2538/N2539: the N2540 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.update() remaining legs still DEFERRED (later slices): leg 2 mountX/mountY + weaponRotation/bulletX/bulletY + bulletRotation() (Weapon.java:307-310, :385-391, :455-457, pure); leg 3 auto-target block (Weapon.java:311-349, BLOCKED -- findTarget :447 live Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget, Predict.intercept not ported); leg 4 rotate block (Weapon.java:351-367, pure with aimX/aimY + targetRotation inputs); leg 5 continuous-laser leg (Weapon.java:376-411, bullet entity live -- BLOCKED as a driver leg; shootLength :391 uses range() N2539 + approachDelta, pure); leg 6 heat decay + sound (Weapon.java:413-424, heat decay pure, sound skipped); leg 7 side-flip leg (Weapon.java:427-432, pure with otherSide mount side + mounts.length + pre-decay lastReload captured from leg 1); leg 8 shoot gate (Weapon.java:437-451, boolean conjunction with frame inputs; shoot() :459 / bullet() :487 / handleBullet() :529 live spawn -- defer). flip() :544 needs ShootPattern.copy()/flip() (port status unchecked) -- defer. init() :562 trivial (alwaysContinuous -> continuous) -- micro-slice later. addStats() :175-187 UI stats, C11-ish -- defer.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_decay_inputs = {
        'mount_reload': a('float', 'public float reload;', 'The mount reload in frames (`public float reload;`, WeaponMount.java:12 -- reload in frames; 0 means ready to fire; the pre-decay value, decayed by `mount.reload - Time.delta * unit.reloadMultiplier` clamped at 0, Weapon.java:294).', source=WEAPON_MOUNT),
        'mount_recoil': a('float', 'public float recoil;', 'The mount recoil (`public float recoil;`, WeaponMount.java:16 -- weapon recoil; approached toward 0 by `unit.reloadMultiplier / recoilTime`, Weapon.java:296).', source=WEAPON_MOUNT),
        'mount_recoils': a('Array', 'public @Nullable float[] recoils;', 'The mount per-barrel recoils (`public @Nullable float[] recoils;`, WeaponMount.java:18 -- weapon barrel recoil; an empty Array is the GDScript representation of Java null, allocated as zeros of length `recoils` then decayed element-wise, Weapon.java:297-302; `recoils <= 0` leaves the input array untouched).', source=WEAPON_MOUNT),
        'mount_smooth_reload': a('float', 'public float smoothReload;', 'The mount smooth reload (`public float smoothReload;`, WeaponMount.java:30 -- lerps to reload time; lerped toward the UPDATED reload `reload\' / reload`, Weapon.java:303).', source=WEAPON_MOUNT),
        'mount_charge': a('float', 'public float charge;', 'The mount charge (`public float charge;`, WeaponMount.java:28 -- counts up to 1 when charging, 0 when not; approached toward 1 while charging with a positive firstShotDelay, else exactly 0, Weapon.java:304).', source=WEAPON_MOUNT),
        'mount_charging': a('bool', 'public boolean charging;', 'Whether the mount is actively charging (`public boolean charging;`, WeaponMount.java:26 -- is the weapon actively charging; gates the charge approach and is one leg of warmupTarget, Weapon.java:304-306).', source=WEAPON_MOUNT),
        'mount_shoot': a('bool', 'public boolean shoot = false;', 'Whether the mount shoots right now (`public boolean shoot = false;`, WeaponMount.java:34 -- whether to shoot right now; with `can` it is the first leg of warmupTarget, Weapon.java:306).', source=WEAPON_MOUNT),
        'mount_warmup': a('float', 'public float warmup;', 'The mount warmup (`public float warmup;`, WeaponMount.java:24 -- lerps to 1 when shooting, 0 when not; approached (linearWarmup) or lerped toward warmupTarget, Weapon.java:307-310).', source=WEAPON_MOUNT),
        'has_continuous_bullet': a('bool', 'public @Nullable Bullet bullet;', 'Whether the mount has a continuous bullet (`public @Nullable Bullet bullet;`, WeaponMount.java:47 -- current bullet for continuous weapons; `mount.bullet != null` with `continuous` is the second leg of warmupTarget, Weapon.java:306).', source=WEAPON_MOUNT),
        'recoils': a('int', 'public int recoils = -1;', 'The weapon barrel-recoil count (`public int recoils = -1;`, Weapon.java:83 -- number of additional counters for recoil; the per-barrel decay block runs only when `recoils > 0`, Weapon.java:297).'),
        'recoil_time': a('float', 'public float recoilTime = -1f;', 'The weapon recoil return time in ticks (`public float recoilTime = -1f;`, Weapon.java:85 -- time taken for weapon to return to starting position in ticks, uses reload time by default; passed through unchanged, NOT clamped or defaulted, Weapon.java:296/300).'),
        'weapon_reload': a('float', 'public float reload = 1;', 'The weapon reload in frames (`public float reload = 1;`, Weapon.java:75 -- weapon reload in frames; the denominator of the smoothReload target `mount.reload / reload`, Weapon.java:303).'),
        'smooth_reload_speed': a('float', 'public float shootWarmupSpeed = 0.1f, smoothReloadSpeed = 0.15f;', 'The smooth reload lerp speed (`public float shootWarmupSpeed = 0.1f, smoothReloadSpeed = 0.15f;`, Weapon.java:111 -- lerp speed for shoot warmup, only used for parts; smoothReloadSpeed is the smoothReload lerpDelta progress, Weapon.java:303).'),
        'first_shot_delay': a('float', 'public float firstShotDelay = 0;', 'The shoot-pattern first-shot delay (`public float firstShotDelay = 0;`, ShootPattern.java:11 -- the delay before the first shot; the charge approach speed is `1 / shoot.firstShotDelay` and only applies while it is positive, Weapon.java:304).', source=SHOOT_PATTERN),
        'shoot_warmup_speed': a('float', 'public float shootWarmupSpeed = 0.1f, smoothReloadSpeed = 0.15f;', 'The shoot warmup speed (`public float shootWarmupSpeed = 0.1f, smoothReloadSpeed = 0.15f;`, Weapon.java:111 -- lerp speed for shoot warmup, only used for parts; the warmup approachDelta / lerpDelta progress, Weapon.java:308/310).'),
        'linear_warmup': a('bool', 'public boolean linearWarmup = false;', 'Whether shoot warmup is linear (`public boolean linearWarmup = false;`, Weapon.java:113 -- if true, shoot warmup is linear instead of a curve; selects approachDelta over lerpDelta for warmup, Weapon.java:307-310).'),
        'continuous': a('bool', 'public boolean continuous;', 'Whether the weapon is continuous (`public boolean continuous;`, Weapon.java:53 -- with `mount.bullet != null` it is the second leg of warmupTarget, Weapon.java:306).'),
        'can': a('bool', 'boolean can = unit.canShoot();', 'The unit canShoot() frame bool (`boolean can = unit.canShoot();`, Weapon.java:293 -- taken as a bool input; canShoot() itself is NOT re-ported here; with `mount.shoot` it is the first leg of warmupTarget, Weapon.java:306).'),
        'source_delta': a('float', 'mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);', 'The frame delta (`Time.delta`, Weapon.java:294 -- the reload decay step and the approachDelta / lerpDelta time base).'),
        'reload_multiplier': a('float', 'mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);', 'The unit reload multiplier (`unit.reloadMultiplier`, Weapon.java:294 -- scales the reload decay and the recoil approach speed).'),
    }
    update_decay_outputs = {
        'reload': a('float', 'mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);', 'The decayed mount reload (`mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);`, Weapon.java:294 -- reload decayed by delta * reloadMultiplier, clamped at 0).'),
        'recoil': a('float', 'mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);', 'The approached mount recoil (`mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);`, Weapon.java:296 -- recoil approached toward 0).'),
        'recoils': a('Array', 'mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);', 'The decayed per-barrel recoils (`mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);`, Weapon.java:300 -- each barrel recoil approached toward 0; null input is allocated as zeros first, Weapon.java:298).'),
        'smooth_reload': a('float', 'mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);', 'The lerped smooth reload (`mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);`, Weapon.java:303 -- lerps toward the UPDATED reload over weapon reload).'),
        'charge': a('float', 'mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;', 'The gated mount charge (`mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;`, Weapon.java:304 -- approaches 1 while charging with a positive firstShotDelay, else exactly 0).'),
        'warmup': a('float', 'mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);', 'The warmed-up mount warmup (`mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);`, Weapon.java:308 -- linearWarmup leg; the lerp leg is `mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);`, Weapon.java:310; warmupTarget is the 3-leg OR of Weapon.java:306).'),
    }
    return update_decay_inputs, update_decay_outputs


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
    update_decay_inputs, update_decay_outputs = definitions()

    entries = [
        ('N2540', UPDATE_DECAY_OWNER, 'source_weapon_update_decay_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.update()', update_decay_inputs, update_decay_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 1 decay from Weapon.java:293-306.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 1 decay from Weapon.java:293-306.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: reload, recoil, recoils,
    # smooth_reload, charge, warmup (source order of the
    # update() leg 1 assignments).
    by_slice['N2540'] = [
        'source_weapon_update_decay_state_result.reload',
        'source_weapon_update_decay_state_result.recoil',
        'source_weapon_update_decay_state_result.recoils',
        'source_weapon_update_decay_state_result.smooth_reload',
        'source_weapon_update_decay_state_result.charge',
        'source_weapon_update_decay_state_result.warmup',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2540', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.update()', godot_owner=UPDATE_DECAY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2540'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
