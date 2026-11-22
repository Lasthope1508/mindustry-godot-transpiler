"""Register the LiquidTurretBuild.findTarget() extinguish-scan loop (N2408).

LiquidTurretBuild.findTarget() (LiquidTurret.java:91-117,
`protected void findTarget(){`) scans the tiles around the
turret for the nearest extinguishable fire when the
extinguish guard holds. This slice owns ONLY the 12 loop
exprs (:93-104 + :105-106 + :111 in scan order):
`int tx = World.toTile(x), ty = World.toTile(y);` (:94),
`float mindst = 0f;` (:96),
`int tr = (int)(range / tilesize);` (:97),
`for(int x = -tr; x <= tr; x++){` (:98),
`for(int y = -tr; y <= tr; y++){` (:99),
`Tile other = world.tile(x + tx, y + ty);` (:100),
`var fire = Fires.get(x + tx, y + ty);` (:101),
`float dst = fire == null ? 0 : dst2(fire);` (:102),
`if(other != null && fire != null && other.build != this
&& Fires.has(other.x, other.y) && dst <= range * range
&& (result == null || dst < mindst) && (other.build ==
null || other.team() == team)){` (:104),
`result = fire;` (:105), `mindst = dst;` (:106),
`if(result != null){` (:111). The shell is NOT in this
slice and is never re-registered: `protected void
findTarget(){` (:92), `if(extinguish &&
liquids.current().canExtinguish()){` (:93),
`Fire result = null;` (:95), `target = result;` (:112),
`return;` (:114) and `super.findTarget();` (:117) are
already the exact_exprs of N1200 (plus the class decl
and @Override); the signature line also hits local
N2316 (TurretBuild.findTarget) and is not registered
here either. The `if(result != null){` tail
(`target = result;` + `return;`) stays N1200-owned --
this slice only computes the scan result (fire_result
+ mindst + result_found).

Two upstream facts verified against the real sources:
World.toTile is Math.round(coord / tilesize)
(World.java:174-176), implemented in GD as
int(floor(v / tilesize + 0.5)) -- Java Math.round
semantics, not GDScript roundi() (they differ on
negative halves). Fires.has is stricter than
`fire != null` (Fires.java: `has` also requires the
fire added, unfinished, and on exactly that tile), so
it stays its own Callable instead of being folded
into fires_get. `world.tile` returns tiles.get, null
out of bounds (World.java:122).

One GD function on SourceLiquidTurretBuildState.gd
next to the N1200 shell (`find_target_extinguish_state`).
All live values arrive as explicit params (the N2188
precedent): the build coords/range/tilesize/team, the
live build identity (`this`), and the world queries
as Callables (the N2395 derelict / N2316 observed-dict
precedent -- the live world/Fires queries stay on the
driver side). `range` is named `scan_range` in GD
because `range` shadows GDScript's builtin `range()`
used by the loop. The tile Dictionary shape is
{"build": Variant, "build_team": Variant} (build is
the live build object or null; build_team is that
build's team, null when there is no build). The scan
never writes the frame and never assigns the target
-- the driver (N1200 shell) consumes fire_result
when result_found is true. Twelve new result symbols:
the scan result plus the origin/radius and the
scalar echoes. One slice source: LiquidTurret.java
only. This slice CLOSES the N1200 deferred scan item
(see DEFERRED).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_liquid_turret_default_constructor import DEFERRED as N2406_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LIQUID_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java'
PROOF = '/root/C07LiquidTurretFindTargetScanProof'
SCAN_OWNER = 'SourceLiquidTurretBuildState.source_liquid_turret_find_target_scan_state'
TESTS = ['test_c07_liquid_turret_find_target_scan_registration', 'test_all_c07_liquid_turret_find_target_scan_input_evidence_is_exact', 'test_liquid_turret_find_target_scan_state', 'test_reference_graph_and_actual_c07_liquid_turret_find_target_scan']
# The 1 slice source the N2408 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java',
]
EXACT_EXPRS = [
    'int tx = World.toTile(x), ty = World.toTile(y);',
    'float mindst = 0f;',
    'int tr = (int)(range / tilesize);',
    'for(int x = -tr; x <= tr; x++){',
    'for(int y = -tr; y <= tr; y++){',
    'Tile other = world.tile(x + tx, y + ty);',
    'var fire = Fires.get(x + tx, y + ty);',
    'float dst = fire == null ? 0 : dst2(fire);',
    'if(other != null && fire != null && other.build != this && Fires.has(other.x, other.y) && dst <= range * range && (result == null || dst < mindst) && (other.build == null || other.team() == team)){',
    'result = fire;',
    'mindst = dst;',
    'if(result != null){',
]

# DEFERRED is carried from the N2406 register script via import --
# never retyped. Three entries are added: the N2408 Windows Godot
# proof debt (GOAL.md section 5), the note that this slice closes
# the N1200 deferred scan item, and the driver wiring (the scan
# must be called from the N1200 extinguish guard; the target
# assignment + early return stay N1200-owned).
DEFERRED = list(N2406_DEFERRED) + [
    'LiquidTurretBuild.findTarget() extinguish-scan loop Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2408 proof runs headless on Linux here and waits for a Windows Godot run.',
    'LiquidTurretBuild.findTarget() fire scan (LiquidTurret.java:93-111) -- CLOSED by N2408: the N1200 deferred entry ("Fire scan tile iteration, distance comparison, team checks, and mindst updates stay deferred; this slice records extinguish gate and target/super dispatch using explicit fire_result.") is now this slice.',
    'Wire the LiquidTurretBuild.findTarget() extinguish-scan driver: the N1200 shell (find_target_extinguish_state, should_scan_fires) must call source_liquid_turret_find_target_scan_state when the extinguish guard holds and take fire_result as its fire_result; the target assignment + early return stay N1200-owned.',
]


def definitions():
    def a(typ, expr, rule, source=LIQUID_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    scan_condition = 'if(other != null && fire != null && other.build != this && Fires.has(other.x, other.y) && dst <= range * range && (result == null || dst < mindst) && (other.build == null || other.team() == team)){'
    scan_inputs = {
        'build_x': a('float', 'int tx = World.toTile(x), ty = World.toTile(y);', 'The build world x in pixels (LiquidTurret.java:94, `int tx = World.toTile(x), ty = World.toTile(y);`): World.toTile(x) rounds x / tilesize (World.java:174-176, Math.round) -- the GD function computes tx with Java Math.round semantics, int(floor(v / tilesize + 0.5)).'),
        'build_y': a('float', 'int tx = World.toTile(x), ty = World.toTile(y);', 'The build world y in pixels (LiquidTurret.java:94, `int tx = World.toTile(x), ty = World.toTile(y);`): World.toTile(y) rounds y / tilesize (World.java:174-176, Math.round) -- the GD function computes ty with Java Math.round semantics, int(floor(v / tilesize + 0.5)).'),
        'scan_range': a('float', 'int tr = (int)(range / tilesize);', 'The targeting range in world pixels (LiquidTurret.java:97, `int tr = (int)(range / tilesize);`): TurretBuild.range(); the GD param is named scan_range because `range` shadows GDScript\'s builtin range() used by the scan loop; the scan compares squared distances against scan_range * scan_range.'),
        'tilesize': a('float', 'int tr = (int)(range / tilesize);', 'The tile size in world pixels (LiquidTurret.java:97, `int tr = (int)(range / tilesize);`): Vars.tilesize (8), always positive; it converts the build coords to tile coords and the range to the scan radius tr.'),
        'team': a('Variant', scan_condition, 'The build team (LiquidTurret.java:104, the `(other.build == null || other.team() == team)` leg of the scan condition): a fire on a built tile counts only when that build is on this team; the team arrives as an explicit Variant param, never hard-coded.'),
        'self_build': a('Variant', scan_condition, 'This build (LiquidTurret.java:104, the `other.build != this` leg of the scan condition): the live build object; a fire on the turret\'s own tile is excluded -- it arrives as an explicit Variant param so the pure function compares tile builds by identity.'),
        'world_tile': a('Callable', 'Tile other = world.tile(x + tx, y + ty);', 'The world tile lookup (LiquidTurret.java:100, `Tile other = world.tile(x + tx, y + ty);`): world.tile returns tiles.get, null out of bounds (World.java:122) -- it arrives as a Callable (tile_x, tile_y) returning a tile Dictionary {"build": Variant, "build_team": Variant} or null; the live world query stays on the driver side.'),
        'fires_get': a('Callable', 'var fire = Fires.get(x + tx, y + ty);', 'The fire lookup (LiquidTurret.java:101, `var fire = Fires.get(x + tx, y + ty);`): Fires.get returns the fire at the tile or null (also null out of bounds) -- it arrives as a Callable (tile_x, tile_y) returning a fire Dictionary or null; the live Fires query stays on the driver side.'),
        'fires_has': a('Callable', scan_condition, 'The Fires.has check (LiquidTurret.java:104, the `Fires.has(other.x, other.y)` leg of the scan condition): Fires.has is stricter than `fire != null` -- the fire must be added, unfinished, and on exactly that tile -- so it stays its own Callable (tile_x, tile_y) returning a bool; the live Fires query stays on the driver side.'),
        'dst2': a('Callable', 'float dst = fire == null ? 0 : dst2(fire);', 'The squared-distance hook (LiquidTurret.java:102, `float dst = fire == null ? 0 : dst2(fire);`): the squared distance from this build to the fire (0 when there is no fire) -- it arrives as a Callable (fire) returning a float; the live position read stays on the driver side.'),
    }
    scan_outputs = {
        'fire_result': a('Variant', 'result = fire;', 'The chosen fire, or null: the nearest valid fire found by the scan (LiquidTurret.java:105, `result = fire;`); the driver (N1200 shell) assigns it to target when result_found is true.'),
        'mindst': a('float', 'mindst = dst;', 'The smallest squared distance seen (LiquidTurret.java:106, `mindst = dst;`): starts 0f and tracks the winning fire\'s dst -- the first valid candidate is accepted while result is null, then only a strictly nearer fire replaces it.'),
        'result_found': a('bool', 'if(result != null){', 'Whether the scan found a fire (LiquidTurret.java:111, `if(result != null){`): true exactly when fire_result is not null; the `target = result;` + `return;` body of that if stays N1200-owned.'),
        'tile_x': a('int', 'int tx = World.toTile(x), ty = World.toTile(y);', 'The scan origin tile x (LiquidTurret.java:94, `int tx = World.toTile(x), ty = World.toTile(y);`): World.toTile(build_x), Java Math.round semantics.'),
        'tile_y': a('int', 'int tx = World.toTile(x), ty = World.toTile(y);', 'The scan origin tile y (LiquidTurret.java:94, `int tx = World.toTile(x), ty = World.toTile(y);`): World.toTile(build_y), Java Math.round semantics.'),
        'scan_radius': a('int', 'int tr = (int)(range / tilesize);', 'The scan radius in tiles (LiquidTurret.java:97, `int tr = (int)(range / tilesize);`): the loop runs offsets -tr..tr on both axes.'),
        'build_x': a('float', 'int tx = World.toTile(x), ty = World.toTile(y);', 'The build world x, read through (LiquidTurret.java:94, `int tx = World.toTile(x), ty = World.toTile(y);`): the explicit build_x param, echoed so the proof can pin the scan origin.'),
        'build_y': a('float', 'int tx = World.toTile(x), ty = World.toTile(y);', 'The build world y, read through (LiquidTurret.java:94, `int tx = World.toTile(x), ty = World.toTile(y);`): the explicit build_y param, echoed so the proof can pin the scan origin.'),
        'scan_range': a('float', 'int tr = (int)(range / tilesize);', 'The targeting range, read through (LiquidTurret.java:97, `int tr = (int)(range / tilesize);`): the explicit scan_range param, echoed so the proof can pin the scan radius.'),
        'tilesize': a('float', 'int tr = (int)(range / tilesize);', 'The tile size, read through (LiquidTurret.java:97, `int tr = (int)(range / tilesize);`): the explicit tilesize param, echoed so the proof can pin the scan origin.'),
        'team': a('Variant', scan_condition, 'The build team, read through (LiquidTurret.java:104, the scan condition): the explicit team param, echoed so the proof can pin the team filter.'),
        'self_build': a('Variant', scan_condition, 'This build, read through (LiquidTurret.java:104, the scan condition): the explicit self_build param, echoed so the proof can pin the identity filter.'),
    }
    return scan_inputs, scan_outputs


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
    scan_inputs, scan_outputs = definitions()

    entries = [
        ('N2408', SCAN_OWNER, 'source_liquid_turret_find_target_scan_state', LIQUID_TURRET, 'mindustry.world.blocks.defense.turrets.LiquidTurret.LiquidTurretBuild', 'LiquidTurretBuild.findTarget()', scan_inputs, scan_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LiquidTurretBuild.findTarget() extinguish-scan loop state from LiquidTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LiquidTurretBuild.findTarget() extinguish-scan loop state from LiquidTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the scan result first, then
    # the origin/radius, then the scalar echoes.
    by_slice['N2408'] = [
        'source_liquid_turret_find_target_scan_state_result.fire_result',
        'source_liquid_turret_find_target_scan_state_result.mindst',
        'source_liquid_turret_find_target_scan_state_result.result_found',
        'source_liquid_turret_find_target_scan_state_result.tile_x',
        'source_liquid_turret_find_target_scan_state_result.tile_y',
        'source_liquid_turret_find_target_scan_state_result.scan_radius',
        'source_liquid_turret_find_target_scan_state_result.build_x',
        'source_liquid_turret_find_target_scan_state_result.build_y',
        'source_liquid_turret_find_target_scan_state_result.scan_range',
        'source_liquid_turret_find_target_scan_state_result.tilesize',
        'source_liquid_turret_find_target_scan_state_result.team',
        'source_liquid_turret_find_target_scan_state_result.self_build',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2408', dict(status='done', java_source=LIQUID_TURRET, java_class='mindustry.world.blocks.defense.turrets.LiquidTurret.LiquidTurretBuild', java_method='LiquidTurretBuild.findTarget()', godot_owner=SCAN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2408'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
