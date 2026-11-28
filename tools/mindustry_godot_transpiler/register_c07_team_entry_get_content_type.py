"""Register TeamEntry.getContentType() (N2493).

TeamEntry.getContentType() (TeamEntry.java:27-29) is one slice
(batch C8 slot 3):
    @Override
    public ContentType getContentType(){
        return ContentType.team;
    }
on `public class TeamEntry extends UnlockableContent`
(TeamEntry.java:9) -- "only for displaying team lore in
the content database". One line, returns the CONSTANT enum
ContentType.team. It takes no params, so no input schema is
upserted (the N2486/N2422 zero-param contract precedent:
`source_team_entry_get_content_type_state_result` exists
with no `_input` schema). One new result symbol:
content_type.

The enum is modeled by its qualified Java name string
(the N1319 precedent: Block.getContentType()
`return ContentType.block;` is modeled as
"ContentType.block"). ContentType.team is the enum
constant with folderName "teams" and contentClass
TeamEntry.class (ContentType.java:27, `team("teams",
TeamEntry.class)`). The GD function lives in
SourceContentRegistryRuntimeState.gd -- no
UnlockableContent/TeamEntry GD file exists, and the
content registry runtime state is the home of the
content catalog state functions (source_item_catalog_state,
source_liquid_catalog_state) that classify content for
the database TeamEntry serves. It sits right after
source_liquid_catalog_state and before the consts block.

NOT a twin-register: the distinctive body literal
`return ContentType.team;` is 0-hit in ledger
exact_exprs (main-thread verified). The generic
signature line `public ContentType getContentType(){`
is shared with N1319 Block.getContentType
(`return ContentType.block;`) -- a different class
returning a different enum value, a name collision
only, not a twin. One slice source: TeamEntry.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM_ENTRY = 'core/src/mindustry/type/TeamEntry.java'
PROOF = '/root/C07TeamEntryGetContentTypeProof'
GET_CONTENT_TYPE_OWNER = 'SourceContentRegistryRuntimeState.source_team_entry_get_content_type_state'
TESTS = ['test_c07_team_entry_get_content_type_registration', 'test_all_c07_team_entry_get_content_type_input_evidence_is_exact', 'test_team_entry_get_content_type_state', 'test_reference_graph_and_actual_c07_team_entry_get_content_type']
# The 1 slice source the N2493 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/type/TeamEntry.java',
]
FORMULA = '        return ContentType.team;'
EXACT_EXPRS = [
    '    public ContentType getContentType(){',
    FORMULA,
    'public class TeamEntry extends UnlockableContent{',
]
JAVA_METHOD = 'TeamEntry.getContentType()'

# DEFERRED is defined locally (the N2487 lesson: never
# import a DEFERRED list from another register script --
# the N2416 list had ballooned with other families'
# entries). Exactly 5 entries.
DEFERRED = [
    'TeamEntry.getContentType() Windows Godot proof -- debt in GOAL.md section 5: the N2493 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TeamEntry.getContentType() is CLEAN, verified by the main thread (2026-11-28), no twin-register needed: java_method `TeamEntry.getContentType()` is 0-hit, the body literal `return ContentType.team;` is 0-hit in ledger exact_exprs, and the registry has 0 `team_entry_get_content_type` symbols before this slice. The generic signature line `public ContentType getContentType(){` is shared with N1319 Block.getContentType (`return ContentType.block;`) -- a different class returning a different enum value, a name collision only, not a twin. No GD function computes the TeamEntry override yet.',
    'TeamEntry.displayExtra(Table) (TeamEntry.java:21-24, `table.add("@team." + name + ".log").pad(6).padTop(20).width(400f).wrap().fillX();`) is NOT in this slice: displayExtra is UI layout for the content database, getContentType only classifies the entry; the table layout belongs to a later slice.',
    'TeamEntry constructors TeamEntry(String, Team) (TeamEntry.java:11-14) and TeamEntry(Team) (TeamEntry.java:16-18) and the `public final Team team;` field (TeamEntry.java:10) are NOT in this slice: getContentType reads no field and takes no params; construction and the team field belong to later slices.',
    'The ContentType enum itself (ContentType.java:10-27, `team("teams", TeamEntry.class)`) is NOT ported here as enum infra: getContentType returns the constant, modeled by its qualified Java name string "ContentType.team" (the N1319 precedent); the enum table, folderName "teams" and contentClass TeamEntry.class belong to later slices.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM_ENTRY, **extra):
        return backed(typ, source, expr, rule, **extra)

    # Zero params: getContentType() takes no state -- no input schema
    # is registered (the N2486/N2422 zero-param contract precedent).
    get_content_type_inputs = {}
    get_content_type_outputs = {
        'content_type': a('String', FORMULA, 'The content type of the team entry (TeamEntry.java:27-29, `return ContentType.team;`): the constant enum ContentType.team, modeled by its qualified Java name string (the N1319 precedent for Block.getContentType -> "ContentType.block"); ContentType.team is the enum constant with folderName "teams" and contentClass TeamEntry.class (ContentType.java:27). It must NOT return a sibling value such as ContentType.block (N1319) or ContentType.item.'),
    }
    return get_content_type_inputs, get_content_type_outputs


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
    get_content_type_inputs, get_content_type_outputs = definitions()

    entries = [
        ('N2493', GET_CONTENT_TYPE_OWNER, 'source_team_entry_get_content_type_state', TEAM_ENTRY, 'mindustry.type.TeamEntry', JAVA_METHOD, get_content_type_inputs, get_content_type_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            # Zero params: skip the input schema entirely (the
            # N2486/N2422 precedent) -- an empty keys object fails
            # state-schema validation.
            if not keys:
                continue
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamEntry.getContentType() state from TeamEntry.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamEntry.getContentType() state from TeamEntry.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2493'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2493', dict(status='done', java_source=TEAM_ENTRY, java_class='mindustry.type.TeamEntry', java_method=JAVA_METHOD, godot_owner=GET_CONTENT_TYPE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2493'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
