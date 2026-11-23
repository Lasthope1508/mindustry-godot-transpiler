"""Register the LaserTurret updateTile() LEG 1 (N2372).

LEG 1 of LaserTurretBuild.updateTile()
(LaserTurret.java:67-89): the whole bullets.any()
branch -- prune dead bullet entries, update each
survivor's bullet position/rotation/time/keepAlive
and decay its life, then set wasShooting/heat/
curRecoil. Leg 2 (the else-if reloadCounter > 0
branch, LaserTurret.java:90-108) is a LATER slice:
the two legs' write-sets are disjoint (leg 1 writes
bullets/wasShooting/heat/curRecoil, leg 2 writes
reloadCounter/liquids), the only join is the
if/else-if guard, and leg 1 returns the branch flag
"reload_branch": "bullets" (leg 2 later returns
"coolant"|"edelta"). Leg-split approved by the main
thread (write-sets disjoint, BurstDrill updateTile
leg precedent N2294+N2149+N2296). The function lives
in the existing PortBridge file (opened by N2360),
following the PortBridge precedent (N2355/N2360/
N2364/N2369).

RED decisions (resolved at RED): (1) The function
lives in the existing PortBridge file: there is no
SourceLaserTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog
validator as port_game.* (source_symbols.
_discover_godot_owner_functions forces class_name
"port_game" for *PortBridge.gd), the same as every
other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2360 PortGame.source_laser_turret_build_should_consume_state,
N2364 PortGame.source_laser_turret_build_update_shooting_state,
N2369 PortGame.source_laser_turret_build_turn_to_target_handle_bullet_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9
failures) -- fixed here, owner PortGame.
(2) `super.updateTile();` is a shared callee (exact
hit in 7 local slices), NOT a distinguishing expr.
(3) `heat = 1f;` / `wasShooting = true;` /
`curRecoil = 1f;` are state outputs in the returned
dict, NOT distinguishing exprs. (4) The shared lines
`entry.bullet.rotation(angle);` /
`entry.bullet.set(bulletX, bulletY);` /
`entry.bullet.keepAlive = true;` (exact 1 hit local:
N2366, different class), `for(var entry : bullets){`
(N2362), the three float declarators (N2366),
`if(bullets.any()){` (N2362, N2364, N2367) are
text-shares across classes/methods, registered
under this java_method (the N632-N639 vs
N1078-N1085 precedent). (5) Angles.trnsx/trnsy here
are the THREE-arg overloads (Angles.java:74-79):
they rotate the (shootX + entry.x, shootY + entry.y)
offset vector by rotation - 90 degrees -- NOT the len
overloads -- so the offset is
Vector2(...).rotated(deg_to_rad(rotation - 90)) (the
N2366 precedent). (6) Time.delta arrives as the
explicit source_delta param (the N2330 param
precedent); Math.max(efficiency, 0.00001f) is maxf.
(7) The bullets seq is NOT ported: it arrives as an
explicit Array of entry dicts {x, y, rotation, life,
bullet: {is_added, type_null, owner_is_self, time,
lifetime, type_optimal_life_fract, keep_alive,
rotation, x, y}} (the N2330 param precedent); the
input array is never mutated, the pruned+updated
list is fresh. (8) NO driver line: a pure function
the tick reads, not a per-tick write; the driver
writes the returned bullets back and evaluates leg 2
when reload_branch is "reload".
Five new result symbols: bullets, was_shooting,
heat, cur_recoil, reload_branch.
Slice source: LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_turn_to_target_handle_bullet import DEFERRED as N2369_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretUpdateTileLeg1Proof'
UPDATE_TILE_LEG1_OWNER = 'PortGame.source_laser_turret_build_update_tile_leg1_state'
TESTS = ['test_c07_laser_turret_update_tile_leg1_registration', 'test_all_c07_laser_turret_update_tile_leg1_input_evidence_is_exact', 'test_laser_turret_update_tile_leg1_state', 'test_reference_graph_and_actual_c07_laser_turret_update_tile_leg1']
# The 1 slice source the N2372 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public class LaserTurret extends PowerTurret{',
    'public class LaserTurretBuild extends PowerTurretBuild{',
    '@Override',
    'public void updateTile(){',
    'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.life <= 0f || b.bullet.owner != this);',
    'if(bullets.any()){',
    'for(var entry : bullets){',
    'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),',
    'bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),',
    'angle = rotation + entry.rotation;',
    'entry.bullet.rotation(angle);',
    'entry.bullet.set(bulletX, bulletY);',
    'entry.bullet.time = entry.bullet.type.lifetime * entry.bullet.type.optimalLifeFract;',
    'entry.bullet.keepAlive = true;',
    'entry.life -= Time.delta * timeScale / Math.max(efficiency, 0.00001f);',
]

# DEFERRED is carried from the N2369 register script via import --
# never retyped. All N2369 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2360/N2364/N2369's own
# Windows proof debt -- none of them is resolved by this
# slice). One entry is added: N2372's Windows proof debt.
DEFERRED = list(N2369_DEFERRED) + [
    'LaserTurret updateTile leg 1 Windows Godot proof -- debt in GOAL.md section 5, same as N2360/N2364/N2369: the N2372 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    remove_all = 'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.life <= 0f || b.bullet.owner != this);'
    trnsx = 'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),'
    trnsy = 'bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),'
    angle_line = 'angle = rotation + entry.rotation;'
    decay = 'entry.life -= Time.delta * timeScale / Math.max(efficiency, 0.00001f);'
    heat_line = 'heat = 1f;'
    cur_recoil_line = 'curRecoil = 1f;'
    was_shooting_line = 'wasShooting = true;'
    guard = 'if(bullets.any()){'
    update_tile_leg1_inputs = {
        'bullets': a('Array', remove_all, 'The bullet entries to prune and update, bullets (LaserTurret.java:70, `bullets.removeAll(...)`): the seq itself is NOT ported -- it arrives as an explicit Array of entry dicts {x, y, rotation, life, bullet} (the N2330 param precedent); the input array is never mutated.'),
        'x': a('float', trnsx, 'The building x, x (LaserTurret.java:76): the bullet position origin.'),
        'y': a('float', trnsy, 'The building y, y (LaserTurret.java:77): the bullet position origin.'),
        'rotation': a('float', angle_line, 'The current rotation, rotation (LaserTurret.java:78): the base angle for the muzzle offset rotation and the entry angle.'),
        'shoot_x': a('float', trnsx, 'The shoot x offset, shootX (LaserTurret.java:76): the muzzle offset vector x component.'),
        'shoot_y': a('float', trnsx, 'The shoot y offset, shootY (LaserTurret.java:76): the muzzle offset vector y component.'),
        'efficiency': a('float', decay, 'The build efficiency, efficiency (LaserTurret.java:84): the life-decay divisor floor Math.max(efficiency, 0.00001f).'),
        'time_scale': a('float', decay, 'The time scale, timeScale (LaserTurret.java:84): scales the life decay.'),
        'source_delta': a('float', decay, 'The frame delta, Time.delta (LaserTurret.java:84): scales the life decay; arrives as the explicit source_delta param (the N2330 param precedent).'),
        'heat': a('float', heat_line, 'The current heat (LaserTurret.java:88, `heat = 1f;`): the value kept when no bullet survives, replaced by 1f when one does -- taken as an explicit in/out param.'),
        'cur_recoil': a('float', cur_recoil_line, 'The current curRecoil (LaserTurret.java:89, `curRecoil = 1f;`): the value kept when no bullet survives, replaced by 1f when one does -- taken as an explicit in/out param.'),
    }
    update_tile_leg1_outputs = {
        'bullets': a('Array', remove_all, 'The pruned+updated bullet entries (LaserTurret.java:70-84): survivors only, each with its bullet moved to the rotated muzzle offset, its time refreshed and keepAlive set, its life decayed -- a fresh Array, the input is never mutated.'),
        'was_shooting': a('bool', was_shooting_line, 'Whether the turret was shooting this tick (LaserTurret.java:87, `wasShooting = true;`): true exactly when a pruned bullet remains.'),
        'heat': a('float', heat_line, 'The heat after the tick (LaserTurret.java:88, `heat = 1f;`): 1f when a bullet survives, otherwise the input heat unchanged.'),
        'cur_recoil': a('float', cur_recoil_line, 'The curRecoil after the tick (LaserTurret.java:89, `curRecoil = 1f;`): 1f when a bullet survives, otherwise the input curRecoil unchanged.'),
        'reload_branch': a('String', guard, 'The branch flag (LaserTurret.java:72, `if(bullets.any()){`): "bullets" when the bullets branch ran, "reload" when it did not -- the driver evaluates leg 2 (the else-if reloadCounter > 0 branch) when it is "reload".'),
    }
    return (update_tile_leg1_inputs, update_tile_leg1_outputs)


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
    (update_tile_leg1_inputs, update_tile_leg1_outputs) = definitions()

    entries = [
        ('N2372', UPDATE_TILE_LEG1_OWNER, 'source_laser_turret_build_update_tile_leg1_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.updateTile()', update_tile_leg1_inputs, update_tile_leg1_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.updateTile() leg 1 state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.updateTile() leg 1 state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: bullets, was_shooting, heat, cur_recoil, reload_branch.
    by_slice['N2372'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2372', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.updateTile()', godot_owner=UPDATE_TILE_LEG1_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2372'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
