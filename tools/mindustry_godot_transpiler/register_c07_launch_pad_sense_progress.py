"""Register the LaunchPad sense(progress) override (N2206).

The LaunchPad's sense(progress) override, following the N2205
pure-function precedent and the N2203 damage() precedent (a pure
function with NO driver tick line -- sense is a logic read, not a
tick write). LaunchPadBuild overrides sense: `if(sensor ==
LAccess.progress) return Mathf.clamp(launchCounter /
launchTime);` (LaunchPad.java:99), and non-progress sensors fall
through to super.sense (LaunchPad.java:100, `return
super.sense(sensor);`) -- but the BuildingComp super switch has
NO progress case (BuildingComp.java:2093, `public double
sense(LAccess sensor){` + 2123, `default -> Float.NaN; //gets
converted to null in logic`), so a logic processor reading
`progress` on a launch pad currently gets NaN/null while Java
returns the clamped launch fraction. N2206 closes that gap with
one pure function (source_launch_pad_sense_state) over one frame
key (`launch_counter`, float) plus the sensor string plus the
per-def launchTime parameter: the function takes (frame, sensor,
launch_time) -- the sensor parameter because sense is a logic
read over an enum, not a tick write -- and returns the generic
laccess wire shape (`sense_value` + `sense_value_is_nan`,
SourceBlockSenseState.laccess_state) plus an explicit `handled`
flag, so a caller can tell "handled, value is a clamped
fraction" from "not handled -- fall through to super.sense".
RED decisions (pinned by this slice): (1) sensor spelling is
"progress" -- LAccess.java:28 lists `progress,`, and the generic
sense layer matches sensor strings by enum name. (2) An absent
`launch_counter` key reads 0.0, NOT NaN: `public float
launchCounter;` defaults to 0.0f at Java init, so a freshly
built pad senses clamp(0 / launchTime) = 0.0 -- the only
observable Java behavior at init -- and returning 0.0 regresses
nothing, because no consumer reads this value yet (the
sense-dispatch hook does not exist); absent -> NaN would
preserve the port's current UNFAITHFUL output instead. The
N2205 absent-means-"no observation yet" precedent does not
apply here: there, absent -> false would zero efficiency for
every live pad (a live regression); here, absent -> 0.0 IS the
Java init value. (3) The clamp edge: counter at/above
launchTime senses 1.0 (a full pad waiting for items), counter 0
senses 0.0, a negative counter (impossible in Java -- the
counter only grows and resets to 0) floors to 0.0 anyway. The
per-def launchTime differs (launch-pad 1200f = 60f * 20,
Blocks.java:6794; advanced-launch-pad 1800f = 60f * 30,
Blocks.java:6804; class default 1f, LaunchPad.java:32), and the
catalog carries no launchTime property, so the caller selects
it by block id (SOURCE_LAUNCH_PAD_LAUNCH_TIMES) and passes it
in. No new frame key, no SOURCE_CONSUMER_FRAME_META_KEYS
change, no simulate_factory wiring change, no driver tick line.
Shard note: LaunchPad.java lives under /world/blocks/campaign/
and no campaign_slices shard file exists yet; the register
rebuilds extension shards from source_ssot_modules.json (the
N2172 precedent), so the GREEN register run must record which
shard files actually change.

Composition, not re-implementation: the generic laccess wire
(SourceBlockSenseState.laccess_state) already defines the
`sense_value` + `sense_value_is_nan` shape for Block-level sense
(Block.java:1651-1664). N2206 does not touch it -- it is the
Block-level sense, takes no frame/launch-counter input, and
adding family state there would break its generic shape; the
BuildingComp sense bridges are likewise the wrong layer (they
port the BuildingComp switch, which has no progress case by
design). N2206 supplies the missing per-family pure function;
the logic-processor integration -- how a logic `sense progress`
read on a placed launch pad reaches this family function -- is
its own later slice with a documented limit. No updateTile
advance: the launchCounter advance / LaunchPayload spawn /
items.clear (LaunchPad.java:143-161) waits for its own slice;
the proof carries no launch/counter/payload keys. Two defs
share the implementation (launch-pad, size 3, itemCapacity
100, launchTime 60f * 20; advanced-launch-pad, size 4,
itemCapacity 100, launchTime 60f * 30, liquidCapacity 40f,
Blocks.java:6790-6809). Do NOT confuse sense with progress():
`public float progress(){` + `return 0f;`
(BuildingComp.java:617-619) is a DIFFERENT method the sense
switch never calls.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_launch_pad_should_consume import DEFERRED as _N2205_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LAUNCH_PAD = 'core/src/mindustry/world/blocks/campaign/LaunchPad.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07LaunchPadSenseProgressProof'
OWNER = 'SourceLaunchPadBuildState.source_launch_pad_sense_state'
TESTS = ['test_c07_launch_pad_sense_progress_registration', 'test_all_c07_launch_pad_sense_progress_input_evidence_is_exact', 'test_launch_pad_sense_progress_state', 'test_reference_graph_and_actual_c07_launch_pad_sense_progress']
# The 5 slice sources the N2206 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = ['public double sense(LAccess sensor){', 'if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);', 'return super.sense(sensor);', 'public float launchCounter;', 'public float launchTime = 1f;', 'public class LaunchPad extends Block{', 'public class LaunchPadBuild extends Building{', 'if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', 'public float progress(){', 'return 0f;', 'progress,', 'Mathf.clamp(build.launchCounter / launchTime)', 'default -> Float.NaN; //gets converted to null in logic', 'launchTime = 60f * 20;', 'launchTime = 60f * 30;', 'size = 3;', 'size = 4;', 'itemCapacity = 100;']

# DEFERRED is carried from the N2205 register script via import --
# never retyped. The N2205 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2204 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2206's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# sense(progress) override itself is NOT carried as deferred: it
# is THIS slice (N2206) -- the inherited N2205 entry still names
# it as waiting, which is stale history, superseded by this
# slice.
DEFERRED = list(_N2205_DEFERRED) + [
    'LaunchPad sense(progress) Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2205: the N2206 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=LAUNCH_PAD, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2206_inputs = {
        'frame': f('Dictionary', 'public float launchCounter;', 'The building frame carrying the launch_counter observation (LaunchPad.java:84, `public float launchCounter;`, stamped by the future updateTile advance every tick after the launch gate consult) plus the sensor read; a missing launch_counter key reads 0.0 -- the Java init default, not "no observation yet" -- because `public float launchCounter;` defaults to 0.0f, so a freshly built pad senses clamp(0 / launchTime) = 0.0.'),
        'sensor': f('String', 'progress,', 'The LAccess sensor enum name as a string (LAccess.java:28 lists `progress,`); the generic sense layer matches sensor strings by enum name ("health", "maxHealth", "color", ...). Only "progress" is handled by this override; any other sensor falls through to super.sense (LaunchPad.java:100, `return super.sense(sensor);`).', source=LACCESS),
        'launch_time': f('float', 'public float launchTime = 1f;', 'The per-def launchTime the sense fraction runs the counter against (LaunchPad.java:32, the class default 1f): launch-pad 1200f (Blocks.java:6794, `launchTime = 60f * 20;`) and advanced-launch-pad 1800f (Blocks.java:6804, `launchTime = 60f * 30;`); the caller selects it by block id from SOURCE_LAUNCH_PAD_LAUNCH_TIMES and passes it in.'),
    }
    n2206_outputs = {
        'sense_value': f('float', 'if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);', 'The sensed progress value (LaunchPad.java:98-101): the clamped launch fraction `Mathf.clamp(launchCounter / launchTime)` when the sensor is "progress" (handled true, sense_value_is_nan false), null when the sensor is not handled (fall through to super.sense, handled false, sense_value_is_nan true).'),
    }
    return n2206_inputs, n2206_outputs


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
    inputs, outputs = definitions()
    for keys in (inputs, outputs):
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + len(inputs) + len(outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    n2206_inputs, n2206_outputs = definitions()

    entries = [
        ('N2206', OWNER, 'source_launch_pad_sense_state', LAUNCH_PAD, 'mindustry.world.blocks.campaign.LaunchPad.LaunchPadBuild', 'LaunchPadBuild.sense()', n2206_inputs, n2206_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaunchPad sense(progress) override from LaunchPad.java / BuildingComp.java / LAccess.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaunchPad sense(progress) override from LaunchPad.java / BuildingComp.java / LAccess.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the sense value, its only result key.
    by_slice['N2206'] = [
        'source_launch_pad_sense_state_result.sense_value',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2206', dict(status='done', java_source=LAUNCH_PAD, java_class='mindustry.world.blocks.campaign.LaunchPad.LaunchPadBuild', java_method='LaunchPadBuild.sense()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2206'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
