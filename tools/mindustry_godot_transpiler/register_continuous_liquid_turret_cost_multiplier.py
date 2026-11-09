"""Register the ContinuousLiquidTurret custom cost multiplier (N2101).

N2101 extends SourceConsumeState.source_cost_multiplier_for_block_state
(N2097) with the custom multiplier lambda of ContinuousLiquidTurret
(ContinuousLiquidTurret.java:45-48, in init()): the ConsumeLiquidFilter
pays 1f / ammo.ammoMultiplier for the bullet type of the building's
current liquid, and 1f when the current liquid has no ammo type.

SourceConsumeState.source_cost_multiplier_for_block_state(build) reads
the turret branch from the build dict (the building frame): current_liquid
is b.liquids.current() — the last received/loaded liquid
(LiquidModule.java:80-83), read in the port from the liquid module's
"current" via SourceLiquidModuleState.source_current_state — and
ammo_types is the port form of ammoTypes (ObjectMap<Liquid, BulletType>,
ContinuousLiquidTurret.java:14), mapping liquid name to the bullet type
dict that carries ammoMultiplier (BulletType.java:95, default 2f).
Sublimate maps ozone to 1.2f and cyanogen to the 2f default
(Blocks.java:4604-4631). A turret frame without the keys its branch
needs keeps the 1.0 default, as do all other blocks (N2096-N2099
behavior unchanged).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java'
OWNER = 'SourceConsumeState.source_cost_multiplier_for_block_state'
INPUT_SCHEMA = 'source_cost_multiplier_for_block_state_input'
PROOF = '/root/ContinuousLiquidTurretCostMultiplierProof'
TESTS = ['test_continuous_liquid_turret_cost_multiplier_registration', 'test_all_continuous_liquid_turret_cost_multiplier_input_evidence_is_exact', 'test_reference_graph_and_actual_continuous_liquid_turret_cost_multiplier']
DEFERRED = [
    'Wiring the turret tick to set the frame keys (current_liquid from the liquid module, ammo_types from the block) is a later slice; the proof passes frame dicts directly.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();',
    'multiplier = b -> {',
    'var ammo = ammoTypes.get(b.liquids.current());',
    'return ammo == null ? 1f : 1f / ammo.ammoMultiplier;',
]


def main():
    new_inputs = {
        'current_liquid': backed('Variant', TURRET, 'ammoTypes.get(b.liquids.current())', 'The building\'s current liquid, b.liquids.current() — the last received/loaded liquid (LiquidModule.java:80-83); the port reads it from the liquid module\'s "current" via SourceLiquidModuleState.source_current_state and passes the liquid name on the frame.'),
        'ammo_types': backed('Dictionary', TURRET, 'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();', 'The turret ammo map, liquid name to the bullet type dict carrying ammoMultiplier (BulletType.java:95, default 2f); sublimate maps ozone to 1.2f and cyanogen to the 2f default (Blocks.java:4604-4631).'),
    }

    symbols = {}
    for field, meta in new_inputs.items():
        meta['used_by'] = [OWNER]
        symbol = INPUT_SCHEMA + '.' + field
        symbols[symbol] = dict(status='source-backed', godot_owner=OWNER, godot_symbol=symbol, java_source=meta['java_source'], java_method='init()', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
    source_symbols.upsert_source_symbols(GODOT, symbols)

    schemas = source_symbols.load_source_state_schema(GODOT)['schemas']
    input_entry = copy.deepcopy(schemas[INPUT_SCHEMA])
    input_entry['keys'].update(new_inputs)
    source_symbols.upsert_source_state_schema(GODOT, INPUT_SCHEMA, input_entry)

    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    contract = copy.deepcopy(contracts[OWNER])
    contract['params'] = [
        dict(name=k, type=input_entry['keys'][k]['type'], schema=INPUT_SCHEMA + '.' + k)
        for k in input_entry['keys']
    ]
    contract['tests'] = sorted(set(contract['tests']) | set(TESTS))
    contract['rule'] = 'Source-backed per-block cost multiplier; unit factories pay Rules.unitCost, other blocks pay the 1.0 default; a ContinuousLiquidTurret pays 1 / ammoMultiplier for its current liquid, 1.0 when the liquid has no ammo type.'
    source_symbols.upsert_source_api_contract(GODOT, OWNER, contract)

    source_symbols.upsert_source_slice(GODOT, 'N2101', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret', java_method='init()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(symbols), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {OWNER}
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
