"""Register the game rules state (N2098).

N2098 is GameState.rules: the live, mutable rules object for the
current game (GameState.java:35):
    /** The current game rules. */
    public Rules rules = new Rules();
Vars.state (Vars.java:271) is the global GameState holding it. The
rules object is created once per game with the Rules defaults
(unitCostMultiplier 1f, Rules.java:83; teams a fresh TeamRules,
Rules.java:29) and every reader — the drill tick, the unit
factories' multiplier callbacks (N2096/N2097) — reads the same
object, so mutations through it are live on the game. Before this
slice the game held no rules state at all: the drill tick read
game.get("rules_state") and fell back to an empty Dictionary, so
unitCost always read the 1.0 defaults.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GAME_STATE = 'core/src/mindustry/core/GameState.java'
VARS = 'core/src/mindustry/Vars.java'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/GameRulesStateProof'
TESTS = ['test_game_rules_state_binding_registration', 'test_all_game_rules_state_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_game_rules_state']
DEFERRED = [
    'Live TeamRules cheating (consumers do not consume while cheating) is a later C05 slice.',
    'C05 cache invalidation on Block reinit/reload is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

GAME_STATE_FIELD = '    /** The current game rules. */\n    public Rules rules = new Rules();'
VARS_STATE = '    public static GameState state;'
RULES_UNIT_COST = '    /** Multiplier of resources that units take to build. */\n    public float unitCostMultiplier = 1f;'
RULES_TEAMS = '    public TeamRules teams = new TeamRules();'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GAME_STATE, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2098_inputs = {
        'rules_state': f('Variant', GAME_STATE_FIELD, 'The game\'s current rules state (Vars.state.rules): null, empty, or the live rules Dictionary.'),
    }
    n2098_outputs = {
        'rules': f('Dictionary', RULES_UNIT_COST, 'The live game rules: the existing rules state, or the Java `new Rules()` defaults.', source=RULES),
    }

    entries = [
        ('N2098', 'SourceRulesRuntimeState.source_game_rules_state', 'source_game_rules_state', GAME_STATE, 'mindustry.core.GameState', 'rules', n2098_inputs, n2098_outputs, [GAME_STATE_FIELD, VARS_STATE, RULES_UNIT_COST, RULES_TEAMS], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed game rules state.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed game rules state; the live Rules object every multiplier callback reads.'))
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
