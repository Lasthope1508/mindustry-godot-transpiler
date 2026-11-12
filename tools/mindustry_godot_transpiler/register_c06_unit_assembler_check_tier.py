"""Register the UnitAssembler tier climb from the module tiers (N2133).

The tier-climb half of the assembler work, the next item on the N2132
"Next" list: UnitAssemblerBuild.checkTier()
(UnitAssembler.java:363-377) derives currentTier from the attached
UnitAssemblerModuleBuild modules -- sort by tier, climb while each
module is the current max or one above it, stop at the first tier gap
(`//tier gap, TODO warning?`), and store the result in currentTier.
The field it writes is UnitAssembler.java:326, `public int
currentTier = 0;`, and the list it reads is UnitAssembler.java:323,
`public Seq<UnitAssemblerModuleBuild> modules = new Seq<>();`. The
call sites are updateModules (UnitAssembler.java:355, `modules
.addUnique(build);` then `checkTier();`) and removeModule
(UnitAssembler.java:360, `modules.remove(build);` then
`checkTier();`) -- the tier only changes on a module event, never
per tick. A module block's tier is content-defined
(UnitAssemblerModule.java:22, `public int tier = 1;`, read through
`public int tier(){ return tier; }`, UnitAssemblerModule.java:85-86).
The consumer is plan() (UnitAssembler.java:383-385, `return
plans.get(Math.min(currentTier, plans.size - 1));`) -- already in the
port (N2124), which is why this slice is the function plus the gate
wiring that derives the plan tier from the module tiers when the
frame carries them, and keeps the stored current_tier otherwise.

N2133 is that function:
SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state,
which takes the frame (its `modules` list is the module tiers, each
UnitAssemblerModuleBuild.tier(); the frame carries them as a plain
list of ints, same minimal-frame convention as the N2129 `blocks`
dict) and returns the source owner, the derived current_tier, the
sorted module_tiers, and whether a gap stopped the climb (tier_gap).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
UNIT_ASSEMBLER_MODULE = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
PROOF = '/root/C06UnitAssemblerCheckTierProof'
TESTS = ['test_c06_unit_assembler_check_tier_registration', 'test_all_c06_unit_assembler_check_tier_input_evidence_is_exact', 'test_assembler_check_tier_reads_module_tiers', 'test_reference_graph_and_actual_c06_unit_assembler_check_tier']
DEFERRED = [
    'lastTier tracking and the progress reset on a tier change (UnitAssembler.java:441-447, if(lastTier != currentTier){ if(lastTier >= 0f){ progress = 0f; } lastTier = lastTier == -2 ? -1 : currentTier; }) -- belongs to the live production/tick wiring, not checkTier itself.',
    'The live-loop module link/unlink call sites: updateModules/removeModule are called from UnitAssemblerModuleBuild link/unlink (UnitAssemblerModule.java:80-83) -- the port has no live module-linking frame event yet, so the frame modules list is an input, not something the tick maintains.',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; the intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is the wiring that calls the intake slice when a payload arrives.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'Units.canCreate live evaluation (Units.java:115-117) needs live per-type unit counts and the unit cap (the unit-group system, C07); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void checkTier(){',
    'modules.sort(b -> b.tier());',
    'int max = 0;',
    'if(mod.tier() == max || mod.tier() == max + 1){',
    'max = mod.tier();',
    'currentTier = max;',
    '//tier gap, TODO warning?',
    'public int currentTier = 0;',
    'public Seq<UnitAssemblerModuleBuild> modules = new Seq<>();',
    'modules.addUnique(build);',
    'modules.remove(build);',
    'public int tier = 1;',
    'public int tier(){',
    'return tier;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_ASSEMBLER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2133_check_tier_inputs = {
        'frame': f('Dictionary', 'public Seq<UnitAssemblerModuleBuild> modules = new Seq<>();', 'The assembler frame; its modules list is the attached module tiers (UnitAssemblerBuild.modules, a Seq<UnitAssemblerModuleBuild>), each entry a UnitAssemblerModuleBuild.tier() int; a missing key reads as no modules.'),
    }
    n2133_check_tier_outputs = {
        'current_tier': f('int', 'currentTier = max;', 'checkTier: the climb result stored in currentTier -- 0 with no modules, else the highest tier reached before the first gap.'),
        'module_tiers': f('Array', 'modules.sort(b -> b.tier());', 'The module tiers sorted ascending, the order checkTier climbs in.'),
        'tier_gap': f('bool', '//tier gap, TODO warning?', 'Whether a tier gap stopped the climb -- true when a module tier is neither the current max nor max + 1.'),
    }

    entries = [
        ('N2133', 'SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state', 'source_unit_factory_assembler_check_tier_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.checkTier()', n2133_check_tier_inputs, n2133_check_tier_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitAssembler checkTier from the module tiers.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitAssembler checkTier from the module tiers.'))
        all_names.extend(names)

    by_slice['N2133'] = sorted(all_names)
    source_symbols.upsert_source_slice(GODOT, 'N2133', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.checkTier()', godot_owner='SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state', exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
