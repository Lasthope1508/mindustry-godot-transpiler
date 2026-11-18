"""Register the Radar progress() accessor (N2263).

RadarBuild.progress() (Radar.java:93, `public float
progress(){` with `return progress;`, Radar.java:94)
overrides the base BuildingComp.progress() for Radar: it
is the discovery-progress accessor, returning the frame's
progress (the Java field `public float progress;`,
Radar.java:49, init 0.0), advanced by updateTile
(Radar.java:68, `progress += edelta() / discoveryTime;`,
clamped Radar.java:69, `progress = Mathf.clamp(progress);`,
N2248) and read by fogRadius() (Radar.java:56, `return
fogRadius * progress * smoothEfficiency;`, N2249). The
accessor is what the logic-dispatch hook reads for sensor
progress -- that hook waits for its own slice (the N2255
sense precedent) -- and what the write/read persistence
rows carry (Radar.java:101, `write.f(progress);` /
Radar.java:108, `progress = read.f();`), likewise their
own slice.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2249 built, following the N2249
fogRadius precedent: (frame) and the accessor returns the
frame's progress; no per-def param is needed (progress
is live frame state, not a def constant). (2) The frame
carries `progress` (absent -> 0.0, the Java field
`public float progress;`, Radar.java:49). (3) No driver
tick line lands here: the accessor is the read its callers
(the fogRadius() read, N2249; the future logic-dispatch
hook) share, and the updateTile advance that writes the
key already landed in N2248. (4) One new result symbol:
progress. Slice source: Radar.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
PROOF = '/root/C07RadarProgressProof'
PROGRESS_OWNER = 'SourceRadarBuildState.source_radar_progress_state'
TESTS = ['test_c07_radar_progress_registration', 'test_all_c07_radar_progress_input_evidence_is_exact', 'test_radar_progress_state', 'test_reference_graph_and_actual_c07_radar_progress']
# The 1 slice source the N2263 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
]
EXACT_EXPRS = ['public float progress(){', 'return progress;', 'public float progress;', 'progress += edelta() / discoveryTime;', 'progress = Mathf.clamp(progress);', 'return fogRadius * progress * smoothEfficiency;', 'public class Radar extends Block{', 'public class RadarBuild extends Building{']

# DEFERRED is carried from the N2227 register script via import --
# never retyped. Round 3: the N2247 (ex-N2229) senseObject(config)
# register is DROPPED (remote N2234 covers that leg), so the chain
# skips it and imports N2227 directly. One carried entry is
# DROPPED here, not carried:
# the Radar canPickup / progress() rows entry -- N2263 IS the
# progress() accessor slice, so carrying it would leave a stale
# "waits for its own slice" row for done work. The canPickup half
# of that entry is re-recorded below as its own entry, since
# canPickup still waits for its own slice.
DEFERRED = [e for e in N2227_DEFERRED if 'Radar canPickup / progress() rows' not in e] + [
    'Radar canPickup row (canPickup false, Radar.java:75-77) -- pickup, not tick state; waits for its own slice.',
    'Radar progress() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2248: the N2263 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    progress_inputs = {
        'frame': a('Dictionary', 'public float progress(){', 'The radar frame (RadarBuild.progress, Radar.java:93): carries progress (Java init 0.0, Radar.java:49).', source=RADAR),
    }
    progress_outputs = {
        'progress': a('float', 'return progress;', 'The discovery progress: progress() (Radar.java:93-94), `return progress;`; 0.0 before discovery (progress 0.0), 1.0 at full discovery, clamped to [0, 1] by the updateTile advance (Radar.java:68-69, N2248).', source=RADAR),
    }
    return progress_inputs, progress_outputs


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
    progress_inputs, progress_outputs = definitions()

    entries = [
        ('N2263', PROGRESS_OWNER, 'source_radar_progress_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.progress()', progress_inputs, progress_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar progress() accessor from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar progress() accessor from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: progress.
    by_slice['N2263'] = [
        'source_radar_progress_state_result.progress',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2263', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.progress()', godot_owner=PROGRESS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2263'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
