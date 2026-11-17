import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_AIM_SHOOT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretAimShootProof.gd'


class C07PointDefenseTurretAimShootTests(unittest.TestCase):
    def test_c07_point_defense_turret_aim_shoot_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2240']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state')
        # N2151 wired the power.status live read but deferred the
        # updateTile advance ("No updateTile advance:
        # PointDefenseBuild.updateTile()
        # (PointDefenseTurret.java:62-103, retarget / rotation /
        # reloadCounter / beam effects) waits for its own slice;
        # the proof carries no progress keys"). N2239 did the
        # first half of that advance (the retarget: every
        # retargetTime (5s) the build re-acquires the nearest
        # enemy hittable bullet in the range rect, plus the
        # pooled invalidation). This slice is the second half --
        # the "look at target" aim / rotation / reloadCounter /
        # shoot (PointDefenseTurret.java:76-101): when the
        # target is non-null, within range, on another team,
        # with a non-null hittable type, the build turns toward
        # it (`float dest = angleTo(target);` / `rotation =
        # Angles.moveToward(rotation, dest, rotateSpeed *
        # edelta());`, PointDefenseTurret.java:77-78), charges
        # the reload (`reloadCounter += edelta();`,
        # PointDefenseTurret.java:79), and shoots when aimed and
        # reloaded (`if(Angles.within(rotation, dest, shootCone)
        # && reloadCounter >= reload){`,
        # PointDefenseTurret.java:82), dealing `bulletDamage *
        # state.rules.blockDamage(team)` (subtracting from the
        # target's damage, or removing the target when lethal,
        # PointDefenseTurret.java:83-88) and resetting
        # `reloadCounter = 0` (PointDefenseTurret.java:97).
        # The beam / shoot / hit effects and the shoot sound
        # (PointDefenseTurret.java:90-95) are side effects: the
        # pure function does NOT spawn them, it returns a
        # shoot_event dict (beam origin + rotation + target
        # position) for the driver / proof to verify. One pure
        # function on SourcePointDefenseTurretBuildState.gd,
        # plus one driver tick line that stamps rotation /
        # reload_counter / target damage live (the N2239
        # precedent). Eight new result symbols: rotation +
        # reload_counter + dest + shot + damage_dealt +
        # target_damage_after + target_removed + shoot_event.
        self.assertEqual(
            ledger['N2240']['source_symbols'],
            [
                'source_point_defense_turret_aim_shoot_state_result.rotation',
                'source_point_defense_turret_aim_shoot_state_result.reload_counter',
                'source_point_defense_turret_aim_shoot_state_result.dest',
                'source_point_defense_turret_aim_shoot_state_result.shot',
                'source_point_defense_turret_aim_shoot_state_result.damage_dealt',
                'source_point_defense_turret_aim_shoot_state_result.target_damage_after',
                'source_point_defense_turret_aim_shoot_state_result.target_removed',
                'source_point_defense_turret_aim_shoot_state_result.shoot_event',
            ],
        )
        for name in ledger['N2240']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/game/Rules.java',
                    'arc-core/src/arc/math/Angles.java',
                    'arc-core/src/arc/math/geom/Position.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_aim_shoot_state_result.rotation': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.reload_counter': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.dest': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.shot': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.damage_dealt': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.target_damage_after': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.target_removed': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.shoot_event': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                }[name])
        self.assertEqual(ledger['N2240']['runtime_proof'], '/root/C07PointDefenseTurretAimShootProof')
        self.assertEqual(
            ledger['N2240']['tests'],
            [
                'test_c07_point_defense_turret_aim_shoot_registration',
                'test_all_c07_point_defense_turret_aim_shoot_input_evidence_is_exact',
                'test_point_defense_turret_aim_shoot_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_aim_shoot',
            ],
        )
        self.assertTrue(ledger['N2240']['deferred_exprs'])

    def test_all_c07_point_defense_turret_aim_shoot_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2240']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_aim_shoot_state_result.rotation': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.reload_counter': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.dest': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.shot': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.damage_dealt': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.target_damage_after': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.target_removed': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                    'source_point_defense_turret_aim_shoot_state_result.shoot_event': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_aim_shoot_state',
                }[name])
        slice_sources = {
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
            # Groups.java is build-generated from GroupDefs.java
            # (@GroupDef(value = Bulletc.class, spatial = true,
            # collide = true) G bullet;, GroupDefs.java:9), so
            # it never exists on disk: the on-disk source is
            # GroupDefs.java, not Groups.java. (RED-test fix,
            # N2239: the 23:00 RED listed Groups.java and the
            # evidence test would FileNotFoundError on it.) This
            # slice does not read Groups at all (the target
            # arrives already acquired by N2239), so GroupDefs
            # is not listed either.
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2240']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_aim_shoot_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # The aim/shoot half of PointDefenseBuild.updateTile()
        # (PointDefenseTurret.java:76-101) lives on the
        # point-defense build state, next to the N2239 acquire:
        # the gate (`if(target != null && target.within(this,
        # range) && target.team != team && target.type() != null
        # && target.type().hittable){`,
        # PointDefenseTurret.java:76) requires all five
        # conditions -- a null target, an out-of-range target
        # (Position.within is dst2 < range*range, STRICT <,
        # Position.java:40-46 `return Mathf.dst2(getX(),
        # getY(), x, y) < dst*dst;`), a same-team target, a
        # typeless target, or a non-hittable target leaves
        # rotation and reloadCounter untouched and shoots
        # nothing. Inside the gate the build turns toward the
        # target (`float dest = angleTo(target);` /
        # `rotation = Angles.moveToward(rotation, dest,
        # rotateSpeed * edelta());`,
        # PointDefenseTurret.java:77-78) and charges the reload
        # (`reloadCounter += edelta();`,
        # PointDefenseTurret.java:79). `angleTo` is
        # Position.angleTo -> Angles.angle(x, y, tx, ty)
        # (Position.java:12-14), i.e. `Mathf.atan2(x2 - x, y2 -
        # y) * Mathf.radDeg` normalized to [0, 360) -- atan2(dx,
        # dy), 0 degrees is +Y, the opposite of GDScript's
        # `atan2(y, x)`, so GREEN must write
        # `rad_to_deg(atan2(tx - x, ty - y))`, never Vector2
        # .angle_to. `Angles.moveToward(angle, to, speed)`
        # (Angles.java:38-49) returns `to` outright when
        # `|angleDist| < speed` and otherwise steps +-speed
        # along the shorter arc (angleDist is the min
        # forward/backward distance after mod 360,
        # Angles.java:22-27). `edelta()` is `efficiency *
        # delta()` (BuildingComp.java:1927-1929); the driver
        # passes it precomputed. `rotation` is the float turret
        # rotation, default 90 (`public float rotation = 90;`,
        # BaseTurret.java:114 -- NOT BuildingComp.rotation,
        # the int block rotation, BuildingComp.java:69), and
        # `reloadCounter` is the float on ReloadTurretBuild
        # (`public float reloadCounter;`,
        # ReloadTurret.java:26). Java does NOT clamp
        # reloadCounter here (the clamp lives on the plain
        # TurretBuild, Turret.java:723, which PointDefenseBuild
        # does not extend), so GREEN must not invent a clamp.
        # The shoot gate (`if(Angles.within(rotation, dest,
        # shootCone) && reloadCounter >= reload){`,
        # PointDefenseTurret.java:82) uses `Angles.within(a, b,
        # margin)` = `angleDist(a, b) <= margin`
        # (Angles.java:19-21), i.e. `<=` shootCone. The damage
        # is `float realDamage = bulletDamage *
        # state.rules.blockDamage(team);`
        # (PointDefenseTurret.java:83) with `blockDamage(team)`
        # = `return blockDamageMultiplier *
        # teams.get(team).blockDamageMultiplier;`
        # (Rules.java:299-300) passed in precomputed; the
        # comparison is STRICT `>` (`if(target.damage() >
        # realDamage){`, PointDefenseTurret.java:84) so a
        # target whose damage equals realDamage is removed,
        # not left at 0 (`target.damage(target.damage() -
        # realDamage);`, PointDefenseTurret.java:85, vs
        # `target.remove();`, PointDefenseTurret.java:87).
        # `target.damage()` reads the bullet's remaining-health
        # field (`@Import float x, y, damage, lastX, lastY,
        # time, lifetime;`, BulletComp.java:31) and
        # `target.remove()` is BulletComp.java:83-91. The reset
        # is `reloadCounter = 0;`
        # (PointDefenseTurret.java:97) -- reset-to-0, NOT ` %=
        # reload` (that is the plain Turret, Turret.java:738).
        # The effects and sound (`Tmp.v1.trns(rotation,
        # shootLength);` / `beamEffect.at(x + Tmp.v1.x, y +
        # Tmp.v1.y, rotation, color, new Vec2().set(target));`
        # / `shootEffect.at(x + Tmp.v1.x, y + Tmp.v1.y,
        # rotation, color);` / `hitEffect.at(target.x,
        # target.y, color);` / `shootSound.at(x + Tmp.v1.x, y +
        # Tmp.v1.y, Mathf.random(0.9f, 1.1f));`,
        # PointDefenseTurret.java:90-95) are side effects: the
        # pure function spawns nothing and instead returns a
        # shoot_event dict (beam origin + rotation + target
        # position) for the driver / proof to verify; the sound
        # pitch is random (0.9-1.1) so it is NOT in the event.
        # Class defaults are shootCone 5f, bulletDamage 10f,
        # shootLength 3f (`public float shootCone = 5f;` /
        # `public float bulletDamage = 10f;` /
        # `public float shootLength = 3f;`,
        # PointDefenseTurret.java:31-33) with rotateSpeed 20f
        # and reload 30f from the ctor (`rotateSpeed = 20f;` /
        # `reload = 30f;`, PointDefenseTurret.java:38-39); the
        # segment per-def overrides are range 180f, shootLength
        # 5f, bulletDamage 30f, reload 8f (`range = 180f;` /
        # `shootLength = 5f;` / `bulletDamage = 30f;` /
        # `reload = 8f;`, Blocks.java:3838-3846) -- the pure
        # function takes them all as parameters and the driver
        # passes the per-def values. The result is an 8-key
        # dict: `rotation` (after moveToward, unchanged when
        # the gate fails), `reload_counter` (after += edelta,
        # 0 on a shot, unchanged when the gate fails), `dest`
        # (the angle to the target, null when the gate fails --
        # Java only computes it inside the if), `shot`
        # (whether the within-cone + reloaded gate fired),
        # `damage_dealt` (realDamage on a shot, 0.0 otherwise),
        # `target_damage_after` (remaining damage, 0.0 when
        # removed, unchanged when no shot),
        # `target_removed` (lethal shot), and `shoot_event`
        # (the beam-origin dict on a shot, null otherwise).
        # The coolant updateCooling()
        # (PointDefenseTurret.java:72-74) and shouldConsume()
        # (PointDefenseTurret.java:105-107, `return
        # super.shouldConsume() && target != null;`) and
        # draw/write/read/setStats/icons are NOT this slice --
        # they wait for their own slices.
        self.assertIn('static func source_point_defense_turret_aim_shoot_state(frame: Dictionary, target: Variant, team_id: int, x: float, y: float, range: float, rotate_speed: float, reload: float, shoot_cone: float, bullet_damage: float, block_damage_multiplier: float, edelta: float) -> Dictionary:', point_defense)
        self.assertIn('var rotation: float = float(frame.get("rotation", 90.0))', point_defense)
        self.assertIn('var reload_counter: float = float(frame.get("reload_counter", 0.0))', point_defense)
        self.assertIn('if target == null or not (target is Dictionary):', point_defense)
        self.assertIn('if int(target.get("team", -1)) == team_id:', point_defense)
        self.assertIn('if not bool(target.get("has_type", false)):', point_defense)
        self.assertIn('if not bool(target.get("hittable", false)):', point_defense)
        self.assertIn('if dist2 >= range * range:', point_defense)
        self.assertIn('var dest: float = fmod(rad_to_deg(atan2(float(target.get("x", 0.0)) - x, float(target.get("y", 0.0)) - y)), 360.0)', point_defense)
        self.assertIn('rotation = _move_toward_angle(rotation, dest, rotate_speed * edelta)', point_defense)
        self.assertIn('reload_counter += edelta', point_defense)
        self.assertIn('if _angle_dist(rotation, dest) <= shoot_cone and reload_counter >= reload:', point_defense)
        self.assertIn('var real_damage: float = bullet_damage * block_damage_multiplier', point_defense)
        self.assertIn('if float(target.get("damage", 0.0)) > real_damage:', point_defense)
        self.assertIn('reload_counter = 0.0', point_defense)
        self.assertIn('return {"rotation": rotation, "reload_counter": reload_counter, "dest": dest, "shot": shot, "damage_dealt": damage_dealt, "target_damage_after": target_damage_after, "target_removed": target_removed, "shoot_event": shoot_event}', point_defense)
        self.assertIn('var aim: Dictionary = source_point_defense_turret_aim_shoot_state(frame, frame.get("target", null), team_id, sprite.position.x, sprite.position.y, 180.0, 20.0, 8.0, 5.0, 30.0,', point_defense)
        self.assertIn('frame["rotation"] = aim.get("rotation", 90.0)', point_defense)
        self.assertIn('frame["reload_counter"] = aim.get("reload_counter", 0.0)', point_defense)
        self.assertIn('if(target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable){', point_defense)
        self.assertIn('float dest = angleTo(target);', point_defense)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());', point_defense)
        self.assertIn('reloadCounter += edelta();', point_defense)
        self.assertIn('if(Angles.within(rotation, dest, shootCone) && reloadCounter >= reload){', point_defense)
        self.assertIn('float realDamage = bulletDamage * state.rules.blockDamage(team);', point_defense)
        self.assertIn('if(target.damage() > realDamage){', point_defense)
        self.assertIn('target.damage(target.damage() - realDamage);', point_defense)
        self.assertIn('target.remove();', point_defense)
        self.assertIn('reloadCounter = 0;', point_defense)
        self.assertIn('Tmp.v1.trns(rotation, shootLength);', point_defense)
        self.assertIn('beamEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation, color, new Vec2().set(target));', point_defense)
        self.assertIn('shootSound.at(x + Tmp.v1.x, y + Tmp.v1.y, Mathf.random(0.9f, 1.1f));', point_defense)
        self.assertIn('return angleDist(a, b) <= margin;', point_defense)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', point_defense)
        self.assertIn('return efficiency * delta();', point_defense)
        self.assertIn('return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;', point_defense)
        self.assertIn('public float rotation = 90;', point_defense)
        self.assertIn('public float reloadCounter;', point_defense)
        self.assertIn('public float shootCone = 5f;', point_defense)
        self.assertIn('public float bulletDamage = 10f;', point_defense)
        self.assertIn('public float shootLength = 3f;', point_defense)
        self.assertIn('rotateSpeed = 20f;', point_defense)
        self.assertIn('reload = 30f;', point_defense)
        self.assertIn('range = 180f;', point_defense)
        self.assertIn('bulletDamage = 30f;', point_defense)
        self.assertIn('reload = 8f;', point_defense)
        self.assertIn('shootLength = 5f;', point_defense)
        # The proof's keys drive the aim/shoot through the real
        # driver (rotation turns toward the target / no rotation
        # without a target / out-of-range and same-team targets
        # ignored / reload accumulates and the shot fires only
        # inside the cone once reloaded / the shot deals
        # bulletDamage * blockDamage / a lethal shot removes
        # the target / the shoot event carries the beam origin).
        # There are no coolant / shouldConsume / draw /
        # write-read keys: those wait for their own slices.
        proof = POINT_DEFENSE_AIM_SHOOT_PROOF.read_text(encoding='utf-8')
        for key in [
            'aim_rotates_toward_target',
            'aim_no_rotation_without_target',
            'aim_ignores_out_of_range_target',
            'aim_ignores_same_team_target',
            'reload_accumulates_and_shoots_at_cone',
            'shoot_deals_block_damage',
            'shoot_removes_target_when_lethal',
            'shoot_event_carries_beam_origin',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_aim_shoot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretAimShootProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_AIM_SHOOT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'aim_rotates_toward_target',
            'aim_no_rotation_without_target',
            'aim_ignores_out_of_range_target',
            'aim_ignores_same_team_target',
            'reload_accumulates_and_shoots_at_cone',
            'shoot_deals_block_damage',
            'shoot_removes_target_when_lethal',
            'shoot_event_carries_beam_origin',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
