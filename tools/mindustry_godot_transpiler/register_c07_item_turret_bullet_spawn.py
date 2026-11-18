"""Register the ItemTurret bullet() spawn (N2252).

N2250 only computed the shoot_event (the bullet origin dict --
`bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),`,
Turret.java:744 -- plus rotation and the barrel) and stamped it
on the frame; nobody consumed it. This slice wires the
shoot_event into a live bullet, following TurretBuild.bullet()
(Turret.java:779-801): shoot() hands the pattern the handler
(`pattern.shoot(barrelCounter, (xOffset, yOffset, angle, delay,
mover) -> {`, Turret.java:754), ShootAlternate picks one barrel
per shot (`float index = ((totalShots + i + barrelOffset) %
barrels) - (barrels-1)/2f;` / `handler.shoot(index * spread *
-Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);`,
ShootAlternate.java:31-37 -- duo barrels 2, spread 3.5,
barrelOffset 0, mirror false, Blocks.java:3293), and delay 0
calls bullet() at once (Turret.java:759-768 -- duo
firstShotDelay 0 and shotDelay 0, so the queue is empty here).
bullet() recomputes the origin with the offset, the angle with
the inaccuracy draw, and lifeScl 1 (scaleLife defaults false),
then `handleBullet(type.create(...), xOffset, yOffset,
shootAngle - rotation);` (Turret.java:790 -- handleBullet is a
no-op on TurretBuild, Turret.java:818-820). type.create stamps
the live bullet (`bullet.initVel(angle, speed * velocityScl *
...);`, BulletType.java:964; `bullet.lifetime = lifetime *
lifetimeScl * ...;`, BulletType.java:968; `bullet.damage =
(damage < 0 ? this.damage : damage) *
bullet.damageMultiplier();`, BulletType.java:972;
`bullet.hitSize = hitSize;`, BulletType.java:971). The
-Mathf.sign(mirror) pin is CLOSED from the arc source on disk:
`Mathf.sign(boolean b)` is `return b ? 1 : -1;`
(Mathf.java:203-205), so sign(false) is -1 and -sign(false) is
+1: xOffset is index * 3.5, barrel 0 (index -0.5) gives -1.75
and barrel 1 (index +0.5) gives +1.75.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceItemTurretBuildState.gd,
source_item_turret_bullet_spawn_state(shoot_event, x, y,
target_pos, barrel_counter, shoot_x, shoot_y, spread, barrels,
barrel_offset, mirror, x_spread, inaccuracy_draw, bullet_speed,
bullet_damage, bullet_lifetime, bullet_hit_size, range),
returning `{"bullet_x": ..., "bullet_y": ..., "shoot_angle":
..., "x_offset": ..., "velocity": ..., "speed": ...,
"damage": ..., "hit_size": ..., "lifetime_remaining": ...,
"life_scl": ..., "barrel": ...}`, plus one driver tick in the
duo branch (inside the shot block, after the ammo write-back)
that calls it with the pre-increment barrel and the peeked
ammo_data, stamps the spawn dict on the frame, and hands the
origin + shoot_angle + ammo_data to the existing runtime spawn
bridge (SourceBulletRuntimeState.spawn_turret_bullet -- the
single writer of game["bullets"], N2242/N2243). Eleven new
result symbols. (2) The origin is NOT recomputed from x/y:
the N2250 shoot_event already carries bullet_x/bullet_y, and
Angles.trnsx/trnsy rotate the (x, y) vector, so the rotation
is linear in the offset: bullet_x is shoot_event.bullet_x plus
(xOffset + xSpread) rotated by rotation - 90. (3) The random
draws are params: x_spread defaults 0.0 (xRand is 0 for duo)
and inaccuracy_draw defaults to a live randf_range(-2, 2)
draw -- the +-2 degrees faithful to Java -- while the proof
seeds a fixed draw through the frame key, so the pure function
itself never calls randf. (4) velocity is in Java per-tick
units (dir(shoot_angle) * speed * 1.0) and
lifetime_remaining is in ticks (lifetime * lifeScl); the
runtime bridge converts to per-second (x60) and seconds (/60)
for the live dict -- that conversion is already registered,
not this slice's. (5) The driver passes the catalog ammo_data
dict straight to the bridge (item / speed / damage / lifetime
/ sprite / width / height / reloadMultiplier); the bridge
defaults hitSize to 4.0 and reloadMultiplier to 1.0 when the
entry omits them. The catalog lifetime (copper 70.0) is the
converted value the port uses, NOT the Java 60f -- the driver
takes it from ammo_data. (6) The pure function takes the
pre-increment barrelCounter (shoot_event["barrel"]) because
pattern.shoot runs before the `}, () -> barrelCounter++);`
incrementer. SSOT expected after GREEN: symbols +11, Done
+1, contracts +1, schema +2, 11589/1701/1635/3061 ->
11600/1702/1636/3063; defense shard slices 180 -> 181,
contracts 179 -> 180.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_item_turret_validate_target import DEFERRED as N2251_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
SHOOT_ALTERNATE = 'core/src/mindustry/entities/pattern/ShootAlternate.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
BULLET_COMP = 'core/src/mindustry/entities/comp/BulletComp.java'
ANGLES = 'arc-core/src/arc/math/Angles.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
VEC2 = 'arc-core/src/arc/math/geom/Vec2.java'
PROOF = '/root/C07ItemTurretBulletSpawnProof'
BULLET_SPAWN_OWNER = 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state'
TESTS = ['test_c07_item_turret_bullet_spawn_registration', 'test_all_c07_item_turret_bullet_spawn_input_evidence_is_exact', 'test_item_turret_bullet_spawn_state', 'test_reference_graph_and_actual_c07_item_turret_bullet_spawn']
# The 9 slice sources the N2252 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/entities/pattern/ShootAlternate.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
    'core/src/mindustry/entities/comp/BulletComp.java',
    'arc-core/src/arc/math/Angles.java',
    'arc-core/src/arc/math/Mathf.java',
    'arc-core/src/arc/math/geom/Vec2.java',
]
EXACT_EXPRS = ['protected void shoot(BulletType type){', 'pattern.shoot(barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {', 'queuedBullets++;', 'if(delay > 0f){', 'bullet(type, xOffset, yOffset, angle, mover);', '}, () -> barrelCounter++);', 'if(consumeAmmoOnce){', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'queuedBullets --;', 'if(dead || (!consumeAmmoOnce && !hasAmmo())) return;', 'xSpread = Mathf.range(xRand),', 'bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', 'bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', 'shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);', 'float lifeScl = type.scaleLife ? Mathf.clamp((1 + scaleLifetimeOffset) * Mathf.dst(bulletX, bulletY, targetPos.x, targetPos.y) / type.range, minRange() / type.range, range() / type.range) : 1f;', 'handleBullet(type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y), xOffset, yOffset, shootAngle - rotation);', 'protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){', 'public float inaccuracy = 0f;', 'public float velocityRnd = 0f;', 'public float scaleLifetimeOffset = 0f;', 'public float xRand = 0f;', 'public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;', '(shootEffect == null ? type.shootEffect : shootEffect).at(bulletX, bulletY, rotation + angleOffset, type.hitColor);', '(smokeEffect == null ? type.smokeEffect : smokeEffect).at(bulletX, bulletY, rotation + angleOffset, type.hitColor);', '(type.shootSound != Sounds.none ? type.shootSound : shootSound).at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);', 'curRecoil = 1f;', 'heat = 1f;', 'totalShots++;', 'bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),', 'shoot = new ShootAlternate(3.5f);', 'Items.copper,  new BasicBulletType(2.5f, 9){{', 'Items.graphite, new BasicBulletType(3.5f, 18){{', 'Items.silicon, new BasicBulletType(3f, 12){{', 'lifetime = 60f;', 'shootY = 3f;', 'range = 160;', 'public float lifetime = 40f;', 'public float hitSize = 4;', 'public boolean scaleLife;', 'public float speed = 1f;', 'bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));', 'bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);', 'bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();', 'bullet.hitSize = hitSize;', 'public int barrels = 2;', 'public boolean mirror = false;', 'public int barrelOffset = 0;', 'float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;', 'handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);', 'public int shots = 1;', 'public float firstShotDelay = 0;', 'public float shotDelay = 0;', 'vel.trns(angle, amount);', 'return rv.set(x, y).rotate(angle).x;', 'return rv.set(x, y).rotate(angle).y;', 'return b ? 1 : -1;', 'return random(-range, range);', 'return set(amount, 0).rotate(angle);']

# DEFERRED is carried from the N2251 register script via import --
# never retyped. bullet() spawn is done by this slice, so the
# N2250 lumped "bullet() spawn detail" entry is superseded for
# the spawn / inaccuracy-draw / lifeScl halves: the inaccuracy
# draw now lives in the driver (randf_range(-2, 2) default,
# seeded through the frame in the proof) and lifeScl is 1.0 for
# duo (scaleLife false). The effects/sound and recoil/heat/
# totalShots halves still wait, as separate entries below, and
# findTarget / warmup / queuedBullets / the other ItemTurret
# defs still wait.
DEFERRED = list(N2251_DEFERRED) + [
    'ItemTurret bullet() spawn Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2251: the N2252 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ItemTurret bullet() effects/sound (shootEffect/smokeEffect/shootSound/ammoUseEffect, Turret.java:792-800) -- the spawn computes position/angle/velocity and the driver spawns the live bullet; Fx/Sounds are not in the port scope yet.',
    'ItemTurret bullet() recoil/heat/totalShots (curRecoil/heat/totalShots, Turret.java:804-812) -- the spawn does not stamp them; they wait for their own slice.',
    'ItemTurret bullet() scaleLife=true defs (lifeScl clamp, Turret.java:787) -- duo scaleLife is false so lifeScl is 1.0 here; artillery defs with scaleLife true wait for their own slice.',
    'ItemTurret bullet() consumeAmmoOnce=false defs (useAmmo per bullet, Turret.java:810-812) -- duo consumes once per shoot(); per-bullet consumption waits for its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    bullet_spawn_inputs = {
        'shoot_event': a('Dictionary', 'bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),', 'The N2250 shoot_event dict (Turret.java:744 -- the bullet origin bullet_x/bullet_y plus rotation and the pre-increment barrel; the pure function derives the spawn origin from it instead of recomputing trnsx/trnsy from x/y).'),
        'x': a('float', 'bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', 'The turret x (Turret.java:783 -- the bullet() origin base; carried for source-completeness, the shoot_event fallback).'),
        'y': a('float', 'bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', 'The turret y (Turret.java:784 -- the bullet() origin base; carried for source-completeness, the shoot_event fallback).'),
        'target_pos': a('Variant', 'float lifeScl = type.scaleLife ? Mathf.clamp((1 + scaleLifetimeOffset) * Mathf.dst(bulletX, bulletY, targetPos.x, targetPos.y) / type.range, minRange() / type.range, range() / type.range) : 1f;', 'The predicted target position dict (Turret.java:787 -- only the lifeScl clamp reads targetPos, and that branch is dead for duo since scaleLife is false; carried so scaleLife=true defs work unchanged).'),
        'barrel_counter': a('int', '}, () -> barrelCounter++);', 'The ShootAlternate barrel counter before the increment (Turret.java:770 -- pattern.shoot runs before the incrementer, so bullet() sees the pre-increment counter; the driver passes shoot_event["barrel"]).'),
        'shoot_x': a('float', 'public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;', 'The shoot X offset (Turret.java:66, class default 0f -- duo does not override it; carried for source-completeness, the shoot_event already includes it).'),
        'shoot_y': a('float', 'shootY = 3f;', 'The shoot Y offset (duo 3f, Blocks.java:3313 -- the bullet origin sits shootY ahead of the turret; carried for source-completeness, the shoot_event already includes it).', source=BLOCKS),
        'spread': a('float', 'shoot = new ShootAlternate(3.5f);', 'The ShootAlternate barrel spread in world units (duo 3.5f, Blocks.java:3293 -- xOffset is index * spread * -Mathf.sign(mirror)).', source=BLOCKS),
        'barrels': a('int', 'public int barrels = 2;', 'The ShootAlternate barrel count (ShootAlternate.java:8 -- duo has 2 barrels, so the index is (barrelCounter % 2) - 0.5).', source=SHOOT_ALTERNATE),
        'barrel_offset': a('int', 'public int barrelOffset = 0;', 'The ShootAlternate barrel start offset (ShootAlternate.java:10 -- duo 0, so the first shot uses barrel 0).', source=SHOOT_ALTERNATE),
        'mirror': a('bool', 'public boolean mirror = false;', 'Whether the ShootAlternate order is flipped (ShootAlternate.java:12 -- duo false; Mathf.sign(false) is -1, so -sign is +1 and xOffset is index * spread).', source=SHOOT_ALTERNATE),
        'x_spread': a('float', 'xSpread = Mathf.range(xRand),', 'The random X spread draw (Turret.java:782 -- Mathf.range(xRand) with xRand defaulting 0f, Turret.java:68, so 0 for duo; the driver/test supplies the draw, the pure function never calls randf).'),
        'inaccuracy_draw': a('float', 'shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);', 'The random inaccuracy draw in degrees (Turret.java:786 -- Mathf.range(inaccuracy + type.inaccuracy) with duo inaccuracy 2f and type inaccuracy 0f, so +-2 degrees; the driver draws it live, the proof seeds it fixed).'),
        'bullet_speed': a('float', 'public float speed = 1f;', 'The peeked ammo bullet speed per tick (BulletType.java:37 -- duo copper 2.5, graphite 3.5, silicon 3, Blocks.java:3259-3295; the driver passes the catalog ammo_data speed).', source=BULLET_TYPE),
        'bullet_damage': a('float', 'Items.copper,  new BasicBulletType(2.5f, 9){{', 'The peeked ammo bullet damage (duo copper 9, Blocks.java:3260 -- graphite 18, silicon 12; the driver passes the catalog ammo_data damage).', source=BLOCKS),
        'bullet_lifetime': a('float', 'lifetime = 60f;', 'The peeked ammo bullet lifetime in ticks (duo 60f in Java, Blocks.java:3265 -- the driver passes the catalog ammo_data lifetime, 70.0 for copper, which is the converted value the port uses).', source=BLOCKS),
        'bullet_hit_size': a('float', 'public float hitSize = 4;', 'The bullet hitSize (BulletType.java:43, default 4 -- the duo ammo entries carry no hitSize, so the driver passes the 4.0 default).', source=BULLET_TYPE),
        'range': a('float', 'range = 160;', 'The per-def range (duo 160, Blocks.java:3316 -- only the lifeScl clamp reads it, and that branch is dead for duo since scaleLife is false; carried so scaleLife=true defs work unchanged).', source=BLOCKS),
    }
    bullet_spawn_outputs = {
        'bullet_x': a('float', 'bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', 'The spawn origin x (Turret.java:783 -- shoot_event.bullet_x plus (xOffset + xSpread) rotated by rotation - 90; the trns rotation is linear in the offset).'),
        'bullet_y': a('float', 'bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', 'The spawn origin y (Turret.java:784 -- shoot_event.bullet_y plus (xOffset + xSpread) rotated by rotation - 90).'),
        'shoot_angle': a('float', 'shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);', 'The shoot angle in degrees (Turret.java:786 -- rotation + angleOffset 0 with ShootAlternate + the inaccuracy_draw param).'),
        'x_offset': a('float', 'handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);', 'The barrel x offset in world units (ShootAlternate.java:35 -- index * spread * -Mathf.sign(mirror); duo mirror false gives index * 3.5, barrel 0 -1.75, barrel 1 +1.75).', source=SHOOT_ALTERNATE),
        'velocity': a('Vector2', 'vel.trns(angle, amount);', 'The bullet velocity in Java per-tick units (BulletComp.java:329-331 -- initVel is vel.trns(angle, amount), i.e. dir(shoot_angle) * speed * 1.0; the runtime bridge multiplies by TICKS_PER_SECOND 60 for the live dict).', source=BULLET_COMP),
        'speed': a('float', 'public float speed = 1f;', 'The bullet speed per tick (BulletType.java:37 -- the ammo speed, copper 2.5; the bridge converts it to per-second for the live dict).', source=BULLET_TYPE),
        'damage': a('float', 'bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();', 'The bullet damage (BulletType.java:972 -- the ammo damage, copper 9).', source=BULLET_TYPE),
        'hit_size': a('float', 'bullet.hitSize = hitSize;', 'The bullet hitSize (BulletType.java:971 -- 4.0 for duo, the BulletType default).', source=BULLET_TYPE),
        'lifetime_remaining': a('float', 'bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);', 'The bullet lifetime remaining in ticks (BulletType.java:968 -- lifetime * lifeScl; the bridge divides by 60 for the live dict).', source=BULLET_TYPE),
        'life_scl': a('float', 'float lifeScl = type.scaleLife ? Mathf.clamp((1 + scaleLifetimeOffset) * Mathf.dst(bulletX, bulletY, targetPos.x, targetPos.y) / type.range, minRange() / type.range, range() / type.range) : 1f;', 'The lifetime scale (Turret.java:787 -- 1.0 for duo because scaleLife defaults false, BulletType.java:141).'),
        'barrel': a('int', 'float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;', 'The barrel this shot used (ShootAlternate.java:32 -- the pre-increment barrelCounter, echoed so the driver/proof can check the alternation).', source=SHOOT_ALTERNATE),
    }
    return bullet_spawn_inputs, bullet_spawn_outputs


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
    bullet_spawn_inputs, bullet_spawn_outputs = definitions()

    entries = [
        ('N2252', BULLET_SPAWN_OWNER, 'source_item_turret_bullet_spawn_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.bullet()', bullet_spawn_inputs, bullet_spawn_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ItemTurret bullet() spawn from Turret.java / Blocks.java / BulletType.java / ShootAlternate.java / ShootPattern.java / BulletComp.java / Angles.java / Mathf.java / Vec2.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ItemTurret bullet() spawn from Turret.java / Blocks.java / BulletType.java / ShootAlternate.java / ShootPattern.java / BulletComp.java / Angles.java / Mathf.java / Vec2.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: bullet_x, bullet_y,
    # shoot_angle, x_offset, velocity, speed, damage,
    # hit_size, lifetime_remaining, life_scl, barrel.
    by_slice['N2252'] = [
        'source_item_turret_bullet_spawn_state_result.bullet_x',
        'source_item_turret_bullet_spawn_state_result.bullet_y',
        'source_item_turret_bullet_spawn_state_result.shoot_angle',
        'source_item_turret_bullet_spawn_state_result.x_offset',
        'source_item_turret_bullet_spawn_state_result.velocity',
        'source_item_turret_bullet_spawn_state_result.speed',
        'source_item_turret_bullet_spawn_state_result.damage',
        'source_item_turret_bullet_spawn_state_result.hit_size',
        'source_item_turret_bullet_spawn_state_result.lifetime_remaining',
        'source_item_turret_bullet_spawn_state_result.life_scl',
        'source_item_turret_bullet_spawn_state_result.barrel',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2252', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.bullet()', godot_owner=BULLET_SPAWN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2252'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
