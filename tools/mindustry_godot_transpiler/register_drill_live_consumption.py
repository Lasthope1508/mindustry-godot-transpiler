"""Register concrete liquid consumers, unique building traversal and automatic Drill ticks."""
import json
from pathlib import Path
from mindustry_port import source_symbols, source_ssot
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BUILDING = 'core/src/mindustry/entities/comp/BuildingComp.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
LOGIC = 'core/src/mindustry/core/Logic.java'
PROOF = '/root/Main.DrillLiveConsumptionProof'
TESTS = ['test_same_batch_contracts_cover_adapter_unique_traversal_and_live_ticks', 'test_factory_uses_live_tick_owner_and_timescale_uses_unique_buildings', 'test_real_process_drives_two_multicell_drills_and_concrete_adapter']
TICK = 'SourceDrillConsumptionRuntimeState.source_tick_state'

def key(typ, source, expr, rule='Compose existing canonical owners; retain source object/frame identity.', **extra):
    return backed(typ, source, expr, rule, **extra)

def main():
    game = key('Object', LOGIC, 'Groups.build.update();', 'Current loaded gameplay owner; traversal resolves actual instances through the canonical occupied-cell placement map.')
    seconds = key('float', BUILDING, 'timeScaleDuration -= Time.delta', 'Godot seconds are converted once through the canonical source tick rate.')
    entries = [
        ('N2007', 'SourceConsumeState.source_cost_multiplier_state', 'source_cost_multiplier', CONSUME, {'_build': key('Variant', CONSUME, 'public Floatf<Building> multiplier = b -> 1f;')}, {'multiplier': key('float', CONSUME, 'public Floatf<Building> multiplier = b -> 1f;', 'Cost multiplier callback result; distinct from efficiencyMultiplier(Building).')}),
        ('N2007', 'SourceConsumeLiquidState.source_runtime_consumer_state', 'source_runtime_consumer', LIQUID, {
            'definition': key('Dictionary', LIQUID, 'public final Liquid liquid;', 'Shared typed Block descriptor reference; amount and flags are not copied per building.', schema='source_liquid_consumer_state'),
            'liquids': key('Dictionary', BUILDING, 'if(block.hasLiquids) liquids = new LiquidModule();', 'Existing Building LiquidModule frame by reference.'),
            'cache_sums': key('Array', MODULE, 'private static float[] cacheSums;', 'Explicit canonical shared flow cache supplied by caller; live null-flow branch has no cache activity.'),
            'cost_multiplier': key('Callable', CONSUME, 'public Floatf<Building> multiplier = b -> 1f;', 'Callable receives building frame and returns registered cost-multiplier result, not efficiencyMultiplier.'),
        }, {'consumer': key('Object', LIQUID, 'public void update(Building build){', 'Concrete adapter implements efficiency(build) and update(build); delegates all arithmetic, storage mutation and clamping to canonical owners.')}),
        ('N2008', 'SourcePlacedBlockState.source_unique_buildings_state', 'source_unique_buildings', LOGIC, {'game': game}, {'buildings': key('Array', LOGIC, 'Groups.build.update();', 'One live Sprite2D per placed Building identity. Transient deduplication over existing placement map, no second persistent registry.')}),
        ('N2009', TICK, 'source_drill_live_tick', DRILL, {'game': game, 'seconds': seconds}, {'drill_states': key('Dictionary', DRILL, 'public void updateTile(){', 'Transient events keyed by origin cell for supported power-free base Drill in a single-ore footprint. Existing production/consumption owners compute state.')}),
        ('N2009', 'SourceDrillConsumptionRuntimeState.source_factory_state', 'source_drill_live_factory', DRILL, {'game': game, 'seconds': seconds}, {
            'drill_state': key('Dictionary', DRILL, 'public void updateTile(){', 'Primary event from world tick, injected into existing factory composition without a second production tick.'),
            'dump_state': key('Dictionary', DRILL, 'dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);'),
            'transport_state': key('Dictionary', BUILDING, 'updateTile();', 'Existing factory transport composition retained.'),
            'transport_progress': key('float', BUILDING, 'updateTile();', 'Existing factory transport projection, not a new conveyor formula.'),
            'source_owner': key('String', DRILL, 'public void updateTile(){', 'Retains existing factory simulation owner metadata.'),
        }),
    ]
    symbols = {}; by_slice = {}
    for slice_id, owner, prefix, source, inputs, outputs in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                symbol = prefix.removeprefix('source_') + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=name + '.' + field, java_source=meta['java_source'], java_method='update(Building build); efficiency(Building build); updateTile()', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, keys=keys, runtime_proof=PROOF))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=source, source_method='update(Building build); efficiency(Building build); updateTile()', params=[dict(name=k,type=v['type'],schema=prefix+'_input.'+k) for k,v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed concrete adapter and live base-Drill gameplay integration. Power consumers, mixed ore, flow binding, reload and secondary output routing are explicitly outside this checkpoint.'))
        by_slice.setdefault(slice_id, []).extend(names)
    binding = {
        'source_delta': key('float', BUILDING, 'return Time.delta * timeScale;', 'Source ticks supplied before calling concrete consumer efficiency/update; canonical Time.delta conversion retained.'),
        'time_scale': key('float', BUILDING, 'return Time.delta * timeScale;', 'Actual Building timeScale supplied before both passes; not a copied Block resource amount.'),
    }
    adapter_owner = 'SourceConsumeLiquidState.source_runtime_consumer_state'
    source_symbols.upsert_source_state_schema(GODOT, 'source_runtime_consumer_binding', dict(status='active', owner=adapter_owner, keys=binding, runtime_proof=PROOF))
    for field, meta in binding.items():
        symbol = 'runtime_consumer_binding.' + field
        by_slice['N2007'].append(symbol)
        symbols[symbol] = dict(status='source-backed', godot_owner=adapter_owner, godot_symbol='source_runtime_consumer_binding.'+field, java_source=BUILDING, java_method='delta()', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
    frame = {
        'enabled': ('bool', BUILDING, 'transient boolean enabled = true;'),
        'cheating': ('bool', 'core/src/mindustry/game/Rules.java', 'public boolean cheat;'),
        'items': ('Dictionary', DRILL, 'items.total() < itemCapacity'),
        'item_progress': ('float', DRILL, 'public float progress;'),
        'warmup': ('float', DRILL, 'public float warmup;'),
        'time_drilled': ('float', DRILL, 'public float timeDrilled;'),
        'last_drill_speed': ('float', DRILL, 'public float lastDrillSpeed;'),
        'dominant_item': ('Variant', DRILL, 'public Item dominantItem;'),
        'dominant_items': ('int', DRILL, 'public int dominantItems;'),
        'consumers': ('Array', BUILDING, 'cons.update(self());'),
        'efficiency': ('float', BUILDING, 'efficiency = minEfficiency;'),
        'optional_efficiency': ('float', BUILDING, 'optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);'),
        'potential_efficiency': ('float', BUILDING, 'potentialEfficiency = efficiency;'),
        'should_consume_power': ('bool', BUILDING, 'shouldConsumePower = true;'),
        'efficiency_scale': ('float', BUILDING, 'public float efficiencyScale(){'),
        'speed': ('float', DRILL, 'float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;'),
    }
    keys = {}
    for field, (typ, source, expr) in frame.items():
        keys[field] = key(typ, source, expr, 'Building-owned runtime projection; primary inventory/progress bridge existing demo owners, secondary isolated frame. Loaded campaign uses default non-cheating team rule; mutable TeamRules binding remains separate.')
        symbol = 'drill_live_frame.' + field
        by_slice['N2009'].append(symbol)
        symbols[symbol] = dict(status='source-backed', godot_owner=TICK, godot_symbol='source_drill_live_frame.'+field, java_source=source, java_method='updateConsumption(); updateTile()', java_expr=expr, rule=keys[field]['rule'], tests=TESTS, runtime_proof=PROOF)
    source_symbols.upsert_source_state_schema(GODOT, 'source_drill_live_frame', dict(status='active', owner=TICK, keys=keys, runtime_proof=PROOF))
    extra = [
        ('drill_live.metadata_key', TICK, 'SourceDrillConsumptionRuntimeState.SOURCE_DRILL_BUILDING_META_KEY', DRILL, 'public class DrillBuild extends Building{', 'N2009'),
        ('drill_live.liquid_boost_intensity', TICK, 'SourceFactoryDefaults.DRILL_LIQUID_BOOST_INTENSITY', DRILL, 'public float liquidBoostIntensity = 1.6f;', 'N2009'),
        ('drill_live.unboosted_speed', TICK, 'SourceFactoryDefaults.DRILL_UNBOOSTED_SPEED', DRILL, 'float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;', 'N2009'),
    ]
    for name, owner, godot_symbol, source, expr, slice_id in extra:
        symbols[name] = dict(status='source-backed', godot_owner=owner, godot_symbol=godot_symbol, java_source=source, java_method='updateTile()', java_expr=expr, rule='One source-backed owner for runtime identity/default; no block-name or liquid-rate allowlist.', tests=TESTS, runtime_proof=PROOF)
        by_slice[slice_id].append(name)
    for slice_id, owner, source, cls, expressions in [
        ('N2007','SourceConsumeLiquidState.source_runtime_consumer_state',LIQUID,'mindustry.world.consumers.ConsumeLiquid',['build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));','float ed = build.edelta() * build.efficiencyScale();']),
        ('N2008','SourcePlacedBlockState.source_unique_buildings_state',LOGIC,'mindustry.core.Logic',['Groups.build.update();']),
        ('N2009',TICK,DRILL,'mindustry.world.blocks.production.Drill',['return items.total() < itemCapacity && enabled && dominantItem != null;','float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;','progress += delta() * dominantItems * speed * warmup;']),
    ]:
        extra_fields={'generated_owner': ''} if slice_id=='N2007' else {}
        source_symbols.upsert_source_slice(GODOT,slice_id,dict(status='done',java_source=source,java_class=cls,java_method='update(); updateConsumption(); updateTile()',godot_owner=owner,exact_exprs=expressions,source_symbols=by_slice[slice_id],tests=TESTS,runtime_proof=PROOF,**extra_fields,deferred_exprs=['Power consumers, mixed ore selection, active flow caches, live reload and mutable TeamRules binding remain unresolved.','Primary routing retains existing factory path; secondary output remains local inventory fallback, complete secondary transport/dump routing is deferred.']))
    source_symbols.upsert_source_symbols(GODOT,symbols)
    for canonical in ['slice_ledger','api_contracts','state_schema','registry']:
        for name, module in json.loads((GODOT/'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))['modules'].items():
            if module.get('canonical_module')==canonical:
                source_ssot.write_registered_json(GODOT,name,source_ssot.build_extension_shard(GODOT,name))

if __name__=='__main__': main()
