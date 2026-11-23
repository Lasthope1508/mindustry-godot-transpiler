"""Register the Radar drawSelect() row (N2333).

RadarBuild.drawSelect() (Radar.java:80-82) draws one dash
circle around the building (`Drawf.dashCircle(x, y,
fogRadius() * tilesize, Pal.accent);`, Radar.java:81):
the center is the building world position, the radius is
the LIVE fog radius (fogRadius(), Radar.java:55-57, `return
fogRadius * progress * smoothEfficiency;`) times tilesize
(8, Vars.java:135). One pure function on the family file
(the N2220 RepairPointBuild.drawSelect() precedent, which
returns center / radius / color the same way): the caller
passes the live fogRadius() result (the N2321
source_radar_fog_radius_state output) and the tilesize as
explicit params, and the pure function does the multiply.
The color is Pal.accent, represented as the string
"Pal.accent" (the SourceBlockDrawState.gd:182 precedent).
No driver tick line lands here: drawSelect is selection UI,
not per-tick state (the accessor precedent N2311/N2321).
This is a different method from N2327 draw() (rotation +
glow) -- no overlap.

RED decisions (resolved at RED): (1) One pure function,
source_radar_draw_select_state(x, y, fog_radius,
tilesize), returning center / radius / color -- the N2220
drawSelect shape, not the N2327 frame-first shape, because
drawSelect reads no frame key: x/y are the building world
position and fog_radius is the live fogRadius() value the
caller already computed (N2321). (2) tilesize is an
explicit param (Vars.tilesize 8, Vars.java:135), not
hardcoded -- the drawPlace precedent passes tilesize
explicitly, and the proof pins tilesize 1.0 reading the
raw fog radius. (3) Three new result symbols: center
(Vector2), radius (float), color (String). Slice source:
Radar.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_radar_draw import DEFERRED as N2327_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
PROOF = '/root/C07RadarDrawSelectProof'
DRAW_SELECT_OWNER = 'SourceRadarBuildState.source_radar_draw_select_state'
TESTS = ['test_c07_radar_draw_select_registration', 'test_all_c07_radar_draw_select_input_evidence_is_exact', 'test_radar_draw_select_state', 'test_reference_graph_and_actual_c07_radar_draw_select']
# The 1 slice source the N2333 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
]
EXACT_EXPRS = ['public void drawSelect(){', 'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', 'fogRadius() * tilesize', 'public float fogRadius(){', 'return fogRadius * progress * smoothEfficiency;', 'public class Radar extends Block{', 'public class RadarBuild extends Building{']

# DEFERRED is carried from the N2327 register script via import --
# never retyped. One entry is DROPPED here, not carried: the
# 'Radar drawSelect rows (drawSelect dash circle,
# Radar.java:80-82)' entry -- N2333 IS the drawSelect slice, so
# carrying it would leave a stale "waits for its own slice" row
# for done work. It is REPLACED by a drawPlace-only entry below
# (drawPlace still waits for its own slice).
DEFERRED = [e for e in N2327_DEFERRED if 'Radar drawSelect rows (drawSelect dash circle, Radar.java:80-82)' not in e] + [
    'Radar drawPlace rows (drawPlace dash circle, Radar.java:42-47) -- presentation, not tick state; waits for its own slice.',
    'Radar drawSelect Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2320/N2321/N2303/N2310/N2318/N2327: the N2333 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    select_inputs = {
        'x': a('float', 'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', 'The building world x (Radar.java:81, `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`): the dash circle is centered on the building position.'),
        'y': a('float', 'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', 'The building world y (Radar.java:81, `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`): the dash circle is centered on the building position.'),
        'fog_radius': a('float', 'fogRadius() * tilesize', 'The live fog radius (Radar.java:81, `fogRadius() * tilesize`): the fogRadius() result (Radar.java:55, `public float fogRadius(){` with `return fogRadius * progress * smoothEfficiency;`, Radar.java:56) -- the def fogRadius is 34 (Blocks.java:1991, `fogRadius = 34;`), overriding the class default 10 (Radar.java:33, `fogRadius = 10;`) -- computed by the caller through N2321 source_radar_fog_radius_state and passed in as an explicit param (the N2212 per-def-param precedent).'),
        'tilesize': a('float', 'fogRadius() * tilesize', 'The world-units-per-tile factor (Radar.java:81, `fogRadius() * tilesize`): Vars.tilesize is 8 (Vars.java:135); the port passes it explicitly (the drawPlace precedent), so the radius is the live fog radius in world units.'),
    }
    select_outputs = {
        'center': a('Vector2', 'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', 'The dash-circle center (Radar.java:81, `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`): the building position itself.'),
        'radius': a('float', 'fogRadius() * tilesize', 'The dash-circle radius (Radar.java:81, `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`): the live fog radius times tilesize -- 272.0 at full discovery (34 * 8) and 0.0 before discovery (progress 0.0).'),
        'color': a('String', 'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', 'The dash-circle color (Radar.java:81, `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`): Pal.accent, represented as the string "Pal.accent" (the SourceBlockDrawState.gd:182 precedent).'),
    }
    return select_inputs, select_outputs


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
    select_inputs, select_outputs = definitions()

    entries = [
        ('N2333', DRAW_SELECT_OWNER, 'source_radar_draw_select_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.drawSelect()', select_inputs, select_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar drawSelect() row from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar drawSelect() row from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: center, radius, color.
    by_slice['N2333'] = [
        'source_radar_draw_select_state_result.center',
        'source_radar_draw_select_state_result.radius',
        'source_radar_draw_select_state_result.color',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2333', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.drawSelect()', godot_owner=DRAW_SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2333'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
