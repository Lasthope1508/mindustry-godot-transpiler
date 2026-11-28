"""Register Team.coloredName() (N2488).

Team.coloredName() (Team.java:139-141) is one slice
(batch C8 slot 1):
    public String coloredName(){
        return emoji + "[#" + color + "]" + localized() + "[]";
    }
The field `emoji` is `public String` (Team.java:23,
default "") and `color` is `public final Color`
(Team.java:18). The "[#" + color + "]" segment
stringifies the arc Color via Color.toString()
(arc-core Color.java:769-779): RRGGBBAA, 8 hex chars --
so the color arrives as a precomputed hex string, not
a Color object. localized() (Team.java:135-137) is
`Core.bundle.get("team." + name + ".name", name)` --
NOT ported here; its value arrives as a precomputed
input (the precomputed-input precedent: a callee the
slice does not own is modelled as an input, never
re-implemented). The function is plain string
concatenation: no guard, no clamp, no escaping -- an
empty emoji contributes nothing, an empty localized
leaves "[#...][]", and the "[#", "]", "[]" markup
literals pass through verbatim. One GD function on the
existing file SourceTeamsRuntimeState.gd (home of N2456
Team.get and N2463 Team.compareTo), placed between
source_team_get_state and source_team_compare_to_state
because Team.get() (:58-60) comes before coloredName()
(:139-141), which comes before compareTo() (:159-162)
in Team.java. NO twin-register: the 3 coloredName hits
in exact_exprs (N548/N1864/N2268) are all call-sites
(player.coloredName(), getPlayer().coloredName()), not
ownership. One slice source: Team.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM = 'core/src/mindustry/game/Team.java'
PROOF = '/root/C07TeamColoredNameProof'
COLORED_NAME_OWNER = 'SourceTeamsRuntimeState.source_team_colored_name_state'
TESTS = ['test_c07_team_colored_name_registration', 'test_all_c07_team_colored_name_input_evidence_is_exact', 'test_team_colored_name_state', 'test_reference_graph_and_actual_c07_team_colored_name']
# The 1 slice source the N2488 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Team.java',
]
FORMULA = '        return emoji + "[#" + color + "]" + localized() + "[]";'
EXACT_EXPRS = [
    'public class Team implements Comparable<Team>, Senseable{',
    '    public final Color color = new Color();',
    '    public String emoji = "";',
    '    public String localized(){',
    '        return Core.bundle.get("team." + name + ".name", name);',
    '    public String coloredName(){',
    FORMULA,
]
JAVA_METHOD = 'Team.coloredName()'

DEFERRED = [
    'Team.localized() (Team.java:135-137) is NOT in this slice: `Core.bundle.get("team." + name + ".name", name)` needs the Core.bundle infra (the N1271 ability_localized.bundle_get precedent) -- this slice models the localized value as a precomputed input; localized() waits for its own slice (backup A of the C8 batch).',
    'Team.coloredName() Windows Godot proof -- debt in GOAL.md section 5: the N2488 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Team.activateUnitFactories() (Team.java:127) and Team.isAI() (Team.java:112) need a twin-register approval of their own (their body literals are exact_exprs of N2124) -- they are NOT in this slice and must not be taken as slots without that approval (the N2474 precedent).',
    'Team.rules() (Team.java:88) needs a twin-register approval of its own (its body literal is an exact_expr of N2099/N2107) -- it is NOT in this slice.',
    'The color input is the arc Color.toString() hex (RRGGBBAA, arc-core Color.java:769-779), NOT a Color object: the "[#" + color + "]" segment stringifies the field, so the GD function takes the precomputed hex string; no Color-to-hex conversion is done in this slice.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM, **extra):
        return backed(typ, source, expr, rule, **extra)

    colored_inputs = {
        'emoji': a('String', '    public String emoji = "";', 'The emoji field (Team.java:23, `public String emoji = "";`, default ""): the icon-font glyph prefix, loaded from stringIcons (Fonts.java:210, 233) -- arrives as an explicit param, empty when the team has none.'),
        'color_hex': a('String', '    public final Color color = new Color();', 'The team color as its arc Color.toString() hex (Team.java:18, `public final Color color = new Color();`): the "[#" + color + "]" segment stringifies the Color (arc-core Color.java:769-779, RRGGBBAA, 8 hex chars) -- arrives as a precomputed hex string, not a Color object.'),
        'localized_name': a('String', '        return Core.bundle.get("team." + name + ".name", name);', 'The precomputed localized() value (Team.java:136, `return Core.bundle.get("team." + name + ".name", name);`): localized() itself is NOT ported here (needs Core.bundle infra) -- its value arrives as an explicit param (the precomputed-input precedent).'),
    }
    colored_outputs = {
        'colored_name': a('String', FORMULA, 'The colored name (Team.java:140): emoji + "[#" + color + "]" + localized() + "[]" -- plain concatenation, no guard, no clamp, no escaping; an empty emoji contributes nothing and an empty localized leaves "[#...][]".'),
    }
    return colored_inputs, colored_outputs


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
    colored_inputs, colored_outputs = definitions()

    entries = [
        ('N2488', COLORED_NAME_OWNER, 'source_team_colored_name_state', TEAM, 'mindustry.game.Team', JAVA_METHOD, colored_inputs, colored_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Team.coloredName() state from Team.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Team.coloredName() state from Team.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2488'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2488', dict(status='done', java_source=TEAM, java_class='mindustry.game.Team', java_method=JAVA_METHOD, godot_owner=COLORED_NAME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2488'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
