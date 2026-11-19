"""Register the DrillBuild shouldAmbientSound() gate (N2305).

DrillBuild.shouldAmbientSound() (Drill.java:252-254, `public
boolean shouldAmbientSound(){`) returns `efficiency > 0.01f
&& items.total() < itemCapacity;` (:253). `efficiency` is
the live Building efficiency (`transient float
efficiency;`, BuildingComp.java:85). `items.total()` is
the cached ItemModule total (`public int total(){` with
`return total;`, ItemModule.java:174-175). `itemCapacity`
is the per-def capacity (`public int itemCapacity = 10;`,
Block.java:75, with `itemCapacity = 40;`,
Blocks.java:3078, for impact-drill and `itemCapacity =
60;`, Blocks.java:3107, for eruption-drill). The
BuildingComp default delegates to shouldConsume (`public
boolean shouldAmbientSound(){` with `return
shouldConsume();`, BuildingComp.java:1212-1214) -- the
Drill override replaces it with the efficiency gate. The
gate is read per tick by the ambient-sound live loop
(`if(!headless && block.ambientSound != Sounds.none &&
shouldAmbientSound()){` with
`control.sound.loop(block.ambientSound, self(),
block.ambientSoundVolume * ambientVolume());`,
BuildingComp.java:2270-2271). The classes are `public
class Drill extends Block{` (Drill.java:27) and `public
class DrillBuild extends Building{` (Drill.java:237);
BurstDrillBuild inherits DrillBuild (`public class
BurstDrill extends Drill{`, BurstDrill.java:17, with
`public class BurstDrillBuild extends DrillBuild{`,
BurstDrill.java:70). The defs are `impactDrill = new
BurstDrill("impact-drill"){{` (Blocks.java:3070) and
`eruptionDrill = new BurstDrill("eruption-drill"){{`
(Blocks.java:3093).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2149 / N2256 / N2258 / N2269 / N2262 /
N2266 / N2271 / N2277 built, after
source_drill_ambient_volume_state:
source_drill_should_ambient_sound_state(frame, efficiency,
items_total, item_capacity) returning
should_ambient_sound. The three inputs are explicit params
(the N2271 / N2277 super-as-param precedent): the caller
passes the already-folded efficiency and the live items
total; frame is the canonical first param of this family
file. (2) This is a Drill-local boolean predicate -- NOT
part of the ambient B/C chain (B = RepairTurret driver
tick, Windows line; C = SoundControl.updateLoops mixer,
N2304 held): it gates the loop call, it is not the loop
itself, and it touches no audio playback and no driver
tick line. It is distinct from the ambient volume (N2277)
and from shouldConsume (N2295, which also requires
`enabled && dominantItem != null`). (3) One new result
symbol: should_ambient_sound. Two defs share the function
(impact-drill, Blocks.java:3070, itemCapacity 40;
eruption-drill, Blocks.java:3093, itemCapacity 60); they
differ only in the per-def capacity the caller passes.
Slice sources: Drill.java + BuildingComp.java + Block.java
+ Blocks.java + ItemModule.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_ambient_volume import DEFERRED as N2277_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
BURST_DRILL = 'core/src/mindustry/world/blocks/production/BurstDrill.java'
PROOF = '/root/C07DrillShouldAmbientSoundProof'
SHOULD_AMBIENT_SOUND_OWNER = 'SourceBurstDrillBuildState.source_drill_should_ambient_sound_state'
TESTS = ['test_c07_drill_should_ambient_sound_registration', 'test_all_c07_drill_should_ambient_sound_input_evidence_is_exact', 'test_drill_should_ambient_sound_state', 'test_reference_graph_and_actual_c07_drill_should_ambient_sound']
# The 6 slice sources the N2305 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/modules/ItemModule.java',
    'core/src/mindustry/world/blocks/production/BurstDrill.java',
]
EXACT_EXPRS = ['public boolean shouldAmbientSound(){', 'return efficiency > 0.01f && items.total() < itemCapacity;', 'transient float efficiency;', 'public int total(){', 'return total;', 'public int itemCapacity = 10;', 'itemCapacity = 40;', 'itemCapacity = 60;', 'public class Drill extends Block{', 'public class DrillBuild extends Building{', 'public class BurstDrill extends Drill{', 'public class BurstDrillBuild extends DrillBuild{', 'return shouldConsume();', 'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){', 'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());']

# DEFERRED is carried from the N2277 register script via import --
# never retyped. No carried entry is dropped: this slice closes
# no deferred entry (the ambient-sound driver-tick entry waits
# for ambient C, N2304, and the ambientVolume entries stay
# deferred for their own slices).
DEFERRED = N2277_DEFERRED + [
    'Drill shouldAmbientSound Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2277: the N2305 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_ambient_sound_inputs = {
        'frame': a('Dictionary', 'public boolean shouldAmbientSound(){', 'The DrillBuild frame (DrillBuild.shouldAmbientSound, Drill.java:252-254); the family-convention first arg (every BurstDrill pure function takes it). No live keys are read from the frame -- all three gate inputs are explicit params.', source=DRILL),
        'efficiency': a('float', 'transient float efficiency;', 'The live Building efficiency (`transient float efficiency;`, BuildingComp.java:85); passed explicitly because the caller (the ambient live loop) already holds the folded efficiency (the N2271 / N2277 super-as-param precedent). The gate needs efficiency strictly above 0.01.', source=BUILDING_COMP),
        'items_total': a('int', 'public int total(){', 'The cached ItemModule total (`public int total(){` with `return total;`, ItemModule.java:174-175); passed explicitly because the caller already holds the live items total (the N2271 / N2277 super-as-param precedent).', source=ITEM_MODULE),
        'item_capacity': a('int', 'public int itemCapacity = 10;', 'The per-def item capacity, 40 for the impact-drill def (Blocks.java:3078) and 60 for the eruption-drill def (Blocks.java:3107); passed explicitly because the pure function cannot reach the catalog (the N2212 per-def-param precedent); the Block default is 10 (Block.java:75).', source=BLOCK),
    }
    should_ambient_sound_outputs = {
        'should_ambient_sound': a('bool', 'return efficiency > 0.01f && items.total() < itemCapacity;', 'The DrillBuild ambient-sound gate (Drill.java:253): efficiency strictly above 0.01 AND items_total strictly below item_capacity; the gate is read per tick by the ambient-sound live loop (BuildingComp.java:2270-2271).'),
    }
    return should_ambient_sound_inputs, should_ambient_sound_outputs


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
    should_ambient_sound_inputs, should_ambient_sound_outputs = definitions()

    entries = [
        ('N2305', SHOULD_AMBIENT_SOUND_OWNER, 'source_drill_should_ambient_sound_state', DRILL, 'mindustry.world.blocks.production.Drill', 'DrillBuild.shouldAmbientSound()', should_ambient_sound_inputs, should_ambient_sound_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild shouldAmbientSound() gate from Drill.java + BuildingComp.java + Block.java + Blocks.java + ItemModule.java + BurstDrill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild shouldAmbientSound() gate from Drill.java + BuildingComp.java + Block.java + Blocks.java + ItemModule.java + BurstDrill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2305'] = [
        'source_drill_should_ambient_sound_state_result.should_ambient_sound',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2305', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='DrillBuild.shouldAmbientSound()', godot_owner=SHOULD_AMBIENT_SOUND_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2305'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
