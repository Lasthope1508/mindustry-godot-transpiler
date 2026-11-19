"""Register the Drill write/read/version persistence (N2286).

DrillBuild.write()/read()/version() (Drill.java:380-394)
persist exactly TWO fields, the drill progress and the
warmup (`write.f(progress);` / `write.f(warmup);`,
Drill.java:386-387, inside `public void write(Writes
write){` / `super.write(write);`, Drill.java:384-385),
restore them only for saves at revision >= 1
(`if(revision >= 1){ progress = read.f(); warmup =
read.f(); }`, Drill.java:391-394, inside `public void
read(Reads read, byte revision){` / `super.read(read,
revision);`, Drill.java:389-390), and report save
version 1 (`public byte version(){ return 1; }`,
Drill.java:380-382; the BuildingComp base returns 0,
BuildingComp.java:669-671). The progress and warmup are
the DrillBuild float fields (`public float progress;` /
`public float warmup;`, Drill.java:238-239), default 0.0,
already tracked frame keys advanced by updateTile
(N2294) and read by progress() (Drill.java:327-329) and
sense() (Drill.java:333-336).

RED decisions (resolved at RED): (1) Three pure functions
on the same family file -- write takes the frame only and
reads both values from frame keys (the N2217 RepairTurret
precedent: the tick driver reads them); read takes the two
stored values + revision and applies them only at revision
>= 1, else keeps the frame's current values; version
returns the constant 1. (2) super.write/read are empty
BuildingComp bodies ("overriden by subclasses!") -- only
the marker is recorded. (3) DrillBuild has NO readSync
override, so there is no readSync follow-up slice
(contrast N2276 Turret, whose TurretBuild.readSync()
Turret.java:853-862 is its own slice). (4) NO driver tick
line: persistence is not a per-tick call, and the port has
no save/load stream to call these functions yet -- wiring
them into a save/load path waits for a
persistence-integration slice. (5) Java write.f is a 32-bit
float while GDScript float is 64-bit -- the pure
functions add NO rounding epsilon; the proof round-trips
float32-safe values exactly and checks the inexact value
0.1 with is_equal_approx. Five new result symbols:
write.progress, write.warmup, read.progress, read.warmup,
version.version. Two slice sources: Drill.java +
BuildingComp.java.

DEFERRED base: the BurstDrill chain forks at N2309 --
N2317 (ambient_volume) -> N2277 (drill_ambient_volume)
and N2309 -> N2280 (drill_set_stats) are BOTH leaves,
and neither deferred list is a superset of the other
(N2277 has 5 entries N2280 lacks; N2280 has 3 entries
N2277 lacks). The N2286 base is the UNION
(N2277_DEFERRED + the 3 N2280-unique entries, 297 lines)
so no deferred line is silently dropped -- the N2287
carry-bug lesson. One entry is added: the N2286 Windows
Godot proof debt (GOAL.md section 5).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_ambient_volume import DEFERRED as N2277_DEFERRED
from register_c07_drill_set_stats import DEFERRED as N2280_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07BurstDrillWriteReadProof'
WRITE_OWNER = 'SourceBurstDrillBuildState.source_drill_write_state'
READ_OWNER = 'SourceBurstDrillBuildState.source_drill_read_state'
VERSION_OWNER = 'SourceBurstDrillBuildState.source_drill_version_state'
TESTS = ['test_c07_burst_drill_write_read_registration', 'test_all_c07_burst_drill_write_read_input_evidence_is_exact', 'test_burst_drill_write_read_state', 'test_reference_graph_and_actual_c07_burst_drill_write_read']
# The 2 slice sources the N2286 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public class Drill extends Block{',
    'public class DrillBuild extends Building{',
    'public float progress;',
    'public float warmup;',
    'public void write(Writes write){',
    'super.write(write);',
    'write.f(progress);',
    'write.f(warmup);',
    'public void read(Reads read, byte revision){',
    'super.read(read, revision);',
    'if(revision >= 1){',
    'progress = read.f();',
    'warmup = read.f();',
    'public byte version(){',
    'return 1;',
    'return 0;',
    '//overriden by subclasses!',
]

# DEFERRED is carried from the two BurstDrill chain leaves
# via import -- never retyped. The union keeps every line:
# N2277 (294) + the 3 entries only N2280 carries. One
# entry is added: the N2286 Windows Godot proof debt
# (GOAL.md section 5). Nothing in it closes here:
# write/read/version was never a deferred entry of the
# BurstDrill chain.
DEFERRED = N2277_DEFERRED + [entry for entry in N2280_DEFERRED if entry not in N2277_DEFERRED] + [
    'Drill write/read/version Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2286 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_inputs = {
        'frame': a('Dictionary', 'public void write(Writes write){', 'The drill frame (DrillBuild.write, Drill.java:384): the family-convention first arg every BurstDrill pure function takes; both persisted values are read from frame keys (the N2217 RepairTurret precedent) -- progress and warmup are tracked frame keys, the tick driver reads them.'),
    }
    write_outputs = {
        'progress': a('float', 'write.f(progress);', 'The persisted drill progress (`write.f(progress);`, Drill.java:386): the DrillBuild field (`public float progress;`, Drill.java:238), default 0.0, advanced by updateTile (N2294); written first, in Java write order.'),
        'warmup': a('float', 'write.f(warmup);', 'The persisted warmup (`write.f(warmup);`, Drill.java:387): the DrillBuild field (`public float warmup;`, Drill.java:239), default 0.0, advanced by updateTile (N2294); written second, in Java write order.'),
    }
    read_inputs = {
        'frame': a('Dictionary', 'public void read(Reads read, byte revision){', 'The drill frame (DrillBuild.read, Drill.java:389): the family-convention first arg every BurstDrill pure function takes; a revision-0 save leaves the fields where they already are, so the frame carries the current values as the fallback.'),
        'stored_progress': a('float', 'progress = read.f();', 'The drill progress read from the save stream (`progress = read.f();`, Drill.java:392) -- applied only when revision >= 1.'),
        'stored_warmup': a('float', 'warmup = read.f();', 'The warmup read from the save stream (`warmup = read.f();`, Drill.java:393) -- applied only when revision >= 1.'),
        'revision': a('int', 'public void read(Reads read, byte revision){', 'The save revision (Drill.java:389, `public void read(Reads read, byte revision){`): the guard (`if(revision >= 1){`, Drill.java:391) -- the save version is 1 (`public byte version(){ return 1; }`, Drill.java:380-382).'),
    }
    read_outputs = {
        'progress': a('float', 'progress = read.f();', 'The drill progress after load (Drill.java:392, `progress = read.f();`): the stored value when revision >= 1, else the frame current value (default 0.0).'),
        'warmup': a('float', 'warmup = read.f();', 'The warmup after load (Drill.java:393, `warmup = read.f();`): the stored value when revision >= 1, else the frame current value (default 0.0).'),
    }
    version_inputs = {
        'frame': a('Dictionary', 'public byte version(){', 'The drill frame (DrillBuild.version, Drill.java:380): accepted for the family call shape and read for nothing -- the version is a class constant, not live state.'),
    }
    version_outputs = {
        'version': a('int', 'return 1;', 'The save version: 1 (Drill.java:381, `return 1;`); the BuildingComp base returns 0 (BuildingComp.java:670).'),
    }
    return write_inputs, write_outputs, read_inputs, read_outputs, version_inputs, version_outputs


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
    write_inputs, write_outputs, read_inputs, read_outputs, version_inputs, version_outputs = definitions()

    entries = [
        ('N2286', WRITE_OWNER, 'source_drill_write_state', DRILL, 'mindustry.world.blocks.production.Drill.DrillBuild', 'DrillBuild.write()', write_inputs, write_outputs, True, 'Dictionary'),
        ('N2286', READ_OWNER, 'source_drill_read_state', DRILL, 'mindustry.world.blocks.production.Drill.DrillBuild', 'DrillBuild.read()', read_inputs, read_outputs, True, 'Dictionary'),
        ('N2286', VERSION_OWNER, 'source_drill_version_state', DRILL, 'mindustry.world.blocks.production.Drill.DrillBuild', 'DrillBuild.version()', version_inputs, version_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed DrillBuild.write()/read()/version() state from Drill.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed DrillBuild.write()/read()/version() state from Drill.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: write.progress,
    # write.warmup, read.progress, read.warmup,
    # version.version.
    by_slice['N2286'] = [
        'source_drill_write_state_result.progress',
        'source_drill_write_state_result.warmup',
        'source_drill_read_state_result.progress',
        'source_drill_read_state_result.warmup',
        'source_drill_version_state_result.version',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2286', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill.DrillBuild', java_method='DrillBuild.write(); DrillBuild.read(); DrillBuild.version()', godot_owner=WRITE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2286'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
