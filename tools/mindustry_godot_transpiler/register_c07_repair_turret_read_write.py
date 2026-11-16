"""Register the RepairTurret read/write persistence (N2217).

N2212-N2215 made the repair turret live (target acquire, heal
advance, rotation slerp, strength lerp) -- but none of that state
survived a save/load: RepairPointBuild persists exactly ONE field,
its rotation (`write.f(rotation);`, RepairTurret.java:239, inside
`public void write(Writes write){` / `super.write(write);`,
RepairTurret.java:236-238), and restores it only for saves written
at revision >= 1 (`if(revision >= 1){` / `rotation = read.f();`,
RepairTurret.java:246-248, inside `public void read(Reads read,
byte revision){` / `super.read(read, revision);`,
RepairTurret.java:243-245), because `public byte version(){`
returns 1 (RepairTurret.java:252-254). Strength is NOT persisted:
it is re-lerped every tick (`strength = Mathf.lerpDelta(strength,
healed ? 1f : 0f, 0.08f * Time.delta);`, RepairTurret.java:212),
so a loaded turret rebuilds it from 0. Target is NOT persisted
either: it is re-acquired by the 20-tick timer (`target =
Units.closest(team, x, y, repairRadius, Unit::damaged);`,
RepairTurret.java:216).

RED decisions (resolved at RED): (1) Two pure functions on the
same family file N2174 / N2188 / N2209 / N2212-N2215 built, plus
one save-version const -- write returns {"rotation"} only, read
returns {"rotation"} (saved value when revision >= 1, the frame's
current rotation otherwise). (2) The version is a const, not a
function: Java version() takes no parameters, and the SSOT schema
validator requires every schema entry to carry non-empty keys, so
a zero-input function could not be registered -- the const
REPAIR_TURRET_SAVE_VERSION pins the `return 1;` fact. (3) NO
driver tick line: persistence is not a per-tick call, and the port
has no save/load stream to call these functions yet -- wiring them
into a save/load path waits for a persistence-integration slice.
(4) The rotation default is 90.0, the field default (`public
float strength, rotation = 90;`, RepairTurret.java:156). (5) Both
defs share RepairPointBuild (repair-point, powerUse 1f,
Blocks.java:6391; repair-turret, powerUse 5f, Blocks.java:6402), so
one set of functions covers both. (6) drawBeam is rendering only,
not persistence -- it waits for its own slice. Two new result
symbols: write.rotation, read.rotation. Single slice source:
RepairTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_impact_reactor_impact_power import DEFERRED as N2216_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
PROOF = '/root/C07RepairTurretReadWriteProof'
WRITE_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_write_state'
READ_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_read_state'
TESTS = ['test_c07_repair_turret_read_write_registration', 'test_all_c07_repair_turret_read_write_input_evidence_is_exact', 'test_repair_turret_read_write_state', 'test_reference_graph_and_actual_c07_repair_turret_read_write']
# The 1 slice source the N2217 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
]
EXACT_EXPRS = ['public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'public float strength, rotation = 90;', 'public void write(Writes write){', 'super.write(write);', 'write.f(rotation);', 'public void read(Reads read, byte revision){', 'super.read(read, revision);', 'if(revision >= 1){', 'rotation = read.f();', 'public byte version(){', 'return 1;', 'strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', 'target = Units.closest(team, x, y, repairRadius, Unit::damaged);']

# DEFERRED is carried from the N2216 register script via import --
# never retyped. The N2216 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2187 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2217's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(N2216_DEFERRED) + [
    'RepairTurret drawBeam rows (RepairTurret.java:106-151, draw() :163-175) are pure rendering (Drawf.laser / Lines.stroke / Draw.rect) with no runtime state effect -- no frame key, waits for a rendering slice if one is ever built.',
    'RepairTurret read/write Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2216: the N2217 proof runs headless on Linux here and waits for a Windows Godot run.',
    'The port has no save/load stream to call the read/write functions yet: the pure functions model the persisted rotation value; wiring them into a save/load path waits for a persistence-integration slice.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_inputs = {
        'frame': a('Dictionary', 'public void write(Writes write){', 'The repair-turret frame carrying the live rotation (stamped by the N2214 slerp; absent reads 90.0, the field default `public float strength, rotation = 90;`, RepairTurret.java:156) -- write persists exactly this one field (`write.f(rotation);`, RepairTurret.java:239).'),
    }
    write_outputs = {
        'rotation': a('float', 'write.f(rotation);', 'The persisted rotation (RepairTurret.java:239, `write.f(rotation);`): the frame rotation, or 90.0 when the frame carries none -- the ONLY value write persists; strength is re-lerped every tick (RepairTurret.java:212) and target is re-acquired by the 20-tick timer (RepairTurret.java:216), so neither survives save/load.'),
    }
    read_inputs = {
        'frame': a('Dictionary', 'public void read(Reads read, byte revision){', 'The repair-turret frame carrying the current rotation (the value a revision-0 save leaves untouched, since `if(revision >= 1){` guards the restore, RepairTurret.java:246; absent reads 90.0, the field default, RepairTurret.java:156).'),
        'saved_rotation': a('float', 'rotation = read.f();', 'The rotation value read from the save stream (`rotation = read.f();`, RepairTurret.java:247) -- applied only when revision >= 1.'),
        'revision': a('int', 'if(revision >= 1){', 'The save revision (RepairTurret.java:246, `if(revision >= 1){`): the restore runs only at revision >= 1, because `public byte version(){` returns 1 (RepairTurret.java:252-254) -- a revision-0 save carries no rotation float to read.'),
    }
    read_outputs = {
        'rotation': a('float', 'rotation = read.f();', 'The rotation after load (RepairTurret.java:247, `rotation = read.f();`): the saved rotation when revision >= 1, the frame rotation (default 90.0) otherwise.'),
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
        ('N2217', WRITE_OWNER, 'source_repair_turret_write_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.write()', write_inputs, write_outputs, True, 'Dictionary'),
        ('N2217', READ_OWNER, 'source_repair_turret_read_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.read()', read_inputs, read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret read/write persistence from RepairTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret read/write persistence from RepairTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: write.rotation, read.rotation.
    by_slice['N2217'] = [
        'source_repair_turret_write_state_result.rotation',
        'source_repair_turret_read_state_result.rotation',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2217', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.write()/read()/version()', godot_owner=WRITE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2217'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
