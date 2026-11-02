"""Register canonical floor assignment and live terrain mutation composition."""
import json
from pathlib import Path
from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
OWNER = 'SourceWorldTerrainRuntimeState.'
PROOF = '/root/TerrainMutationLifecycleProof'
TESTS = ['test_terrain_lifecycle_contracts', 'test_live_terrain_notifications_and_ordered_mutations', 'test_new_terrain_evidence_and_nested_schemas']
DEFERRED = ['Tile recache, renderer floor index, floor/overlay change event bus and pathfinder callbacks remain separate live integrations.', 'Floor.floorChanged overrides such as TiledFloor/ColoredFloor and Tile data bytes are not implemented by this assignment/Drill-notification adapter.', 'Superclass BuildingComp.noSleep/group lifecycle, non-Drill proximity overrides, removal/overlap and controller pickup/world transition remain open in C01.', 'Remote receiver composition is executed locally; no RPC transport, authority, save/load or multiplayer acceptance is implied.', 'C02 per-Building inventory, offload/dump/transport, secondary local fallback and nullable dump-any remain open.']


def main():
    symbols = {}; by_slice = {}
    def f(typ, expr, rule, **extra): return backed(typ,TILE,expr,rule,**extra)
    def schema(name, owner, sid, fields):
        for key, meta in fields.items():
            meta['used_by']=[owner];symbol=name+'.'+key
            symbols[symbol]=dict(status='source-backed',godot_owner=owner,godot_symbol=symbol,java_source=meta['java_source'],java_method='setFloor; setOverlayQuiet; clearOverlay; setFloorNet',java_expr=meta['java_expr'],rule=meta['rule'],tests=TESTS,runtime_proof=PROOF)
            by_slice.setdefault(sid,[]).append(symbol)
        source_symbols.upsert_source_state_schema(GODOT,name,dict(status='active',owner=owner,source_slice=sid,keys=fields,runtime_proof=PROOF))
    def register(method,sid,prefix,source_method,inputs,outputs=None,owner=None):
        owner=owner or OWNER+method;schema(prefix+'_input',owner,sid,inputs)
        if outputs is None:return
        schema(prefix+'_result',owner,sid,outputs)
        source_symbols.upsert_source_api_contract(GODOT,owner,dict(status='active',source_slice=sid,java_source=TILE,source_method=source_method,params=[dict(name=k,type=v['type'],schema=prefix+'_input.'+k) for k,v in inputs.items()],return_keys=list(outputs),tests=TESTS,runtime_proof=PROOF,rule='Reuse canonical Tile geometry assignment/notification guards and receiver recipe on the actual Tile store. Only supported Drill proximity callback runs; renderer/events/pathfinder/Floor override/RPC effects remain deferred, not populated with invented defaults.'))
    def game():return f('Object','build.onProximityUpdate();','Actual game with canonical dense Tile storage, placement index, world-scoped Item view and existing Building frames.')
    def coord():return f('int','public short x, y;','Actual in-bounds Tile coordinate; unresolved Tile is rejected, not fabricated.')
    def floor():return f('Object','this.floor = type;','Actual resolved typed Floor definition; Item drops come from existing canonical metadata. Floor override/data callbacks remain separate.',schema='source_terrain_block_definition')
    def overlay():return f('Object','this.overlay = (Floor)block;','Actual resolved typed overlay Floor definition by reference.',schema='source_terrain_block_definition')
    def phase():return f('bool','if(!world.isGenerating() && build != null){','Explicit source generation phase. setFloor notification deliberately ignores this overlay-only guard.')
    def base():return {'game':game(),'x':coord(),'y':coord()}
    def floor_result():return {'changed':f('bool','if(this.floor == type) return;','True after the canonical identity guard allows floor assignment.'),'proximity_updated':f('bool','build.onProximityUpdate();','True only when the supported actual Drill frame was recomputed. Floor notification is independent of generating.')}
    def overlay_result():return {'changed':f('bool','if(this.overlay == block) return;','Delegate normal setOverlay; retain its identity guard.'),'proximity_updated':f('bool','if(!world.isGenerating() && build != null){','Actual supported Drill notification only; generating and identity no-op are inherited from canonical overlay owner.')}
    def paired_result():return {'floor_state':f('Dictionary','tile.setFloor(floor.asFloor());','Result of first canonical receiver call.',schema='source_world_drill_floor_result'),'overlay_state':f('Dictionary','tile.setOverlay(overlay);','Result of second call, after first notification has observed the prior overlay.',schema='source_world_drill_overlay_result')}
    register('tile_floor_assignment_state','N2023','source_tile_floor_assignment','setFloor(Floor type)',{
        'type_value':f('Variant','this.floor = type;','Actual supplied Floor reference.'),
        'previous_floor':f('Variant','var prev = this.floor;','Previous Floor reference; preserve identity.'),
        'build_present':f('bool','if(build != null){','Actual Building presence, not an inferred content flag.'),
    },{'same_floor':f('bool','if(this.floor == type) return;','Canonical identity guard shared by state description and actual mutation.'),'floor':f('Variant','this.floor = type;','Prior reference on no-op; supplied reference on assignment.'),'build_proximity_updated':f('bool','if(build != null){','Changed floor notifies Building regardless of generation; one formula shared with existing full Tile.setFloor state owner.')},owner='SourceBlockGeometry.tile_floor_assignment_state')
    register('source_set_world_floor_state','N2023','source_world_drill_floor','setFloor(Floor type)',{**base(),'floor_block':floor()},floor_result())
    register('source_set_world_overlay_quiet_state','N2024','source_world_quiet_overlay','setOverlayQuiet(Block block)',{**base(),'block':overlay()})
    register('source_clear_world_overlay_state','N2024','source_world_clear_overlay','clearOverlay()',{**base(),'generating':phase()},overlay_result())
    register('source_set_world_floor_overlay_state','N2025','source_world_floor_overlay_receiver','setFloor(Tile tile, Block floor, Block overlay)',{**base(),'floor_block':floor(),'overlay_block':overlay(),'generating':phase()},paired_result())
    register('source_set_world_floor_default_state','N2025','source_world_floor_default_receiver','setFloorNet(Block floor)',{**base(),'floor_block':floor(),'generating':phase()},paired_result())
    source_symbols.upsert_source_symbols(GODOT,symbols)
    for sid,owner,method,exprs in [
        ('N2023',OWNER+'source_set_world_floor_state','setFloor(Floor type)',['if(this.floor == type) return;','this.floor = type;','if(build != null){','build.onProximityUpdate();']),
        ('N2024',OWNER+'source_clear_world_overlay_state','setOverlayQuiet(Block block); clearOverlay()',['this.overlay = (Floor)block;','setOverlay(Blocks.air);']),
        ('N2025',OWNER+'source_set_world_floor_overlay_state','setFloor(Tile tile, Block floor, Block overlay); setFloorNet(Block floor)',['tile.setFloor(floor.asFloor());','tile.setOverlay(overlay);','setFloorNet(floor, Blocks.air);']),
    ]:
        source_symbols.upsert_source_slice(GODOT,sid,dict(status='done',java_source=TILE,java_class='mindustry.world.Tile',java_method=method,godot_owner=owner,exact_exprs=exprs,source_symbols=by_slice[sid],tests=TESTS,runtime_proof=PROOF,deferred_exprs=DEFERRED))
    source_symbols.write_source_symbol_audit_report(GODOT)
    modules=json.loads((GODOT/'src/generated/source_ssot_modules.json').read_text())['modules']
    for canonical in ['slice_ledger','api_contracts','state_schema','registry','audit_report']:
        for name,module in modules.items():
            if module.get('canonical_module')==canonical:
                source_ssot.write_registered_json(GODOT,name,source_ssot.build_extension_shard(GODOT,name))

if __name__=='__main__':main()
