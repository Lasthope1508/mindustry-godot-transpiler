"""Register the BeamDrill version() + write() + read() (N2378).

MERGED slice (N2322 TurretBuild / N2286 DrillBuild /
N2375 ContinuousTurret precedent): ONE record, ONE
owner, covering ALL THREE java methods:
BeamDrillBuild.version()
(BeamDrill.java:414-416, `public byte version(){` /
`return 1;`) and
BeamDrillBuild.write()
(BeamDrill.java:419-424, `public void write(Writes write){` /
`super.write(write);` / `write.f(time);` /
`write.f(warmup);`) and
BeamDrillBuild.read()
(BeamDrill.java:426-433, `public void read(Reads read, byte revision){` /
`super.read(read, revision);` / `if(revision >= 1){` /
`time = read.f();` / `warmup = read.f();`)
are one pure function on the existing
SourceBeamDrillBuildState.gd (created by N2155,
power status row only), following the merged
version/write/read precedent (N2322 TurretBuild,
N2286 DrillBuild, N2375 ContinuousTurret).
version() stamps the save revision, write()
persists the two own fields time and warmup,
read() restores them only at revision >= 1 -- one
persistence record, one symbol/owner, with ALL THREE
java_method names in the ledger record
(`BeamDrillBuild.version();
BeamDrillBuild.write(Writes);
BeamDrillBuild.read(Reads, byte)`).
Main thread confirms at merge.

RED decisions (resolved at RED): (1) BeamDrill is
opened for C07 by main thread decision ~14:3x
(batch 17 scope): BeamDrill extends Block, not
Drill, but it is a Drill-family production block
(the batch-11 LaserTurret / PayloadAmmoTurret
subclass precedent) -- not RepairTurret /
RepairTower / PointDefenseTurret, so no family-split
violation. (2) The name `version` shares text with
8 other-class slices (N1187/N745/N923/N1885/N2217/
N2286/N2322/N2375, all `version()` on a different
class) -- registered under this java_method with
the class prefix + full java_class, 0-hit for
`BeamDrillBuild.version` in both ledgers.
(3) `super.write(write);` / `super.read(read, revision);`
each EXACT-hit 9 slices -- they are callee/context
only, NOT distinguishing exprs, and are NOT in
EXACT_EXPRS: the super layer is DrillBuild.write/
read, owned by N2286, not re-ported here.
(4) `write.f(warmup);` / `warmup = read.f();` EXACT-hit
only N2286 (DrillBuild.write/read also persists
warmup) -- text-share across class/method, the
registry precedent (N632-N639 duplicate N1078-
N1085 verbatim); they ARE in EXACT_EXPRS because
they are part of this method's body, registered
under this java_method with the class prefix.
The distinguishing exprs are `write.f(time);` and
`time = read.f();`, EXACT 0-hit in both ledgers
(re-probed at HEAD 76d71f1e).
(5) time is the BeamDrillBuild field
(BeamDrill.java:225, `public float time;`, advanced
by updateTile N2155-deferred, read by write here);
warmup is the BeamDrillBuild field (BeamDrill.java:
226, `public float warmup, boostWarmup;`, gated by
updateTile N2155-deferred) -- both values arrive as
explicit params; the values read.f() would return
arrive as the explicit stored_time / stored_warmup
params (the N2330 param precedent -- the port has
no save/load stream).
(6) The write carries no revision: write.f(time) /
write.f(warmup) persist the current values whatever
the revision, so write_time / write_warmup never
depend on the revision param. Write order is time
then warmup (BeamDrill.java:421-422), read order
the same (:429-430).
(7) Java write.f is a 32-bit float while GDScript float
is 64-bit -- the pure function adds NO rounding epsilon;
the proof round-trips float32-safe values exactly.
(8) NO driver tick line: persistence is not a per-tick
call, and the port has no save/load stream to call this
function yet.
Five new result symbols: version, write_time,
write_warmup, time, warmup.
Slice source: BeamDrill.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_power_status import DEFERRED as N2155_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
PROOF = '/root/C07BeamDrillVersionWriteReadProof'
VERSION_WRITE_READ_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_write_state'
TESTS = ['test_c07_beam_drill_version_write_read_registration', 'test_all_c07_beam_drill_version_write_read_input_evidence_is_exact', 'test_beam_drill_version_write_read_state', 'test_reference_graph_and_actual_c07_beam_drill_version_write_read']
# The 1 slice source the N2378 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
]
EXACT_EXPRS = [
    'public class BeamDrill extends Block{',
    'public class BeamDrillBuild extends Building{',
    '@Override',
    'public byte version(){',
    'return 1;',
    'public void write(Writes write){',
    'write.f(time);',
    'write.f(warmup);',
    'public void read(Reads read, byte revision){',
    'if(revision >= 1){',
    'time = read.f();',
    'warmup = read.f();',
    'public float time;',
    'public float warmup, boostWarmup;',
]

# DEFERRED is carried from the N2155 register script via import --
# never retyped. All N2155 entries are carried verbatim (the
# BeamDrill updateTile advance, shouldConsume gate, liquid rows,
# facing/laser binding, drillMultipliers rows, plus the Pump /
# Fracker / SolidPump / projector / payload-producer / BurstDrill
# chain notes -- none of them is resolved by this slice). One
# entry is added: N2378's Windows proof debt.
DEFERRED = list(N2155_DEFERRED) + [
    'BeamDrill version + write + read Windows Godot proof -- debt in GOAL.md section 5, same as N2155: the N2378 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    version_expr = 'return 1;'
    write_time_expr = 'write.f(time);'
    write_warmup_expr = 'write.f(warmup);'
    gate_expr = 'if(revision >= 1){'
    read_time_expr = 'time = read.f();'
    read_warmup_expr = 'warmup = read.f();'
    version_write_read_inputs = {
        'time': a('float', write_time_expr, 'The current time field, time (BeamDrill.java:225, `public float time;`, advanced by updateTile): the value write() persists and read() keeps when the revision is below 1.'),
        'warmup': a('float', write_warmup_expr, 'The current warmup field, warmup (BeamDrill.java:226, `public float warmup, boostWarmup;`, gated by updateTile): the value write() persists and read() keeps when the revision is below 1.'),
        'revision': a('int', gate_expr, 'The save revision, revision (BeamDrill.java:426-431): read() restores time and warmup only when revision >= 1, the version() stamp.'),
        'stored_time': a('float', read_time_expr, 'The value read.f() would return from the stream for time (BeamDrill.java:429, `time = read.f();`): the port has no save/load stream, so it arrives as an explicit param, not re-ported here.'),
        'stored_warmup': a('float', read_warmup_expr, 'The value read.f() would return from the stream for warmup (BeamDrill.java:430, `warmup = read.f();`): the port has no save/load stream, so it arrives as an explicit param, not re-ported here.'),
    }
    version_write_read_outputs = {
        'version': a('int', version_expr, 'The save version (BeamDrill.java:414-416, `public byte version(){ return 1; }`): always 1 -- the name shares text with 8 other-class slices (N1187/N745/N923/N1885/N2217/N2286/N2322/N2375), registered under this java_method with the class prefix.'),
        'write_time': a('float', write_time_expr, 'The persisted time (BeamDrill.java:421, `write.f(time);`): the value write() stores, whatever the revision.'),
        'write_warmup': a('float', write_warmup_expr, 'The persisted warmup (BeamDrill.java:422, `write.f(warmup);`): the value write() stores, whatever the revision.'),
        'time': a('float', read_time_expr, 'The post-read time (BeamDrill.java:428-430, `if(revision >= 1){ time = read.f(); }`): the stored value at revision >= 1, the current value otherwise.'),
        'warmup': a('float', read_warmup_expr, 'The post-read warmup (BeamDrill.java:428-431, `if(revision >= 1){ warmup = read.f(); }`): the stored value at revision >= 1, the current value otherwise.'),
    }
    return (version_write_read_inputs, version_write_read_outputs)


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (version_write_read_inputs, version_write_read_outputs) = definitions()

    entries = [
        ('N2378', VERSION_WRITE_READ_OWNER, 'source_beam_drill_write_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.version(); BeamDrillBuild.write(Writes); BeamDrillBuild.read(Reads, byte)', version_write_read_inputs, version_write_read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.version()/write()/read() state from BeamDrill.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrillBuild.version()/write()/read() state from BeamDrill.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: version, write_time,
    # write_warmup, time, warmup.
    by_slice['N2378'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2378', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrillBuild.version(); BeamDrillBuild.write(Writes); BeamDrillBuild.read(Reads, byte)', godot_owner=VERSION_WRITE_READ_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2378'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
