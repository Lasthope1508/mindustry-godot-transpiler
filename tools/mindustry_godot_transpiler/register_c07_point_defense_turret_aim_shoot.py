"""Register the PointDefenseTurret aim + reload + shoot (N2240).

N2151 wired the power.status live read but deferred the
updateTile advance ("No updateTile advance:
PointDefenseBuild.updateTile()
(PointDefenseTurret.java:62-103, retarget / rotation /
reloadCounter / beam effects) waits for its own slice;
the proof carries no progress keys"). N2239 did the
first half of that advance (the retarget: every
retargetTime (5s) the build re-acquires the nearest
enemy hittable bullet in the range rect, plus the
pooled invalidation). This slice is the second half --
the "look at target" aim / rotation / reloadCounter /
shoot (PointDefenseTurret.java:76-101): when the
target is non-null, within range, on another team,
with a non-null hittable type, the build turns toward
it (`float dest = angleTo(target);` /
`rotation = Angles.moveToward(rotation, dest,
rotateSpeed * edelta());`,
PointDefenseTurret.java:77-78), charges the reload
(`reloadCounter += edelta();`,
PointDefenseTurret.java:79), and shoots when aimed
and reloaded (`if(Angles.within(rotation, dest,
shootCone) && reloadCounter >= reload){`,
PointDefenseTurret.java:82), dealing `bulletDamage *
state.rules.blockDamage(team)` (subtracting from the
target's damage, or removing the target when lethal,
PointDefenseTurret.java:83-88) and resetting
`reloadCounter = 0` (PointDefenseTurret.java:97).
The beam / shoot / hit effects and the shoot sound
(PointDefenseTurret.java:90-95) are side effects:
the pure function does NOT spawn them, it returns a
shoot_event dict (beam origin + rotation + target
position) for the driver / proof to verify.

GREEN decisions (pinned by this slice): (1) One pure
function on SourcePointDefenseTurretBuildState.gd,
source_point_defense_turret_aim_shoot_state(frame,
target, team_id, x, y, range, rotate_speed, reload,
shoot_cone, bullet_damage, block_damage_multiplier,
edelta), returning `{"rotation": ...,
"reload_counter": ..., "dest": ..., "shot": ...,
"damage_dealt": ..., "target_damage_after": ...,
"target_removed": ..., "shoot_event": ...}`, plus
one driver tick line that stamps rotation /
reload_counter / shot / shoot_event live and writes
the target damage back (the N2239 precedent). Eight
new result symbols. (2) The gate requires all five
conditions (PointDefenseTurret.java:76); a failing
gate leaves rotation and reloadCounter untouched,
dest null, and shoots nothing. `target.within` is
Position.within, dst2 < range*range, STRICT `<`
(Position.java:40-46, `return Mathf.dst2(getX(),
getY(), x, y) < dst*dst;`). (3) `angleTo` is
Position.angleTo -> Angles.angle, i.e.
`Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg`
normalized to [0, 360) -- atan2(dx, dy), 0 degrees
is +Y, the opposite of GDScript's `atan2(y, x)`, so
GREEN writes `rad_to_deg(atan2(tx - x, ty - y))`,
never Vector2.angle_to. (4) `Angles.moveToward`
returns `to` outright when `|angleDist| < speed`
and otherwise steps +-speed along the shorter arc
(Angles.java:38-49); `rotation` is the float turret
rotation, default 90 (BaseTurret.java:114, `public
float rotation = 90;` -- NOT BuildingComp.rotation,
the int block rotation). (5) Java does NOT clamp
reloadCounter here (the clamp lives on the plain
TurretBuild, Turret.java:723, which
PointDefenseBuild does not extend), so GREEN invents
no clamp; `edelta()` is `efficiency * delta()`
(BuildingComp.java:1927-1929) passed in
precomputed. (6) The shoot gate uses
`Angles.within(a, b, margin)` = `angleDist(a, b) <=
margin` (Angles.java:19-21), i.e. `<=` shootCone,
and `reloadCounter >= reload`. (7) The damage
comparison is STRICT `>` (`if(target.damage() >
realDamage){`, PointDefenseTurret.java:84) so a
target whose damage equals realDamage is removed,
not left at 0; `blockDamage(team)` =
`blockDamageMultiplier *
teams.get(team).blockDamageMultiplier`
(Rules.java:299-300) is passed in precomputed.
(8) The reset is `reloadCounter = 0;`
(PointDefenseTurret.java:97) -- reset-to-0, NOT
`%= reload` (that is the plain Turret,
Turret.java:738). (9) The shoot_event beam origin
is Tmp.v1.trns(rotation, shootLength) with the
per-def shootLength 5f (Blocks.java:3843; the class
default is 3f, PointDefenseTurret.java:34) -- the
sound pitch is random (0.9-1.1) so it is NOT in the
event. (10) The driver passes the per-def segment
values (range 180f, shootLength 5f, bulletDamage
30f, reload 8f, Blocks.java:3838-3846; rotateSpeed
20f, shootCone 5f class defaults). The lumped
deferred entry "PointDefenseTurret updateTile
advance / shouldConsume gate; TractorBeamTurret
..." is NOT dropped here: the coolant update, the
shouldConsume gate, draw / write-read / setStats /
icons, and the real effect/sound spawn still wait,
and TractorBeam is untouched. Shard note:
PointDefenseTurret.java lives under
/world/blocks/defense/turrets/ and matches the
defense shard selection (the N2239 precedent), so
the GREEN register run records the defense shard
count change. SSOT expected after GREEN: symbols
+8, Done +1, contracts +1, schema +2, 11544/1689/
1620/3031 -> 11552/1690/1621/3033.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_point_defense_turret_target_acquire import DEFERRED as N2239_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RULES = 'core/src/mindustry/game/Rules.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BULLET_COMP = 'core/src/mindustry/entities/comp/BulletComp.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
ANGLES = 'arc-core/src/arc/math/Angles.java'
POSITION = 'arc-core/src/arc/math/geom/Position.java'
PROOF = '/root/C07PointDefenseTurretAimShootProof'
AIM_SHOOT_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state'
TESTS = ['test_c07_point_defense_turret_aim_shoot_registration', 'test_all_c07_point_defense_turret_aim_shoot_input_evidence_is_exact', 'test_point_defense_turret_aim_shoot_state', 'test_reference_graph_and_actual_c07_point_defense_turret_aim_shoot']
# The 10 slice sources the N2240 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/game/Rules.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/comp/BulletComp.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'arc-core/src/arc/math/Angles.java',
    'arc-core/src/arc/math/geom/Position.java',
]
EXACT_EXPRS = ['if(target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable){', 'float dest = angleTo(target);', 'rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());', 'reloadCounter += edelta();', 'if(Angles.within(rotation, dest, shootCone) && reloadCounter >= reload){', 'float realDamage = bulletDamage * state.rules.blockDamage(team);', 'if(target.damage() > realDamage){', 'target.damage(target.damage() - realDamage);', 'target.remove();', 'reloadCounter = 0;', 'Tmp.v1.trns(rotation, shootLength);', 'beamEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation, color, new Vec2().set(target));', 'shootEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation, color);', 'hitEffect.at(target.x, target.y, color);', 'shootSound.at(x + Tmp.v1.x, y + Tmp.v1.y, Mathf.random(0.9f, 1.1f));', 'return angleDist(a, b) <= margin;', 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', 'return efficiency * delta();', 'return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;', 'public float rotation = 90;', 'public float reloadCounter;', 'public float shootCone = 5f;', 'public float bulletDamage = 10f;', 'public float shootLength = 3f;', 'rotateSpeed = 20f;', 'reload = 30f;', 'range = 180f;', 'bulletDamage = 30f;', 'reload = 8f;', 'shootLength = 5f;']

# DEFERRED is carried from the N2239 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the coolant update + shouldConsume gate + draw / write-read /
# setStats / icons + the real effect/sound spawn, and the
# TractorBeam half is untouched. Only the N2240 Windows-proof
# debt entry is appended.
DEFERRED = list(N2239_DEFERRED) + [
    'PointDefenseTurret aim + reload + shoot Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2239: the N2240 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    gate = 'if(target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable){'
    aim_shoot_inputs = {
        'frame': a('Dictionary', 'public @Nullable Bullet target;', 'The turret frame (PointDefenseTurret.java:60, `public @Nullable Bullet target;` -- the frame carries the current target dict plus rotation (default 90.0, BaseTurret.java:114) and reload_counter (default 0.0, ReloadTurret.java:26); the driver stamps both back every tick).'),
        'target': a('Dictionary', gate, 'The acquired target dict (PointDefenseTurret.java:76 -- the N2239 acquire hands it over; it carries x/y/team/has_type/hittable/damage, the five gate conditions read from it).'),
        'team_id': a('int', gate, 'The turret team id (PointDefenseTurret.java:76, `target.team != team` -- the team whose enemy bullets the gate admits; the driver reads it from the frame).'),
        'x': a('float', 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', 'The turret x (Position.java:46 -- the Building x Java passes to the within test; the driver reads sprite.position.x).', source=POSITION),
        'y': a('float', 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', 'The turret y (Position.java:46 -- the Building y Java passes to the within test; the driver reads sprite.position.y).', source=POSITION),
        'range': a('float', 'range = 180f;', 'The per-def range (segment 180f, Blocks.java:3838, `range = 180f;`, the only PointDefenseTurret def): the within radius Java tests with dst2 < range*range (PointDefenseTurret.java:76, Position.java:46).', source=BLOCKS),
        'rotate_speed': a('float', 'rotateSpeed = 20f;', 'The rotate speed in degrees per second (PointDefenseTurret.java:38, `rotateSpeed = 20f;` -- the ctor override; Angles.moveToward steps rotation by rotateSpeed * edelta).'),
        'reload': a('float', 'reload = 8f;', 'The per-def reload in seconds (segment 8f, Blocks.java:3845, `reload = 8f;` -- the class ctor default is 30f, PointDefenseTurret.java:39; the driver passes the per-def 8f and the shoot gate fires at reloadCounter >= reload).', source=BLOCKS),
        'shoot_cone': a('float', 'public float shootCone = 5f;', 'The shoot cone in degrees (PointDefenseTurret.java:31, `public float shootCone = 5f;` -- Angles.within(rotation, dest, shootCone) is angleDist <= shootCone, Angles.java:19-21).'),
        'bullet_damage': a('float', 'bulletDamage = 30f;', 'The per-def bullet damage (segment 30f, Blocks.java:3844, `bulletDamage = 30f;` -- the class default is 10f, PointDefenseTurret.java:32; the driver passes the per-def 30f and realDamage = bulletDamage * blockDamageMultiplier).', source=BLOCKS),
        'block_damage_multiplier': a('float', 'return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;', 'The precomputed blockDamage(team) multiplier (Rules.java:299-300, `return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;` -- the driver reads it from the rules state; the pure function never reads rules directly).', source=RULES),
        'edelta': a('float', 'return efficiency * delta();', 'The effective delta in seconds (BuildingComp.java:1927-1929, `return efficiency * delta();` -- the driver passes frame efficiency * seconds precomputed).', source=BUILDING_COMP),
    }
    aim_shoot_outputs = {
        'rotation': a('float', 'rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());', 'The rotation after moveToward toward dest (PointDefenseTurret.java:78 -- unchanged when the gate fails; the float turret rotation, default 90, BaseTurret.java:114).'),
        'reload_counter': a('float', 'reloadCounter += edelta();', 'The reload counter after += edelta, 0.0 on a shot (PointDefenseTurret.java:79 charges it, :97 resets it to 0 -- reset-to-0, NOT %= reload; Java never clamps it here; unchanged when the gate fails).'),
        'dest': a('float', 'float dest = angleTo(target);', 'The angle to the target (PointDefenseTurret.java:77 -- angleTo is Position.angleTo -> Angles.angle, atan2(dx, dy), 0 degrees is +Y; null when the gate fails, Java only computes it inside the if).'),
        'shot': a('bool', 'if(Angles.within(rotation, dest, shootCone) && reloadCounter >= reload){', 'Whether the shoot gate fired (PointDefenseTurret.java:82 -- Angles.within is angleDist <= shootCone and reloadCounter >= reload).'),
        'damage_dealt': a('float', 'float realDamage = bulletDamage * state.rules.blockDamage(team);', 'The real damage dealt on a shot (PointDefenseTurret.java:83 -- bulletDamage * blockDamageMultiplier; 0.0 when no shot).'),
        'target_damage_after': a('float', 'target.damage(target.damage() - realDamage);', 'The target damage remaining after the shot (PointDefenseTurret.java:85 -- target damage minus realDamage; 0.0 when the shot is lethal; unchanged when no shot).'),
        'target_removed': a('bool', 'target.remove();', 'Whether the shot removed the target (PointDefenseTurret.java:87 -- the STRICT > comparison at :84 means a target whose damage equals realDamage is removed, not left at 0).'),
        'shoot_event': a('Dictionary', 'beamEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation, color, new Vec2().set(target));', 'The shoot event dict on a shot (PointDefenseTurret.java:91 -- the beam origin Tmp.v1.trns(rotation, shootLength) with the per-def shootLength 5f, plus rotation and the target position; null when no shot; the pure function spawns no effects or sound).'),
    }
    return aim_shoot_inputs, aim_shoot_outputs


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
    aim_shoot_inputs, aim_shoot_outputs = definitions()

    entries = [
        ('N2240', AIM_SHOOT_OWNER, 'source_point_defense_turret_aim_shoot_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.updateTile()', aim_shoot_inputs, aim_shoot_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret aim + reload + shoot from PointDefenseTurret.java / ReloadTurret.java / BaseTurret.java / BuildingComp.java / Rules.java / Blocks.java / Angles.java / Position.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret aim + reload + shoot from PointDefenseTurret.java / ReloadTurret.java / BaseTurret.java / BuildingComp.java / Rules.java / Blocks.java / Angles.java / Position.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, reload_counter,
    # dest, shot, damage_dealt, target_damage_after,
    # target_removed, shoot_event.
    by_slice['N2240'] = [
        'source_point_defense_turret_aim_shoot_state_result.rotation',
        'source_point_defense_turret_aim_shoot_state_result.reload_counter',
        'source_point_defense_turret_aim_shoot_state_result.dest',
        'source_point_defense_turret_aim_shoot_state_result.shot',
        'source_point_defense_turret_aim_shoot_state_result.damage_dealt',
        'source_point_defense_turret_aim_shoot_state_result.target_damage_after',
        'source_point_defense_turret_aim_shoot_state_result.target_removed',
        'source_point_defense_turret_aim_shoot_state_result.shoot_event',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2240', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.updateTile()', godot_owner=AIM_SHOOT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2240'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
