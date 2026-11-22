"""Register Logic.checkCampaignStats() (N2438).

Logic.checkCampaignStats() (Logic.java:251-253, `private
boolean checkCampaignStats(){`) is the pure predicate for
whether campaign stats should be recorded:
`:252` `return state.isCampaign() && !net.client();`.
The line is 0-hit in BOTH ledgers (re-probed at base
91576ded).

One GD function on the existing
SourceGameLoopRuntimeState.gd (the N2123 file): the new
func source_game_loop_check_campaign_stats_state takes the
two frame inputs as explicit params and returns the
`campaign_stats` envelope key. `state.isCampaign()` and
`net.client()` are read as-is from the frame inputs and
never resolved here (their live reads are later slices).

NOT re-registered here: the call-sites
`if(checkCampaignStats()){` in the Logic ctor
(Logic.java:163, :196, :206, :212, :223, :232, :239,
:245) -- they belong to the 16 handler ctor slices,
waiting on the bus decision. No other line of
checkCampaignStats() exists: the method is one
signature line + one return line.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c06_pause_gate import DEFERRED as N2123_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LOGIC = 'core/src/mindustry/core/Logic.java'
PROOF = '/root/C07LogicCheckCampaignStatsProof'
CHECK_CAMPAIGN_STATS_OWNER = 'SourceGameLoopRuntimeState.source_game_loop_check_campaign_stats_state'
TESTS = ['test_c07_logic_check_campaign_stats_registration', 'test_all_c07_logic_check_campaign_stats_input_evidence_is_exact', 'test_logic_check_campaign_stats_state', 'test_reference_graph_and_actual_c07_logic_check_campaign_stats']
SLICE_SOURCES = [
    'core/src/mindustry/core/Logic.java',
]
EXACT_EXPRS = [
    'return state.isCampaign() && !net.client();',
]

# DEFERRED is carried from the N2123 register script via import --
# never retyped. Three entries are added: the N2438 Windows Godot
# proof debt (GOAL.md section 5), the ctor call-sites, and the
# live reads of state.isCampaign() / net.client().
DEFERRED = N2123_DEFERRED + [
    'Logic.checkCampaignStats() N2438 Windows Godot proof -- debt in GOAL.md section 5, same as N2123: the N2438 proof runs headless on Linux here and waits for a Windows Godot run.',
    'The checkCampaignStats() call-sites `if(checkCampaignStats()){` in the Logic ctor (Logic.java:163, :196, :206, :212, :223, :232, :239, :245) are later slices: they belong to the 16 handler ctor slices, waiting on the bus decision, not to the predicate slice N2438.',
    'The live reads of `state.isCampaign()` and `net.client()` are later slices: checkCampaignStats() only reads the frame inputs, it never resolves the campaign/client state itself.',
]


def definitions():
    def a(typ, expr, rule, source=LOGIC, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return state.isCampaign() && !net.client();'
    check_campaign_stats_inputs = {
        'is_campaign': a('bool', expr, 'Whether the game is a campaign game (Logic.java:252, `state.isCampaign()`): the first conjunct of checkCampaignStats().'),
        'is_client': a('bool', expr, 'Whether the game runs as a net client (Logic.java:252, `net.client()`): negated in the second conjunct of checkCampaignStats().'),
    }
    check_campaign_stats_outputs = {
        'campaign_stats': a('bool', expr, 'Whether campaign stats should be recorded (Logic.java:252, the full return line): isCampaign() && !net.client().'),
    }
    return check_campaign_stats_inputs, check_campaign_stats_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    check_campaign_stats_inputs, check_campaign_stats_outputs = definitions()

    entries = [
        ('N2438', CHECK_CAMPAIGN_STATS_OWNER, 'source_game_loop_check_campaign_stats_state', LOGIC, 'mindustry.core.Logic', 'Logic.checkCampaignStats()', check_campaign_stats_inputs, check_campaign_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Logic.checkCampaignStats() campaign-stats predicate state from Logic.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Logic.checkCampaignStats() campaign-stats predicate state from Logic.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the campaign_stats key only.
    by_slice['N2438'] = [
        'source_game_loop_check_campaign_stats_state_result.campaign_stats',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2438', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method='Logic.checkCampaignStats()', godot_owner=CHECK_CAMPAIGN_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2438'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
