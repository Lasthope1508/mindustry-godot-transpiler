"""Register the Radar drawPlace() row (N2284).

Radar.drawPlace() (Radar.java:42-47) draws one dash circle at the
ghost position (`Drawf.dashCircle(x * tilesize + offset, y *
tilesize + offset, fogRadius * tilesize, Pal.accent);`,
Radar.java:46) after `super.drawPlace(x, y, rotation, valid);`
(Radar.java:43). This is a BLOCK-level method (Radar class, not
RadarBuild): the center converts tile coords to world coords with
tilesize (8, Vars.java:135) plus the block offset (Block.java:761
-- radar size 1, so 0.0), and the radius is the DEF fogRadius --
34 (Blocks.java:1991, `fogRadius = 34;`), class default 10
(Radar.java:33, `fogRadius = 10;`) -- times tilesize. That is a
DIFFERENT radius from N2281 drawSelect, which reads the LIVE
fogRadius() (Radar.java:55-57, `return fogRadius * progress *
smoothEfficiency;`) of the Build. One pure function on the family
file (the N2281 drawSelect precedent in the same file, same
dashCircle math): the caller passes tile_x/tile_y, rotation,
valid, the def fog_radius and the tilesize plus block_offset as
explicit params, and the pure function does the multiply. The
color is Pal.accent, represented as the string "Pal.accent" (the
SourceBlockDrawState.gd:182 precedent). The super leg
(Block.drawPlace, Block.java:491-494: drawPotentialLinks +
drawOverlay) is folded as explicit params (the N2271/N2277
super-as-param precedent): rotation/valid are echoed and
super_draw_place_called records the call; the link/overlay
drawing itself waits for its own slice. No driver tick line
lands here: drawPlace is placement UI, not per-tick state (the
accessor precedent N2268/N2275). This is the LAST unported Radar
method.

RED decisions (resolved at RED): (1) One pure function,
source_radar_draw_place_state(tile_x, tile_y, rotation, valid,
fog_radius, tilesize, block_offset), returning center / radius /
color / rotation / valid / super_draw_place_called -- the N2281
drawSelect shape extended with the super-leg echo, because
drawPlace reads no frame key: tile_x/tile_y are tile coords and
fog_radius is the def fogRadius the caller already knows (the
N2212 per-def-param precedent). (2) tilesize and block_offset
are explicit params (Vars.tilesize 8, Vars.java:135; Block offset
Block.java:761), not hardcoded -- the proof pins tilesize 1.0
reading the raw fog radius and a nonzero offset shifting the
center. (3) Six new result symbols: center (Vector2), radius
(float), color (String), rotation (int), valid (bool),
super_draw_place_called (bool). Slice sources: Radar.java +
Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_radar_draw_select import DEFERRED as N2281_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RadarDrawPlaceProof'
DRAW_PLACE_OWNER = 'SourceRadarBuildState.source_radar_draw_place_state'
TESTS = ['test_c07_radar_draw_place_registration', 'test_all_c07_radar_draw_place_input_evidence_is_exact', 'test_radar_draw_place_state', 'test_reference_graph_and_actual_c07_radar_draw_place']
# The 2 slice sources the N2284 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void drawPlace(int x, int y, int rotation, boolean valid){', 'super.drawPlace(x, y, rotation, valid);', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', 'fogRadius * tilesize', 'fogRadius = 10;', 'fogRadius = 34;', 'public class Radar extends Block{']

# DEFERRED is carried from the N2281 register script via import --
# never retyped. One entry is DROPPED here, not carried: the
# 'Radar drawPlace rows (drawPlace dash circle,
# Radar.java:42-47)' entry -- N2284 IS the drawPlace slice, so
# carrying it would leave a stale "waits for its own slice" row
# for done work. It is REPLACED by a Windows-proof-debt entry
# below (drawPlace is the last unported Radar method, so no
# further Radar row waits for its own slice).
DEFERRED = [e for e in N2281_DEFERRED if 'Radar drawPlace rows (drawPlace dash circle, Radar.java:42-47)' not in e] + [
    'Radar drawPlace Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2274/N2275/N2303/N2310/N2272/N2278/N2281: the N2284 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    place_inputs = {
        'tile_x': a('int', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', 'The ghost tile x (Radar.java:46, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`): the dash circle is centered on the tile position in world units.'),
        'tile_y': a('int', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', 'The ghost tile y (Radar.java:46, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`): the dash circle is centered on the tile position in world units.'),
        'rotation': a('int', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The placement rotation (Radar.java:42, `public void drawPlace(int x, int y, int rotation, boolean valid){`): passed to the super leg and echoed, so the caller can place the ghost at the right rotation.'),
        'valid': a('bool', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'Whether the placement is valid (Radar.java:42, `public void drawPlace(int x, int y, int rotation, boolean valid){`): passed to the super leg and echoed.'),
        'fog_radius': a('float', 'fogRadius * tilesize', 'The def fog radius (Radar.java:46, `fogRadius * tilesize`): the DEF fogRadius -- 34 (Blocks.java:1991, `fogRadius = 34;`), class default 10 (Radar.java:33, `fogRadius = 10;`) -- NOT the live fogRadius() (N2275), because drawPlace is Block-level and reads the def field; the caller passes it as an explicit param (the N2212 per-def-param precedent).'),
        'tilesize': a('float', 'fogRadius * tilesize', 'The world-units-per-tile factor (Radar.java:46, `fogRadius * tilesize`): Vars.tilesize is 8 (Vars.java:135); the port passes it explicitly (the drawPlace precedent), so the radius is the def fog radius in world units.'),
        'block_offset': a('float', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', 'The block offset (Radar.java:46, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`): ((size + 1) % 2) * tilesize / 2f (Block.java:761) -- radar size 1, so 0.0 -- passed explicitly so the center shifts correctly for even-sized blocks.'),
    }
    place_outputs = {
        'center': a('Vector2', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', 'The dash-circle center (Radar.java:46, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`): the tile position in world units -- tile coord times tilesize plus the block offset.'),
        'radius': a('float', 'fogRadius * tilesize', 'The dash-circle radius (Radar.java:46, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`): the def fog radius times tilesize -- 272.0 for the radar def (34 * 8) and 80.0 for the class default (10 * 8).'),
        'color': a('String', 'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', 'The dash-circle color (Radar.java:46, `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`): Pal.accent, represented as the string "Pal.accent" (the SourceBlockDrawState.gd:182 precedent).'),
        'rotation': a('int', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The placement rotation echoed (Radar.java:42, `public void drawPlace(int x, int y, int rotation, boolean valid){`): the super leg receives the rotation, so the pure function echoes it for the caller.'),
        'valid': a('bool', 'public void drawPlace(int x, int y, int rotation, boolean valid){', 'The placement validity echoed (Radar.java:42, `public void drawPlace(int x, int y, int rotation, boolean valid){`): the super leg receives the validity flag, so the pure function echoes it for the caller.'),
        'super_draw_place_called': a('bool', 'super.drawPlace(x, y, rotation, valid);', 'The super-leg call marker (Radar.java:43, `super.drawPlace(x, y, rotation, valid);`): the Block.drawPlace leg (Block.java:491-494: drawPotentialLinks + drawOverlay) is folded as an explicit param (the N2271/N2277 super-as-param precedent), so this records that the super leg was invoked; the link/overlay drawing itself waits for its own slice.'),
    }
    return place_inputs, place_outputs


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
    place_inputs, place_outputs = definitions()

    entries = [
        ('N2284', DRAW_PLACE_OWNER, 'source_radar_draw_place_state', RADAR, 'mindustry.world.blocks.defense.Radar', 'Radar.drawPlace()', place_inputs, place_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar drawPlace() row from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar drawPlace() row from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: center, radius, color,
    # rotation, valid, super_draw_place_called.
    by_slice['N2284'] = [
        'source_radar_draw_place_state_result.center',
        'source_radar_draw_place_state_result.radius',
        'source_radar_draw_place_state_result.color',
        'source_radar_draw_place_state_result.rotation',
        'source_radar_draw_place_state_result.valid',
        'source_radar_draw_place_state_result.super_draw_place_called',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2284', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar', java_method='Radar.drawPlace()', godot_owner=DRAW_PLACE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2284'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
