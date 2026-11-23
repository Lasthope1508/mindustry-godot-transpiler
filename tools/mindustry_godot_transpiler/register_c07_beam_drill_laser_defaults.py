"""Register the BeamDrill field-defaults slice (N2440).

BeamDrill field defaults (BeamDrill.java:28-59), 12 lines, no
method owns them: the six @Load laser TextureRegions (:28-30,
:32-34), the spark/glow colors (:53), the glow/pulse
intensities (:54), glowScl (:55), sparks (:56), the five
spark numbers (:57) and the boost heat color (:59). Field
declarations are load-time block definition setup, not
per-tick state, so no method slice can absorb them -- this
is the first field-decl-only slice (main-thread decision,
batch 40 slot 1).

The values are NOT live code anywhere else: the draw func
(source_beam_drill_draw_state, N2382/N2408) takes every one
of them as an explicit param, and the defaults themselves
live only as a prose comment (:562-566) -- the new func
source_beam_drill_laser_defaults_state is the first live
home for the values. The laser textures load as name +
suffix ("@-beam" etc.) with the drill-laser* fallback
names; the result carries the resolved per-block region
name (the N2212/N2224 per-def-param precedent: block_name
arrives explicitly -- plasma-bore, Blocks.java:3038, and
large-plasma-bore, Blocks.java:3052, override none of the
12 lines, only laserWidth 0.7f, Blocks.java:3062).
sparkColor is Color.valueOf("fd9e81"), glowColor is
Color.white, boostHeatColor is Color.sky.cpy().mul(0.87f)
-- GDScript Color.SKY_BLUE * 0.87 (Color * float multiplies
all four components, arc Color.mul(float) included).
Colors are Variant in the schema (no "Color" type exists
in source_state_schema.json -- the draw_state precedent).

NOT this slice: topRegion :36 / glowRegion :37 / range
:40 / tier :41 / drillMultipliers :47 / blockedItem :49 /
blockedItems :51 (already own), drillTime :39 /
laserWidth :42 / optionalBoostIntensity :44 / heatColor
:60 (free, deferred to their own slices).

One pure function on the existing
SourceBeamDrillBuildState.gd: it returns the computed
defaults and does NOT touch real Draw playback. This is
field defaults only: NOT ambient C (N2304 HELD -- the
SoundControl updateLoops mixer), NO driver tick line.
18 new result symbols: laser, laser_end, laser_center,
laser_boost, laser_end_boost, laser_center_boost,
spark_color, glow_color, glow_intensity, pulse_intensity,
glow_scl, sparks, spark_range, spark_life,
spark_recurrence, spark_spread, spark_size,
boost_heat_color. Slice source: BeamDrill.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_outputs_items_rotated_output_icons_should_consume import DEFERRED as N2417_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
PROOF = '/root/C07BeamDrillLaserDefaultsProof'
OWNER = 'SourceBeamDrillBuildState.source_beam_drill_laser_defaults_state'
TESTS = ['test_c07_beam_drill_laser_defaults_registration', 'test_all_c07_beam_drill_laser_defaults_input_evidence_is_exact', 'test_beam_drill_laser_defaults_state', 'test_reference_graph_and_actual_c07_beam_drill_laser_defaults']
# The 1 slice source the N2440 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
]
EXACT_EXPRS = [
    'public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;',
    'public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;',
    'public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;',
    'public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;',
    'public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;',
    'public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;',
    'public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;',
    'public float glowIntensity = 0.2f, pulseIntensity = 0.07f;',
    'public float glowScl = 3f;',
    'public int sparks = 7;',
    'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;',
    'public Color boostHeatColor = Color.sky.cpy().mul(0.87f);',
]

# DEFERRED is carried from the N2417 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the laser/spark/glow/heat field defaults are load-time block
# definition setup, not the shouldConsume tick wiring or the
# outputsItems/rotatedOutput/icons/shouldConsume proof debt),
# so all are carried verbatim. Three entries are added: the
# still-free BeamDrill field decls (drillTime :39, laserWidth
# :42, optionalBoostIntensity :44, heatColor :60) and N2440's
# Windows proof debt.
DEFERRED = list(N2417_DEFERRED) + [
    'BeamDrill field decls still free, not this slice: `public float drillTime = 200f;` (:39), `public float laserWidth = 0.65f;` (:42), `public float optionalBoostIntensity = 2.5f;` (:44), `public Color heatColor = new Color(1f, 0.35f, 0.35f, 0.9f);` (:60) -- each waits for its own slice; large-plasma-bore overrides only laserWidth (0.7f, Blocks.java:3062).',
    'BeamDrill laser/spark/glow/heat field defaults Windows Godot proof -- debt in GOAL.md section 5, same as N2401/N2417: the N2440 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;', 'The beam-drill frame (BeamDrill field defaults, BeamDrill.java:28-59): carries no live keys for this load-time setup -- the laser region names depend on the block name, not on frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file.'),
        'block_name': a('String', 'public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;', 'The block name (BeamDrill.java:28, `value = "@-beam"`): the "@-beam" value is the block name + "-beam" (plasma-bore, Blocks.java:3038; large-plasma-bore, Blocks.java:3052); it passes through to the six laser region keys, and the scalar / color defaults below do not depend on it.'),
    }
    outputs = {
        'laser': a('String', 'public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;', 'The laser region name (BeamDrill.java:28, `public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;`): block_name + "-beam" -- the "@-beam" value; the "drill-laser" fallback is load metadata kept in the comment + rule, the draw_state `laser` param receives the resolved region name.'),
        'laser_end': a('String', 'public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;', 'The laser-end region name (BeamDrill.java:29, `public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;`): block_name + "-beam-end"; fallback "drill-laser-end" is load metadata, the draw_state `laser_end` param receives the resolved name.'),
        'laser_center': a('String', 'public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;', 'The laser-center region name (BeamDrill.java:30, `public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;`): block_name + "-beam-center"; fallback "drill-laser-center" is load metadata, the draw_state `laser_center` param receives the resolved name.'),
        'laser_boost': a('String', 'public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;', 'The boost laser region name (BeamDrill.java:32, `public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;`): block_name + "-beam-boost"; fallback "drill-laser-boost" is load metadata, the draw_state `laser_boost` param receives the resolved name.'),
        'laser_end_boost': a('String', 'public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;', 'The boost laser-end region name (BeamDrill.java:33, `public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;`): block_name + "-beam-boost-end"; fallback "drill-laser-boost-end" is load metadata, the draw_state `laser_end_boost` param receives the resolved name.'),
        'laser_center_boost': a('String', 'public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;', 'The boost laser-center region name (BeamDrill.java:34, `public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;`): block_name + "-beam-boost-center"; fallback "drill-laser-boost-center" is load metadata, the draw_state `laser_center_boost` param receives the resolved name.'),
        'spark_color': a('Variant', 'public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;', 'The spark color (BeamDrill.java:53, `Color.valueOf("fd9e81")`): (253, 158, 129) / 255, alpha 1 -- the Tmp.c3 spark base the draw func lerps toward boostHeatColor; Variant in the schema (no "Color" type exists -- the draw_state precedent).'),
        'glow_color': a('Variant', 'public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;', 'The glow color (BeamDrill.java:53, `Color.white`): (1, 1, 1, 1) -- the Draw.mixcol base the draw func mixes with absin(glowScl, glowIntensity); Variant in the schema (no "Color" type exists -- the draw_state precedent).'),
        'glow_intensity': a('float', 'public float glowIntensity = 0.2f, pulseIntensity = 0.07f;', 'The glow intensity (BeamDrill.java:54, `glowIntensity = 0.2f`): 0.2 -- the absin amplitude the draw func mixes glowColor with; the draw_state `glow_intensity` param.'),
        'pulse_intensity': a('float', 'public float glowIntensity = 0.2f, pulseIntensity = 0.07f;', 'The pulse intensity (BeamDrill.java:54, `pulseIntensity = 0.07f`): 0.07 -- the absin amplitude the draw func adds to laserWidth for the beam width; the draw_state `pulse_intensity` param.'),
        'glow_scl': a('float', 'public float glowScl = 3f;', 'The glow scale (BeamDrill.java:55, `glowScl = 3f`): 3.0 -- the absin period the draw func uses for both the beam width and the glow mix; the draw_state `glow_scl` param.'),
        'sparks': a('int', 'public int sparks = 7;', 'The spark count (BeamDrill.java:56, `sparks = 7`): 7 -- the loop bound of the spark pass in the draw func; the draw_state `sparks` param.'),
        'spark_range': a('float', 'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;', 'The spark range (BeamDrill.java:57, `sparkRange = 10f`): 10.0 -- the spark travel distance (sparkRange * fin) in the draw func; the draw_state `spark_range` param.'),
        'spark_life': a('float', 'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;', 'The spark life (BeamDrill.java:57, `sparkLife = 27f`): 27.0 -- the fin divisor (Time.time / sparkLife) in the draw func; the draw_state `spark_life` param.'),
        'spark_recurrence': a('float', 'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;', 'The spark recurrence (BeamDrill.java:57, `sparkRecurrence = 4f`): 4.0 -- the fin modulus and the rand.random bound in the draw func; the draw_state `spark_recurrence` param.'),
        'spark_spread': a('float', 'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;', 'The spark spread (BeamDrill.java:57, `sparkSpread = 45f`): 45.0 -- the rand.range rotation bound in the draw func; the draw_state `spark_spread` param.'),
        'spark_size': a('float', 'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;', 'The spark size (BeamDrill.java:57, `sparkSize = 3.5f`): 3.5 -- the spark line width in the draw func; the draw_state `spark_size` param.'),
        'boost_heat_color': a('Variant', 'public Color boostHeatColor = Color.sky.cpy().mul(0.87f);', 'The boost heat color (BeamDrill.java:59, `Color.sky.cpy().mul(0.87f)`): sky (135, 206, 235) / 255 with every component * 0.87 (alpha 0.87) -- the lerp target the draw func blends sparkColor toward at full boostWarmup; GDScript Color.SKY_BLUE * 0.87 (Color * float multiplies all four components, arc Color.mul(float) included); Variant in the schema (no "Color" type exists -- the draw_state precedent).'),
    }
    return (inputs, outputs)


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
    for pair in inputs_outputs:
        total += len(pair)
        for field, meta in pair.items():
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
    inputs, outputs = definitions()

    entries = [
        ('N2440', OWNER, 'source_beam_drill_laser_defaults_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.<field declarations>', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill laser/spark/glow/heat field defaults from BeamDrill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill laser/spark/glow/heat field defaults from BeamDrill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: laser, laser_end,
    # laser_center, laser_boost, laser_end_boost,
    # laser_center_boost, spark_color, glow_color,
    # glow_intensity, pulse_intensity, glow_scl, sparks,
    # spark_range, spark_life, spark_recurrence,
    # spark_spread, spark_size, boost_heat_color.
    by_slice['N2440'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2440', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill', java_method='BeamDrill.<field declarations>', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2440'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
