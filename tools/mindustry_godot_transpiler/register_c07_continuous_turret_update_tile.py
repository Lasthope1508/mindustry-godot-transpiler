"""Register the ContinuousTurret updateTile() (N2362).

ContinuousTurretBuild.updateTile()
(ContinuousTurret.java:86-101, `@Override` /
`public void updateTile(){` /
`super.updateTile();` /
`bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);` /
`if(bullets.any()){` /
`for(var entry : bullets){` /
`updateBullet(entry);` /
`wasShooting = true;` /
`heat = 1f;` /
`curRecoil = recoil;`) is one pure function on the
existing SourceContinuousTurretBuildPortBridge.gd (created
by N2355), following the ItemTurret PortBridge precedent
(SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state) and the
ContinuousTurret PortBridge precedent (N2355). It prunes
dead bullets, then when any bullet survives it flags
wasShooting, sets heat to 1f and curRecoil to recoil.

RED decisions (resolved at RED): (1) The function lives
directly in the existing PortBridge file: there is no
SourceContinuousTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed at N2355, owner PortGame here.
(2) super.updateTile() is the TurretBuild base tick
(Turret.java:490): it resets wasShooting to false
(Turret.java:517) and decays heat / curRecoil toward 0, so
this slice reads the post-super frame -- was_shooting is
true exactly when pruned bullets remain, and heat /
cur_recoil arrive as explicit in/out params that keep
their input values when no bullet remains (the N2330
param precedent). super is NOT re-ported here: the base
tick is owned elsewhere.
(3) The bullets seq is NOT ported: it arrives as an
explicit param, an Array of {is_added, type_null,
owner_is_self} dicts (the N2313 hasAmmo Array precedent),
and the function returns a fresh pruned Array -- the
input array is never mutated.
(4) updateBullet(entry) is a CALLEE -- its body is NOT
ported in this slice (batch 13+, draft §4e); only the
call line is registered as evidence, the same as the
super.handleLiquid callee evidence at batch 10.
(5) NO driver line yet: the pure function returns the
frame the driver writes; the driver tick that calls it
per tick is a later slice. (6) Evidence, not ownership:
the other updateTile overrides own their own bodies --
TurretBuild base (remote N2250/N2263 family), ItemTurret,
LaserTurret (unscoped, draft §5f), BurstDrill (N2294 +
N2149 + N2296) -- and are NOT touched here. The
wasShooting = true line shares text with remote N2250
(TurretBuild.updateTile, different class/method) -- text
overlap only, registered under the correct java_method
(the N632-N639 vs N1078-N1085 precedent). Four new
result symbols: bullets, was_shooting, heat, cur_recoil.
Slice source: ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_should_consume import DEFERRED as N2360_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretUpdateTileProof'
UPDATE_TILE_OWNER = 'PortGame.source_continuous_turret_build_update_tile_state'
TESTS = ['test_c07_continuous_turret_update_tile_registration', 'test_all_c07_continuous_turret_update_tile_input_evidence_is_exact', 'test_continuous_turret_update_tile_state', 'test_reference_graph_and_actual_c07_continuous_turret_update_tile']
# The 1 slice source the N2362 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurret extends Turret{',
    'public class ContinuousTurretBuild extends TurretBuild{',
    '@Override',
    'public void updateTile(){',
    'super.updateTile();',
    'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);',
    'if(bullets.any()){',
    'for(var entry : bullets){',
    'updateBullet(entry);',
    'wasShooting = true;',
    'heat = 1f;',
    'curRecoil = recoil;',
]

# DEFERRED is carried from the N2360 register script via import --
# never retyped. All N2360 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2360's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2362's Windows proof debt.
DEFERRED = list(N2360_DEFERRED) + [
    'ContinuousTurret updateTile Windows Godot proof -- debt in GOAL.md section 5, same as N2360: the N2362 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_tile_inputs = {
        'bullets': a('Array', 'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);', 'The bullets seq (ContinuousTurret.java:89): the ContinuousTurretBuild field -- NOT re-ported here (BulletEntry/Seq are not ported); it arrives as an explicit param (the N2313 hasAmmo Array precedent) as an Array of {is_added, type_null, owner_is_self} dicts, one per BulletEntry, and the function returns a fresh pruned Array -- the input array is never mutated.'),
        'recoil': a('float', 'curRecoil = recoil;', 'The block recoil field (ContinuousTurret.java:98): the value curRecoil is set to when a bullet survives -- taken as an explicit param.'),
        'heat': a('float', 'heat = 1f;', 'The current heat after the super tick decayed it toward 0 (ContinuousTurret.java:97, Turret.java:525): the value kept when no bullet survives, replaced by 1f when one does -- taken as an explicit in/out param.'),
        'cur_recoil': a('float', 'curRecoil = recoil;', 'The current curRecoil after the super tick decayed it toward 0 (ContinuousTurret.java:98, Turret.java:519): the value kept when no bullet survives, replaced by recoil when one does -- taken as an explicit in/out param.'),
    }
    update_tile_outputs = {
        'bullets': a('Array', 'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);', 'The bullets seq after pruning (ContinuousTurret.java:89, `bullets.removeAll(...)`): only entries whose bullet is added, whose type is not null, and whose owner is this turret survive, in original order.'),
        'was_shooting': a('bool', 'wasShooting = true;', 'Whether the turret was shooting this tick (ContinuousTurret.java:96, `wasShooting = true;`): super.updateTile() resets wasShooting to false first (Turret.java:517), so this is true exactly when pruned bullets remain.'),
        'heat': a('float', 'heat = 1f;', 'The heat after the tick (ContinuousTurret.java:97, `heat = 1f;`): 1f when a bullet survives, otherwise the input heat unchanged.'),
        'cur_recoil': a('float', 'curRecoil = recoil;', 'The curRecoil after the tick (ContinuousTurret.java:98, `curRecoil = recoil;`): recoil when a bullet survives, otherwise the input curRecoil unchanged.'),
    }
    return (update_tile_inputs, update_tile_outputs)


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
    (update_tile_inputs, update_tile_outputs) = definitions()

    entries = [
        ('N2362', UPDATE_TILE_OWNER, 'source_continuous_turret_build_update_tile_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.updateTile()', update_tile_inputs, update_tile_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.updateTile() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.updateTile() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: bullets, was_shooting, heat, cur_recoil.
    by_slice['N2362'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2362', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.updateTile()', godot_owner=UPDATE_TILE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2362'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
