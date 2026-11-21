"""Register the Turret updateCooling() coolant fold (N2525).

updateCooling() is `protected void updateCooling(){` /
`if(canReload() && coolant != null &&
coolant.efficiency(this) > 0 && efficiency > 0){` /
`float capacity = coolant instanceof ConsumeLiquidFilter
filter ? filter.getConsumed(this).heatCapacity :
(coolant.consumes(liquids.current()) ?
liquids.current().heatCapacity : 0.4f);` /
`float amount = coolant.amount *
coolant.efficiency(this);` / `coolant.update(this);` /
`reloadCounter += amount * edelta() * capacity *
coolantMultiplier * ammoReloadMultiplier();` /
`if(Mathf.chance(0.06 * amount)){`
(ReloadTurret.java:28-38), the shared ReloadTurretBuild
implementation every ReloadTurret subclass runs from
Turret.java:550 (`if(reloadWhileCharging ||
!charging()){` / `updateReload();` / `updateCooling(); }`,
"turret always reloads regardless of whether it's
targeting something"). This slice ports it for the Turret
family as one pure function mirroring
`source_point_defense_turret_cooling_state` (N2241), with
one added parameter: `ammo_reload_multiplier` is the
Turret.java:727 override (`return hasAmmo() ?
peekAmmo().reloadMultiplier : 1f;`, NOT the
ReloadTurret.java:41-43 default 1f); `coolantMultiplier`
is 5f for the Turret family (BaseTurret.java:32 -- no
override in ItemTurret / Turret / PowerTurret; only
PointDefenseTurret 2f, LaserTurret / ContinuousTurret /
TractorBeamTurret 1f); `capacity` is the consumed
liquid's heatCapacity (ReloadTurret.java:30, the
ConsumeLiquidFilter filter branch -- ConsumeCoolant
extends ConsumeLiquidFilter), passed in as a parameter
with the 0.4f fallback belonging to the coolant-pick
slice, not this function; `edelta()` is `efficiency *
delta()` (BuildingComp.java:1927-1929), passed in
precomputed; the coolEffect chance is a random visual,
NOT in the pure function (the N2240 random-pitch
precedent); `coolant.update(this)` removes `amount *
edelta() * multiplier` -- the pure function returns that
as `coolant_consumed` for a later wiring slice to apply,
since the frame carries no liquid inventory (the N2241
precedent). NO driver tick call site: the frame carries
no liquid state and the catalog records `coolant` for NO
block, so the driver tick cannot read a coolant amount
today; the call-site gate (`reloadWhileCharging ||
!charging()`, Turret.java:550) belongs to the
driver-tick slice. LaserTurret / ContinuousTurret
override updateCooling into a no-op
(LaserTurret.java:48-50, ContinuousTurret.java:49-51),
so meltdown (coolant 0.5f, Blocks.java:4346) never uses
this function -- out of scope, no slice needed unless
Java changes.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_cooling_state(frame, has_coolant,
coolant_amount, coolant_efficiency, heat_capacity,
coolant_multiplier, ammo_reload_multiplier, reload,
edelta), placed immediately AFTER
source_turret_should_consume_state (the other
ReloadTurret-port helper, N2524) and BEFORE
source_turret_can_heal_state. It reads
`reload_counter` (default 0.0) and `efficiency`
(default 1.0) from the frame and returns exactly three
keys, `reload_counter` / `cooling_applied` /
`coolant_consumed` (the N2241 PointDefense precedent).
(2) NO tick call site -- the function is DORMANT live
today: the driver tick never calls it, so live behavior
does not change. (3) The Turret-family coolant pick
reuses `source_point_defense_turret_coolant_state`
(N2248) as-is -- NO twin is written by this slice: its
ConsumeCoolant filter / getConsumed pick / efficiency /
removal / heatCapacity / coolEffect-chance math is
class-level ConsumeCoolant/ConsumeLiquidFilter logic
with no PointDefense-specific branch (only the name is
PointDefense-specific); the future coolant-pick slice
calls it directly. SSOT expected after GREEN: symbols
+3, Done +1, contracts +1, schema +2, 11712/1753/1686/3163
-> 11715/1754/1687/3165; defense shard slices 212 -> 213,
contracts 211 -> 212; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_should_consume import DEFERRED as N2524_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretCoolingProof'
COOLING_OWNER = 'SourceTurretBuildState.source_turret_cooling_state'
TESTS = ['test_c07_turret_cooling_registration', 'test_all_c07_turret_cooling_input_evidence_is_exact', 'test_turret_cooling_state', 'test_reference_graph_and_actual_c07_turret_cooling']
# The slice sources the N2525 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){',
    'float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);',
    'float amount = coolant.amount * coolant.efficiency(this);',
    'reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();',
    'if(Mathf.chance(0.06 * amount)){',
]

# DEFERRED is carried from the N2524 register script via import --
# never retyped. No entry is dropped: the updateCooling coolant
# fold the N2524 pool entry deferred is recorded DONE below.
# New entries below record the fold as DONE by this slice, the
# Windows proof debt, and the reuse decision for the
# Turret-family coolant pick (reuse N2248 as-is, no twin).
DEFERRED = N2524_DEFERRED + [
    'Turret updateCooling() coolant fold (`reload_counter` / `cooling_applied` / `coolant_consumed` frame keys) -- DONE by this slice (N2525): `source_turret_cooling_state` ports ReloadTurret.java:28-38 for the Turret family (gate `canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0`, boost `amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier()` with coolantMultiplier 5f, BaseTurret.java:32, and the Turret.java:727 ammoReloadMultiplier override), mirroring `source_point_defense_turret_coolant_state` (N2241) with one added parameter. NO driver tick call site: the frame carries no liquid state and the catalog records `coolant` for NO block, so the driver tick cannot read a coolant amount today; the Turret.java:550 call-site gate (`reloadWhileCharging || !charging()`) belongs to the driver-tick slice. Dormant live today: the driver tick never calls the function, so live behavior does not change.',
    'Turret updateCooling() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524: the N2525 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret-family coolant pick reuses `source_point_defense_turret_coolant_state` (N2248) as-is -- DECIDED by N2525 (no twin): the ConsumeCoolant filter / getConsumed pick / efficiency / removal / heatCapacity / coolEffect-chance math is class-level ConsumeCoolant/ConsumeLiquidFilter logic with no PointDefense-specific branch (only the function name is PointDefense-specific); the future Turret-family coolant-pick slice calls it directly via preload and does NOT write a twin. BLOCKED on liquid-module wiring + catalog coolant capture (the frame carries no liquid state; the catalog records `coolant` for no block).',
]


def definitions():
    def a(typ, expr, rule, source=RELOAD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    cooling_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (the port Building state) the tick stamps every tick (`public void updateTile(){`, Turret.java:490 -- the driver tick for every Turret-family build); the pure function reads `reload_counter` (default 0.0, N2240 stamp) and `efficiency` (default 1.0) from it and returns exactly three keys (the N2241 precedent).', source=TURRET),
        'has_coolant': a('bool', 'coolant != null', 'Whether the def defines a coolant consumer (`coolant != null`, ReloadTurret.java:29 -- the gate half; BaseTurret.init finds it with `coolant = findConsumer(c -> c instanceof ConsumeCoolant);`, BaseTurret.java:50-52; the catalog records `coolant` for NO block, so this is false live today).'),
        'coolant_amount': a('float', 'coolant.amount', 'The ConsumeCoolant consumer amount field (`coolant.amount`, ReloadTurret.java:31, `float amount = coolant.amount * coolant.efficiency(this);`): duo 0.1f, scatter 0.2f, salvo 0.2f, foreshadow 1f (Blocks.java); the local amount is this times the efficiency.'),
        'coolant_efficiency': a('float', 'coolant.efficiency(this)', 'The ConsumeCoolant efficiency (`coolant.efficiency(this)`, ReloadTurret.java:29, :31 -- `min(liquids.get(liq) / (amount * ed * multiplier), 1f)`, ConsumeLiquidFilter.java:50-56, 0 when no liquid): passed in as a parameter, computed by the future coolant-pick slice reusing `source_point_defense_turret_coolant_state` (N2248).'),
        'heat_capacity': a('float', 'float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', 'The consumed liquid heatCapacity (ReloadTurret.java:30, the ConsumeLiquidFilter filter branch applies because ConsumeCoolant extends ConsumeLiquidFilter); passed in as a parameter, with the 0.4f fallback belonging to the coolant-pick slice, not this function.'),
        'coolant_multiplier': a('float', 'public float coolantMultiplier = 5f;', 'The per-class coolant multiplier (`public float coolantMultiplier = 5f;`, BaseTurret.java:32 -- the Turret-family value; no override in ItemTurret / Turret / PowerTurret; only PointDefenseTurret 2f, LaserTurret / ContinuousTurret / TractorBeamTurret 1f).', source=BASE_TURRET),
        'ammo_reload_multiplier': a('float', 'return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;', 'The Turret ammo reload multiplier (Turret.java:727, `return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;` -- the Turret override, NOT the ReloadTurret.java:41-43 default 1f); passed in as a parameter, live peekAmmo wiring is a later slice (the frame has no peeked reloadMultiplier yet).', source=TURRET),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time in ticks (`public float reload = 10f;`, ReloadTurret.java:10 -- the class default; duo 20f, scatter 18f, salvo 29f, foreshadow 200f, Blocks.java): the canReload() gate half (`return reloadCounter < reload;`, ReloadTurret.java:46-48).'),
        'edelta': a('float', 'return efficiency * delta();', 'The per-tick efficiency-scaled delta (`return efficiency * delta();`, BuildingComp.java:1927-1929, `edelta()` is `efficiency * delta()`), passed in precomputed (the N2240/N2248 precedent).', source=BUILDING_COMP),
    }
    cooling_outputs = {
        'reload_counter': a('float', 'reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();', 'The reload counter after the coolant boost (`reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();`, ReloadTurret.java:33, with `amount = coolant.amount * coolant.efficiency(this)`, :31); unchanged when the gate fails.'),
        'cooling_applied': a('bool', 'if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){', 'Whether the updateCooling gate passed (ReloadTurret.java:29, `if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){`, canReload() = `reloadCounter < reload`, :46-48); false whenever the gate fails, and `coolant_consumed` is 0.0 then.'),
        'coolant_consumed': a('float', 'coolant.update(this);', 'The coolant amount the update removes (`coolant.update(this);`, ReloadTurret.java:32 -- `amount * edelta() * multiplier`, ConsumeLiquidFilter.java:44-49, multiplier default 1f, returned for a later wiring slice to apply since the frame carries no liquid inventory; the N2241 precedent).'),
    }
    return cooling_inputs, cooling_outputs


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
    cooling_inputs, cooling_outputs = definitions()

    entries = [
        ('N2525', COOLING_OWNER, 'source_turret_cooling_state', RELOAD_TURRET, 'mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', 'ReloadTurretBuild.updateCooling()', cooling_inputs, cooling_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret updateCooling() coolant fold from ReloadTurret.java:28-38 + Turret.java:550/:727 + BaseTurret.java:32 + BuildingComp.java:1927-1929 + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret updateCooling() coolant fold from ReloadTurret.java:28-38 + Turret.java:550/:727 + BaseTurret.java:32 + BuildingComp.java:1927-1929 + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: reload_counter,
    # cooling_applied, coolant_consumed.
    by_slice['N2525'] = [
        'source_turret_cooling_state_result.reload_counter',
        'source_turret_cooling_state_result.cooling_applied',
        'source_turret_cooling_state_result.coolant_consumed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2525', dict(status='done', java_source=RELOAD_TURRET, java_class='mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', java_method='ReloadTurretBuild.updateCooling()', godot_owner=COOLING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2525'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
