# Báo cáo — N2278 Turret logicControlled() live derivation (C07) [DONE + PUSHED]

Ngày: 2026-11-20 ~09:53 +07 (GREEN), gate xong 10:37 +07, push lượt cron 10:45.

## Trạng thái

- N2277 DONE + PUSHED (origin/main 9391d5a1). Không có gì thay đổi về N2277.
- N2278 DONE + PUSHED (slice 7d2d024f, docs ee3b1ea1, GOAL 2d770e56, status 36b394a0): Turret logicControlled() — `logicControlled(){ return logicControlTime > 0; }` (Turret.java:445-447) mà driver validate call N2251 đọc với default false vì key `frame["logic_controlled"]` chưa từng được stamp, nay có pure function standalone + driver tick stamp live ngay trước call validate, cứu target logic-controlled khỏi bị clear sai. Gate xác minh độc lập từ log: Ran 6205, failures=228, skipped=5 — toàn Godot-absent (228 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR).

## Làm được lượt này (GREEN)

- 1 pure function `source_turret_logic_controlled_state` (1 param logic_control_time, 1 key: logic_controlled) trong SourceTurretBuildState.gd:162 — Java method nguyên văn, ngay TRƯỚC `source_turret_is_shooting_state` (mirror thứ tự Java :445-447 trước :492).
- Driver tick trong `source_turret_tick_buildings_state` (:1318-1319), ngay TRƯỚC call validate (đúng thứ tự Java :491 validate, :534-536 decay chạy sau), stamp frame["logic_controlled"] từ logic_control_time của tick TRƯỚC (cùng precedent N2277 / N2265).
- Sửa fixture proof N2251: frame 5 của `C07ItemTurretValidateTargetProof.gd` đổi `frames[5]["logic_controlled"] = true` thành `frames[5]["logic_control_time"] = 120.0` (:138) — tick stamp mới sẽ ghi đè flag trực tiếp, nên rescue phải đi từ logic_control_time.
- Proof 5 keys: matches:true, 8/8 true (đọc trực tiếp từ C07TurretLogicControlledProof.json — GREEN ~09:53 +07). Key `logic_controlled_driver_rescues_validate` chứng minh validate call thấy derivation live (dead-Healthc target due east + logic_control_time 120.0 → target kept, aim dest 90).
- `register_c07_turret_logic_controlled.py --verify`: 7/7 exprs present. SSOT đo từ đĩa: 11654/1728/1662/3115 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 205, contracts 204.

## Test xanh/đỏ

- Xanh: targeted 8/8 (N2278 4/4 + N2251 4/4, 54 subtests, 29.62s re-run lượt 10:45, Godot trên PATH); neighbours 177 passed (610.53s) + 2 flake port-7777, re-run riêng lượt 10:45 8/8 (59 subtests, 34.15s, Godot trên PATH, 0 lỗi 7777); wiring 32/32 OK; `git diff --check` OK.
- Gate (log full-suite-n2278-gate.log, chain log hidden_files/n2278-chain.log, GATE-START 03:16:30Z rồi 03:17:37Z — lần chạy trọn vẹn là lần 2, GATE-EXIT 1 03:37:38Z): Ran 6205 in 1200.625s, failures=228, skipped=5, errors=0 — toàn Godot-absent (+4 tests / +1 failure so với gate N2277, đúng 4 test mới; +1 failure là test reference-graph của chính N2278).
- Đỏ: chỉ 228 test Godot-absent trong gate (môi trường gate không có Godot trên PATH theo thiết kế chuỗi — đúng mẫu mọi slice trước; chain script reset PATH không gồm godot-bin). 2 fail neighbours đã xác minh là flake port-7777 (cả 2 proof in `"matches":true`, ERROR duy nhất là `[MCP Runtime] Failed to start server on port 7777: 22`) và đã xanh khi re-run riêng với port trống.

## Blocker

- Không có blocker. Gate lần đầu (03:16:30Z) không chạy trọn vẹn; lần 2 (03:17:37Z) chạy trọn vẹn 1200.625s.

## Bước tiếp theo

- Push N2278 lên origin main lượt cron 10:45 (slice TBD đã DONE, đủ điều kiện).
- Slice tiếp theo: chọn từ deferred list (calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; `controlled()` live wiring cần player unit) — lượt cron sau.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-logic-controlled-handoff.md.
