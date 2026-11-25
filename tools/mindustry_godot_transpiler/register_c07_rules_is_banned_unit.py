"""Register Rules.isBanned(UnitType) (N2469).

Rules.isBanned(UnitType) (Rules.java:311-313) is one slice (batch 48
slot 3):
    public boolean isBanned(UnitType unit){
        return unitWhitelist != bannedUnits.contains(unit);
    }
unitWhitelist defaults to false (Rules.java:147) and bannedUnits
defaults to an empty ObjectSet<UnitType> (Rules.java:183). The trap
is the whitelist XOR: with the whitelist on, a unit IN the set is
allowed (false) and a unit NOT in the set is banned (true); with
an empty set and the whitelist on, EVERY unit is banned. A port
that reads isBanned as "is in the set" (== instead of !=) is wrong
in both whitelist cases. A second trap is copying N2465's field
names (blockWhitelist/bannedBlocks) instead of unitWhitelist/
bannedUnits -- the sibling slice's deferred_exprs explicitly left
this method for a later batch. The unit travels as its String name
-- precedent N2465 isBanned(Block), which keys blocks by name in
GD because Java keys the set by object. No new const is needed in
SourceRulesDefaults.gd: the defaults are false / empty, used as
literals like the Java fields. One GD function on the existing
file SourceRulesRuntimeState.gd (home of N2465 isBanned(Block) and
N2466 unitActivationDelay), placed between
source_rules_is_banned_state and
source_rules_unit_activation_delay_state because isBanned(UnitType)
(:311-313) comes after isBanned(Block) (:307-309) and before
unitActivationDelay() (:315-317) in Rules.java. One slice source:
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
PROOF = '/root/C07RulesIsBannedUnitProof'
IS_BANNED_UNIT_OWNER = 'SourceRulesRuntimeState.source_rules_is_banned_unit_state'
TESTS = ['test_c07_rules_is_banned_unit_registration', 'test_all_c07_rules_is_banned_unit_input_evidence_is_exact', 'test_rules_is_banned_unit_state', 'test_reference_graph_and_actual_c07_rules_is_banned_unit']
# The 1 slice source the N2469 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return unitWhitelist != bannedUnits.contains(unit);'
EXACT_EXPRS = [
    '    public boolean isBanned(UnitType unit){',
    FORMULA,
    '    /** If true, bannedUnits becomes a whitelist. */\n    public boolean unitWhitelist = false;',
    '    /** Units that cannot be built. */\n    public ObjectSet<UnitType> bannedUnits = new ObjectSet<>();',
]
JAVA_METHOD = 'Rules.isBanned(UnitType)'

DEFERRED = [
    'Rules.isBanned(UnitType) Windows Godot proof -- debt in GOAL.md section 5: the N2469 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    is_banned_unit_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:311-313): a Dictionary with unitWhitelist (:147, defaults to false) and bannedUnits (:183, defaults to an empty set of unit names). A missing key means the Java field default.'),
        'unit': a('String', FORMULA, 'The unit to check, by String name (Rules.java:311, `isBanned(UnitType unit)`) -- precedent N2465 isBanned(Block), which keys blocks by name in GD.'),
    }
    is_banned_unit_outputs = {
        'is_banned': a('bool', FORMULA, 'Whether the unit is banned (Rules.java:311-313): unitWhitelist != bannedUnits.contains(unit) -- the whitelist INVERTS the answer, so with the whitelist on a listed unit is allowed (false) and with an empty set every unit is banned (true).'),
    }
    return is_banned_unit_inputs, is_banned_unit_outputs


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
    is_banned_unit_inputs, is_banned_unit_outputs = definitions()

    entries = [
        ('N2469', IS_BANNED_UNIT_OWNER, 'source_rules_is_banned_unit_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, is_banned_unit_inputs, is_banned_unit_outputs, True, 'Dictionary'),
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
    by_slice['N2469'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2469', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=IS_BANNED_UNIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2469'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
