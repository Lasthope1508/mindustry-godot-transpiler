"""Register the Turret control() setters (N2264).

TurretBuild.control() arms the logic-control timer from a
logic shoot / shootp instruction, outside updateTile():
`if(type == LAccess.shoot && !unit.isPlayer()){`
`targetPos.set(World.unconv((float)p1), World.unconv((float)p2));`
`logicControlTime = logicControlCooldown;`
`logicShooting = !Mathf.zero(p3);`
(Turret.java:382-386) and
`if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){`
`logicControlTime = logicControlCooldown;`
`logicShooting = !Mathf.zero(p2);`
`if(p1 instanceof Posc pos){`
`targetPosition(pos);`
(Turret.java:393-400). The cooldown is
`public final static float logicControlCooldown = 60 * 2;`
(:38 -- 120 ticks of logic control), the timer field is
`public float curRecoil, heat, logicControlTime = -1;`
(:284), the flag field is
`public boolean logicShooting = false;` (:287) and the
target field is `public Vec2 targetPos = new Vec2();`
(:289). The reader is `logicControlled()`
(`return logicControlTime > 0;`, :445-447), so the arm is
observable through the isShooting gate (:492) on the very
next tick -- the N2261 decay tick only ever reads the frame
value, it never arms it. World.unconv is
`public static float unconv(float coord){`
`return coord * tilesize;` (World.java:170-172) with
`public static final int tilesize = 8;` (Vars.java:135),
and Mathf.zero is `return Math.abs(value) <=
FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524) with
`public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
(:10).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_control_state(control_type, p1, p2, p3,
unit_is_player, unit_is_null, logic_control_time,
logic_shooting, target_pos, target_is_posc, tilesize),
returning `{"logic_control_time": .., "logic_shooting": ..,
"target_pos": {"x": .., "y": ..}, "target_position_deferred": ..}` --
shoot with a non-player unit sets targetPos to (p1, p2)
unconv'd (times tilesize), arms the timer to 120 and sets
logicShooting from !zero(p3); shootp with a null or
non-player unit arms the timer to 120 and sets
logicShooting from !zero(p2), and reports
target_position_deferred true when p1 is a Posc (the
targetPosition(pos) call itself waits for its own slice:
hasAmmo / peekAmmo plus Predict.intercept, :453-471);
any other type, or a player-controlled unit, returns all
inputs unchanged. (2) No driver tick: control() is
event-driven (called by the logic executor) and no logic
executor exists in the driver yet -- the N2248 precedent --
so the proof calls the pure function directly. (3) The
BuildingComp super.control() enabled/config cases
(BuildingComp.java:2150-2161) are their own slices; the
TurretBuild arms only model shoot/shootp. SSOT expected
after GREEN: symbols +4, Done +1, contracts +1, schema +2,
11622/1713/1647/3085 -> 11626/1714/1648/3087; defense
shard slices 192 -> 193, contracts 191 -> 192.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_heat_req import DEFERRED as N2263_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
WORLD = 'core/src/mindustry/core/World.java'
VARS = 'core/src/mindustry/Vars.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07TurretControlProof'
CONTROL_OWNER = 'SourceTurretBuildState.source_turret_control_state'
TESTS = ['test_c07_turret_control_registration', 'test_all_c07_turret_control_input_evidence_is_exact', 'test_turret_control_state', 'test_reference_graph_and_actual_c07_turret_control']
# The slice sources the N2264 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/core/World.java',
    'core/src/mindustry/Vars.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = ['if(type == LAccess.shoot && !unit.isPlayer()){', 'targetPos.set(World.unconv((float)p1), World.unconv((float)p2));', 'logicControlTime = logicControlCooldown;', 'logicShooting = !Mathf.zero(p3);', 'public final static float logicControlCooldown = 60 * 2;', 'if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){', 'logicShooting = !Mathf.zero(p2);', 'if(p1 instanceof Posc pos){', 'targetPosition(pos);', 'public float curRecoil, heat, logicControlTime = -1;', 'public boolean logicShooting = false;', 'public Vec2 targetPos = new Vec2();']

# DEFERRED is carried from the N2263 register script via import --
# never retyped. The control() setters are done by this slice
# (they were the next item named in the N2263 handoff); the
# targetPosition(pos) call, the calculateHeat live proximity
# scan, the efficiency fold, the maxHealth/health re-sync, the
# set(tile) world position, the cross-tick queuedBullets
# counter, effects/sound, findTarget / the other ItemTurret
# defs still wait.
DEFERRED = list(N2263_DEFERRED) + [
    'Turret control() setters Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2263: the N2264 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret control() setters arming logicControlTime = logicControlCooldown (Turret.java:384/:394) -- DONE by this slice (N2264); it was the next item named in the N2263 handoff.',
    'Turret control() targetPosition(pos) call (Turret.java:398, :453-471) -- waits for its own slice: needs hasAmmo / peekAmmo plus Predict.intercept (accurateDelay / moveWhileCharging offset, predictTarget gating); the shootp arm only reports target_position_deferred.',
    'Turret control() for defs other than duo -- the pure function takes control_type / params as inputs; no driver tick exists yet (control() is event-driven, no logic executor in the driver).',
    'BuildingComp super.control() enabled/config cases (BuildingComp.java:2150-2161) -- waits for their own slices: the TurretBuild control() arms only model the shoot/shootp branches; other LAccess types return inputs unchanged.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    control_inputs = {
        'control_type': a('String', 'shoot("x", "y", "shoot"),', 'The logic access type of the control call (LAccess.java:81-82: shoot takes ("x", "y", "shoot"), shootp takes ("unit", "shoot") as an object access); "shoot" selects the double overload, "shootp" the Object overload, any other type changes nothing.', source=LACCESS),
        'p1': a('float', 'targetPos.set(World.unconv((float)p1), World.unconv((float)p2));', 'The first numeric param (Turret.java:383: the shoot x tile coord, unconv\'d to world coords; for shootp this param is the Posc object, so the caller passes 0.0 and the Posc-ness arrives via target_is_posc).'),
        'p2': a('float', 'logicShooting = !Mathf.zero(p2);', 'The second numeric param (Turret.java:396: the shootp shoot flag; for shoot this param is the y tile coord, read at :383).'),
        'p3': a('float', 'logicShooting = !Mathf.zero(p3);', 'The third numeric param (Turret.java:385: the shoot shoot flag; unused by the shootp overload).'),
        'unit_is_player': a('bool', 'if(type == LAccess.shoot && !unit.isPlayer()){', 'Whether the turret unit is player-controlled (Turret.java:382: the shoot guard requires !unit.isPlayer(); :393: shootp requires unit == null || !unit.isPlayer()).'),
        'unit_is_null': a('bool', 'if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){', 'Whether the turret unit is null (Turret.java:393: shootp arms when unit == null || !unit.isPlayer(); the shoot overload never sees a null unit -- the field is initialized at declaration, :290).'),
        'logic_control_time': a('float', 'logicControlTime = logicControlCooldown;', 'The logic-control timer before this control call (Turret.java:284, the field default is -1 -- never logic-controlled; the N2261 decay tick reads the armed value).'),
        'logic_shooting': a('bool', 'public boolean logicShooting = false;', 'The logic-shooting flag before this control call (Turret.java:287, the field default is false).'),
        'target_pos': a('Dictionary', 'public Vec2 targetPos = new Vec2();', 'The target position before this control call (Turret.java:289, the field default is (0, 0) in world coords).'),
        'target_is_posc': a('bool', 'if(p1 instanceof Posc pos){', 'Whether the shootp Object arg is a Posc (Turret.java:397: only then does Java call targetPosition(pos); the call itself is deferred, so this only drives the target_position_deferred flag).'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world-units-per-tile factor (Vars.java:135; World.unconv multiplies by it, World.java:170-172; the driver passes 8.0).', source=VARS),
    }
    control_outputs = {
        'logic_control_time': a('float', 'logicControlTime = logicControlCooldown;', 'The logic-control timer after this control call (Turret.java:384/:394 -- 120.0 when a shoot/shootp arm fires, unchanged otherwise; the N2261 decay tick then reads it).'),
        'logic_shooting': a('bool', 'logicShooting = !Mathf.zero(p3);', 'The logic-shooting flag after this control call (Turret.java:385 -- !zero(p3) for shoot, :396 -- !zero(p2) for shootp; unchanged when no arm fires).'),
        'target_pos': a('Dictionary', 'targetPos.set(World.unconv((float)p1), World.unconv((float)p2));', 'The target position after this control call (Turret.java:383 -- shoot sets (p1 * tilesize, p2 * tilesize); shootp leaves it unchanged because targetPosition(pos) is deferred).'),
        'target_position_deferred': a('bool', 'targetPosition(pos);', 'Whether Java would call targetPosition(pos) here (Turret.java:398 -- true only for shootp with a Posc arg; the call needs hasAmmo / peekAmmo plus Predict.intercept, :453-471, so it waits for its own slice).'),
    }
    return control_inputs, control_outputs


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
    control_inputs, control_outputs = definitions()

    entries = [
        ('N2264', CONTROL_OWNER, 'source_turret_control_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.control()', control_inputs, control_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret control() setters from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret control() setters from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: logic_control_time, logic_shooting,
    # target_pos, target_position_deferred.
    by_slice['N2264'] = [
        'source_turret_control_state_result.logic_control_time',
        'source_turret_control_state_result.logic_shooting',
        'source_turret_control_state_result.target_pos',
        'source_turret_control_state_result.target_position_deferred',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2264', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.control()', godot_owner=CONTROL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2264'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
