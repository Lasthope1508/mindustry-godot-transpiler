"""Register the Radar draw() rows (N2278).

RadarBuild.draw() (Radar.java:84-90) draws the base region
unrotated (`Draw.rect(baseRegion, x, y);`, Radar.java:86),
the region rotated by rotateSpeed * totalProgress
(Radar.java:87), and the glow additive with alpha
glowColor.a * (1f - glowMag + Mathf.absin(glowScl,
glowMag)) at the same rotation (Radar.java:89). Two pure
functions on the same family file, one ledger entry (the
N2270 multi-function precedent): the dish rotation and the
glow alpha. The base rect has no computed value -- it is a
static draw call, render-only, so no pure function pins it.
Mathf.absin(glowScl, glowMag) is time-dependent, so the
caller supplies its evaluated value and the glow pure
function does the algebra. No driver tick line lands here:
draw() is a render call, not tick state (the accessor
precedent N2268/N2275).

RED decisions (resolved at RED): (1) Two pure functions on
the same family file N2274/N2275 built, following the N2270
multi-function precedent: rotation reads total_progress
from the frame + rotate_speed as an explicit per-def param;
glow takes glow_color_alpha + glow_mag + absin_value as
explicit params and reads no frame key. (2) No driver tick
line lands here: the accessor is the read its callers (the
render path) share, and there is no tick that writes a
draw key. (3) Two new result symbols: rotation (float),
glow_alpha (float). Slice source: Radar.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_radar_can_pickup import DEFERRED as N2272_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
PROOF = '/root/C07RadarDrawProof'
DRAW_ROTATION_OWNER = 'SourceRadarBuildState.source_radar_draw_rotation_state'
DRAW_GLOW_OWNER = 'SourceRadarBuildState.source_radar_draw_glow_state'
TESTS = ['test_c07_radar_draw_registration', 'test_all_c07_radar_draw_input_evidence_is_exact', 'test_radar_draw_state', 'test_reference_graph_and_actual_c07_radar_draw']
# The 10 slice sources the N2278 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
]
EXACT_EXPRS = ['public void draw(){', 'Draw.rect(baseRegion, x, y);', 'Draw.rect(region, x, y, rotateSpeed * totalProgress);', 'Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);', 'rotateSpeed * totalProgress', 'Mathf.absin(glowScl, glowMag)', '1f - glowMag + Mathf.absin(glowScl, glowMag)', 'glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag))', 'public class Radar extends Block{', 'public class RadarBuild extends Building{']

# DEFERRED is carried from the N2272 register script via import --
# never retyped. One entry is DROPPED here, not carried: the
# combined 'Radar draw / drawSelect / icons rows' entry -- N2278
# IS the draw() slice, so carrying it would leave a stale "waits
# for its own slice" row for done work. It is REPLACED by a
# drawSelect-only entry below (drawSelect still waits for its
# own slice, as does drawPlace).
DEFERRED = [e for e in N2272_DEFERRED if 'Radar draw / drawSelect / icons rows' not in e] + [
    'Radar drawSelect rows (drawSelect dash circle, Radar.java:80-82) -- presentation, not tick state; waits for its own slice.',
    'Radar draw Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2274/N2275/N2263/N2267/N2272: the N2278 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    rotation_inputs = {
        'frame': a('Dictionary', 'public void draw(){', 'The radar frame (RadarBuild.draw, Radar.java:85): the family-convention first arg (every Radar pure function takes it); it carries total_progress (absent defaults to 0.0 -- `public float totalProgress;`, Radar.java:52, advanced by updateTile Radar.java:71).', source=RADAR),
        'rotate_speed': a('float', 'rotateSpeed * totalProgress', 'The dish rotate speed (Radar.java:19, `public float rotateSpeed = 2f;`): an explicit per-def param (the N2212 per-def-param precedent) because the catalog carries no rotateSpeed.', source=RADAR),
    }
    rotation_outputs = {
        'rotation': a('float', 'rotateSpeed * totalProgress', 'The dish rotation angle: draw() (Radar.java:85-90) rotates both the region rect (`Draw.rect(region, x, y, rotateSpeed * totalProgress);`, Radar.java:87) and the glow (`Drawf.additive(..., rotateSpeed * totalProgress, ...);`, Radar.java:89) by rotateSpeed * totalProgress.', source=RADAR),
    }
    glow_inputs = {
        'frame': a('Dictionary', 'public void draw(){', 'The radar frame (RadarBuild.draw, Radar.java:85): the family-convention first arg (every Radar pure function takes it); the glow formula reads no frame key, so the frame is unused.', source=RADAR),
        'glow_color_alpha': a('float', 'glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag))', 'The glow color alpha (Radar.java:24, `public Color glowColor = Pal.turretHeat;`, Pal.java:52 `turretHeat = Color.valueOf("ab3400")` -- 6-digit hex, alpha 1.0): an explicit per-def param because the catalog carries no glowColor.', source=RADAR),
        'glow_mag': a('float', '1f - glowMag + Mathf.absin(glowScl, glowMag)', 'The glow magnitude (Radar.java:25, `public float glowScl = 5f, glowMag = 0.6f;`): an explicit per-def param because the catalog carries no glowMag.', source=RADAR),
        'absin_value': a('float', 'Mathf.absin(glowScl, glowMag)', 'The time-dependent Mathf.absin(glowScl, glowMag) value (Radar.java:89): an explicit input -- the pure function does the algebra, the caller supplies the arc absin evaluation.', source=RADAR),
    }
    glow_outputs = {
        'glow_alpha': a('float', 'glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag))', 'The glow alpha: draw() (Radar.java:89) passes glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)) as the additive glow alpha -- full glowColor.a at peak absin, (1f - glowMag) of it at zero absin.', source=RADAR),
    }
    return rotation_inputs, rotation_outputs, glow_inputs, glow_outputs


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
    rotation_inputs, rotation_outputs, glow_inputs, glow_outputs = definitions()

    entries = [
        ('N2278', DRAW_ROTATION_OWNER, 'source_radar_draw_rotation_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.draw()', rotation_inputs, rotation_outputs, True, 'Dictionary'),
        ('N2278', DRAW_GLOW_OWNER, 'source_radar_draw_glow_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.draw()', glow_inputs, glow_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar draw() rows from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar draw() rows from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, glow_alpha.
    by_slice['N2278'] = [
        'source_radar_draw_rotation_state_result.rotation',
        'source_radar_draw_glow_state_result.glow_alpha',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2278', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.draw()', godot_owner=DRAW_ROTATION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2278'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
