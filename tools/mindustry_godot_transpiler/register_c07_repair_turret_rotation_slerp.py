"""Register the RepairTurret rotation slerp (N2214).

N2213 healed the acquired target; this slice is the rotation
slerp on the very next line: RepairPointBuild.updateTile
rotates the turret toward the acquired target (`rotation =
Mathf.slerpDelta(rotation, angle, 0.5f * efficiency *
timeScale);`, RepairTurret.java:209), inside the same
`if(target != null && efficiency > 0){` gate
(RepairTurret.java:203) but OUTSIDE the aim-cone
`if(Angles.angleDist(angle, rotation) < 30f){`
(RepairTurret.java:205) -- the cone gates only the heal
(RepairTurret.java:206-207), so the turret still turns toward
a target outside the cone. The strength lerp (`strength =
Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f *
Time.delta);`, RepairTurret.java:212) is NOT this slice --
it waits for its own slice (the N2213 handoff deferral:
"rotation slerp, strength lerp -- separate slices").

RED decisions (pinned by this slice): (1) One pure function
on SourceRepairTurretBuildState.gd as
source_repair_turret_rotation_slerp_state(frame, x, y, delta,
time_scale) returning `{"rotation": ...}`. The frame carries
the target dict (already validated by the N2212 acquire,
which runs first in the same tick), rotation (Java field
default 90, `public float strength, rotation = 90;`,
RepairTurret.java:155), efficiency (folded, absent -> 1.0,
the N2174 fold), and the beam offset (Vector2.ZERO when
there is no target). x/y are the turret position, the N2213
precedent -- the angle cannot be computed without them.
(2) The angle follows Angles.angle exactly: atan2(dx, dy) in
degrees, normalized to [0, 360) (Angles.java:56-58).
(3) slerpDelta multiplies its progress by Time.delta and
clamps to [0, 1] (Mathf.java:460-462, `return
slerp(fromDegrees, toDegrees, clamp(progress *
Time.delta));`), and slerp always takes the shortest
circular path (Mathf.java:455-458). The driver passes its
per-tick seconds as delta, the same `seconds` the N2212
acquire and the N2213 heal use, so the pure function folds
it as `0.5 * efficiency * time_scale * delta` and clamps.
(4) timeScale is the Building's own field (BuildingComp.java:98,
`private transient float timeScale = 1f`, read through
`timeScale()`, BuildingComp.java:599-600) -- NOT the global
Time.timeScale. No frame key stamps it yet, so the driver
passes `frame.get("time_scale", 1.0)` -- the Java default 1f
-- and a future timeScale slice only needs to stamp the
frame key. (5) The driver calls the slerp AFTER the N2213
heal in the same tick (the Java order: angle -> cone/heal ->
slerp), because the heal reads the pre-slerp rotation for its
cone check. (6) The result carries ONLY rotation: angle is
an intermediate like edelta in N2213, no consumer stamps
it. Shard note: the N2213 precedent applies -- no
source_modules shard is expected to match RepairTurret.java,
so the GREEN register run must record that no shard changes.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_turret_heal_advance import DEFERRED as _N2213_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
ANGLES = 'arc-core/src/arc/math/Angles.java'
TIME = 'arc-core/src/arc/util/Time.java'
PROOF = '/root/C07RepairTurretRotationSlerpProof'
SLERP_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_rotation_slerp_state'
TESTS = ['test_c07_repair_turret_rotation_slerp_registration', 'test_all_c07_repair_turret_rotation_slerp_input_evidence_is_exact', 'test_repair_turret_rotation_slerp_state', 'test_reference_graph_and_actual_c07_repair_turret_rotation_slerp']
# The 5 slice sources the N2214 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'arc-core/src/arc/math/Mathf.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'arc-core/src/arc/math/Angles.java',
    'arc-core/src/arc/util/Time.java',
]
EXACT_EXPRS = ['public class RepairTurret extends Block{', 'public float strength, rotation = 90;', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'public void updateTile(){', 'if(target != null && efficiency > 0){', 'float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', 'if(Angles.angleDist(angle, rotation) < 30f){', 'healed = true;', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);', 'strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', 'public Unit target;', 'public static float slerpDelta(float fromDegrees, float toDegrees, float progress){', 'return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));', 'public static float slerp(float fromDegrees, float toDegrees, float progress){', 'float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;', 'return (fromDegrees + delta * progress + 360) % 360;', 'public static float clamp(float value){', 'return Math.max(Math.min(value, 1f), 0f);', 'private transient float timeScale = 1f, timeScaleDuration;', 'public float timeScale(){', 'return timeScale;', 'public float delta(){', 'return Time.delta * timeScale;', 'public static float angle(float x, float y, float x2, float y2){', 'float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', 'if(ang < 0) ang += 360f;', 'public static float delta = 1f;']

# DEFERRED is carried from the N2213 register script via import --
# never retyped. The N2213 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2212 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2214's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# strength lerp (RepairTurret.java:212) is NOT carried as deferred
# here beyond the docstring above -- it waits for its own slice,
# as this script's docstring records.
DEFERRED = list(_N2213_DEFERRED) + [
    'RepairTurret rotation slerp Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2213: the N2214 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    slerp_inputs = {
        'frame': a('Dictionary', 'public Unit target;', 'The turret frame (RepairTurret.java:154, `public Unit target;` -- the frame carries the current target dict, rotation, efficiency, and the beam offset; absent keys read the Java field defaults: rotation 90, efficiency 1.0, offset zero).'),
        'x': a('float', 'float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', 'The turret x (RepairTurret.java:204 -- the Building x Java passes to Angles.angle; the driver reads sprite.position.x).'),
        'y': a('float', 'float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', 'The turret y (RepairTurret.java:204 -- the Building y Java passes to Angles.angle; the driver reads sprite.position.y).'),
        'delta': a('float', 'return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));', 'The tick delta in seconds (Mathf.java:461, `return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));` -- slerpDelta multiplies its progress by Time.delta; the driver passes its per-tick seconds, the same `seconds` the N2212 acquire and the N2213 heal use).', source=MATHF),
        'time_scale': a('float', 'private transient float timeScale = 1f, timeScaleDuration;', 'The Building timeScale (BuildingComp.java:98, `private transient float timeScale = 1f, timeScaleDuration;` -- read through `timeScale()`, BuildingComp.java:599-600; the driver passes `frame.get("time_scale", 1.0)`, the Java default, until a timeScale slice stamps the frame key).', source=BUILDING_COMP),
    }
    slerp_outputs = {
        'rotation': a('float', 'rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);', 'The rotation after this tick: slerped toward the target angle by `0.5 * efficiency * timeScale * delta`, clamped to [0, 1], along the shortest circular path (RepairTurret.java:209 with Mathf.java:455-462 -- unchanged when the frame carries no target dict or efficiency <= 0).'),
    }
    return slerp_inputs, slerp_outputs


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
    slerp_inputs, slerp_outputs = definitions()

    entries = [
        ('N2214', SLERP_OWNER, 'source_repair_turret_rotation_slerp_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.updateTile()', slerp_inputs, slerp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret rotation slerp from RepairTurret.java / Mathf.java / BuildingComp.java / Angles.java / Time.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret rotation slerp from RepairTurret.java / Mathf.java / BuildingComp.java / Angles.java / Time.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation only.
    by_slice['N2214'] = [
        'source_repair_turret_rotation_slerp_state_result.rotation',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2214', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.updateTile()', godot_owner=SLERP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2214'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
