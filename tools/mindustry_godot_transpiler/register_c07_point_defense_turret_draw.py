"""Register the PointDefenseTurret draw() body (N2244).

PointDefenseBuild.draw() (PointDefenseTurret.java:110-114,
`public void draw(){`) draws the base rect at (x, y) with no
rotation (`Draw.rect(baseRegion, x, y);` -- :111), draws the
shadow and the region rect at rotation - 90
(`Drawf.shadow(region, x - (size / 2f), y - (size / 2f),
rotation - 90);` -- :112, the overload `public static void
shadow(TextureRegion region, float x, float y, float
rotation){`, Drawf.java:366 -- and `Draw.rect(region, x, y,
rotation - 90);` -- :113). There is NO Draw.z call here,
unlike RepairTurret.draw() (RepairTurret.java:167,
`Draw.z(Layer.turret);`) -- so this slice has NO z_layer
symbol, only the three draw keys. The shadow offset quirk
stays as Java wrote it: `size / 2f` is subtracted directly
on world coords, NOT tilesize-scaled -- segment (size 2, the
only PointDefenseTurret def, Blocks.java:3842, `size = 2;`)
offsets 1.0, the class default size 1 (Block.java:215,
`public int size = 1;`) offsets 0.5.

GREEN decisions (pinned by this slice): (1) One pure
function on SourcePointDefenseTurretBuildState.gd,
source_point_defense_turret_draw_state(x, y, rotation,
size), returning `{"draw_rotation": ...,
"shadow_position": ..., "base_position": ...}`, plus one
driver tick line that stamps the three keys live right
after the aim/shoot block (the N2225 RepairTurret draw
precedent -- draw() runs every frame after updateTile).
Three new result symbols. (2) draw_rotation is
rotation - 90 (the same angle the shadow uses); the
shadow position is (x - size / 2f, y - size / 2f); the
base position is (x, y) with no rotation. (3) rotation
defaults to 90 (the field init `public float rotation =
90;`, BaseTurret.java:114 -- NOT BuildingComp.rotation,
the int block rotation); the driver passes the per-def
segment size 2.0 (Blocks.java:3842, the only
PointDefenseTurret def) and reads rotation live from the
frame the aim/shoot block just stamped. (4) Rendering
itself stays out of the game -- only the state draw()
depends on is captured, per the user boundary. The
write/read rows (PointDefenseTurret.java:117-128,
`write.f(rotation);` / `rotation = read.f();`),
setStats (PointDefenseTurret.java:36-42) and icons
(PointDefenseTurret.java:31-34) wait for their own
slices. Shard note: PointDefenseTurret.java lives under
/world/blocks/defense/turrets/ and matches the defense
shard selection (the N2239 precedent), so the GREEN
register run records the defense shard count change.
SSOT expected after GREEN: symbols +3, Done +1,
contracts +1, schema +2, 11558/1693/1624/3039 ->
11561/1694/1625/3041.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_point_defense_turret_spawn_team_stamp import DEFERRED as N2243_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
DRAWF = 'core/src/mindustry/graphics/Drawf.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07PointDefenseTurretDrawProof'
DRAW_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_draw_state'
TESTS = ['test_c07_point_defense_turret_draw_registration', 'test_all_c07_point_defense_turret_draw_input_evidence_is_exact', 'test_point_defense_turret_draw_state', 'test_reference_graph_and_actual_c07_point_defense_turret_draw']
# The 5 slice sources the N2244 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/graphics/Drawf.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void draw(){', 'Draw.rect(baseRegion, x, y);', 'Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);', 'Draw.rect(region, x, y, rotation - 90);', 'public static void shadow(TextureRegion region, float x, float y, float rotation){', 'public float rotation = 90;', 'public int size = 1;', 'size = 2;', 'public class PointDefenseTurret extends ReloadTurret{']

# DEFERRED is carried from the N2243 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the live coolant wiring + write/read + setStats / icons +
# the real effect/sound spawn, and the TractorBeam half is
# untouched. Only the N2244 Windows-proof debt entry is
# appended.
DEFERRED = list(N2243_DEFERRED) + [
    'PointDefenseTurret draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2243: the N2244 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'x': a('float', 'Draw.rect(baseRegion, x, y);', 'The live world x of the building in pixels (PointDefenseTurret.java:111, `Draw.rect(baseRegion, x, y);`, the base rect is drawn at (x, y) with no rotation); passed explicitly (the N2225 draw precedent) because the pure function takes the position as args, not a frame.'),
        'y': a('float', 'Draw.rect(baseRegion, x, y);', 'The live world y of the building in pixels (PointDefenseTurret.java:111, `Draw.rect(baseRegion, x, y);`, same line as x); passed explicitly, same precedent as x.'),
        'rotation': a('float', 'public float rotation = 90;', 'The live rotation in degrees (BaseTurret.java:114, `public float rotation = 90;`, the field init -- NOT BuildingComp.rotation, the int block rotation; the driver reads it live from the frame the aim/shoot block just stamped); passed explicitly because the draw angle is rotation - 90.', source=BASE_TURRET),
        'size': a('float', 'public int size = 1;', 'The Block.size in tiles (Block.java:215, `public int size = 1;`, the class default; segment 2, Blocks.java:3842, `size = 2;`, the only PointDefenseTurret def); passed explicitly because it is per-def static state, not a live frame key (the N2225 draw precedent).', source=BLOCK),
    }
    draw_outputs = {
        'draw_rotation': a('float', 'Draw.rect(region, x, y, rotation - 90);', 'The region rect angle in degrees: rotation - 90 (PointDefenseTurret.java:113, `Draw.rect(region, x, y, rotation - 90);`, the same angle the shadow uses at :112).'),
        'shadow_position': a('float', 'Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);', 'The shadow position: (x - size / 2f, y - size / 2f) (PointDefenseTurret.java:112, `Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);`); size / 2f is subtracted directly on world coords, NOT tilesize-scaled -- the quirk stays as Java wrote it.'),
        'base_position': a('float', 'Draw.rect(baseRegion, x, y);', 'The base rect position: (x, y) with no rotation (PointDefenseTurret.java:111, `Draw.rect(baseRegion, x, y);`).'),
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
        ('N2244', DRAW_OWNER, 'source_point_defense_turret_draw_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.draw()', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret draw() state from PointDefenseTurret.java + Drawf.java + Block.java + BaseTurret.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret draw() state from PointDefenseTurret.java + Drawf.java + Block.java + BaseTurret.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: draw_rotation,
    # shadow_position, base_position.
    by_slice['N2244'] = [
        'source_point_defense_turret_draw_state_result.draw_rotation',
        'source_point_defense_turret_draw_state_result.shadow_position',
        'source_point_defense_turret_draw_state_result.base_position',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2244', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.draw()', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2244'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
