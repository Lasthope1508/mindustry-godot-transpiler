"""Register the Turret micro-accessors (N2297).

Four read accessors on TurretBuild (Turret.java:277,
`public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`)
in `public class Turret extends ReloadTurret{` (Turret.java:36):

- warmup() (Turret.java:354-356): `return shootWarmup;`
- drawrot() (Turret.java:359-361): `return rotation - 90;`
- canControl() (Turret.java:376-378): `return playerControllable;`
- logicControlled() (Turret.java:445-447): `return logicControlTime > 0;`

RED decisions (resolved at RED): (1) Four pure functions, one
per accessor -- each takes the family-convention frame first
arg plus ONE explicit param carrying the live value (the
N2311/N2261/N2282 precedent: super-leg / already-live fields
arrive as explicit params, do NOT re-port them). warmup()'s
shoot_warmup is advanced by the updateTile warmup leg (N2308,
Turret.java:502-515), NOT here; drawrot()'s rotation is the
RotComp float aim angle (`@SyncField(false) @SyncLocal float
rotation;`, RotComp.java:8, default 0.0) -- NOT the Building
int rotation 0-3 (`transient int rotation;`,
BuildingComp.java:69) -- and the caller binds it from the
frame bound by source_turret_bind_frame_state (frame["rotation"],
the carrier N2276's write/read already use, default 0.0);
canControl()'s player_controllable is the block-level Turret
field (Turret.java:97, `public boolean playerControllable =
true;`, "If true, this turret can be controlled by players.");
logicControlled()'s logic_control_time is the TurretBuild
field (`public float curRecoil, heat, logicControlTime = -1;`,
Turret.java:284), set to logicControlCooldown (`public final
static float logicControlCooldown = 60 * 2;`, Turret.java:38)
by control() (Turret.java:384/394) while logic holds the
turret. (2) NO driver tick line for any of the four: they
are read accessors their callers read, not per-tick writes
(the N2249/N2221 precedent) -- drawrot() is read by the
draw path, warmup() by the minWarmup fire gate
(Turret.java:733) and the sound loop, canControl() by the
control dispatch, logicControlled() by updateTile's
isShooting computation (Turret.java:492) and findTarget's
validateTarget (Turret.java:632); every caller waits for
its own slice. (3) controlled() (Turret.java:441-443,
`return unit.isPlayer();`) is EXPLICITLY OUT OF SCOPE: the
main thread decides separately whether it becomes its own
slice -- it is NOT ported here and NOT in EXACT_EXPRS.
Four new result symbols: warmup, drawrot, can_control,
logic_controlled. Three slice sources: Turret.java +
RotComp.java + BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_status import DEFERRED as N2285_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
ROT_COMP = 'core/src/mindustry/entities/comp/RotComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretMicroAccessorsProof'
WARMUP_OWNER = 'SourceTurretBuildState.source_turret_warmup_state'
DRAWROT_OWNER = 'SourceTurretBuildState.source_turret_drawrot_state'
CAN_CONTROL_OWNER = 'SourceTurretBuildState.source_turret_can_control_state'
LOGIC_CONTROLLED_OWNER = 'SourceTurretBuildState.source_turret_logic_controlled_state'
TESTS = ['test_c07_turret_micro_accessors_registration', 'test_all_c07_turret_micro_accessors_input_evidence_is_exact', 'test_turret_micro_accessors_state', 'test_reference_graph_and_actual_c07_turret_micro_accessors']
# The 3 slice sources the N2297 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/RotComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public float warmup(){',
    'return shootWarmup;',
    'public float shootWarmup, charge, warmupHold = 0f;',
    'public float drawrot(){',
    'return rotation - 90;',
    '@SyncField(false) @SyncLocal float rotation;',
    'transient int rotation;',
    'public boolean canControl(){',
    'return playerControllable;',
    'public boolean playerControllable = true;',
    'public boolean logicControlled(){',
    'return logicControlTime > 0;',
    'public float curRecoil, heat, logicControlTime = -1;',
    'public final static float logicControlCooldown = 60 * 2;',
]

# DEFERRED is carried from the N2285 register script via import --
# never retyped. Nothing in it closes here: none of the four
# accessors was a deferred entry of the Turret chain (the
# updateTile isShooting-computation entry that names
# logicControlled() stays deferred -- it is the Turret.java:492
# computation, not this accessor -- and the warmup driver-tick
# entry stays deferred -- no driver line is wired here, the
# N2249/N2221 precedent). Two entries are added: the N2297
# Windows Godot proof debt (GOAL.md section 5) and the
# controlled() out-of-scope note.
DEFERRED = N2285_DEFERRED + [
    'Turret micro-accessors (warmup/drawrot/canControl/logicControlled) Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2297 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TurretBuild.controlled() (Turret.java:441-443, `return unit.isPlayer();`) -- explicitly out of scope for N2297; the main thread decides separately whether it becomes its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    warmup_inputs = {
        'frame': a('Dictionary', 'public float warmup(){', 'The turret frame (TurretBuild.warmup, Turret.java:354): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- shoot_warmup arrives as an explicit param (the N2311/N2261 precedent), because the tick frame tracks no shoot_warmup key yet.'),
        'shoot_warmup': a('float', 'public float shootWarmup, charge, warmupHold = 0f;', 'The current warmup (`shootWarmup`, Turret.java:355): the TurretBuild field (`public float shootWarmup, charge, warmupHold = 0f;`, Turret.java:286, Java default 0f), advanced toward warmupTarget by the updateTile warmup leg (N2308, Turret.java:502-515) -- NOT re-ported here; read by warmup() and by the minWarmup fire gate (Turret.java:733).'),
    }
    warmup_outputs = {
        'warmup': a('float', 'return shootWarmup;', 'The warmup (Turret.java:355, `return shootWarmup;`): the TurretBuild shootWarmup field as-is.'),
    }
    drawrot_inputs = {
        'frame': a('Dictionary', 'public float drawrot(){', 'The turret frame (TurretBuild.drawrot, Turret.java:359): the family-convention first arg every Turret pure function takes; the rotation value itself arrives as an explicit param, bound by the caller from the frame bound by source_turret_bind_frame_state (frame["rotation"], the carrier N2276\'s write/read already use, default 0.0).'),
        'rotation': a('float', '@SyncField(false) @SyncLocal float rotation;', 'The aim angle (`rotation`, Turret.java:360): the RotComp float aim angle (`@SyncField(false) @SyncLocal float rotation;`, RotComp.java:8, default 0.0) -- NOT the Building int rotation 0-3 (`transient int rotation;`, BuildingComp.java:69); drawrot() subtracts 90 to convert the aim angle to draw rotation.', source=ROT_COMP),
    }
    drawrot_outputs = {
        'drawrot': a('float', 'return rotation - 90;', 'The draw rotation (Turret.java:360, `return rotation - 90;`): the aim angle minus 90 degrees.'),
    }
    can_control_inputs = {
        'frame': a('Dictionary', 'public boolean canControl(){', 'The turret frame (TurretBuild.canControl, Turret.java:376): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- player_controllable arrives as an explicit param (the N2311/N2261 precedent), because it is a block-level def field, not build state.'),
        'player_controllable': a('bool', 'public boolean playerControllable = true;', 'Whether players may control this turret (`playerControllable`, Turret.java:377): the block-level Turret field (`public boolean playerControllable = true;`, Turret.java:97, "If true, this turret can be controlled by players."), default true.'),
    }
    can_control_outputs = {
        'can_control': a('bool', 'return playerControllable;', 'Whether the turret can be controlled (Turret.java:377, `return playerControllable;`): the Turret playerControllable def as-is.'),
    }
    logic_controlled_inputs = {
        'frame': a('Dictionary', 'public boolean logicControlled(){', 'The turret frame (TurretBuild.logicControlled, Turret.java:445): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- logic_control_time arrives as an explicit param (the N2311/N2261 precedent), because the tick frame tracks no logic key yet.'),
        'logic_control_time': a('float', 'public float curRecoil, heat, logicControlTime = -1;', 'The logic-control timer (`logicControlTime`, Turret.java:446): the TurretBuild field (`public float curRecoil, heat, logicControlTime = -1;`, Turret.java:284, Java default -1), set to logicControlCooldown (`public final static float logicControlCooldown = 60 * 2;`, Turret.java:38) by control() (Turret.java:384/394) while logic holds the turret; positive while logic controls it.'),
    }
    logic_controlled_outputs = {
        'logic_controlled': a('bool', 'return logicControlTime > 0;', 'Whether logic controls the turret (Turret.java:446, `return logicControlTime > 0;`): true while the logic-control timer is positive.'),
    }
    return (warmup_inputs, warmup_outputs), (drawrot_inputs, drawrot_outputs), (can_control_inputs, can_control_outputs), (logic_controlled_inputs, logic_controlled_outputs)


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
    warmup, drawrot, can_control, logic_controlled = definitions()

    entries = [
        ('N2297', WARMUP_OWNER, 'source_turret_warmup_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.warmup()', warmup[0], warmup[1], True, 'Dictionary'),
        ('N2297', DRAWROT_OWNER, 'source_turret_drawrot_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.drawrot()', drawrot[0], drawrot[1], True, 'Dictionary'),
        ('N2297', CAN_CONTROL_OWNER, 'source_turret_can_control_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.canControl()', can_control[0], can_control[1], True, 'Dictionary'),
        ('N2297', LOGIC_CONTROLLED_OWNER, 'source_turret_logic_controlled_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.logicControlled()', logic_controlled[0], logic_controlled[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.warmup()/drawrot()/canControl()/logicControlled() state from Turret.java + RotComp.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.warmup()/drawrot()/canControl()/logicControlled() state from Turret.java + RotComp.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: warmup, drawrot, can_control,
    # logic_controlled.
    by_slice['N2297'] = [
        'source_turret_warmup_state_result.warmup',
        'source_turret_drawrot_state_result.drawrot',
        'source_turret_can_control_state_result.can_control',
        'source_turret_logic_controlled_state_result.logic_controlled',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2297', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.warmup(); TurretBuild.drawrot(); TurretBuild.canControl(); TurretBuild.logicControlled()', godot_owner=WARMUP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2297'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
