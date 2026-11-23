"""Register the Weapon update() leg 4 side-flip (N2543).

Weapon.update() leg 4 (Weapon.java:418-423):
`//flip weapon shoot side for alternating weapons` /
`boolean wasFlipped = mount.side;` /
`if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){` /
`unit.mounts[otherSide].side = !unit.mounts[otherSide].side;` /
`mount.side = !mount.side;` /
`}`.
The guard is an AND of six conjuncts, in Java order.
`last_reload` is the pre-decay reload (`float lastReload =
mount.reload;`, Weapon.java:294) -- a separate frame input,
because leg 1 (N2540) only returns the post-decay reload.
`was_flipped` is mount.side BEFORE the flip (:419) and is
read by the shoot gate (:435) in a later slice, not here.
update() is a large tick method, so it is ported leg by
leg in source order; leg 4 is the pure side-flip leg.
NO driver tick call site: update() has no driver in
the port yet, and no caller reads the new function
today.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_update_side_flip_state(9 params), placed
immediately AFTER source_weapon_update_heat_state (the
N2542 function) and BEFORE set_rotation_state, plus a
one-line delegate of the same name on
SourceWeaponsState.gd (the setup_mounts_state facade
precedent). It returns the three keys `mount_side`,
`other_side_side`, `was_flipped` on every call (the
N2526 precedent -- every return key is a symbol). (2) NO
tick call site -- the function is DORMANT live today: no
caller reads it, so live behavior does not change. (3)
Guard kept in Java order: `other_side >= 0`, `alternate`,
`mount_side == flip_sprite`, `other_side < mounts_count`,
`mount_reload <= weapon_reload / 2`, `last_reload >
weapon_reload / 2`. Note the asymmetry: reload uses `<=`
(exactly half still flips) while lastReload uses strict
`>` (exactly half does NOT flip). `other_mount_side` is
the opposite mount's current side, passed as its own
param -- the pure function does not read the live mounts
array (the N2540 precedent). Mirror invariant: `otherSide`
points at the mirrored mount, never at this mount itself.
SSOT expected after GREEN: symbols +3, Done +1,
contracts +1, schemas +2 (input + result),
11767/1771/1704/3199 -> 11770/1772/1705/3201; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_update_heat import DEFERRED as N2542_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
PROOF = '/root/C07WeaponUpdateSideFlipProof'
UPDATE_SIDE_FLIP_OWNER = 'SourceWeaponsCoreState.source_weapon_update_side_flip_state'
TESTS = ['test_c07_weapon_update_side_flip_registration', 'test_all_c07_weapon_update_side_flip_input_evidence_is_exact', 'test_weapon_update_side_flip_state', 'test_reference_graph_and_actual_c07_weapon_update_side_flip']
# The slice sources the N2543 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
]
EXACT_EXPRS = [
    '//flip weapon shoot side for alternating weapons',
    'boolean wasFlipped = mount.side;',
    'if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){',
    'unit.mounts[otherSide].side = !unit.mounts[otherSide].side;',
    'mount.side = !mount.side;',
    'public int otherSide = -1;',
    'public boolean alternate = true;',
    'public boolean flipSprite = false;',
    'public float reload = 1;',
    'float lastReload = mount.reload;',
    'public boolean side;',
]

# DEFERRED is carried from the N2542 register script via import --
# never retyped. No entry is dropped: the Weapon.update()
# leg 4 entry the N2542 pool recorded as candidate stays
# deferred below (it is superseded by this slice's DONE
# entry, not deleted), and the DrawPart subsystem +
# Windows proof debt stay deferred below.
# New entries below record the update() leg 4 side-flip
# as DONE by this slice, the Windows proof debt,
# and the remaining update() legs that still need later slices.
DEFERRED = N2542_DEFERRED + [
    'Weapon.update() leg 4 side-flip (`mount_side` / `other_side_side` / `was_flipped` frame keys) -- DONE by this slice (N2543): `source_weapon_update_side_flip_state` ports Weapon.java:418-423 for the Weapon family. The guard is an AND of six conjuncts in Java order: `otherSide >= 0`, `alternate`, `mount.side == flipSprite`, `otherSide < unit.mounts.length`, `mount.reload <= reload / 2f`, `lastReload > reload / 2f`. Note the asymmetry: reload uses `<=` (exactly half still flips) while lastReload uses strict `>` (exactly half does NOT flip). `last_reload` is the pre-decay reload (`float lastReload = mount.reload;`, Weapon.java:294) -- a separate frame input, because leg 1 (N2540) only returns the post-decay reload. `was_flipped` is mount.side BEFORE the flip (:419) and is read by the shoot gate (:435) in a later slice, not here. `other_mount_side` is the opposite mount\'s current side, passed as its own param -- the pure function does not read the live mounts array (the N2540 precedent). Mirror invariant: `otherSide` points at the mirrored mount, never at this mount itself. NO driver tick call site: update() has no driver in the port yet, and no caller reads the function today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.update() leg 4 Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/N2538/N2539/N2540/N2541/N2542: the N2543 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.update() remaining legs still DEFERRED (later slices): auto-target block (Weapon.java:315-347, BLOCKED -- findTarget :447 live Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget, Predict.intercept not ported); continuous-laser leg (Weapon.java:376-408, bullet entity live -- BLOCKED as a driver leg; shootLength :391 uses range() N2539 + approachDelta, pure); activeSound (Weapon.java:425-427, audio -- skip); shoot gate + shoot() (Weapon.java:429-444, BLOCKED/live -- shoot() spawns a real bullet, :459+; velLen needs unit.isRemote/deltaLen live; the shoot gate reads `was_flipped` from N2543, `(!alternate || wasFlipped == flipSprite)` :435). init() :562 trivial (alwaysContinuous -> continuous) -- micro-slice candidate N2544. flip() :544 needs ShootPattern.copy()/flip() (port status unchecked) -- defer. addStats() :175-187 UI stats, C11-ish -- defer.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_side_flip_inputs = {
        'other_side': a('int', 'public int otherSide = -1;', 'The mirror mount index (`/** internal value used for alternation - do not change! */ public int otherSide = -1;`, Weapon.java:125 -- the first conjunct of the :420 guard is `otherSide >= 0`).'),
        'alternate': a('bool', 'public boolean alternate = true;', 'Whether the weapon alternates arms (`/** whether to shoot the weapons in different arms one after another, rather than all at once; only valid when mirror = true */ public boolean alternate = true;`, Weapon.java:43 -- the second conjunct of the :420 guard).'),
        'mount_side': a('bool', 'public boolean side;', 'This mount\'s side (`/** extra state for alternating weapons */ public boolean side;`, WeaponMount.java:40 -- the third conjunct compares it to `flipSprite`, and it is flipped by :422 when the guard passes).', source=WEAPON_MOUNT),
        'flip_sprite': a('bool', 'public boolean flipSprite = false;', 'Whether to flip the weapon\'s sprite when rendering (`/** whether to flip the weapon\'s sprite when rendering. internal use only - do not set! */ public boolean flipSprite = false;`, Weapon.java:41 -- the third conjunct of the :420 guard is `mount.side == flipSprite`).'),
        'other_mount_side': a('bool', 'unit.mounts[otherSide].side = !unit.mounts[otherSide].side;', 'The opposite mount\'s current side (`unit.mounts[otherSide].side`, Weapon.java:421 -- flipped by :421 when the guard passes; a separate param because the pure function does not read the live mounts array, the N2540 precedent).'),
        'mounts_count': a('int', 'otherSide < unit.mounts.length', 'The number of mounts on the unit (`unit.mounts.length`, Weapon.java:420 -- the fourth conjunct of the guard is `otherSide < unit.mounts.length`).'),
        'mount_reload': a('float', 'mount.reload <= reload / 2f', 'The mount reload AFTER the leg 1 decay (`mount.reload <= reload / 2f`, Weapon.java:420 -- the fifth conjunct; the post-decay reload returned by leg 1, N2540, Weapon.java:295).'),
        'weapon_reload': a('float', 'public float reload = 1;', 'The weapon reload (`/** weapon reload in frames */ public float reload = 1;`, Weapon.java:75 -- the half-reload threshold `reload / 2f` in the fifth and sixth conjuncts of the :420 guard).'),
        'last_reload': a('float', 'float lastReload = mount.reload;', 'The pre-decay reload (`float lastReload = mount.reload;`, Weapon.java:294 -- the sixth conjunct is `lastReload > reload / 2f`, strict; a separate frame input because leg 1 only returns the post-decay reload).'),
    }
    update_side_flip_outputs = {
        'mount_side': a('bool', 'mount.side = !mount.side;', 'This mount\'s side after the leg (`mount.side = !mount.side;`, Weapon.java:422 -- flipped when the guard passes, unchanged otherwise).'),
        'other_side_side': a('bool', 'unit.mounts[otherSide].side = !unit.mounts[otherSide].side;', 'The opposite mount\'s side after the leg (`unit.mounts[otherSide].side = !unit.mounts[otherSide].side;`, Weapon.java:421 -- flipped when the guard passes, unchanged otherwise).'),
        'was_flipped': a('bool', 'boolean wasFlipped = mount.side;', 'This mount\'s side BEFORE the flip (`boolean wasFlipped = mount.side;`, Weapon.java:419 -- returned unchanged when the guard fails; read by the shoot gate :435 in a later slice, not here).'),
    }
    return update_side_flip_inputs, update_side_flip_outputs


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
    update_side_flip_inputs, update_side_flip_outputs = definitions()

    entries = [
        ('N2543', UPDATE_SIDE_FLIP_OWNER, 'source_weapon_update_side_flip_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.update()', update_side_flip_inputs, update_side_flip_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 4 side-flip from Weapon.java:418-423.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 4 side-flip from Weapon.java:418-423.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: mount_side, other_side_side,
    # was_flipped (the three return keys of the update()
    # leg 4 side-flip).
    by_slice['N2543'] = [
        'source_weapon_update_side_flip_state_result.mount_side',
        'source_weapon_update_side_flip_state_result.other_side_side',
        'source_weapon_update_side_flip_state_result.was_flipped',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2543', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.update()', godot_owner=UPDATE_SIDE_FLIP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2543'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
