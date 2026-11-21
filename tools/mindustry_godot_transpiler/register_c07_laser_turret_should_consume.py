"""Register the LaserTurret shouldConsume() (N2360).

LaserTurretBuild.shouldConsume()
(LaserTurret.java:53-58, `@Override` /
`public boolean shouldConsume(){` /
`//still consumes power when bullet is around` /
`if(bullets.any() || isActive()) return true;` /
`return isShooting;`) is one pure function on the NEW
SourceLaserTurretBuildPortBridge.gd, following the
ItemTurret PortBridge precedent
(SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state) and the
ContinuousTurret PortBridge precedent (N2355). It still
consumes power while a bullet is around (bullets.any())
or while it is active (isActive(), N2328); otherwise it
consumes only while shooting (isShooting, N2343).

RED decisions (resolved at RED): (1) The function lives
directly in the new PortBridge file: there is no
SourceLaserTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) The bullets seq is NOT ported: its emptiness arrives
as the explicit has_bullets param (the N2330 param
precedent). isActive() (N2328) and isShooting (N2343)
are owned elsewhere -- their values arrive as explicit
params, not re-ported here. (3) All inputs are scalars --
there is no dict frame input, so there is no
input-unmutated proof key for this slice (unlike the
frame-taking Turret accessors). (4) NO driver line: a
pure predicate the power graph reads, not a per-tick
write. (5) Evidence, not ownership: the other
shouldConsume overrides own their own bodies --
TurretBuild base (N2291), ContinuousLiquidTurretBuild
(N1225), TractorBeamBuild (N1235), DrillBuild (N2338),
BurstDrillBuild (N2295) -- and are NOT touched here.
One new result symbol: should_consume. Slice source:
LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_get_ammo_fraction import DEFERRED as N2355_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretShouldConsumeProof'
SHOULD_CONSUME_OWNER = 'PortGame.source_laser_turret_build_should_consume_state'
TESTS = ['test_c07_laser_turret_should_consume_registration', 'test_all_c07_laser_turret_should_consume_input_evidence_is_exact', 'test_laser_turret_should_consume_state', 'test_reference_graph_and_actual_c07_laser_turret_should_consume']
# The 1 slice source the N2360 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public class LaserTurret extends PowerTurret{',
    'public class LaserTurretBuild extends PowerTurretBuild{',
    '@Override',
    'public boolean shouldConsume(){',
    '//still consumes power when bullet is around',
    'if(bullets.any() || isActive()) return true;',
    'return isShooting;',
]

# DEFERRED is carried from the N2355 register script via import --
# never retyped. All N2355 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2355's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2360's Windows proof debt.
DEFERRED = list(N2355_DEFERRED) + [
    'LaserTurret shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2355: the N2360 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_consume_inputs = {
        'has_bullets': a('bool', 'if(bullets.any() || isActive()) return true;', 'Whether the bullets seq is non-empty, bullets.any() (LaserTurret.java:55): the seq itself is NOT ported -- its emptiness arrives as an explicit param (the N2330 param precedent).'),
        'is_active': a('bool', 'if(bullets.any() || isActive()) return true;', 'Whether the turret is active, isActive() (LaserTurret.java:55): owned at N2328, its value arrives as an explicit param, not re-ported here.'),
        'is_shooting': a('bool', 'return isShooting;', 'Whether the turret is shooting, isShooting (LaserTurret.java:56): owned at N2343, its value arrives as an explicit param, not re-ported here.'),
    }
    should_consume_outputs = {
        'should_consume': a('bool', 'return isShooting;', 'Whether the turret should consume power (LaserTurret.java:56, `return isShooting;`): true while a bullet is around or while active, otherwise the isShooting flag -- the fall-through return defines the result.'),
    }
    return (should_consume_inputs, should_consume_outputs)


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
    (should_consume_inputs, should_consume_outputs) = definitions()

    entries = [
        ('N2360', SHOULD_CONSUME_OWNER, 'source_laser_turret_build_should_consume_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.shouldConsume()', should_consume_inputs, should_consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.shouldConsume() state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.shouldConsume() state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: should_consume.
    by_slice['N2360'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2360', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.shouldConsume()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2360'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
