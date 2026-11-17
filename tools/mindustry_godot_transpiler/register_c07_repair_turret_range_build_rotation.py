"""Register the RepairTurret range() / buildRotation() rows (N2233).

RepairPointBuild.range() (RepairTurret.java:230-233, `@Override
public float range(){` / `return repairRadius;`) returns the
per-def repairRadius: class default 50f (`public float
repairRadius = 50f;`, RepairTurret.java:32), repair-point 60f
(`repairRadius = 60f;`, Blocks.java:6389), repair-turret 145f
(`repairRadius = 145f;`, Blocks.java:6401) -- from the Ranged
interface (`public interface Ranged extends Posc, Teamc{` /
`float range();`, Ranged.java:5-6). RepairPointBuild.
buildRotation() (RepairTurret.java:158-161, `@Override public
float buildRotation(){` / `return rotation;`) returns the
rotation field (`public float strength, rotation = 90;`,
RepairTurret.java:156) -- from the RotBlock interface
(`public interface RotBlock{` / `float buildRotation();`,
RotBlock.java:4-5). These are the last two RepairTurret-level
methods without a slice: setStats N2224, init N2226, drawPlace
N2220, icons N2227, drawBeam N2219, draw N2225, drawSelect
N2220, shouldAmbientSound N2221, updateTile N2174/N2209/
N2212-N2215, shouldConsume N2188, status N2221, write/read/
version N2217, sense N2223, ambient-sound loop N2222 -- only
range() and buildRotation() had no ledger entry (grep ledger
`RepairPointBuild.range` / `buildRotation` = 0 hits).

RED decisions (resolved at RED): (1) Two pure functions on
the same family file N2174 / N2188 / N2209 / N2212-N2215 /
N2217 / N2219-N2227 built: range takes the per-def
repair_radius explicitly (per-def static state, not a live
frame key -- the N2212 / N2220 precedent; resolved by the
existing `_repair_radius_for_block_id` helper, repair-point
60f / repair-turret 145f / class default 50f) and
buildRotation reads the live `frame["rotation"]` key
(stamped by the N2214 slerp + N2217 read/write, absent
folding to 90.0, the Java field init -- the N2223
sense(rotation) precedent). (2) There is NO driver tick line
for either accessor: both are pure reads (the N2223 sense /
N2230 setStats / N2232 RepairTower range+warmup precedent).
(3) The deferred pool entry "RepairTurret status() / range()
rows" is dropped -- both halves are now done (status() at
N2221, range() here) -- and replaced by the N2233
Windows-proof debt entry. (4) config-display stays
deferred: it is BuildingComp-level work (display()
BuildingComp.java:1556, senseObject(config) BuildingComp.
java:2139-2146, configSenseable Block.java:809-813),
investigated at N2222 RED and N2224, bigger and unpinned.
(5) Suppression live + targets live list stay BLOCKED: no
`frame["units"] =` stamp exists anywhere in src/game (the
RepairTower driver reads `frame.get("units", [])` and always
gets []), and no frame stamps `heal_suppressed` /
`heal_suppression_time` (the is_heal_suppressed bridge
exists but no driver calls it; healSuppressionTime is only
set by applyHealSuppression from damage paths) -- wiring the
bridge with a never-stamped input would be vacuous. Two new
result symbols: range, build_rotation. SSOT expected after
GREEN: symbols +2, Done +1, contracts +2, schema +4,
11522/1682/1612/3015 -> 11524/1683/1614/3019. Slice sources:
RepairTurret.java + Blocks.java + Ranged.java + RotBlock.java.
No shard change: RepairTurret.java matches no shard (the
N2213-N2227 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
RANGED = 'core/src/mindustry/logic/Ranged.java'
ROT_BLOCK = 'core/src/mindustry/world/blocks/RotBlock.java'
PROOF = '/root/C07RepairTurretRangeBuildRotationProof'
RANGE_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_range_state'
BUILD_ROTATION_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_build_rotation_state'
TESTS = ['test_c07_repair_turret_range_build_rotation_registration', 'test_all_c07_repair_turret_range_build_rotation_input_evidence_is_exact', 'test_repair_turret_range_build_rotation_state', 'test_reference_graph_and_actual_c07_repair_turret_range_build_rotation']
# The 4 slice sources the N2233 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/logic/Ranged.java',
    'core/src/mindustry/world/blocks/RotBlock.java',
]
EXACT_EXPRS = ['public float range(){', 'return repairRadius;', 'public float buildRotation(){', 'return rotation;', 'public float strength, rotation = 90;', 'public float repairRadius = 50f;', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'public class RepairTurret extends Block{', 'repairRadius = 60f;', 'repairRadius = 145f;', 'public interface Ranged extends Posc, Teamc{', 'float range();', 'public interface RotBlock{', 'float buildRotation();']

# DEFERRED is carried from the N2227 register script via import --
# never retyped. The N2227 script's DEFERRED is a computed
# list(...) + [...] expression, so carry it forward by import,
# not by ast.literal_eval (the N2227 register docstring). The
# lumped entry "RepairTurret status() / range() rows" is DROPPED
# here -- both halves are now done (status() at N2221, range()
# at N2233) -- and replaced by the new entry below, which keeps
# the Windows-proof debt; every other entry is carried verbatim
# (the N2211/N2228 lesson -- never retype the pool). The filter
# drops only the entry carrying the exact lumped phrase, so other
# RepairTurret deferrals (config-display, drawBeam jitter/pulse,
# suppression, targets) survive untouched.
DEFERRED = [e for e in N2227_DEFERRED if 'RepairTurret status() / range() rows' not in e] + [
    'RepairTurret range() / buildRotation() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2227: the N2233 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    range_inputs = {
        'repair_radius': a('float', 'public float repairRadius = 50f;', 'The per-def repair radius (RepairTurret.java:32, `public float repairRadius = 50f;` -- repair-point 60f, Blocks.java:6389, `repairRadius = 60f;`; repair-turret 145f, Blocks.java:6401, `repairRadius = 145f;`): passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2220 per-def-param precedent; resolved by the existing `_repair_radius_for_block_id` helper).'),
    }
    range_outputs = {
        'range': a('float', 'return repairRadius;', 'The range (RepairTurret.java:232, `return repairRadius;`, inside `public float range(){`, RepairTurret.java:231, from the Ranged interface, Ranged.java:5-6, `public interface Ranged extends Posc, Teamc{` / `float range();`).'),
    }
    build_rotation_inputs = {
        'frame': a('Dictionary', 'public float strength, rotation = 90;', 'The turret frame (RepairTurret.java:156, `public float strength, rotation = 90;` -- the frame carries rotation, stamped live by the N2214 slerp + N2217 read/write; an absent key reads the Java field default, rotation 90).'),
    }
    build_rotation_outputs = {
        'build_rotation': a('float', 'return rotation;', 'The build rotation (RepairTurret.java:160, `return rotation;`, inside `public float buildRotation(){`, RepairTurret.java:159, from the RotBlock interface, RotBlock.java:4-5, `public interface RotBlock{` / `float buildRotation();`).'),
    }
    return range_inputs, range_outputs, build_rotation_inputs, build_rotation_outputs


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
    range_inputs, range_outputs, build_rotation_inputs, build_rotation_outputs = definitions()

    entries = [
        ('N2233', RANGE_OWNER, 'source_repair_turret_range_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.range()', range_inputs, range_outputs, True, 'Dictionary'),
        ('N2233', BUILD_ROTATION_OWNER, 'source_repair_turret_build_rotation_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.buildRotation()', build_rotation_inputs, build_rotation_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret range()/buildRotation() state from RepairTurret.java + Blocks.java + Ranged.java + RotBlock.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret range()/buildRotation() state from RepairTurret.java + Blocks.java + Ranged.java + RotBlock.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: range, build_rotation.
    by_slice['N2233'] = [
        'source_repair_turret_range_state_result.range',
        'source_repair_turret_build_rotation_state_result.build_rotation',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2233', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.range()/RepairPointBuild.buildRotation()', godot_owner=RANGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2233'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
