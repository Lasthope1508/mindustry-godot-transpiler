"""Register Rules.isBanned(Block) (N2465).

Rules.isBanned(Block) (Rules.java:307-309) is one slice (batch 47
slot 2):
    public boolean isBanned(Block block){
        return blockWhitelist != bannedBlocks.contains(block);
    }
blockWhitelist defaults to false (Rules.java:145) and bannedBlocks
defaults to an empty ObjectSet<Block> (Rules.java:181). The trap is
the whitelist XOR: with the whitelist on, a block IN the set is
allowed (false) and a block NOT in the set is banned (true); with
an empty set and the whitelist on, EVERY block is banned. A port
that reads isBanned as "is in the set" (== instead of !=) is wrong
in both whitelist cases. The block travels as its String name --
precedent N2460 GameStats.getPlaced
(SourceGameStatsRuntimeState.source_game_stats_get_placed_state),
because Java keys the set by Block object and GD keys by name. No
new const is needed in SourceRulesDefaults.gd: the defaults are
false / empty, used as literals like the Java fields. One GD
function on the existing file SourceRulesRuntimeState.gd (home of
N2096 unitCost, N2458 mode, N2459 unitHealth, N2461 buildRadius,
N2462 unitDamage and N2464 unitBuildSpeed), placed after
source_rules_unit_health_state and before
source_team_cheating_state because isBanned() (:307-309) comes
after unitHealth() (:283-286) in Rules.java. One slice source:
Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesIsBannedProof'
IS_BANNED_OWNER = 'SourceRulesRuntimeState.source_rules_is_banned_state'
TESTS = ['test_c07_rules_is_banned_registration', 'test_all_c07_rules_is_banned_input_evidence_is_exact', 'test_rules_is_banned_state', 'test_reference_graph_and_actual_c07_rules_is_banned']
# The 1 slice source the N2465 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return blockWhitelist != bannedBlocks.contains(block);'
EXACT_EXPRS = [
    '    public boolean isBanned(Block block){',
    FORMULA,
    '    /** If true, bannedBlocks becomes a whitelist. */\n    public boolean blockWhitelist = false;',
    '    /** Blocks that cannot be placed. */\n    public ObjectSet<Block> bannedBlocks = new ObjectSet<>();',
]
JAVA_METHOD = 'Rules.isBanned(Block)'

DEFERRED = [
    'Rules.isBanned(UnitType) -- same whitelist XOR shape as isBanned(Block), left for a later batch so batch 47 is not all one pattern.',
    'Rules.isBanned(Block) Windows Godot proof -- debt in GOAL.md section 5: the N2465 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    is_banned_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:307-309): a Dictionary with blockWhitelist (:145, defaults to false) and bannedBlocks (:181, defaults to an empty set of block names). A missing key means the Java field default.'),
        'block': a('String', FORMULA, 'The block to check, by String name (Rules.java:307, `isBanned(Block block)`) -- precedent N2460 GameStats.getPlaced, which keys blocks by name in GD.'),
    }
    is_banned_outputs = {
        'is_banned': a('bool', FORMULA, 'Whether the block is banned (Rules.java:307-309): blockWhitelist != bannedBlocks.contains(block) -- the whitelist INVERTS the answer, so with the whitelist on a listed block is allowed (false) and with an empty set every block is banned (true).'),
    }
    return is_banned_inputs, is_banned_outputs


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
    is_banned_inputs, is_banned_outputs = definitions()

    entries = [
        ('N2465', IS_BANNED_OWNER, 'source_rules_is_banned_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, is_banned_inputs, is_banned_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.isBanned() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.isBanned() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2465'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2465', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=IS_BANNED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2465'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
