"""Register the PointDefenseTurret persistence-integration bridge (N2249).

N2245 built the write/read pure functions on
SourcePointDefenseTurretBuildState, but nothing in the port could
call them from the PortGame surface: the port has no save/load
stream, and no bridge exposed them (PointDefenseTurret.java:117-128,
`write` persists exactly one float, `rotation`, and `read`
restores it unconditionally -- no revision guard, unlike
RepairTurret.read(), N2217). N2249 wires the two pure functions
onto the PortGame-callable surface, the N2217/N2245 deferred
persistence-integration step: two thin bridge functions on
SourceTurretRuntimePortBridge (the TractorBeam precedent, :221/:227,
and the ItemTurret precedent,
SourceItemTurretBuildPortBridge.gd:68) that delegate to the N2245
pure functions, plus two registry consts in
SourceRuntimeOwnerTurretRegistry (the N2246 precedent: a registry
const gets no symbol of its own, only the callable surface is
registered). The bridge write wraps the rotation float into the
frame the pure function reads (`{"rotation": rotation_value}`,
default 90.0 when absent, `public float rotation = 90;`,
BaseTurret.java:114); the bridge read passes the saved float
straight through -- NO revision parameter, because the Java body
never reads `revision`, and NO frame parameter either. NO driver
tick line: persistence is not a per-tick call (the N2245
precedent). NO `generated_*_bridge_state` variant: that pattern
needs a `java_inner_class_PointDefenseBuild_method_write_*` /
`read_*` stub, and grep of `godot-mindustry/src/` finds NO
`java_inner_class_PointDefense*` stub at all. NO save/load stream
is created here: PortGame.gd calls no `*_build_write_state` /
`*_build_read_state` bridge yet, and no file outside the
bridge/registry calls these two either -- the stream caller is a
later slice. Two new result symbols: the bridge write/read
rotation, each backed by the same Java line as its N2245 pure
function. SSOT expected after GREEN: symbols +2, Done +1,
contracts +2, schema +4, 11575/1698/1631/3053 ->
11577/1699/1633/3057; defense shard slices 177 -> 178.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_point_defense_turret_coolant import DEFERRED as N2248_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
PROOF = '/root/C07PointDefenseTurretPersistenceIntegrationProof'
WRITE_BRIDGE_OWNER = 'PortGame.source_point_defense_turret_build_write_state'
READ_BRIDGE_OWNER = 'PortGame.source_point_defense_turret_build_read_state'
TESTS = ['test_c07_point_defense_turret_persistence_integration_registration', 'test_all_c07_point_defense_turret_persistence_integration_input_evidence_is_exact', 'test_point_defense_turret_persistence_integration_state', 'test_reference_graph_and_actual_c07_point_defense_turret_persistence_integration']
# The 4 slice sources the N2249 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
]
EXACT_EXPRS = ['public class PointDefenseTurret extends ReloadTurret{', 'public class PointDefenseBuild extends ReloadTurretBuild{', 'public void write(Writes write){', 'super.write(write);', 'write.f(rotation);', 'public void read(Reads read, byte revision){', 'super.read(read, revision);', 'rotation = read.f();', 'public byte version(){', 'return 0;', 'public float rotation = 90;', 'public @Nullable Bullet target;', 'if(timer(timerTarget, retargetTime)){', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'public float reloadCounter;', 'reloadCounter += edelta();']

# DEFERRED is carried from the N2248 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the live coolant wiring + the real effect/sound spawn, and the
# TractorBeam half is untouched. Only the N2249 Windows-proof
# debt + the still-missing save/load stream caller entries are
# appended. The N2245 save/load-stream entry is carried verbatim
# (its "waits for a persistence-integration slice" words are
# stale now that N2249 IS that slice -- but the stream caller
# itself is still missing, which the new entry below records).
DEFERRED = list(N2248_DEFERRED) + [
    'PointDefenseTurret persistence-integration Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2248: the N2249 proof runs headless on Linux here and waits for a Windows Godot run.',
    'PointDefenseTurret persistence bridge surface exists (N2249: bridge write/read + registry consts) but no save/load stream calls it yet: PortGame.gd calls no *_build_write_state / *_build_read_state bridge; a real save/load stream caller is a later slice.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_bridge_inputs = {
        'rotation_value': a('float', 'write.f(rotation);', 'The rotation the bridge persists (PointDefenseTurret.java:121, `write.f(rotation);`): the bridge wraps this float into the frame the N2245 pure function reads (`{"rotation": rotation_value}`), because the pure function takes a frame -- the adapter is thin and invents no behaviour.'),
    }
    write_bridge_outputs = {
        'rotation': a('float', 'write.f(rotation);', 'The persisted rotation (PointDefenseTurret.java:121, `write.f(rotation);`): exactly what the N2245 pure function returns for the wrapped frame -- the ONLY value write persists; target is re-acquired by the retarget timer (PointDefenseTurret.java:65-67) and reloadCounter is recharged every tick (PointDefenseTurret.java:79), so neither survives save/load.'),
    }
    read_bridge_inputs = {
        'saved_rotation': a('float', 'rotation = read.f();', 'The rotation value read from the save stream (`rotation = read.f();`, PointDefenseTurret.java:127) -- applied unconditionally: PointDefenseTurret.read() has NO `if(revision >= 1){` guard (unlike RepairTurret.java:246-248, N2217), and PointDefenseTurret does not override version() (the BuildingComp default 0, BuildingComp.java:669-671), so the revision the read is handed is never consulted -- the bridge takes NO revision parameter.'),
    }
    read_bridge_outputs = {
        'rotation': a('float', 'rotation = read.f();', 'The rotation after load (PointDefenseTurret.java:127, `rotation = read.f();`): always the saved rotation -- there is no revision-0 fallback to the frame rotation, because the Java body never reads `revision`.'),
    }
    return write_bridge_inputs, write_bridge_outputs, read_bridge_inputs, read_bridge_outputs


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
    write_bridge_inputs, write_bridge_outputs, read_bridge_inputs, read_bridge_outputs = definitions()

    entries = [
        ('N2249', WRITE_BRIDGE_OWNER, 'source_point_defense_turret_build_write_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.write()', write_bridge_inputs, write_bridge_outputs, True, 'Dictionary'),
        ('N2249', READ_BRIDGE_OWNER, 'source_point_defense_turret_build_read_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.read()', read_bridge_inputs, read_bridge_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret persistence-integration bridge from PointDefenseTurret.java + BaseTurret.java + BuildingComp.java + ReloadTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret persistence-integration bridge from PointDefenseTurret.java + BaseTurret.java + BuildingComp.java + ReloadTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: bridge write.rotation, bridge read.rotation.
    by_slice['N2249'] = [
        'source_point_defense_turret_build_write_state_result.rotation',
        'source_point_defense_turret_build_read_state_result.rotation',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2249', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.write()/read()', godot_owner=WRITE_BRIDGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2249'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
