"""Register Logic.checkOverlappingPlans() (N2441).

Logic.checkOverlappingPlans() (Logic.java:255-266, `private
void checkOverlappingPlans(Team team, Tile tile)`) removes
build plans that overlap the block just placed on a tile:
`:256` `TeamData data = team.data();`
`:257` `Iterator<BlockPlan> it = data.plans.iterator();`
`:258` `var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);`
`:259` `while(it.hasNext()){`
`:260` `BlockPlan b = it.next();`
`:261` `if(bounds.overlaps(b.block.bounds(b.x, b.y, Tmp.r2))){`
`:262` `b.removed = true;`
`:263` `it.remove();`

Re-probed at base d638bfc2: 7/8 exprs are 0-hit in the
local ledger (:257-:263). The remaining expr, `:256`
`TeamData data = team.data();`, is a TWIN-REGISTER -- it
is already owned by local N2430 (Teams.updateTeamStats(),
owner SourceTeamsRuntimeState.source_teams_update_team_stats_state,
which registers the same literal as 1 of its 2 exprs;
remote FREE). Same literal under a different method/owner
-- precedent batch 37 slot 1 (shake :803, 9 slices own 1
literal) + N2194-N2200 (7 slices own 1 literal). Only
the 8 exprs :256-:263 are registered here; no other line
of N2430 is re-registered.

One GD function on the existing
SourceGameLoopRuntimeState.gd (the N2123 file): the new
func source_game_loop_check_overlapping_plans_state takes
the team data and the tile as explicit Dictionary inputs
and returns the `removed_plans` / `kept_plans` envelope.
`Tmp.r1` / `Tmp.r2` are shared temp rects and are NOT
ported -- bounds arrive as data: tile["bounds"] is the
tile block's bounds rect (tile.block().bounds(tile.x,
tile.y, Tmp.r1)) and each plan carries its own
plan["bounds"] (b.block.bounds(b.x, b.y, Tmp.r2)).
BlockPlan (Teams.java:492-496) is {x, y, rotation, block,
config, removed}; the port keeps plans as Dictionaries
with "x", "y", "bounds" (Rect2) and "removed" (bool).

NOT re-registered here: the two call-sites
`checkOverlappingPlans(event.team, event.tile);`
(Logic.java:55) and `checkOverlappingPlans(e.build.team,
e.build.tile);` (Logic.java:65) in the Logic ctor --
they belong to the 16 handler ctor slices, waiting on
the bus decision. No other line of checkOverlappingPlans()
exists: the method is one signature line + 8 body lines.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c06_pause_gate import DEFERRED as N2123_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LOGIC = 'core/src/mindustry/core/Logic.java'
PROOF = '/root/C07LogicCheckOverlappingPlansProof'
CHECK_OVERLAPPING_PLANS_OWNER = 'SourceGameLoopRuntimeState.source_game_loop_check_overlapping_plans_state'
TESTS = ['test_c07_logic_check_overlapping_plans_registration', 'test_all_c07_logic_check_overlapping_plans_input_evidence_is_exact', 'test_logic_check_overlapping_plans_state', 'test_reference_graph_and_actual_c07_logic_check_overlapping_plans']
SLICE_SOURCES = [
    'core/src/mindustry/core/Logic.java',
]
EXACT_EXPRS = [
    'TeamData data = team.data();',
    'Iterator<BlockPlan> it = data.plans.iterator();',
    'var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);',
    'while(it.hasNext()){',
    'BlockPlan b = it.next();',
    'if(bounds.overlaps(b.block.bounds(b.x, b.y, Tmp.r2))){',
    'b.removed = true;',
    'it.remove();',
]

# DEFERRED is carried from the N2123 register script via import --
# never retyped. Entries are added: the N2441 Windows Godot
# proof debt (GOAL.md section 5), the ctor call-sites, the
# Tmp.r1/Tmp.r2 bounds-as-data note, and the live bounds reads.
DEFERRED = N2123_DEFERRED + [
    'Logic.checkOverlappingPlans() N2441 Windows Godot proof -- debt in GOAL.md section 5, same as N2123: the N2441 proof runs headless on Linux here and waits for a Windows Godot run.',
    'The checkOverlappingPlans() call-sites `checkOverlappingPlans(event.team, event.tile);` (Logic.java:55) and `checkOverlappingPlans(e.build.team, e.build.tile);` (Logic.java:65) in the Logic ctor are later slices: they belong to the 16 handler ctor slices, waiting on the bus decision, not to the method slice N2441.',
    'Tmp.r1 / Tmp.r2 are shared temp rects and are NOT ported: tile.block().bounds(tile.x, tile.y, Tmp.r1) arrives as tile["bounds"] data and b.block.bounds(b.x, b.y, Tmp.r2) arrives as each plan["bounds"] data; the GD func only tests Rect2 overlap on that data.',
    'The live reads of tile.block().bounds() and BlockPlan fields (x, y, block, removed -- Teams.java:492-496) are later slices: checkOverlappingPlans() only reads the frame inputs, it never resolves live block bounds itself.',
]


def definitions():
    def a(typ, expr, rule, source=LOGIC, **extra):
        return backed(typ, source, expr, rule, **extra)

    team_data = 'TeamData data = team.data();'
    tile_bounds = 'var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);'
    check_overlapping_plans_inputs = {
        'team_data': a('Dictionary', team_data, 'The team data holding the build plans (Logic.java:256, `team.data()`): the plans list is read as team_data["plans"], one Dictionary per BlockPlan {x, y, bounds, removed} (Teams.java:492-496).'),
        'tile': a('Dictionary', tile_bounds, 'The tile whose block bounds are the overlap test rect (Logic.java:258, `tile.block().bounds(tile.x, tile.y, Tmp.r1)`): passed as tile["bounds"] Rect2 data, since Tmp.r1 is a shared temp rect and is not ported.'),
    }
    check_overlapping_plans_outputs = {
        'removed_plans': a('Array', 'b.removed = true;', 'The plans whose block bounds overlap the tile bounds (Logic.java:261-262): each is marked removed = true and removed from the team plans by `it.remove();` (Logic.java:263).'),
        'kept_plans': a('Array', 'while(it.hasNext()){', 'The plans that survive the loop (Logic.java:259): every plan is visited, and only the overlapping ones are removed (`it.remove();`, Logic.java:263), so the kept list is the plans for which it.remove() is never called.'),
    }
    return check_overlapping_plans_inputs, check_overlapping_plans_outputs


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
    check_overlapping_plans_inputs, check_overlapping_plans_outputs = definitions()

    entries = [
        ('N2441', CHECK_OVERLAPPING_PLANS_OWNER, 'source_game_loop_check_overlapping_plans_state', LOGIC, 'mindustry.core.Logic', 'Logic.checkOverlappingPlans()', check_overlapping_plans_inputs, check_overlapping_plans_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Logic.checkOverlappingPlans() overlapping-plan removal state from Logic.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Logic.checkOverlappingPlans() overlapping-plan removal state from Logic.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: removed_plans first, then kept_plans.
    by_slice['N2441'] = [
        'source_game_loop_check_overlapping_plans_state_result.removed_plans',
        'source_game_loop_check_overlapping_plans_state_result.kept_plans',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2441', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method='Logic.checkOverlappingPlans()', godot_owner=CHECK_OVERLAPPING_PLANS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2441'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
