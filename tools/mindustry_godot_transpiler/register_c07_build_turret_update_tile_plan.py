"""Register the BuildTurret updateTile() plan legs (N2423).

BuildTurretBuild.updateTile()
(BuildTurret.java:121-227) is the build-tower tick. N2184
(136 exprs) folded the power-status row over the whole
method as context; this slice ports the plan search /
follow / mimic / validate advance N2184 deferred -- the
9 distinct exprs that were 0-hit in BOTH ledgers at RED:

- `following = null;` (:147 validate follower, :175
  mimic setup, :218 controlled branch -- one expr,
  three positions, registered once)
- `for(int i = 0; i < blocks.size; i++){` (:158)
- `var block = blocks.get(i);` (:159)
- `var btype = block.block;` (:161)
- `if(Build.validPlace(btype, unit.team(), block.x,
  block.y, block.rotation) &&
  (state.rules.infiniteResources ||
  team.rules().infiniteResources ||
  team.items().has(btype.requirements,
  state.rules.buildCostMultiplier))){` (:163)
- `if(unit.buildPlan() == null){` (:174)
- `if(following  != null) return;` (:177, TWO spaces in
  source)
- `team.data().plans.remove(p -> p.x == req.x &&
  p.y == req.y);` (:198)
- `(req.breaking ?` (:207, fragment of the valid
  ternary :204-211)

Nothing already owned by N2184 is re-registered --
especially the :156 search opener, the :189 validate
opener, :217 `}else{`, the plan-search / mimic /
validate bodies and `unit.updateBuildLogic();`.
Leg-slice inside an already-owned method (the N2397
precedent). One slice entry, one pure function, ONE
owner (SourceBuildTurretBuildState.*, the N2184/N2201
convention for this file -- NOT PortGame.*).

RED decisions (pinned by this slice): (1) The pure
function takes the follower / control / build-plan
observations as explicit bools, the team plan queue as
an Array of plan Dictionaries, and the Build.validPlace
+ infiniteResources/items gate as an explicit Callable
(the N2418 precedent) -- no engine calls. (2) The
`Units.nearby` live query is NOT modeled: the function
only answers whether mimic starts and whether a
candidate's callback returns early; the live query and
the driver call site wait for their own slice. (3)
`timer(timerTarget, targetInterval)` (:156) and
`timer.get(timerTarget2, 30f)` (:193) are caller-side
booleans, not modeled here. (4) `following = null;` is
registered once for all three positions; the GD func
covers all three branches through its params. Slice
source: BuildTurret.java only.
"""
import ast
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
PROOF = '/root/C07BuildTurretUpdateTilePlanProof'
PLAN_OWNER = 'SourceBuildTurretBuildState.source_build_turret_update_tile_plan_state'
TESTS = ['test_c07_build_turret_update_tile_plan_registration', 'test_all_c07_build_turret_update_tile_plan_input_evidence_is_exact', 'test_build_turret_update_tile_plan_state', 'test_reference_graph_and_actual_c07_build_turret_update_tile_plan']
# The 1 slice source the N2423 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
]
EXACT_EXPRS = [
    'following = null;',
    'for(int i = 0; i < blocks.size; i++){',
    'var block = blocks.get(i);',
    'var btype = block.block;',
    'if(Build.validPlace(btype, unit.team(), block.x, block.y, block.rotation) && (state.rules.infiniteResources || team.rules().infiniteResources || team.items().has(btype.requirements, state.rules.buildCostMultiplier))){',
    'if(unit.buildPlan() == null){',
    'if(following  != null) return;',
    'team.data().plans.remove(p -> p.x == req.x && p.y == req.y);',
    '(req.breaking ?',
]

# DEFERRED is carried from the N2184 register script via AST --
# never retyped (the N2201 precedent). The N2184 script's
# DEFERRED is a plain list literal, so ast.literal_eval recovers
# it verbatim. New entries below are the N2423 handoff items:
# the pure plan legs land here, but the live Units.nearby mimic
# query, the driver call site, the timer evaluation and the
# live plans_count stamping still wait for their own slices.
_N2184_REGISTER = Path(__file__).resolve().parent / 'register_c07_build_turret_power_status.py'
_N2184_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2184_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
DEFERRED = list(_N2184_DEFERRED) + [
    'BuildTurret updateTile plan driver wiring -- the N2423 pure function is not yet called by source_build_turret_tick_buildings_state; the driver call site + live plans_count stamping (unit.plans().size, BuildTurret.java:230) + Units.nearby mimic query (BuildTurret.java:176-187) + timer(timerTarget, targetInterval) / timer.get(timerTarget2, 30f) evaluation wait for their own slices.',
    'BuildTurret updateTile plan legs Windows Godot proof -- debt in GOAL.md section 5, same as N2184-N2201: the N2423 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    plan_inputs = {
        'has_following': a('bool', 'if(following != null){', 'Whether a follower is currently set (BuildTurret.java:144, `if(following != null){`): the validate-follower leg only runs with a follower present.'),
        'following_valid': a('bool', 'if(!following.isValid() || !following.activelyBuilding()){', 'Whether the current follower is still valid (BuildTurret.java:146, `if(!following.isValid() || !following.activelyBuilding()){`): an invalid follower is forgotten and the plans are cleared.'),
        'controlled': a('bool', 'following = null;', 'Whether the build is player-controlled (BuildTurret.java:217-218, the controlled branch forgets everything: `following = null;`).'),
        'build_plan_null': a('bool', 'if(unit.buildPlan() == null){', 'Whether the unit has no build plan at mimic time (BuildTurret.java:174, `if(unit.buildPlan() == null){`): the mimic leg only runs with no plan after the search.'),
        'team_plans': a('Array', 'for(int i = 0; i < blocks.size; i++){', 'The team plan queue to search (BuildTurret.java:157-158, `Queue<BlockPlan> blocks = team.data().plans;` / `for(int i = 0; i < blocks.size; i++){`): plan Dictionaries with x, y, rotation, block, config.'),
        'valid_place': a('Callable', 'if(Build.validPlace(btype, unit.team(), block.x, block.y, block.rotation) && (state.rules.infiniteResources || team.rules().infiniteResources || team.items().has(btype.requirements, state.rules.buildCostMultiplier))){', 'Caller-supplied Build.validPlace + infiniteResources/items gate (BuildTurret.java:163): whether a queued plan may be built here.'),
        'req_breaking': a('bool', '(req.breaking ?', 'Whether the request being validated is a break request (BuildTurret.java:207, `(req.breaking ?`): picks the break leg of the valid ternary.'),
        'req_pos': a('Vector2i', 'team.data().plans.remove(p -> p.x == req.x && p.y == req.y);', 'Position of the request being validated (BuildTurret.java:198): the plan removed from the team queue when another player is breaking the same position.'),
        'player_breaking_same_pos': a('bool', 'team.data().plans.remove(p -> p.x == req.x && p.y == req.y);', 'Whether another player is breaking the same position as the request (BuildTurret.java:193-200, the isBuilder samePos breaking discard).'),
        'mimic_following_set': a('bool', 'if(following  != null) return;', 'Whether following is already set when a mimic candidate is considered (BuildTurret.java:177, `if(following  != null) return;`): the Units.nearby callback returns early for later candidates once one became the follower.'),
    }
    plan_outputs = {
        'following_cleared': a('bool', 'following = null;', 'Whether following is cleared (BuildTurret.java:147/:175/:218, `following = null;`): invalid follower, mimic setup, or controlled branch.'),
        'found_plan': a('Dictionary', 'var block = blocks.get(i);', 'The first queued plan the validPlace gate accepts (BuildTurret.java:159, `var block = blocks.get(i);`), or {} when none is valid.'),
        'found_btype': a('String', 'var btype = block.block;', 'The block type of the found plan (BuildTurret.java:161, `var btype = block.block;`), or "" when no plan was found.'),
        'found_index': a('int', 'for(int i = 0; i < blocks.size; i++){', 'Index of the found plan in the team queue (BuildTurret.java:158), or -1 when no plan was found.'),
        'mimic': a('bool', 'if(unit.buildPlan() == null){', 'Whether mimic starts (BuildTurret.java:174, `if(unit.buildPlan() == null){`): still no plan after the search, not controlled.'),
        'mimic_early_return': a('bool', 'if(following  != null) return;', 'Whether a mimic candidate callback returns early (BuildTurret.java:177, `if(following  != null) return;`): mimic is running and following is already set.'),
        'team_plans': a('Array', 'team.data().plans.remove(p -> p.x == req.x && p.y == req.y);', 'The team plan queue after the validate leg (BuildTurret.java:198): the req_pos entry is removed when another player is breaking the same position.'),
        'valid_break_branch': a('bool', '(req.breaking ?', 'Whether the valid ternary takes the break leg (BuildTurret.java:207, `(req.breaking ?`): the request is a break request being validated, not controlled.'),
    }
    return (plan_inputs, plan_outputs)


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
    inputs_outputs = [definitions()]
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
    (plan_inputs, plan_outputs) = definitions()

    entries = [
        ('N2423', PLAN_OWNER, 'source_build_turret_update_tile_plan_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', 'BuildTurretBuild.updateTile()', plan_inputs, plan_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.updateTile() plan legs from BuildTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.updateTile() plan legs from BuildTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: following_cleared, found_plan,
    # found_btype, found_index, mimic, mimic_early_return,
    # team_plans, valid_break_branch.
    by_slice['N2423'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2423', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method='BuildTurretBuild.updateTile()', godot_owner=PLAN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2423'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
