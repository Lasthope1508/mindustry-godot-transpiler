"""Register the battery live enabled stamp (N2134).

The battery live `enabled` stamp, the next item on the N2133 "Next"
list (and the N2133 deferred line: "PowerGraph.getBatteryStored
gates on battery.enabled (PowerGraph.java:118-126), but the battery
has no tick frame in the port, so its live enabled flag cannot be
read yet; the battery dict keeps its static enabled value").
PowerGraph reads the live `Building.enabled` on every battery pass
-- `if(battery.enabled){` in getBatteryStored / getBatteryCapacity /
getTotalBatteryCapacity / useBatteries (PowerGraph.java:123, 135,
147, 163) and `if(battery.enabled && battery.block.consPower.
capacity > 0f){` in chargeBatteries (PowerGraph.java:180). The flag
itself is BuildingComp's `transient boolean enabled = true;`
(BuildingComp.java:77). The port's
SourcePowerGraphBatteryDistributionState already reads
`battery.enabled` from the frame dicts, and
SourceBuildingPowerState.block_battery_state stamps an `enabled`
key -- but derived statically as `has_power or outputs_power or
consumes_power or power_buffered`, never from the live building --
so a disabled battery building still counts as enabled in the
graph.

N2134 is that function:
SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state,
which takes the frame (its `batteries` list is the battery dicts
built by block_battery_state, each carrying its live building under
the `block` key plus the statically derived `enabled`) and
overwrites each dict's `enabled` with the live Building.enabled
read through the existing block_properties seam; a battery whose
block carries no live `enabled` keeps its statically derived value
(Java defaults `enabled` to true, and the static derivation is the
port's standing default for a battery block -- the guard keeps
existing proof frames unaffected, same pattern as N2133's
`frame.has("modules")` guard). It returns the source owner, the
stamped batteries, and the enabled/disabled counts.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C06BatteryEnabledStampProof'
TESTS = ['test_c06_battery_enabled_stamp_registration', 'test_all_c06_battery_enabled_stamp_input_evidence_is_exact', 'test_battery_enabled_stamp_reads_live_building_enabled', 'test_reference_graph_and_actual_c06_battery_enabled_stamp']
DEFERRED = [
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; the intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is the wiring that calls the intake slice when a payload arrives.',
    'Units.canCreate live evaluation (Units.java:115-117) needs live per-type unit counts and the unit cap (the unit-group system, C07); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'lastTier tracking and the progress reset on a tier change (UnitAssembler.java:441-447, if(lastTier != currentTier){ if(lastTier >= 0f){ progress = 0f; } lastTier = lastTier == -2 ? -1 : currentTier; }) -- belongs to the live production/tick wiring, not the battery stamp.',
    'The live-loop module link/unlink call sites: updateModules/removeModule are called from UnitAssemblerModuleBuild link/unlink (UnitAssemblerModule.java:80-83) -- the port has no live module-linking frame event yet, so the frame modules list is an input, not something the tick maintains.',
    'The standalone SourcePlacedPowerGraphState.battery_state() query helper is not stamped -- only the live tick path (runtime_state) stamps. A query frame without a live building keeps its static enabled either way.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'transient boolean enabled = true;',
    'if(battery.enabled){',
    'if(battery.enabled && battery.block.consPower.capacity > 0f){',
    'var items = batteries.items;',
    'for(int i = 0; i < batteries.size; i++){',
    'var battery = items[i];',
    'float totalAccumulator = 0f;',
    'float totalCapacity = 0f;',
    'totalAccumulator += battery.power.status * battery.block.consPower.capacity;',
    'totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;',
    'totalCapacity += battery.block.consPower.capacity;',
    'battery.power.status *= (1f-consumedPowerPercentage);',
    'battery.power.status += (1f - battery.power.status) * chargedPercent;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=POWER_GRAPH, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2134_enabled_stamp_inputs = {
        'frame': f('Dictionary', 'transient boolean enabled = true;', 'The tick frame; its batteries list is the battery dicts built by block_battery_state, each carrying its live building under the block key plus the statically derived enabled. The stamp overwrites each dict enabled with the live Building.enabled (BuildingComp.enabled, default true); a battery whose block carries no live enabled keeps its static value.', source=BUILDING_COMP),
    }
    n2134_enabled_stamp_outputs = {
        'batteries': f('Array', 'if(battery.enabled){', 'The stamped batteries -- the same dicts, each enabled now the live Building.enabled of its block, so the graph gates on the live flag on the next pass.'),
        'enabled_count': f('int', 'var battery = items[i];', 'How many stamped batteries are enabled -- the count of batteries the PowerGraph passes include (getBatteryStored / getBatteryCapacity / getTotalBatteryCapacity / useBatteries / chargeBatteries).'),
        'disabled_count': f('int', 'if(battery.enabled && battery.block.consPower.capacity > 0f){', 'How many stamped batteries are disabled -- the count the PowerGraph passes exclude.'),
    }

    entries = [
        ('N2134', 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state', 'source_building_power_battery_enabled_stamp_state', POWER_GRAPH, 'mindustry.world.blocks.power.PowerGraph', 'PowerGraph.getBatteryStored()', n2134_enabled_stamp_inputs, n2134_enabled_stamp_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed battery live enabled stamp from PowerGraph.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed battery live enabled stamp from PowerGraph.'))
        all_names.extend(names)

    by_slice['N2134'] = sorted(all_names)
    source_symbols.upsert_source_slice(GODOT, 'N2134', dict(status='done', java_source=POWER_GRAPH, java_class='mindustry.world.blocks.power.PowerGraph', java_method='PowerGraph.getBatteryStored()', godot_owner='SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state', exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
