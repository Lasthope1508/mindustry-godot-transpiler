"""Register the ItemTurret aim + reload + shoot (N2250).

ItemTurret does NOT override updateTile (ItemTurret.java:23,
`public class ItemTurret extends Turret{` -- it only overrides
ammo); the whole aim / reload / shoot lives in
Turret.TurretBuild.updateTile() (Turret.java:490-615), so this
slice is the duo half of that updateTile, following the N2240
PointDefense precedent: when the target is valid
(`if(validateTarget()){`, Turret.java:573 -- validateTarget is
`return !Units.invalidateTarget(target, canHeal() ?
Team.derelict : team, x, y) || controlled() ||
logicControlled();`, Turret.java:631-632, passed in as
target_valid because Units.invalidateTarget waits for its own
slice), the build aims at the predicted position
(`targetPosition(target);`, Turret.java:581 -- Predict.intercept
when `predictTarget && bullet.speed >= 0.01f`,
Turret.java:464-465), turns toward it (`float targetRot =
angleTo(targetPos);` / `turnToTarget(targetRot);`,
Turret.java:595-598 -- `rotation = Angles.moveToward(rotation,
targetRot, rotateSpeed * delta() * potentialEfficiency);`,
Turret.java:665-667), and shoots when aimed and in range
(`if(!alwaysShooting && Angles.angleDist(rotation, targetRot) <
shootCone && canShoot){`, Turret.java:599 -- STRICT `<`
shootCone, unlike the PointDefense `Angles.within` `<=`;
`canShoot = within(target, range() + (target instanceof Sized hb
? hb.hitSize()/1.9f : 0f));`, Turret.java:585). The reload
charges every tick (`reloadCounter += delta() *
ammoReloadMultiplier() * baseReloadSpeed();` /
`reloadCounter = Math.min(reloadCounter, reload);`,
Turret.java:719-724 -- the cap lives here, on the plain
TurretBuild, unlike PointDefense which never clamps), and
updateShooting fires only when reloaded, not charging, and
warmed up (`if(reloadCounter >= reload && !charging() &&
shootWarmup >= minWarmup){`, Turret.java:733) then resets with
modulo (`reloadCounter %= reload;`, Turret.java:738 -- NOT
`= 0`, unlike PointDefenseTurret.java:97). The shot consumes
ammo once (`if(consumeAmmoOnce){ useAmmo(); }`,
Turret.java:771-773 -- `entry.amount -= ammoPerShot;` /
`if(entry.amount <= 0) ammo.pop();` / `totalAmmo -=
ammoPerShot;` / `totalAmmo = Math.max(totalAmmo, 0);`,
Turret.java:680-690; cheating returns peekAmmo() without
consuming, Turret.java:681) and advances the alternate barrel
(`}, () -> barrelCounter++);`, Turret.java:770 --
ShootAlternate (Blocks.java:3300, `shoot = new
ShootAlternate(3.5f);`, `public int barrels = 2;`,
ShootAlternate.java:8). The bullet() spawn detail, the
warmup lerp advance, findTarget/validateTarget, and
queuedBullets when shotDelay > 0 are side effects / later
slices: the pure function spawns no bullet, it returns a
shoot_event dict (bullet origin + rotation + barrel) for the
driver / proof to verify.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceItemTurretBuildState.gd,
source_item_turret_aim_shoot_state(frame, target, target_valid,
team_id, x, y, delta, potential_efficiency, shoot_warmup,
charging, ammo_entries, total_ammo, barrel_counter, range,
rotate_speed, reload, shoot_cone, shoot_x, shoot_y, inaccuracy,
ammo_per_shot, consume_ammo_once, reload_multiplier,
range_change, bullet_speed, predict_target, min_warmup,
always_shooting, cheating, base_reload_speed), returning
`{"rotation": ..., "reload_counter": ..., "dest": ..., "shot":
..., "target_pos": ..., "total_ammo_after": ...,
"ammo_entries_after": ..., "shoot_event": ...,
"barrel_counter_after": ..., "was_shooting": ...}`, plus one
driver tick line in SourceTurretBuildState.gd guarded on block
`duo` that stamps rotation / reload_counter live. Ten new
result symbols. (2) updateReload runs every tick
(reloadWhileCharging defaults true, Turret.java:82):
reloadCounter += delta * ammoReloadMultiplier *
baseReloadSpeed, then capped with min(reloadCounter, reload);
ammoReloadMultiplier is the peeked ammo's reloadMultiplier
when there is ammo, else 1f (Turret.java:727-729), and
baseReloadSpeed is efficiency (ReloadTurret.java:45-47) passed
in precomputed. (3) The aim/shoot half runs only with a valid
target; a null target, a non-dict target, or target_valid
false leaves rotation at its charged value and shoots nothing.
(4) targetPosition uses Predict.intercept when predictTarget
and bullet.speed >= 0.01 -- the deterministic quadratic
(Predict.java:33-36/:87-104) with the target velocity
per-second and the bullet speed as inputs; otherwise the
target position is used as-is. (5) `angleTo` is
Position.angleTo -> Angles.angle, i.e. `Mathf.atan2(x2 - x,
y2 - y) * Mathf.radDeg` normalized to [0, 360) -- atan2(dx,
dy), 0 degrees is +Y, the opposite of GDScript's `atan2(y,
x)`, so GREEN writes `rad_to_deg(atan2(tx - x, ty - y))`,
never Vector2.angle_to. (6) `Angles.moveToward` returns `to`
outright when `|angleDist| < speed` and otherwise steps
+-speed along the shorter arc (Angles.java:38-49);
`rotation` is the float turret rotation, default 90
(BaseTurret.java:114, `public float rotation = 90;` -- NOT
BuildingComp.rotation, the int block rotation). (7) The shoot
gate uses STRICT `<` shootCone (Turret.java:599), NOT
Angles.within `<=`, and requires canShoot (Position.within,
dst2 < range*range, STRICT `<`, Position.java:40-46) with
range() already including the peeked ammo's rangeChange
(Turret.java:342-346). (8) updateShooting requires
reloadCounter >= reload AND !charging() AND shootWarmup >=
minWarmup (Turret.java:733); the reset is `reloadCounter %=
reload` (Turret.java:738). (9) useAmmo is computed inline
with the exact Turret.java:680-690 formula (cheating -> no
subtraction; consumeAmmoOnce=true -> subtract once at
shoot()), with a comment pointing at the registered
source_turret_use_ammo_state in SourceTurretBuildState.gd;
the stacks are the {"item", "amount"} dicts of
SourceTurretAmmoState.selected_turret_ammo_entries /
use_ammo_stack_state, peeked from the last stack. (10) The
driver passes the per-def duo values (range 160, rotateSpeed
10, reload 20, shootCone 15, shootY 3, inaccuracy 2,
Blocks.java:3257-3324; shoot = ShootAlternate(3.5f)) and the
peeked ammo's reloadMultiplier / rangeChange / bullet_speed
(copper 1.0/0/2.5, graphite 0.8/16/3.5, silicon 1.5/0/3).
The lumped deferred entry "ItemTurret updateTile advance"
is NOT dropped here: the bullet() spawn detail, the warmup
lerp advance, findTarget/validateTarget, queuedBullets, and
the other ItemTurret defs still wait. Shard note: Turret.java
lives under /world/blocks/defense/turrets/ and matches the
defense shard selection (the N2240 precedent), so the GREEN
register run records the defense shard count change. SSOT
expected after GREEN: symbols +10, Done +1, contracts +1,
schema +2, 11577/1699/1633/3057 -> 11587/1700/1634/3059.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_point_defense_turret_persistence_integration import DEFERRED as N2249_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PREDICT = 'core/src/mindustry/entities/Predict.java'
SHOOT_ALTERNATE = 'core/src/mindustry/entities/pattern/ShootAlternate.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
ANGLES = 'arc-core/src/arc/math/Angles.java'
POSITION = 'arc-core/src/arc/math/geom/Position.java'
PROOF = '/root/C07ItemTurretAimShootProof'
AIM_SHOOT_OWNER = 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state'
TESTS = ['test_c07_item_turret_aim_shoot_registration', 'test_all_c07_item_turret_aim_shoot_input_evidence_is_exact', 'test_item_turret_aim_shoot_state', 'test_reference_graph_and_actual_c07_item_turret_aim_shoot']
# The 12 slice sources the N2250 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/entities/Predict.java',
    'core/src/mindustry/entities/pattern/ShootAlternate.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
    'arc-core/src/arc/math/Angles.java',
    'arc-core/src/arc/math/geom/Position.java',
]
EXACT_EXPRS = ['if(!validateTarget()) target = null;', 'wasShooting = false;', 'reloadCounter += delta() * ammoReloadMultiplier() * baseReloadSpeed();', 'reloadCounter = Math.min(reloadCounter, reload);', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', 'reloadCounter %= reload;', 'targetPosition(target);', 'if(Float.isNaN(rotation)) rotation = 0;', 'canShoot = within(target, range() + (target instanceof Sized hb ? hb.hitSize()/1.9f : 0f));', 'float targetRot = angleTo(targetPos);', 'if(shouldTurn()){', 'turnToTarget(targetRot);', 'rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);', 'if(!alwaysShooting && Angles.angleDist(rotation, targetRot) < shootCone && canShoot){', 'wasShooting = true;', 'if(predictTarget && bullet.speed >= 0.01f){', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'if(cheating()) return peekAmmo();', 'entry.amount -= ammoPerShot;', 'if(entry.amount <= 0) ammo.pop();', 'totalAmmo -= ammoPerShot;', 'totalAmmo = Math.max(totalAmmo, 0);', 'public int ammoPerShot = 1;', 'public boolean consumeAmmoOnce = true;', 'public float inaccuracy = 0f;', 'public float shootCone = 8f;', 'public float minWarmup = 0f;', 'public boolean alwaysShooting = false;', 'public boolean predictTarget = true;', 'public boolean moveWhileCharging = true;', 'public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),', 'if(consumeAmmoOnce){', 'useAmmo();', '}, () -> barrelCounter++);', 'return range + peekAmmo().rangeChange;', 'public float rotation = 90;', 'public float reloadCounter;', 'return efficiency;', 'return shootWarmup;', 'return Time.delta * timeScale;', 'return moveWhileCharging || !charging();', 'range = 160;', 'rotateSpeed = 10f;', 'reload = 20f;', 'shootCone = 15f;', 'shootY = 3f;', 'inaccuracy = 2f;', 'shoot = new ShootAlternate(3.5f);', 'reloadMultiplier = 0.8f;', 'rangeChange = 16f;', 'reloadMultiplier = 1.5f;', 'ammoMultiplier = 2;', 'public class ItemTurret extends Turret{', 'public static Vec2 intercept(float srcx, float srcy, float dstx, float dsty, float dstvx, float dstvy, float v){', 'float a = dstvx * dstvx + dstvy * dstvy - v * v;', 'float b = 2 * (dstvx * tx + dstvy * ty);', 'float c = tx * tx + ty * ty;', 'float disc = b * b - 4 * a * c;', 'private static Vec2 quad(float a, float b, float c){', 'float t = Math.min(t0, t1);', 'return angleDist(a, b) <= margin;', 'if(Math.abs(angleDist(angle, to)) < speed) return to;', 'float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', 'return Angles.angle(getX(), getY(), other.getX(), other.getY());', 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', 'public float reloadMultiplier = 1f;', 'public float rangeChange = 0f;', 'public float speed = 1f;', 'public int barrels = 2;', 'float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;', 'public int shots = 1;', 'public float firstShotDelay = 0;']

# DEFERRED is carried from the N2249 register script via import --
# never retyped. Nothing is dropped here: the PointDefenseTurret
# live coolant wiring + save/load stream caller still wait, and
# the ItemTurret bullet() spawn detail, warmup lerp advance,
# findTarget/validateTarget, queuedBullets, and the other
# ItemTurret defs beyond duo wait for their own slices. Only the
# N2250 Windows-proof debt entry is appended.
DEFERRED = list(N2249_DEFERRED) + [
    'ItemTurret aim + reload + shoot Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2249: the N2250 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ItemTurret bullet() spawn detail (inaccuracy random, lifeScl, effects/sound, recoil/heat/totalShots, Turret.java:776-812) -- the pure function returns a shoot_event for the driver/proof; the real bullet spawn waits for its own slice.',
    'ItemTurret findTarget/validateTarget (Units.invalidateTarget, Turret.java:631-632) -- the pure function takes target_valid as a parameter; live target acquisition waits for its own slice.',
    'ItemTurret warmup lerp advance (Turret.java:502-515) -- shootWarmup is an input; the warmup fold waits for its own slice.',
    'ItemTurret queuedBullets when shotDelay > 0 (Turret.java:756-770) -- duo ShootAlternate has shotDelay 0, so the queue is empty here; multi-shot delay waits for its own slice.',
    'Other ItemTurret defs beyond duo (Blocks.java:3257) -- only duo is ticked by the driver guard; other defs wait for their own slices.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    aim_shoot_inputs = {
        'frame': a('Dictionary', 'public float rotation = 90;', 'The turret frame (BaseTurret.java:114, `public float rotation = 90;` -- the frame carries the float turret rotation, default 90.0, and reload_counter, default 0.0, ReloadTurret.java:26; the driver stamps both back every tick).', source=BASE_TURRET),
        'target': a('Dictionary', 'if(!validateTarget()) target = null;', 'The acquired target dict (Turret.java:491 -- the target arrives already acquired; it carries x/y/vx/vy/hit_size, the position / velocity / size the aim math reads).'),
        'target_valid': a('bool', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'Whether the target is still valid (Turret.java:631-632, validateTarget -- Units.invalidateTarget waits for its own slice, so the driver passes the verdict in; a false verdict leaves rotation at its charged value and shoots nothing).'),
        'team_id': a('int', 'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', 'The turret team id (Turret.java:632, `canHeal() ? Team.derelict : team` -- the team the validation is judged against; the driver reads it from the frame).'),
        'x': a('float', 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', 'The turret x (Position.java:46 -- the Building x Java passes to the within test; the driver reads sprite.position.x).', source=POSITION),
        'y': a('float', 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', 'The turret y (Position.java:46 -- the Building y Java passes to the within test; the driver reads sprite.position.y).', source=POSITION),
        'delta': a('float', 'return Time.delta * timeScale;', 'The scaled delta in seconds (BuildingComp.java:1922-1924, `return Time.delta * timeScale;` -- the driver passes Time.delta precomputed).', source=BUILDING_COMP),
        'potential_efficiency': a('float', 'rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);', 'The potential efficiency (Turret.java:666 -- turnToTarget steps rotation by rotateSpeed * delta() * potentialEfficiency; the driver reads it from the frame).'),
        'shoot_warmup': a('float', 'return shootWarmup;', 'The shoot warmup 0..1 (Turret.java:355-357, warmup() -- updateShooting requires shootWarmup >= minWarmup, Turret.java:733; the warmup lerp advance itself waits for its own slice).'),
        'charging': a('bool', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'Whether the turret is charging (Turret.java:715-717 -- queuedBullets > 0 and firstShotDelay > 0; duo firstShotDelay is 0, so charging is false here, but the gate is still checked).'),
        'ammo_entries': a('Array', 'AmmoEntry entry = ammo.peek();', 'The ammo stacks (Turret.java:683 -- {"item", "amount"} dicts in the SourceTurretAmmoState.selected_turret_ammo_entries / use_ammo_stack_state format, peeked from the last stack).'),
        'total_ammo': a('int', 'totalAmmo -= ammoPerShot;', 'The total ammo count (Turret.java:687 -- decremented by ammoPerShot on a shot, clamped at 0).'),
        'barrel_counter': a('int', '}, () -> barrelCounter++);', 'The ShootAlternate barrel counter (Turret.java:770 -- incremented once per shoot() call; duo has barrels 2, ShootAlternate.java:8).'),
        'range': a('float', 'range = 160;', 'The per-def range (duo 160, Blocks.java:3316, `range = 160;` -- the within radius before the ammo rangeChange and the target hitSize/1.9).', source=BLOCKS),
        'rotate_speed': a('float', 'rotateSpeed = 10f;', 'The rotate speed in degrees per second (duo 10f, Blocks.java:3321, `rotateSpeed = 10f;` -- turnToTarget steps rotation by rotateSpeed * delta() * potentialEfficiency).', source=BLOCKS),
        'reload': a('float', 'reload = 20f;', 'The per-def reload in seconds (duo 20f, Blocks.java:3314, `reload = 20f;` -- the shoot gate fires at reloadCounter >= reload and the reset is reloadCounter %= reload).', source=BLOCKS),
        'shoot_cone': a('float', 'shootCone = 15f;', 'The shoot cone in degrees (duo 15f, Blocks.java:3317, `shootCone = 15f;` -- the shoot gate is STRICT angleDist < shootCone, Turret.java:599; the class default is 8f, Turret.java:64).', source=BLOCKS),
        'shoot_x': a('float', 'public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;', 'The shoot X offset (Turret.java:66, class default 0f -- duo does not override it; the bullet origin is x + trnsx(rotation - 90, shootX, shootY)).'),
        'shoot_y': a('float', 'shootY = 3f;', 'The shoot Y offset (duo 3f, Blocks.java:3313, `shootY = 3f;` -- the bullet origin is y + trnsy(rotation - 90, shootX, shootY)).', source=BLOCKS),
        'inaccuracy': a('float', 'inaccuracy = 2f;', 'The shot inaccuracy in degrees (duo 2f, Blocks.java:3320, `inaccuracy = 2f;` -- the class default is 0f, Turret.java:58; the random spread itself is bullet() spawn detail and waits for its own slice).', source=BLOCKS),
        'ammo_per_shot': a('int', 'public int ammoPerShot = 1;', 'The ammo units per shot (Turret.java:49, `public int ammoPerShot = 1;` -- useAmmo subtracts exactly this once per shot when consumeAmmoOnce is true).'),
        'consume_ammo_once': a('bool', 'public boolean consumeAmmoOnce = true;', 'Whether ammo is consumed once per shot (Turret.java:51 -- duo does not override it; false would consume per bullet in bullet(), which waits for its own slice).'),
        'reload_multiplier': a('float', 'reloadMultiplier = 0.8f;', 'The peeked ammo reload multiplier (graphite 0.8f, Blocks.java:3277 -- copper uses the BulletType default 1f, BulletType.java:97, silicon 1.5f; the driver passes the peeked ammo type value).', source=BLOCKS),
        'range_change': a('float', 'rangeChange = 16f;', 'The peeked ammo range change (graphite 16f, Blocks.java:3278 -- copper/silicon use the BulletType default 0f, BulletType.java:157; range() = range + rangeChange).', source=BLOCKS),
        'bullet_speed': a('float', 'public float speed = 1f;', 'The peeked ammo bullet speed (BulletType.java:37 -- duo copper 2.5, graphite 3.5, silicon 3, Blocks.java:3259-3295; Predict.intercept needs it, and the predict gate needs speed >= 0.01).', source=BULLET_TYPE),
        'predict_target': a('bool', 'public boolean predictTarget = true;', 'Whether to lead the target (Turret.java:105, class default true -- duo does not override it; targetPosition uses Predict.intercept only when this and bullet.speed >= 0.01f).'),
        'min_warmup': a('float', 'public float minWarmup = 0f;', 'The minimum warmup to fire (Turret.java:76, class default 0f -- duo does not override it; updateShooting requires shootWarmup >= minWarmup).'),
        'always_shooting': a('bool', 'public boolean alwaysShooting = false;', 'Whether the turret shoots without a target (Turret.java:103, class default false -- duo does not override it; the shoot gate requires !alwaysShooting).'),
        'cheating': a('bool', 'if(cheating()) return peekAmmo();', 'Whether the team cheats (Turret.java:681 -- a cheating team returns peekAmmo() without consuming anything).'),
        'base_reload_speed': a('float', 'return efficiency;', 'The base reload speed (ReloadTurret.java:45-47, `return efficiency;` -- the driver passes the frame efficiency precomputed).', source=RELOAD_TURRET),
    }
    aim_shoot_outputs = {
        'rotation': a('float', 'rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);', 'The rotation after moveToward toward dest (Turret.java:666 -- unchanged when there is no valid target; the float turret rotation, default 90, BaseTurret.java:114).'),
        'reload_counter': a('float', 'reloadCounter += delta() * ammoReloadMultiplier() * baseReloadSpeed();', 'The reload counter after the tick charge, capped at reload, modulo on a shot (Turret.java:720 charges it, :723 caps it with min, :738 resets it with %= reload).'),
        'dest': a('float', 'float targetRot = angleTo(targetPos);', 'The angle to the predicted target position (Turret.java:595 -- angleTo is Position.angleTo -> Angles.angle, atan2(dx, dy), 0 degrees is +Y; null without a valid target).'),
        'shot': a('bool', 'if(!alwaysShooting && Angles.angleDist(rotation, targetRot) < shootCone && canShoot){', 'Whether the shoot gate fired (Turret.java:599 -- STRICT angleDist < shootCone, plus canShoot, plus the updateShooting reload / !charging / warmup gate at :733).'),
        'target_pos': a('Dictionary', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'The predicted target position dict (Turret.java:465 -- Predict.intercept when predictTarget and bullet.speed >= 0.01f, else the target position as-is; null without a valid target).'),
        'total_ammo_after': a('int', 'totalAmmo -= ammoPerShot;', 'The total ammo after the shot (Turret.java:687 -- minus ammoPerShot once when consumeAmmoOnce, clamped at 0 by Turret.java:688; unchanged when no shot or cheating).'),
        'ammo_entries_after': a('Array', 'entry.amount -= ammoPerShot;', 'The ammo stacks after the shot (Turret.java:685-686 -- the peeked entry minus ammoPerShot, popped when it reaches 0; the {"item", "amount"} format of SourceTurretAmmoState.use_ammo_stack_state).'),
        'shoot_event': a('Dictionary', 'bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),', 'The shoot event dict on a shot (Turret.java:744 -- the bullet origin x + trnsx(rotation - 90, shootX, shootY), plus rotation and the barrel; null when no shot; the pure function spawns no bullet).'),
        'barrel_counter_after': a('int', '}, () -> barrelCounter++);', 'The barrel counter after the tick (Turret.java:770 -- +1 on a shot, unchanged otherwise; duo ShootAlternate has barrels 2).'),
        'was_shooting': a('bool', 'wasShooting = true;', 'Whether the shoot gate fired this tick (Turret.java:600 -- set true inside the shoot gate, false otherwise; Turret.java:517 resets it false at the top of updateTile).'),
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
        ('N2250', AIM_SHOOT_OWNER, 'source_item_turret_aim_shoot_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', aim_shoot_inputs, aim_shoot_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ItemTurret aim + reload + shoot from Turret.java / ItemTurret.java / ReloadTurret.java / BaseTurret.java / BuildingComp.java / Blocks.java / BulletType.java / Predict.java / ShootAlternate.java / ShootPattern.java / Angles.java / Position.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ItemTurret aim + reload + shoot from Turret.java / ItemTurret.java / ReloadTurret.java / BaseTurret.java / BuildingComp.java / Blocks.java / BulletType.java / Predict.java / ShootAlternate.java / ShootPattern.java / Angles.java / Position.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, reload_counter,
    # dest, shot, target_pos, total_ammo_after,
    # ammo_entries_after, shoot_event, barrel_counter_after,
    # was_shooting.
    by_slice['N2250'] = [
        'source_item_turret_aim_shoot_state_result.rotation',
        'source_item_turret_aim_shoot_state_result.reload_counter',
        'source_item_turret_aim_shoot_state_result.dest',
        'source_item_turret_aim_shoot_state_result.shot',
        'source_item_turret_aim_shoot_state_result.target_pos',
        'source_item_turret_aim_shoot_state_result.total_ammo_after',
        'source_item_turret_aim_shoot_state_result.ammo_entries_after',
        'source_item_turret_aim_shoot_state_result.shoot_event',
        'source_item_turret_aim_shoot_state_result.barrel_counter_after',
        'source_item_turret_aim_shoot_state_result.was_shooting',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2250', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=AIM_SHOOT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2250'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
