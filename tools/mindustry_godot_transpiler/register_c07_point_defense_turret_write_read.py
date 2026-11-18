"""Register the PointDefenseTurret write/read persistence (N2245).

N2240-N2244 made the point-defense turret live (aim + shoot,
shouldConsume, live bullets, team stamp, draw) -- but none of
that state survived a save/load: PointDefenseBuild persists
exactly ONE field, its rotation (`write.f(rotation);`,
PointDefenseTurret.java:121, inside `public void write(Writes
write){` / `super.write(write);`, PointDefenseTurret.java:117-119),
and restores it UNCONDITIONALLY (`rotation = read.f();`,
PointDefenseTurret.java:127, inside `public void read(Reads read,
byte revision){` / `super.read(read, revision);`,
PointDefenseTurret.java:124-126) -- there is NO `if(revision >=
1){` guard here, unlike RepairTurret.read()
(RepairTurret.java:246-248, the N2217 precedent).
PointDefenseTurret does NOT override version(), so the save
version is the BuildingComp default 0 (`public byte version(){`
/ `return 0;`, BuildingComp.java:669-671) -- the read ignores
the revision it is handed either way. Target is NOT persisted:
it is re-acquired by the retarget timer
(`if(timer(timerTarget, retargetTime)){` / `target =
Groups.bullet.intersect(x - range, y - range, range*2,
range*2).min(b -> b.team != team && b.type().hittable, b ->
b.dst2(this));`, PointDefenseTurret.java:65-67). reloadCounter
is NOT persisted either: it is recharged every tick (`public
float reloadCounter;`, ReloadTurret.java:26; `reloadCounter +=
edelta();`, PointDefenseTurret.java:79).

RED decisions (resolved at RED): (1) Two pure functions on the
same family file N2240-N2244 built, plus one save-version const
-- write returns {"rotation"} only, read returns {"rotation"}
(the saved value, unconditionally -- NO revision parameter,
because the Java body never reads `revision`, and NO frame
parameter either, because the result never falls back to the
frame: unlike N2217's read, there is no revision-0 branch to
keep the current rotation). (2) The version is a const, not a
function: Java version() takes no parameters, and the SSOT
schema validator requires every schema entry to carry non-empty
keys, so a zero-input function could not be registered -- the
const POINT_DEFENSE_TURRET_SAVE_VERSION pins the `return 0;`
default. (3) NO driver tick line: persistence is not a per-tick
call, and the port has no save/load stream to call these
functions yet -- wiring them into a save/load path waits for a
persistence-integration slice (deferred) -- the N2217
precedent, NOT the N2244 draw pattern: the task's "driver tick
line" parenthetical does not apply to persistence, and
inventing a per-tick save stamp would invent behavior. (4) The
rotation default is 90.0, the field default (`public float
rotation = 90;`, BaseTurret.java:114). (5) The one def,
segment, is the only PointDefenseTurret def
(Blocks.java:3835-3845), so one set of functions covers it.
Two new result symbols: write.rotation, read.rotation. SSOT
expected after GREEN: symbols +2, Done +1, contracts +2,
schema +4, 11561/1694/1625/3041 -> 11563/1695/1627/3045;
defense shard slices 173 -> 174.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_point_defense_turret_draw import DEFERRED as N2244_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
PROOF = '/root/C07PointDefenseTurretWriteReadProof'
WRITE_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_write_state'
READ_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_read_state'
TESTS = ['test_c07_point_defense_turret_write_read_registration', 'test_all_c07_point_defense_turret_write_read_input_evidence_is_exact', 'test_point_defense_turret_write_read_state', 'test_reference_graph_and_actual_c07_point_defense_turret_write_read']
# The 4 slice sources the N2245 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
]
EXACT_EXPRS = ['public class PointDefenseTurret extends ReloadTurret{', 'public class PointDefenseBuild extends ReloadTurretBuild{', 'public void write(Writes write){', 'super.write(write);', 'write.f(rotation);', 'public void read(Reads read, byte revision){', 'super.read(read, revision);', 'rotation = read.f();', 'public byte version(){', 'return 0;', 'public float rotation = 90;', 'public @Nullable Bullet target;', 'if(timer(timerTarget, retargetTime)){', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'public float reloadCounter;', 'reloadCounter += edelta();']

# DEFERRED is carried from the N2244 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the live coolant wiring + setStats / icons + the real
# effect/sound spawn (its "write/read" words are stale now that
# N2245 lands them -- the N2244 precedent carries the entry
# verbatim), and the TractorBeam half is untouched. Only the
# N2245 Windows-proof debt + save/load-stream debt entries are
# appended.
DEFERRED = list(N2244_DEFERRED) + [
    'PointDefenseTurret write/read Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2244: the N2245 proof runs headless on Linux here and waits for a Windows Godot run.',
    'The port has no save/load stream to call the point-defense read/write functions yet: the pure functions model the persisted rotation value; wiring them into a save/load path waits for a persistence-integration slice.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_inputs = {
        'frame': a('Dictionary', 'public void write(Writes write){', 'The point-defense frame carrying the live rotation (stamped by the N2240 aim/shoot block; absent reads 90.0, the field default `public float rotation = 90;`, BaseTurret.java:114) -- write persists exactly this one field (`write.f(rotation);`, PointDefenseTurret.java:121).'),
    }
    write_outputs = {
        'rotation': a('float', 'write.f(rotation);', 'The persisted rotation (PointDefenseTurret.java:121, `write.f(rotation);`): the frame rotation, or 90.0 when the frame carries none -- the ONLY value write persists; target is re-acquired by the retarget timer (PointDefenseTurret.java:65-67) and reloadCounter is recharged every tick (PointDefenseTurret.java:79), so neither survives save/load.'),
    }
    read_inputs = {
        'saved_rotation': a('float', 'rotation = read.f();', 'The rotation value read from the save stream (`rotation = read.f();`, PointDefenseTurret.java:127) -- applied unconditionally: PointDefenseTurret.read() has NO `if(revision >= 1){` guard (unlike RepairTurret.java:246-248, N2217), and PointDefenseTurret does not override version() (the BuildingComp default 0, BuildingComp.java:669-671), so the revision the read is handed is never consulted.'),
    }
    read_outputs = {
        'rotation': a('float', 'rotation = read.f();', 'The rotation after load (PointDefenseTurret.java:127, `rotation = read.f();`): always the saved rotation -- there is no revision-0 fallback to the frame rotation, because the Java body never reads `revision`.'),
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
        ('N2245', WRITE_OWNER, 'source_point_defense_turret_write_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.write()', write_inputs, write_outputs, True, 'Dictionary'),
        ('N2245', READ_OWNER, 'source_point_defense_turret_read_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.read()', read_inputs, read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret write/read persistence from PointDefenseTurret.java + BaseTurret.java + BuildingComp.java + ReloadTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret write/read persistence from PointDefenseTurret.java + BaseTurret.java + BuildingComp.java + ReloadTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: write.rotation, read.rotation.
    by_slice['N2245'] = [
        'source_point_defense_turret_write_state_result.rotation',
        'source_point_defense_turret_read_state_result.rotation',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2245', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.write()/read()', godot_owner=WRITE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2245'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
