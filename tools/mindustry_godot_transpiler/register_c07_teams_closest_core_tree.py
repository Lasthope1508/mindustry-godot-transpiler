"""Register Teams closestCore + TeamData tree group (N2392).

Teams.closestCore()+TeamData.tree()
(Teams.java:56-58 + :437-440,
`public CoreBuild closestCore(float x, float y, Team team){` /
`return Geometry.findClosest(x, y, get(team).cores);` /
`public QuadTree<Unit> tree(){` /
`if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));` /
`return unitTree;`) is one grouped slice: two one-to-two-line
read-only lookup methods on Teams/TeamData (`cores` +
`unitTree`) -- main-thread decision 2026-11-21 (the N2380
seven-method / N2374 five-accessor group precedent). Two GD
functions on SourceTeamsRuntimeState.gd, one ledger entry,
one owner per function (the N2380 multi-function precedent;
the N2378 lesson: a contract owner must be an actual GD
function, so the group label
`source_teams_closest_core_tree_state` is NOT registered as
an owner -- the ledger godot_owner is the first function
owner, `source_teams_closest_core_state`).

Callees -- NOT re-registered as distinguishing exprs:
- `get(team)` in closestCore() -- the Teams.get(Team)
  lookup (Teams.java:97), already the exact_expr of N2380;
  the cores arrive already resolved as an Array param.
- `Geometry.findClosest` -- arc engine API, not ported;
  it arrives as a Callable param (x, y, cores) -> the
  nearest core ref, or null (the @Nullable return).
- `Vars.world.getQuadBounds` -- live world API, not
  ported; it arrives as a Callable param (no args -> the
  bounds Dictionary for the fresh tree), called only when
  the unitTree cache is null (the lazy init).
- `QuadTree` / `Vars` / `Rect` -- not ported; the cache
  arrives as its Dictionary shape.

Both functions are read-only: closestCore only reads the
resolved cores through the Callable, tree() only reads the
cache (the lazy-init value is returned for the caller to
store back -- the function itself never writes).
Two new result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_team_data_lookup import DEFERRED as N2390_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsClosestCoreTreeProof'
CLOSEST_CORE_OWNER = 'SourceTeamsRuntimeState.source_teams_closest_core_state'
TREE_OWNER = 'SourceTeamsRuntimeState.source_team_data_tree_state'
TESTS = ['test_c07_teams_closest_core_tree_registration', 'test_all_c07_teams_closest_core_tree_input_evidence_is_exact', 'test_teams_closest_core_tree_state', 'test_reference_graph_and_actual_c07_teams_closest_core_tree']
# The 1 slice source the N2392 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public static class TeamData{',
    'public CoreBuild closestCore(float x, float y, Team team){',
    'return Geometry.findClosest(x, y, get(team).cores);',
    'public QuadTree<Unit> tree(){',
    'if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));',
    'return unitTree;',
]

# DEFERRED is carried from the N2390 register script via import --
# never retyped. All N2390 entries are carried verbatim (the
# Game chain, the B/C notes, the unitTree QuadTree model, the
# Team.all / Groups frame notes, and N2390's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2392's Windows proof debt.
DEFERRED = list(N2390_DEFERRED) + [
    'Teams.closestCore()+TeamData.tree() Windows Godot proof -- debt in GOAL.md section 5, same as N2390: the N2392 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    closest_core_inputs = {
        'x': a('float', 'public CoreBuild closestCore(float x, float y, Team team){', 'The x asking (Teams.java:56, `public CoreBuild closestCore(float x, float y, Team team){`): the query point x, passed straight to Geometry.findClosest.'),
        'y': a('float', 'public CoreBuild closestCore(float x, float y, Team team){', 'The y asking (Teams.java:56, `public CoreBuild closestCore(float x, float y, Team team){`): the query point y, passed straight to Geometry.findClosest.'),
        'cores': a('Array', 'return Geometry.findClosest(x, y, get(team).cores);', 'The team cores (Teams.java:57, `return Geometry.findClosest(x, y, get(team).cores);`): get(team).cores -- the TeamData cores Seq (Teams.java:288) as an Array of core refs; get(team) is the Teams.get(Team) lookup (Teams.java:97), already the exact_expr of N2380, so the cores arrive already resolved.'),
        'find_closest': a('Callable', 'return Geometry.findClosest(x, y, get(team).cores);', 'The nearest-core search (Teams.java:57, `return Geometry.findClosest(x, y, get(team).cores);`): Geometry.findClosest is an arc engine API, not ported -- it arrives as a Callable param (x, y, cores) -> the nearest core ref, or null (the @Nullable return, Teams.java:55) when no core is near.'),
    }
    closest_core_outputs = {
        'core': a('Variant', 'return Geometry.findClosest(x, y, get(team).cores);', 'The closest core (Teams.java:57, `return Geometry.findClosest(x, y, get(team).cores);`): whatever Geometry.findClosest returns -- the nearest CoreBuild ref, or null (the @Nullable return) when the cores Array is empty.'),
    }
    tree_inputs = {
        'unit_tree': a('Variant', 'if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));', 'The cached unit tree (TeamData.tree, Teams.java:438, `if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));`): the @Nullable QuadTree<Unit> cache (Teams.java:296) as a Dictionary-or-null param -- the QuadTree itself is not ported, the cache arrives as its Dictionary shape (the same shape _teams_reset_team_data keeps under "unit_tree").'),
        'world_quad_bounds': a('Callable', 'if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));', 'The world bounds supplier (Teams.java:438, `if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));`): Vars.world.getQuadBounds is a live world API, not ported -- it arrives as a Callable param (no args -> the bounds Dictionary for the fresh tree), called only when the cache is null (the lazy init).'),
    }
    tree_outputs = {
        'unit_tree': a('Dictionary', 'return unitTree;', 'The unit tree (Teams.java:439, `return unitTree;`): the cached tree when present, or the fresh tree from the world-bounds Callable when the cache was null -- the value the caller stores back into TeamData.'),
    }
    return (closest_core_inputs, closest_core_outputs), (tree_inputs, tree_outputs)


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
    for pair in inputs_outputs:
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
        ('N2392', CLOSEST_CORE_OWNER, 'source_teams_closest_core_state', TEAMS, 'mindustry.game.Teams', 'Teams.closestCore(float, float, Team)', pairs[0][0], pairs[0][1], True, 'Dictionary'),
        ('N2392', TREE_OWNER, 'source_team_data_tree_state', TEAMS, 'mindustry.game.Teams', 'TeamData.tree()', pairs[1][0], pairs[1][1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.closestCore()/TeamData.tree() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.closestCore()/TeamData.tree() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: closestCore core; tree unit_tree.
    by_slice['N2392'] = [
        'source_teams_closest_core_state_result.core',
        'source_team_data_tree_state_result.unit_tree',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2392', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.closestCore(float, float, Team)/TeamData.tree()', godot_owner=CLOSEST_CORE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2392'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
