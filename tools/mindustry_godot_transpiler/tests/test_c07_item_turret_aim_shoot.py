import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildState.gd'
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ITEM_TURRET_AIM_SHOOT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemTurretAimShootProof.gd'


class C07ItemTurretAimShootTests(unittest.TestCase):
    def test_c07_item_turret_aim_shoot_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2250']['godot_owner'], 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state')
        # ItemTurret does NOT override updateTile (ItemTurret.java:23,
        # `public class ItemTurret extends Turret{` -- it only
        # overrides ammo); the whole aim / reload / shoot lives in
        # Turret.TurretBuild.updateTile() (Turret.java:490-615), so
        # this slice is the duo half of that updateTile, following
        # the N2240 PointDefense precedent: when the target is valid
        # (`if(validateTarget()){`, Turret.java:573 -- validateTarget
        # is `return !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();`, Turret.java:631-632, passed in as
        # target_valid because Units.invalidateTarget waits for its
        # own slice), the build aims at the predicted position
        # (`targetPosition(target);`, Turret.java:581 -- Predict
        # .intercept when `predictTarget && bullet.speed >= 0.01f`,
        # Turret.java:464-465), turns toward it (`float targetRot
        # = angleTo(targetPos);` / `turnToTarget(targetRot);`,
        # Turret.java:595-598 -- `rotation =
        # Angles.moveToward(rotation, targetRot, rotateSpeed *
        # delta() * potentialEfficiency);`,
        # Turret.java:665-667), and shoots when aimed and in range
        # (`if(!alwaysShooting && Angles.angleDist(rotation,
        # targetRot) < shootCone && canShoot){`,
        # Turret.java:599 -- STRICT `<` shootCone, unlike the
        # PointDefense `Angles.within` `<=`; `canShoot =
        # within(target, range() + (target instanceof Sized hb ?
        # hb.hitSize()/1.9f : 0f));`, Turret.java:585). The
        # reload charges every tick (`reloadCounter += delta() *
        # ammoReloadMultiplier() * baseReloadSpeed();` /
        # `reloadCounter = Math.min(reloadCounter, reload);`,
        # Turret.java:719-724 -- the cap lives here, on the plain
        # TurretBuild, unlike PointDefense which never clamps),
        # and updateShooting fires only when reloaded, not
        # charging, and warmed up (`if(reloadCounter >= reload
        # && !charging() && shootWarmup >= minWarmup){`,
        # Turret.java:733) then resets with modulo
        # (`reloadCounter %= reload;`, Turret.java:738 -- NOT
        # `= 0`, unlike PointDefenseTurret.java:97). The shot
        # consumes ammo once (`if(consumeAmmoOnce){ useAmmo();
        # }`, Turret.java:771-773 -- `entry.amount -=
        # ammoPerShot;` / `if(entry.amount <= 0) ammo.pop();` /
        # `totalAmmo -= ammoPerShot;` / `totalAmmo =
        # Math.max(totalAmmo, 0);`, Turret.java:680-690; cheating
        # returns peekAmmo() without consuming, Turret.java:681)
        # and advances the alternate barrel (`}, () ->
        # barrelCounter++);`, Turret.java:770 -- ShootAlternate
        # (Blocks.java:3300, `shoot = new ShootAlternate(3.5f);`,
        # `public int barrels = 2;`,
        # ShootAlternate.java:8). One pure function on
        # SourceItemTurretBuildState.gd, plus one driver tick
        # line in SourceTurretBuildState.gd guarded on block
        # `duo` (the shared TurretBuild driver,
        # source_turret_tick_buildings_state, already ticks every
        # TurretBuild). Ten new result symbols: rotation +
        # reload_counter + dest + shot + target_pos +
        # total_ammo_after + ammo_entries_after + shoot_event +
        # barrel_counter_after + was_shooting.
        self.assertEqual(
            ledger['N2250']['source_symbols'],
            [
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
            ],
        )
        for name in ledger['N2250']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
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
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_turret_aim_shoot_state_result.rotation': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.reload_counter': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.dest': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.shot': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.target_pos': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.total_ammo_after': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.ammo_entries_after': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.shoot_event': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.barrel_counter_after': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.was_shooting': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                }[name])
        self.assertEqual(ledger['N2250']['runtime_proof'], '/root/C07ItemTurretAimShootProof')
        self.assertEqual(
            ledger['N2250']['tests'],
            [
                'test_c07_item_turret_aim_shoot_registration',
                'test_all_c07_item_turret_aim_shoot_input_evidence_is_exact',
                'test_item_turret_aim_shoot_state',
                'test_reference_graph_and_actual_c07_item_turret_aim_shoot',
            ],
        )
        self.assertTrue(ledger['N2250']['deferred_exprs'])

    def test_all_c07_item_turret_aim_shoot_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2250']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_turret_aim_shoot_state_result.rotation': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.reload_counter': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.dest': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.shot': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.target_pos': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.total_ammo_after': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.ammo_entries_after': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.shoot_event': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.barrel_counter_after': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                    'source_item_turret_aim_shoot_state_result.was_shooting': 'SourceItemTurretBuildState.source_item_turret_aim_shoot_state',
                }[name])
        slice_sources = {
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
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2250']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_turret_aim_shoot_state(self):
        item_turret = ITEM_TURRET_STATE.read_text(encoding='utf-8')
        # The duo half of TurretBuild.updateTile()
        # (Turret.java:490-615) lives on the item-turret build
        # state: the reload charges every tick (`reloadCounter
        # += delta() * ammoReloadMultiplier() *
        # baseReloadSpeed();` / `reloadCounter =
        # Math.min(reloadCounter, reload);`,
        # Turret.java:719-724 -- reloadWhileCharging defaults
        # true, Turret.java:82, so updateReload always runs;
        # ammoReloadMultiplier is the peeked ammo's
        # reloadMultiplier when there is ammo, else 1f,
        # Turret.java:727-729; baseReloadSpeed is efficiency,
        # ReloadTurret.java:45-47, passed in precomputed).
        # The aim/shoot half runs only with a valid target
        # (`if(validateTarget()){`, Turret.java:573 -- the
        # target_valid param, because Units.invalidateTarget
        # waits for its own slice; a null target, a non-dict
        # target, or target_valid false leaves rotation and
        # reloadCounter at their charged values and shoots
        # nothing). targetPosition (`targetPosition(target);`,
        # Turret.java:581) uses Predict.intercept when
        # `predictTarget && bullet.speed >= 0.01f`
        # (Turret.java:464-465) -- the intercept is the
        # deterministic quadratic (`float a = dstvx * dstvx +
        # dstvy * dstvy - v * v;` / `float b = 2 * (dstvx *
        # tx + dstvy * ty);` / `float c = tx * tx + ty *
        # ty;` / `float disc = b * b - 4 * a * c;`,
        # Predict.java:33-36/:42/:87-104, `private static Vec2
        # quad(float a, float b, float c){`), with the target
        # velocity per second and the bullet speed as inputs;
        # otherwise the target position is used as-is. The
        # NaN guard (`if(Float.isNaN(rotation)) rotation =
        # 0;`, Turret.java:583) runs before the turn. canShoot
        # is `within(target, range() + (target instanceof
        # Sized hb ? hb.hitSize()/1.9f : 0f))`
        # (Turret.java:585) -- Position.within is dst2 <
        # range*range, STRICT < (Position.java:40-46), with
        # range() already including the peeked ammo's
        # rangeChange (`return range + peekAmmo().rangeChange;`,
        # Turret.java:342-346). `angleTo` is Position.angleTo
        # -> Angles.angle, i.e. `Mathf.atan2(x2 - x, y2 - y)
        # * Mathf.radDeg` normalized to [0, 360)
        # (Angles.java:56-59) -- atan2(dx, dy), 0 degrees is
        # +Y, so GREEN writes `rad_to_deg(atan2(tx - x, ty -
        # y))`, never Vector2.angle_to. turnToTarget is
        # `rotation = Angles.moveToward(rotation, targetRot,
        # rotateSpeed * delta() * potentialEfficiency)`
        # (Turret.java:665-667); shouldTurn is
        # `moveWhileCharging || !charging()`
        # (Turret.java:669-671) and moveWhileCharging defaults
        # true (Turret.java:80), so duo always turns. The
        # shoot gate (`if(!alwaysShooting &&
        # Angles.angleDist(rotation, targetRot) < shootCone &&
        # canShoot){`, Turret.java:599) is STRICT `<`
        # shootCone (not Angles.within `<=`); alwaysShooting
        # defaults false (Turret.java:103). updateShooting
        # (`if(reloadCounter >= reload && !charging() &&
        # shootWarmup >= minWarmup){`, Turret.java:733) fires
        # shoot(type) then `reloadCounter %= reload;`
        # (Turret.java:738 -- modulo, NOT reset-to-0). shoot()
        # consumes ammo once (`if(consumeAmmoOnce){ useAmmo();
        # }`, Turret.java:771-773) and advances the barrel
        # (`}, () -> barrelCounter++);`, Turret.java:770);
        # useAmmo is inline here (`if(cheating()) return
        # peekAmmo();` / `entry.amount -= ammoPerShot;` /
        # `if(entry.amount <= 0) ammo.pop();` / `totalAmmo -=
        # ammoPerShot;` / `totalAmmo = Math.max(totalAmmo,
        # 0);`, Turret.java:680-690 -- the same formula as
        # the registered source_turret_use_ammo_state in
        # SourceTurretBuildState.gd, which the comment points
        # at; the stacks are the {"item", "amount"} dicts of
        # SourceTurretAmmoState.selected_turret_ammo_entries
        # / use_ammo_stack_state, peeked from the last stack).
        # `rotation` is the float turret rotation, default 90
        # (`public float rotation = 90;`, BaseTurret.java:114
        # -- NOT BuildingComp.rotation, the int block
        # rotation), and `reloadCounter` is the float on
        # ReloadTurretBuild (`public float reloadCounter;`,
        # ReloadTurret.java:26). Class defaults are
        # shootCone 8f, minWarmup 0f, inaccuracy 0f,
        # ammoPerShot 1, consumeAmmoOnce true
        # (Turret.java:49/:51/:58/:64/:76); the per-def duo
        # overrides are range 160, rotateSpeed 10, reload 20,
        # shootCone 15, shootY 3, inaccuracy 2
        # (Blocks.java:3257-3324), `shoot = new
        # ShootAlternate(3.5f);` with barrels 2
        # (ShootAlternate.java:8), and ammo copper/graphite/
        # silicon with reloadMultiplier 1.0 (BulletType
        # default, BulletType.java:97)/0.8/1.5 and rangeChange
        # 0 (BulletType default, BulletType.java:157)/16/0.
        # The result is a 10-key dict: `rotation` (after
        # moveToward, unchanged when there is no valid
        # target), `reload_counter` (charged and capped
        # every tick, modulo on a shot), `dest` (the angle
        # to the predicted target position, null without a
        # valid target), `shot` (whether the aim + range +
        # reloaded + not-charging + warmed-up gate fired),
        # `target_pos` (the predicted position dict, null
        # without a valid target), `total_ammo_after` (after
        # the one useAmmo, unchanged when no shot or
        # cheating), `ammo_entries_after` (the stacks after
        # the one useAmmo), `shoot_event` (the bullet-origin
        # dict -- `bulletX = x + Angles.trnsx(rotation - 90,
        # shootX, shootY),`, Turret.java:744 -- plus rotation
        # and the barrel, null when no shot), `barrel_counter
        # _after` (barrelCounter + 1 on a shot, unchanged
        # otherwise), and `was_shooting` (whether the shoot
        # gate fired this tick). The bullet() spawn detail
        # (inaccuracy random, lifeScl, effects/sound,
        # recoil/heat/totalShots, Turret.java:776-812),
        # findTarget/validateTarget (Units.invalidateTarget),
        # the warmup lerp advance (Turret.java:502-515), and
        # queuedBullets when shotDelay > 0 are NOT this slice
        # -- they wait for their own slices.
        self.assertIn('static func source_item_turret_aim_shoot_state(frame: Dictionary, target: Variant, target_valid: bool, team_id: int, x: float, y: float, delta: float, potential_efficiency: float, shoot_warmup: float, charging: bool, ammo_entries: Array, total_ammo: int, barrel_counter: int, range: float, rotate_speed: float, reload: float, shoot_cone: float, shoot_x: float, shoot_y: float, inaccuracy: float, ammo_per_shot: int, consume_ammo_once: bool, reload_multiplier: float, range_change: float, bullet_speed: float, predict_target: bool, min_warmup: float, always_shooting: bool, cheating: bool, base_reload_speed: float) -> Dictionary:', item_turret)
        self.assertIn('var rotation: float = float(frame.get("rotation", 90.0))', item_turret)
        self.assertIn('var reload_counter: float = float(frame.get("reload_counter", 0.0))', item_turret)
        self.assertIn('reload_counter += delta * ammo_reload_multiplier * base_reload_speed', item_turret)
        self.assertIn('reload_counter = minf(reload_counter, reload)', item_turret)
        self.assertIn('if target == null or not (target is Dictionary) or not target_valid:', item_turret)
        self.assertIn('if predict_target and bullet_speed >= 0.01:', item_turret)
        self.assertIn('var disc: float = b * b - 4.0 * a * c', item_turret)
        self.assertIn('var dest: float = fmod(rad_to_deg(atan2(float(target_pos.get("x", 0.0)) - x, float(target_pos.get("y", 0.0)) - y)), 360.0)', item_turret)
        self.assertIn('rotation = _move_toward_angle(rotation, dest, rotate_speed * delta * potential_efficiency)', item_turret)
        self.assertIn('if _angle_dist(rotation, dest) < shoot_cone and can_shoot:', item_turret)
        self.assertIn('if reload_counter >= reload and not charging and shoot_warmup >= min_warmup:', item_turret)
        self.assertIn('reload_counter = fmod(reload_counter, reload)', item_turret)
        self.assertIn('if not cheating:', item_turret)
        self.assertIn('entry["amount"] = int(entry.get("amount", 0)) - ammo_per_shot', item_turret)
        self.assertIn('if int(entry.get("amount", 0)) <= 0:', item_turret)
        self.assertIn('total_ammo_after = maxi(total_ammo - ammo_per_shot, 0)', item_turret)
        self.assertIn('return {"rotation": rotation, "reload_counter": reload_counter, "dest": dest, "shot": shot, "target_pos": target_pos, "total_ammo_after": total_ammo_after, "ammo_entries_after": ammo_entries_after, "shoot_event": shoot_event, "barrel_counter_after": barrel_counter_after, "was_shooting": was_shooting}', item_turret)
        self.assertIn('canShoot = within(target, range() + (target instanceof Sized hb ? hb.hitSize()/1.9f : 0f));', item_turret)
        self.assertIn('if(!alwaysShooting && Angles.angleDist(rotation, targetRot) < shootCone && canShoot){', item_turret)
        self.assertIn('rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);', item_turret)
        self.assertIn('reloadCounter += delta() * ammoReloadMultiplier() * baseReloadSpeed();', item_turret)
        self.assertIn('reloadCounter = Math.min(reloadCounter, reload);', item_turret)
        self.assertIn('if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', item_turret)
        self.assertIn('reloadCounter %= reload;', item_turret)
        self.assertIn('targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', item_turret)
        self.assertIn('if(predictTarget && bullet.speed >= 0.01f){', item_turret)
        self.assertIn('float targetRot = angleTo(targetPos);', item_turret)
        self.assertIn('targetPosition(target);', item_turret)
        self.assertIn('if(Float.isNaN(rotation)) rotation = 0;', item_turret)
        self.assertIn('if(!validateTarget()) target = null;', item_turret)
        self.assertIn('wasShooting = false;', item_turret)
        self.assertIn('wasShooting = true;', item_turret)
        self.assertIn('if(cheating()) return peekAmmo();', item_turret)
        self.assertIn('entry.amount -= ammoPerShot;', item_turret)
        self.assertIn('if(entry.amount <= 0) ammo.pop();', item_turret)
        self.assertIn('totalAmmo -= ammoPerShot;', item_turret)
        self.assertIn('totalAmmo = Math.max(totalAmmo, 0);', item_turret)
        self.assertIn('return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', item_turret)
        self.assertIn('return queuedBullets > 0 && shoot.firstShotDelay > 0;', item_turret)
        self.assertIn('bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),', item_turret)
        self.assertIn('}, () -> barrelCounter++);', item_turret)
        self.assertIn('return range + peekAmmo().rangeChange;', item_turret)
        self.assertIn('public float rotation = 90;', item_turret)
        self.assertIn('public float reloadCounter;', item_turret)
        self.assertIn('public int ammoPerShot = 1;', item_turret)
        self.assertIn('public boolean consumeAmmoOnce = true;', item_turret)
        self.assertIn('public float shootCone = 8f;', item_turret)
        self.assertIn('public float minWarmup = 0f;', item_turret)
        self.assertIn('public boolean alwaysShooting = false;', item_turret)
        self.assertIn('public boolean predictTarget = true;', item_turret)
        self.assertIn('public boolean moveWhileCharging = true;', item_turret)
        self.assertIn('public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;', item_turret)
        self.assertIn('range = 160;', item_turret)
        self.assertIn('rotateSpeed = 10f;', item_turret)
        self.assertIn('reload = 20f;', item_turret)
        self.assertIn('shootCone = 15f;', item_turret)
        self.assertIn('shootY = 3f;', item_turret)
        self.assertIn('inaccuracy = 2f;', item_turret)
        self.assertIn('shoot = new ShootAlternate(3.5f);', item_turret)
        self.assertIn('reloadMultiplier = 0.8f;', item_turret)
        self.assertIn('rangeChange = 16f;', item_turret)
        self.assertIn('reloadMultiplier = 1.5f;', item_turret)
        self.assertIn('return angleDist(a, b) <= margin;', item_turret)
        self.assertIn('if(Math.abs(angleDist(angle, to)) < speed) return to;', item_turret)
        self.assertIn('float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', item_turret)
        self.assertIn('return Angles.angle(getX(), getY(), other.getX(), other.getY());', item_turret)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', item_turret)
        self.assertIn('public float reloadMultiplier = 1f;', item_turret)
        self.assertIn('public float rangeChange = 0f;', item_turret)
        self.assertIn('public float speed = 1f;', item_turret)
        self.assertIn('public int barrels = 2;', item_turret)
        self.assertIn('float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;', item_turret)
        self.assertIn('public int shots = 1;', item_turret)
        self.assertIn('public float firstShotDelay = 0;', item_turret)
        self.assertIn('float a = dstvx * dstvx + dstvy * dstvy - v * v;', item_turret)
        self.assertIn('float b = 2 * (dstvx * tx + dstvy * ty);', item_turret)
        self.assertIn('float c = tx * tx + ty * ty;', item_turret)
        self.assertIn('float disc = b * b - 4 * a * c;', item_turret)
        self.assertIn('private static Vec2 quad(float a, float b, float c){', item_turret)
        self.assertIn('return Time.delta * timeScale;', item_turret)
        self.assertIn('return moveWhileCharging || !charging();', item_turret)
        self.assertIn('return efficiency;', item_turret)
        self.assertIn('return shootWarmup;', item_turret)
        self.assertIn('public class ItemTurret extends Turret{', item_turret)
        self.assertIn('if(shouldTurn()){', item_turret)
        self.assertIn('turnToTarget(targetRot);', item_turret)
        self.assertIn('if(consumeAmmoOnce){', item_turret)
        self.assertIn('useAmmo();', item_turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), guarded on block `duo`:
        # it calls the new pure function with the per-def duo
        # values (range 160 / rotateSpeed 10 / reload 20 /
        # shootCone 15) and stamps rotation / reload_counter
        # back onto the frame every tick.
        driver = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('source_item_turret_build_state.source_item_turret_aim_shoot_state(frame, frame.get("target", null),', driver)
        self.assertIn('block_id == "duo"', driver)
        self.assertIn('160.0, 10.0, 20.0, 15.0', driver)
        self.assertIn('frame["rotation"] = aim.get("rotation", 90.0)', driver)
        self.assertIn('frame["reload_counter"] = aim.get("reload_counter", 0.0)', driver)
        # The proof's keys drive the aim/shoot through the real
        # driver (rotation turns toward the predicted target /
        # no rotation without a target / out-of-range targets
        # ignored / reload caps at reload and the shot fires
        # only inside the cone once reloaded / the shot
        # consumes exactly one ammo / the shoot event carries
        # the bullet origin / Predict.intercept leads a moving
        # target / no shot while charging or below minWarmup).
        # There are no bullet-spawn / findTarget / warmup /
        # queuedBullets keys: those wait for their own slices.
        proof = ITEM_TURRET_AIM_SHOOT_PROOF.read_text(encoding='utf-8')
        for key in [
            'aim_rotates_toward_target',
            'aim_no_rotation_without_target',
            'aim_ignores_out_of_range_target',
            'reload_caps_and_shoots_in_cone',
            'shoot_consumes_one_ammo',
            'shoot_event_carries_bullet_origin',
            'predict_intercept_leads_moving_target',
            'no_shoot_when_charging_or_warmup_low',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_item_turret_aim_shoot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemTurretAimShootProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_TURRET_AIM_SHOOT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'aim_rotates_toward_target',
            'aim_no_rotation_without_target',
            'aim_ignores_out_of_range_target',
            'reload_caps_and_shoots_in_cone',
            'shoot_consumes_one_ammo',
            'shoot_event_carries_bullet_origin',
            'predict_intercept_leads_moving_target',
            'no_shoot_when_charging_or_warmup_low',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
