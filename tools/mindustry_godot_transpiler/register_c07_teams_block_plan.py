"""Register Teams.BlockPlan ctor (N2409).

Teams.BlockPlan(int x, int y, short rotation, Block block,
Object config) (Teams.java:497-503, static nested class
Teams.BlockPlan, Teams.java:492-496) is one slice: a plain
data-class constructor that stores x/y (narrowed to
short), rotation, block and config in the new record.

Only 3 exprs are registered as distinguishing (main-thread
decision 2026-11-22, batch 28 slot 2 -- 3 exprs is enough,
the N2407 2-expr precedent):
- `this.x = (short)x;`
- `this.y = (short)y;`
- `this.config = config;`

Evidence -- NOT re-registered as distinguishing exprs:
- `this.rotation = rotation;` -- owned N1770 (Building.init,
  both ledgers); the rotation value still passes through
  the GD function, it is only the expr ownership that is
  already held.
- `this.block = block;` -- owned N1771 (Building.create,
  both ledgers); same pass-through, same note.
- The mutable `removed` field (Teams.java:496) is outside
  the ctor: the ctor never touches it, so the returned
  record has no "removed" key.

Pattern (main-thread decision 2026-11-22, batch 28): pure
function returning a Dictionary -- BlockPlan is a data
class, not a Build state, so nothing is written to a
frame. The (short) casts narrow x/y to 16-bit signed
(GDScript has no short), the same narrowing
SourceBlockGeometry packs tile coords with.

Five result symbols (one per record key). One slice source:
Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_destroy_payload import DEFERRED as N2402_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsBlockPlanProof'
OWNER = 'SourceTeamsRuntimeState.source_teams_block_plan_state'
TESTS = ['test_c07_teams_block_plan_registration', 'test_all_c07_teams_block_plan_input_evidence_is_exact', 'test_teams_block_plan_state', 'test_reference_graph_and_actual_c07_teams_block_plan']
# The 1 slice source the N2409 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'this.x = (short)x;',
    'this.y = (short)y;',
    'this.config = config;',
]

# DEFERRED is carried from the N2402 register script via import --
# never retyped. All N2402 entries are carried verbatim (the
# Game chain, the B/C notes, and N2402's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2409's Windows proof debt.
DEFERRED = list(N2402_DEFERRED) + [
    'Teams.BlockPlan() Windows Godot proof -- debt in GOAL.md section 5, same as N2402: the N2409 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'x': a('int', 'this.x = (short)x;', 'The plan tile x (Teams.java:498, `this.x = (short)x;`): the ctor int is narrowed to a 16-bit signed short on store -- the GD function applies the same narrowing (GDScript has no short).'),
        'y': a('int', 'this.y = (short)y;', 'The plan tile y (Teams.java:499, `this.y = (short)y;`): same (short) narrowing as x.'),
        'rotation': a('int', 'this.rotation = rotation;', 'The plan rotation (Teams.java:500, `this.rotation = rotation;`): evidence only, owned N1770 (Building.init) -- the value passes through the GD function, only the expr ownership is already held.'),
        'block': a('Variant', 'this.block = block;', 'The planned block (Teams.java:501, `this.block = block;`): evidence only, owned N1771 (Building.create) -- Block is not ported, so it arrives as a Variant and passes through.'),
        'config': a('Variant', 'this.config = config;', 'The plan config (Teams.java:502, `this.config = config;`): Object config arrives as a Variant and is stored verbatim.'),
    }
    outputs = {
        'x': a('int', 'this.x = (short)x;', 'The stored plan tile x (Teams.java:498, `this.x = (short)x;`): the int ctor arg narrowed to 16-bit signed.'),
        'y': a('int', 'this.y = (short)y;', 'The stored plan tile y (Teams.java:499, `this.y = (short)y;`): the int ctor arg narrowed to 16-bit signed.'),
        'rotation': a('int', 'this.rotation = rotation;', 'The stored plan rotation (Teams.java:500, `this.rotation = rotation;`): evidence only, owned N1770 -- passes through verbatim.'),
        'block': a('Variant', 'this.block = block;', 'The stored planned block (Teams.java:501, `this.block = block;`): evidence only, owned N1771 -- Block is not ported, stored as a Variant.'),
        'config': a('Variant', 'this.config = config;', 'The stored plan config (Teams.java:502, `this.config = config;`): the Object config stored verbatim as a Variant.'),
    }
    return (inputs, outputs)


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
    for pair in [inputs_outputs]:
        for keys in pair:
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
    pairs = definitions()

    entries = [
        ('N2409', OWNER, 'source_teams_block_plan_state', TEAMS, 'mindustry.game.Teams', 'BlockPlan(int x, int y, short rotation, Block block, Object config)', pairs[0], pairs[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams BlockPlan ctor state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams BlockPlan ctor state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2409'] = [
        'source_teams_block_plan_state_result.x',
        'source_teams_block_plan_state_result.y',
        'source_teams_block_plan_state_result.rotation',
        'source_teams_block_plan_state_result.block',
        'source_teams_block_plan_state_result.config',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2409', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams$BlockPlan', java_method='BlockPlan(int x, int y, short rotation, Block block, Object config)', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2409'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
