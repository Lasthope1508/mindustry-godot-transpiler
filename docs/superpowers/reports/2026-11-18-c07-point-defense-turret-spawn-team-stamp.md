# Báo cáo — N2243 PointDefenseTurret spawn-side team stamp for live bullets (C07)

Ngày: 2026-11-18 ~06:45–10:00 +07. Slice trước N2242 DONE + PUSHED (main 7dfdec38, SSOT 11557/1692/1623/3037 — đã xác minh lại từ disk).

## Kết luận scoping

N2243 làm được, đóng GAP do N2242 để lại: live bullets chưa mang team nên N2242 wiring loại mọi live bullet và `should_consume` không sống thật trong live play. Team được luồn sim → bridge → runtime → spawn state, stamp `"team": team_id` lên live bullet dict lúc spawn. Không còn blocker. Đóng deferred entry "PointDefenseTurret spawn-side team stamp" của N2242.

## Java đã pin (đọc từ disk)

- Turret.java:790 `handleBullet(type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y), xOffset, yOffset, shootAngle - rotation);` — turret bắn truyền team của chính nó vào create chain.
- BulletType.java:954 `bullet.team = team;`.
- BulletComp.java:29 `@Import Team team` — mọi live Bullet đều có team.
- Sim đọc team từ placed-block meta: `cell` là Vector2i grid cell, `fire_context`/`shot_context` không mang team; sprite đặt mang meta `origin_cell` (SourcePlacedBlockState.gd:90) + team meta key (SourceBlockGeometry.gd:161, derelict default 0, tiền lệ SourceTurretBuildState.gd:199).

## RED (2026-11-18 ~06:45 +07)

- RED 4 failed (Ran 4 in 0.241s, FAILED (failures=2, errors=2); KeyError 'N2243' ×2 — main-thread re-run).
- Register --verify OK (worker).

## GREEN (2026-11-18 ~06:45–09:19 +07)

- Luồng team (không hàm pure mới — stamp là side-effect trong hàm spawn có sẵn):
  - Sim `SourceTurretSimulationState.gd:288`: đọc team của firing cell từ placed sprite rồi `game.call("spawn_turret_bullet", bullet_origin, target, data, team_id, shoot_angle_degrees)` — team_id bắt buộc, KHÔNG default (default -1 sẽ bị stamp thành team và acquire coi là địch).
  - Bridge `SourceBulletRuntimePortBridge.gd:89` + runtime `SourceBulletRuntimeState.gd:134`: `team_id: int` đứng TRƯỚC param optional `shoot_angle_degrees` (xem Blocker).
  - Spawn `SourceBulletSpawnState.gd:18` (đổi tên, xem Gate 4): `source_spawn_turret_bullet_from_state(game, origin, target, bullet_spawn_state, bullet_texture, team_id: int)` stamp `"team": team_id` lên live bullet dict (:41) — đúng 1 key mới.
  - Pins trong `test_playable.py`: 13 signature pins + pin chuỗi append `:19520` (`"team": team_id`).
- Proof `C07PointDefenseTurretSpawnTeamStampProof.gd` + `.tscn` (mới): 6 key semantic đã pin.
- Register --verify 5/5 exprs present; main() exit 0. SSOT từ disk: **11558/1693/1624/3039** — đúng delta dự kiến (symbols +1, ledger +1, contracts +1 sau rename, schema +2). N2243 trong ledger, status done, godot_owner `SourceBulletSpawnState.source_spawn_turret_bullet_from_state`. Defense shard change: defense_slices 171 → 172, defense_api_contracts 170 → 171.
- Targeted **4/4 OK** (Ran 4 in 17.832s, OK — worker log n2243-targeted-after-fix2.log; sau rename 4/4 trong 37.4s, worker log n2243-rename-verify.log).
- Family PointDefenseTurret **24/24 OK** (6 module: power_status N2151 + target_acquire N2239 + aim_shoot N2240 + should_consume_cooling N2241 + live_bullets_wiring N2242 + spawn_team_stamp N2243 — main-thread run, log n2243-family-after-rename.log).
- Wiring-standard **32/32 OK** (9 module, main-thread run trong 237.41s, log n2243-wiring-after-rename.log).
- Mirror module **17 passed** (14390 subtests, 455.87s — worker log n2243-rename-verify.log).
- **Tổng 60/60 OK** (targeted + family + wiring; mirror là module riêng, không tính vào 60). `git diff --check` sạch (kiểm tra lại trước commit).
- Godot proof headless Linux: scene `C07PointDefenseTurretSpawnTeamStampProof.tscn`, exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretSpawnTeamStampProof.json` (untracked, KHÔNG stage — file ignored): **6 semantic key / 9 trong JSON, matches:true** — spawn_team_stamp_both_turrets_loaded, spawn_team_stamp_carries_firing_turret_team, spawn_team_stamp_first_turret_placed, spawn_team_stamp_second_team_carries_other_team, spawn_team_stamp_second_turret_placed, spawn_team_stamp_wiring_includes_both_with_correct_teams (proof ~09:19 +07, mtime JSON 02:19 UTC).
- Deferred pool: **284 → 284** (resolve 1 entry spawn-side team stamp, +1 nợ proof Windows N2243).
- Lưu ý nhỏ (không chặn): schema keys trong SSOT vẫn mang prefix tên cũ `spawn_turret_bullet_from_state_input/result` (register script truyền prefix cũ làm tên schema) — chỉ là tên key schema + text mô tả, không phải code .gd/.py; mirror test đã PASS.

## Blocker đã sửa (do chính N2243 gây ra — không phải regression)

Chữ ký GREEN đầu tiên đặt `team_id: int` bắt buộc SAU param optional `shoot_angle_degrees := 0.0` — GDScript cấm điều này. Bridge :89 và runtime :134 đều mắc → parse error → cascade "Could not resolve super class inheritance from SourcePortGameFacadePortBridge.gd" → `PortGame.gd` không load → proof scene `_ready` :23 "Nonexistent function 'enter_campaign_playable_slice'" → không có proof JSON, targeted 3/4. Fix (worker 07:15): đưa `team_id` lên TRƯỚC param optional ở bridge :89, runtime :134, call site sim :288, cập nhật pins test_playable.py theo thứ tự mới. Không cho team_id default.

## Gate 1 — regression do chính N2243 (cron 08:00 phát hiện)

Footer: Ran 6065 tests in 1091.502s, FAILED (failures=203, skipped=5, errors=0). Kỳ vọng 193. Chênh +10, toàn bộ do N2243:

- 9 lỗi catalog validator (2 errors): contract mới `SourceBulletSpawnState.spawn_turret_bullet_from_state` (return_type void) không được discovery nhận ra — validator chỉ discover hàm `source_` / `generated_` / `tile_` (`source_symbols.py:_discover_godot_owner_functions`), nên báo 'facade/module function not discovered' + 'void return requires an explicit -> void implementation'. Đó là 8 test power generator/node slice + `test_real_catalog_report_preserves_open_p1_baseline` (2 errors trong report). Đây là contract owner KHÔNG prefix duy nhất trong 1624 contracts.
- 1 lỗi pin cũ trong test_playable.py:19520 — pin chuỗi `bullets.append({...})` KHÔNG có `"team": team_id` (worker chỉ cập nhật 13 signature pins, sót pin này).

Fix (cron 08:0x, KHÔNG đổi game — chỉ test + SSOT đăng ký): gỡ contract N2243 khỏi `source_api_contracts.json` và `defense_api_contracts.json`; pin `:19520` thêm `"team": team_id`; register script `has_contract True → False`. Xác minh sau sửa: 10/10 test lỗi cũ chạy lại OK (Ran 10 in 129.327s); register --verify 5/5; targeted N2243 4/4 OK.

## Gate 2 + Gate 3 — CHẾT giữa chừng (worker-launched)

Gate 2 (PID 9476, launch ~08:12): log đứng ở 3861 byte (3685 dots / 171 F / 5 s), không footer. Gate 3 (PID 10130, launch ~08:17, `nohup setsid`): chết ở ~60% (log 3864 byte, 3688 dots / 171 F / 0 E), không footer. Bài học khẳng định lại: gate launch từ worker/cron session chết giữa chừng NGAY CẢ với `nohup setsid` — chỉ launch từ main thread mới sống được. Logs giữ nguyên làm bằng chứng.

## Gate 4 — ĐÃ XONG, +1 LỖI THẬT (main thread, PID 10490, ~08:2x–08:40)

Footer: Ran 6065 tests in 1095.824s, FAILED (failures=194, skipped=5, errors=0). Phân rã từ log (xác minh trực tiếp): FAIL header 194; `AssertionError: unexpectedly None` 193 (192 plain + 1 `... : Godot required for hydration proof` — vẫn Godot-absent); ERROR 0. Lỗi duy nhất KHÔNG phải Godot-absent: mirror test `test_source_ssot_defense_json_shards_declare_canonical_mirror_contracts` (test_source_symbols.py:1766) — 'SourceBulletSpawnState.spawn_turret_bullet_from_state' có trong defense slices (171 owner) nhưng không còn trong defense contracts (170) sau fix gate 1. Gốc rễ: fix gate 1 sửa 9 lỗi validator nhưng phá bất biến mirror của defense shard; hai test mâu thuẫn nhau với tên hàm không prefix.

Fix (main thread 08:45, worker 09:00 thực hiện, main thread xác minh): pure rename `spawn_turret_bullet_from_state` → `source_spawn_turret_bullet_from_state` (không đổi gameplay) + đăng lại contract (has_contract → True). Đổi: def (SourceBulletSpawnState.gd:18), call site duy nhất (SourceBulletRuntimeState.gd:141), comment (SourcePointDefenseTurretBuildState.gd:449), test pins, register script (SPAWN_OWNER), chạy lại register (SSOT viết lại: contracts 1623 → 1624). Sau rename: validator discover được (prefix `source_`), mirror thấy contract → hết lỗi; slices 171 vs contracts 171 cân bằng. Hai hướng khác đã loại: mở rộng discovery của validator (rủi ro lan rộng), nới mirror test (cấm theo AGENTS.md). Xác minh sau rename: targeted 4/4, family 24/24, wiring 32/32, mirror module 17 passed, proof matches:true — N2243 GREEN 60/60 sau rename.

## Gate 5 — toàn bộ (main thread, PID 4027, ~09:23–09:55 +07)

- Ran **6065** trong 1867.939s, failures=**193**, skipped=5, errors=**0** — cả 193 đều là `AssertionError: unexpectedly None` (Godot-absent; đếm trực tiếp trong log: `unexpectedly None` = 193, `FAIL:` = 193, `ERROR:` = 0, KeyError = 0; trong đó 192 plain + 1 hydration message — vẫn Godot-absent). Mirror test PASS (không còn trong danh sách FAIL). Test reference N2243 nằm trong 193 (gate log Godot-absent như dự kiến). KHÔNG phải regression. Log `tools/mindustry_godot_transpiler/full-suite-n2243-gate5.log` (untracked, KHÔNG stage).
- Đối chiếu footer: Ran 6061 → 6065 (+4 test N2243); failures 192 → 193 (+1 test reference của slice mới, Godot-absent); errors 0 → 0. Khớp đúng dự kiến.
- origin/main không di chuyển trước khi push: kiểm tra bằng fetch trước khi push (xem mục Hashes).

## Môi trường

- Worker 06:45 timeout giữa GREEN (code + register xong, chưa có proof scene); worker 07:00 viết proof scene nhưng targeted 3/4 vì blocker chữ ký; worker 07:15 sửa blocker + targeted 4/4 + proof xanh nhưng timeout trước family/wiring/docs/gate/commit. Gates 2 + 3 do worker launch đều chết giữa chừng. Gate 4 + 5 launch từ main thread, sống tới footer.
- VM clock chạy UTC — file mtime ~02:1x UTC = ~09:1x +07. Port 7777 free khi chạy proof.

## Hashes

- 5-commit xong: slice (hash), docs (hash), GOAL (hash) — đã push lên origin main (main hash).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: suppression live + targets live list vẫn BLOCKED (cần frame plumbing); PointDefenseTurret draw/write/read/setStats/icons rows + live coolant efficiency/trừ liquid/coolEffect + bullet hitSize + live bullet removal. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
