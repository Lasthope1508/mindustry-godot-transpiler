"""Register the DrillBuild senseObject() + sense() pure functions (N2298).

DrillBuild overrides senseObject (Drill.java:281-284, `public
Object senseObject(LAccess sensor){` / `if(sensor ==
LAccess.firstItem) return dominantItem;` / `return
super.senseObject(sensor);`) and sense (Drill.java:333-336,
`public double sense(LAccess sensor){` / `if(sensor ==
LAccess.progress && dominantItem != null) return progress;`
/ `return super.sense(sensor);`) over the base defaults
BuildingComp.senseObject (BuildingComp.java:2128-2137,
`public Object senseObject(LAccess sensor){`, whose firstItem
leg is `case firstItem -> items == null ? null :
items.first();` and whose default is `default -> noSensed;`)
and BuildingComp.sense (BuildingComp.java:2093, `public
double sense(LAccess sensor){`), whose default is `default
-> Float.NaN; //gets converted to null in logic`
(BuildingComp.java:2123). The sensor spellings are the
LAccess enum names `firstItem,` (LAccess.java:8) and
`progress,` (:28). sense() returns the RAW progress field
(`public float progress;`, Drill.java:238) -- NOT the clamped
progress() (Drill.java:327-329, `return dominantItem == null
? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));`),
which is its own slice. senseObject returns dominantItem
itself for firstItem -- null when no dominant item is bound --
and the caller-passed super result otherwise; sense returns
progress for the progress sensor with a dominant item and the
caller-passed super result otherwise.

RED decisions (resolved at RED): (1) Two pure functions on
the same family file N2149 built, next to the N2283 drawSelect
row (both are DrillBuild overrides), following the N2293
Turret sense precedent exactly: (frame, sensor, ...) and the
generic laccess wire shape (`handled` + `sense_value` +
`sense_value_is_nan` for sense; `handled` +
`sense_object_value` for senseObject, the N2223 senseObject
precedent), so a caller can tell "handled" from "not handled
-- fall through to super". (2) The super legs are the live
BuildingComp sense (N636 / N1078-N1085) and arrive as
explicit params (the N2317/N2277 super-as-param precedent):
the fallthrough legs return the caller-passed super result
instead of null. (3) All live values arrive as explicit
params (the N2188 precedent) -- the dominant item is `public
Item dominantItem;` (Drill.java:244), set by the N2262
ore/dominant binding; the caller passes it as
(has_dominant_item, dominant_item), the N2311/N2321/N2281
explicit-param precedent. (4) NO driver line: sense is a
logic read, not a tick write (the N2206 / N2208 / N2223
precedent); the logic-processor dispatch hook is its own
later slice. Five new result symbols: sense_object handled +
sense_object_value, sense handled + sense_value +
sense_value_is_nan. Slice sources: Drill.java +
BuildingComp.java + LAccess.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_burst_drill_liquid_rows import DEFERRED as N2296_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07DrillSenseProof'
SENSE_OBJECT_OWNER = 'SourceBurstDrillBuildState.source_drill_sense_object_state'
SENSE_OWNER = 'SourceBurstDrillBuildState.source_drill_sense_state'
TESTS = ['test_c07_drill_sense_registration', 'test_all_c07_drill_sense_input_evidence_is_exact', 'test_drill_sense_state', 'test_reference_graph_and_actual_c07_drill_sense']
# The 3 slice sources the N2298 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = ['public Object senseObject(LAccess sensor){', 'if(sensor == LAccess.firstItem) return dominantItem;', 'return super.senseObject(sensor);', 'public double sense(LAccess sensor){', 'if(sensor == LAccess.progress && dominantItem != null) return progress;', 'return super.sense(sensor);', 'public float progress;', 'public Item dominantItem;', 'public class DrillBuild extends Building{', 'public class Drill extends Block{', 'case firstItem -> items == null ? null : items.first();', 'default -> noSensed;', 'default -> Float.NaN; //gets converted to null in logic', 'firstItem,', 'progress,']

# DEFERRED is carried from the N2296 register script via import --
# never retyped. No carried entry defers DrillBuild sense /
# senseObject -- N2298 IS that slice. The super-leg dispatch
# hook and the clamped progress() wait for their own slices.
DEFERRED = N2296_DEFERRED + [
    'Drill sense Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2298 proof runs headless on Linux here and waits for a Windows Godot run.',
    'DrillBuild.sense() / senseObject() logic-processor dispatch hook -- the default legs fall through to BuildingComp.sense / senseObject (BuildingComp.java:2093/2128); the dispatch hook that calls Drill sense then falls back to the BuildingComp sense bridge (SourceBuildingSenseState.gd) is its own later slice.',
    'DrillBuild.progress() clamped progress -- sense() returns the raw progress field (Drill.java:334), NOT progress() (Drill.java:327-329, `return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));`); the clamped progress() is its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_object_inputs = {
        'frame': a('Dictionary', 'public Object senseObject(LAccess sensor){', 'The drill frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'sensor': a('String', 'public Object senseObject(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (LAccess.java:8 `firstItem,`): only firstItem is handled here, anything else falls through to super.senseObject (Drill.java:283, `return super.senseObject(sensor);`).'),
        'has_dominant_item': a('bool', 'public Item dominantItem;', 'Whether a dominant item is bound: the DrillBuild.dominantItem field (Drill.java:244) is non-null, set by the N2262 ore/dominant binding; passed explicitly because the caller owns the binding (the N2311/N2321/N2281 explicit-param precedent).'),
        'dominant_item': a('Variant', 'public Item dominantItem;', 'The bound dominant item: the DrillBuild.dominantItem field (Drill.java:244), returned for the firstItem sensor (Drill.java:282, `if(sensor == LAccess.firstItem) return dominantItem;`); null when no dominant item is bound -- Java returns dominantItem itself, so firstItem reads null then; passed explicitly because the caller owns the binding.'),
        'super_sense_object_value': a('Variant', 'return super.senseObject(sensor);', 'The already-computed super result: BuildingComp.senseObject (BuildingComp.java:2128-2137, firstItem leg `case firstItem -> items == null ? null : items.first();`, default `default -> noSensed;`), live at N636 (PortGame.source_building_sense_object_state); the caller passes it (the N2317/N2277 super-as-param precedent) and the fallthrough leg returns it. The expr is the Drill fallthrough call site (Drill.java:283).'),
    }
    sense_object_outputs = {
        'handled': a('bool', 'return super.senseObject(sensor);', 'Whether this slice handled the sensor (firstItem only); false means "not handled -- the returned value is the super result" (the N2223 sense precedent).'),
        'sense_object_value': a('Variant', 'if(sensor == LAccess.firstItem) return dominantItem;', 'The sensed object: dominantItem for "firstItem" (Drill.java:282), null when no dominant item is bound, or the caller-passed super result for any other sensor (Drill.java:283).'),
    }
    sense_inputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The drill frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (LAccess.java:28 `progress,`): only progress is handled here, anything else falls through to super.sense (Drill.java:335, `return super.sense(sensor);`).'),
        'has_dominant_item': a('bool', 'public Item dominantItem;', 'Whether a dominant item is bound: the DrillBuild.dominantItem field (Drill.java:244) is non-null, set by the N2262 ore/dominant binding; the progress leg requires it (Drill.java:334, `if(sensor == LAccess.progress && dominantItem != null) return progress;`); passed explicitly because the caller owns the binding (the N2311/N2321/N2281 explicit-param precedent).'),
        'progress': a('float', 'public float progress;', 'The raw drill progress field: DrillBuild.progress (Drill.java:238), advanced in updateTile (N2294); returned for the progress sensor with a dominant item (Drill.java:334) -- NOT the clamped progress() (Drill.java:327-329), which is its own slice; passed explicitly because no frame key stamps it yet.'),
        'super_sense_value': a('Variant', 'return super.sense(sensor);', 'The already-computed super result: BuildingComp.sense (BuildingComp.java:2093), live at N1078-N1085 (PortGame.source_building_sense_*_state); the caller passes it (the N2317/N2277 super-as-param precedent) and the fallthrough leg returns it; null when the super was NaN (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`). The expr is the Drill fallthrough call site (Drill.java:335).'),
        'super_sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the caller-passed super result is NaN: true when the super sensor fell through to the BuildingComp default (BuildingComp.java:2123), which converts to null in logic; false for every handled super row.', source=BUILDING_COMP),
    }
    sense_outputs = {
        'handled': a('bool', 'return super.sense(sensor);', 'Whether this slice handled the sensor (progress with a dominant item only); false means "not handled -- the returned value is the super result" (the N2223 sense precedent).'),
        'sense_value': a('float', 'if(sensor == LAccess.progress && dominantItem != null) return progress;', 'The sensed value: the raw progress field for "progress" with a dominant item (Drill.java:334), or the caller-passed super result for any other sensor (Drill.java:335); null when the sensor is not handled and the super was NaN.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the sensed value is NaN: true only when the sensor falls through to a NaN super result (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`, converts to null in logic); false for the handled progress row.', source=BUILDING_COMP),
    }
    return sense_object_inputs, sense_object_outputs, sense_inputs, sense_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    sense_object_inputs, sense_object_outputs, sense_inputs, sense_outputs = definitions()

    entries = [
        ('N2298', SENSE_OBJECT_OWNER, 'source_drill_sense_object_state', DRILL, 'mindustry.world.blocks.production.Drill.DrillBuild', 'DrillBuild.senseObject(LAccess)', sense_object_inputs, sense_object_outputs, True, 'Dictionary'),
        ('N2298', SENSE_OWNER, 'source_drill_sense_state', DRILL, 'mindustry.world.blocks.production.Drill.DrillBuild', 'DrillBuild.sense(LAccess)', sense_inputs, sense_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild senseObject() + sense() state from Drill.java + BuildingComp.java + LAccess.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild senseObject() + sense() state from Drill.java + BuildingComp.java + LAccess.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: sense_object handled,
    # sense_object_value, sense handled, sense_value,
    # sense_value_is_nan.
    by_slice['N2298'] = [
        'source_drill_sense_object_state_result.handled',
        'source_drill_sense_object_state_result.sense_object_value',
        'source_drill_sense_state_result.handled',
        'source_drill_sense_state_result.sense_value',
        'source_drill_sense_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2298', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill.DrillBuild', java_method='DrillBuild.senseObject(LAccess); DrillBuild.sense(LAccess)', godot_owner=SENSE_OBJECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2298'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
