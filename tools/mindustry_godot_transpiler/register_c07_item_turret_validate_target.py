"""Register the ItemTurret validateTarget (N2251).

validateTarget() is the gate at the top of
TurretBuild.updateTile() (`if(!validateTarget()) target =
null;`, Turret.java:491) and the aim/shoot branch
(`if(validateTarget()){`, Turret.java:573 -- N2250 takes the
verdict in as target_valid because Units.invalidateTarget
waited for its own slice). validateTarget is `return
!Units.invalidateTarget(target, canHeal() ? Team.derelict :
team, x, y) || controlled() || logicControlled();`
(Turret.java:631-633), and it calls the NO-range overload of
Units.invalidateTarget (`return invalidateTarget(target, team,
x, y, Float.MAX_VALUE);`, Units.java:160-162), so the range
clause is dead in validateTarget and the pure function takes
NO range param. Units.invalidateTarget (Units.java:151-157)
invalidates when the target is null, when it is a Teamc on
the effective team, when it is a Healthc that is not valid,
or when it is a Unit that is not targetable by the effective
team. The effective team is Team.derelict when canHeal() and
the turret team otherwise; canHeal() is `targetHealing &&
hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals()`
(Turret.java:635-637). Team.derelict is id 0 (Team.java:33,
`derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),`).
targetHealing defaults false (Turret.java:95) and the duo def
(Blocks.java:3257-3324) never sets it, so the derelict branch
is dead for duo -- but the pure function still takes the
already-resolved effective-team bool as a param, so later
ItemTurret defs with targetHealing true work unchanged.
controlled() is `unit.isPlayer()` (Turret.java:441-443) and
logicControlled() is `logicControlTime > 0`
(Turret.java:445-447); either one rescues even a null target,
exactly as Java's `||` does. The port has NO controlled /
logic_controlled frame flags yet, so the driver and the proof
stamp them in from the frame with false defaults -- the live
player/logic wiring waits for its own slice.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceItemTurretBuildState.gd,
source_item_turret_validate_target_state(target_is_null,
target_same_team_effective, target_health_valid,
target_unit_targetable, controlled, logic_controlled),
returning `{"valid": ..., "target_cleared": ...}`, plus one
driver tick line in SourceTurretBuildState.gd at the head of
the duo branch (before the N2250 aim/shoot call) that clears
frame["target"] / frame["has_target"] when the verdict is
invalid and feeds the verdict into the aim/shoot target_valid
arg (which today passes `bool(frame.get("has_target",
false))`, NOT a hardcoded true -- the scope note said
hardcoded true, the disk says has_target). Two new result
symbols. (2) invalidate is the OR of the four live clauses:
target null, same effective team, !health_valid,
!unit_targetable; the range clause is dead because
validateTarget calls the no-range overload with
Float.MAX_VALUE. (3) valid = !invalidate || controlled ||
logic_controlled -- either control flag rescues even a null
target. (4) The effective-team resolution (derelict id 0
when canHeal, else the turret team) happens at the driver /
test, NOT in the pure function. (5) The frame target dict
carries only x/y/vx/vy/hit_size, so the team / health /
targetable / controlled bools are stamped in from the frame
with vacuous defaults (health_valid / unit_targetable true,
same team / controlled / logic_controlled false); no new key
is invented inside the target dict. findTarget
(Turret.java:651-662) is NOT this slice -- it needs the live
entity scan and waits for its own slice. SSOT expected after
GREEN: symbols +2, Done +1, contracts +1, schema +1,
11587/1700/1634/3059 -> 11589/1701/1635/3060.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_item_turret_aim_shoot import DEFERRED as N2250_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
UNITS = 'core/src/mindustry/entities/Units.java'
TEAM = 'core/src/mindustry/game/Team.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ItemTurretValidateTargetProof'
VALIDATE_TARGET_OWNER = 'SourceItemTurretBuildState.source_item_turret_validate_target_state'
TESTS = ['test_c07_item_turret_validate_target_registration', 'test_all_c07_item_turret_validate_target_input_evidence_is_exact', 'test_item_turret_validate_target_state', 'test_reference_graph_and_actual_c07_item_turret_validate_target']
# The 4 slice sources the N2251 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/Units.java',
    'core/src/mindustry/game/Team.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['if(!validateTarget()) target = null;', 'if(validateTarget()){', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();', 'public boolean targetHealing = false;', 'public boolean controlled(){', 'return unit.isPlayer();', 'public boolean logicControlled(){', 'return logicControlTime > 0;', 'public float curRecoil, heat, logicControlTime = -1;', 'return target == null ||', '(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||', '(target instanceof Teamc t && t.team() == team) ||', '(target instanceof Healthc h && !h.isValid()) ||', '(target instanceof Unit u && !u.targetable(team));', 'return invalidateTarget(target, team, x, y, Float.MAX_VALUE);', 'derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),']

# DEFERRED is carried from the N2250 register script via import --
# never retyped. validateTarget is done by this slice, so the
# N2250 lumped "findTarget/validateTarget" entry is superseded
# for the validateTarget half: findTarget still waits, and the
# canHeal live wiring + the Windows proof debt are appended.
DEFERRED = list(N2250_DEFERRED) + [
    'ItemTurret validateTarget Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2250: the N2251 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ItemTurret findTarget (bestEnemy/bestTarget live scan, Turret.java:651-662) -- still waits; validateTarget (N2251) only judges an already-acquired target, it does not acquire one.',
    'ItemTurret canHeal live wiring (targetHealing + peekAmmo collidesTeam/heals, Turret.java:635-637) -- the driver passes target_same_team_effective in from the frame; resolving the effective team (derelict id 0 when canHeal) from live ammo state waits for its own slice.',
    'ItemTurret controlled/logicControlled live wiring (unit.isPlayer() / logicControlTime > 0, Turret.java:441-447) -- the driver passes both flags in from the frame with false defaults; the live player/logic stamps wait for their own slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    validate_target_inputs = {
        'target_is_null': a('bool', 'return target == null ||', 'Whether the target is null (Units.java:152 -- the first invalidateTarget clause; a null target is invalid unless controlled or logic-controlled).', source=UNITS),
        'target_same_team_effective': a('bool', '(target instanceof Teamc t && t.team() == team) ||', 'Whether the target is a Teamc on the effective team (Units.java:154 -- the effective team is Team.derelict, id 0, when canHeal(), else the turret team, Turret.java:632; the driver resolves it and passes the bool in).', source=UNITS),
        'target_health_valid': a('bool', '(target instanceof Healthc h && !h.isValid()) ||', 'Whether the target is a valid Healthc (Units.java:155 -- true when the target is not a Healthc at all, so the clause is vacuous; the driver passes it in from the frame).', source=UNITS),
        'target_unit_targetable': a('bool', '(target instanceof Unit u && !u.targetable(team));', 'Whether the target Unit is targetable by the effective team (Units.java:156 -- true when the target is not a Unit at all, so the clause is vacuous; the driver passes it in from the frame).', source=UNITS),
        'controlled': a('bool', 'return unit.isPlayer();', 'Whether the build is player-controlled (Turret.java:441-443, `controlled(){ return unit.isPlayer(); }` -- rescues the verdict even for a null target; the driver passes it in from the frame with a false default, the live player stamp waits for its own slice).'),
        'logic_controlled': a('bool', 'return logicControlTime > 0;', 'Whether the build is logic-controlled (Turret.java:445-447, `logicControlled(){ return logicControlTime > 0; }` -- rescues the verdict even for a null target; the driver passes it in from the frame with a false default, the live logic stamp waits for its own slice).'),
    }
    validate_target_outputs = {
        'valid': a('bool', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'The validateTarget verdict (Turret.java:631-633 -- !invalidate || controlled || logic_controlled; the driver clears the frame target when false and feeds it into the aim/shoot target_valid arg).'),
        'target_cleared': a('bool', 'if(!validateTarget()) target = null;', 'Whether updateTile clears the target this tick (Turret.java:491 -- exactly !valid; the driver sets frame["target"] = null and frame["has_target"] = false when true).'),
    }
    return validate_target_inputs, validate_target_outputs


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
    validate_target_inputs, validate_target_outputs = definitions()

    entries = [
        ('N2251', VALIDATE_TARGET_OWNER, 'source_item_turret_validate_target_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.validateTarget()', validate_target_inputs, validate_target_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ItemTurret validateTarget from Turret.java / Units.java / Team.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ItemTurret validateTarget from Turret.java / Units.java / Team.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: valid, target_cleared.
    by_slice['N2251'] = [
        'source_item_turret_validate_target_state_result.valid',
        'source_item_turret_validate_target_state_result.target_cleared',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2251', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.validateTarget()', godot_owner=VALIDATE_TARGET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2251'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
