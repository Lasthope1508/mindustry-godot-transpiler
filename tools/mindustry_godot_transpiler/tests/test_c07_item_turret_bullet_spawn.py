import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildState.gd'
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ITEM_TURRET_BULLET_SPAWN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemTurretBulletSpawnProof.gd'


class C07ItemTurretBulletSpawnTests(unittest.TestCase):
    def test_c07_item_turret_bullet_spawn_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2252']['godot_owner'], 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state')
        # N2250 only computed the shoot_event (the bullet origin
        # dict -- `bulletX = x + Angles.trnsx(rotation - 90,
        # shootX, shootY),`, Turret.java:744 -- plus rotation
        # and the barrel) and stamped it on the frame; nobody
        # consumed it. This slice wires the shoot_event into a
        # live bullet, following TurretBuild.bullet()
        # (Turret.java:779-801): shoot() hands the pattern the
        # handler (`pattern.shoot(barrelCounter, (xOffset,
        # yOffset, angle, delay, mover) -> {`,
        # Turret.java:754 -- `ShootPattern pattern =
        # type.shootPattern != null ? type.shootPattern :
        # shoot;`, Turret.java:752), ShootAlternate picks one
        # barrel per shot (`float index = ((totalShots + i +
        # barrelOffset) % barrels) - (barrels-1)/2f;` /
        # `handler.shoot(index * spread * -Mathf.sign(mirror),
        # 0, 0f, firstShotDelay + shotDelay * i);`,
        # ShootAlternate.java:31-37 -- duo barrels 2, spread
        # 3.5, barrelOffset 0, mirror false,
        # Blocks.java:3293, `shoot = new
        # ShootAlternate(3.5f);`), and delay 0 calls bullet()
        # at once (`if(delay > 0f){` queues, `else{` calls
        # `bullet(type, xOffset, yOffset, angle, mover);`,
        # Turret.java:759-768 -- duo firstShotDelay 0 and
        # shotDelay 0, ShootPattern.java:11-13, so the queue
        # is empty here). bullet() recomputes the origin with
        # the offset (`bulletX = x + Angles.trnsx(rotation -
        # 90, shootX + xOffset + xSpread, shootY + yOffset),`
        # / `bulletY = y + Angles.trnsy(rotation - 90, shootX
        # + xOffset + xSpread, shootY + yOffset),`,
        # Turret.java:783-784 -- xSpread is
        # `Mathf.range(xRand),` Turret.java:782, and xRand
        # defaults 0f, Turret.java:68, so xSpread is 0 for
        # duo), the angle with the inaccuracy draw
        # (`shootAngle = rotation + angleOffset +
        # Mathf.range(inaccuracy + type.inaccuracy);`,
        # Turret.java:786 -- duo inaccuracy 2f,
        # Blocks.java:3320, type inaccuracy 0f,
        # BulletType.java:93, so the draw is +-2 degrees),
        # and lifeScl 1 (`float lifeScl = type.scaleLife ?
        # Mathf.clamp((1 + scaleLifetimeOffset) *
        # Mathf.dst(bulletX, bulletY, targetPos.x,
        # targetPos.y) / type.range, minRange() /
        # type.range, range() / type.range) : 1f;`,
        # Turret.java:787 -- scaleLife defaults false,
        # BulletType.java:141, and the duo def never sets it,
        # so the clamp branch is dead for duo and lifeScl is
        # 1.0), then `handleBullet(type.create(this, team,
        # bulletX, bulletY, shootAngle, -1f, (1f -
        # velocityRnd) + Mathf.random(velocityRnd), lifeScl,
        # null, mover, targetPos.x, targetPos.y), xOffset,
        # yOffset, shootAngle - rotation);`
        # (Turret.java:790 -- velocityRnd defaults 0f,
        # Turret.java:60, so the velocity factor is 1.0;
        # handleBullet is a no-op on TurretBuild,
        # Turret.java:818-820). type.create stamps the live
        # bullet (`bullet.initVel(angle, speed *
        # velocityScl * ...);`, BulletType.java:964 --
        # initVel is `vel.trns(angle, amount);`,
        # BulletComp.java:329-331, i.e. Vec2.trns is
        # `return set(amount, 0).rotate(angle);`,
        # Vec2.java:40-42, so the velocity is dir(angle) *
        # speed; `bullet.lifetime = lifetime * lifetimeScl *
        # ...;`, BulletType.java:968; `bullet.damage =
        # (damage < 0 ? this.damage : damage) *
        # bullet.damageMultiplier();`, BulletType.java:972;
        # `bullet.hitSize = hitSize;`,
        # BulletType.java:971). The -Mathf.sign(mirror) pin
        # is CLOSED from the arc source on disk:
        # `Mathf.sign(boolean b)` is `return b ? 1 : -1;`
        # (Mathf.java:203-205), so sign(false) is -1 and
        # -sign(false) is +1: xOffset is index * 3.5, barrel
        # 0 (index -0.5) gives -1.75 and barrel 1 (index
        # +0.5) gives +1.75. One pure function on
        # SourceItemTurretBuildState.gd, plus one driver tick
        # in the duo branch that calls it on a shot and hands
        # the result to the existing runtime spawn bridge
        # (SourceBulletRuntimeState.spawn_turret_bullet --
        # the single writer of game["bullets"], N2242/N2243).
        # Eleven new result symbols: bullet_x + bullet_y +
        # shoot_angle + x_offset + velocity + speed + damage
        # + hit_size + lifetime_remaining + life_scl + barrel.
        self.assertEqual(
            ledger['N2252']['source_symbols'],
            [
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
            ],
        )
        for name in ledger['N2252']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'core/src/mindustry/entities/pattern/ShootAlternate.java',
                    'core/src/mindustry/entities/pattern/ShootPattern.java',
                    'core/src/mindustry/entities/comp/BulletComp.java',
                    'arc-core/src/arc/math/Angles.java',
                    'arc-core/src/arc/math/Mathf.java',
                    'arc-core/src/arc/math/geom/Vec2.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_turret_bullet_spawn_state_result.bullet_x': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.bullet_y': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.shoot_angle': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.x_offset': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.velocity': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.speed': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.damage': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.hit_size': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.lifetime_remaining': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.life_scl': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.barrel': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                }[name])
        self.assertEqual(ledger['N2252']['runtime_proof'], '/root/C07ItemTurretBulletSpawnProof')
        self.assertEqual(
            ledger['N2252']['tests'],
            [
                'test_c07_item_turret_bullet_spawn_registration',
                'test_all_c07_item_turret_bullet_spawn_input_evidence_is_exact',
                'test_item_turret_bullet_spawn_state',
                'test_reference_graph_and_actual_c07_item_turret_bullet_spawn',
            ],
        )
        self.assertTrue(ledger['N2252']['deferred_exprs'])

    def test_all_c07_item_turret_bullet_spawn_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2252']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_turret_bullet_spawn_state_result.bullet_x': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.bullet_y': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.shoot_angle': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.x_offset': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.velocity': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.speed': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.damage': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.hit_size': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.lifetime_remaining': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.life_scl': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                    'source_item_turret_bullet_spawn_state_result.barrel': 'SourceItemTurretBuildState.source_item_turret_bullet_spawn_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/pattern/ShootAlternate.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
            'arc-core/src/arc/math/Angles.java',
            'arc-core/src/arc/math/Mathf.java',
            'arc-core/src/arc/math/geom/Vec2.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2252']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_turret_bullet_spawn_state(self):
        item_turret = ITEM_TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.bullet() (Turret.java:779-801) spawns one
        # bullet per pattern handler call: shoot() hands the
        # pattern the handler (`pattern.shoot(barrelCounter,
        # (xOffset, yOffset, angle, delay, mover) -> {`,
        # Turret.java:754), ShootAlternate picks one barrel
        # (`float index = ((totalShots + i + barrelOffset) %
        # barrels) - (barrels-1)/2f;` /
        # `handler.shoot(index * spread * -Mathf.sign(mirror),
        # 0, 0f, firstShotDelay + shotDelay * i);`,
        # ShootAlternate.java:31-37 -- duo barrels 2, spread
        # 3.5, barrelOffset 0, mirror false), and delay 0
        # calls bullet() at once (`if(delay > 0f){` queues,
        # `else{` calls `bullet(type, xOffset, yOffset, angle,
        # mover);`, Turret.java:759-768). bullet() is
        # `protected void bullet(BulletType type, float
        # xOffset, float yOffset, float angleOffset, Mover
        # mover){` (Turret.java:779): `queuedBullets --;`
        # (:780), then the early return (`if(dead ||
        # (!consumeAmmoOnce && !hasAmmo())) return;`, :781 --
        # duo consumeAmmoOnce is true, so the hasAmmo half is
        # dead here and the updateTile hasAmmo gate at
        # Turret.java:548 already guards the shot), `xSpread
        # = Mathf.range(xRand),` (:782 -- xRand defaults 0f,
        # `public float xRand = 0f;`, Turret.java:68, so
        # xSpread is 0 for duo but stays a param for later
        # defs), the origin (`bulletX = x + Angles.trnsx
        # (rotation - 90, shootX + xOffset + xSpread,
        # shootY + yOffset),` / `bulletY = y +
        # Angles.trnsy(rotation - 90, shootX + xOffset +
        # xSpread, shootY + yOffset),`, :783-784), the angle
        # (`shootAngle = rotation + angleOffset +
        # Mathf.range(inaccuracy + type.inaccuracy);`, :786
        # -- inaccuracy is the duo 2f, `inaccuracy = 2f;`,
        # Blocks.java:3320, type inaccuracy 0f, `public float
        # inaccuracy = 0f;`, BulletType.java:93, so the draw
        # is +-2 degrees; `Mathf.range(float range)` is
        # `return random(-range, range);`,
        # Mathf.java:220-222), lifeScl (`float lifeScl =
        # type.scaleLife ? Mathf.clamp((1 +
        # scaleLifetimeOffset) * Mathf.dst(bulletX, bulletY,
        # targetPos.x, targetPos.y) / type.range, minRange()
        # / type.range, range() / type.range) : 1f;`, :787 --
        # scaleLife defaults false, `public boolean
        # scaleLife;`, BulletType.java:141, and the duo def
        # never sets it, so lifeScl is 1.0 for duo;
        # scaleLifetimeOffset defaults 0f, `public float
        # scaleLifetimeOffset = 0f;`, Turret.java:62), and
        # the create (`handleBullet(type.create(this, team,
        # bulletX, bulletY, shootAngle, -1f, (1f -
        # velocityRnd) + Mathf.random(velocityRnd), lifeScl,
        # null, mover, targetPos.x, targetPos.y), xOffset,
        # yOffset, shootAngle - rotation);`, :790 --
        # velocityRnd defaults 0f, `public float velocityRnd
        # = 0f;`, Turret.java:60, so the velocity factor is
        # 1.0; handleBullet is a no-op on TurretBuild,
        # `protected void handleBullet(@Nullable Bullet
        # bullet, float offsetX, float offsetY, float
        # angleOffset){`, Turret.java:818-820). type.create
        # stamps the live bullet (`bullet.initVel(angle,
        # speed * velocityScl * (velocityScaleRandMin != 1f
        # || velocityScaleRandMax != 1f ?
        # Mathf.random(velocityScaleRandMin,
        # velocityScaleRandMax) : 1f));`,
        # BulletType.java:964 -- initVel is `vel.trns(angle,
        # amount);`, BulletComp.java:329-331, i.e. Vec2.trns
        # is `return set(amount, 0).rotate(angle);`,
        # Vec2.java:40-42, so velocity is dir(angle) *
        # speed; `bullet.lifetime = lifetime * lifetimeScl *
        # (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f
        # ? Mathf.random(lifeScaleRandMin,
        # lifeScaleRandMax) : 1f);`, BulletType.java:968;
        # `bullet.damage = (damage < 0 ? this.damage :
        # damage) * bullet.damageMultiplier();`,
        # BulletType.java:972; `bullet.hitSize = hitSize;`,
        # BulletType.java:971). The origin is NOT recomputed
        # from x/y: the N2250 shoot_event already carries
        # bullet_x/bullet_y (`bulletX = x + Angles.trnsx
        # (rotation - 90, shootX, shootY),`,
        # Turret.java:744), and Angles.trnsx/trnsy rotate
        # the (x, y) vector (`return rv.set(x, y).rotate
        # (angle).x;` / `return rv.set(x, y).rotate(angle)
        # .y;`, Angles.java:74-80), so the rotation is
        # linear in the offset: bullet_x is shoot_event
        # .bullet_x plus (xOffset + xSpread) rotated by
        # rotation - 90, bullet_y the same with sin. The
        # -Mathf.sign(mirror) pin: `Mathf.sign(boolean b)`
        # is `return b ? 1 : -1;` (Mathf.java:203-205), so
        # sign(false) is -1 and -sign(false) is +1: xOffset
        # is index * 3.5, barrel 0 (index -0.5) gives -1.75
        # and barrel 1 (index +0.5) gives +1.75. Class
        # defaults are shootX 0f / shootY -INF (`public
        # float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;`,
        # Turret.java:66 -- duo shootY 3f, `shootY = 3f;`,
        # Blocks.java:3313), barrels 2 (`public int barrels
        # = 2;`, ShootAlternate.java:8), mirror false
        # (`public boolean mirror = false;`,
        # ShootAlternate.java:12), barrelOffset 0 (`public
        # int barrelOffset = 0;`, ShootAlternate.java:10),
        # shots 1 (`public int shots = 1;`,
        # ShootPattern.java:9), firstShotDelay 0 (`public
        # float firstShotDelay = 0;`, ShootPattern.java:11),
        # shotDelay 0 (`public float shotDelay = 0;`,
        # ShootPattern.java:13). Duo ammo is copper
        # `Items.copper,  new BasicBulletType(2.5f, 9){{`
        # (Blocks.java:3260 -- note the double space),
        # graphite `Items.graphite, new BasicBulletType(3.5f,
        # 18){{` (:3270), silicon `Items.silicon, new
        # BasicBulletType(3f, 12){{` (:3282), each with
        # `lifetime = 60f;` in Java; the catalog ammo entries
        # the driver reads carry damage / speed / lifetime
        # (copper 9 / 2.5 / 70.0, graphite 18 / 3.5 /
        # 54.57142857142857, silicon 12 / 3.0 /
        # 58.333333333333336 -- the catalog lifetime is
        # converted from range/speed, NOT the Java 60f, and
        # the driver takes it from ammo_data). BulletType
        # defaults are lifetime 40f (`public float lifetime
        # = 40f;`, BulletType.java:33), hitSize 4 (`public
        # float hitSize = 4;`, BulletType.java:43), speed 1f
        # (`public float speed = 1f;`, BulletType.java:37).
        # The result is an 11-key dict: `bullet_x` /
        # `bullet_y` (the spawn origin), `shoot_angle`
        # (rotation + inaccuracy_draw, angleOffset 0 with
        # ShootAlternate), `x_offset` (the barrel offset),
        # `velocity` (dir(shoot_angle) * speed * 1.0, Java
        # per-tick units -- the runtime bridge multiplies
        # by TICKS_PER_SECOND 60 for the live dict),
        # `speed` / `damage` / `hit_size` (from ammo_data),
        # `lifetime_remaining` (lifetime * lifeScl, ticks --
        # the bridge divides by 60 for the live dict),
        # `life_scl` (1.0 for duo), `barrel` (the
        # pre-increment barrelCounter -- pattern.shoot runs
        # before the `}, () -> barrelCounter++);`
        # incrementer, Turret.java:770). The effects/sound
        # (`(shootEffect == null ? type.shootEffect :
        # shootEffect).at(bulletX, bulletY, rotation +
        # angleOffset, type.hitColor);` /
        # `(smokeEffect == null ? type.smokeEffect :
        # smokeEffect).at(bulletX, bulletY, rotation +
        # angleOffset, type.hitColor);` /
        # `(type.shootSound != Sounds.none ? type.shootSound
        # : shootSound).at(bulletX, bulletY,
        # Mathf.random(soundPitchMin, soundPitchMax),
        # shootSoundVolume);`, Turret.java:792-800),
        # recoil/heat/totalShots (`curRecoil = 1f;` /
        # `heat = 1f;` / `totalShots++;`, Turret.java:804-812),
        # queuedBullets when shotDelay > 0, scaleLife=true
        # defs, consumeAmmoOnce=false defs, and findTarget
        # are NOT this slice -- they wait for their own
        # slices.
        self.assertIn('static func source_item_turret_bullet_spawn_state(shoot_event: Dictionary, x: float, y: float, target_pos: Variant, barrel_counter: int, shoot_x: float, shoot_y: float, spread: float, barrels: int, barrel_offset: int, mirror: bool, x_spread: float, inaccuracy_draw: float, bullet_speed: float, bullet_damage: float, bullet_lifetime: float, bullet_hit_size: float, range: float) -> Dictionary:', item_turret)
        self.assertIn('var index: float = float((barrel_counter + barrel_offset) % barrels) - float(barrels - 1) / 2.0', item_turret)
        self.assertIn('var mirror_factor: float = -1.0 if mirror else 1.0', item_turret)
        self.assertIn('var x_offset: float = index * spread * mirror_factor', item_turret)
        self.assertIn('var rotation: float = float(shoot_event.get("rotation", 90.0))', item_turret)
        self.assertIn('var angle_rad: float = deg_to_rad(rotation - 90.0)', item_turret)
        self.assertIn('var bullet_x: float = float(shoot_event.get("bullet_x", x)) + (x_offset + x_spread) * cos(angle_rad)', item_turret)
        self.assertIn('var bullet_y: float = float(shoot_event.get("bullet_y", y)) + (x_offset + x_spread) * sin(angle_rad)', item_turret)
        self.assertIn('var shoot_angle: float = rotation + inaccuracy_draw', item_turret)
        self.assertIn('var velocity: Vector2 = Vector2(cos(deg_to_rad(shoot_angle)), sin(deg_to_rad(shoot_angle))) * bullet_speed', item_turret)
        self.assertIn('var life_scl: float = 1.0', item_turret)
        self.assertIn('return {"bullet_x": bullet_x, "bullet_y": bullet_y, "shoot_angle": shoot_angle, "x_offset": x_offset, "velocity": velocity, "speed": bullet_speed, "damage": bullet_damage, "hit_size": bullet_hit_size, "lifetime_remaining": bullet_lifetime * life_scl, "life_scl": life_scl, "barrel": barrel_counter}', item_turret)
        self.assertIn('pattern.shoot(barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {', item_turret)
        self.assertIn('float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;', item_turret)
        self.assertIn('handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);', item_turret)
        self.assertIn('return b ? 1 : -1;', item_turret)
        self.assertIn('protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', item_turret)
        self.assertIn('queuedBullets --;', item_turret)
        self.assertIn('if(dead || (!consumeAmmoOnce && !hasAmmo())) return;', item_turret)
        self.assertIn('xSpread = Mathf.range(xRand),', item_turret)
        self.assertIn('bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', item_turret)
        self.assertIn('bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),', item_turret)
        self.assertIn('shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);', item_turret)
        self.assertIn('float lifeScl = type.scaleLife ? Mathf.clamp((1 + scaleLifetimeOffset) * Mathf.dst(bulletX, bulletY, targetPos.x, targetPos.y) / type.range, minRange() / type.range, range() / type.range) : 1f;', item_turret)
        self.assertIn('handleBullet(type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y), xOffset, yOffset, shootAngle - rotation);', item_turret)
        self.assertIn('protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){', item_turret)
        self.assertIn('public float inaccuracy = 0f;', item_turret)
        self.assertIn('public float velocityRnd = 0f;', item_turret)
        self.assertIn('public float scaleLifetimeOffset = 0f;', item_turret)
        self.assertIn('public float xRand = 0f;', item_turret)
        self.assertIn('public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;', item_turret)
        self.assertIn('public int barrels = 2;', item_turret)
        self.assertIn('public boolean mirror = false;', item_turret)
        self.assertIn('public int barrelOffset = 0;', item_turret)
        self.assertIn('public int shots = 1;', item_turret)
        self.assertIn('public float firstShotDelay = 0;', item_turret)
        self.assertIn('public float shotDelay = 0;', item_turret)
        self.assertIn('shoot = new ShootAlternate(3.5f);', item_turret)
        self.assertIn('Items.copper,  new BasicBulletType(2.5f, 9){{', item_turret)
        self.assertIn('Items.graphite, new BasicBulletType(3.5f, 18){{', item_turret)
        self.assertIn('Items.silicon, new BasicBulletType(3f, 12){{', item_turret)
        self.assertIn('lifetime = 60f;', item_turret)
        self.assertIn('shootY = 3f;', item_turret)
        self.assertIn('range = 160;', item_turret)
        self.assertIn('public float lifetime = 40f;', item_turret)
        self.assertIn('public float hitSize = 4;', item_turret)
        self.assertIn('public boolean scaleLife;', item_turret)
        self.assertIn('public float speed = 1f;', item_turret)
        self.assertIn('bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));', item_turret)
        self.assertIn('bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);', item_turret)
        self.assertIn('bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();', item_turret)
        self.assertIn('bullet.hitSize = hitSize;', item_turret)
        self.assertIn('vel.trns(angle, amount);', item_turret)
        self.assertIn('return set(amount, 0).rotate(angle);', item_turret)
        self.assertIn('return rv.set(x, y).rotate(angle).x;', item_turret)
        self.assertIn('return rv.set(x, y).rotate(angle).y;', item_turret)
        self.assertIn('return random(-range, range);', item_turret)
        self.assertIn('(shootEffect == null ? type.shootEffect : shootEffect).at(bulletX, bulletY, rotation + angleOffset, type.hitColor);', item_turret)
        self.assertIn('(smokeEffect == null ? type.smokeEffect : smokeEffect).at(bulletX, bulletY, rotation + angleOffset, type.hitColor);', item_turret)
        self.assertIn('(type.shootSound != Sounds.none ? type.shootSound : shootSound).at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);', item_turret)
        self.assertIn('curRecoil = 1f;', item_turret)
        self.assertIn('heat = 1f;', item_turret)
        self.assertIn('totalShots++;', item_turret)
        self.assertIn('bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),', item_turret)
        self.assertIn('}, () -> barrelCounter++);', item_turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch inside
        # the `if bool(aim.get("shot", false)):` block after the
        # ammo write-back: it calls the new pure function with
        # the pre-increment barrel (shoot_event["barrel"] --
        # pattern.shoot runs before the `}, () ->
        # barrelCounter++);` incrementer), the per-def duo
        # values (shootX 0, shootY 3, spread 3.5, barrels 2,
        # barrelOffset 0, mirror false, range 160) and the
        # peeked ammo_data (speed / damage / lifetime /
        # hitSize, with the BulletType defaults 1.0 / 0.0 /
        # 40.0 / 4.0 when the catalog entry omits them),
        # stamps the spawn dict on the frame, and hands the
        # origin + shoot_angle + the ammo_data dict to the
        # existing runtime spawn bridge
        # (SourceBulletRuntimeState.spawn_turret_bullet --
        # the single writer of game["bullets"], N2242/N2243:
        # it builds the spawn state from the data dict,
        # looks the "bullet" sprite texture up on the game,
        # converts speed to per-second (x60) and lifetime to
        # seconds (/60), and appends the live dict with the
        # team stamp). The random draws are params: x_spread
        # defaults 0.0 (xRand is 0 for duo) and
        # inaccuracy_draw defaults to a live randf_range(-2,
        # 2) draw -- the +-2 degrees faithful to Java
        # (`Mathf.range(inaccuracy + type.inaccuracy)` with
        # duo inaccuracy 2f and type inaccuracy 0f) -- while
        # the proof seeds a fixed draw through the frame key,
        # so the pure function itself never calls randf.
        driver = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")', driver)
        self.assertIn('var shoot_event: Dictionary = aim.get("shoot_event", {})', driver)
        self.assertIn('var spawn: Dictionary = source_item_turret_build_state.source_item_turret_bullet_spawn_state(', driver)
        self.assertIn('shoot_event, sprite.position.x, sprite.position.y, aim.get("target_pos", null),', driver)
        self.assertIn('int(shoot_event.get("barrel", 0)),', driver)
        self.assertIn('0.0, 3.0, 3.5, 2, 0, false,', driver)
        self.assertIn('float(frame.get("x_spread", 0.0)), float(frame.get("inaccuracy_draw", randf_range(-2.0, 2.0))),', driver)
        self.assertIn('float(duo_ammo_data.get("speed", 1.0)), float(duo_ammo_data.get("damage", 0.0)),', driver)
        self.assertIn('float(duo_ammo_data.get("lifetime", 40.0)), float(duo_ammo_data.get("hitSize", 4.0)), 160.0)', driver)
        self.assertIn('frame["bullet_spawn"] = spawn', driver)
        self.assertIn('source_bullet_runtime_state.spawn_turret_bullet(game, Vector2(float(spawn.get("bullet_x", 0.0)), float(spawn.get("bullet_y", 0.0))), frame.get("target", null), duo_ammo_data, team_id, float(spawn.get("shoot_angle", 90.0)))', driver)
        # The proof's keys drive the bullet spawn through the
        # real driver (the alternate barrel flips the x offset
        # -1.75 / +1.75 / the shoot angle carries the seeded
        # inaccuracy draw / the spawn origin sits shootY 3
        # ahead of the turret / the live lifetime comes from
        # the catalog ammo entry, 70.0 ticks for copper /
        # the live damage is the copper 9 / the live velocity
        # length is the copper speed 2.5 per tick, i.e. 150
        # per second after the bridge conversion / a live
        # bullet dict lands in game["bullets"] / the live
        # bullet carries the turret team). There are no
        # effects/sound / recoil/heat / queuedBullets /
        # findTarget keys: those wait for their own slices.
        proof = ITEM_TURRET_BULLET_SPAWN_PROOF.read_text(encoding='utf-8')
        for key in [
            'spawn_barrel_alternates_x_offset',
            'spawn_angle_includes_inaccuracy_draw',
            'spawn_position_uses_shoot_y_3',
            'spawn_lifetime_from_ammo_catalog',
            'spawn_damage_copper_9',
            'spawn_velocity_matches_speed_2_5',
            'spawn_live_bullet_in_game_bullets',
            'spawn_team_stamp',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_item_turret_bullet_spawn(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemTurretBulletSpawnProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_TURRET_BULLET_SPAWN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'spawn_barrel_alternates_x_offset',
            'spawn_angle_includes_inaccuracy_draw',
            'spawn_position_uses_shoot_y_3',
            'spawn_lifetime_from_ammo_catalog',
            'spawn_damage_copper_9',
            'spawn_velocity_matches_speed_2_5',
            'spawn_live_bullet_in_game_bullets',
            'spawn_team_stamp',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
