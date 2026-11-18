# Handoff — N2252 ItemTurret bullet() spawn (C07) [GREEN — chờ gate + push]

## Status: DONE + PUSHED (2026-11-19 ~01:5x +07, lượt cron 01:45) — slice `3a846b15`, main `75d273eb`. Targeted 4/4 + family 116/116 + wiring 32/32 + proof matches:true 11/11 + gate 3 Ran 6101, failures=202 toàn Godot-absent (đã xác minh độc lập).

- Targeted **4/4, 96 subtests, 16.90s** (PATH += ~/workspace/godot-bin): registration / input-evidence (87/87 exprs) / behavior / reference-graph + proof.
- Family `-k item_turret`: **116 passed, 317 subtests, 53.96s, exit 0** (log `n2252-family.log`) — 111 cũ + 4 mới N2252 + 1 flake N2251 nay pass trong batch, 0 flake.
- Wiring **32/32, 250 subtests, 126.33s, exit 0** (9 module chuẩn N2184, log `n2252-wiring.log`).
- Proof `C07ItemTurretBulletSpawnProof.json`: `matches:true`, 11/11 true (8 semantic keys + registry_valid + one_headquarter_per_ssot + matches).
- SSOT đo từ đĩa sau register: symbols **11600** (+11 đúng kỳ vọng), Done **1702** (+1), contracts **1636** (+1), schemas **3063** (+2 — 2 schema entries input+result, theo đúng register docstring); defense shard slices **181**, contracts **180**. `git diff --check` CLEAN (kiểm tra trước khi docs).
- Register `--verify` **87/87 exprs present** (58 EXACT_EXPRS + 18 input + 11 output), chạy trước GREEN.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống trước mọi lần chạy; ps sạch (không còn pytest/unittest/Godot) trước khi launch neighbours.

## Scope (đã khóa, xác minh từ đĩa — xem `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2252-item-turret-bullet-spawn-scope.md`)

- Slice bullet() spawn cho duo: N2250 chỉ tính `shoot_event` (bullet_x/bullet_y/rotation/barrel) rồi stamp lên frame (`SourceTurretBuildState.gd:324`), CHƯA có ai tiêu thụ nó để spawn đạn live. N2252 nối `shoot_event` → `game["bullets"]` qua spawn infra đã có, theo đúng `TurretBuild.bullet()` (Turret.java:779-801).
- `handleBullet` là no-op ở TurretBuild (Turret.java:818-820) → spawn = `type.create(...)` + append live dict, không có bước trung gian.
- Hoãn sang slice sau: effects/sound (`shootEffect`/`smokeEffect`/`shootSound`/`ammoUseEffect`, Turret.java:792-800 — Fx/Sounds chưa trong phạm vi port), recoil/heat/totalShots, `queuedBullets` khi `shotDelay > 0` (duo firstShotDelay = 0, shotDelay = 0 → delay = 0, bullet() gọi ngay, không queue), `findTarget` (vẫn BLOCKED — cần live entity scan), các def ItemTurret khác ngoài duo.

## Java evidence (đã xác minh từ đĩa)

- `Turret.java:742-777` — `shoot(BulletType)`: bulletX/bulletY ở :744-746 (đã phủ N2250 trong shoot_event); pattern = type.shootPattern ?? shoot (:752); `pattern.shoot(barrelCounter, handler, () -> barrelCounter++)` (:754); delay > 0 mới queue (:759-766), delay = 0 → `bullet(...)` ngay (:768); `consumeAmmoOnce` → `useAmmo()` (:774-776, đã phủ N2250).
- `ShootAlternate.java:31-37` — `shoot(totalShots, handler, barrelIncrementer)`: shots = 1 (ShootPattern.java:9); `index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f`; `handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i)`. Duo: barrels = 2, spread = 3.5 (Blocks.java:3293), barrelOffset = 0, mirror = false → index = (barrelCounter % 2) - 0.5 = ±0.5 → xOffset = ±1.75.
- PIN MỞ ĐÃ ĐÓNG từ đĩa (lượt cron 00:45): `Mathf.sign(boolean b)` = `return b ? 1 : -1;` (arc-upstream/arc-core/src/arc/math/Mathf.java:203-205) → sign(false) = -1 → -sign(false) = +1 → xOffset = index × 3.5: barrel 0 (index -0.5) → -1.75, barrel 1 (index +0.5) → +1.75.
- `Turret.java:779-790` — `bullet(type, xOffset, yOffset, angleOffset, mover)`: `queuedBullets--` (:780); `xSpread = Mathf.range(xRand)` (:782); `bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)` (:783-784, yOffset = 0 với ShootAlternate); `shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy)` (:786, angleOffset = 0 với ShootAlternate); `lifeScl = type.scaleLife ? clamp(...) : 1f` (:787); `type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y)` (:790).
- Class defaults (Turret.java:60/62/68): `velocityRnd = 0f` → velocity factor = 1.0; `scaleLifetimeOffset = 0f`; `xRand = 0f` → xSpread = 0 với duo (vẫn nhận làm param để def sau dùng).
- `BulletType.java:43/93/141`: `hitSize = 4` (N2247 đã pin), `inaccuracy = 0f` (type inaccuracy), `scaleLife` boolean default false → lifeScl = 1 với mọi đạn duo (không set scaleLife).
- Duo ammo (Blocks.java:3257-3291 + catalog `content_registry.json` entry duo, đã đọc): copper BasicBulletType(2.5, 9) lifetime 60, graphite (3.5, 18) lifetime 60, silicon (3, 12, homingPower 0.2) lifetime 60. Catalog ammo entries đã mang `damage`/`speed`/`lifetime` (copper damage 9 / speed 2.5 / lifetime 70.0 — lifetime catalog đã quy đổi theo range/speed, KHÔNG bằng 60 Java; driver lấy lifetime từ ammo_data như đã lấy speed/reloadMultiplier, không hardcode 60). Homing của silicon (homingPower) KHÔNG thuộc bullet() spawn — slice BulletType update riêng sau này.
- `Turret.java:599` nhắc lại: shoot gate STRICT `< shootCone` — đã phủ N2250, N2252 không tính lại gate.

## Thiết kế slice (đã khóa ở RED, test đã pin)

- 1 pure function `source_item_turret_bullet_spawn_state` (18 params, 11 result keys: bullet_x, bullet_y, shoot_angle, x_offset, velocity, speed, damage, hit_size, lifetime_remaining, life_scl, barrel) trong `SourceItemTurretBuildState.gd` (ngay trước `source_item_turret_aim_shoot_state`).
- Công thức: `index = float((barrel_counter + barrel_offset) % barrels) - float(barrels - 1) / 2.0`; `mirror_factor = -1.0 if mirror else 1.0` (= -sign(mirror)); `x_offset = index * spread * mirror_factor`; origin suy từ shoot_event + offset xoay (trns tuyến tính, KHÔNG tính lại trnsx/trnsy từ x/y): `bullet_x = shoot_event.bullet_x + (x_offset + x_spread) * cos(deg_to_rad(rotation - 90))`, `bullet_y` tương tự với sin; `shoot_angle = rotation + inaccuracy_draw`; `velocity = Vector2(cos, sin)(shoot_angle) * bullet_speed` (Java per-tick units — bridge ×60 ra live); `life_scl = 1.0`; `lifetime_remaining = bullet_lifetime * life_scl` (ticks — bridge /60 ra live); `barrel = barrel_counter` (pre-increment).
- Random draws (x_spread, inaccuracy_draw) là PARAM do driver/test cấp — game giữ random ±2° faithful Java (boundary user), proof seed draw cố định; pure function không gọi randf.
- 1 dòng driver tick trong nhánh duo (`SourceTurretBuildState.gd`, trong khối `if bool(aim.get("shot", false)):` sau ammo write-back): gọi pure function với barrel pre-increment (`shoot_event["barrel"]`), per-def duo (shootX 0, shootY 3, spread 3.5, barrels 2, barrelOffset 0, mirror false, range 160) và peeked ammo_data (speed/damage/lifetime/hitSize, defaults BulletType 1.0/0.0/40.0/4.0), stamp `frame["bullet_spawn"]`, đưa qua bridge `SourceBulletRuntimeState.spawn_turret_bullet` (writer duy nhất của game["bullets"]); `inaccuracy_draw` mặc định live `randf_range(-2.0, 2.0)`, proof seed cố định qua frame key; `x_spread` mặc định 0.0.
- Lệch layout đã ghi nhận (không sửa test): test pin chuỗi `float(frame.get("x_spread", 0.0)), float(frame.get("inaccuracy_draw", randf_range(-2.0, 2.0))), ` có trailing space — driver viết tiếp arg speed/damage trên CÙNG dòng sau dấu phẩy để chuỗi pin khớp mà không để trailing whitespace (git diff --check sẽ báo trailing whitespace).
- 8 proof keys đã pin trong test: `spawn_barrel_alternates_x_offset` (barrel 0 → xOffset −1.75, barrel 1 → +1.75), `spawn_angle_includes_inaccuracy_draw` (draw seed 1.5 → shoot_angle 91.5), `spawn_position_uses_shoot_y_3` (rotation 90, barrel 0 → (x−1.75, y+3)), `spawn_lifetime_from_ammo_catalog` (copper 70.0 ticks → 70/60 s live), `spawn_damage_copper_9`, `spawn_velocity_matches_speed_2_5` (2.5/tick → 150/s live), `spawn_live_bullet_in_game_bullets` (đúng 4 live bullets, segment control không shot không spawn), `spawn_team_stamp` (live bullet team == frame team_id).

## GREEN (lượt cron 01:00, main thread)

1. Pure function + comment Java lines đã pin trong `SourceItemTurretBuildState.gd`, theo đúng chữ ký test RED đã khóa (18 params, thứ tự như test). ✅
2. 1 dòng driver tick trong `SourceTurretBuildState.gd` (khối shot nhánh duo, sau ammo write-back): gọi pure function, stamp `frame["bullet_spawn"]`, gọi bridge `spawn_turret_bullet(game, origin, target, duo_ammo_data, team_id, shoot_angle)`; thêm preload `source_bullet_runtime_state` ở đầu file. ✅
3. Register main đã chạy → ledger N2252 status done; targeted 4/4 → proof mới `C07ItemTurretBulletSpawnProof` (.gd + .tscn + .json, headless Godot 4.6.2 Linux; 8 proof keys đã pin trong test). ✅ — proof JSON `matches:true`, 11/11 true.
4. Family + wiring: xong — family **116 passed, 317 subtests, 53.96s, exit 0**; wiring **32/32, 250 subtests, 126.33s, exit 0** (9 module chuẩn N2184). Neighbours 152/152 OK.
5. Gate full: gate 3 XANH (trừ Godot-absent) — footer ~01:39, Ran 6101 in 1101.035s, failures=202 (xác minh độc lập lượt cron 01:45: 202/202 FAIL blocks nhắc Godot, 0 ERROR, skipped=5), log `full-suite-n2252-gate3.log`. Gate 1 chết lúc launch (sai cwd, `ImportError: 'tests'`, log `full-suite-n2252-gate.log`); gate 2 chết do VM restart ~01:20 (log `full-suite-n2252-gate2.log` dở dang); gate attempt 2 launch nhầm ~01:46 (PID 4081, chưa đọc gate3.log) đã kill ~01:47. Slice đủ điều kiện commit + push (test + proof + gate xanh).

## Commits

- Slice `3a846b15` / docs `aba09129` / GOAL `24760c3f` (mẫu 5-commit N2251; còn handoff-status + push).

## Bối cảnh N2252 (vì sao là bullet spawn, không phải findTarget)

- findTarget vẫn BLOCKED (cần live entity scan, cùng họ với suppression/targets live list — N2251 handoff). Bullet spawn là mục deferred đầu tiên của N2250 còn làm được ngay: mọi input đã có (shoot_event N2250 + ammo_data catalog + spawn infra), không cần live scan.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
