"""Register the RepairTurret icons() return array (N2227).

RepairTurret.icons() (RepairTurret.java:101-104, `@Override
public TextureRegion[] icons(){`) returns the two loaded
regions in order (`return new TextureRegion[]{baseRegion,
region};` -- RepairTurret.java:103). baseRegion is the
block's own base field (`public @Load(value = "@-base",
fallback = "block-@size") TextureRegion baseRegion;` --
RepairTurret.java:47) and region is the inherited block
region (`public TextureRegion region;` -- Block.java:427).
The Block.icons() base (`protected TextureRegion[]
icons(){` -- Block.java:976-980, the variants/teamRegion
fold) is NOT this slice: RepairTurret overrides it, so
only the override's return array is pinned; the
getGeneratedIcons cache (`public TextureRegion[]
getGeneratedIcons(){` -- Block.java:986-988, `return
generatedIcons == null ? (generatedIcons = icons()) :
generatedIcons;`) is likewise deferred (the N1232
TractorBeamTurret.icons() precedent: "TextureRegion
internals and inherited region loading remain deferred;
explicit inputs carry baseRegion and region field values",
pinned as the identity pure function
source_tractor_beam_turret_icons_state).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2174 / N2188 / N2209 / N2212-N2215 /
N2217 / N2219-N2226 built:
source_repair_turret_icons_state(base_region, region)
returning icons ([base_region, region]). Both params are
explicit Variants (the N1232 precedent: TextureRegion
values ride as Variants; the proof passes string region
ids, as the N1232 proof did with ["tractor-base",
"tractor-top"]). (2) There is NO driver tick line: icons()
is a load-time region accessor, not a per-tick write (the
N2217 read/write + N2224 setStats lifecycle precedent).
One new result symbol: icons. Slice sources:
RepairTurret.java + Block.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_init import DEFERRED as N2226_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretIconsProof'
ICONS_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_icons_state'
TESTS = ['test_c07_repair_turret_icons_registration', 'test_all_c07_repair_turret_icons_input_evidence_is_exact', 'test_repair_turret_icons_state', 'test_reference_graph_and_actual_c07_repair_turret_icons']
# The 2 slice sources the N2227 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['@Override', 'public TextureRegion[] icons(){', 'return new TextureRegion[]{baseRegion, region};', 'public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;', 'public TextureRegion region;', 'protected TextureRegion[] icons(){', 'public TextureRegion[] getGeneratedIcons(){', 'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;', 'public class RepairTurret extends Block{']

# DEFERRED is carried from the N2226 register script via import --
# never retyped. The N2226 script's DEFERRED is a computed
# expression (list comprehension over the N2225 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. NOTE for the next
# slice: N2227's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval.
# One carried entry is DROPPED here, not carried: the N2226
# entry deferring the RepairTurret icons() return array to
# "its own slice (N2227)" -- N2227 IS that slice, so carrying
# it would leave a stale "waits for its own slice" row for done
# work. Every other carried entry still waits for its own slice.
DEFERRED = [e for e in N2226_DEFERRED if 'RepairTurret icons()' not in e] + [
    'RepairTurret icons() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2226: the N2227 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    icons_inputs = {
        'base_region': a('Variant', 'public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;', 'The block base region (RepairTurret.java:47, `public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;`, loaded as name + "-base" with the "block-@size" fallback); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
        'region': a('Variant', 'public TextureRegion region;', 'The inherited block region (Block.java:427, `public TextureRegion region;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=BLOCK),
    }
    icons_outputs = {
        'icons': a('Array', 'return new TextureRegion[]{baseRegion, region};', 'The icons() return array: [baseRegion, region], base first, exactly 2 elements (RepairTurret.java:103, `return new TextureRegion[]{baseRegion, region};`); repair-point ["repair-point-base", "repair-point"], repair-turret ["repair-turret-base", "repair-turret"] (Blocks.java:6386, :6396). The Block.icons() base (Block.java:976-980, variants/teamRegion fold) and the getGeneratedIcons cache (Block.java:986-988) are deferred (the N1232 precedent) -- only the override return array is pinned.'),
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
        ('N2227', ICONS_OWNER, 'source_repair_turret_icons_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret', 'RepairTurret.icons()', icons_inputs, icons_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret icons() state from RepairTurret.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret icons() state from RepairTurret.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: icons.
    by_slice['N2227'] = [
        'source_repair_turret_icons_state_result.icons',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2227', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret', java_method='RepairTurret.icons()', godot_owner=ICONS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2227'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
