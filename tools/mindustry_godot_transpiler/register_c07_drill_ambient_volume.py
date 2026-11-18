"""Register the DrillBuild ambientVolume() super leg (N2277).

DrillBuild.ambientVolume() (Drill.java:257-259, `public
float ambientVolume(){`) returns `efficiency * (size *
size) / 4f;` (:258). `efficiency` is the live Building
efficiency (`transient float efficiency;`,
BuildingComp.java:85), carried on the frame (absent
defaults to 0.0 -- the N2258 liquid-rows frame-key
precedent). `size` is the block size in tiles (`public
int size = 1;`, Block.java:215), a per-def param passed
explicitly (the N2212 per-def-param precedent):
impact-drill size 4 (Blocks.java:3073), eruption-drill
size 5 (Blocks.java:3096). At efficiency 1 the super is
4.0 vs 6.25 -- the exact values N2271 takes as its
explicit super input (BurstDrill.ambientVolume(),
BurstDrill.java:123-125, `return super.ambientVolume()
* Mathf.pow(progress(), 4f);`, BurstDrill.java:124).
This slice CLOSES the super-leg deferred entry N2271
carried: the Drill super formula is now ported. The
classes are `public class Drill extends Block{`
(Drill.java:27) and `public class DrillBuild extends
Building{` (Drill.java:237). The defs are
`impactDrill = new BurstDrill("impact-drill"){{`
(Blocks.java:3070) and `eruptionDrill = new
BurstDrill("eruption-drill"){{` (Blocks.java:3093).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 / N2256 / N2258 / N2269 / N2262 /
N2266 / N2271 built, after
source_burst_drill_ambient_volume_state:
source_drill_ambient_volume_state(frame, size) returning
ambient_volume (frame efficiency times size squared over
four). efficiency is a frame key (the N2258 precedent --
the power fold that computes it is ported); size is an
explicit per-def int param (the N2212 precedent). (2)
There is NO driver tick line: ambientVolume is read per
tick by the ambient-sound live loop
(`control.sound.loop(block.ambientSound, self(),
block.ambientSoundVolume * ambientVolume());`,
BuildingComp.java:2271); the driver side waits for the
ambient C mixer slice (N2264). (3) One new result symbol:
ambient_volume. Two defs share the function (impact-drill,
Blocks.java:3070, size 4; eruption-drill, Blocks.java:3093,
size 5); they differ only in the per-def size the caller
passes. Slice sources: Drill.java + BuildingComp.java +
Block.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_ambient_volume import DEFERRED as N2271_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07DrillAmbientVolumeProof'
AMBIENT_VOLUME_OWNER = 'SourceBurstDrillBuildState.source_drill_ambient_volume_state'
TESTS = ['test_c07_drill_ambient_volume_registration', 'test_all_c07_drill_ambient_volume_input_evidence_is_exact', 'test_drill_ambient_volume_state', 'test_reference_graph_and_actual_c07_drill_ambient_volume']
# The 4 slice sources the N2277 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public float ambientVolume(){', 'return efficiency * (size * size) / 4f;', 'transient float efficiency;', 'public int size = 1;', 'public class Drill extends Block{', 'public class DrillBuild extends Building{', 'impactDrill = new BurstDrill("impact-drill"){{', 'eruptionDrill = new BurstDrill("eruption-drill"){{']

# DEFERRED is carried from the N2271 register script via import --
# never retyped. The N2271 script's DEFERRED is a computed
# expression (list(...) + [...]), NOT a plain list literal, so
# the N2218-style ast.literal_eval carry cannot recover it
# (ValueError: malformed node); the import recovers the runtime
# value verbatim. One carried entry is DROPPED here, not carried:
# the BurstDrill ambientVolume() super leg entry -- N2277 IS the
# super-leg slice, so carrying it would leave a stale "waits for
# its own slice" row for done work. The DrillBuild.progress()
# entry and the ambientVolume driver-tick entry stay deferred --
# those slices own them.
DEFERRED = [e for e in N2271_DEFERRED if 'BurstDrill ambientVolume() super leg' not in e] + [
    'DrillBuild ambientVolume() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2277 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    ambient_volume_inputs = {
        'frame': a('Dictionary', 'public float ambientVolume(){', 'The DrillBuild frame (DrillBuild.ambientVolume, Drill.java:257-259): carries efficiency (float, absent -> 0.0 -- `transient float efficiency;`, BuildingComp.java:85); the family-convention first arg (every BurstDrill pure function that reads live state takes it).', source=DRILL),
        'size': a('int', 'public int size = 1;', 'The block size in tiles (`public int size = 1;`, Block.java:215); passed explicitly because it is per-def static state, not live frame state (the N2212 per-def-param precedent). Per-def values: impact-drill size 4 (Blocks.java:3073), eruption-drill size 5 (Blocks.java:3096).', source=BLOCK),
    }
    ambient_volume_outputs = {
        'ambient_volume': a('float', 'return efficiency * (size * size) / 4f;', 'The DrillBuild ambient volume: the frame efficiency times the block size squared over four (Drill.java:258, `return efficiency * (size * size) / 4f;`); efficiency 0 silences the drill, efficiency 1 with size 4 gives 4.0, with size 5 gives 6.25.'),
    }
    return ambient_volume_inputs, ambient_volume_outputs


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
    ambient_volume_inputs, ambient_volume_outputs = definitions()

    entries = [
        ('N2277', AMBIENT_VOLUME_OWNER, 'source_drill_ambient_volume_state', DRILL, 'mindustry.world.blocks.production.Drill', 'DrillBuild.ambientVolume()', ambient_volume_inputs, ambient_volume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild ambientVolume() state from Drill.java + BuildingComp.java + Block.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild ambientVolume() state from Drill.java + BuildingComp.java + Block.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ambient_volume.
    by_slice['N2277'] = [
        'source_drill_ambient_volume_state_result.ambient_volume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2277', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='DrillBuild.ambientVolume()', godot_owner=AMBIENT_VOLUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2277'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
