"""Register production placement binding for Tile.setBlock (N2032-N2034)."""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
TEAM = 'core/src/mindustry/game/Team.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILD = 'core/src/mindustry/world/Build.java'
CONSTRUCT = 'core/src/mindustry/world/blocks/ConstructBlock.java'
PROOF = '/root/PlacedTileSetBlockProof'
TESTS = ['test_placed_tile_set_block_binding_registration', 'test_all_placed_tile_set_block_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_placed_tile_set_block']
DEFERRED = [
    'Change events and renderer recache have no runtime bus or cache yet; the binding records only whether the setBlock guard reached them.',
    'Block.blockChanged overrides beyond the empty default (ColoredWall, TiledWall) stay open.',
    'Schematic placement (Schematics.place) has no runtime path yet; only player, scenario and campaign-bootstrap placement go through record_placed_block.',
    'Block.update and Block.hasBuilding are not exported by the content catalog; the binding reads update from the catalog when present and treats a supplied sprite as the Building.',
    'Superclass noSleep, power onProximity hooks, turret unregister, controller pickup, world transitions and remaining Tile/Floor side effects stay open in C01.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

SET_BLOCK_METHOD = 'public void setBlock(Block type, Team team, int rotation, Prov<Building> entityprov){'
CHANGE_BUILD_INIT = 'build = entityprov.get().init(this, team, block.update && !state.isEditor(), rotation);'
CONSTRUCT_FINISH_SET_BLOCK = 'tile.setBlock(block, team, rotation);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TILE, **extra):
        return backed(typ, source, expr, rule, **extra)

    # N2032: placed-Building team identity (build_team hook target).
    n2032_inputs = {
        'sprite': f('Sprite2D', 'build.team(team);', 'Actual placed Building sprite whose team is assigned.'),
        'team_id': f('int', 'Team.sharded.id', 'Actual campaign player team id; sharded is the placing team.', source=BLOCK),
    }
    n2032_outputs = {
        'team_id': f('int', 'build.team(team);', 'Team id stored on the Building sprite meta.'),
        'build': f('Sprite2D', 'build.team(team);', 'The same Building sprite, now carrying its team id.'),
    }
    # N2033: production setBlock binding from the game context.
    n2033_inputs = {
        'game': f('Object', CONSTRUCT_FINISH_SET_BLOCK, 'Actual game world containing the Tile store, placement index and content catalog.', source=CONSTRUCT),
        'block': f('Object', CONSTRUCT_FINISH_SET_BLOCK, 'Actual Block placed by ConstructBlock.constructFinish.', source=CONSTRUCT),
        'cell': f('Vector2i', 'Tile tile = world.tile(x, y);', 'Actual placement Tile cell resolved through the world lookup.', source=BUILD),
        'sprite': f('Sprite2D', CHANGE_BUILD_INIT, 'Actual created Building entity; the placed sprite is the runtime Building identity.'),
        'team_id': f('int', 'build.team(team);', 'Actual Team id assigned to the new Building after changeBuild.'),
        'rotation': f('int', 'changeBuild(team, entityprov, (byte)Mathf.mod(rotation, 4));', 'Actual requested rotation; normalized with posmod 4 by the composed primitive.'),
    }
    n2033_outputs = {
        'tile': f('Dictionary', SET_BLOCK_METHOD, 'Actual mutated Tile dictionary; changing, block and build are set on it in source order.'),
        'build': f('Variant', CHANGE_BUILD_INIT, 'The placed Building sprite, or null when no sprite was supplied.'),
        'removed_old_build': f('bool', 'build.remove();', 'Whether a previous Building was removed by the composed changeBuild.'),
        'proximity_updated': f('int', 't.updateProximity();', 'Number of unique Buildings whose proximity recompute applied through the binding.'),
        'changed_event_fired': f('bool', 'fireChanged();', 'Whether the changed event hook was reached; no runtime event bus consumes it yet.'),
        'recache_called': f('bool', 'recache();', 'Whether the static recache guard fired; no runtime renderer cache consumes it yet.'),
    }
    # N2034: wire the binding into record_placed_block.
    n2034_inputs = {
        'sprite': f('Sprite2D', CHANGE_BUILD_INIT, 'Actual placed Building sprite threaded through the placement funnel as the created entity.'),
        'block': f('Object', CONSTRUCT_FINISH_SET_BLOCK, 'Actual Block placed by ConstructBlock.constructFinish.', source=CONSTRUCT),
        'cell': f('Vector2i', 'Tile tile = world.tile(x, y);', 'Actual placement Tile cell resolved through the world lookup.', source=BUILD),
    }

    entries = [
        ('N2032', 'SourceBlockGeometry.source_assign_build_team_state', 'source_assign_build_team_state', TILE, 'mindustry.world.Tile', 'setBlock', n2032_inputs, n2032_outputs, ['build.team(team);', SET_BLOCK_METHOD]),
        ('N2033', 'SourceWorldTerrainRuntimeState.source_apply_placed_tile_set_block_state', 'source_apply_placed_tile_set_block_state', TILE, 'mindustry.world.Tile', 'setBlock', n2033_inputs, n2033_outputs, [SET_BLOCK_METHOD, 'build.team(team);', 'if(block.hasBuilding()){', 'build.remove();', 't.updateProximity();', 'tile.onProximityUpdate();', 'fireChanged();', 'recache();', 'block.blockChanged(this);', 'changing = false;']),
        ('N2034', 'SourcePlacedBlockPortBridge.record_placed_block', 'record_placed_block', CONSTRUCT, 'mindustry.world.blocks.ConstructBlock', 'constructFinish', n2034_inputs, None, [CONSTRUCT_FINISH_SET_BLOCK, 'if(tile.build != null && tile.build.block == block){']),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs in entries:
        names = []
        for suffix, keys in [('input', inputs)] + ([('result', outputs)] if outputs is not None else []):
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed placement binding inputs; hooks must be actual source context.'))
        if outputs is None:
            # N2034 registers ledger + symbols + schema only, no contract.
            # The wiring lives in PortBridge record_placed_block, whose
            # name the implementation-discovery rule cannot see (PortBridge
            # files only discover source_ / generated_ functions), so a
            # void contract here fails catalog validation with "facade /
            # module function not discovered". Symbol owners without a
            # contract are established practice (99 owners); the slice is
            # still proven by the runtime proof. Remove the contract if a
            # previous run registered one.
            contracts = source_symbols.load_source_api_contracts(GODOT)
            if owner in contracts.get("contracts", {}):
                del contracts["contracts"][owner]
                source_ssot.write_json(GODOT, "api_contracts", contracts)
        else:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed placement binding; the result dictionary reports what the composed setBlock did, with no fabricated runtime state.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    # File-level team constants (not function inputs).
    for name, godot_symbol, expr, slice_id in [
        ('team_identity.sharded_id', 'SourceBlockGeometry.SOURCE_TEAM_SHARDED_ID', 'sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),', 'N2032'),
        ('team_identity.derelict_id', 'SourceBlockGeometry.SOURCE_TEAM_DERELICT_ID', 'derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),', 'N2032'),
    ]:
        symbols[name] = dict(status='source-backed', godot_owner='SourceBlockGeometry.source_assign_build_team_state', godot_symbol=godot_symbol, java_source=TEAM, java_method='Team', java_expr=expr, rule='Team id constant from the Team field declaration; sharded is the campaign player team and derelict is the default for tiles without a Building.', tests=TESTS, runtime_proof=PROOF)
        by_slice[slice_id].append(name)
    # Re-record N2032 with the constant symbols included.
    ledger = json.loads((GODOT / 'src/generated/source_slice_ledger.json').read_text(encoding='utf-8'))
    entry = ledger['slices']['N2032']
    entry['source_symbols'] = by_slice['N2032']
    source_symbols.upsert_source_slice(GODOT, 'N2032', entry)

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
