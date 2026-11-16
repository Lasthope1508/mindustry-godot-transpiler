"""Register the RepairTurret drawSelect/drawPlace rows (N2220).

N2212-N2215 made the repair turret live (target acquire, heal
advance, rotation slerp, strength lerp), N2217 persisted its
rotation and N2219 captured the beam state draw() draws each
frame -- but nothing in the port captured what the selection /
placement UI draws: RepairPointBuild.drawSelect() draws one dash
circle around the building (`Drawf.dashCircle(x, y,
repairRadius, Pal.accent);`, RepairTurret.java:178, inside
`public void drawSelect(){`, RepairTurret.java:177) and
RepairTurret.drawPlace() draws the same circle at the ghost
position (`Drawf.dashCircle(x * tilesize + offset, y * tilesize
+ offset, repairRadius, Pal.accent);`,
RepairTurret.java:98, inside `public void drawPlace(int x, int
y, int rotation, boolean valid){`, RepairTurret.java:95, after
`super.drawPlace(x, y, rotation, valid);`,
RepairTurret.java:96).

RED decisions (resolved at RED): (1) Two pure functions on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217 /
N2219 built, returning the deterministic dash-circle state:
center, radius, color. Rendering itself stays out of the game --
only the state the circle depends on is captured, per the user
boundary. (2) The radius is the per-def repairRadius --
repair-point 60f (Blocks.java:6389), repair-turret 145f
(Blocks.java:6401), class default 50f (`public float
repairRadius = 50f;`, RepairTurret.java:32) -- resolved by the
caller through the existing _repair_radius_for_block_id helper
(N2212). (3) The place center converts tile coords to world
coords with the tilesize and the block offset (`x * tilesize +
offset`, RepairTurret.java:98; tilesize 8, Vars.java:135;
offset `((size + 1) % 2) * tilesize / 2f`, Block.java:761 --
repair-point size 1, no size override in Blocks.java:6386, so
0.0; repair-turret size 2, Blocks.java:6398, so 4.0), resolved
by the new _block_offset_for_block_id helper. (4) The color is
Pal.accent in both call sites, represented as the string
"Pal.accent" (the SourceBlockDrawState.gd:182 precedent). (5)
There is NO driver tick line: drawSelect / drawPlace are
selection / placement UI, not per-tick -- the functions are
called from the selection / placement code, not from the frame
loop. (6) The drawPlace super call (`super.drawPlace(x, y,
rotation, valid);`, RepairTurret.java:96) draws the block
itself, not the circle -- out of scope for this slice. Six new
result symbols: select center / radius / color, place center /
radius / color. Single slice source: RepairTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_draw_beam import DEFERRED as N2219_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
PROOF = '/root/C07RepairTurretDrawSelectPlaceProof'
SELECT_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_draw_select_state'
PLACE_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_draw_place_state'
TESTS = ['test_c07_repair_turret_draw_select_place_registration', 'test_all_c07_repair_turret_draw_select_place_input_evidence_is_exact', 'test_repair_turret_draw_select_place_state', 'test_reference_graph_and_actual_c07_repair_turret_draw_select_place']
# The 1 slice source the N2220 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
]
EXACT_EXPRS = ['public void drawSelect(){', 'Drawf.dashCircle(x, y, repairRadius, Pal.accent);', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'super.drawPlace(x, y, rotation, valid);', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'public float repairRadius = 50f;', 'repairRadius / tilesize']

# DEFERRED is carried from the N2219 register script via import --
# never retyped. The N2219 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2217 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2220's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
# NOTE: the N2219 pool entry claiming the drawSelect / drawPlace
# dash circles "are selection/placement rendering, not the beam --
# wait for their own slice" is SUPERSEDED by this slice -- the
# dash-circle state now has frame-independent result symbols
# (select/place center / radius / color). The pool is cumulative
# history, so the old entry stays; the new entries below pin what
# is still deferred.
DEFERRED = list(N2219_DEFERRED) + [
    'RepairTurret shouldAmbientSound (RepairTurret.java:181-184, `return target != null && efficiency > 0f;`) -- the ambient-sound gate for the repair turret -- waits for its own slice.',
    'RepairTurret status() (RepairTurret.java:225-228, `return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();`) -- the noInput status gate -- waits for its own slice.',
    'RepairTurret drawSelect/drawPlace Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2219: the N2220 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    select_inputs = {
        'x': a('float', 'Drawf.dashCircle(x, y, repairRadius, Pal.accent);', 'The building world x (RepairTurret.java:178, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`): the dash circle is centered on the building position.'),
        'y': a('float', 'Drawf.dashCircle(x, y, repairRadius, Pal.accent);', 'The building world y (RepairTurret.java:178, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`): the dash circle is centered on the building position.'),
        'repair_radius': a('float', 'public float repairRadius = 50f;', 'The dash-circle radius (RepairTurret.java:178, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`): the per-def repairRadius -- repair-point 60f (Blocks.java:6389), repair-turret 145f (Blocks.java:6401), class default 50f (`public float repairRadius = 50f;`, RepairTurret.java:32) -- resolved by the caller through the existing _repair_radius_for_block_id helper (N2212).'),
    }
    select_outputs = {
        'center': a('Vector2', 'Drawf.dashCircle(x, y, repairRadius, Pal.accent);', 'The dash-circle center (RepairTurret.java:178, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`): the building position itself.'),
        'radius': a('float', 'public float repairRadius = 50f;', 'The dash-circle radius (RepairTurret.java:178, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`): the per-def repairRadius passed in.'),
        'color': a('String', 'Drawf.dashCircle(x, y, repairRadius, Pal.accent);', 'The dash-circle color (RepairTurret.java:178, `Drawf.dashCircle(x, y, repairRadius, Pal.accent);`): Pal.accent, represented as the string "Pal.accent" (the SourceBlockDrawState.gd:182 precedent).'),
    }
    place_inputs = {
        'tile_x': a('int', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'The placement tile x (RepairTurret.java:98, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`): the ghost circle center converts the tile coord to world coords with the tilesize and the block offset.'),
        'tile_y': a('int', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'The placement tile y (RepairTurret.java:98, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`): the ghost circle center converts the tile coord to world coords with the tilesize and the block offset.'),
        'repair_radius': a('float', 'public float repairRadius = 50f;', 'The dash-circle radius (RepairTurret.java:98, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`): the per-def repairRadius -- repair-point 60f (Blocks.java:6389), repair-turret 145f (Blocks.java:6401), class default 50f (`public float repairRadius = 50f;`, RepairTurret.java:32) -- resolved by the caller through the existing _repair_radius_for_block_id helper (N2212).'),
        'tilesize': a('float', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'The world-units-per-tile factor (RepairTurret.java:98, `x * tilesize + offset`): Vars.tilesize is 8 (Vars.java:135); the port passes it explicitly (the SourceTurretPlacementState.draw_place_state precedent).'),
        'block_offset': a('float', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'The block placement offset (RepairTurret.java:98, `x * tilesize + offset`): Block.offset is `((size + 1) % 2) * tilesize / 2f` (Block.java:761) -- repair-point size 1, no size override in Blocks.java:6386, so 0.0; repair-turret size 2, Blocks.java:6398, so 4.0 -- resolved by the new _block_offset_for_block_id helper.'),
    }
    place_outputs = {
        'center': a('Vector2', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'The ghost dash-circle center (RepairTurret.java:98, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`): tile_x * tilesize + block_offset, tile_y * tilesize + block_offset.'),
        'radius': a('float', 'public float repairRadius = 50f;', 'The ghost dash-circle radius (RepairTurret.java:98, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`): the per-def repairRadius passed in.'),
        'color': a('String', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', 'The ghost dash-circle color (RepairTurret.java:98, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`): Pal.accent, represented as the string "Pal.accent" (the SourceBlockDrawState.gd:182 precedent).'),
    }
    return select_inputs, select_outputs, place_inputs, place_outputs


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
    select_inputs, select_outputs, place_inputs, place_outputs = definitions()

    entries = [
        ('N2220', SELECT_OWNER, 'source_repair_turret_draw_select_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.drawSelect()', select_inputs, select_outputs, True, 'Dictionary'),
        ('N2220', PLACE_OWNER, 'source_repair_turret_draw_place_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret', 'RepairTurret.drawPlace()', place_inputs, place_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret drawSelect/drawPlace range state from RepairTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret drawSelect/drawPlace range state from RepairTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: select center / radius / color,
    # place center / radius / color.
    by_slice['N2220'] = [
        'source_repair_turret_draw_select_state_result.center',
        'source_repair_turret_draw_select_state_result.radius',
        'source_repair_turret_draw_select_state_result.color',
        'source_repair_turret_draw_place_state_result.center',
        'source_repair_turret_draw_place_state_result.radius',
        'source_repair_turret_draw_place_state_result.color',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2220', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.drawSelect()/RepairTurret.drawPlace()', godot_owner=SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2220'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
