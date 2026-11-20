# Báo cáo — N2277 Turret isShooting state (C07) [DONE]

Ngày: 2026-11-20 ~08:3x +07 (GREEN), gate xong 09:21 +07, push lượt cron 09:30.

## Trạng thái

- N2276 DONE + PUSHED (origin/main 5f0f72c0). Không có gì thay đổi về N2276.
- N2277 DONE (slice 23b993d8, chờ push lượt cron 09:30): Turret isShooting — cờ `isShooting` ở đầu `TurretBuild.updateTile()` (Turret.java:492) mà N2253 mới fold inline làm arg của warmup call, nay có pure function standalone + driver tick stamp `frame["is_shooting"]`, warmup call rewire đọc frame thay vì recompute. Gate xác minh độc lập từ log: Ran 6201, failures=227, skipped=5 — toàn Godot-absent (227 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR).

## Làm được lượt này (GREEN)

- 1 pure function `source_turret_is_shooting_state` (6 params always_shooting/is_player/player_is_shooting/logic_controlled/logic_shooting/has_target, 1 key: is_shooting) trong SourceTurretBuildState.gd:162 — ternary Java nguyên văn, ngay TRƯỚC `source_turret_warmup_state` (mirror thứ tự Java :492 trước :502).
- Driver tick trong `source_turret_tick_buildings_state` (:1310-1311), ngay SAU block validateTarget và TRƯỚC fold efficiency N2265 (đúng thứ tự Java :491 validate, :492 isShooting), stamp frame["is_shooting"]; `logicControlled()` derive LIVE từ `logic_control_time` của tick TRƯỚC (tick decay N2261 chạy sau; cùng precedent với N2265).
- Warmup call (:1336) rewire đọc `bool(frame.get("is_shooting", false))` thay vì recompute `has_target and validate.valid` inline — giá trị giống hệt với mọi frame duo hiện có; với frame logic-controlled giá trị mới là giá trị Java ĐÚNG (logicShooting, không phải target != null). Rewire làm stale 1 assert trong test_c07_turret_warmup — đã fix assert theo dòng rewire.
- Proof 5 keys: matches:true, 8/8 true (đọc trực tiếp từ C07TurretIsShootingProof.json — GREEN ~08:3x +07). Key `is_shooting_logic_live` chứng minh derivation logicControlled live từ logic_control_time (120.0 + logic_shooting true, no target → frame is_shooting true).
- `register_c07_turret_is_shooting.py --verify`: 13/13 exprs present. SSOT đo từ đĩa: 11653/1727/1661/3113 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 204, contracts 203.

## Test xanh/đỏ

- Xanh: targeted 4/4 (18 subtests, 17.64s); neighbours 174 passed (556.35s) + 1 stale assert đã fix, warmup + targeted chạy lại độc lập lượt 09:30 8/8 (74 subtests, 32.94s, Godot trên PATH); wiring 32/32 OK (124.789s); `git diff --check` OK.
- Gate (log full-suite-n2277-gate.log, chuỗi n2277-gate-only-main.sh launch từ main thread; GATE-START 01:47:54Z rồi 02:03:02Z — lần chạy trọn vẹn là lần 2, GATE-EXIT 1 02:21:51Z): Ran 6201 in 1127.323s, failures=227, skipped=5, errors=0 — toàn Godot-absent (+4 tests / +1 failure so với gate N2276, đúng 4 test mới; +1 failure là test reference-graph của chính N2277).
- Đỏ: chỉ 227 test Godot-absent trong gate (môi trường gate không có Godot trên PATH theo thiết kế chuỗi — đúng mẫu mọi slice trước; chain script reset PATH không gồm godot-bin).

## Blocker

- Không có blocker. Gate lần đầu chết do VM restart (log partial full-suite-n2277-gate-partial-vm-restart.log); lần 2 chạy trọn vẹn 1127.323s.

## Bước tiếp theo

- Push N2277 lên origin main lượt cron 09:30 (slice TBD đã DONE, đủ điều kiện).
- Slice tiếp theo: chọn từ deferred list (calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; các def ItemTurret khác ngoài duo) — lượt cron sau.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-is-shooting-handoff.md.
