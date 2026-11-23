"""Register the Weapon update() leg 3 heat decay (N2542).

Weapon.update() leg 3 (Weapon.java:376, :409-415):
`if(continuous && mount.bullet != null){` /
`//heat decreases when not firing` /
`mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);` /
`if(mount.sound != null){` /
`mount.sound.update(bulletX, bulletY, false);` /
`}`.
The decay runs ONLY in the else-branch -- when NOT
(continuous && mount.bullet != null). The
`mount.sound.update(bulletX, bulletY, false)` line is
audio -- SKIP (the N2541 activeSound skip precedent).
update() is a large tick method, so it is ported leg by
leg in source order; leg 3 is the pure heat-decay leg.
NO driver tick call site: update() has no driver in
the port yet, and no caller reads the new function
today.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_update_heat_state(6 params), placed
immediately AFTER source_weapon_update_aim_state (the
N2541 function) and BEFORE set_rotation_state, plus a
one-line delegate of the same name on
SourceWeaponsState.gd (the setup_mounts_state facade
precedent). It returns the single key `heat` on every
call (the N2526 precedent -- every return key is a
symbol). (2) NO tick call site -- the function is
DORMANT live today: no caller reads it, so live
behavior does not change. (3) Guard kept: heat is
returned unchanged when continuous && bullet present;
otherwise it decays by `source_delta *
reload_multiplier / cooldown_time`, clamped at 0 with
Math.max (:411). `cooldown_time` is a param (default
20f, Weapon.java:89), NOT hard-coded.
SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schemas +2 (input + result),
11766/1770/1703/3197 -> 11767/1771/1704/3199; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_update_aim import DEFERRED as N2541_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
PROOF = '/root/C07WeaponUpdateHeatProof'
UPDATE_HEAT_OWNER = 'SourceWeaponsCoreState.source_weapon_update_heat_state'
TESTS = ['test_c07_weapon_update_heat_registration', 'test_all_c07_weapon_update_heat_input_evidence_is_exact', 'test_weapon_update_heat_state', 'test_reference_graph_and_actual_c07_weapon_update_heat']
# The slice sources the N2542 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
]
EXACT_EXPRS = [
    'public float cooldownTime = 20f;',
    'if(continuous && mount.bullet != null){',
    '//heat decreases when not firing',
    'mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);',
    'if(mount.sound != null){',
    'mount.sound.update(bulletX, bulletY, false);',
]

# DEFERRED is carried from the N2541 register script via import --
# never retyped. No entry is dropped: the Weapon.update()
# leg 3 entry the N2541 pool recorded deferred stays
# deferred below (it is superseded by this slice's DONE
# entry, not deleted), and the DrawPart subsystem +
# Windows proof debt stay deferred below.
# New entries below record the update() leg 3 heat decay
# as DONE by this slice, the Windows proof debt,
# and the remaining update() legs that still need later slices.
DEFERRED = N2541_DEFERRED + [
    'Weapon.update() leg 3 heat decay (`heat` frame key) -- DONE by this slice (N2542): `source_weapon_update_heat_state` ports Weapon.java:376, :409-415 for the Weapon family. The decay runs ONLY in the else-branch -- when NOT (continuous && mount.bullet != null); when the continuous bullet is live, heat is returned unchanged. Decay is `source_delta * reload_multiplier / cooldown_time`, clamped at 0 with Math.max (:411). `cooldown_time` is a param (default 20f, Weapon.java:89), NOT hard-coded. The `mount.sound.update(bulletX, bulletY, false)` line (:413-415) is audio -- SKIP (the N2541 activeSound skip precedent). NO driver tick call site: update() has no driver in the port yet, and no caller reads the function today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.update() leg 3 Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/N2538/N2539/N2540/N2541: the N2542 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.update() remaining legs still DEFERRED (later slices): auto-target block (Weapon.java:315-347, BLOCKED -- findTarget :447 live Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget, Predict.intercept not ported); continuous-laser leg (Weapon.java:376-408, bullet entity live -- BLOCKED as a driver leg; shootLength :391 uses range() N2539 + approachDelta, pure); side-flip leg (Weapon.java:418-423, pure with `lastReload` :294 as a separate frame input -- leg 1 only returns the post-decay reload -- candidate N2543); activeSound (Weapon.java:425-427, audio -- skip); shoot gate + shoot() (Weapon.java:429-444, BLOCKED/live -- shoot() spawns a real bullet, :459+; velLen needs unit.isRemote/deltaLen live). flip() :544 needs ShootPattern.copy()/flip() (port status unchecked) -- defer. init() :562 trivial (alwaysContinuous -> continuous) -- micro-slice later. addStats() :175-187 UI stats, C11-ish -- defer.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_heat_inputs = {
        'mount_heat': a('float', 'public float heat;', 'The mount heat (`/** current heat, 0 to 1*/ public float heat;`, WeaponMount.java:21-22 -- the heat value decayed by the else-branch, Weapon.java:411, and returned unchanged when the continuous bullet is live).', source=WEAPON_MOUNT),
        'source_delta': a('float', 'Time.delta * unit.reloadMultiplier / cooldownTime', 'The frame delta (`Time.delta`, Weapon.java:411 -- the decay step is `Time.delta * unit.reloadMultiplier / cooldownTime`).'),
        'reload_multiplier': a('float', 'Time.delta * unit.reloadMultiplier / cooldownTime', 'The unit reload multiplier (`unit.reloadMultiplier`, Weapon.java:411 -- scales the decay step).'),
        'cooldown_time': a('float', 'public float cooldownTime = 20f;', 'The weapon cooldown time (`/** ticks to cool down the heat region */ public float cooldownTime = 20f;`, Weapon.java:89 -- the decay divisor; passed as a param, NOT hard-coded).'),
        'continuous': a('bool', 'public boolean continuous;', 'Whether the weapon is continuous (`public boolean continuous;`, Weapon.java:53 -- the first leg of the :376 guard; when true AND a bullet is live, the else-branch does NOT run).'),
        'has_continuous_bullet': a('bool', 'if(continuous && mount.bullet != null){', 'Whether a continuous bullet is live (`mount.bullet != null`, Weapon.java:376 -- the second leg of the guard; a bool input for the null-check, the N2540 precedent).'),
    }
    update_heat_outputs = {
        'heat': a('float', 'mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);', 'The updated mount heat (`mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);`, Weapon.java:411 -- decayed by the else-branch, clamped at 0; unchanged when continuous && bullet present).'),
    }
    return update_heat_inputs, update_heat_outputs


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
    update_heat_inputs, update_heat_outputs = definitions()

    entries = [
        ('N2542', UPDATE_HEAT_OWNER, 'source_weapon_update_heat_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.update()', update_heat_inputs, update_heat_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 3 heat decay from Weapon.java:376, :409-415.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 3 heat decay from Weapon.java:376, :409-415.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: heat (the single return
    # key of the update() leg 3 heat decay).
    by_slice['N2542'] = [
        'source_weapon_update_heat_state_result.heat',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2542', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.update()', godot_owner=UPDATE_HEAT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2542'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
