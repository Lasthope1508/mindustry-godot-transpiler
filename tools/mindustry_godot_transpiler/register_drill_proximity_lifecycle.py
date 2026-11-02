"""Register Drill dominant-item lifecycle and actual production binding.

Canonical ore selection/Tile mutation owners remain the only semantic owners.
"""
import json
from pathlib import Path
from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
TILE = 'core/src/mindustry/world/Tile.java'
CONTENT = 'core/src/mindustry/core/ContentLoader.java'
PROOF = '/root/DrillProximityLifecycleProof'
TESTS = ['test_proximity_lifecycle_contracts', 'test_actual_proximity_mutation_and_dominant_production']
DEFERRED = ['Superclass BuildingComp.noSleep group membership/sleep lifecycle; this checkpoint implements the Drill assignment part only.', 'Complete Tile floor notifications, overlapping placement/removal/neighbors/events/recache and campaign world transition invalidation.', 'Actual pickup controller dispatch and detached Building removal; pickup helper only preserves source field-reset semantics.', 'Nullable dump-any, transport routing, secondary offload/dump and inventory ownership remain C02.', 'BeamDrill override, BurstDrill updateTile, power consumers, definition reload and mutable rules require their own lifecycle gates.']


def main():
    symbols = {}; by_slice = {}
    def f(typ, source, expr, rule, **extra):
        return backed(typ, source, expr, rule, **extra)
    def schema(name, owner, sid, fields):
        for key, meta in fields.items():
            meta['used_by'] = [owner]
            symbol = name + '.' + key
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method='getDrop; onProximityUpdate; pickedUp; updateTile; setOverlay', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            by_slice.setdefault(sid, []).append(symbol)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=fields, runtime_proof=PROOF))
    def register(owner, sid, name, source, method, inputs, outputs=None):
        schema(name+'_input', owner, sid, inputs)
        if outputs is None:
            return
        schema(name+'_result', owner, sid, outputs)
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k,type=v['type'],schema=name+'_input.'+k) for k,v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='One world-scoped typed Item view; reuse canonical countOre/drop/Tile mutation and existing per-Building frame. No per-tick ore re-selection. Only stated partial lifecycle/production scope; deferred behaviors are recorded in ledger.'))
    def frame(): return f('Dictionary',DRILL,'public class DrillBuild extends Building{','Existing live frame, same mutable identity; no parallel dominant state.',schema='source_drill_live_frame')
    def item(): return f('Variant',DRILL,'public Item dominantItem;','Nullable typed Item fact; retain shared reference, numeric id/hardness/lowPriority from canonical content provider.',schema='source_drill_ore_item')
    def game(): return f('Object',TILE,'build.onProximityUpdate();','Actual game world containing canonical Tile store, placement index and readonly typed Item view.')
    def sprite(): return f('Sprite2D',DRILL,'public class DrillBuild extends Building{','Actual placed Building identity and existing frame metadata; nullable only for output name lookup.')
    selection = {'dominant_item': item(), 'dominant_items': f('int',DRILL,'dominantItems = returnCount;','Count from existing canonical countOre owner; zero on empty.')}
    register('SourceDrillRuntimeState.source_get_drop_state','N2020','source_drill_get_drop',DRILL,'getDrop(Tile tile)',{'tile':f('Dictionary',TILE,'return overlay == Blocks.air || overlay.itemDrop == null ? floor.itemDrop : overlay.itemDrop;','Tile facts already computed by canonical Tile drop provider.',schema='source_drill_ore_tile')},{'drop':f('Variant',DRILL,'return tile.drop();','Return canonical Tile drop by reference, including null.',schema='source_drill_ore_item')})
    register('SourceDrillRuntimeState.source_on_proximity_update_state','N2020','source_drill_proximity_assignment',DRILL,'DrillBuild.onProximityUpdate()',{
        'linked_tiles':f('Array',DRILL,'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){','Source linked order/bounds from existing Tile provider.',schema='source_drill_ore_tile'),
        'tier':f('int',DRILL,'drops.hardness <= tier','Actual resolved Block tier; no guessed default.'),
        'blocked_items':f('Variant',DRILL,'(blockedItems == null || !blockedItems.contains(drops))','Canonical nullable numeric Item identities from existing Drill.init/bind owner.'),
    },selection)
    register('SourceDrillRuntimeState.source_picked_up_state','N2020','source_drill_pickup_assignment',DRILL,'DrillBuild.pickedUp()',{'frame':frame()},{'dominant_item':f('Variant',DRILL,'dominantItem = null;','Only reset item; preserve count/progress and all other supplied fields. Extra frame keys pass through unchanged.')})
    register('SourceDrillConsumptionRuntimeState.source_on_proximity_update_state','N2021','source_drill_live_proximity',DRILL,'DrillBuild.onProximityUpdate()',{'game':game(),'sprite':sprite(),'block':f('Object',DRILL,'countOre(tile);','Actual typed Drill ancestry definition, identified by source-exported blockedItems metadata; separate overrides remain unsupported.',schema='source_terrain_block_definition')},{'applied':f('bool',DRILL,'dominantItem = returnItem;','Whether supported Drill assignment was applied to its existing frame; no claim of superclass sleep/other override execution.')})
    register('SourceDrillConsumptionRuntimeState.source_picked_up_state','N2021','source_drill_live_pickup',DRILL,'DrillBuild.pickedUp()',{'sprite':sprite()})
    register('SourceWorldTerrainRuntimeState.source_set_world_overlay_state','N2021','source_world_drill_overlay',TILE,'setOverlay(Block block)',{
        'game':game(), 'x':f('int',TILE,'public short x, y;','Actual Tile x coordinate.'), 'y':f('int',TILE,'public short x, y;','Actual Tile y coordinate.'),
        'block':f('Object',TILE,'this.overlay = (Floor)block;','Resolved typed overlay Block; no guessed content or rendering-based lookup.',schema='source_terrain_block_definition'),
        'generating':f('bool',TILE,'if(!world.isGenerating() && build != null){','Explicit source world generation phase; defer notification during generation.'),
    },{'changed':f('bool',TILE,'if(this.overlay == block) return;','Canonical Tile overlay owner controls identity guard and assignment.'),'proximity_updated':f('bool',TILE,'build.onProximityUpdate();','Canonical guard selects notification; true only when supported live Drill assignment actually ran. Recache/events/other Building overrides remain deferred.')})
    register('SourceDrillConsumptionRuntimeState.source_dominant_item_name_state','N2022','source_drill_dominant_item_name',DRILL,'DrillBuild.updateTile()',{'game':game(),'sprite':sprite()},{'item_id':f('Variant',DRILL,'offload(dominantItem);','Nullable exact registered content name resolved through shared numeric Item id; never global output slug or dictionary stringification. Actual primary offload and secondary local storage use this projection; C02 routing still open.')})
    # World-scoped cache is a readonly typed view of content, not another selection registry.
    symbols['drill_proximity.world_item_catalog'] = dict(status='source-backed',godot_owner='SourceDrillConsumptionRuntimeState.source_on_proximity_update_state',godot_symbol='PortGame.source_item_catalog',java_source=CONTENT,java_method='items()',java_expr='return getBy(ContentType.item);',rule='One shared typed Item view per build_world from canonical content order. Rebuilt before placements; never reconstructed per tick. World reload acceptance remains separate.',tests=TESTS,runtime_proof=PROOF)
    by_slice['N2021'].append('drill_proximity.world_item_catalog')
    source_symbols.upsert_source_symbols(GODOT,symbols)
    for sid,owner,method,exprs in [
        ('N2020','SourceDrillRuntimeState.source_on_proximity_update_state','getDrop(Tile); DrillBuild.onProximityUpdate(); pickedUp()',['return tile.drop();','countOre(tile);','dominantItem = returnItem;','dominantItems = returnCount;','dominantItem = null;']),
        ('N2021','SourceDrillConsumptionRuntimeState.source_on_proximity_update_state','DrillBuild.onProximityUpdate()',['countOre(tile);','dominantItem = returnItem;','dominantItems = returnCount;']),
        ('N2022','SourceDrillConsumptionRuntimeState.source_dominant_item_name_state','DrillBuild.updateTile()',['if(dominantItem == null){','float delay = getDrillTime(dominantItem);','offload(dominantItem);']),
    ]:
        source_symbols.upsert_source_slice(GODOT,sid,dict(status='done',java_source=DRILL,java_class='mindustry.world.blocks.production.Drill',java_method=method,godot_owner=owner,exact_exprs=exprs,source_symbols=by_slice[sid],tests=TESTS,runtime_proof=PROOF,deferred_exprs=DEFERRED))
    source_symbols.write_source_symbol_audit_report(GODOT)
    modules=json.loads((GODOT/'src/generated/source_ssot_modules.json').read_text())['modules']
    for canonical in ['slice_ledger','api_contracts','state_schema','registry','audit_report']:
        for name,module in modules.items():
            if module.get('canonical_module')==canonical:
                source_ssot.write_registered_json(GODOT,name,source_ssot.build_extension_shard(GODOT,name))

if __name__=='__main__': main()
