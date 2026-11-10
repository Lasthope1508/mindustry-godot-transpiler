"""Register the GenericCrafter warmup / liquid-output / totalProgress slice (N2118).

N2117 wired the production half of GenericCrafterBuild.updateTile()
(GenericCrafter.java:235-266) -- progress climbs by
getProgressIncrease(craftTime) and a completed progress crafts -- but
three statements of updateTile stayed unwired: the warmup approach,
the continuous liquid output loop, and totalProgress. N2118 is the
second C06 slice and wires all three through the live loop, in Java
order (GenericCrafter.java:239, 241-246, 259-260, then the craft
check at 262-264):

- warmup approaches warmupTarget() at warmupSpeed while efficiency
  is above zero (GenericCrafter.java:239, Mathf.approachDelta) and
  decays toward 0 when efficiency is zero (GenericCrafter.java:253).
  warmupTarget() returns 1f (GenericCrafter.java:287-289); the
  HeatCrafter override (Mathf.clamp(heat / heatRequirement),
  HeatCrafter.java:70-72) is deferred -- the frame carries no heat
  state yet. warmupSpeed is the block's own, else the class default
  0.019f (GenericCrafter.java:45); the only initializer override in
  Blocks.java is the blast drill (a Drill, not a factory).
- the liquid loop runs getProgressIncrease(1f) -- the GenericCrafter
  override at base time 1f, so a full output liquid scales the
  increase to zero through the same headroom scaling N2117
  registered -- then handles each output liquid once per tick with
  Math.min(output.amount * inc, liquidCapacity - liquids.get(
  output.liquid)) (GenericCrafter.java:241-246). handleLiquid is
  liquids.add (BuildingComp.java:872-874), and LiquidModule.add
  (LiquidModule.java:110-115) is liquids[id] += amount with current
  set to the liquid. A block with no output liquids outputs nothing.
- totalProgress banks warmup * Time.delta every tick, outside the
  efficiency branch (GenericCrafter.java:259-260; Time.delta is in
  seconds), before the craft check, so a factory at efficiency zero
  still banks the warmup it has left as it cools.

Java: BuildingComp.delta() = Time.delta * timeScale and edelta() =
efficiency * delta() (BuildingComp.java:1922-1929); the port edelta
convention is seconds * TICK_RATE. The cryofluid mixer outputs
cryofluid 12f/60f per tick (Blocks.java:1170) into a 36.0 liquid
capacity; the electrolyzer outputs ozone 4f/60 and hydrogen 6f/60
(Blocks.java:1394). dumpOutputs() (GenericCrafter.java:317+) is the
next slice.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
PROOF = '/root/C06FactoryLiquidOutputProof'
TESTS = ['test_factory_liquid_output_registration', 'test_all_factory_liquid_output_input_evidence_is_exact', 'test_tick_outputs_liquid_when_efficient', 'test_reference_graph_and_actual_c06_factory_liquid_output_gate']
DEFERRED = [
    'dumpOutputs() (GenericCrafter.java:317+) is the next slice; the item dump timer and per-output-liquid dumpLiquid are still unwired.',
    'HeatCrafterBuild.warmupTarget() (HeatCrafter.java:70-72, Mathf.clamp(heat / heatRequirement)) is deferred: the frame carries no heat state yet, so a heat crafter takes the GenericCrafter default 1f until the heat slice lands.',
    'The updateEffect chance branch (GenericCrafter.java:247-249) is not wired: it is a visual effect only.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public float warmupTarget(){',
    'warmup = Mathf.approachDelta(warmup, warmupTarget(), warmupSpeed);',
    'warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);',
    'public float warmupSpeed = 0.019f;',
    'public float warmup;',
    'if(efficiency > 0){',
    'if(outputLiquids != null){',
    'float inc = getProgressIncrease(1f);',
    'for(var output : outputLiquids){',
    'handleLiquid(this, output.liquid, Math.min(output.amount * inc, liquidCapacity - liquids.get(output.liquid)));',
    'totalProgress += warmup * Time.delta;',
    'outputLiquid = new LiquidStack(Liquids.cryofluid, 12f / 60f);',
    'outputLiquids = LiquidStack.with(Liquids.ozone, 4f / 60, Liquids.hydrogen, 6f / 60);',
    'public void handleLiquid(Building source, Liquid liquid, float amount){',
    'liquids.add(liquid, amount);',
    'return Time.delta * timeScale;',
    'return efficiency * delta();',
    'public void add(Liquid liquid, float amount){',
    'liquids[liquid.id] += amount;',
    'current = liquid;',
    'public float getProgressIncrease(float baseTime){',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2118_warmup_target_inputs = {
        'block': f('Object', 'warmup = Mathf.approachDelta(warmup, warmupTarget(), warmupSpeed);', 'The typed block definition; its warmupTarget() is what the warmup approaches.'),
    }
    n2118_warmup_target_outputs = {
        'warmup_target': f('float', 'public float warmupTarget(){', 'The warmup target: 1f for a GenericCrafterBuild (the HeatCrafter override is deferred).'),
    }

    n2118_warmup_inputs = {
        'warmup': f('float', 'public float warmup;', 'The current warmup the approach moves from.'),
        'target': f('float', 'warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);', 'The approach target: warmupTarget() while efficient, 0f when efficiency is zero.'),
        'warmup_speed': f('float', 'public float warmupSpeed = 0.019f;', "The block's warmupSpeed, else the class default 0.019f."),
        'seconds': f('float', 'warmup = Mathf.approachDelta(warmup, warmupTarget(), warmupSpeed);', 'The frame delta in seconds; approachDelta steps by Time.delta * warmupSpeed.'),
    }
    n2118_warmup_outputs = {
        'warmup': f('float', 'warmup = Mathf.approachDelta(warmup, warmupTarget(), warmupSpeed);', 'The warmup after one approach step toward the target.'),
        'target': f('float', 'public float warmupTarget(){', 'The target the warmup approached this tick.'),
    }

    n2118_liquid_output_inputs = {
        'block': f('Object', 'if(outputLiquids != null){', 'The typed block definition; its outputLiquids rows are what the loop handles.'),
        'liquids': f('Dictionary', 'handleLiquid(this, output.liquid, Math.min(output.amount * inc, liquidCapacity - liquids.get(output.liquid)));', "The building's liquid module the produced liquid is handled into."),
        'liquid_ids': f('Dictionary', 'outputLiquid = new LiquidStack(Liquids.cryofluid, 12f / 60f);', 'The catalog name-to-id map for the output liquids: the liquid module is id-indexed, so output liquid names resolve to ids through it.', source=BLOCKS),
        'efficiency': f('float', 'if(efficiency > 0){', 'The live efficiency; the liquid loop only runs while it is above zero.'),
        'seconds': f('float', 'float inc = getProgressIncrease(1f);', 'The frame delta in seconds; inc is the GenericCrafter override at base time 1f.'),
        'time_scale': f('float', 'return Time.delta * timeScale;', 'The building time scale (BuildingComp.delta() = Time.delta * timeScale).', source=BUILDING_COMP),
    }
    n2118_liquid_output_outputs = {
        'inc': f('float', 'float inc = getProgressIncrease(1f);', 'The per-tick output increase: getProgressIncrease(1f), scaled to zero by a full output liquid.'),
        'added': f('Dictionary', 'handleLiquid(this, output.liquid, Math.min(output.amount * inc, liquidCapacity - liquids.get(output.liquid)));', 'What each output liquid gained this tick: min(amount * inc, liquidCapacity - held).'),
        'liquids_after': f('Dictionary', 'liquids.add(liquid, amount);', "The liquid module after the adds: liquids[id] += amount with current set to the liquid.", source=BUILDING_COMP),
    }

    n2118_total_progress_inputs = {
        'total_progress': f('float', 'totalProgress += warmup * Time.delta;', 'The banked total progress the warmup adds to.'),
        'warmup': f('float', 'totalProgress += warmup * Time.delta;', 'The current warmup; totalProgress banks warmup * Time.delta every tick.'),
        'seconds': f('float', 'totalProgress += warmup * Time.delta;', 'The frame delta in seconds; Time.delta is in seconds, not ticks.'),
    }
    n2118_total_progress_outputs = {
        'total_progress': f('float', 'totalProgress += warmup * Time.delta;', 'The banked total progress after this tick.'),
    }

    entries = [
        ('N2118', 'SourceFactoryBuildState.source_factory_warmup_target_state', 'source_factory_warmup_target_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.warmupTarget()', n2118_warmup_target_inputs, n2118_warmup_target_outputs, True, 'Dictionary'),
        ('N2118', 'SourceFactoryBuildState.source_factory_warmup_state', 'source_factory_warmup_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.updateTile()', n2118_warmup_inputs, n2118_warmup_outputs, True, 'Dictionary'),
        ('N2118', 'SourceFactoryBuildState.source_factory_liquid_output_state', 'source_factory_liquid_output_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.updateTile()', n2118_liquid_output_inputs, n2118_liquid_output_outputs, True, 'Dictionary'),
        ('N2118', 'SourceFactoryBuildState.source_factory_total_progress_state', 'source_factory_total_progress_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.updateTile()', n2118_total_progress_inputs, n2118_total_progress_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GenericCrafter warmup / liquid-output / totalProgress live-loop slice.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GenericCrafter warmup / liquid-output / totalProgress live-loop slice.'))
        all_names.extend(names)

    # The live-loop tick driver (N2110) gains the warmup / liquid
    # output / totalProgress half (N2113 pattern: deepcopy the
    # existing contract and extend its rule and tests, keeping the
    # N2110 source_slice the driver itself was registered under; the
    # game+seconds params are unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows, with shouldConsume() read live from the output space every tick so a factory with a full output ticks at efficiency 0, and with efficiency above zero the progress climbs by getProgressIncrease(craftTime) and a completed progress crafts (consume + offload), and the tick also approaches warmup toward warmupTarget() at warmupSpeed, handles each output liquid once per tick at getProgressIncrease(1f) capped at the remaining liquid capacity, and banks warmup * Time.delta into totalProgress every tick before the craft check.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2118'] = sorted(all_names)
    # One slice row: the tick driver is the primary owner (the
    # warmup / liquid-output / totalProgress half is wired into it);
    # the four new functions are registered under it.
    source_symbols.upsert_source_slice(GODOT, 'N2118', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.updateTile(); GenericCrafterBuild.warmupTarget(); BuildingComp.handleLiquid(Building, Liquid, float); LiquidModule.add(Liquid, float)', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    # No emitter change this slice, so the canonical
    # content_registry.json is untouched; its blocks shard mirror is
    # rebuilt with it anyway (the N2114 lesson: a stale mirror fails
    # the gate).
    source_ssot.write_registered_json(GODOT, 'content_registry_blocks', source_ssot.build_extension_shard(GODOT, 'content_registry_blocks'))


if __name__ == '__main__':
    main()
