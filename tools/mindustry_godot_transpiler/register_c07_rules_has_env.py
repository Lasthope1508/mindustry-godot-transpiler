"""Register Rules.hasEnv(int) (N2467).

Rules.hasEnv(int) (Rules.java:263-265) is one slice
(batch 48 slot 1):
    public boolean hasEnv(int env){
        return (this.env & env) != 0;
    }
The env field defaults to Vars.defaultEnv (Rules.java:163;
Vars.java:65: Env.terrestrial | Env.spores | Env.groundOil |
Env.groundWater | Env.oxygen), which with the Env bits
(Env.java: terrestrial=1, space=1<<1, spores=1<<3,
groundOil=1<<5, groundWater=1<<6, oxygen=1<<7) is
1|8|32|64|128 = 233 -- note space (2) is NOT in the default.
The traps: this is an ANY-overlap check, not ALL-bits -- a
combined flag is true when ANY of its bits is set (flag 2|8=10
is true on the default env because spores=8 is set); and flag
0 is always false (0 & anything is 0). The Java parameter is
also named `env` and shadows the field; GD names the
parameter env_flag and the field travels as the "env" key.
No const exists for the default in SourceRulesDefaults.gd, so
the GD function uses the literal 233 with the Vars.java:65
derivation in its comment. One GD function on the existing
file SourceRulesRuntimeState.gd (home of N2096 unitCost,
N2458 mode, N2459 unitHealth, N2461 buildRadius, N2462
unitDamage, N2464 unitBuildSpeed, N2465 isBanned and N2466
unitActivationDelay), placed after source_rules_mode_state
and before source_rules_build_radius_state because hasEnv()
(:263-265) sits between mode() (:249-261) and buildRadius()
(:267-269) in Rules.java. Two slice sources: Rules.java and
Vars.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
VARS = 'core/src/mindustry/Vars.java'
PROOF = '/root/C07RulesHasEnvProof'
HAS_ENV_OWNER = 'SourceRulesRuntimeState.source_rules_has_env_state'
TESTS = ['test_c07_rules_has_env_registration', 'test_all_c07_rules_has_env_input_evidence_is_exact', 'test_rules_has_env_state', 'test_reference_graph_and_actual_c07_rules_has_env']
# The 2 slice sources the N2467 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear
# verbatim in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
    'core/src/mindustry/Vars.java',
]
FORMULA = '        return (this.env & env) != 0;'
EXACT_EXPRS = [
    '    public boolean hasEnv(int env){',
    FORMULA,
    '    /** Environmental flags that dictate visuals & how blocks function. */\n    public int env = Vars.defaultEnv;',
    '    /** Default rule environment. */\n    public static final int defaultEnv = Env.terrestrial | Env.spores | Env.groundOil | Env.groundWater | Env.oxygen;',
]
JAVA_METHOD = 'Rules.hasEnv(int)'

DEFERRED = [
    'Rules.hasEnv(int) Windows Godot proof -- debt in GOAL.md section 5: the N2467 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    has_env_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:263-265): a Dictionary with env (:163, defaults to Vars.defaultEnv = 233 per Vars.java:65). A missing key means the Java field default.'),
        'env_flag': a('int', FORMULA, 'The environment flag bitmask to test (Rules.java:263, `hasEnv(int env)`) -- true when ANY of its bits overlaps the rules env.'),
    }
    has_env_outputs = {
        'has_env': a('bool', FORMULA, 'Whether the rules env overlaps the flag (Rules.java:263-265): (this.env & env) != 0 -- an ANY-overlap check, not ALL-bits, and flag 0 is always false.'),
    }
    return has_env_inputs, has_env_outputs


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
    has_env_inputs, has_env_outputs = definitions()

    entries = [
        ('N2467', HAS_ENV_OWNER, 'source_rules_has_env_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, has_env_inputs, has_env_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.hasEnv() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.hasEnv() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2467'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2467', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=HAS_ENV_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2467'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
