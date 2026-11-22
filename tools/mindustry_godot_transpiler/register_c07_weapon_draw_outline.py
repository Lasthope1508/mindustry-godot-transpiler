"""Register the Weapon drawOutline() read (N2537).

Weapon.drawOutline() (Weapon.java:196-213):
`public void drawOutline(Unit unit, WeaponMount mount){` /
`if(!outlineRegion.found()) return;` /
`rotation = unit.rotation - 90,` /
`realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
`weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
`wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
`wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
`Draw.xscl = -Mathf.sign(flipSprite);` /
`Draw.rect(outlineRegion, wx, wy, weaponRotation);` /
`Draw.xscl = 1f;`.
`outline_found` is a bool param: the guard is first in Java,
and the port mirrors the draw_team_top_state precedent
(SourceBuildingDrawState.gd:159-163, which takes
`team_region_found` as its first param and returns
`{"visible": false}` when the region is not found) -- when
the outline region is not found, drawOutline() returns
before computing anything, so this function returns only
`visible: false` and no draw keys. The found branch returns
exactly the five keys `visible`, `outline_x`, `outline_y`,
`weapon_rotation`, `xscl`. `xscl` is `-Mathf.sign(flipSprite)`;
arc Mathf.sign(boolean) (Mathf.java:203-205) is 1 if true
else -1, so xscl is -1.0 when flip_sprite is true and +1.0
otherwise. The trns legs reuse the existing port: no scalar
trnsx/trnsy port exists, and `source_angles_trns_vec`
(SourceMathState.gd:140) computes exactly
Angles.trnsx/trnsy(angle, x, y) (arc Angles.java:74-82).
The intermediates `rotation` / `real_recoil` are NOT return
keys -- they are encoded in `outline_x` / `outline_y` /
`weapon_rotation`. The `Draw.xscl = 1f;` reset after
Draw.rect is render-state restore, not a return value.
NO driver tick call site: drawOutline() is draw code,
rendering is outside the game, and no caller reads it
today (its only Java caller is draw() when `top` is true,
Weapon.java:227-229, itself draw code; the draw() port is
a later slice).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_draw_outline_state(outline_found,
unit_rotation, unit_x, unit_y, mount_recoil, mount_rotation,
rotate, base_rotation, recoil, recoil_pow, weapon_x, weapon_y,
flip_sprite), placed immediately AFTER
source_weapon_shots_per_sec_state (the N2535 function) and
BEFORE set_rotation_state, plus a one-line delegate of the
same name on SourceWeaponsState.gd (the setup_mounts_state
facade precedent). It returns `{"visible": false}` when the
outline region is not found and the five draw keys otherwise
(the N2526 precedent -- every return key is a symbol).
(2) NO tick call site -- the function is DORMANT live today:
no caller reads it, so live behavior does not change.
(3) All 13 params stay field params (defaults: outline
region found; unit_rotation 90; unit 0,0; mount_recoil 0;
mount_rotation 0; rotate false; base_rotation 0; recoil 1.5;
recoil_pow 1.8; weapon x 5, y 0; flip_sprite false).
SSOT expected after GREEN: symbols +5, Done +1,
contracts +1, schemas +2 (input + result),
11732/1765/1698/3187 -> 11737/1766/1699/3189; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_unit_type_weapons_dps_sum import DEFERRED as N2536_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
PROOF = '/root/C07WeaponDrawOutlineProof'
DRAW_OUTLINE_OWNER = 'SourceWeaponsCoreState.source_weapon_draw_outline_state'
TESTS = ['test_c07_weapon_draw_outline_registration', 'test_all_c07_weapon_draw_outline_input_evidence_is_exact', 'test_weapon_draw_outline_state', 'test_reference_graph_and_actual_c07_weapon_draw_outline']
# The slice sources the N2537 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
]
EXACT_EXPRS = [
    'public void drawOutline(Unit unit, WeaponMount mount){',
    'if(!outlineRegion.found()) return;',
    'rotation = unit.rotation - 90,',
    'realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,',
    'weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),',
    'wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),',
    'wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);',
    'Draw.xscl = -Mathf.sign(flipSprite);',
    'Draw.rect(outlineRegion, wx, wy, weaponRotation);',
]

# DEFERRED is carried from the N2536 register script via import --
# never retyped. No entry is dropped: the Wiring N2533 -> N2534
# entry the N2535 pool recorded deferred is recorded DONE by
# N2536, and the sum -> estimateDps wiring stays deferred below.
# New entries below record the drawOutline() read as DONE by
# this slice, the Windows proof debt, and the consumer that
# still needs a later slice.
DEFERRED = N2536_DEFERRED + [
    'Weapon.drawOutline() (`visible` / `outline_x` / `outline_y` / `weapon_rotation` / `xscl` frame keys) -- DONE by this slice (N2537): `source_weapon_draw_outline_state` ports Weapon.java:196-213 for the Weapon family (guard `if(!outlineRegion.found()) return;` first -- the draw_team_top_state precedent returns only `{"visible": false}` when not found; otherwise `rotation = unit.rotation - 90`, `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil`, `weaponRotation = rotation + (rotate ? mount.rotation : baseRotation)`, wx/wy via the existing `source_angles_trns_vec` port of Angles.trnsx/trnsy, `xscl = -Mathf.sign(flipSprite)` with arc Mathf.sign(boolean) = 1 if true else -1). The intermediates `rotation` / `real_recoil` are NOT return keys -- they are encoded in `outline_x` / `outline_y` / `weapon_rotation`. NO driver tick call site: drawOutline() is draw code, rendering is outside the game, and no caller reads it today (its only Java caller is draw() when `top` is true, Weapon.java:227-229, itself draw code). Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.drawOutline() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536: the N2537 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.drawOutline() consumers still DEFERRED (later slices): Weapon.draw() (Weapon.java:214+, `if(top){ drawOutline(unit, mount); }`) is a later slice -- the draw call that reads `outline_x` / `outline_y` / `weapon_rotation` / `xscl` and issues the Draw.rect is draw code, rendering outside the game.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_outline_inputs = {
        'outline_found': a('bool', 'if(!outlineRegion.found()) return;', 'Whether the outline region exists (`if(!outlineRegion.found()) return;`, Weapon.java:197 -- the guard is first in Java; the draw_team_top_state precedent takes `team_region_found` as its first param and returns `{"visible": false}` when not found); a bool param, default true.'),
        'unit_rotation': a('float', 'rotation = unit.rotation - 90,', 'The owning unit rotation in degrees (`rotation = unit.rotation - 90,`, Weapon.java:201 -- the aim rotation the weapon outline is drawn relative to, default 90 for a fresh unit).'),
        'unit_x': a('float', 'wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),', 'The owning unit x position (`wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),`, Weapon.java:204 -- the outline x is unit.x plus the rotated weapon offset plus the recoil offset).'),
        'unit_y': a('float', 'wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);', 'The owning unit y position (`wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);`, Weapon.java:205 -- the outline y is unit.y plus the rotated weapon offset plus the recoil offset).'),
        'mount_recoil': a('float', 'public float recoil;', 'The mount recoil (`public float recoil;`, WeaponMount.java:16 -- "weapon recoil"; the mount recoil the real recoil is powered from, default 0 for a fresh mount).', source=WEAPON_MOUNT),
        'mount_rotation': a('float', 'public float rotation;', 'The mount rotation in degrees (`public float rotation;`, WeaponMount.java:14 -- "rotation relative to the unit this mount is on"; used when `rotate` is true, default the weapon base rotation).', source=WEAPON_MOUNT),
        'rotate': a('bool', 'public boolean rotate = false;', 'Whether the weapon rotates toward the target independently of the unit (`public boolean rotate = false;`, Weapon.java:45 -- "whether to rotate toward the target independently of unit"; `ROTATE_DEFAULT := false` in SourceWeaponDefaults.gd); a bool param, default false.'),
        'base_rotation': a('float', 'public float baseRotation = 0f;', 'The rotation at which this weapon starts at (`public float baseRotation = 0f;`, Weapon.java:49 -- "rotation at which this weapon starts at."; `BASE_ROTATION_DEFAULT := 0.0` in SourceWeaponDefaults.gd); used when `rotate` is false.'),
        'recoil': a('float', 'public float recoil = 1.5f;', 'The visual weapon knockback (`public float recoil = 1.5f;`, Weapon.java:81 -- "visual weapon knockback."); the real recoil is `Mathf.pow(mount.recoil, recoilPow) * recoil`.'),
        'recoil_pow': a('float', 'public float recoilPow = 1.8f;', 'The power curve applied to visual recoil (`public float recoilPow = 1.8f;`, Weapon.java:87 -- "power curve applied to visual recoil").'),
        'weapon_x': a('float', 'public float x = 5f, y = 0f;', 'The weapon x offset on the unit (`public float x = 5f, y = 0f;`, Weapon.java:93 -- "offsets of weapon position on unit"); the base offset is Angles.trnsx/trnsy(rotation, x, y).'),
        'weapon_y': a('float', 'public float x = 5f, y = 0f;', 'The weapon y offset on the unit (`public float x = 5f, y = 0f;`, Weapon.java:93 -- "offsets of weapon position on unit"); the base offset is Angles.trnsx/trnsy(rotation, x, y).'),
        'flip_sprite': a('bool', 'public boolean flipSprite = false;', 'Whether to flip the weapon sprite when rendering (`public boolean flipSprite = false;`, Weapon.java:41 -- "whether to flip the weapon\'s sprite when rendering. internal use only - do not set!"; `FLIP_SPRITE_DEFAULT := false` in SourceWeaponDefaults.gd); `xscl = -Mathf.sign(flipSprite)` with arc Mathf.sign(boolean) = 1 if true else -1.'),
    }
    draw_outline_outputs = {
        'visible': a('bool', 'if(!outlineRegion.found()) return;', 'Whether the outline is drawn (`if(!outlineRegion.found()) return;`, Weapon.java:197 -- the guard returns early when the outline region is not found, so `visible` is false then and true otherwise; the draw_team_top_state precedent returns only `{"visible": false}` in that branch).'),
        'outline_x': a('float', 'wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),', 'The outline draw x (`wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),`, Weapon.java:204 -- unit.x plus the rotated weapon offset plus the recoil offset, via the existing `source_angles_trns_vec` port).'),
        'outline_y': a('float', 'wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);', 'The outline draw y (`wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);`, Weapon.java:205 -- unit.y plus the rotated weapon offset plus the recoil offset, via the existing `source_angles_trns_vec` port).'),
        'weapon_rotation': a('float', 'weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),', 'The outline draw rotation (`weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),`, Weapon.java:203 -- the unit rotation minus 90 plus the mount rotation when `rotate` is true, else the base rotation).'),
        'xscl': a('float', 'Draw.xscl = -Mathf.sign(flipSprite);', 'The Draw x scale drawOutline() sets before the rect call (`Draw.xscl = -Mathf.sign(flipSprite);`, Weapon.java:207 -- arc Mathf.sign(boolean) is 1 if true else -1, so -1.0 when flip_sprite is true and +1.0 otherwise; the `Draw.xscl = 1f;` reset after Draw.rect is render-state restore, not a return value).'),
    }
    return draw_outline_inputs, draw_outline_outputs


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
    draw_outline_inputs, draw_outline_outputs = definitions()

    entries = [
        ('N2537', DRAW_OUTLINE_OWNER, 'source_weapon_draw_outline_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.drawOutline(Unit, WeaponMount)', draw_outline_inputs, draw_outline_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon drawOutline() read from Weapon.java:196-213.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon drawOutline() read from Weapon.java:196-213.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: visible, outline_x, outline_y, weapon_rotation, xscl.
    by_slice['N2537'] = [
        'source_weapon_draw_outline_state_result.visible',
        'source_weapon_draw_outline_state_result.outline_x',
        'source_weapon_draw_outline_state_result.outline_y',
        'source_weapon_draw_outline_state_result.weapon_rotation',
        'source_weapon_draw_outline_state_result.xscl',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2537', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.drawOutline(Unit, WeaponMount)', godot_owner=DRAW_OUTLINE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2537'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
