"""Register the power.status live read -- PowerGraph.distributePower
consumer write-back (N2142).

The next deferred follow-up from N2139/N2141 and the next C07 item
per the completion backlog (unit lifecycle/teams). N2139's assembler
driver folds `frame.get("power_status", null)` -- null to 1.0,
`!enabled` to 0.0 -- with the comment "the frame records no
power_status yet, so null folds to 1.0 and !enabled folds to 0.0
until a power-status slice lands." N2142 is that slice: the graph
update already runs every tick before the factory tick
(SourceFactoryRuntimeState.gd:163 vs :192) and already computes every
consumer's `power.status` through the pure `distributePower` -- but
the live loop only writes battery statuses back to sprite meta and
drops every consumer's computed status. The unit-factory driver
therefore never sees a live value, so an assembler with no power
still runs at full `powerStatus`.

Composition, not re-implementation: `distributePower` already has a
pure function (`SourcePowerGraphBatteryDistributionState.
distribute_power_state`, via `SourcePowerGraphState.
distribute_power_state`, port bridge + `PowerGraphBatteryDistributionModuleProof`
driving it) -- N2142 does not touch it. N2142 supplies the missing
read/write pair on the placed building's frame (the battery pattern,
N2082/N2083) plus the live-loop write-back of the already-computed
statuses.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWERGRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
POWERMODULE = 'core/src/mindustry/world/modules/PowerModule.java'
UNITASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUMEPOWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
PROOF = '/root/C07PowerStatusLiveProof'
OWNER_READ = 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state'
OWNER_SET = 'SourcePlacedPowerGraphState.source_consumer_set_power_status_for_cell_state'
TESTS = ['test_c07_power_status_live_registration', 'test_all_c07_power_status_live_input_evidence_is_exact', 'test_consumer_power_status_state', 'test_reference_graph_and_actual_c07_power_status_live']
DEFERRED = [
    'drones_in_position / spawn_occupied / spawn_visual_occupied / allow_update frame inputs -- the assembler driver still reads defaults (0 / false / false / true) until a drone-position / collision / allow-update slice lands.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Reconstructor constructTime catalog capture -- the driver still uses default 120.0 instead of the real 600 for additive-reconstructor.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'power.status live read for the other consumer families (drill, turret, factory, adjacent) -- the write-back stamps every consumer\'s frame generically, but only the unit-factory driver reads frame["power_status"] so far; the other families\' consumption paths still fold their own defaults until their slices land.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void distributePower(float needed, float produced, boolean charged){',
    'float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);',
    'consumer.power.status = Mathf.clamp(consumer.power.status + maximumRate / cons.capacity);',
    'consumer.power.status = coverage;',
    'consumer.power.status = Math.min(1, produced / (needed + cons.usage * consumer.delta()));',
    'if(Float.isNaN(consumer.power.status)){',
    'consumer.power.status = 0f;',
    'tile.power.status = 1f;',
    'lastPowerNeeded = lastPowerProduced = 1f;',
    'distributePower(powerNeeded, powerProduced, charged);',
    'public float status = 0.0f;',
    'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;',
    'return build.power.status;',
    '(1f - entity.power.status) * capacity :',
    'public void add(Building build){',
    'public void update(){',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=POWERGRAPH, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2142_read_inputs = {
        'game': f('Object', 'public void update(){', 'The live game world (PowerGraph.java:215 update()): the placed-building index the read resolves the cell\'s sprite from.'),
        'cell': f('Vector2i', 'public void add(Building build){', 'The placed building\'s origin cell (PowerGraph.java:277 add): the graph-membership gate -- only a building added to the graph has a frame to read.'),
    }
    n2142_read_outputs = {
        'status': f('float', 'return build.power.status;', 'The frame\'s stored power.status (ConsumePower.java:39, the canonical power.status read); 0.0 when no frame carries one -- the PowerModule field default (PowerModule.java:13).', source=CONSUMEPOWER),
        'found': f('bool', 'public void add(Building build){', 'Whether a placed building frame was found at the cell (PowerGraph.java:277 add): false when there is no sprite or no family frame.'),
        'reason': f('String', 'public void update(){', 'Why the read resolved the way it did (PowerGraph.java:215 update()): live_frame, no_sprite, or no_frame.'),
    }

    n2142_set_inputs = {
        'game': f('Object', 'public void update(){', 'The live game world (PowerGraph.java:215 update()): the placed-building index the write resolves the cell\'s sprite from.'),
        'cell': f('Vector2i', 'public void add(Building build){', 'The placed building\'s origin cell (PowerGraph.java:277 add): the graph-membership gate -- only a building added to the graph has a frame to write.'),
        'status': f('float', 'consumer.power.status = coverage;', 'The distributePower result to store (PowerGraph.java:203): the consumer\'s computed power.status for this tick.'),
    }
    n2142_set_outputs = {
        'stored': f('bool', 'consumer.power.status = coverage;', 'Whether the status was stored on the placed building\'s frame (PowerGraph.java:203 consumer.power.status = coverage).'),
        'reason': f('String', 'public void update(){', 'Why the write resolved the way it did (PowerGraph.java:215 update()): live_frame, no_sprite, or no_frame.'),
    }

    entries = [
        ('N2142', OWNER_READ, 'source_consumer_power_status_for_cell_state', POWERGRAPH, 'mindustry.world.blocks.power.PowerGraph', 'PowerGraph.distributePower(float, float, boolean)', n2142_read_inputs, n2142_read_outputs, True, 'Dictionary'),
        ('N2142', OWNER_SET, 'source_consumer_set_power_status_for_cell_state', POWERGRAPH, 'mindustry.world.blocks.power.PowerGraph', 'PowerGraph.distributePower(float, float, boolean)', n2142_set_inputs, n2142_set_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PowerGraph.distributePower consumer power.status read/write from PowerGraph.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PowerGraph.distributePower consumer power.status read/write from PowerGraph.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the three read results, then the two
    # set results.
    by_slice['N2142'] = [
        'source_consumer_power_status_for_cell_state_result.status',
        'source_consumer_power_status_for_cell_state_result.found',
        'source_consumer_power_status_for_cell_state_result.reason',
        'source_consumer_set_power_status_for_cell_state_result.stored',
        'source_consumer_set_power_status_for_cell_state_result.reason',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2142', dict(status='done', java_source=POWERGRAPH, java_class='mindustry.world.blocks.power.PowerGraph', java_method='PowerGraph.distributePower(float, float, boolean)', godot_owner=OWNER_READ, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2142'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
