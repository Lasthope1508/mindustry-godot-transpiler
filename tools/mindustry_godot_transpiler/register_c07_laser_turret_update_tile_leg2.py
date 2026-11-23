"""Register the LaserTurret updateTile() LEG 2 (N2373).

LEG 2 of LaserTurretBuild.updateTile()
(LaserTurret.java:90-106): the else-if reloadCounter
> 0 branch -- with coolant, burn liquid to cool the
reload counter down (used * liquid.heatCapacity *
coolantMultiplier) and remove the used liquid,
sometimes spawning the cool effect; without coolant,
the counter falls by edelta(). Leg 1 (N2372, the
bullets.any() branch) owns the if/else-if guard's
first leg and returns the branch flag "reload_branch":
"bullets" (leg 2 returns "coolant"|"edelta"). The
two legs' write-sets are disjoint (leg 1 writes
bullets/wasShooting/heat/curRecoil, leg 2 writes
reloadCounter/liquids), the only join is the
if/else-if guard. Leg-split approved by the main
thread (write-sets disjoint, BurstDrill updateTile
leg precedent N2294+N2149+N2296). The function lives
in the existing PortBridge file (opened by N2360),
following the PortBridge precedent (N2355/N2360/
N2364/N2369/N2372).

RED decisions (resolved at RED): (1) NO leg-1 expr
is re-registered here: the class decls, @Override,
`public void updateTile(){` and `if(bullets.any()){`
stay owned by N2372 and are only context/callees
for this leg. (2) The guard `reloadCounter > 0` is
evaluated inside the pure function (the leg-1
precedent); when it fails nothing happens and
reload_branch is "none". (3) `coolant` is
ConsumeLiquid (`coolant.amount` is the per-second
cap): it arrives as an explicit Dictionary {amount}
or null. `coolantMultiplier` is a LaserTurret field
with default 1f (LaserTurret.java:22): it arrives as
an explicit float, the driver passes 1.0 when unset.
`reload` is NOT a param: it never appears in
LaserTurret.java:90-106 (progress() reads it, a
different method). (4) `liquids` is the LiquidModule:
it arrives as an explicit Dictionary (liquid name ->
amount) and is NEVER mutated -- the returned dict is
fresh. `liquids.current()` arrives as the explicit
current_liquid key (the N1243 TractorBeam coolant
precedent); `liquids.remove(liquid, used)` caps the
removal at zero (LiquidModule.remove: "cap to prevent
negative removal"). When cheating, used = maxUsed *
delta() even if less is stored, so the removal still
caps at zero. (5) cheating()/delta()/edelta() are
Building methods (BuildingComp.java:1922-1930):
they arrive as explicit cheating/delta/edelta params.
(6) `Mathf.chance(0.06 * used)` arrives as the
explicit chance_result bool and the two `Mathf.range
(size * tilesize / 2f)` offsets as explicit
range_x/range_y floats (the N1246 TractorBeam
coolant-effect precedent); the effect itself is NOT
ported -- the pure function returns the
cool_effect_call dict (or {} when not spawned), the
driver performs the spawn. (7) NO driver line: a
pure function the tick reads, not a per-tick write;
the driver writes the returned reloadCounter/
liquids back when reload_branch is "coolant" or
"edelta".
Seven new result symbols: reload_counter, liquids,
used, max_used, reload_branch, cool_effect_called,
cool_effect_call.
Slice source: LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_update_tile_leg1 import DEFERRED as N2372_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretUpdateTileLeg2Proof'
UPDATE_TILE_LEG2_OWNER = 'PortGame.source_laser_turret_build_update_tile_leg2_state'
TESTS = ['test_c07_laser_turret_update_tile_leg2_registration', 'test_all_c07_laser_turret_update_tile_leg2_input_evidence_is_exact', 'test_laser_turret_update_tile_leg2_state', 'test_reference_graph_and_actual_c07_laser_turret_update_tile_leg2']
# The 1 slice source the N2373 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    '}else if(reloadCounter > 0){',
    'if(coolant != null){',
    'Liquid liquid = liquids.current();',
    'float maxUsed = coolant.amount;',
    'float used = (cheating() ? maxUsed : Math.min(liquids.get(liquid), maxUsed)) * delta();',
    'reloadCounter -= used * liquid.heatCapacity * coolantMultiplier;',
    'liquids.remove(liquid, used);',
    'if(Mathf.chance(0.06 * used)){',
    'coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));',
    '}else{',
    'reloadCounter -= edelta();',
]

# DEFERRED is carried from the N2372 register script via import --
# never retyped. All N2372 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2360/N2364/N2369/N2372's own
# Windows proof debt -- none of them is resolved by this
# slice). One entry is added: N2373's Windows proof debt.
DEFERRED = list(N2372_DEFERRED) + [
    'LaserTurret updateTile leg 2 Windows Godot proof -- debt in GOAL.md section 5, same as N2360/N2364/N2369/N2372: the N2373 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    guard = '}else if(reloadCounter > 0){'
    coolant_guard = 'if(coolant != null){'
    current_liquid_line = 'Liquid liquid = liquids.current();'
    max_used_line = 'float maxUsed = coolant.amount;'
    used_line = 'float used = (cheating() ? maxUsed : Math.min(liquids.get(liquid), maxUsed)) * delta();'
    coolant_decay = 'reloadCounter -= used * liquid.heatCapacity * coolantMultiplier;'
    remove_line = 'liquids.remove(liquid, used);'
    chance_line = 'if(Mathf.chance(0.06 * used)){'
    cool_effect_line = 'coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));'
    edelta_decay = 'reloadCounter -= edelta();'
    update_tile_leg2_inputs = {
        'reload_counter': a('float', guard, 'The reload counter entering the branch, reloadCounter (LaserTurret.java:90, `}else if(reloadCounter > 0){`): the else-if guard -- when it is not positive nothing happens and reload_branch is "none".'),
        'coolant': a('Variant', coolant_guard, 'The coolant consumer, coolant (LaserTurret.java:92, `if(coolant != null){`): a Dictionary {amount} (ConsumeLiquid.amount, the per-second cap) or null -- null takes the edelta fallback branch.'),
        'coolant_multiplier': a('float', coolant_decay, 'The coolant multiplier, coolantMultiplier (LaserTurret.java:97): a LaserTurret field with default 1f (LaserTurret.java:22, `coolantMultiplier = 1f;`) -- the driver passes 1.0 when unset.'),
        'cheating': a('bool', used_line, 'Whether the building cheats, cheating() (LaserTurret.java:95): a Building method -- when true the used liquid is maxUsed * delta() regardless of what is stored.'),
        'delta': a('float', used_line, 'The frame delta, delta() (LaserTurret.java:95): a Building method (BuildingComp.java:1922-1924, Time.delta * timeScale) -- scales the used liquid.'),
        'edelta': a('float', edelta_decay, 'The efficiency-scaled delta, edelta() (LaserTurret.java:104, `reloadCounter -= edelta();`): a Building method (BuildingComp.java:1927-1929, efficiency * delta()) -- the fallback counter decay without coolant.'),
        'liquids': a('Dictionary', remove_line, 'The stored liquids, liquids (LaserTurret.java:98, `liquids.remove(liquid, used);`): a Dictionary (liquid name -> amount) -- the input is never mutated, the returned dict is fresh.'),
        'current_liquid': a('Variant', current_liquid_line, 'The current liquid, liquids.current() (LaserTurret.java:93, `Liquid liquid = liquids.current();`): the key into the liquids dict (the N1243 TractorBeam coolant precedent) -- null means there is nothing to remove.'),
        'liquid_heat_capacity': a('float', coolant_decay, 'The current liquid heat capacity, liquid.heatCapacity (LaserTurret.java:97): scales how much the used liquid cools the reload counter.'),
        'chance_result': a('bool', chance_line, 'The chance roll result, Mathf.chance(0.06 * used) (LaserTurret.java:100, `if(Mathf.chance(0.06 * used)){`): the explicit bool (the N1246 TractorBeam coolant-effect precedent) -- true spawns the cool effect.'),
        'x': a('float', cool_effect_line, 'The building x, x (LaserTurret.java:101): the cool-effect spawn origin.'),
        'y': a('float', cool_effect_line, 'The building y, y (LaserTurret.java:101): the cool-effect spawn origin.'),
        'size': a('float', cool_effect_line, 'The block size, size (LaserTurret.java:101): the cool-effect spawn range is size * tilesize / 2f.'),
        'source_tilesize': a('float', cool_effect_line, 'The tile size, tilesize (LaserTurret.java:101): the cool-effect spawn range is size * tilesize / 2f.'),
        'range_x': a('float', cool_effect_line, 'The x random offset, Mathf.range(size * tilesize / 2f) (LaserTurret.java:101): the explicit float (the N1246 TractorBeam coolant-effect precedent).'),
        'range_y': a('float', cool_effect_line, 'The y random offset, Mathf.range(size * tilesize / 2f) (LaserTurret.java:101): the explicit float (the N1246 TractorBeam coolant-effect precedent).'),
    }
    update_tile_leg2_outputs = {
        'reload_counter': a('float', coolant_decay, 'The reload counter after the tick (LaserTurret.java:97, `reloadCounter -= used * liquid.heatCapacity * coolantMultiplier;`): cooled by the used liquid with coolant, by edelta() without (LaserTurret.java:104) -- unchanged when the guard fails.'),
        'liquids': a('Dictionary', remove_line, 'The stored liquids after the tick (LaserTurret.java:98, `liquids.remove(liquid, used);`): a fresh Dictionary, the used liquid removed (capped at zero, the LiquidModule.remove contract) -- unchanged without coolant or when the guard fails.'),
        'used': a('float', used_line, 'The liquid used this tick (LaserTurret.java:95, `float used = (cheating() ? maxUsed : Math.min(liquids.get(liquid), maxUsed)) * delta();`): 0 when the guard fails or without coolant.'),
        'max_used': a('float', max_used_line, 'The per-second coolant cap, maxUsed (LaserTurret.java:94, `float maxUsed = coolant.amount;`): 0 when the guard fails or without coolant.'),
        'reload_branch': a('String', guard, 'The branch flag (LaserTurret.java:90, `}else if(reloadCounter > 0){`): "coolant" when the coolant branch ran, "edelta" when the fallback ran, "none" when the guard failed -- the driver writes the returned reloadCounter/liquids back on "coolant" or "edelta".'),
        'cool_effect_called': a('bool', chance_line, 'Whether the cool effect spawned (LaserTurret.java:100, `if(Mathf.chance(0.06 * used)){`): true exactly when the coolant branch ran and the chance roll hit.'),
        'cool_effect_call': a('Dictionary', cool_effect_line, 'The cool-effect spawn call (LaserTurret.java:101, `coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));`): {call, x, y, range} when spawned, {} otherwise -- the driver performs the spawn.'),
    }
    return (update_tile_leg2_inputs, update_tile_leg2_outputs)


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
    (update_tile_leg2_inputs, update_tile_leg2_outputs) = definitions()

    entries = [
        ('N2373', UPDATE_TILE_LEG2_OWNER, 'source_laser_turret_build_update_tile_leg2_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.updateTile()', update_tile_leg2_inputs, update_tile_leg2_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.updateTile() leg 2 state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.updateTile() leg 2 state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: reload_counter, liquids, used, max_used, reload_branch, cool_effect_called, cool_effect_call.
    by_slice['N2373'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2373', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.updateTile()', godot_owner=UPDATE_TILE_LEG2_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2373'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
