# Báo cáo — N2252 ItemTurret bullet() spawn (C07)

Ngày: 2026-11-19 ~00:35–01:1x +07. Slice trước N2251 DONE + PUSHED (main f9f458d7, SSOT 11589/1701/1635/3061).

## Kết luận scoping

N2252 làm được: slice bullet() spawn cho ItemTurret (duo) — nối `shoot_event` N2250 → đạn live trong `game["bullets"]` qua spawn infra đã có, theo đúng `TurretBuild.bullet()` (Turret.java:779-801). 1 pure function `source_item_turret_bullet_spawn_state` (18 params, 11 keys: bullet_x, bullet_y, shoot_angle, x_offset, velocity, speed, damage, hit_size, lifetime_remaining, life_scl, barrel) trong `SourceItemTurretBuildState.gd:275` + 1 dòng driver tick trong nhánh duo của driver chung `source_turret_tick_buildings_state` (`SourceTurretBuildState.gd:357` gọi pure function, `:363` stamp `frame["bullet_spawn"]`, `:364` gọi bridge `spawn_turret_bullet`). Hoãn sang slice sau: effects/sound (Turret.java:792-800, Fx/Sounds chưa trong phạm vi port), recoil/heat/totalShots (Turret.java:804-812), `queuedBullets` khi shotDelay > 0, scaleLife=true defs, consumeAmmoOnce=false defs, findTarget (vẫn BLOCKED — cần live entity scan), các def ItemTurret khác ngoài duo.

## Java đã pin (đọc từ disk)

- `shoot()` (Turret.java:742-777): `pattern.shoot(barrelCounter, handler, () -> barrelCounter++)` (:754); delay > 0 mới queue (:759-766), delay = 0 → `bullet(...)` ngay (:768); duo firstShotDelay = 0, shotDelay = 0 → queue rỗng.
- `ShootAlternate` (ShootAlternate.java:31-37): `index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f`; `handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i)`. Duo barrels 2, spread 3.5 (Blocks.java:3293), barrelOffset 0, mirror false → index ±0.5 → xOffset ±1.75.
- **PIN MỞ ĐÃ ĐÓNG từ đĩa (lượt cron 00:45)**: `Mathf.sign(boolean b)` = `return b ? 1 : -1;` (arc-upstream/arc-core/src/arc/math/Mathf.java:203-205) → sign(false) = -1 → -sign(false) = +1 → xOffset = index × 3.5: barrel 0 → -1.75, barrel 1 → +1.75.
- `bullet()` (Turret.java:779-790): `queuedBullets--` (:780); `xSpread = Mathf.range(xRand)` (:782, xRand default 0f → 0 với duo); origin trnsx/trnsy (:783-784); `shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy)` (:786, duo inaccuracy 2f, type inaccuracy 0f → draw ±2°); `lifeScl` (:787, scaleLife default false → 1.0); `type.create(...)` (:790, velocityRnd 0f → velocity factor 1.0; `handleBullet` no-op Turret.java:818-820).
- `type.create` (BulletType.java:964/968/971/972): `initVel` = `vel.trns(angle, amount)` (BulletComp.java:329-331, Vec2.trns `set(amount, 0).rotate(angle)`) → velocity = dir(angle) × speed; `lifetime = lifetime * lifetimeScl`; `damage`; `hitSize = 4` (BulletType.java:43).
- Duo ammo (Blocks.java:3257-3291 + catalog `content_registry.json` entry duo): copper BasicBulletType(2.5, 9) / graphite (3.5, 18) / silicon (3, 12), Java lifetime 60f; catalog lifetime đã quy đổi (copper 70.0, graphite 54.57142857142857, silicon 58.333333333333336) — driver lấy từ ammo_data, không hardcode 60. Homing silicon KHÔNG thuộc bullet() spawn.
- Công thức: `index = (barrel_counter + barrel_offset) % barrels - (barrels-1)/2.0`; `mirror_factor = -1.0 if mirror else 1.0`; `x_offset = index * spread * mirror_factor`; origin suy từ shoot_event + offset xoay (trns tuyến tính, KHÔNG tính lại trnsx/trnsy từ x/y); `shoot_angle = rotation + inaccuracy_draw`; `velocity = dir(shoot_angle) * speed` (per-tick — bridge ×60 ra live); `lifetime_remaining = lifetime * lifeScl` (ticks — bridge /60 ra live).

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_item_turret_bullet_spawn.py` (4 tests: registration / input-evidence / behavior / reference-graph) + register script `tools/mindustry_godot_transpiler/register_c07_item_turret_bullet_spawn.py` + proof `C07ItemTurretBulletSpawnProof` (.gd + .tscn).
- Chạy RED (lượt cron 00:45): 4 failed in 1.37s — registration + evidence `KeyError: 'N2252'` (ledger chưa có N2252), behavior `AssertionError` (pure function chưa tồn tại), proof Godot returncode 1 (thiếu .tscn) — đúng kỳ vọng. Register `--verify` **87/87 exprs present** (58 EXACT_EXPRS + 18 input + 11 output).

## GREEN (lượt cron 01:00, main thread)

- Pure function + comment Java lines đã pin trong `SourceItemTurretBuildState.gd:275`, đúng chữ ký test RED đã khóa (18 params, thứ tự như test). Driver tick `SourceTurretBuildState.gd:357-364`: trong khối shot nhánh duo, sau ammo write-back; gọi pure function với barrel pre-increment (`shoot_event["barrel"]`), per-def duo (shootX 0, shootY 3, spread 3.5, barrels 2, barrelOffset 0, mirror false, range 160) và peeked ammo_data (speed/damage/lifetime/hitSize, defaults BulletType 1.0/0.0/40.0/4.0); stamp `frame["bullet_spawn"]`; gọi bridge `spawn_turret_bullet(game, origin, target, duo_ammo_data, team_id, shoot_angle)`; thêm preload `source_bullet_runtime_state` (`SourceTurretBuildState.gd:6`).
- Lệch layout đã ghi nhận (không sửa test): test pin chuỗi `float(frame.get("x_spread", 0.0)), float(frame.get("inaccuracy_draw", randf_range(-2.0, 2.0))), ` có trailing space — driver viết tiếp arg speed/damage trên CÙNG dòng sau dấu phẩy để chuỗi pin khớp mà không để trailing whitespace (`git diff --check` sạch).
- Register script main đã chạy → ledger N2252 status done. SSOT **11589/1701/1635/3061 → 11600/1702/1636/3063** (+11 symbols, +1 Done, +1 contract, +2 schema — đúng kỳ vọng register docstring); defense shard slices 180 → 181, defense_api_contracts 179 → 180.
- Targeted **4/4 OK, 96 subtests, 16.90s** — lượt cron 01:00 (PATH += ~/workspace/godot-bin). Family `-k item_turret`: **116 passed, 317 subtests, 53.96s, exit 0** (111 cũ + 4 mới N2252 + 1 flake N2251 nay pass trong batch, 0 flake). Wiring **32/32, 250 subtests, 126.33s, exit 0** (9 module chuẩn N2184, log `n2252-wiring.log`). Neighbours 152/152 OK.
- Godot proof headless Linux: scene `C07ItemTurretBulletSpawnProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07ItemTurretBulletSpawnProof.json`: **8 keys + matches, 11/11 true, matches:true** — spawn_barrel_alternates_x_offset, spawn_angle_includes_inaccuracy_draw, spawn_position_uses_shoot_y_3, spawn_lifetime_from_ammo_catalog, spawn_damage_copper_9, spawn_velocity_matches_speed_2_5, spawn_live_bullet_in_game_bullets, spawn_team_stamp, registry_valid, one_headquarter_per_ssot.
- `git diff --check` sạch.

## Gate — XANH (trừ Godot-absent), footer về ~01:39 +07 (gate 3, log `tools/mindustry_godot_transpiler/full-suite-n2252-gate3.log`)

- Gate 1 launch ~01:10 chết ngay: `ImportError: Start directory is not importable: 'tests'` — launch sai cwd (từ repo root thay vì `tools/mindustry_godot_transpiler/`), KHÔNG phải lỗi test (log `full-suite-n2252-gate.log`, 972 byte).
- Gate 2 chết ~01:20 do VM restart (log `full-suite-n2252-gate2.log` dở dang, không footer).
- Gate 3 (PID 1743, main thread, đúng cwd): **Ran 6101 tests in 1101.035s — FAILED (failures=202, skipped=5, errors=0)**. Đã xác minh độc lập lượt cron 01:45: 202 FAIL blocks, cả 202 đều nhắc Godot, 0 block không nhắc Godot; distinct AssertionError chỉ có `unexpectedly None` và `unexpectedly None : Godot required for hydration proof` (godot không có trên PATH). Đúng profile kỳ vọng (N2251: 201; N2252 +1 test Godot-dependent → 202). Gate xanh theo chuẩn repo (chỉ fail vì thiếu engine).
- Lượt cron 01:45 launch nhầm gate attempt 2 (PID 4081, ~01:46) vì lúc đó chưa đọc nhật ký 01:30 / gate3.log; đã kill ~01:47 ngay khi thấy footer gate 3 (log `full-suite-n2252-gate-attempt2.log` dở dang, bỏ).
- Slice đủ điều kiện commit + push: targeted + family + wiring + proof + gate đều xanh.

## Môi trường

- Port 7777 trống trước mọi lần chạy, không va chạm agent khác; ps sạch (không còn pytest/unittest/Godot) trước khi launch neighbours và gate.
- javalang 0.13.0 + pytest 9.2.0 còn importable lúc 01:00 (không cần cài lại).
- VM clock chạy UTC — file mtime ~18:0x UTC = ~01:0x +07.

## Hashes

- Slice `3a846b15` / docs `aba09129` / GOAL `24760c3f`.
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: chờ gate footer → xác minh toàn Godot-absent → commit + push N2252 theo mẫu 5-commit → sau N2252: findTarget (vẫn BLOCKED) hoặc family tiếp theo trong backlog; live coolant driver wiring + suppression/targets live list vẫn BLOCKED.
