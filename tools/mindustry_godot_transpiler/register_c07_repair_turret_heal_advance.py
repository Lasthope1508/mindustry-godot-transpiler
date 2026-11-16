"""Register the RepairTurret heal advance (N2213).

N2212 stamped the live target (the acquire) and N2209 ported
the coolant multiplier the heal multiplies by. This slice is
the heal advance itself: RepairPointBuild.updateTile heals
the acquired target only when it has efficiency and the beam
is aimed at it (`if(target != null && efficiency > 0){` /
`float angle = Angles.angle(x, y, target.x + offset.x,
target.y + offset.y);` / `if(Angles.angleDist(angle,
rotation) < 30f){` / `healed = true;` /
`target.heal(repairSpeed * strength * edelta() *
multiplier);`, RepairTurret.java:203-207). The rotation
slerp (`rotation = Mathf.slerpDelta(rotation, angle, 0.5f *
efficiency * timeScale);`, RepairTurret.java:208) and the
strength lerp (`strength = Mathf.lerpDelta(strength, healed
? 1f : 0f, 0.08f * Time.delta);`, RepairTurret.java:211) are
NOT this slice -- they wait for their own slices (the N2212
handoff deferral: "heal advance, rotation slerp, strength
lerp -- separate slices").

RED decisions (pinned by this slice): (1) One pure function
on SourceRepairTurretBuildState.gd as
source_repair_turret_heal_advance_state(frame, x, y,
repair_speed, delta, multiplier) returning `{"healed": ...,
"heal_amount": ..., "target": ..., "target_health": ...}`.
The frame carries the target dict (already validated by the
N2212 acquire, which runs first in the same tick),
rotation (Java field default 90, `public float strength,
rotation = 90;`, RepairTurret.java:155), strength (Java
field default 0), efficiency (folded, absent -> 1.0, the
N2174 fold), and the beam offset (Vector2.ZERO when there
is no target). (2) edelta is efficiency * delta
(BuildingComp.java:1927-1928, `return efficiency * delta();`,
with delta() = Time.delta * timeScale,
BuildingComp.java:1922-1923) -- the driver passes its
per-tick seconds as delta, the same `seconds` the N2212
acquire uses. (3) The angle follows Angles.angle exactly:
atan2(dx, dy) in degrees, normalized to [0, 360)
(Angles.java:56-58); the distance is the minimal circular
distance in [0, 180] (Angles.java:23-26); the cone is
STRICT `< 30` (30.0 exactly does not heal). (4) `healed`
is set by the angle gate, not by the amount: Java sets
`healed = true;` before the heal call, so a strength-0
turret still reports healed with a 0.0 amount.
HealthComp.heal(float) adds the amount and clamps
(`health += amount;` / `clampHealth();`,
HealthComp.java:109-111, with `health = Math.min(health,
maxHealth);`, HealthComp.java:104). The returned target is
a DUPLICATE with the healed health -- the input dict is not
mutated, so the driver stamps the returned target. (5)
UnitComp.heal(float) only sets the wasHealed flag
(UnitComp.java:623-625) -- the port tracks no wasHealed on
unit records, so that side effect is unmodeled; the health
increase itself is HealthComp.heal. (6) The driver calls
the heal advance after the acquire with the per-def
repairSpeed (repair-point 0.45f, repair-turret 3f,
Blocks.java:6388/6400; class default 0.3f,
RepairTurret.java:32) and the N2209 coolant multiplier as
`multiplier`, stamping the returned target / target_health
live (the N2212 driver-line precedent). Shard note: the
N2212 precedent applies -- no source_modules shard is
expected to match RepairTurret.java, so the GREEN register
run must record that no shard changes.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_turret_target_acquire import DEFERRED as _N2212_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
ANGLES = 'arc-core/src/arc/math/Angles.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
PROOF = '/root/C07RepairTurretHealAdvanceProof'
HEAL_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_heal_advance_state'
TESTS = ['test_c07_repair_turret_heal_advance_registration', 'test_all_c07_repair_turret_heal_advance_input_evidence_is_exact', 'test_repair_turret_heal_advance_state', 'test_reference_graph_and_actual_c07_repair_turret_heal_advance']
# The 6 slice sources the N2213 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'arc-core/src/arc/math/Angles.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
]
EXACT_EXPRS = ['public class RepairTurret extends Block{', 'public float repairSpeed = 0.3f;', 'public float repairRadius = 50f;', 'public Unit target;', 'public float strength, rotation = 90;', 'public void updateTile(){', 'float multiplier = 1f;', 'if(acceptCoolant){', 'multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', 'boolean healed = false;', 'if(target != null && efficiency > 0){', 'float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', 'if(Angles.angleDist(angle, rotation) < 30f){', 'healed = true;', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);', 'strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'void heal(float amount){', 'health += amount;', 'clampHealth();', 'health = Math.min(health, maxHealth);', 'public float delta(){', 'return Time.delta * timeScale;', 'public float edelta(){', 'return efficiency * delta();', 'public static float angle(float x, float y, float x2, float y2){', 'float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', 'if(ang < 0) ang += 360f;', 'public static float angleDist(float a, float b){', 'a = Mathf.mod(a, 360f);', 'b = Mathf.mod(b, 360f);', 'return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);', 'repairSpeed = 0.45f;', 'repairSpeed = 3f;', 'repairPoint = new RepairTurret("repair-point"){{', 'repairTurret = new RepairTurret("repair-turret"){{', 'public void heal(float amount){', 'wasHealed = true;']

# DEFERRED is carried from the N2212 register script via import --
# never retyped. The N2212 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2211 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2213's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# rotation slerp (RepairTurret.java:208) and strength lerp
# (RepairTurret.java:211) are NOT carried as deferred here beyond
# the docstring above -- they wait for their own slices, as this
# script's docstring records.
DEFERRED = list(_N2212_DEFERRED) + [
    'RepairTurret heal advance Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2212: the N2213 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    heal_inputs = {
        'frame': a('Dictionary', 'public Unit target;', 'The turret frame (RepairTurret.java:154, `public Unit target;` -- the frame carries the current target dict, rotation, strength, efficiency, and the beam offset; absent keys read the Java field defaults: rotation 90, strength 0, efficiency 1.0, offset zero).'),
        'x': a('float', 'float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', 'The turret x (RepairTurret.java:204 -- the Building x Java passes to Angles.angle; the driver reads sprite.position.x).'),
        'y': a('float', 'float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', 'The turret y (RepairTurret.java:204 -- the Building y Java passes to Angles.angle; the driver reads sprite.position.y).'),
        'repair_speed': a('float', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'The per-def repairSpeed (RepairTurret.java:207 -- class default `public float repairSpeed = 0.3f;`, RepairTurret.java:32; repair-point 0.45f, repair-turret 3f, Blocks.java:6388/6400).'),
        'delta': a('float', 'return efficiency * delta();', 'The tick delta in seconds (BuildingComp.java:1928, `return efficiency * delta();` -- edelta is efficiency * delta, and delta() is Time.delta * timeScale, BuildingComp.java:1922-1923; the driver passes its per-tick seconds, the same `seconds` the N2212 acquire uses).', source=BUILDING_COMP),
        'multiplier': a('float', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'The heal multiplier (RepairTurret.java:207 -- the N2209 coolant multiplier: 1.0 without coolant, `1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency` when the def accepts coolant, RepairTurret.java:188-190).'),
    }
    heal_outputs = {
        'healed': a('bool', 'healed = true;', 'Whether the target was healed this tick: the angle gate passed with a target and efficiency > 0 (RepairTurret.java:205-206, `if(Angles.angleDist(angle, rotation) < 30f){` / `healed = true;` -- set by the gate, not by the amount, so a strength-0 turret still reports healed with a 0.0 amount).'),
        'heal_amount': a('float', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'The health added this tick: repairSpeed * strength * edelta * multiplier (RepairTurret.java:207 -- 0.0 when the gate fails or strength is 0).'),
        'target': a('Dictionary', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'The target after this tick: a duplicate of the frame target dict with the healed health, or null when the frame carries no target dict (RepairTurret.java:207 -- the heal mutates the live Unit in Java; the port returns a duplicate so the input dict is not mutated and the driver stamps the returned target).'),
        'target_health': a('float', 'health += amount;', 'The target health after this tick, clamped at maxHealth (HealthComp.java:110, `health += amount;` with clampHealth, HealthComp.java:104 -- 0.0 when the frame carries no target dict; unchanged when the gate fails).', source=HEALTH_COMP),
    }
    return heal_inputs, heal_outputs


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
    heal_inputs, heal_outputs = definitions()

    entries = [
        ('N2213', HEAL_OWNER, 'source_repair_turret_heal_advance_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.updateTile()', heal_inputs, heal_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret heal advance from RepairTurret.java / HealthComp.java / BuildingComp.java / Angles.java / Blocks.java / UnitComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret heal advance from RepairTurret.java / HealthComp.java / BuildingComp.java / Angles.java / Blocks.java / UnitComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: healed + heal_amount + target
    # + target_health.
    by_slice['N2213'] = [
        'source_repair_turret_heal_advance_state_result.healed',
        'source_repair_turret_heal_advance_state_result.heal_amount',
        'source_repair_turret_heal_advance_state_result.target',
        'source_repair_turret_heal_advance_state_result.target_health',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2213', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.updateTile()', godot_owner=HEAL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2213'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
