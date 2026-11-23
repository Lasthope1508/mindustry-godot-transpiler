"""Register the PayloadAmmoTurret(String name) ctor field default (N2416).

PayloadAmmoTurret(String name) (PayloadAmmoTurret.java:26-33,
`public PayloadAmmoTurret(String name){`) assigns 1 distinguishing
field default on the PayloadAmmoTurret def: `maxAmmo = 3;` (:29).
The other ctor lines are NOT in this slice and are never
re-registered: `super(name);` is already the exact_expr of N2185
and `acceptsPayload = true;` of N2168 -- both 0-hit re-probed at
HEAD 1571952f, local + remote ledgers. One GD function on
SourcePayloadAmmoTurretBuildPortBridge.gd (the PayloadAmmoTurret
file, NOT a new file -- main-thread decision batch 30, N2406/N2413
ctor precedent). The owner is PortGame.* (this file is a PortBridge
-- N2358/N2384/N2396 precedent), NOT the file class name. The value
is an int literal: it arrives as an explicit int param and passes
through. The Turret base default the ctor overrides is `public int
maxAmmo = 30;` (Turret.java:47). The default is frame data only; no
Draw is ported. Two new result symbols: the default plus the updated
def frame. One slice source: PayloadAmmoTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_ammo_turret_init import DEFERRED as N2396_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadAmmoTurretDefaultConstructorProof'
CTOR_OWNER = 'PortGame.source_payload_ammo_turret_default_constructor_state'
TESTS = ['test_c07_payload_ammo_turret_default_constructor_registration', 'test_all_c07_payload_ammo_turret_default_constructor_input_evidence_is_exact', 'test_payload_ammo_turret_default_constructor_state', 'test_reference_graph_and_actual_c07_payload_ammo_turret_default_constructor']
# The 1 slice source the N2416 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'maxAmmo = 3;',
]

# DEFERRED is carried from the N2396 register script via import --
# never retyped. Nothing in it closes here: N2416 ports the
# PayloadAmmoTurret() ctor field default, which no N2396 entry
# lists. One entry is added: the N2416 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = list(N2396_DEFERRED) + [
    'PayloadAmmoTurret() ctor field default N2416 Windows Godot proof -- debt in GOAL.md section 5, same as N2396: the N2416 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_inputs = {
        'payload_ammo_turret_defaults': a('Dictionary', 'public PayloadAmmoTurret(String name){', 'The PayloadAmmoTurret def frame (PayloadAmmoTurret.java:26, `public PayloadAmmoTurret(String name){`): the family-convention first arg; the ctor writes its 1 field default into it, so payload_ammo_turret_defaults is an in/out param -- keys already present keep their unrelated values, the ctor key is overwritten with the ctor value.'),
        'max_ammo': a('int', 'maxAmmo = 3;', 'The max ammo (PayloadAmmoTurret.java:29, `maxAmmo = 3;`): Turret.maxAmmo; the int literal arrives as an explicit int param and passes through to the result max_ammo key; the Turret base default it overrides is `public int maxAmmo = 30;` (Turret.java:47).'),
    }
    ctor_outputs = {
        'max_ammo': a('int', 'maxAmmo = 3;', 'The max ammo, read through (PayloadAmmoTurret.java:29, `maxAmmo = 3;`): the int passed in as max_ammo; the payload ammo turret holds at most 3 payload ammo at once.'),
        'payload_ammo_turret_defaults': a('Dictionary', 'public PayloadAmmoTurret(String name){', 'The updated PayloadAmmoTurret def frame (PayloadAmmoTurret.java:26, `public PayloadAmmoTurret(String name){`): the same in/out Dictionary -- unrelated keys preserved, the ctor key written with the ctor value.'),
    }
    return ctor_inputs, ctor_outputs


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
    ctor_inputs, ctor_outputs = definitions()

    entries = [
        ('N2416', CTOR_OWNER, 'source_payload_ammo_turret_default_constructor_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurret(String name)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurret() ctor field default state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurret() ctor field default state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the default first, then the
    # updated def frame.
    by_slice['N2416'] = [
        'source_payload_ammo_turret_default_constructor_state_result.max_ammo',
        'source_payload_ammo_turret_default_constructor_state_result.payload_ammo_turret_defaults',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2416', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', java_method='PayloadAmmoTurret(String name)', godot_owner=CTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2416'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
