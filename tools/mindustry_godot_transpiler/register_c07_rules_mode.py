"""Register Rules.mode() (N2458).

Rules.mode() (Rules.java:249-261) is one slice (batch 45 slot 1):
the signature `public Gamemode mode(){` (:249) and the 5 branches
-- pvp > editor > attackMode > infiniteResources > survival
(default) -- all 0-hit in ledger, registry and contracts at base
c48a0af0 (1932 slices). The enum is returned as its String name
(precedent N2454: GameState `state` travels through GD as
`state_name`). The priority order is the whole slice: pvp=true
wins even when editor, attackMode and infiniteResources are all
true too, so the branches must be checked in Java order. A missing
flag means the Java field default (false): all four booleans
default to false (pvp :41, editor :51, attackMode :49,
infiniteResources :27), so an empty rules state is survival.
Gamemode.apply (Gamemode.java, mutating presets) is NOT part of
this slice. One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2096 unitCost), placed before
source_unit_cost_state because mode() (:249-261) comes before
unitCost() (:275-276) in Rules.java. One slice source: Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesModeProof'
MODE_OWNER = 'SourceRulesRuntimeState.source_rules_mode_state'
TESTS = ['test_c07_rules_mode_registration', 'test_all_c07_rules_mode_input_evidence_is_exact', 'test_rules_mode_state', 'test_reference_graph_and_actual_c07_rules_mode']
# The 1 slice source the N2458 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
EXACT_EXPRS = [
    '    public Gamemode mode(){',
    '        if(pvp){\n            return Gamemode.pvp;',
    '        }else if(editor){\n            return Gamemode.editor;',
    '        }else if(attackMode){\n            return Gamemode.attack;',
    '        }else if(infiniteResources){\n            return Gamemode.sandbox;',
    '        }else{\n            return Gamemode.survival;',
]
JAVA_METHOD = 'Rules.mode()'

DEFERRED = [
    'Gamemode.apply (Gamemode.java, mutating rules presets) -- NOT ported here; mode() only reads the 4 flags and returns the mode name.',
    'Gamemode.valid / description / toString -- NOT part of this slice; description/toString need Core.bundle (i18n).',
    'Rules.mode() Windows Godot proof -- debt in GOAL.md section 5: the N2458 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    mode_inputs = {
        'rules_state': a('Dictionary', '    public Gamemode mode(){', 'The live rules state (Rules.java:249-261): a Dictionary with the 4 bool flags pvp (:41), editor (:51), attackMode (:49) and infiniteResources (:27). A missing flag means the Java field default (false); all four default to false, so an empty rules state is survival.'),
    }
    mode_outputs = {
        'mode': a('String', '        }else{\n            return Gamemode.survival;', 'The gamemode that best fits these rules (Rules.java:249-261, `/** Returns the gamemode that best fits these rules. */`): "pvp", "editor", "attack", "sandbox" or "survival" -- the Gamemode enum name as a String (precedent N2454 GameState state_name). Priority order is pvp > editor > attackMode > infiniteResources > survival.'),
    }
    return mode_inputs, mode_outputs


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
    mode_inputs, mode_outputs = definitions()

    entries = [
        ('N2458', MODE_OWNER, 'source_rules_mode_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, mode_inputs, mode_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.mode() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.mode() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2458'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2458', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=MODE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2458'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
