"""Register the RepairTurret draw() body (N2225).

RepairPointBuild.draw() (RepairTurret.java:164-174, `public
void draw(){`) draws the base rect at (x, y) with no rotation
(`Draw.rect(baseRegion, x, y);` -- RepairTurret.java:165),
sets the z-layer (`Draw.z(Layer.turret);` -- :167,
Layer.turret = 50, Layer.java:48), draws the shadow and the
region rect at rotation - 90 (`Drawf.shadow(region,
x - (size / 2f), y - (size / 2f), rotation - 90);` -- :168 --
and `Draw.rect(region, x, y, rotation - 90);` -- :169), then
calls drawBeam (:171-173). The drawBeam call leg is N2219
(`source_repair_turret_draw_beam_state`), NOT this slice.
The shadow overload is Drawf.shadow (Drawf.java:366,
`public static void shadow(TextureRegion region, float x,
float y, float rotation){`).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2174 / N2188 / N2209 / N2212-N2215 /
N2217 / N2219-N2224 built:
source_repair_turret_draw_state(x, y, rotation, size)
returning draw_rotation (rotation - 90), shadow_position
(x - size / 2f, y - size / 2f), base_position (x, y) and
z_layer (50.0, Layer.turret). All four params are explicit
floats (the N2220 draw-place / N2223 sense per-def-param
precedent for size, and the draw_select precedent for x / y /
rotation passed explicitly: rotation defaults to 90, the
field init `public float strength, rotation = 90;`,
RepairTurret.java:156; size is Block.size in tiles, class
default 1, Block.java:215, `public int size = 1;`,
repair-point has no override, Blocks.java:6386-6394,
repair-turret 2, Blocks.java:6398, `size = 2;`). The shadow
offset quirk stays as Java wrote it: `size / 2f` is
subtracted directly on world coords, NOT tilesize-scaled.
(2) There IS a driver tick line, unlike N2220
(drawSelect/drawPlace -- UI, no tick line) and N2224 (stat
display, no tick line): draw() runs every frame after
updateTile in the frame loop, and the driver already calls
draw_beam_state each tick
(SourceRepairTurretBuildState.gd:664), so N2225 adds one
draw_state call there, stamping draw_rotation,
shadow_position, base_position and z_layer live. Rendering
itself stays out of the game -- only the state draw()
depends on is captured, per the user boundary. (3) The
drawBeam(x, y, rotation, length, id, target, team, strength,
...) call leg (RepairTurret.java:171-173) is N2219's
`source_repair_turret_draw_beam_state`, NOT re-emitted here.
Four new result symbols: draw_rotation, shadow_position,
base_position, z_layer. Slice sources: RepairTurret.java +
Layer.java + Drawf.java + Blocks.java + Block.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_set_stats import DEFERRED as N2224_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
LAYER = 'core/src/mindustry/graphics/Layer.java'
DRAWF = 'core/src/mindustry/graphics/Drawf.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretDrawProof'
DRAW_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_draw_state'
TESTS = ['test_c07_repair_turret_draw_registration', 'test_all_c07_repair_turret_draw_input_evidence_is_exact', 'test_repair_turret_draw_state', 'test_reference_graph_and_actual_c07_repair_turret_draw']
# The 5 slice sources the N2225 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/graphics/Layer.java',
    'core/src/mindustry/graphics/Drawf.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['public void draw(){', 'Draw.rect(baseRegion, x, y);', 'Draw.z(Layer.turret);', 'Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);', 'Draw.rect(region, x, y, rotation - 90);', 'public float strength, rotation = 90;', 'turret = 50,', 'public static void shadow(TextureRegion region, float x, float y, float rotation){', 'size = 2;', 'public int size = 1;', 'public class RepairTurret extends Block{']

# DEFERRED is carried from the N2224 register script via import --
# never retyped. The N2224 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2223 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2225's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
# One carried entry is DROPPED here, not carried: the N2224
# entry deferring the RepairPointBuild.draw() body to "its own
# slice" -- N2225 IS that slice, so carrying it would leave a
# stale "waits for its own slice" row for done work. Every other
# carried entry still waits for its own slice.
DEFERRED = [e for e in N2224_DEFERRED if 'RepairPointBuild.draw() body' not in e] + [
    'RepairTurret draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2224: the N2225 proof runs headless on Linux here and waits for a Windows Godot run.',
    'RepairTurret init() updateClipRadius -- updateClipRadius(repairRadius + tilesize) (RepairTurret.java:90); clip_radius = repairRadius + tilesize -> class default 58.0, repair-point 68.0, repair-turret 153.0 (tilesize 8, Vars.java:135); the N1234 TractorBeamTurret.init() precedent pins only the call argument; waits for its own slice (N2226).',
    'RepairTurret icons() -- return new TextureRegion[]{baseRegion, region}; (RepairTurret.java:102-103); the N1232 TractorBeamTurret.icons() precedent pins it as an identity pure function (source_tractor_beam_turret_icons_state); lowest value of the three remaining candidates, waits for its own slice (N2227).',
    'RepairTurret drawBeam() jitter/pulse -- Rand + Time.time modeling (RepairTurret.java:121-125, :129-145); N2219 returns the PRE-JITTER endpoint and N2225 takes only the deterministic draw() body; the jitter/pulse phase is still deferred.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'x': a('float', 'Draw.rect(baseRegion, x, y);', 'The live world x of the building in pixels (RepairTurret.java:165, `Draw.rect(baseRegion, x, y);`, the base rect is drawn at (x, y) with no rotation); passed explicitly (the N2220 draw-place precedent) because the pure function takes the position as args, not a frame.'),
        'y': a('float', 'Draw.rect(baseRegion, x, y);', 'The live world y of the building in pixels (RepairTurret.java:165, `Draw.rect(baseRegion, x, y);`, same line as x); passed explicitly, same precedent as x.'),
        'rotation': a('float', 'public float strength, rotation = 90;', 'The live rotation in degrees (RepairTurret.java:156, `public float strength, rotation = 90;`, the field init; stamped live by the N2214 slerp and persisted by the N2217 read/write); passed explicitly because the draw angle is rotation - 90.'),
        'size': a('float', 'public int size = 1;', 'The Block.size in tiles (Block.java:215, `public int size = 1;`, the class default; repair-point has no override, Blocks.java:6386-6394, repair-turret 2, Blocks.java:6398, `size = 2;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=BLOCK),
    }
    draw_outputs = {
        'draw_rotation': a('float', 'Draw.rect(region, x, y, rotation - 90);', 'The region rect angle in degrees: rotation - 90 (RepairTurret.java:169, `Draw.rect(region, x, y, rotation - 90);`, the same angle the shadow uses at :168).'),
        'shadow_position': a('float', 'Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);', 'The shadow position: (x - size / 2f, y - size / 2f) (RepairTurret.java:168, `Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);`); size / 2f is subtracted directly on world coords, NOT tilesize-scaled -- the quirk stays as Java wrote it.'),
        'base_position': a('float', 'Draw.rect(baseRegion, x, y);', 'The base rect position: (x, y) with no rotation (RepairTurret.java:165, `Draw.rect(baseRegion, x, y);`).'),
        'z_layer': a('float', 'turret = 50,', 'The z-layer: Layer.turret = 50 (Layer.java:48, `turret = 50,`), set by `Draw.z(Layer.turret);` (RepairTurret.java:167).', source=LAYER),
    }
    return draw_inputs, draw_outputs


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
    draw_inputs, draw_outputs = definitions()

    entries = [
        ('N2225', DRAW_OWNER, 'source_repair_turret_draw_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret', 'RepairTurret.draw()', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret draw() state from RepairTurret.java + Layer.java + Drawf.java + Blocks.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret draw() state from RepairTurret.java + Layer.java + Drawf.java + Blocks.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: draw_rotation,
    # shadow_position, base_position, z_layer.
    by_slice['N2225'] = [
        'source_repair_turret_draw_state_result.draw_rotation',
        'source_repair_turret_draw_state_result.shadow_position',
        'source_repair_turret_draw_state_result.base_position',
        'source_repair_turret_draw_state_result.z_layer',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2225', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret', java_method='RepairTurret.draw()', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2225'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
