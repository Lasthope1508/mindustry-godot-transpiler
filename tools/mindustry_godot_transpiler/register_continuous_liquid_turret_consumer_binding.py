"""Register the ContinuousLiquidTurret RuntimeConsumer binding (N2106).

N2104 captured the class init's ConsumeLiquidFilter into the content
registry (one consumeLiquid descriptor per ammo liquid at liquidConsumed
1/60) and N2105 wired the tick to read ammoTypes from the registry, but
nothing consumed the liquid yet: a placed sublimate kept its ozone and
cyanogen forever. N2106 binds a RuntimeConsumer actor per consumeLiquid
row (the drill model, N2097/N2100) into the live-loop tick and runs it
through BuildingComp.updateConsumption's second pass, so the placed
turret actually consumes its ammo liquid each tick.

Java: ContinuousLiquidTurret.init() consumes through a
ConsumeLiquidFilter over exactly the ammo liquids
(ContinuousLiquidTurret.java:40-51, liquidConsumed 1f/60f at :15) with
the multiplier lambda (1f / ammo.ammoMultiplier for the current liquid's
bullet type, 1f when the liquid has no ammo type). The filter's update
removes amount * edelta * multiplier from getConsumed
(ConsumeLiquidFilter.java), where getConsumed is the current liquid
when the filter admits it and its amount is positive, else the first
content liquid the filter admits with amount left. updateConsumption
(BuildingComp.java:1943-2004) runs the first pass (minimum efficiency
of the non-optional consumers) and the second pass (update every update
consumer when update, i.e. shouldConsume() && productionValid(), and
efficiency > 0); the turret's shouldConsume is super.shouldConsume()
(enabled) && activated, with the hysteresis updated after
super.updateTile() (ContinuousLiquidTurret.java:71-81). Removing a
liquid sets current to it (LiquidModule.remove -> add,
LiquidModule.java:110-112, 125-127), so the first tick after water
arrives pays the water-current multiplier 1.0 and the next ticks pay
1/1.2 once current flips to ozone.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java'
FILTER = 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java'
BUILDING = 'core/src/mindustry/entities/comp/BuildingComp.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BIND_OWNER = 'SourceContinuousLiquidTurretBuildState.source_bind_consumer_state'
CONSUMED_OWNER = 'SourceContinuousLiquidTurretBuildState.source_consumed_liquid_state'
TICK_OWNER = 'SourceContinuousLiquidTurretBuildState.source_tick_buildings_state'
PROOF = '/root/ContinuousLiquidTurretLiveLoopProof'
TESTS = ['test_continuous_liquid_turret_consumer_binding_registration', 'test_all_continuous_liquid_turret_consumer_binding_input_evidence_is_exact', 'test_tick_binds_a_runtime_consumer_for_sublimate', 'test_reference_graph_and_actual_continuous_liquid_turret_consumer_binding']
DEFERRED = [
    'Wiring other buildings (turrets, factories) to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){',
    'public float liquidConsumed = 1f / 60f;',
    'multiplier = b -> {',
    'var ammo = ammoTypes.get(b.liquids.current());',
    'return ammo == null ? 1f : 1f / ammo.ammoMultiplier;',
    'return super.shouldConsume() && activated;',
    'public @Nullable Liquid getConsumed(Building build){',
    'if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){',
    'build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));',
    'public void updateConsumption(){',
    'for(var cons : block.updateConsumers){',
    'cons.update(self());',
    'public float edelta(){',
    'public void remove(Liquid liquid, float amount){',
    'add(liquid, Math.max(-amount, -liquids[liquid.id]));',
    'current = liquid;',
    'protected Seq<Consume> consumeBuilder = new Seq<>();',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2106_bind_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The turret frame (the port Building state) the consumers bind onto; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'public class ContinuousLiquidTurret extends ContinuousTurret{', 'The typed block definition; only a block carrying consumeLiquid rows binds consumers.'),
        'catalog': f('Object', 'content.liquids().each(filter, item -> block.liquidFilter[item.id] = true);', 'The content catalog the bound rows resolve their liquid fields against (content.liquids()).', source=FILTER),
        'amounts': f('Dictionary', 'public void remove(Liquid liquid, float amount){', "The building's liquid module the actors remove from (LiquidModule.remove).", source=LIQUID_MODULE),
    }
    n2106_bind_outputs = {
        'bound': f('bool', 'consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){', 'Whether RuntimeConsumer actors were created on this call; false when the frame already carries them.'),
        'consumers': f('Array', 'build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', 'The RuntimeConsumer actors on the frame, one per bound consumeLiquid row.', source=FILTER),
        'rows': f('Array', 'public float liquidConsumed = 1f / 60f;', 'The bound consumeLiquid rows (liquid id + amount at liquidConsumed 1/60).'),
    }
    n2106_consumed_inputs = {
        'frame': f('Dictionary', 'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();', 'The turret frame; carries current_liquid and ammo_types (the filter).'),
        'liquids': f('Dictionary', 'public Liquid current(){', "The building's liquid module whose current liquid and amounts getConsumed reads.", source=LIQUID_MODULE),
        'liquid_names_by_id': f('Array', 'public Liquid current(){', 'Content liquid names indexed by liquid id (Java resolves a liquid by id through content.liquid(id)).', source=LIQUID_MODULE),
    }
    n2106_consumed_outputs = {
        'consumed_liquid': f('Variant', 'public @Nullable Liquid getConsumed(Building build){', 'The liquid id getConsumed returns, null when no ammo liquid has amount left.', source=FILTER),
        'consumed_index': f('int', 'for(int i = 0; i < liqs.size; i++){', 'Its index in the content liquids, -1 when none.', source=FILTER),
    }

    entries = [
        ('N2106', BIND_OWNER, 'source_bind_consumer_state', TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret', 'init()', n2106_bind_inputs, n2106_bind_outputs, True, 'Dictionary'),
        ('N2106', CONSUMED_OWNER, 'source_consumed_liquid_state', FILTER, 'mindustry.world.consumers.ConsumeLiquidFilter', 'getConsumed(Building build)', n2106_consumed_inputs, n2106_consumed_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret RuntimeConsumer binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret RuntimeConsumer binding; the tick binds one RuntimeConsumer per consumeLiquid row and consumes only getConsumed each tick through updateConsumption.'))
        all_names.extend(names)

    # The live-loop tick driver (N2103) gains the frame delta it needs
    # to drive the consumer edelta (N2101 pattern: deepcopy the
    # existing schema/contract entries and extend them, keeping the
    # N2103 source_slice the driver itself was registered under).
    seconds_meta = f('float', 'timeScaleDuration -= Time.delta', 'Frame delta in seconds driving the tick (Godot seconds are converted once through the canonical source tick rate).', source=BUILDING)
    seconds_meta['used_by'] = [TICK_OWNER]
    seconds_symbol = 'source_tick_buildings_state_input.seconds'
    all_names.append(seconds_symbol)
    symbols[seconds_symbol] = dict(status='source-backed', godot_owner=TICK_OWNER, godot_symbol=seconds_symbol, java_source=seconds_meta['java_source'], java_method='ContinuousLiquidTurretBuild.updateTile()', java_expr=seconds_meta['java_expr'], rule=seconds_meta['rule'], tests=TESTS, runtime_proof=PROOF)
    schemas = source_symbols.load_source_state_schema(GODOT)['schemas']
    tick_input = copy.deepcopy(schemas['source_tick_buildings_state_input'])
    tick_input['keys'].update({'seconds': seconds_meta})
    source_symbols.upsert_source_state_schema(GODOT, 'source_tick_buildings_state_input', tick_input)
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['params'] = [
        dict(name=k, type=tick_input['keys'][k]['type'], schema='source_tick_buildings_state_input.' + k)
        for k in tick_input['keys']
    ]
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed ContinuousLiquidTurret live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live liquid module every simulate_factory tick, so the N2101 cost multiplier is paid live, and the tick runs the bound RuntimeConsumer actors through updateConsumption so the placed turret consumes its ammo liquid each tick.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2106'] = sorted(all_names)
    # One slice row: the live-loop tick driver is the primary owner; the
    # bind and consumed-liquid helpers share the slice (their symbols
    # carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2106', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret.ContinuousLiquidTurretBuild', java_method='ContinuousLiquidTurretBuild.updateTile(); ConsumeLiquidFilter.update(); ConsumeLiquidFilter.getConsumed()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
