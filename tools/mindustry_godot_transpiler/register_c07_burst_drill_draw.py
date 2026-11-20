"""Register the BurstDrillBuild draw() OVERRIDE slice (N2314).

BurstDrillBuild.draw() (BurstDrill.java:133-180, `public void
draw(){`) is the BurstDrillBuild OVERRIDE (`public class
BurstDrillBuild extends DrillBuild{`, BurstDrill.java:70, of
`public class BurstDrill extends Drill{`, BurstDrill.java:17):
`Draw.rect(region, x, y);` (:134),
`drawDefaultCracks();` (:135),
`Draw.rect(topRegion, x, y);` (:137),
`if(invertTime > 0 && topInvertRegion.found()){` (:139)
with `Draw.alpha(Interp.pow3Out.apply(invertTime));` (:140)
and `Draw.rect(topInvertRegion, x, y);` (:141),
`if(dominantItem != null && drawMineItem){` (:145) with
`Draw.color(dominantItem.color);` (:146) and
`Draw.rect(itemRegion, x, y);` (:147),
`float fract = smoothProgress;` (:151),
`Draw.color(arrowColor);` (:152), then the 4-direction
arrow ring (:153-173): `float arrowFract = (arrows - 1 -
j);` (:155), `float a = Mathf.clamp(fract * arrows -
arrowFract);` (:156), `Tmp.v1.trns(i * 90 + 45, j *
arrowSpacing + arrowOffset);` (:157),
`Draw.z(Layer.block);` (:159),
`Draw.color(baseArrowColor, arrowColor, a);` (:160),
`Draw.rect(arrowRegion, x + Tmp.v1.x, y + Tmp.v1.y, i *
90);` (:161), blur `if(arrowBlurRegion.found()){` (:165)
with `Draw.z(Layer.blockAdditive);` (:166),
`Draw.blend(Blending.additive);` (:167),
`Draw.alpha(Mathf.pow(a, 10f));` (:168) and
`Draw.rect(arrowBlurRegion, x + Tmp.v1.x, y + Tmp.v1.y,
i * 90);` (:169), then `Draw.color();` (:174) and
`if(glowRegion.found()){` (:177) with
`Drawf.additive(glowRegion, Tmp.c2.set(glowColor).a(
Mathf.pow(fract, 3f) * glowColor.a), x, y);` (:178).
The DrillBuild.draw() BASE (Drill.java:346-379) is a LATER
slice (N2317), NOT this one. drawDefaultCracks()
(Drill.java:341-343, `public void drawDefaultCracks(){`)
is a callee (D5): its already-computed result rides in as
an explicit param, NOT re-ported. One pure function on the
family file (the N2341 drawSelect precedent): it returns
the computed draw state (rects, colors, alpha, z, blend,
glow) and does NOT touch real Draw/Drawf playback. There
is NO driver tick line: draw() is per-frame render state,
not per-tick state (the N2341 drawSelect lifecycle
precedent). Fourteen new result symbols: base_rect, cracks,
top_rect, invert_visible, invert_alpha, invert_rect,
mine_item_visible, mine_item_rect, fract, arrow_count,
arrows, glow_visible, glow_alpha, glow_color. Two defs
share the function (impact-drill, Blocks.java:3070, size
4; eruption-drill, Blocks.java:3093, size 5); they differ
only in the per-def params the caller passes (arrows 3 vs
2, arrowSpacing 4f vs 5f, arrowOffset 0f vs 2f, glowColor.a
1.0 vs 0.6f). Formulas: Interp.pow3Out.apply(t) = 1 -
(1 - t)^3 (arc PowOut, power 3); Mathf.clamp(x) clamps to
[0, 1] (arc Mathf.java:402-404); Tmp.v1.trns(angle, len)
rotates (len, 0) by the angle in degrees (arc
Vec2.java:40-42); Draw.color(a, b, s) lerps a toward b by
s (arc Draw.java:234-236); Layer.block = 30,
Layer.blockAdditive = 31 (Layer.java:27,36). Slice
sources: BurstDrill.java + Drill.java + Block.java +
Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07BurstDrillDrawProof'
DRAW_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_draw_state'
TESTS = ['test_c07_burst_drill_draw_registration', 'test_all_c07_burst_drill_draw_input_evidence_is_exact', 'test_burst_drill_draw_state', 'test_reference_graph_and_actual_c07_burst_drill_draw']
# The 4 slice sources the N2314 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void draw(){', 'Draw.rect(region, x, y);', 'drawDefaultCracks();', 'Draw.rect(topRegion, x, y);', 'if(invertTime > 0 && topInvertRegion.found()){', 'Draw.alpha(Interp.pow3Out.apply(invertTime));', 'Draw.rect(topInvertRegion, x, y);', 'Draw.color();', 'if(dominantItem != null && drawMineItem){', 'Draw.color(dominantItem.color);', 'Draw.rect(itemRegion, x, y);', 'float fract = smoothProgress;', 'Draw.color(arrowColor);', 'for(int i = 0; i < 4; i++){', 'for(int j = 0; j < arrows; j++){', 'float arrowFract = (arrows - 1 - j);', 'float a = Mathf.clamp(fract * arrows - arrowFract);', 'Tmp.v1.trns(i * 90 + 45, j * arrowSpacing + arrowOffset);', 'Draw.z(Layer.block);', 'Draw.color(baseArrowColor, arrowColor, a);', 'Draw.rect(arrowRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);', 'if(arrowBlurRegion.found()){', 'Draw.z(Layer.blockAdditive);', 'Draw.blend(Blending.additive);', 'Draw.alpha(Mathf.pow(a, 10f));', 'Draw.rect(arrowBlurRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);', 'Draw.blend();', 'if(glowRegion.found()){', 'Drawf.additive(glowRegion, Tmp.c2.set(glowColor).a(Mathf.pow(fract, 3f) * glowColor.a), x, y);', 'public class BurstDrill extends Drill{', 'public class BurstDrillBuild extends DrillBuild{', 'public float smoothProgress = 0f;', 'public float invertTime = 0f;', 'public float arrowSpacing = 4f, arrowOffset = 0f;', 'public int arrows = 3;', 'public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");', 'public Color glowColor = arrowColor.cpy();', 'public @Load("@-top-invert") TextureRegion topInvertRegion;', 'public @Load("@-glow") TextureRegion glowRegion;', 'public @Load("@-arrow") TextureRegion arrowRegion;', 'public @Load("@-arrow-blur") TextureRegion arrowBlurRegion;', 'public void drawDefaultCracks(){', 'public boolean drawMineItem = true;', 'public Item dominantItem;', 'public @Load("@-top") TextureRegion topRegion;', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'public TextureRegion region;', 'public class Drill extends Block{', 'public class DrillBuild extends Building{', 'size = 4;', 'size = 5;', 'arrowOffset = 2f;', 'arrowSpacing = 5f;', 'arrows = 2;', 'glowColor.a = 0.6f;']

DEFERRED = [
    'BurstDrillBuild draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2314 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BurstDrillBuild draw() concrete rect rendering (Draw.rect / Drawf.additive with live TextureRegions) stays owned by Godot rendering integration; this helper preserves rects, colors, alpha, z, blend and glow state.',
    'BurstDrillBuild draw() drawDefaultCracks() callee (DrillBuild.drawDefaultCracks, Drill.java:341-343, D5) -- the caller passes the already-computed cracks dict; the callee itself is not this slice.',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'x': a('float', 'Draw.rect(region, x, y);', 'The building world x (BurstDrill.java:134, `Draw.rect(region, x, y);`); passed explicitly because draw() reads the live building position.'),
        'y': a('float', 'Draw.rect(region, x, y);', 'The building world y (BurstDrill.java:134, `Draw.rect(region, x, y);`); passed explicitly because draw() reads the live building position.'),
        'region': a('Variant', 'public TextureRegion region;', 'The inherited block region (Block.java:427, `public TextureRegion region;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=BLOCK),
        'top_region': a('Variant', 'public @Load("@-top") TextureRegion topRegion;', 'The Drill top region (Drill.java:73, `public @Load("@-top") TextureRegion topRegion;`, loaded as name + "-top"); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=DRILL),
        'item_region': a('Variant', 'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;', 'The Drill item region (Drill.java:74, `public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;`); passed explicitly because it is per-def static state, not a live frame key.', source=DRILL),
        'arrow_region': a('Variant', 'public @Load("@-arrow") TextureRegion arrowRegion;', 'The BurstDrill arrow region (BurstDrill.java:40, `public @Load("@-arrow") TextureRegion arrowRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'arrow_blur_region': a('Variant', 'public @Load("@-arrow-blur") TextureRegion arrowBlurRegion;', 'The BurstDrill arrow blur region (BurstDrill.java:41, `public @Load("@-arrow-blur") TextureRegion arrowBlurRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'glow_region': a('Variant', 'public @Load("@-glow") TextureRegion glowRegion;', 'The BurstDrill glow region (BurstDrill.java:39, `public @Load("@-glow") TextureRegion glowRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'top_invert_region': a('Variant', 'public @Load("@-top-invert") TextureRegion topInvertRegion;', 'The BurstDrill top invert region (BurstDrill.java:38, `public @Load("@-top-invert") TextureRegion topInvertRegion;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'invert_time': a('float', 'public float invertTime = 0f;', 'The invert overlay timer (BurstDrill.java:76, `public float invertTime = 0f;`), counted down in updateTile (N2294); passed explicitly because it is live build state, not a frame key.'),
        'smooth_progress': a('float', 'public float smoothProgress = 0f;', 'The smoothed drill progress (BurstDrill.java:74, `public float smoothProgress = 0f;`), smoothed in updateTile (N2294); the arrow ring reads it as `float fract = smoothProgress;` (BurstDrill.java:151); passed explicitly because it is live build state, not a frame key.'),
        'has_dominant_item': a('bool', 'public Item dominantItem;', 'Whether the drill has a dominant item: dominantItem is `public Item dominantItem;` (Drill.java:244), set by the N2302 ore/dominant binding; the draw guard is `if(dominantItem != null && drawMineItem){` (BurstDrill.java:145); passed explicitly because the binding is not this slice.', source=DRILL),
        'dominant_item_color': a('Variant', 'Draw.color(dominantItem.color);', 'The dominant item color (BurstDrill.java:146, `Draw.color(dominantItem.color);`); passed explicitly with the dominant item.'),
        'draw_mine_item': a('bool', 'public boolean drawMineItem = true;', 'The block flag for drawing the mined item (Drill.java:51, `public boolean drawMineItem = true;`, default true); the draw guard is `if(dominantItem != null && drawMineItem){` (BurstDrill.java:145); passed explicitly because it is per-def static state.', source=DRILL),
        'arrows': a('int', 'public int arrows = 3;', 'The arrows per direction (BurstDrill.java:28, `public int arrows = 3;`, default 3); eruption-drill overrides `arrows = 2;` (Blocks.java:3110); passed explicitly because it is per-def static state.'),
        'arrow_spacing': a('float', 'public float arrowSpacing = 4f, arrowOffset = 0f;', 'The arrow spacing (BurstDrill.java:26, `public float arrowSpacing = 4f, arrowOffset = 0f;`, default 4f); eruption-drill overrides `arrowSpacing = 5f;` (Blocks.java:3109); passed explicitly because it is per-def static state.'),
        'arrow_offset': a('float', 'public float arrowSpacing = 4f, arrowOffset = 0f;', 'The arrow offset (BurstDrill.java:26, `public float arrowSpacing = 4f, arrowOffset = 0f;`, default 0f); eruption-drill overrides `arrowOffset = 2f;` (Blocks.java:3108); passed explicitly because it is per-def static state.'),
        'arrow_color': a('Variant', 'public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");', 'The arrow color (BurstDrill.java:29, `public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");`, "feb380"); passed explicitly because it is per-def static state.'),
        'base_arrow_color': a('Variant', 'public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");', 'The base arrow color (BurstDrill.java:29, `public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");`, "6e7080"); the per-arrow color lerps from it toward arrowColor; passed explicitly because it is per-def static state.'),
        'glow_color': a('Variant', 'public Color glowColor = arrowColor.cpy();', 'The glow color (BurstDrill.java:30, `public Color glowColor = arrowColor.cpy();`, a copy of arrowColor); eruption-drill overrides `glowColor.a = 0.6f;` (Blocks.java:3111); passed explicitly because it is per-def static state.'),
        'top_invert_region_found': a('bool', 'if(invertTime > 0 && topInvertRegion.found()){', 'Whether the @-top-invert region exists (BurstDrill.java:139, `if(invertTime > 0 && topInvertRegion.found()){`); passed explicitly because region presence is load-time state.'),
        'arrow_blur_region_found': a('bool', 'if(arrowBlurRegion.found()){', 'Whether the @-arrow-blur region exists (BurstDrill.java:165, `if(arrowBlurRegion.found()){`); passed explicitly because region presence is load-time state.'),
        'glow_region_found': a('bool', 'if(glowRegion.found()){', 'Whether the @-glow region exists (BurstDrill.java:177, `if(glowRegion.found()){`); passed explicitly because region presence is load-time state.'),
        'draw_default_cracks': a('Dictionary', 'drawDefaultCracks();', 'The already-computed result of drawDefaultCracks() (BurstDrill.java:135, `drawDefaultCracks();`; defined Drill.java:341-343, callee D5, N2317); passed explicitly because the callee is not this slice -- the helper passes it through as `cracks`.'),
    }
    draw_outputs = {
        'base_rect': a('Dictionary', 'Draw.rect(region, x, y);', 'The base rect {region, x, y}, always drawn (BurstDrill.java:134, `Draw.rect(region, x, y);`).'),
        'cracks': a('Dictionary', 'drawDefaultCracks();', 'The callee result passed through unchanged (BurstDrill.java:135, `drawDefaultCracks();`).'),
        'top_rect': a('Dictionary', 'Draw.rect(topRegion, x, y);', 'The top rect {region, x, y}, always drawn (BurstDrill.java:137, `Draw.rect(topRegion, x, y);`).'),
        'invert_visible': a('bool', 'if(invertTime > 0 && topInvertRegion.found()){', 'Whether the invert overlay is drawn: true exactly when invertTime > 0 and the top-invert region exists (BurstDrill.java:139, `if(invertTime > 0 && topInvertRegion.found()){`).'),
        'invert_alpha': a('float', 'Draw.alpha(Interp.pow3Out.apply(invertTime));', 'The invert overlay alpha: pow3Out(invertTime) = 1 - (1 - invertTime)^3 when visible, else 0.0 (BurstDrill.java:140, `Draw.alpha(Interp.pow3Out.apply(invertTime));`; arc PowOut power 3).'),
        'invert_rect': a('Variant', 'Draw.rect(topInvertRegion, x, y);', 'The invert rect {region, x, y, alpha} when visible, else null (BurstDrill.java:141, `Draw.rect(topInvertRegion, x, y);`).'),
        'mine_item_visible': a('bool', 'if(dominantItem != null && drawMineItem){', 'Whether the mine-item overlay is drawn: true exactly when a dominant item is bound and drawMineItem (BurstDrill.java:145, `if(dominantItem != null && drawMineItem){`).'),
        'mine_item_rect': a('Variant', 'Draw.rect(itemRegion, x, y);', 'The mine-item rect {region, x, y, color} when visible, else null (BurstDrill.java:147, `Draw.rect(itemRegion, x, y);`).'),
        'fract': a('float', 'float fract = smoothProgress;', 'The arrow ring progress: fract = smoothProgress (BurstDrill.java:151, `float fract = smoothProgress;`).'),
        'arrow_count': a('int', 'for(int i = 0; i < 4; i++){', 'The total arrows drawn: 4 directions x arrows (BurstDrill.java:153, `for(int i = 0; i < 4; i++){`); 12 impact-drill (arrows 3), 8 eruption-drill (arrows 2).'),
        'arrows': a('Array', 'Draw.rect(arrowRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);', 'The per-arrow computed state, ordered i = 0..3 then j = 0..arrows-1: position (x, y) + trns(i * 90 + 45, j * arrowSpacing + arrowOffset), alpha = clamp(fract * arrows - (arrows - 1 - j)) to [0, 1], color = baseArrowColor.lerp(arrowColor, alpha), rotation = i * 90, blur_alpha = pow(alpha, 10) when the blur region exists, z 30 (Layer.block) / blur z 31 (Layer.blockAdditive), blur blend additive (BurstDrill.java:153-173).'),
        'glow_visible': a('bool', 'if(glowRegion.found()){', 'Whether the glow is drawn: true exactly when the glow region exists (BurstDrill.java:177, `if(glowRegion.found()){`).'),
        'glow_alpha': a('float', 'Drawf.additive(glowRegion, Tmp.c2.set(glowColor).a(Mathf.pow(fract, 3f) * glowColor.a), x, y);', 'The glow alpha: pow(fract, 3) * glowColor.a when visible, else 0.0 (BurstDrill.java:178).'),
        'glow_color': a('Variant', 'Drawf.additive(glowRegion, Tmp.c2.set(glowColor).a(Mathf.pow(fract, 3f) * glowColor.a), x, y);', 'The glow color: glowColor with alpha = glow_alpha (BurstDrill.java:178, `Tmp.c2.set(glowColor).a(Mathf.pow(fract, 3f) * glowColor.a)`).'),
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
        ('N2314', DRAW_OWNER, 'source_burst_drill_draw_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill$BurstDrillBuild', 'BurstDrillBuild.draw()', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrillBuild draw() state from BurstDrill.java + Drill.java + Block.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrillBuild draw() state from BurstDrill.java + Drill.java + Block.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: base_rect, cracks, top_rect,
    # invert_visible, invert_alpha, invert_rect,
    # mine_item_visible, mine_item_rect, fract, arrow_count,
    # arrows, glow_visible, glow_alpha, glow_color.
    by_slice['N2314'] = [
        'source_burst_drill_draw_state_result.base_rect',
        'source_burst_drill_draw_state_result.cracks',
        'source_burst_drill_draw_state_result.top_rect',
        'source_burst_drill_draw_state_result.invert_visible',
        'source_burst_drill_draw_state_result.invert_alpha',
        'source_burst_drill_draw_state_result.invert_rect',
        'source_burst_drill_draw_state_result.mine_item_visible',
        'source_burst_drill_draw_state_result.mine_item_rect',
        'source_burst_drill_draw_state_result.fract',
        'source_burst_drill_draw_state_result.arrow_count',
        'source_burst_drill_draw_state_result.arrows',
        'source_burst_drill_draw_state_result.glow_visible',
        'source_burst_drill_draw_state_result.glow_alpha',
        'source_burst_drill_draw_state_result.glow_color',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2314', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill$BurstDrillBuild', java_method='BurstDrillBuild.draw()', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2314'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
