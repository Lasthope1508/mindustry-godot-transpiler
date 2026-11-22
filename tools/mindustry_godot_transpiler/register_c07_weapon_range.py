"""Register the Weapon range() read (N2539).

Weapon.range() (Weapon.java:288-290):
`public float range(){` /
`return bullet.range;` /
`}`. `bullet` is the weapon bullet type
(`public BulletType bullet = Bullets.placeholder;`,
Weapon.java:33); `bullet.range` is the BulletType range
field (`public float range = 0f;`, BulletType.java:161),
computed by calculateRange() at init
(BulletType.java:854) and afterPatch (BulletType.java:402).
calculateRange() (BulletType.java:433-439) is already
ported (SourceBulletTypeInitRangeState.gd: `if(rangeOverride
> 0) return rangeOverride;` / spawnUnit / despawnUnit legs
/ the drag fallback), so this slice takes the catalog
`bullet.range` as its one input and returns it unchanged
(the N2533 param-driven precedent: dps() took
`bullet_estimate_dps` as a float param).
NO driver tick call site: range() is a catalog read, and
no caller reads it today (UnitType.init range / maxRange,
UnitType.java:971-989, and Weapon.update shootLength,
Weapon.java:391, are consumer slices later).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_range_state(bullet_range), placed
immediately AFTER source_weapon_draw_state (the N2538
function) and BEFORE set_rotation_state, plus a one-line
delegate of the same name on SourceWeaponsState.gd (the
setup_mounts_state facade precedent). It returns the one
key `range` on every call (the N2526 precedent -- every
return key is a symbol). (2) NO tick call site -- the
function is DORMANT live today: no caller reads it, so
live behavior does not change. (3) The one param stays a
field param (default: the BulletType.range field default
0.0; Bullets.placeholder post-init range is 150.0 --
BasicBulletType(2.5f, 9, "ohno") with lifetime 60f, so
calculateRange() gives speed * lifetime = 2.5 * 60 = 150,
drag 0f, maxRange -1f).
SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schemas +2 (input + result),
11750/1767/1700/3191 -> 11751/1768/1701/3193; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_draw import DEFERRED as N2538_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07WeaponRangeProof'
RANGE_OWNER = 'SourceWeaponsCoreState.source_weapon_range_state'
TESTS = ['test_c07_weapon_range_registration', 'test_all_c07_weapon_range_input_evidence_is_exact', 'test_weapon_range_state', 'test_reference_graph_and_actual_c07_weapon_range']
# The slice sources the N2539 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'public float range(){',
    'return bullet.range;',
]

# DEFERRED is carried from the N2538 register script via import --
# never retyped. No entry is dropped: the Weapon.draw() consumer
# entry the N2538 pool recorded deferred stays deferred below
# (it is a Unit draw call-site, not this slice), and the
# DrawPart subsystem + Windows proof debt stay deferred below.
# New entries below record the range() read as DONE by this
# slice, the Windows proof debt, and the consumers that still
# need later slices.
DEFERRED = N2538_DEFERRED + [
    'Weapon.range() (`range` frame key) -- DONE by this slice (N2539): `source_weapon_range_state` ports Weapon.java:288-290 for the Weapon family (`public float range(){ return bullet.range; }`). `bullet` is the weapon bullet type (`public BulletType bullet = Bullets.placeholder;`, Weapon.java:33); `bullet.range` is the BulletType range field (`public float range = 0f;`, BulletType.java:161), computed by calculateRange() at init (BulletType.java:854) and afterPatch (BulletType.java:402) -- calculateRange() itself is already ported (SourceBulletTypeInitRangeState.gd), so this slice takes the catalog `bullet.range` as its one input and returns it unchanged. NO driver tick call site: range() is a catalog read, and no caller reads it today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.range() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/N2538: the N2539 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.range() consumers still DEFERRED (later slices): UnitType.init range / maxRange (UnitType.java:971-989 -- `range = Math.min(range, weapon.range() - margin);` / `maxRange = Math.max(maxRange, weapon.range() - margin);` with margin 4f, gated on `weapon.useAttackRange`) and Weapon.update shootLength laser clamp (Weapon.java:391 -- `float shootLength = Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY), range());`).',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    range_inputs = {
        'bullet_range': a('float', 'public float range = 0f;', 'The catalog BulletType range (`public float range = 0f;`, BulletType.java:161 -- the maximum distance the bullet type can travel, computed by calculateRange() at init (BulletType.java:854) and afterPatch (BulletType.java:402); calculateRange() itself is already ported, so this slice takes the computed catalog value as its one input; the proof passes 0.0 for the field default and 150.0 for Bullets.placeholder post-init (BasicBulletType(2.5f, 9, "ohno") with lifetime 60f: speed * lifetime = 2.5 * 60 = 150, drag 0f, maxRange -1f)).', source=BULLET_TYPE),
    }
    range_outputs = {
        'range': a('float', 'return bullet.range;', 'The weapon range (`return bullet.range;`, Weapon.java:289 -- the range() read returns the bullet type range unchanged).'),
    }
    return range_inputs, range_outputs


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
    range_inputs, range_outputs = definitions()

    entries = [
        ('N2539', RANGE_OWNER, 'source_weapon_range_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.range()', range_inputs, range_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon range() read from Weapon.java:288-290.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon range() read from Weapon.java:288-290.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: range.
    by_slice['N2539'] = [
        'source_weapon_range_state_result.range',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2539', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.range()', godot_owner=RANGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2539'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
