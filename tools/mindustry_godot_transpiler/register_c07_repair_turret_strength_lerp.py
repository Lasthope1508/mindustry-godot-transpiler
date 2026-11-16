"""Register the RepairTurret strength lerp (N2215).

N2214 slerped the rotation toward the target; this slice is the
strength lerp on the next line: RepairPointBuild.updateTile
fades the beam strength toward 1 while healing and toward 0
otherwise (`strength = Mathf.lerpDelta(strength, healed ? 1f
: 0f, 0.08f * Time.delta);`, RepairTurret.java:212). Unlike
the heal and the slerp, the lerp sits OUTSIDE the `if(target
!= null && efficiency > 0){` gate (RepairTurret.java:203) --
it runs on EVERY tick, so a turret that stops healing decays
its beam back to 0 instead of freezing at full strength.
`healed` is the same tick's local (`boolean healed = false;`,
RepairTurret.java:200, set `healed = true;` only inside the
aim cone, RepairTurret.java:206, before the heal,
RepairTurret.java:207) -- the N2213 heal stamps it on the
frame, so the pure function reads `frame["healed"]` (absent
-> false, no heal observed).

RED decisions (pinned by this slice): (1) One pure function
on SourceRepairTurretBuildState.gd as
source_repair_turret_strength_lerp_state(frame, delta)
returning `{"strength": ...}`. The frame carries strength
(Java field default 0, `public float strength, rotation =
90;`, RepairTurret.java:155) and healed (stamped by the N2213
heal in the same tick, before this call). (2) lerpDelta
multiplies its progress by Time.delta and clamps to [0, 1]
(Mathf.java:430-432, `return lerp(fromValue, toValue,
clamp(progress * Time.delta));`), and lerp is the plain
linear interpolation (Mathf.java:425-427). The driver passes
its per-tick seconds as delta, the same `seconds` the N2212
acquire, the N2213 heal and the N2214 slerp use, so the pure
function folds it as `0.08 * delta` and clamps. (3) The
driver calls the lerp AFTER the N2214 slerp in the same tick
(the Java order: angle -> cone/heal -> slerp -> strength
lerp), because the heal reads the pre-lerp strength. (4) The
result carries ONLY strength. (5) This is the FIRST stamp of
`frame["strength"]` -- before N2215 the N2213 heal read
strength 0.0 forever, so no repair turret ever healed
anything. Shard note: the N2213/N2214 precedent applies -- no
source_modules shard is expected to match RepairTurret.java,
so the GREEN register run must record that no shard changes.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_turret_rotation_slerp import DEFERRED as _N2214_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
TIME = 'arc-core/src/arc/util/Time.java'
PROOF = '/root/C07RepairTurretStrengthLerpProof'
LERP_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_strength_lerp_state'
TESTS = ['test_c07_repair_turret_strength_lerp_registration', 'test_all_c07_repair_turret_strength_lerp_input_evidence_is_exact', 'test_repair_turret_strength_lerp_state', 'test_reference_graph_and_actual_c07_repair_turret_strength_lerp']
# The 3 slice sources the N2215 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'arc-core/src/arc/math/Mathf.java',
    'arc-core/src/arc/util/Time.java',
]
EXACT_EXPRS = ['public class RepairTurret extends Block{', 'public float strength, rotation = 90;', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'public void updateTile(){', 'boolean healed = false;', 'if(target != null && efficiency > 0){', 'healed = true;', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', 'public static float lerp(float fromValue, float toValue, float progress){', 'return fromValue + (toValue - fromValue) * progress;', 'public static float lerpDelta(float fromValue, float toValue, float progress){', 'return lerp(fromValue, toValue, clamp(progress * Time.delta));', 'public static float clamp(float value){', 'return Math.max(Math.min(value, 1f), 0f);', 'public static float delta = 1f;']

# DEFERRED is carried from the N2214 register script via import --
# never retyped. The N2214 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2213 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2215's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(_N2214_DEFERRED) + [
    'RepairTurret strength lerp Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2214: the N2215 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    lerp_inputs = {
        'frame': a('Dictionary', 'public float strength, rotation = 90;', 'The turret frame (RepairTurret.java:155, `public float strength, rotation = 90;` -- the frame carries the current strength, default 0, and the same tick\'s healed flag stamped by the N2213 heal; absent healed reads false, no heal observed).'),
        'delta': a('float', 'return lerp(fromValue, toValue, clamp(progress * Time.delta));', 'The tick delta in seconds (Mathf.java:431, `return lerp(fromValue, toValue, clamp(progress * Time.delta));` -- lerpDelta multiplies its progress by Time.delta; the driver passes its per-tick seconds, the same `seconds` the N2212 acquire, the N2213 heal and the N2214 slerp use).', source=MATHF),
    }
    lerp_outputs = {
        'strength': a('float', 'strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', 'The strength after this tick: lerped toward 1 while healing and toward 0 otherwise, by `0.08 * delta` clamped to [0, 1] (RepairTurret.java:212 with Mathf.java:425-432 -- runs on every tick, outside the target/efficiency gate, so strength decays toward 0 with no target or no power).'),
    }
    return lerp_inputs, lerp_outputs


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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    lerp_inputs, lerp_outputs = definitions()

    entries = [
        ('N2215', LERP_OWNER, 'source_repair_turret_strength_lerp_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.updateTile()', lerp_inputs, lerp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret strength lerp from RepairTurret.java / Mathf.java / Time.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret strength lerp from RepairTurret.java / Mathf.java / Time.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: strength only.
    by_slice['N2215'] = [
        'source_repair_turret_strength_lerp_state_result.strength',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2215', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.updateTile()', godot_owner=LERP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2215'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
