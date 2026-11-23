"""Register the ContinuousTurret version() + write() + read() (N2375).

MERGED slice (N2322 TurretBuild / N2286 DrillBuild
precedent): ONE record, ONE owner, covering ALL THREE
java methods:
ContinuousTurretBuild.version()
(ContinuousTurret.java:176-178, `public byte version(){` /
`return 3;`) and
ContinuousTurretBuild.write()
(ContinuousTurret.java:181-185, `public void write(Writes write){` /
`super.write(write);` / `write.f(lastLength);`) and
ContinuousTurretBuild.read()
(ContinuousTurret.java:188-194, `public void read(Reads read, byte revision){` /
`super.read(read, revision);` / `if(revision >= 3){` /
`lastLength = read.f();`)
are one pure function on the existing
SourceContinuousTurretBuildPortBridge.gd (created by N2355,
updateTile by N2362, updateBullet by N2366, updateShooting
by N2367, turnToTarget+handleBullet by N2370), following
the PortBridge precedent (N2355/N2362/N2366/N2367/N2370)
and the merged version/write/read precedent (N2322
TurretBuild, N2286 DrillBuild). version() stamps the save
revision, write() persists the single own field lastLength,
read() restores it only at revision >= 3 -- one
persistence record, one symbol/owner, with ALL THREE
java_method names in the ledger record
(`ContinuousTurretBuild.version();
ContinuousTurretBuild.write(Writes);
ContinuousTurretBuild.read(Reads, byte)`).
Main thread confirms at merge.

RED decisions (resolved at RED): (1) The function lives
in the existing PortBridge file: there is no
SourceContinuousTurretBuildState.gd to delegate to. The
SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2370 PortGame.source_continuous_turret_build_turn_to_target_handle_bullet_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed at N2355, owner PortGame here.
(2) The name `version` shares text with 7 other-class
slices (N1187/N745/N923/N1885/N2217/N2286/N2322, all
`version()` on a different class) -- registered under
this java_method with the class prefix + full java_class,
0-hit for `ContinuousTurretBuild.version` in both ledgers.
(3) `super.write(write);` / `super.read(read, revision);`
each EXACT-hit 9 slices -- they are callee/context only,
NOT distinguishing exprs, and are NOT in EXACT_EXPRS:
the super layer is TurretBuild.write/read, owned by
N2322, not re-ported here.
(4) The four distinguishing exprs are EXACT 0-hit in
both ledgers: `return 3;` (standalone -- N1797 only
matches the substring form `if(...) return 3;`, not
exact), `write.f(lastLength);`, `lastLength = read.f();`,
`if(revision >= 3){`.
(5) lastLength is the ContinuousTurretBuild field
(ContinuousTurret.java:40, `public float lastLength =
size * 4f;`, written by updateBullet N2366, read by
handleBullet N2370) -- its value arrives as the explicit
last_length param; the value read.f() would return
arrives as the explicit stored_last_length param (the
N2330 param precedent -- the port has no save/load
stream).
(6) The write carries no revision: write.f(lastLength)
persists the current value whatever the revision, so
write_last_length never depends on the revision param.
(7) Java write.f is a 32-bit float while GDScript float
is 64-bit -- the pure function adds NO rounding epsilon;
the proof round-trips float32-safe values exactly.
(8) NO driver tick line: persistence is not a per-tick
call, and the port has no save/load stream to call this
function yet.
Three new result symbols: version, write_last_length,
last_length.
Slice source: ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_turn_to_target_handle_bullet import DEFERRED as N2370_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretVersionWriteReadProof'
VERSION_WRITE_READ_OWNER = 'PortGame.source_continuous_turret_build_version_write_read_state'
TESTS = ['test_c07_continuous_turret_version_write_read_registration', 'test_all_c07_continuous_turret_version_write_read_input_evidence_is_exact', 'test_continuous_turret_version_write_read_state', 'test_reference_graph_and_actual_c07_continuous_turret_version_write_read']
# The 1 slice source the N2375 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurret extends Turret{',
    'public class ContinuousTurretBuild extends TurretBuild{',
    '@Override',
    'public byte version(){',
    'return 3;',
    'public void write(Writes write){',
    'write.f(lastLength);',
    'public void read(Reads read, byte revision){',
    'if(revision >= 3){',
    'lastLength = read.f();',
    'public float lastLength = size * 4f;',
]

# DEFERRED is carried from the N2370 register script via import --
# never retyped. All N2370 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2370's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2375's Windows proof debt.
DEFERRED = list(N2370_DEFERRED) + [
    'ContinuousTurret version + write + read Windows Godot proof -- debt in GOAL.md section 5, same as N2370: the N2375 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    version_expr = 'return 3;'
    write_expr = 'write.f(lastLength);'
    gate_expr = 'if(revision >= 3){'
    read_expr = 'lastLength = read.f();'
    version_write_read_inputs = {
        'last_length': a('float', write_expr, 'The current lastLength field, lastLength (ContinuousTurret.java:40, `public float lastLength = size * 4f;`, written by updateBullet N2366): the value write() persists and read() keeps when the revision is below 3.'),
        'revision': a('int', gate_expr, 'The save revision, revision (ContinuousTurret.java:188-191): read() restores lastLength only when revision >= 3, the version() stamp.'),
        'stored_last_length': a('float', read_expr, 'The value read.f() would return from the stream (ContinuousTurret.java:192, `lastLength = read.f();`): the port has no save/load stream, so it arrives as an explicit param, not re-ported here.'),
    }
    version_write_read_outputs = {
        'version': a('int', version_expr, 'The save version (ContinuousTurret.java:176-178, `public byte version(){ return 3; }`): always 3 -- the name shares text with 7 other-class slices (N1187/N745/N923/N1885/N2217/N2286/N2322), registered under this java_method with the class prefix.'),
        'write_last_length': a('float', write_expr, 'The persisted lastLength (ContinuousTurret.java:184, `write.f(lastLength);`): the value write() stores, whatever the revision.'),
        'last_length': a('float', read_expr, 'The post-read lastLength (ContinuousTurret.java:191-193, `if(revision >= 3){ lastLength = read.f(); }`): the stored value at revision >= 3, the current value otherwise.'),
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
        ('N2375', VERSION_WRITE_READ_OWNER, 'source_continuous_turret_build_version_write_read_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.version(); ContinuousTurretBuild.write(Writes); ContinuousTurretBuild.read(Reads, byte)', version_write_read_inputs, version_write_read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.version()/write()/read() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.version()/write()/read() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: version, write_last_length, last_length.
    by_slice['N2375'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2375', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.version(); ContinuousTurretBuild.write(Writes); ContinuousTurretBuild.read(Reads, byte)', godot_owner=VERSION_WRITE_READ_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2375'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
