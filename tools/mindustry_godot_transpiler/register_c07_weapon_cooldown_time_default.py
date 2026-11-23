"""Register the Weapon cooldownTime field default (N2542, trimmed at merge).

Weapon cooldownTime (Weapon.java:89, `public float cooldownTime
= 20f;`): the ticks-to-cool-down divisor of the heat-decay leg
(Weapon.java:411, `mount.heat = Math.max(mount.heat - Time.delta
* unit.reloadMultiplier / cooldownTime, 0);`).

MERGE TRIM (2026-11-23, main thread): remote N2542 carried the
whole heat-decay leg (6 exact exprs + the scalar pure function
`source_weapon_update_heat_state`), but local N864 already ports
that exact leg (SourceWeaponBulletContinuousState.gd:231,
`next_heat = max(current_heat - source_delta * reload_multiplier
/ cooldown_time, 0.0)` + the sound update call) — 5/6 exprs dedup
into N864, verified from disk. The remote GD function + its
register/test/proof are DROPPED; this slice keeps the number
N2542 with the ONE genuinely new expr, the field declaration,
per the N2440 field-decl-only precedent (main-thread decision,
batch 40 slot 1): a field decl belongs to no method, so it gets
its own slice with a new Dictionary-defaults func in the family
file. The new func `source_weapon_cooldown_time_defaults_state`
is the first live home for the value; the same 20.0 already
lives as SourceWeaponDefaults.COOLDOWN_TIME_DEFAULT, which the
N864 impl reads when the weapon state carries no cooldownTime.

NOT this slice: the heat-decay leg itself (N864), the sound
update (audio, skipped per the N2541 precedent), any driver
tick line (a def field default, not per-tick state).
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
PROOF = '/root/C07WeaponCooldownTimeDefaultProof'
OWNER = 'SourceWeaponsCoreState.source_weapon_cooldown_time_defaults_state'
TESTS = ['test_c07_weapon_cooldown_time_default_registration', 'test_all_c07_weapon_cooldown_time_default_input_evidence_is_exact', 'test_weapon_cooldown_time_defaults_state', 'test_reference_graph_and_actual_c07_weapon_cooldown_time_default']
# The 1 slice source the N2542 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
]
EXACT_EXPRS = [
    'public float cooldownTime = 20f;',
]

# DEFERRED is carried from the N2541 register script via import --
# never retyped. The remote N2542 deferred chain (UnitCargoLoader /
# PayloadMassDriver entries) is NOT carried: unrelated to Weapon
# (merge decision). Three entries are added: the heat-decay leg
# resolution (dedup into N864), the field decl DONE here, and the
# Windows proof debt.
DEFERRED = list(N2541_DEFERRED) + [
    'Weapon.update() heat-decay leg (Weapon.java:407-415 else-branch) -- DONE by dedup into local N864, NOT re-owned here (merge decision 2026-11-23): N864 ports the same decay (`next_heat = max(current_heat - source_delta * reload_multiplier / cooldown_time, 0.0)`, SourceWeaponBulletContinuousState.gd:231) + the sound update call; the remote N2542 scalar function is dropped.',
    'Weapon cooldownTime field decl (`public float cooldownTime = 20f;`, Weapon.java:89) -- DONE by this slice (N2542, trimmed at merge): the new func `source_weapon_cooldown_time_defaults_state` returns the 20.0 default; the same value already lives as SourceWeaponDefaults.COOLDOWN_TIME_DEFAULT, read by the N864 impl.',
    'Weapon cooldownTime field default Windows Godot proof -- debt in GOAL.md section 5, same as N2541: the N2542 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    # No inputs: a def field default takes no live values (the
    # N1206/N2422 precedent -- no input schema is upserted).
    inputs = {}
    outputs = {
        'cooldown_time': a('float', 'public float cooldownTime = 20f;', 'The weapon cooldown time in ticks (Weapon.java:89, `public float cooldownTime = 20f;`): the divisor of the heat-decay leg (Weapon.java:411) -- 20 ticks to cool down; the N864 impl reads it from the weapon state with this same default (SourceWeaponDefaults.COOLDOWN_TIME_DEFAULT).'),
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
        ('N2542', OWNER, 'source_weapon_cooldown_time_defaults_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.<field declarations>', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon cooldownTime field default from Weapon.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon cooldownTime field default from Weapon.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: cooldown_time.
    by_slice['N2542'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2542', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.<field declarations>', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2542'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
