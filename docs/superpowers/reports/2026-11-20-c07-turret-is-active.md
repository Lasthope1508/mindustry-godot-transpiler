# Báo cáo — N2280 Turret isActive() derivation (C07) [DONE + PUSHED]

Ngày: 2026-11-20 ~12:0x +07 (GREEN), gate xong 13:21 +07, push lượt cron 13:30.

## Trạng thái

- N2279 DONE + PUSHED (origin/main 2e1267ac). Không có gì thay đổi về N2279.
- N2280 DONE + PUSHED (slice d523d6f6, docs a9b603ae, GOAL c83ddd9a, status TBD): Turret isActive() derivation — `public boolean isActive(){ return (target != null || wasShooting) && enabled && activationTimer <= 0; }` (Turret.java:449-450 — hiệu chỉnh: handoff N2279 ghi :448-450, grep trên đĩa cho method ở :449, return ở :450) — nay activation_timer đã có live input (N2279 stamp); các clause còn lại (has_target/was_shooting/enabled) đều đã live trên frame; chỉ LaserTurret tiêu thụ isActive() trong Java, duo không có consumer — stamp-only như N2274–N2276. Gate xác minh độc lập từ log: Ran 6213, failures=230, skipped=5 — toàn Godot-absent (230 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR).

## Làm được lượt này (GREEN)

- 1 pure function `source_turret_is_active_state` (4 params has_target, was_shooting, enabled, activation_timer; 1 key: is_active) trong SourceTurretBuildState.gd:654 — Java :450 verbatim (`target != null` map sang `has_target`, tiền lệ N2277), ngay SAU `source_turret_activation_timer_state` (isActive() tiêu thụ clause `activationTimer <= 0` mà N2279 vừa stamp), trước `source_turret_heat_req_state`.
- Driver tick trong `source_turret_tick_buildings_state` (:1650-1651), ngay SAU stamp `frame["was_shooting"]` (:1602), trước khối `if shot`, stamp `frame["is_active"]` từ `bool(frame.get("has_target", false))`, `bool(frame.get("was_shooting", false))`, `bool(frame.get("enabled", true))`, `float(frame.get("activation_timer", 0.0))` (defaults = field defaults: BuildingComp.java:77 enabled true, BaseTurret.java:115 activationTimer 0).
- Snapshot semantics (khác thứ tự Java một tick, đã ghi rõ trong scope + comment driver): is_active stamp SAU aim call, khi mọi input đều là giá trị cuối tick này — frame sau một driver tick là observable tự nhất quán cho consumer tương lai (LaserTurret shouldConsume); trong Java shouldConsume chạy ở updateConsumption TRƯỚC updateTile (BuildingComp.java:2274 vs :2277) nên lời gọi live thấy wasShooting/target của tick trước — chênh một tick này DEFER cho slice consumer LaserTurret.
- KHÔNG rewire consumer nào: duo không tiêu thụ isActive(); LaserTurret shouldConsume (`bullets.any() || isActive()`) cần `bullets` live list — chưa có trong port.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07TurretIsActiveProof.json — GREEN ~12:0x +07). Key `is_active_target_and_timer_stamped_to_frame` chứng minh driver stamp live (set target + has_target true → tick → true; rồi set activation_timer 120.0 → tick → false, timer ~119.983).
- `register_c07_turret_is_active.py --verify`: 10/10 exprs present. SSOT đo từ đĩa: 11657/1730/1664/3119 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 207, contracts 206. Lưu ý: MEMORY.md ghi schemas 3117 là số của N2279; đếm lại từ đĩa sau GREEN cho 3119 (scope ban đầu ghi +1 schemas là sai, đã sửa thành +2 — mỗi pure function mới thêm cả _input và _result schema, như N2279).

## Test xanh/đỏ

- Xanh: targeted 4/4 (19 subtests, 15.76s, Godot trên PATH); neighbours 187 passed (605.94s, log `hidden_files/n2280-neighbours.log`); wiring 32 tests OK một batch (Ran 32 in 125.888s, log `hidden_files/n2280-wiring.log`, không flake); `git diff --check` OK.
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2280-gate.log`, chain log `hidden_files/n2280-chain.log`, lần chạy hoàn thành GATE-START 06:02:43Z, GATE-EXIT 1 06:21:48Z — các lần trước chết: GATE-EXIT 143 06:02:33Z sau VM restart / worker launch): Ran 6213 in 1144.274s, failures=230, skipped=5, errors=0 — toàn Godot-absent (+4 tests / +1 failure so với gate N2279, đúng 4 test mới; +1 failure là test reference-graph của chính N2280).
- Đỏ: chỉ 230 test Godot-absent trong gate (môi trường gate không có Godot trên PATH theo thiết kế chuỗi — đúng mẫu mọi slice trước; chain script reset PATH không gồm godot-bin). Xác minh độc lập: 230 dòng `FAIL:` = 230 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR (grep `ERROR` case-sensitive = 0; các hit case-insensitive đều nằm trong chuỗi `AssertionError`).

## Blocker

- Không có blocker. Gate chạy trọn vẹn một lần từ main thread (lần chạy hoàn thành 06:02:43Z–06:21:48Z), 1144.274s.

## Bước tiếp theo

- Push N2280 lên origin main lượt cron 13:30 (slice d523d6f6 đã DONE, đủ điều kiện).
- Slice tiếp theo: N2281 — chọn từ deferred list (calculateHeat vẫn BLOCKED; shootp live wiring cần logic executor; findTarget BLOCKED; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list).
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-is-active-handoff.md.
