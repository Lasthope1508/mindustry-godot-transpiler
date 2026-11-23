"""Register the LaserTurret placed() (N2422).

LaserTurretBuild.placed()
(LaserTurret.java:59-64, `@Override` /
`public void placed(){` /
`super.placed();` /
`reloadCounter = reload;`) is one pure function on the
SourceLaserTurretBuildPortBridge.gd. Call-site fragment:
`super.placed();` is the only free expr -- `reloadCounter
= reload;` is already owned at N2364
(LaserTurretBuild.updateShooting) and is NOT
re-registered. The super call runs
BaseTurretBuild.placed() (whose own body is not ported
here -- only the call site); the GD function records
that placed() ran, returning a frame with `placed:
true` (the N2318 canPickup precedent: a bare call-site
returns a frame). NO driver line: placed() runs once at
build placement, not per-tick.

RED decisions (resolved at RED): (1) One slice entry
for the method, one pure function, ONE owner
(PortGame.source_laser_turret_build_placed_state,
the N2360 PortGame.* convention for PortBridge files:
the catalog validator discovers PortBridge files as
port_game.*, registering the bridge filename as owner
breaks implementation_linkage validation). (2) Zero
params: placed() takes no state -- no input schema is
upserted (the N1206 zero-param contract precedent:
`source_base_turret_reinitialize_consumers_result`
exists with no `_input` schema; 82 contracts in the
ledger have 0 params). (3) One new result symbol:
placed. Slice source: LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_active_sound_volume import DEFERRED as N2418_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretPlacedProof'
PLACED_OWNER = 'PortGame.source_laser_turret_build_placed_state'
TESTS = ['test_c07_laser_turret_placed_registration', 'test_all_c07_laser_turret_placed_input_evidence_is_exact', 'test_laser_turret_placed_state', 'test_reference_graph_and_actual_c07_laser_turret_placed']
# The 1 slice source the N2422 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public class LaserTurret extends PowerTurret{',
    'public class LaserTurretBuild extends PowerTurretBuild{',
    '@Override',
    'public void placed(){',
    'super.placed();',
]

# DEFERRED is carried from the N2418 register script via import --
# never retyped. All N2418 entries are carried verbatim (the
# N2355 chain, the B/C notes, and N2418's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2422's Windows proof debt.
DEFERRED = list(N2418_DEFERRED) + [
    'LaserTurret placed() Windows Godot proof -- debt in GOAL.md section 5, same as N2360: the N2422 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    # Zero params: placed() takes no state -- no input schema
    # is registered (the N1206 zero-param contract precedent).
    placed_inputs = {}
    placed_outputs = {
        'placed': a('bool', 'super.placed();', 'Whether placed() ran (LaserTurret.java:61, `super.placed();`): the super call runs BaseTurretBuild.placed(); the GD function records that placed() ran, returning a frame with `placed: true`.'),
    }
    return (placed_inputs, placed_outputs)


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (placed_inputs, placed_outputs) = definitions()

    entries = [
        ('N2422', PLACED_OWNER, 'source_laser_turret_build_placed_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.placed()', placed_inputs, placed_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            # Zero params: skip the input schema entirely (the
            # N1206 precedent) -- an empty keys object fails
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.placed() state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.placed() state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: placed.
    by_slice['N2422'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2422', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.placed()', godot_owner=PLACED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2422'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
