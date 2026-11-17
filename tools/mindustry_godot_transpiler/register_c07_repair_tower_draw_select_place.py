"""Register the RepairTower drawSelect/drawPlace rows (N2231).

N2190 / N2191 / N2211 / N2228 / N2229 made the repair tower
live (refresh, should-consume, nearby driver, heal advance,
ozone consumer) and N2230 captured its setStats rows -- but
nothing in the port captured what the selection / placement
UI draws: RepairTowerBuild.drawSelect() draws one dash circle
around the building (`Drawf.dashCircle(x, y, range,
Pal.placing);`, RepairTower.java:123, inside `public void
drawSelect(){`, RepairTower.java:122) and
RepairTower.drawPlace() draws the same circle at the ghost
position (`Drawf.dashCircle(x * tilesize + offset, y *
tilesize + offset, range, Pal.placing);`,
RepairTower.java:47, inside `public void drawPlace(int x,
int y, int rotation, boolean valid){`,
RepairTower.java:44, after `super.drawPlace(x, y, rotation,
valid);`, RepairTower.java:45).

RED decisions (resolved at RED): (1) Two pure functions on
the same family file N2190 / N2191 / N2211 / N2228 / N2229 /
N2230 built, returning the deterministic dash-circle state:
center, radius, color. Rendering itself stays out of the
game -- only the state the circle depends on is captured, per
the user boundary. (2) The radius is the per-def range --
unit-repair-tower 100f (Blocks.java:6579), class default 80f
(`public float range = 80f;`, RepairTower.java:21) -- passed
as an explicit param (the N2220 / N2230 per-def-param
precedent; single def, so no _range_for_block_id helper).
(3) The place center converts tile coords to world coords
with the tilesize and the block offset (`x * tilesize +
offset`, RepairTower.java:47; tilesize 8, Vars.java:135;
offset `((size + 1) % 2) * tilesize / 2f`, Block.java:761 --
unit-repair-tower size 2, Blocks.java:6578, so 4.0), passed
as explicit params (the N2220 draw-place precedent; single
def, so no _block_offset_for_block_id helper). (4) The color
is Pal.placing in both call sites, represented as the string
"Pal.placing" (the SourceBaseTurretDrawState.gd:25 /
SourceTurretPlacementState.gd:35 precedent). (5) There is NO
driver tick line: drawSelect / drawPlace are selection /
placement UI, not per-tick -- the functions are called from
the selection / placement code, not from the frame loop; the
proof's no_driver_tick_line key reads the state script
source and greps the driver body -- a runtime check, not a
hardcoded true. (6) The drawPlace super call
(`super.drawPlace(x, y, rotation, valid);`,
RepairTower.java:45) draws the block itself, not the circle
-- out of scope for this slice. Six new result symbols:
select center / radius / color, place center / radius /
color. SSOT expected after GREEN: symbols +6, Done +1,
contracts +2, schema +4, 11498/1680/1607/3005 ->
11504/1681/1609/3009. Slice sources: RepairTower.java +
Vars.java + Blocks.java. No shard change: the java_source IS
RepairTower.java (the N2230 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_tower_set_stats import DEFERRED as N2230_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTowerDrawSelectPlaceProof'
SELECT_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_draw_select_state'
PLACE_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_draw_place_state'
TESTS = ['test_c07_repair_tower_draw_select_place_registration', 'test_all_c07_repair_tower_draw_select_place_input_evidence_is_exact', 'test_repair_tower_draw_select_place_state', 'test_reference_graph_and_actual_c07_repair_tower_draw_select_place']
# The 3 slice sources the N2231 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void drawSelect(){', 'Drawf.dashCircle(x, y, range, Pal.placing);', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'super.drawPlace(x, y, rotation, valid);', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'public float range = 80f;', 'range = 100f;', 'public static final int tilesize = 8;', 'public class RepairTower extends Block{', 'range / tilesize']

# DEFERRED is carried from the N2230 register script via import --
# never retyped. The lumped draw-family entry that N2230 wrote
# (draw / drawSelect / drawPlace / range / warmup) is DROPPED
# here -- this slice closes drawSelect()/drawPlace() -- and
# replaced by the new entries below, which keep the draw() /
# range() / warmup() deferral record with its line refs; every
# other entry is carried verbatim (the N2211/N2228 lesson --
# never retype the pool). The filter drops only entries
# mentioning BOTH RepairTower and drawSelect, so the other
# RepairTower deferrals (suppression, targets) and the other
# families' drawSelect/drawPlace entries survive untouched.
DEFERRED = [e for e in N2230_DEFERRED if not ('RepairTower' in e and 'drawSelect' in e)] + [
    'RepairTower draw() / range() / warmup() rows (draw circle/glow, RepairTower.java:94-110; range() returns range, RepairTower.java:112-114; warmup() returns warmup, RepairTower.java:117-119) -- drawSelect()/drawPlace() are DONE at N2231; the draw()/range()/warmup() rows still wait for their own slices.',
    'RepairTower drawSelect/drawPlace Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2230: the N2231 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    select_inputs = {
        'x': a('float', 'Drawf.dashCircle(x, y, range, Pal.placing);', 'The building world x (RepairTower.java:123, `Drawf.dashCircle(x, y, range, Pal.placing);`): the dash circle is centered on the building position.'),
        'y': a('float', 'Drawf.dashCircle(x, y, range, Pal.placing);', 'The building world y (RepairTower.java:123, `Drawf.dashCircle(x, y, range, Pal.placing);`): the dash circle is centered on the building position.'),
        'range': a('float', 'public float range = 80f;', 'The dash-circle radius (RepairTower.java:123, `Drawf.dashCircle(x, y, range, Pal.placing);`): the per-def range -- unit-repair-tower 100f (Blocks.java:6579), class default 80f (`public float range = 80f;`, RepairTower.java:21) -- passed explicitly because it is per-def static state, not a live frame key (the N2220 / N2230 per-def-param precedent).'),
    }
    select_outputs = {
        'center': a('Vector2', 'Drawf.dashCircle(x, y, range, Pal.placing);', 'The dash-circle center (RepairTower.java:123, `Drawf.dashCircle(x, y, range, Pal.placing);`): the building position itself.'),
        'radius': a('float', 'public float range = 80f;', 'The dash-circle radius (RepairTower.java:123, `Drawf.dashCircle(x, y, range, Pal.placing);`): the per-def range passed in.'),
        'color': a('String', 'Drawf.dashCircle(x, y, range, Pal.placing);', 'The dash-circle color (RepairTower.java:123, `Drawf.dashCircle(x, y, range, Pal.placing);`): Pal.placing, represented as the string "Pal.placing" (the SourceBaseTurretDrawState.gd:25 / SourceTurretPlacementState.gd:35 precedent).'),
    }
    place_inputs = {
        'tile_x': a('int', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'The placement tile x (RepairTower.java:47, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`): the ghost circle center converts the tile coord to world coords with the tilesize and the block offset.'),
        'tile_y': a('int', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'The placement tile y (RepairTower.java:47, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`): the ghost circle center converts the tile coord to world coords with the tilesize and the block offset.'),
        'range': a('float', 'public float range = 80f;', 'The dash-circle radius (RepairTower.java:47, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`): the per-def range -- unit-repair-tower 100f (Blocks.java:6579), class default 80f (`public float range = 80f;`, RepairTower.java:21) -- passed explicitly because it is per-def static state, not a live frame key.'),
        'tilesize': a('float', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'The world-units-per-tile factor (RepairTower.java:47, `x * tilesize + offset`): Vars.tilesize is 8 (Vars.java:135); the port passes it explicitly (the SourceTurretPlacementState.draw_place_state precedent).'),
        'block_offset': a('float', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'The block placement offset (RepairTower.java:47, `x * tilesize + offset`): Block.offset is `((size + 1) % 2) * tilesize / 2f` (Block.java:761) -- unit-repair-tower size 2, Blocks.java:6578, so 4.0 -- passed explicitly (the N2220 draw-place precedent; single def, so no helper).'),
    }
    place_outputs = {
        'center': a('Vector2', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'The ghost dash-circle center (RepairTower.java:47, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`): tile_x * tilesize + block_offset, tile_y * tilesize + block_offset.'),
        'radius': a('float', 'public float range = 80f;', 'The ghost dash-circle radius (RepairTower.java:47, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`): the per-def range passed in.'),
        'color': a('String', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', 'The ghost dash-circle color (RepairTower.java:47, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`): Pal.placing, represented as the string "Pal.placing" (the SourceBaseTurretDrawState.gd:25 / SourceTurretPlacementState.gd:35 precedent).'),
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
        ('N2231', SELECT_OWNER, 'source_repair_tower_draw_select_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.drawSelect()', select_inputs, select_outputs, True, 'Dictionary'),
        ('N2231', PLACE_OWNER, 'source_repair_tower_draw_place_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower', 'RepairTower.drawPlace()', place_inputs, place_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower drawSelect/drawPlace range state from RepairTower.java + Vars.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower drawSelect/drawPlace range state from RepairTower.java + Vars.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: select center / radius / color,
    # place center / radius / color.
    by_slice['N2231'] = [
        'source_repair_tower_draw_select_state_result.center',
        'source_repair_tower_draw_select_state_result.radius',
        'source_repair_tower_draw_select_state_result.color',
        'source_repair_tower_draw_place_state_result.center',
        'source_repair_tower_draw_place_state_result.radius',
        'source_repair_tower_draw_place_state_result.color',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2231', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTowerBuild.drawSelect()/RepairTower.drawPlace()', godot_owner=SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2231'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
