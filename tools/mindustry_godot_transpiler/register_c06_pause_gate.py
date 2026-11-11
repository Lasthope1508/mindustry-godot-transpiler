"""Register the C06 pause gate (N2123).

The live loop had no pause: process_tick ran Time.update and every
sim on every frame no matter what, so there was no way to freeze the
game. Java gates the whole game update on the pause state:
Logic.update (Logic.java:507) runs the tick, Time.update and
updateEntities only inside `if(!state.isPaused())`, and
GameState.isPaused (GameState.java:93-95) is `state == State.paused`
(the states are paused, playing, menu; the state is set with
GameState.set(State)). The port keeps the pause as the game's
`paused` flag on the root bridge, reads it through the pure
source_game_loop_paused_state, and process_tick returns before
Time.update and before any sim while it is set — so a paused game
advances nothing at all: no drill time, no pump warmup, no belt
movement, no core deliveries, and MindustryTime.time frozen.

Java: GameState.isPaused(); GameState.set(State); Logic.update().

Deferred: per-building timeScale expiry (BuildingComp.update's
timeScaleDuration decay runs in simulate_block_time_scales already,
but no overdrive boost ever sets a duration yet), the disabled
gate (BuildingComp.update's `enabled || !block.noUpdateDisabled`
updateTile gate — the factory tick still runs its updateTile half
for a disabled factory because GenericCrafter leaves
noUpdateDisabled false, and efficiency 0 is what stops its
progress), removal of destroyed buildings from the live loop, and
source-exhaustion/output-full acts; the per-class shouldConsume()
bodies (UnitFactory.java:446, Reconstructor.java:368,
UnitAssembler.java:389); ConsumeItemDynamic.trigger plan stacks;
UnitAssembler plan dynamics; power-graph shouldConsumePower from
the live frame.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GAME_STATE = 'core/src/mindustry/core/GameState.java'
LOGIC = 'core/src/mindustry/core/Logic.java'
PAUSED_OWNER = 'SourceGameLoopRuntimeState.source_game_loop_paused_state'
PROOF = '/root/C06PauseProof'
TESTS = ['test_c06_pause_gate_registration', 'test_all_c06_pause_gate_input_evidence_is_exact', 'test_pause_gate_reads_live_game_state', 'test_reference_graph_and_actual_c06_pause_gate']
DEFERRED = [
    'Per-building timeScale expiry is a later slice: BuildingComp.update (BuildingComp.java:2262-2266) decays timeScaleDuration by Time.delta and resets timeScale to 1f when it runs out, and simulate_block_time_scales already runs that decay each tick, but nothing ever sets a duration yet (no overdrive boost path writes it).',
    'The disabled-building gate is a later slice: BuildingComp.update (BuildingComp.java:2275-2277) runs updateTile only when `enabled || !block.noUpdateDisabled`, and GenericCrafter leaves noUpdateDisabled false (Block.java:170), so a disabled factory still runs its updateTile half and only its zero efficiency stops progress; the tick driver does not skip the disabled frame yet.',
    'Removal of destroyed buildings from the live loop is a later slice: the factory tick still visits every placed building frame, and a destroyed building has no removal path out of placed_blocks yet.',
    'Source-exhaustion/output-full acts are later C06 slices: a drill on a depleted ore cell and a factory with a full output are not acted on yet.',
    'The three per-class shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389) are later slices; the tick passes the frame enabled flag as should_consume until then.',
    'The plan stacks leave only at unit completion via ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-56); the per-tick second pass removes nothing for items, so the production slice owns the trigger.',
    'The UnitAssembler plan dynamics (ConsumePayloadDynamic, ConsumeItemDynamic over plan().itemReq, ConsumeLiquidsDynamic over plan().liquidReq, UnitAssembler.java:158-160) are later slices; the registry captures no assembler plans yet, so no dynamic rows bind for them.',
    'Power graph shouldConsumePower from the live frame enabled flag is a later slice: Java ConsumePower.requestedPower gates on entity.shouldConsume(), but the port uses static catalog properties, so disabling a building does not change the power graph needed value and a disable -> battery-charges act is not possible yet.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public boolean isPaused(){',
    'return state == State.paused;',
    'paused, playing, menu',
    'public void set(State astate){',
    'if(!state.isPaused()){',
    'Events.fire(Trigger.beforeGameUpdate);',
    'state.tick += Float.isNaN(delta) || Float.isInfinite(delta) ? 0f : delta * 60f;',
    'Time.update();',
    'updateEntities();',
    'Events.fire(Trigger.afterGameUpdate);',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GAME_STATE, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2123_paused_inputs = {
        'game': f('Object', 'public boolean isPaused(){', 'The live game: its GameState pause flag is read from it.'),
    }
    n2123_paused_outputs = {
        'paused': f('bool', 'return state == State.paused;', 'True when the game state is State.paused; false while playing or in the menu, and false for a null game.'),
    }

    entries = [
        ('N2123', PAUSED_OWNER, 'source_game_loop_paused_state', LOGIC, 'mindustry.core.Logic', 'Logic.update(); GameState.isPaused()', n2123_paused_inputs, n2123_paused_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed C06 pause gate: GameState.isPaused reads State.paused, and Logic.update runs the tick, Time.update and the entity update only while unpaused.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed C06 pause gate: process_tick returns before Time.update and before any sim while the game is paused, so a paused game advances nothing at all.'))
        all_names.extend(names)

    by_slice['N2123'] = sorted(all_names)
    # One slice row: the paused read is the primary owner. The
    # process_tick early return and the `paused` flag on the root
    # bridge fold into this slice (the Logic.update gate wiring).
    source_symbols.upsert_source_slice(GODOT, 'N2123', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method='Logic.update(); GameState.isPaused()', godot_owner=PAUSED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
