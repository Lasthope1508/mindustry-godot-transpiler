"""Register the live TeamRules cheating state (N2099).

N2099 is TeamComp.cheating(): whether a team's buildings skip
their consumers (TeamComp.java:17-19):
    public boolean cheating(){
        return team.rules().cheat;
    }
Team.rules() (Team.java:88-90) returns state.rules.teams.get(this);
TeamRules.get (Rules.java:391-394) creates a fresh TeamRule when the
team has none, and TeamRule.cheat (Rules.java:328, "If true, blocks
don't require power or resources.") defaults to false. While a team
cheats, its buildings' consumers are skipped and everything counts
as valid (BuildingComp.java:1944-1945). Before this slice the drill
frame's cheating flag was hardcoded false, so no live rules change
could ever make a building cheat; the drill tick now refreshes it
from the live rules every tick.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
TEAM = 'core/src/mindustry/game/Team.java'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/TeamCheatingStateProof'
TESTS = ['test_team_cheating_state_binding_registration', 'test_all_team_cheating_state_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_team_cheating_state']
DEFERRED = [
    'Wiring other buildings (turrets, factories) to the live cheating value is a later slice; this slice wires the drill tick.',
    'C05 cache invalidation on Block reinit/reload is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

CHEATING = '        return team.rules().cheat;'
TEAM_RULES_METHOD = '        return state.rules.teams.get(this);'
CHEAT_FIELD = '        /** If true, blocks don\'t require power or resources. */\n        public boolean cheat;'
TEAMRULES_GET = '            return out == null ? (values[team.id] = new TeamRule(team)) : out;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TEAM_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2099_inputs = {
        'rules_state': f('Variant', CHEATING, 'The live rules state: per-team cheat flags under "teams".'),
        'team_id': f('int', CHEATING, 'The team whose TeamRule cheat flag to read.'),
    }
    n2099_outputs = {
        'cheating': f('bool', CHEATING, 'Whether the team cheats: its TeamRule cheat flag (false by default).'),
    }

    entries = [
        ('N2099', 'SourceRulesRuntimeState.source_team_cheating_state', 'source_team_cheating_state', TEAM_COMP, 'mindustry.entities.comp.TeamComp', 'cheating()', n2099_inputs, n2099_outputs, [CHEAT_FIELD, CHEATING, TEAM_RULES_METHOD, TEAMRULES_GET], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed live TeamRules cheating.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed live TeamRules cheating; a cheating team skips its consumers.'))
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
