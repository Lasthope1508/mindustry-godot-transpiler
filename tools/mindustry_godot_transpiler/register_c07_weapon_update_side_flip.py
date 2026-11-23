"""Register the Weapon side-flip field defaults (N2543, trimmed at merge).

Weapon side-flip field defaults (Weapon.java:125/:43/:41,
WeaponMount.java:40): the four def fields the side-flip leg
(Weapon.java:418-423) reads -- `otherSide = -1`, `alternate =
true`, `flipSprite = false`, `side` (WeaponMount, Java boolean
default false) -- plus the leg's comment
`//flip weapon shoot side for alternating weapons`.

MERGE TRIM (2026-11-23, main thread): remote N2543 carried the
whole side-flip leg (11 exact exprs + the scalar pure function
`source_weapon_update_side_flip_state`), but local N856 already
ports that exact leg (flip body: `wasFlipped` / if / 2
assignments) and N870 owns `lastReload` -- 5/11 exprs dedup
into local slices, verified from disk; `public float reload =
1;` is already claimed by remote N2534 + N2535 and is NOT
taken here. The remote GD function + its register/test/proof
are DROPPED; this slice keeps the number N2543 with the 5
genuinely new exprs, the comment + the four field declarations,
per the N2440 field-decl-only precedent (main-thread decision,
batch 40 slot 1) and the N2542 trim precedent: a field decl
belongs to no method, so it gets its own slice with a new
Dictionary-defaults func in the family file. The new func
`source_weapon_side_flip_defaults_state` is the first live
home for the values.

NOT this slice: the side-flip leg itself (N856 + N870), the
`reload = 1` field decl (N2534/N2535), any driver tick line
(a def field default, not per-tick state).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_cooldown_time_default import DEFERRED as N2542_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
PROOF = '/root/C07WeaponSideFlipDefaultsProof'
OWNER = 'SourceWeaponsCoreState.source_weapon_side_flip_defaults_state'
TESTS = ['test_c07_weapon_side_flip_defaults_registration', 'test_all_c07_weapon_side_flip_defaults_input_evidence_is_exact', 'test_weapon_side_flip_defaults_state', 'test_reference_graph_and_actual_c07_weapon_side_flip_defaults']
# The 2 slice sources the N2543 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
]
EXACT_EXPRS = [
    '//flip weapon shoot side for alternating weapons',
    'public int otherSide = -1;',
    'public boolean alternate = true;',
    'public boolean flipSprite = false;',
    'public boolean side;',
]

# DEFERRED is carried from the N2542 trim register script via
# import -- never retyped. The remote N2543 deferred chain
# (which hung off the dropped N2542 heat register) is NOT
# carried: the merge base already holds the local chain.
# Four entries are added: the side-flip leg resolution
# (dedup into N856 + N870), the field decls DONE here, the
# `reload = 1` decl NOT taken, and the Windows proof debt.
DEFERRED = list(N2542_DEFERRED) + [
    'Weapon.update() leg 4 side-flip (Weapon.java:418-423) -- DONE by dedup into local N856 + N870, NOT re-owned here (merge decision 2026-11-23): N856 ports the flip body (`boolean wasFlipped = mount.side;` / the 6-conjunct guard / the 2 assignments) and N870 owns `float lastReload = mount.reload;` (Weapon.java:294); the remote N2543 scalar function is dropped.',
    'Weapon side-flip field decls (`public int otherSide = -1;`, Weapon.java:125; `public boolean alternate = true;`, Weapon.java:43; `public boolean flipSprite = false;`, Weapon.java:41; `public boolean side;`, WeaponMount.java:40) + the leg comment (`//flip weapon shoot side for alternating weapons`, Weapon.java:418) -- DONE by this slice (N2543, trimmed at merge): the new func `source_weapon_side_flip_defaults_state` returns the 4 defaults.',
    'Weapon `reload = 1` field decl (`public float reload = 1;`, Weapon.java:75) -- NOT taken by this slice (merge decision 2026-11-23): already claimed by remote N2534 (Weapon.dps) + N2535 (Weapon.shotsPerSec), present in the merge ledger at both.',
    'Weapon side-flip field defaults Windows Godot proof -- debt in GOAL.md section 5, same as N2542: the N2543 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    # No inputs: a def field default takes no live values (the
    # N1206/N2422 precedent -- no input schema is upserted).
    inputs = {}
    outputs = {
        'other_side': a('int', 'public int otherSide = -1;', 'The mirror mount index (`/** internal value used for alternation - do not change! */ public int otherSide = -1;`, Weapon.java:125 -- the first conjunct of the :420 guard is `otherSide >= 0`; -1 means no mirror mount).'),
        'alternate': a('bool', 'public boolean alternate = true;', 'Whether the weapon alternates arms (`/** whether to shoot the weapons in different arms one after another, rather than all at once; only valid when mirror = true */ public boolean alternate = true;`, Weapon.java:43 -- the second conjunct of the :420 guard).'),
        'flip_sprite': a('bool', 'public boolean flipSprite = false;', 'Whether to flip the weapon\'s sprite when rendering (`/** whether to flip the weapon\'s sprite when rendering. internal use only - do not set! */ public boolean flipSprite = false;`, Weapon.java:41 -- the third conjunct of the :420 guard is `mount.side == flipSprite`).'),
        'side': a('bool', 'public boolean side;', 'This mount\'s side (`/** extra state for alternating weapons */ public boolean side;`, WeaponMount.java:40 -- the third conjunct compares it to `flipSprite`, and it is flipped by :422 when the guard passes; Java boolean default false).', source=WEAPON_MOUNT),
    }
    return (inputs, outputs)


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
    for pair in inputs_outputs:
        total += len(pair)
        for field, meta in pair.items():
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
    inputs, outputs = definitions()

    entries = [
        ('N2543', OWNER, 'source_weapon_side_flip_defaults_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.<field declarations>', inputs, outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            # Zero params: skip the input schema entirely (the
            # N1206/N2422 precedent) -- an empty keys object fails
            # state-schema validation.
            if not keys:
                continue
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon side-flip field defaults from Weapon.java / WeaponMount.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon side-flip field defaults from Weapon.java / WeaponMount.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: other_side, alternate,
    # flip_sprite, side.
    by_slice['N2543'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2543', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.<field declarations>', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2543'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
