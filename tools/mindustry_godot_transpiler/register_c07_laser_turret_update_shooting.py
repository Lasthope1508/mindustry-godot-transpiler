"""Register the LaserTurret updateShooting() (N2364).

LaserTurretBuild.updateShooting()
(LaserTurret.java:120-132, `protected void updateShooting(){` /
`if(bullets.any()){` / `return;` /
`if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){` /
`BulletType type = peekAmmo();` / `shoot(type);` /
`reloadCounter = reload;`) is one pure decision function on
the SourceLaserTurretBuildPortBridge.gd (opened by N2360),
following the PortBridge precedent (N2355/N2360). It shoots
only when no bullet is around and the guard holds
(reloadCounter <= 0, efficiency > 0, not charging,
shootWarmup >= minWarmup); the driver performs shoot(type).

RED decisions (resolved at RED): (1) The function lives
in the existing PortBridge file: there is no
SourceLaserTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2360 PortGame.source_laser_turret_build_should_consume_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) The bullets seq is NOT ported: its emptiness arrives
as the explicit has_bullets param (the N2330 param
precedent). peekAmmo() (N1172, PowerTurretBuild -- body
`return shootType;`), charging() (Turret.java:715-717 --
`return queuedBullets > 0 && shoot.firstShotDelay > 0;`)
and shoot(type) are callees -- their values arrive as
explicit params, not re-ported here. (3) All inputs are
scalars (plus one Variant ammo type) -- there is no dict
frame input, so there is no input-unmutated proof key for
this slice (unlike the frame-taking Turret accessors).
(4) NO driver line: a pure decision function the tick
reads, not a per-tick write. (5) Evidence, not
ownership: `if(bullets.any()){` also appears in local
N2362 (ContinuousTurret updateTile, a different class/
method) -- text-share across methods, registry precedent
OK; this slice registers the correct java_method and
notes the share here. Three new result symbols:
should_shoot, shoot_type, reload_counter. Slice source:
LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_should_consume import DEFERRED as N2360_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretUpdateShootingProof'
UPDATE_SHOOTING_OWNER = 'PortGame.source_laser_turret_build_update_shooting_state'
TESTS = ['test_c07_laser_turret_update_shooting_registration', 'test_all_c07_laser_turret_update_shooting_input_evidence_is_exact', 'test_laser_turret_update_shooting_state', 'test_reference_graph_and_actual_c07_laser_turret_update_shooting']
# The 1 slice source the N2364 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public class LaserTurret extends PowerTurret{',
    'public class LaserTurretBuild extends PowerTurretBuild{',
    '@Override',
    'protected void updateShooting(){',
    'if(bullets.any()){',
    'if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){',
    'BulletType type = peekAmmo();',
    'shoot(type);',
    'reloadCounter = reload;',
]

# DEFERRED is carried from the N2360 register script via import --
# never retyped. All N2360 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2360's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2364's Windows proof debt.
DEFERRED = list(N2360_DEFERRED) + [
    'LaserTurret updateShooting Windows Godot proof -- debt in GOAL.md section 5, same as N2360: the N2364 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    guard = 'if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){'
    update_shooting_inputs = {
        'has_bullets': a('bool', 'if(bullets.any()){', 'Whether the bullets seq is non-empty, bullets.any() (LaserTurret.java:121): the seq itself is NOT ported -- its emptiness arrives as an explicit param (the N2330 param precedent).'),
        'reload_counter': a('float', guard, 'The reload counter, reloadCounter (LaserTurret.java:124): shooting requires it at or below zero.'),
        'efficiency': a('float', guard, 'The build efficiency, efficiency (LaserTurret.java:124): shooting requires it above zero.'),
        'charging': a('bool', guard, 'Whether the turret is charging, charging() (LaserTurret.java:124, Turret.java:715-717): a callee, its value arrives as an explicit param, not re-ported here.'),
        'shoot_warmup': a('float', guard, 'The shoot warmup, shootWarmup (LaserTurret.java:124): shooting requires it at or above minWarmup.'),
        'min_warmup': a('float', guard, 'The minimum warmup, minWarmup (LaserTurret.java:124, Turret.java:76 `public float minWarmup = 0f;`): the shoot threshold.'),
        'reload': a('float', 'reloadCounter = reload;', 'The reload time, reload (LaserTurret.java:129): the new reloadCounter when shooting.'),
        'ammo_type': a('Variant', 'BulletType type = peekAmmo();', 'The peekAmmo() result, BulletType type (LaserTurret.java:126): peekAmmo() is owned at N1172 (PowerTurretBuild, body `return shootType;`), its value arrives as an explicit param, not re-ported here.'),
    }
    update_shooting_outputs = {
        'should_shoot': a('bool', 'shoot(type);', 'Whether to shoot (LaserTurret.java:127, `shoot(type);`): true only when no bullet is around and the guard holds -- the shoot call is the observable effect of the decision.'),
        'shoot_type': a('Variant', 'BulletType type = peekAmmo();', 'The type to shoot (LaserTurret.java:126, `BulletType type = peekAmmo();`): the peekAmmo() result when shooting, null otherwise.'),
        'reload_counter': a('float', 'reloadCounter = reload;', 'The new reload counter (LaserTurret.java:129, `reloadCounter = reload;`): reload when shooting, the input value otherwise.'),
    }
    return (update_shooting_inputs, update_shooting_outputs)


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
    (update_shooting_inputs, update_shooting_outputs) = definitions()

    entries = [
        ('N2364', UPDATE_SHOOTING_OWNER, 'source_laser_turret_build_update_shooting_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.updateShooting()', update_shooting_inputs, update_shooting_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.updateShooting() state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.updateShooting() state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: should_shoot, shoot_type, reload_counter.
    by_slice['N2364'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2364', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.updateShooting()', godot_owner=UPDATE_SHOOTING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2364'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
