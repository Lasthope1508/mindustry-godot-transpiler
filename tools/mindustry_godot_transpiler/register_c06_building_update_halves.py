"""Register the BuildingComp.update() live-loop halves (N2126).

BuildingComp.update() (BuildingComp.java:2262-2277) does two things per
tick before updateTile: it decays timeScaleDuration and resets
timeScale to 1f on expiry, and it runs updateTile only when
`enabled || !block.noUpdateDisabled`. The decay already ran in the
live loop (simulate_block_time_scales decays every placed sprite), but
neither half was wired into the tick drivers that consume the values:

- The belt advance moved items by `speed * delta` with a hardcoded
  time scale of 1.0, while ConveyorBuild.updateTile moves them by
  `speed * edelta()` (Conveyor.java:266) and edelta carries the
  building's own timeScale (BuildingComp.java:1922-1929). A boosted
  belt never moved faster, and the expiry was unobservable in the belt
  path. N2126 reads each belt sprite's live timeScale in the wrapper
  and scales the advance by it.
- The conduit tick ran updateTile unconditionally, while the conduit
  sets noUpdateDisabled (Conduit.java:53), so a disabled conduit kept
  moving liquid. N2126 reads the conduit frame's enabled flag (the
  factory/turret frame pattern) and applies the gate: a disabled
  conduit returns with update_tile_called false and its liquid,
  smoothLiquid and flow timer untouched until it is enabled again.

Java: BuildingComp.update (BuildingComp.java:2262-2277):
    public void update(){
        if((timeScaleDuration -= Time.delta) <= 0f){
            timeScale = 1f;
        }
        ...
        updateConsumption();
        if(enabled || !block.noUpdateDisabled){
            updateTile();
        }
    }
BuildingComp.delta()/edelta() (BuildingComp.java:1921-1929):
    public float delta(){
        return Time.delta * timeScale;
    }
    public float edelta(){
        return efficiency * delta();
    }
ConveyorBuild.updateTile (Conveyor.java:255-266):
            if(len == 0 && Mathf.equal(timeScale, 1f)){
                clogHeat = 0f;
                sleep();
                return;
            }
            float moved = speed * edelta();
ConduitBuild.updateTile (Conduit.java:249-255):
            smoothLiquid = Mathf.lerpDelta(smoothLiquid, liquids.currentAmount() / liquidCapacity, 0.05f);
            if(liquids.currentAmount() > 0.0001f && timer(timerFlow, 1)){
                moveLiquidForward(leaks, liquids.current());
                noSleep();
            }else{
                sleep();
            }
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONVEYOR = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
CONDUIT = 'core/src/mindustry/world/blocks/liquid/Conduit.java'
CONDUIT_OWNER = 'SourceConduitRuntimeState.source_conduit_update_state'
ADVANCE_OWNER = 'SourceConveyorRuntimeState.source_conveyor_advance_state'
ADVCONV_OWNER = 'SourceFactoryRuntimeState.source_factory_advance_conveyors_state'
PROOF = '/root/C06BuildingUpdateProof'
TESTS = ['test_c06_building_update_halves_registration', 'test_all_c06_building_update_halves_input_evidence_is_exact', 'test_live_loop_wires_building_update_halves', 'test_reference_graph_and_actual_c06_building_update_halves']
DEFERRED = [
    'The battery\'s live enabled stamp (PowerGraph.getBatteryStored gates on battery.enabled, but the battery has no tick frame).',
    'The shouldConsumePower half that clears when a non-power consumer fails (BuildingComp.java:1971-1974, first pass).',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948, consumerless branch: efficiency is 1 only when enabled and productionValid); the port carries no per-belt efficiency yet, so a disabled belt still advances — the updateConsumption disabled branch needs a per-belt efficiency first.',
    'ConsumeItemDynamic.trigger at unit completion (ConsumeItemDynamic.java:53-56).',
    'UnitAssembler plan dynamics (UnitAssembler.java:158-160).',
    'Source-exhaustion/output-full acts.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    '            float moved = speed * edelta();',
    '        return Time.delta * timeScale;',
    '        return efficiency * delta();',
    '        if((timeScaleDuration -= Time.delta) <= 0f){',
    '            timeScale = 1f;',
    '    transient boolean enabled = true;',
    '        if(enabled || !block.noUpdateDisabled){',
    '            updateTile();',
    '        noUpdateDisabled = true;',
    '            smoothLiquid = Mathf.lerpDelta(smoothLiquid, liquids.currentAmount() / liquidCapacity, 0.05f);',
    '            if(liquids.currentAmount() > 0.0001f && timer(timerFlow, 1)){',
    '                moveLiquidForward(leaks, liquids.current());',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2126_outputs = {
        'update_tile_called': f('bool', '        if(enabled || !block.noUpdateDisabled){', 'Whether BuildingComp.update() ran updateTile this frame: false when the building is disabled and its block sets noUpdateDisabled (Conduit.java:53).'),
        'enabled': f('bool', '    transient boolean enabled = true;', 'The conduit frame enabled flag (Building.enabled, BuildingComp.java:77): what the updateTile gate reads; true unless the frame was disabled.'),
    }

    entries = [
        ('N2126', CONDUIT_OWNER, 'source_conduit_update_state', CONDUIT, 'mindustry.world.blocks.liquid.Conduit', 'update', {}, n2126_outputs, False, 'Dictionary'),
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
            # The result schema already exists (N2092): extend its keys
            # in place, keeping the N2092 source_slice and owner.
            schemas = source_symbols.load_source_state_schema(GODOT)['schemas']
            schema = copy.deepcopy(schemas[name])
            schema['keys'].update(keys)
            source_symbols.upsert_source_state_schema(GODOT, name, schema)
        all_names.extend(names)

    # The conduit update (N2092) gains the gate keys: deepcopy the
    # existing contract and extend its return keys, rule and tests,
    # keeping the N2092 source_slice (the signature does not change —
    # the gate only decides whether updateTile runs).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    conduit_contract = copy.deepcopy(contracts[CONDUIT_OWNER])
    conduit_contract['return_keys'] = list(conduit_contract['return_keys']) + ['update_tile_called', 'enabled']
    conduit_contract['tests'] = sorted(set(conduit_contract['tests']) | set(TESTS))
    conduit_contract['rule'] = 'Source-backed conduit rotation and updateTile; the conduits point at the drill and push water forward once per second. A disabled conduit runs no updateTile at all: BuildingComp.update (BuildingComp.java:2276) runs updateTile only when `enabled || !block.noUpdateDisabled`, and the conduit sets noUpdateDisabled (Conduit.java:53), so the tick reads the frame enabled flag (Building.enabled, BuildingComp.java:77) and returns update_tile_called false with its liquid, smoothLiquid and flow timer untouched until it is enabled again.'
    source_symbols.upsert_source_api_contract(GODOT, CONDUIT_OWNER, conduit_contract)

    # The belt advance (N2069) gains the timeScale factor: the rule
    # extends in place, keeping the N2069 source_slice and the same
    # params/return keys (moved is now speed * delta * time_scale).
    advance_contract = copy.deepcopy(contracts[ADVANCE_OWNER])
    advance_contract['tests'] = sorted(set(advance_contract['tests']) | set(TESTS))
    advance_contract['rule'] = 'Source-backed conveyor belt advance; the belt moves its items and hands the front item to the next belt or the core. Items move by speed * edelta() (Conveyor.java:266): the advance takes the building\'s live per-building timeScale (decayed each tick by BuildingComp.update, BuildingComp.java:2265-2267), so a boosted belt moves faster until its duration expires.'
    source_symbols.upsert_source_api_contract(GODOT, ADVANCE_OWNER, advance_contract)

    # The belt wrapper (N2070) gains the live timeScale read: the rule
    # extends in place, keeping the N2070 source_slice and the same
    # params/return keys (each belt passes its own live timeScale).
    advconv_contract = copy.deepcopy(contracts[ADVCONV_OWNER])
    advconv_contract['tests'] = sorted(set(advconv_contract['tests']) | set(TESTS))
    advconv_contract['rule'] = 'Source-backed conveyor belt advance; the belt moves its items and hands the front item to the next belt or the core. The wrapper reads each belt sprite\'s live per-building timeScale (decayed each tick by simulate_block_time_scales, BuildingComp.java:2265-2267) and passes it to the advance, so a boosted belt moves by speed * edelta() until its duration expires.'
    source_symbols.upsert_source_api_contract(GODOT, ADVCONV_OWNER, advconv_contract)

    # The advance time_scale input symbol (N2069) gains the movement
    # half of its meaning: the rule extends in place, keeping the
    # N2069 java_expr and source_slice.
    registry = source_symbols.load_source_symbol_registry(GODOT)['symbols']
    time_scale_symbol = copy.deepcopy(registry['source_conveyor_advance_state_input.time_scale'])
    time_scale_symbol['rule'] = 'Block time scale; an empty belt sleeps when it is 1, and a loaded belt moves by speed * edelta() (speed * delta * timeScale), so a boosted belt moves faster until its duration expires (Conveyor.java:266, BuildingComp.java:1922-1929).'
    time_scale_symbol['tests'] = sorted(set(time_scale_symbol['tests']) | set(TESTS))
    symbols['source_conveyor_advance_state_input.time_scale'] = time_scale_symbol

    # One slice row: the conduit update is the primary owner; the belt
    # halves share the slice (their contracts carry their own owners).
    source_symbols.upsert_source_slice(GODOT, 'N2126', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp', java_method='update', godot_owner=CONDUIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
