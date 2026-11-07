"""Register live-loop dump-all-drills binding (N2073).

N2073 makes the live loop dump every drill's output when the dump
timer fires (the two-Drill gate): simulate_factory calls the new
dump-all step instead of dumping only the primary drill. Each drill
dumps from its own inventory via the N2072 per-drill dump, so the
secondary's output now reaches a belt instead of accumulating in its
frame forever.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PROOF = '/root/TwoDrillGateProof'
TESTS = ['test_two_drill_gate_binding_registration', 'test_all_two_drill_gate_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_two_drill_gate']
DEFERRED = [
    'The queue-to-sprite sync stays open in C02 (transport is sprite-based with no item identity).',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DUMP_TIMER = 'if(timer(timerDump, dumpTime / timeScale)){'
DUMP_DISPATCH = 'dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);'
NULL_GATE = 'if(dominantItem == null){'
TIME_DRILLED = 'timeDrilled += warmup * delta();'
DELAY = 'float delay = getDrillTime(dominantItem);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, DRILL, expr, rule, **extra)

    n2073_inputs = {
        'game': f('Object', DUMP_TIMER, 'Actual game world containing the drills and their belts.'),
        'should_dump': f('bool', DUMP_TIMER, 'Whether the dump timer fired this frame.'),
    }
    n2073_outputs = {
        'results_by_cell': f('Dictionary', DUMP_DISPATCH, 'The per-drill dump results keyed by drill cell.'),
        'dumped_count': f('int', DUMP_DISPATCH, 'How many drills dumped an item this frame.'),
        'reason': f('String', NULL_GATE, 'Dump outcome: timer_not_fired, no_drills, dumped, none_dumped.'),
    }

    entries = [
        ('N2073', 'SourceFactoryRuntimeState.source_factory_dump_all_drill_outputs_state', 'source_factory_dump_all_drill_outputs_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'updateTile', n2073_inputs, n2073_outputs, [DUMP_TIMER, DUMP_DISPATCH, NULL_GATE, TIME_DRILLED, DELAY], True, 'Dictionary'),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed live-loop dump-all-drills step.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed live-loop step; when the dump timer fires it dumps every drill from its own inventory.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
