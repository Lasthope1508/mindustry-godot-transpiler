"""Register the Weapon init() (N2544).

Weapon.init() (Weapon.java:561-566):
`@CallSuper` /
`public void init(){` /
`if(alwaysContinuous){` /
`continuous = true;` /
`}`.
Only set when `alwaysContinuous` is true; otherwise the
current `continuous` value is kept unchanged (including
when it is already true). `continuous` is passed as an
input param because the pure function returns the field's
new value without mutating live state (the N2540
precedent). init() is a content-load lifecycle hook, not
a tick. NO driver tick call site: init() has no driver in
the port yet, and no caller reads the new function
today.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_init_state(2 params), placed immediately
AFTER source_weapon_side_flip_defaults_state (the N2543
trimmed defaults function, merge 2026-11-23) and BEFORE
set_rotation_state, plus a
one-line delegate of the same name on
SourceWeaponsState.gd (the setup_mounts_state facade
precedent). It returns the single key `continuous` on
every call (the N2526 precedent -- every return key is
a symbol). (2) NO tick call site -- the function is
DORMANT live today: no caller reads it, so live
behavior does not change. (3) `@CallSuper` is an
annotation, not logic -- quoted in the code comment
only, not ported as a branch.
SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schemas +2 (input + result),
11770/1772/1705/3201 -> 11771/1773/1706/3203; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_update_side_flip import DEFERRED as N2543_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
PROOF = '/root/C07WeaponInitProof'
WEAPON_INIT_OWNER = 'SourceWeaponsCoreState.source_weapon_init_state'
TESTS = ['test_c07_weapon_init_registration', 'test_all_c07_weapon_init_input_evidence_is_exact', 'test_weapon_init_state', 'test_reference_graph_and_actual_c07_weapon_init']
# The slice sources the N2544 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
]
EXACT_EXPRS = [
    '@CallSuper',
    'public void init(){',
    'if(alwaysContinuous){',
    'continuous = true;',
    'public boolean continuous;',
    'public boolean alwaysContinuous;',
    '/** whether this weapon uses continuous fire without reloading; implies continuous = true */',
    '/** whether to hold the bullet in place while firing; it will still require reload. */',
]

# DEFERRED is carried from the N2543 register script via import --
# never retyped. No entry is dropped: the Weapon.update()
# remaining-legs entry the N2543 pool recorded stays
# deferred below (updated: init() is now DONE by this
# slice, not a candidate), and the DrawPart subsystem +
# Windows proof debt stay deferred below.
# New entries below record init() as DONE by this slice,
# the Windows proof debt, and the remaining update() legs
# that still need later slices.
DEFERRED = N2543_DEFERRED + [
    'Weapon.init() (`continuous` frame key) -- DONE by this slice (N2544): `source_weapon_init_state` ports Weapon.java:561-566 for the Weapon family. `continuous = true` only when `alwaysContinuous` is true; otherwise the current `continuous` value is kept unchanged (including when it is already true). `continuous` is passed as an input param because the pure function returns the field\'s new value without mutating live state (the N2540 precedent). `@CallSuper` is an annotation, not logic -- quoted in the code comment only. init() is a content-load lifecycle hook, not a tick. NO driver tick call site: init() has no driver in the port yet, and no caller reads the function today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.init() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/N2538/N2539/N2540/N2541/N2542/N2543: the N2544 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.update() remaining legs still DEFERRED (later slices): auto-target block (Weapon.java:315-347, BLOCKED -- findTarget :447 live Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget, Predict.intercept not ported); continuous-laser leg (Weapon.java:376-408, bullet entity live -- BLOCKED as a driver leg; shootLength :391 uses range() N2539 + approachDelta, pure); activeSound (Weapon.java:425-427, audio -- skip); shoot gate + shoot() (Weapon.java:429-444, BLOCKED/live -- shoot() spawns a real bullet, :459+; velLen needs unit.isRemote/deltaLen live; the shoot gate reads `was_flipped` from local N856 (merge re-point 2026-11-23: the remote N2543 side-flip function was trimmed, the flip body lives in N856), `(!alternate || wasFlipped == flipSprite)` :435). flip() :544 needs ShootPattern.copy()/flip() (port status unchecked) -- defer. addStats() :175-187 UI stats, C11-ish -- defer.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    weapon_init_inputs = {
        'always_continuous': a('bool', 'public boolean alwaysContinuous;', 'Whether this weapon uses continuous fire without reloading (`/** whether this weapon uses continuous fire without reloading; implies continuous = true */ public boolean alwaysContinuous;`, Weapon.java:55 -- the guard of the init() body, :563 `if(alwaysContinuous){`).'),
        'continuous': a('bool', 'public boolean continuous;', 'The current hold-bullet flag (`/** whether to hold the bullet in place while firing; it will still require reload. */ public boolean continuous;`, Weapon.java:53 -- kept unchanged when `alwaysContinuous` is false; a separate param because the pure function returns the field\'s new value without mutating live state, the N2540 precedent).'),
    }
    weapon_init_outputs = {
        'continuous': a('bool', 'continuous = true;', 'The hold-bullet flag after init() (`continuous = true;`, Weapon.java:564 -- set when `alwaysContinuous` is true, otherwise the input value is returned unchanged).'),
    }
    return weapon_init_inputs, weapon_init_outputs


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
    weapon_init_inputs, weapon_init_outputs = definitions()

    entries = [
        ('N2544', WEAPON_INIT_OWNER, 'source_weapon_init_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.init()', weapon_init_inputs, weapon_init_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon init() from Weapon.java:561-566.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon init() from Weapon.java:561-566.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: continuous (the single
    # return key of init()).
    by_slice['N2544'] = [
        'source_weapon_init_state_result.continuous',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2544', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.init()', godot_owner=WEAPON_INIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2544'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
