"""Register the Radar write/read persistence (N2267).

RadarBuild.write()/read() (Radar.java:98-101 / :105-108)
persist exactly ONE field, the discovery progress
(`write.f(progress);`, Radar.java:101, inside `public void
write(Writes write){` / `super.write(write);`,
Radar.java:98-99; `progress = read.f();`, Radar.java:108,
inside `public void read(Reads read, byte revision){` /
`super.read(read, revision);`, Radar.java:105-106).
RadarBuild does NOT override version(), so read ignores
`revision` entirely -- there is no `if(revision >= ...)`
guard like RepairTurret's (N2217). lastRadius /
smoothEfficiency / totalProgress are NOT persisted: they
are recomputed every tick (`smoothEfficiency =
Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`,
Radar.java:61; `lastRadius = fogRadius();`,
Radar.java:65; `totalProgress += efficiency * edelta();`,
Radar.java:71, N2248), so a loaded radar rebuilds them
from their field defaults.

RED decisions (resolved at RED): (1) Two pure functions on
the same family file N2248 / N2249 / N2250 / N2263 built --
write returns {"progress"} only, read returns {"progress"}
(the stored value, whatever the revision). (2) Read takes
`revision` as an explicit int input and ignores it, so the
proof can pin that revisions 0, 1 and 2 give the same
result -- the param exists to prove the ignore, not to gate
on it; the scope proposal listed read as (frame,
stored_progress) only, and the revision param is the one
addition the parent task's revision test requires. (3) NO
driver tick line: persistence is not a per-tick call, and
the port has no save/load stream to call these functions
yet -- wiring them into a save/load path waits for a
persistence-integration slice. (4) The progress default is
0.0, the field default (`public float progress;`,
Radar.java:49). (5) Java write.f is a 32-bit float while
GDScript float is 64-bit -- the pure functions add NO
rounding epsilon; the proof round-trips float32-safe values
exactly and checks the inexact value 0.1 with
is_equal_approx. Two new result symbols: write.progress,
read.progress. Single slice source: Radar.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_radar_progress import DEFERRED as N2263_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
PROOF = '/root/C07RadarWriteReadProof'
WRITE_OWNER = 'SourceRadarBuildState.source_radar_write_state'
READ_OWNER = 'SourceRadarBuildState.source_radar_read_state'
TESTS = ['test_c07_radar_write_read_registration', 'test_all_c07_radar_write_read_input_evidence_is_exact', 'test_radar_write_read_state', 'test_reference_graph_and_actual_c07_radar_write_read']
# The 1 slice source the N2267 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
]
EXACT_EXPRS = ['public class Radar extends Block{', 'public class RadarBuild extends Building{', 'public float progress;', 'public float lastRadius = 0f;', 'public float smoothEfficiency = 1f;', 'public float totalProgress;', 'public void write(Writes write){', 'super.write(write);', 'write.f(progress);', 'public void read(Reads read, byte revision){', 'super.read(read, revision);', 'progress = read.f();', 'smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);', 'lastRadius = fogRadius();', 'totalProgress += efficiency * edelta();', 'public float progress(){', 'return progress;', 'progress += edelta() / discoveryTime;', 'progress = Mathf.clamp(progress);']

# DEFERRED is carried from the N2263 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the Radar read/write rows entry -- N2267 IS the write/read
# slice, so carrying it would leave a stale "waits for its own
# slice" row for done work.
DEFERRED = [e for e in N2263_DEFERRED if 'Radar read/write rows' not in e] + [
    'Radar write/read Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2248/N2263: the N2267 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_inputs = {
        'frame': a('Dictionary', 'public void write(Writes write){', 'The radar frame (RadarBuild.write, Radar.java:98): the family-convention first arg every Radar pure function takes; the persisted value itself arrives as the explicit progress param.'),
        'progress': a('float', 'write.f(progress);', 'The live discovery progress to persist (`write.f(progress);`, Radar.java:101): the Java field `public float progress;` (Radar.java:49, init 0.0), advanced by updateTile (Radar.java:68-69, N2248).'),
    }
    write_outputs = {
        'progress': a('float', 'write.f(progress);', 'The persisted progress (Radar.java:101, `write.f(progress);`): the frame progress -- the ONLY value write persists; lastRadius / smoothEfficiency / totalProgress are recomputed every tick (Radar.java:61, :65, :71, N2248), so none survives save/load.'),
    }
    read_inputs = {
        'frame': a('Dictionary', 'public void read(Reads read, byte revision){', 'The radar frame (RadarBuild.read, Radar.java:105): the family-convention first arg every Radar pure function takes; the restored value itself arrives as the explicit stored_progress param.'),
        'stored_progress': a('float', 'progress = read.f();', 'The progress value read from the save stream (`progress = read.f();`, Radar.java:108) -- applied unconditionally, whatever the revision.'),
        'revision': a('int', 'public void read(Reads read, byte revision){', 'The save revision (Radar.java:105, `public void read(Reads read, byte revision){`): passed to super only -- RadarBuild does NOT override version(), so there is no revision guard in the body; the param exists so the proof can pin that revisions 0, 1 and 2 give the same result.'),
    }
    read_outputs = {
        'progress': a('float', 'progress = read.f();', 'The progress after load (Radar.java:108, `progress = read.f();`): the stored progress, whatever the revision -- lastRadius / smoothEfficiency / totalProgress rebuild from their field defaults on the next tick (Radar.java:50-52, :61, :65, :71, N2248).'),
    }
    return write_inputs, write_outputs, read_inputs, read_outputs


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
    write_inputs, write_outputs, read_inputs, read_outputs = definitions()

    entries = [
        ('N2267', WRITE_OWNER, 'source_radar_write_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.write()', write_inputs, write_outputs, True, 'Dictionary'),
        ('N2267', READ_OWNER, 'source_radar_read_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.read()', read_inputs, read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar write/read persistence from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar write/read persistence from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: write.progress, read.progress.
    by_slice['N2267'] = [
        'source_radar_write_state_result.progress',
        'source_radar_read_state_result.progress',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2267', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.write(); RadarBuild.read()', godot_owner=WRITE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2267'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
