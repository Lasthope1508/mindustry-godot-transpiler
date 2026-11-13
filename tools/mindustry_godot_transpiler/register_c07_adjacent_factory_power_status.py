"""Register the adjacent-factory power.status live read (N2146).

The second of the remaining power.status consumer families named in
the N2142/N2144/N2145 handoffs. N2142's live loop stamps
frame["power_status"] each tick before the adjacent tick runs, and
the write-back is generic: SourcePlacedPowerGraphState
SOURCE_CONSUMER_FRAME_META_KEYS includes
"source_adjacent_factory_building", so adjacent-family frames
already receive the live status. But the adjacent-family tick
driver never reads it: it builds its first-pass rows from the
bound actors with is_power false and the comment said "the power
consumer stays the power graph's domain (N2080/N2107) and is not
bound here", so a separator with no power still ran at full
efficiency and its progress would climb by
getProgressIncrease(craftTime) (Separator.java:142) as if
power.status were 1.0. N2146 is the adjacent family's live read.

Composition, not re-implementation: the shared efficiency machinery
(SourceBuildingEfficiencyState.update_consumption_state, via
update_consumption_non_optional_pass_state) already folds
{"result": ..., "is_power": true} rows into the min efficiency --
the power consumer's ConsumePower.efficiency is build.power.status
(ConsumePower.java:39). N2146 does not touch it. N2146 supplies the
missing pure power row over the stamped frame value + the tick-driver
append. No has_consumers fix is needed, unlike N2145: the adjacent
driver already passes _has_consumers_state(block), which counts the
power consumer (Block.java:1449).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SEPARATOR = 'core/src/mindustry/world/blocks/production/Separator.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
POWER_MODULE = 'core/src/mindustry/world/modules/PowerModule.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
PROOF = '/root/C07AdjacentFactoryPowerStatusProof'
OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state'
TESTS = ['test_c07_adjacent_factory_power_status_registration', 'test_all_c07_adjacent_factory_power_status_input_evidence_is_exact', 'test_adjacent_factory_power_status_row_state', 'test_reference_graph_and_actual_c07_adjacent_factory_power_status']
DEFERRED = [
    'power.status live read for the drill and turret consumer families -- the write-back stamps every consumer\'s frame generically, and the adjacent driver now reads frame["power_status"]; the drill driver skips power-consumer blocks, and turret has four implementations -- each its own slice.',
    'Adjacent-family progress advance (progress += getProgressIncrease(craftTime), Separator.java:142, gated on efficiency > 0) -- the adjacent driver advances no progress at all yet; the N2146 proof carries no progress keys; needs its own slice.',
    'spawn_occupied / spawn_visual_occupied frame inputs -- checkSolid(spawn, false/true) (UnitAssembler.java:675-680) needs tile solidity + a nearby-units query; the port\'s check_solid_state() is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.',
    'allow_update frame input -- the canonical allow_update_state exists (SourceBuildingAccessState, BuildingComp.java:622-627) but the driver cannot supply its inputs: rules_state carries only unitCostMultiplier + teams (no env, limitMapArea, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.',
    'Per-unit AssemblerAI.inPosition() evaluation from live unit pos/rotation/targetPos/targetAngle -- the count reads the recorded in_position flag; the units list carries no pos/rotation yet.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'return build.power.status;',
    'for(var cons : block.nonOptionalConsumers){',
    'minEfficiency = Math.min(minEfficiency, result);',
    'if(!block.hasConsumers || cheating()){',
    'progress += getProgressIncrease(craftTime);',
    'public float status = 0.0f;',
    'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;',
    'hasConsumers = consumers.length > 0;',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SEPARATOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2146_inputs = {
        'frame': f('Dictionary', 'return build.power.status;', 'The building frame carrying the graph-stamped power_status (ConsumePower.java:39, the canonical power.status read): the live value the row folds; null before the first graph update, folding to 1.0.', source=CONSUME_POWER),
        'has_power_consumer': f('bool', 'hasConsumers = consumers.length > 0;', 'Whether the block has a power consumer (Block.java:1449): the driver gate -- the row joins the first pass only when the block consumes power, and the power consumer counts toward hasConsumers.', source=BLOCK),
    }
    n2146_outputs = {
        'row': f('Dictionary', 'return build.power.status;', 'The power row for the first pass (ConsumePower.java:39, the canonical power.status read): {"result": live power.status, "is_power": true}, folded by the non-optional pass into the min efficiency.', source=CONSUME_POWER),
        'has_power_row': f('bool', 'for(var cons : block.nonOptionalConsumers){', 'Whether the row joins the first pass (BuildingComp.java:1969): true when the block has a power consumer; the row is the power consumer\'s entry in the non-optional pass.', source=BUILDING_COMP),
    }

    entries = [
        ('N2146', OWNER, 'source_adjacent_factory_power_status_row_state', SEPARATOR, 'mindustry.world.blocks.production.Separator.SeparatorBuild', 'SeparatorBuild.updateTile()', n2146_inputs, n2146_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed adjacent-factory power.status row from ConsumePower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed adjacent-factory power.status row from ConsumePower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the row, then its presence flag.
    by_slice['N2146'] = [
        'source_adjacent_factory_power_status_row_state_result.row',
        'source_adjacent_factory_power_status_row_state_result.has_power_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2146', dict(status='done', java_source=SEPARATOR, java_class='mindustry.world.blocks.production.Separator.SeparatorBuild', java_method='SeparatorBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2146'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
