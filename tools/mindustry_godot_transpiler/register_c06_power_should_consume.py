"""Register the power-graph shouldConsumePower from the live frame enabled flag (N2125).

The graph's consumer dicts are rebuilt from the catalog every frame
(SourcePlacedPowerGraphState._group_state /
SourceBuildingPowerState.block_consumer_state), and both power keys
are static there: should_consume and shouldConsumePower are
`has_power and consumes_power`. Java charges an unbuffered consumer
only while it should consume — ConsumePower.requestedPower
(ConsumePower.java:60-63) is `usage * (entity.shouldConsume() ? 1f :
0f)` — and BuildingComp.shouldConsume() (BuildingComp.java:755-757)
is just `return enabled;`, while updateConsumption's disabled branch
(BuildingComp.java:1952-1956) clears shouldConsumePower outright.
So a disabled lancer kept charging its full 6.0/60 in the live loop.
N2125 reads each placed building's live frame `enabled` flag
(N2107's cheating-stamp pattern) and stamps both consumer keys with
it in the live-loop power-graph step, so disabling the lancer drops
power_needed to 0.0, coverage goes to 1.0, and the solar surplus
charges the battery. The turret tick frame preserves `enabled` (the
factory pattern) so the disable survives the live loop.

Java: ConsumePower.requestedPower (ConsumePower.java:57-63):
    public float requestedPower(Building entity){
        return buffered ?
            (1f - entity.power.status) * capacity :
            usage * (entity.shouldConsume() ? 1f : 0f);
    }
BuildingComp.shouldConsume() (BuildingComp.java:755-757):
    public boolean shouldConsume(){
        return enabled;
    }
BuildingComp.updateConsumption() disabled branch
(BuildingComp.java:1952-1956):
        //disabled -> nothing works
        if(!enabled){
            potentialEfficiency = efficiency = optionalEfficiency = 0f;
            shouldConsumePower = false;
            return;
        }
PowerGraph.getPowerNeeded() (PowerGraph.java:105-115) sums only
consumers whose shouldConsumePower is set, at
`consumePower.requestedPower(consumer) * consumer.delta()`.
PowerGraph.distributePower() (PowerGraph.java:189) computes coverage
0 when needed, produced and the stored charge are all zero and
nothing charged, 1 when needed is zero, else min(1, produced /
needed).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
HELPER_OWNER = 'SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state'
DRIVER_OWNER = 'SourceFactoryRuntimeState.source_factory_update_power_graph_state'
TURRET_FRAME_OWNER = 'SourceTurretBuildState.source_turret_tick_frame_state'
PROOF = '/root/C06PowerShouldConsumeProof'
TESTS = ['test_c06_power_should_consume_registration', 'test_all_c06_power_should_consume_input_evidence_is_exact', 'test_live_loop_stamps_consumers_with_live_should_consume', 'test_reference_graph_and_actual_c06_power_should_consume']
DEFERRED = [
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'The shouldConsumePower half that clears when a non-power consumer fails (BuildingComp.java:1971-1974, first pass) is a later slice; this slice wires only the enabled half.',
    'ConsumeItemDynamic.trigger at unit completion (ConsumeItemDynamic.java:53-56).',
    'UnitAssembler plan dynamics (UnitAssembler.java:158-160).',
    'Per-building timeScale expiry plus the disabled-building updateTile gate (BuildingComp.java:2262-2276); timeScaleDuration decay already runs in simulate_block_time_scales.',
    'Source-exhaustion/output-full acts.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    '    public boolean shouldConsume(){',
    '        return enabled;',
    '        //disabled -> nothing works',
    '            shouldConsumePower = false;',
    '    transient boolean enabled = true;',
    '    public float requestedPower(Building entity){',
    '            usage * (entity.shouldConsume() ? 1f : 0f);',
    '    public float getPowerNeeded(){',
    '            if(consumer.shouldConsumePower){',
    '                powerNeeded += consumePower.requestedPower(consumer) * consumer.delta();',
    '        float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=POWER_GRAPH, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2125_inputs = {
        'game': f('Object', 'public void update(){', 'The game whose placed buildings form the power graph (PowerGraph.update runs over its consumers).'),
        'cell': f('Vector2i', 'public void add(Building build){', 'The origin cell of the placed building whose live frame enabled flag the consumer dict carries (PowerGraph.add puts each placed building in the graph once).'),
    }
    n2125_outputs = {
        'should_consume': f('bool', '        return enabled;', 'Whether the building should consume: its live frame enabled flag (BuildingComp.shouldConsume() returns enabled).', source=BUILDING_COMP),
        'shouldConsumePower': f('bool', '            shouldConsumePower = false;', 'Whether the building should consume power: false when its live frame is disabled (BuildingComp.updateConsumption clears it on the disabled branch).', source=BUILDING_COMP),
        'found': f('bool', 'public void add(Building build){', 'Whether a placed building frame (a graph member with a tick frame) was found at the cell.'),
        'reason': f('String', 'public void update(){', 'Why the lookup resolved the way it did (no_game/no_sprite/no_frame when no live frame was found, live_frame otherwise).'),
    }

    entries = [
        ('N2125', HELPER_OWNER, 'source_consumer_should_consume_for_cell_state', POWER_GRAPH, 'mindustry.world.blocks.power.PowerGraph', 'update', n2125_inputs, n2125_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed power-graph consumer live should-consume value.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed power-graph consumer live should-consume value; the helper reads a placed building\'s live frame enabled flag, so the grouped consumer dict carries what ConsumePower.requestedPower() and PowerGraph.getPowerNeeded() read.'))
        all_names.extend(names)

    # The live-loop driver (N2077) gains the should-consume stamp:
    # deepcopy the existing contract and extend its rule, keeping the
    # N2077 source_slice and the same params/return keys (the
    # signature does not change — the stamp only fills the consumer
    # dicts' should_consume / shouldConsumePower keys before the
    # update runs).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    driver_contract = copy.deepcopy(contracts[DRIVER_OWNER])
    driver_contract['tests'] = sorted(set(driver_contract['tests']) | set(TESTS))
    driver_contract['rule'] = 'Source-backed live-loop power graph update; each frame the placed graph runs PowerGraph.update(). Each grouped consumer dict is stamped with its building\'s live cheating value (TeamComp.cheating() from the live rules) and with its live should_consume / shouldConsumePower values (BuildingComp.shouldConsume() from the frame enabled flag) before the update runs, so the cheat gate fires when the first consumer\'s team cheats and a disabled building requests no power.'
    source_symbols.upsert_source_api_contract(GODOT, DRIVER_OWNER, driver_contract)

    # The turret tick frame (N2108) gains the enabled preservation:
    # deepcopy the existing contract and extend its rule, keeping the
    # N2108 source_slice and the same params/return keys (the frame
    # gains one preserved key; the signature does not change).
    turret_contract = copy.deepcopy(contracts[TURRET_FRAME_OWNER])
    turret_contract['tests'] = sorted(set(turret_contract['tests']) | set(TESTS))
    turret_contract['rule'] = 'Source-backed turret tick frame wiring; the tick refreshes the frame keys the ammo path reads (block_implementation, team_id, rules_state, cheating from TeamComp.cheating()) and preserves the frame\'s enabled flag (Building.enabled, BuildingComp.java:77 — what shouldConsume() returns), so a disabled turret stays disabled across ticks and the power graph reads it live.'
    source_symbols.upsert_source_api_contract(GODOT, TURRET_FRAME_OWNER, turret_contract)

    by_slice['N2125'] = sorted(all_names)
    # One slice row: the live-loop driver is the primary owner; the
    # helper shares the slice (its symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2125', dict(status='done', java_source=POWER_GRAPH, java_class='mindustry.world.blocks.power.PowerGraph', java_method='update', godot_owner=DRIVER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
