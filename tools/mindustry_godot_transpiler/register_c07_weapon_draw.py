"""Register the Weapon draw() read (N2538).

Weapon.draw() (Weapon.java:214-286):
`public void draw(Unit unit, WeaponMount mount){` /
`float z = Draw.z();` /
`Draw.z(z + layerOffset);` /
`rotation = unit.rotation - 90,` /
`realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
`weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
`wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
`wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
`if(shadow > 0){` / `Drawf.shadow(wx, wy, shadow);` /
`if(top){` / `drawOutline(unit, mount);` /
`if(parts.size > 0){` (per-part DrawPart drawing is a later
DrawPart subsystem slice) /
`Draw.xscl *= -Mathf.sign(flipSprite);` /
`if(region.found()) Draw.rect(region, wx, wy, weaponRotation);` /
`if(cellRegion.found()){` /
`if(heatRegion.found() && mount.heat > 0){` /
`Draw.z(z);` (render-state restore, not a return value).
draw() has NO early return (unlike drawOutline): every branch
returns all thirteen keys (`rotation`, `real_recoil`,
`weapon_rotation`, `wx`, `wy`, `xscl`, `z_draw`,
`shadow_drawn`, `outline_called`, `has_parts`, `region_drawn`,
`cell_drawn`, `heat_drawn`). `z_draw` is `z + layerOffset`;
`shadow_drawn` is `shadow > 0`; `outline_called` is `top`;
`has_parts` is `parts_count > 0`; `region_drawn` is
`region_found`; `cell_drawn` is `cell_region_found`;
`heat_drawn` is `heat_region_found` AND `mount_heat > 0`.
`xscl` is `-Mathf.sign(flipSprite)`; arc Mathf.sign(boolean)
(Mathf.java:203-205) is 1 if true else -1, so xscl is -1.0
when flip_sprite is true and +1.0 otherwise. The trns legs
reuse the existing port: no scalar trnsx/trnsy port exists,
and `source_angles_trns_vec` (SourceMathState.gd:140)
computes exactly Angles.trnsx/trnsy(angle, x, y) (arc
Angles.java:74-82). The drawOutline call body is already
N2537's function -- only the `outline_called` flag is
returned here. cellColor / heatColor / applyColor values are
render-only, no return key. The `Draw.z(z);` restore at the
end is render-state restore, not a return value.
NO driver tick call site: draw() is draw code, rendering is
outside the game, and no caller reads it today.
NOTE on the scope count: the task brief says "14 return
keys" but enumerates thirteen keys; this slice ports exactly
the thirteen enumerated keys and invents no fourteenth.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_draw_state(z, unit_rotation, unit_x, unit_y,
mount_recoil, mount_rotation, rotate, base_rotation, recoil,
recoil_pow, weapon_x, weapon_y, flip_sprite, shadow, top,
region_found, cell_region_found, heat_region_found,
mount_heat, layer_offset, parts_count), placed immediately
AFTER source_weapon_draw_outline_state (the N2537 function)
and BEFORE set_rotation_state, plus a one-line delegate of
the same name on SourceWeaponsState.gd (the setup_mounts_state
facade precedent). It returns all thirteen keys on every
call (the N2526 precedent -- every return key is a symbol).
(2) NO tick call site -- the function is DORMANT live today:
no caller reads it, so live behavior does not change.
(3) All 21 params stay field params (defaults: z 0;
unit_rotation 90; unit 0,0; mount_recoil 0; mount_rotation 0;
rotate false; base_rotation 0; recoil 1.5; recoil_pow 1.8;
weapon x 5, y 0; flip_sprite false; shadow -1; top true;
region_found true; cell_region_found false;
heat_region_found false; mount_heat 0; layer_offset 0;
parts_count 0).
SSOT expected after GREEN: symbols +13, Done +1,
contracts +1, schemas +2 (input + result),
11737/1766/1699/3189 -> 11750/1767/1700/3191; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_draw_outline import DEFERRED as N2537_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
PROOF = '/root/C07WeaponDrawProof'
DRAW_OWNER = 'SourceWeaponsCoreState.source_weapon_draw_state'
TESTS = ['test_c07_weapon_draw_registration', 'test_all_c07_weapon_draw_input_evidence_is_exact', 'test_weapon_draw_state', 'test_reference_graph_and_actual_c07_weapon_draw']
# The slice sources the N2538 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
]
EXACT_EXPRS = [
    'public void draw(Unit unit, WeaponMount mount){',
    'float z = Draw.z();',
    'Draw.z(z + layerOffset);',
    'rotation = unit.rotation - 90,',
    'realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,',
    'weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),',
    'wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),',
    'wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);',
    'if(shadow > 0){',
    'Drawf.shadow(wx, wy, shadow);',
    'if(top){',
    'drawOutline(unit, mount);',
    'if(parts.size > 0){',
    'Draw.xscl *= -Mathf.sign(flipSprite);',
    'if(region.found()) Draw.rect(region, wx, wy, weaponRotation);',
    'if(cellRegion.found()){',
    'if(heatRegion.found() && mount.heat > 0){',
    'Draw.z(z);',
]

# DEFERRED is carried from the N2537 register script via import --
# never retyped. No entry is dropped: the Weapon.draw() consumer
# entry the N2537 pool recorded deferred is recorded DONE by
# this slice, and the DrawPart subsystem + Windows proof debt
# stay deferred below. New entries below record the draw() read
# as DONE by this slice, the Windows proof debt, and the
# consumers that still need later slices.
DEFERRED = N2537_DEFERRED + [
    'Weapon.draw() (`rotation` / `real_recoil` / `weapon_rotation` / `wx` / `wy` / `xscl` / `z_draw` / `shadow_drawn` / `outline_called` / `has_parts` / `region_drawn` / `cell_drawn` / `heat_drawn` frame keys) -- DONE by this slice (N2538): `source_weapon_draw_state` ports Weapon.java:214-286 for the Weapon family (z / layerOffset first, then `rotation = unit.rotation - 90`, `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil`, `weaponRotation = rotation + (rotate ? mount.rotation : baseRotation)`, wx/wy via the existing `source_angles_trns_vec` port of Angles.trnsx/trnsy, `xscl = -Mathf.sign(flipSprite)` with arc Mathf.sign(boolean) = 1 if true else -1, `z_draw = z + layerOffset`, `shadow_drawn = shadow > 0`, `outline_called = top`, `has_parts = parts_count > 0`, `region_drawn = region_found`, `cell_drawn = cell_region_found`, `heat_drawn = heat_region_found AND mount_heat > 0`). draw() has NO early return, so all thirteen keys return on every call (the brief says "14 return keys" but enumerates thirteen; no fourteenth key is invented). The drawOutline call body is already N2537 -- only the flag is returned. The `Draw.z(z);` restore is render-state restore, not a return value. NO driver tick call site: draw() is draw code, rendering is outside the game, and no caller reads it today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537: the N2538 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.draw() consumers still DEFERRED (later slices): the Unit draw call-site that reads the draw() frame keys (`wx` / `wy` / `weapon_rotation` / `xscl` / `z_draw` / `shadow_drawn` / `outline_called` / `region_drawn` / `cell_drawn` / `heat_drawn`) and issues the Draw calls is draw code, rendering outside the game.',
    'Weapon.draw() per-part DrawPart drawing still DEFERRED (later DrawPart subsystem slice): both under/over loops over `parts` with DrawPart.params.set / setRecoil (Weapon.java:232-244 and 271-281) are NOT ported by N2538 -- only the `has_parts` flag is returned.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'z': a('float', 'float z = Draw.z();', 'The Draw z before the layer offset (`float z = Draw.z();`, Weapon.java:214 -- the caller-passed z the layer offset is added to; the proof passes 0.0 for a fresh draw).'),
        'unit_rotation': a('float', 'rotation = unit.rotation - 90,', 'The owning unit rotation in degrees (`rotation = unit.rotation - 90,`, Weapon.java:218 -- the aim rotation the weapon is drawn relative to, default 90 for a fresh unit).'),
        'unit_x': a('float', 'wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),', 'The owning unit x position (`wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),`, Weapon.java:221 -- the draw x is unit.x plus the rotated weapon offset plus the recoil offset).'),
        'unit_y': a('float', 'wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);', 'The owning unit y position (`wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);`, Weapon.java:222 -- the draw y is unit.y plus the rotated weapon offset plus the recoil offset).'),
        'mount_recoil': a('float', 'public float recoil;', 'The mount recoil (`public float recoil;`, WeaponMount.java:16 -- "weapon recoil"; the mount recoil the real recoil is powered from, default 0 for a fresh mount).', source=WEAPON_MOUNT),
        'mount_rotation': a('float', 'public float rotation;', 'The mount rotation in degrees (`public float rotation;`, WeaponMount.java:14 -- "rotation relative to the unit this mount is on"; used when `rotate` is true, default the weapon base rotation).', source=WEAPON_MOUNT),
        'rotate': a('bool', 'public boolean rotate = false;', 'Whether the weapon rotates toward the target independently of the unit (`public boolean rotate = false;`, Weapon.java:45 -- "whether to rotate toward the target independently of unit"; `ROTATE_DEFAULT := false` in SourceWeaponDefaults.gd); a bool param, default false.'),
        'base_rotation': a('float', 'public float baseRotation = 0f;', 'The rotation at which this weapon starts at (`public float baseRotation = 0f;`, Weapon.java:49 -- "rotation at which this weapon starts at."; `BASE_ROTATION_DEFAULT := 0.0` in SourceWeaponDefaults.gd); used when `rotate` is false.'),
        'recoil': a('float', 'public float recoil = 1.5f;', 'The visual weapon knockback (`public float recoil = 1.5f;`, Weapon.java:81 -- "visual weapon knockback."); the real recoil is `Mathf.pow(mount.recoil, recoilPow) * recoil`.'),
        'recoil_pow': a('float', 'public float recoilPow = 1.8f;', 'The power curve applied to visual recoil (`public float recoilPow = 1.8f;`, Weapon.java:87 -- "power curve applied to visual recoil").'),
        'weapon_x': a('float', 'public float x = 5f, y = 0f;', 'The weapon x offset on the unit (`public float x = 5f, y = 0f;`, Weapon.java:93 -- "offsets of weapon position on unit"); the base offset is Angles.trnsx/trnsy(rotation, x, y).'),
        'weapon_y': a('float', 'public float x = 5f, y = 0f;', 'The weapon y offset on the unit (`public float x = 5f, y = 0f;`, Weapon.java:93 -- "offsets of weapon position on unit"); the base offset is Angles.trnsx/trnsy(rotation, x, y).'),
        'flip_sprite': a('bool', 'public boolean flipSprite = false;', 'Whether to flip the weapon sprite when rendering (`public boolean flipSprite = false;`, Weapon.java:41 -- "whether to flip the weapon\'s sprite when rendering. internal use only - do not set!"; `FLIP_SPRITE_DEFAULT := false` in SourceWeaponDefaults.gd); `xscl = -Mathf.sign(flipSprite)` with arc Mathf.sign(boolean) = 1 if true else -1.'),
        'shadow': a('float', 'public float shadow = -1f;', 'The radius of the shadow drawn under the weapon (`public float shadow = -1f;`, Weapon.java:99 -- "radius of shadow drawn under the weapon; <0 to disable"); `shadow_drawn` is `shadow > 0`.'),
        'top': a('bool', 'public boolean top = true;', 'Whether to draw the outline on top (`public boolean top = true;`, Weapon.java:51 -- "whether to draw the outline on top."); `outline_called` is `top`.'),
        'region_found': a('bool', 'if(region.found()) Draw.rect(region, wx, wy, weaponRotation);', 'Whether the displayed weapon region exists (`if(region.found()) Draw.rect(region, wx, wy, weaponRotation);`, Weapon.java:253 -- the region is drawn only when found); a bool param, default true.'),
        'cell_region_found': a('bool', 'if(cellRegion.found()){', 'Whether the cell region exists (`if(cellRegion.found()){`, Weapon.java:255 -- the cell region is drawn only when found); a bool param, default false.'),
        'heat_region_found': a('bool', 'if(heatRegion.found() && mount.heat > 0){', 'Whether the heat region exists (`if(heatRegion.found() && mount.heat > 0){`, Weapon.java:261 -- the heat region is drawn only when found and the mount heat is above 0); a bool param, default false.'),
        'mount_heat': a('float', 'mount.heat > 0', 'The mount heat, 0 to 1 (`mount.heat > 0`, Weapon.java:261 -- "current heat, 0 to 1", WeaponMount.java:21-22; `heat_drawn` is `heat_region_found` AND `mount_heat > 0`).'),
        'layer_offset': a('float', 'public float layerOffset = 0f;', 'The draw Z offset relative to the default value (`public float layerOffset = 0f;`, Weapon.java:127 -- "draw Z offset relative to the default value"); `z_draw` is `z + layerOffset`.'),
        'parts_count': a('int', 'if(parts.size > 0){', 'The number of extra animated parts (`if(parts.size > 0){`, Weapon.java:232 -- "extra animated parts", Weapon.java:160-161; `has_parts` is `parts_count > 0`; the per-part drawing itself is a later DrawPart subsystem slice).'),
    }
    draw_outputs = {
        'rotation': a('float', 'rotation = unit.rotation - 90,', 'The draw rotation (`rotation = unit.rotation - 90,`, Weapon.java:218 -- the unit rotation minus 90, the aim rotation the weapon is drawn relative to).'),
        'real_recoil': a('float', 'realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,', 'The real visual recoil (`realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,`, Weapon.java:219 -- the mount recoil powered by the recoil curve times the visual knockback).'),
        'weapon_rotation': a('float', 'weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),', 'The weapon draw rotation (`weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),`, Weapon.java:220 -- the unit rotation minus 90 plus the mount rotation when `rotate` is true, else the base rotation).'),
        'wx': a('float', 'wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),', 'The draw x (`wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),`, Weapon.java:221 -- unit.x plus the rotated weapon offset plus the recoil offset, via the existing `source_angles_trns_vec` port).'),
        'wy': a('float', 'wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);', 'The draw y (`wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);`, Weapon.java:222 -- unit.y plus the rotated weapon offset plus the recoil offset, via the existing `source_angles_trns_vec` port).'),
        'xscl': a('float', 'Draw.xscl *= -Mathf.sign(flipSprite);', 'The Draw x scale draw() multiplies before the rect calls (`Draw.xscl *= -Mathf.sign(flipSprite);`, Weapon.java:248 -- arc Mathf.sign(boolean) is 1 if true else -1, so -1.0 when flip_sprite is true and +1.0 otherwise; the `Draw.xscl = 1f;` reset after the parts loop is render-state restore, not a return value).'),
        'z_draw': a('float', 'Draw.z(z + layerOffset);', 'The draw z (`Draw.z(z + layerOffset);`, Weapon.java:215 -- the caller z plus the layer offset; the `Draw.z(z);` restore at the end is render-state restore, not a return value).'),
        'shadow_drawn': a('bool', 'if(shadow > 0){', 'Whether the shadow is drawn (`if(shadow > 0){`, Weapon.java:224 -- the shadow is drawn only when the shadow radius is above 0).'),
        'outline_called': a('bool', 'drawOutline(unit, mount);', 'Whether drawOutline() is called (`drawOutline(unit, mount);`, Weapon.java:229 -- called only when `top` is true, Weapon.java:228; the drawOutline body is already N2537, only the flag is returned here).'),
        'has_parts': a('bool', 'if(parts.size > 0){', 'Whether the weapon has extra animated parts (`if(parts.size > 0){`, Weapon.java:232 -- the per-part DrawPart drawing itself is a later DrawPart subsystem slice).'),
        'region_drawn': a('bool', 'if(region.found()) Draw.rect(region, wx, wy, weaponRotation);', 'Whether the displayed weapon region is drawn (`if(region.found()) Draw.rect(region, wx, wy, weaponRotation);`, Weapon.java:253 -- drawn only when the region is found).'),
        'cell_drawn': a('bool', 'if(cellRegion.found()){', 'Whether the cell region is drawn (`if(cellRegion.found()){`, Weapon.java:255 -- drawn only when the cell region is found).'),
        'heat_drawn': a('bool', 'if(heatRegion.found() && mount.heat > 0){', 'Whether the heat region is drawn (`if(heatRegion.found() && mount.heat > 0){`, Weapon.java:261 -- drawn only when the heat region is found and the mount heat is above 0).'),
    }
    return draw_inputs, draw_outputs


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
    draw_inputs, draw_outputs = definitions()

    entries = [
        ('N2538', DRAW_OWNER, 'source_weapon_draw_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.draw(Unit, WeaponMount)', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon draw() read from Weapon.java:214-286.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon draw() read from Weapon.java:214-286.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, real_recoil, weapon_rotation, wx, wy, xscl, z_draw, shadow_drawn, outline_called, has_parts, region_drawn, cell_drawn, heat_drawn.
    by_slice['N2538'] = [
        'source_weapon_draw_state_result.rotation',
        'source_weapon_draw_state_result.real_recoil',
        'source_weapon_draw_state_result.weapon_rotation',
        'source_weapon_draw_state_result.wx',
        'source_weapon_draw_state_result.wy',
        'source_weapon_draw_state_result.xscl',
        'source_weapon_draw_state_result.z_draw',
        'source_weapon_draw_state_result.shadow_drawn',
        'source_weapon_draw_state_result.outline_called',
        'source_weapon_draw_state_result.has_parts',
        'source_weapon_draw_state_result.region_drawn',
        'source_weapon_draw_state_result.cell_drawn',
        'source_weapon_draw_state_result.heat_drawn',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2538', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.draw(Unit, WeaponMount)', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2538'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
