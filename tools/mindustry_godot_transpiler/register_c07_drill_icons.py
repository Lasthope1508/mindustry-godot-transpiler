"""Register the Drill icons() return array (N2335).

Drill.icons() (Drill.java:194-196, `@Override
public TextureRegion[] icons(){`) returns the three loaded
regions in order (`return new TextureRegion[]{region,
rotatorRegion, topRegion};` -- Drill.java:195). region is
the inherited block region (`public TextureRegion region;`
-- Block.java:427) and rotatorRegion / topRegion are the
Drill base fields (`public @Load("@-rotator") TextureRegion
rotatorRegion;` -- Drill.java:72, loaded as name +
"-rotator"; `public @Load("@-top") TextureRegion topRegion;`
-- Drill.java:73, loaded as name + "-top"). The
Block.icons() base (`protected TextureRegion[] icons(){` --
Block.java:976-980, the variants/teamRegion fold) is NOT
this slice: Drill overrides it, so only the override's
return array is pinned; the getGeneratedIcons cache (`public
TextureRegion[] getGeneratedIcons(){` -- Block.java:986-988,
`return generatedIcons == null ? (generatedIcons = icons())
: generatedIcons;`) is likewise deferred (the N2312
BurstDrill.icons() precedent, itself following the N2250
Radar.icons() precedent: "TextureRegion internals and
inherited region loading remain deferred; explicit inputs
carry region and topRegion field values", pinned as the
identity pure function
source_tractor_beam_turret_icons_state).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 built:
source_drill_icons_state(region, rotator_region, top_region)
returning icons ([region, rotator_region, top_region]).
All three params are explicit Variants (the N2312
precedent: TextureRegion values ride as Variants; the proof
passes string region ids, as the N2312 proof did with
["impact-drill", "impact-drill-top"]). (2) There is NO
driver tick line: icons() is a load-time region accessor,
not a per-tick write (the N2217 read/write + N2224 setStats
lifecycle precedent). One new result symbol: icons. Two
defs share the function (impact-drill, Blocks.java:3070;
eruption-drill, Blocks.java:3093); they differ only in the
region name the caller passes. (3) This slice does NOT
touch Turret.icons() (N1159), Radar.icons() (N2288) or
BurstDrill.icons() (N2312) -- each class owns its own
icons(). Slice sources: Drill.java + Block.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_set_stats import DEFERRED as N2332_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07DrillIconsProof'
ICONS_OWNER = 'SourceBurstDrillBuildState.source_drill_icons_state'
TESTS = ['test_c07_drill_icons_registration', 'test_all_c07_drill_icons_input_evidence_is_exact', 'test_drill_icons_state', 'test_reference_graph_and_actual_c07_drill_icons']
# The 2 slice sources the N2335 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['@Override', 'public TextureRegion[] icons(){', 'return new TextureRegion[]{region, rotatorRegion, topRegion};', 'public @Load("@-rotator") TextureRegion rotatorRegion;', 'public @Load("@-top") TextureRegion topRegion;', 'public TextureRegion region;', 'protected TextureRegion[] icons(){', 'public TextureRegion[] getGeneratedIcons(){', 'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;', 'public class Drill extends Block{']

# DEFERRED is carried from the N2332 register script via import --
# never retyped. The N2332 script's DEFERRED is a computed
# expression (list comprehension over the N2309 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. NOTE for the next
# slice: N2335's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval.
# No carried entry is dropped here: there is no Drill icons
# entry in the carried list. The stale 'BurstDrill
# shouldConsume gate' entry the N2296 list still carries
# (N2257 closed it, but N2296 branched from N2256) is left
# as-is -- ledger hygiene belongs to the main thread.
DEFERRED = list(N2332_DEFERRED) + [
    'Drill icons() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2335 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    icons_inputs = {
        'region': a('Variant', 'public TextureRegion region;', 'The inherited block region (Block.java:427, `public TextureRegion region;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=BLOCK),
        'rotator_region': a('Variant', 'public @Load("@-rotator") TextureRegion rotatorRegion;', 'The Drill rotator region (Drill.java:72, `public @Load("@-rotator") TextureRegion rotatorRegion;`, loaded as name + "-rotator"); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
        'top_region': a('Variant', 'public @Load("@-top") TextureRegion topRegion;', 'The Drill top region (Drill.java:73, `public @Load("@-top") TextureRegion topRegion;`, loaded as name + "-top"); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
    }
    icons_outputs = {
        'icons': a('Array', 'return new TextureRegion[]{region, rotatorRegion, topRegion};', 'The icons() return array: [region, rotatorRegion, topRegion], region first, exactly 3 elements (Drill.java:195, `return new TextureRegion[]{region, rotatorRegion, topRegion};`); impact-drill ["impact-drill", "impact-drill-rotator", "impact-drill-top"] (Blocks.java:3070) and eruption-drill ["eruption-drill", "eruption-drill-rotator", "eruption-drill-top"] (Blocks.java:3093). The Block.icons() base (Block.java:976-980, variants/teamRegion fold) and the getGeneratedIcons cache (Block.java:986-988) are deferred (the N2312 precedent) -- only the override return array is pinned.'),
    }
    return icons_inputs, icons_outputs


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
    icons_inputs, icons_outputs = definitions()

    entries = [
        ('N2335', ICONS_OWNER, 'source_drill_icons_state', DRILL, 'mindustry.world.blocks.production.Drill', 'Drill.icons()', icons_inputs, icons_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Drill icons() state from Drill.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Drill icons() state from Drill.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: icons.
    by_slice['N2335'] = [
        'source_drill_icons_state_result.icons',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2335', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.icons()', godot_owner=ICONS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2335'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
