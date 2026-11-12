"""Register the reconstructor constructTime catalog capture (N2143).

The deferred catalog follow-up named in the N2138, N2139 and N2142
handoffs ("catalog has no constructTime for reconstructor blocks, so
the driver uses default 120.0 instead of the real 600 for
additive-reconstructor -- waits for a later catalog slice"). N2138
wired the reconstructor production tick and its pure function takes
construct_time as an input (backed by the class default,
Reconstructor.java:36), but the content catalog never captured the
per-block override, so the tick driver read
block.properties.get("constructTime", 120.0) and an
additive-reconstructor upgraded on the 120.0 default instead of its
real 600.0 (Blocks.java:6310), and a multiplicative-reconstructor on
120.0 instead of 1800.0 (Blocks.java:6330).

Composition, not re-implementation: the tick function
(source_reconstructor_production_tick_state, N2138) already completes
exactly when `progress >= constructTime` (Reconstructor.java:334);
N2143 does not touch it. N2143 supplies the missing catalog capture
(the craftTime pattern, N2117: the initializer's own assignment, else
the class default) plus one pure read on the block so the driver
stops inlining the fold.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
RECONSTRUCTOR = 'core/src/mindustry/world/blocks/units/Reconstructor.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ReconstructorConstructTimeProof'
OWNER = 'SourceUnitFactoryBuildState.source_reconstructor_construct_time_state'
TESTS = ['test_c07_reconstructor_construct_time_registration', 'test_all_c07_reconstructor_construct_time_input_evidence_is_exact', 'test_reconstructor_construct_time_state', 'test_reference_graph_and_actual_c07_reconstructor_construct_time']
DEFERRED = [
    'drones_in_position / spawn_occupied / spawn_visual_occupied / allow_update frame inputs -- the assembler driver still reads defaults (0 / false / false / true) until a drone-position / collision / allow-update slice lands.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'power.status live read for the other consumer families (drill, turret, factory, adjacent) -- the write-back stamps every consumer\'s frame generically, but only the unit-factory driver reads frame["power_status"] so far; the other families\' consumption paths still fold their own defaults until their slices land.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public float constructTime = 60 * 2;',
    'if(progress >= constructTime){',
    'constructTime = 60f * 10f;',
    'constructTime = 60f * 30f;',
    'stats.timePeriod = constructTime;',
    'stats.add(Stat.productionTime, constructTime / 60f, StatUnit.seconds);',
    'return progress / constructTime;',
    'additiveReconstructor = new Reconstructor("additive-reconstructor"){{',
    'multiplicativeReconstructor = new Reconstructor("multiplicative-reconstructor"){{',
    'public Reconstructor(String name){',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=RECONSTRUCTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2143_inputs = {
        'block': f('Object', 'additiveReconstructor = new Reconstructor("additive-reconstructor"){{', 'The block definition the read resolves (Blocks.java:6302): the catalog block whose properties carry the per-block constructTime override, or the class default when it carries none.', source=BLOCKS),
    }
    n2143_outputs = {
        'construct_time': f('float', 'public float constructTime = 60 * 2;', 'The per-block build time the production tick completes against (Reconstructor.java:36, the class default the read returns when the catalog carries no override); 600.0 for additive-reconstructor (Blocks.java:6310), 1800.0 for multiplicative-reconstructor (Blocks.java:6330).'),
    }

    entries = [
        ('N2143', OWNER, 'source_reconstructor_construct_time_state', RECONSTRUCTOR, 'mindustry.world.blocks.units.Reconstructor.ReconstructorBuild', 'ReconstructorBuild.updateTile()', n2143_inputs, n2143_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Reconstructor constructTime read from Reconstructor.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Reconstructor constructTime read from Reconstructor.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the single result symbol.
    by_slice['N2143'] = [
        'source_reconstructor_construct_time_state_result.construct_time',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2143', dict(status='done', java_source=RECONSTRUCTOR, java_class='mindustry.world.blocks.units.Reconstructor.ReconstructorBuild', java_method='ReconstructorBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2143'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
