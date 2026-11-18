"""Register the BurstDrill ambientVolume() override (N2271).

BurstDrill.ambientVolume() (BurstDrill.java:123-125, `public
float ambientVolume(){`) returns `super.ambientVolume() *
Mathf.pow(progress(), 4f);` (:124). The super is
DrillBuild.ambientVolume (Drill.java:257-259, `return
efficiency * (size * size) / 4f;`): efficiency is the live
Building efficiency (`transient float efficiency;`,
BuildingComp.java:85) times the block size squared over
four. The super
formula is NOT ported in this slice: the caller passes the
already-computed super result as an explicit param (the
N2270 explicit-param precedent). progress() is
DrillBuild.progress (Drill.java:327-329, `return
dominantItem == null ? 0f : Mathf.clamp(progress /
getDrillTime(dominantItem));`): 0 when there is no dominant
item, else the DrillBuild `progress` field
(`public float progress;`, Drill.java:238) clamped by the
per-item drill time (`public float getDrillTime(Item item){`,
BurstDrill.java:53, `return drillTime /
drillMultipliers.get(item, 1f);`). progress() is NOT ported
for DrillBuild either (N700 `PortGame.
source_drill_progress_fraction` and N1627 `PortGame.
source_building_progress_state` are game-level progress,
not the DrillBuild override): the caller passes the
already-computed progress as an explicit param. Mathf.pow
is arc `public static float pow(float a, float b){`
(Mathf.java:212). The classes are `public class
BurstDrill extends Drill{` (BurstDrill.java:17) and `public
class Drill extends Block{` (Drill.java:27). Per-def supers
at efficiency 1: impact-drill (size 4, Blocks.java:3073)
4.0, eruption-drill (size 5, Blocks.java:3096) 6.25.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 / N2256 / N2258 / N2269 / N2262 /
N2266 built, after source_burst_drill_icons_state:
source_burst_drill_ambient_volume_state(
super_ambient_volume, progress) returning ambient_volume
(the super result times progress to the fourth). Both
inputs are explicit: the super formula and progress() are
unported for DrillBuild (see above); no frame param -- the
formula reads no live frame keys (the N2212 / N2224
per-def-param precedent, extended by the N2270
explicit-param precedent). (2) There is NO driver tick
line: ambientVolume is read per tick by the ambient-sound
live loop (`control.sound.loop(block.ambientSound, self(),
block.ambientSoundVolume * ambientVolume());`,
BuildingComp.java:2271); the driver side waits for the
ambient C mixer slice (N2264). (3) One new result symbol:
ambient_volume. Two defs share the function (impact-drill,
Blocks.java:3070, size 4; eruption-drill, Blocks.java:3093,
size 5); they differ only in the per-def super value the
caller passes. Slice sources: BurstDrill.java + Drill.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_set_stats import DEFERRED as N2266_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PROOF = '/root/C07BurstDrillAmbientVolumeProof'
AMBIENT_VOLUME_OWNER = 'SourceBurstDrillBuildState.source_burst_drill_ambient_volume_state'
TESTS = ['test_c07_burst_drill_ambient_volume_registration', 'test_all_c07_burst_drill_ambient_volume_input_evidence_is_exact', 'test_burst_drill_ambient_volume_state', 'test_reference_graph_and_actual_c07_burst_drill_ambient_volume']
# The 2 slice sources the N2271 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
    'core/src/mindustry/world/blocks/production/Drill.java',
]
EXACT_EXPRS = ['public float ambientVolume(){', 'return super.ambientVolume() * Mathf.pow(progress(), 4f);', 'return efficiency * (size * size) / 4f;', 'public float progress(){', 'return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));', 'public class BurstDrill extends Drill{', 'public class Drill extends Block{', 'public float progress;']

# DEFERRED is carried from the N2266 register script via import --
# never retyped. The N2266 script's DEFERRED is a computed
# expression (list(...) + [...]), NOT a plain list literal, so
# the N2218-style ast.literal_eval carry cannot recover it
# (ValueError: malformed node); the import recovers the runtime
# value verbatim. NOTE for the next slice: N2271's DEFERRED is
# likewise a computed list(...) + [...] expression, so carry it
# forward by import too, not by ast.literal_eval.
# No carried entry is dropped here: no carried entry is closed
# by this slice (the ambientVolume super leg and progress()
# stay deferred; the Windows proof debt is new).
DEFERRED = list(N2266_DEFERRED) + [
    'BurstDrill ambientVolume() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2271 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BurstDrill ambientVolume() super leg (DrillBuild.ambientVolume, Drill.java:257-259: `return efficiency * (size * size) / 4f;`) -- the N2271 pure function takes the super result as an explicit input; the Drill super formula waits for its own slice.',
    'DrillBuild.progress() (Drill.java:327-329: `return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));`) -- the N2271 pure function takes progress as an explicit input; the progress formula (dominant-item null gate + clamp by getDrillTime) waits for its own slice.',
    'BurstDrill ambientVolume() driver tick (the ambient-sound live loop reading ambientVolume() per tick, BuildingComp.java:2271 `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`) -- the N2271 pure function has no driver line; the driver side waits for the ambient C mixer slice (N2264).',
]


def definitions():
    def a(typ, expr, rule, source=BURST_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    ambient_volume_inputs = {
        'super_ambient_volume': a('float', 'return efficiency * (size * size) / 4f;', 'The DrillBuild.ambientVolume() super result (Drill.java:257-259, `return efficiency * (size * size) / 4f;`, efficiency times size squared over four); passed explicitly because the Drill super formula is NOT ported in this slice (the N2270 explicit-param precedent). Per-def values at efficiency 1: impact-drill (size 4, Blocks.java:3073) 4.0, eruption-drill (size 5, Blocks.java:3096) 6.25.', source=DRILL),
        'progress': a('float', 'return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));', 'The DrillBuild.progress() result (Drill.java:327-329, `return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));`, 0 with no dominant item, else the `progress` field clamped by the per-item drill time); passed explicitly because progress() is NOT ported for DrillBuild in this slice (N700 / N1627 are PortGame game-level progress, not the DrillBuild override) -- the N2270 explicit-param precedent.', source=DRILL),
    }
    ambient_volume_outputs = {
        'ambient_volume': a('float', 'return super.ambientVolume() * Mathf.pow(progress(), 4f);', 'The BurstDrill ambient volume: the super result times progress to the fourth power (BurstDrill.java:124, `return super.ambientVolume() * Mathf.pow(progress(), 4f);`, arc Mathf.pow at Mathf.java:212 `public static float pow(float a, float b){`); progress 0 silences the drill, progress 1 passes the super through.'),
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
        ('N2271', AMBIENT_VOLUME_OWNER, 'source_burst_drill_ambient_volume_state', BURST_DRILL, 'mindustry.world.blocks.production.BurstDrill', 'BurstDrillBuild.ambientVolume()', ambient_volume_inputs, ambient_volume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BurstDrill ambientVolume() state from BurstDrill.java + Drill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BurstDrill ambientVolume() state from BurstDrill.java + Drill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ambient_volume.
    by_slice['N2271'] = [
        'source_burst_drill_ambient_volume_state_result.ambient_volume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2271', dict(status='done', java_source=BURST_DRILL, java_class='mindustry.world.blocks.production.BurstDrill', java_method='BurstDrillBuild.ambientVolume()', godot_owner=AMBIENT_VOLUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2271'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
