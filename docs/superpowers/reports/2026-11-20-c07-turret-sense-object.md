# Báo cáo — N2506 Turret senseObject() (C07) [DONE + PUSHED]

Ngày: 2026-11-20 ~20:05 +07 (GREEN), gate xong 21:05:31 +07, push ~21:2x +07.

## Trạng thái

- N2284 DONE + PUSHED (origin/main 6c18436d).
- N2506 DONE + PUSHED (slice 51258c1e, docs db59b8cd, GOAL ac693c14, status e0d09415, hashes TBD): Turret senseObject() — `public Object senseObject(LAccess sensor){ return switch(sensor){ case type -> block; case firstItem -> items == null ? null : items.first(); case config -> block.configSenseable() ? config() : null; case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null; default -> noSensed; }; }` (BuildingComp.java:2128-2136) — 4 legs + default cho duo: type → block_id "duo" (Blocks.java:3257); firstItem → param `first_item` ("" = null), duo hasItems=true (ItemTurret.java:28) nên items non-null; config → constant null (duo không đăng ký `config(...)` nào → `configSenseable()` false, Block.java:809-812; base `config()` null, BuildingComp.java:2024); payloadType → constant null (base `getPayload()` null, BuildingComp.java:984-985, không override ở turret); default → `noSensed` sentinel (Senseable.java:6), logic fallback sang numeric `sense()` (LExecutor.java:697-699). KHÔNG có driver tick (senseObject là logic read, tiền lệ N2206/N2208/N2223/N2283/N2284).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_turret_sense_object_state` (3 params sensor, block_id, first_item; 3 keys: handled, sense_value, is_no_sensed) trong SourceTurretBuildState.gd:537, ngay SAU `source_building_comp_sense_state` (:313), TRƯỚC `source_turret_progress_state` (:566) (mirror Java order — BuildingComp.senseObject :2128-2136 ngay sau sense :2093-2126).
- KHÔNG có driver tick: senseObject là logic read; logic-processor dispatch hook là slice riêng sau.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07TurretSenseObjectProof.json — GREEN ~20:05 +07). 6 key semantic: type duo, firstItem copper, firstItem none ("" → null), config null, payloadType null, unknown sensor → noSensed (handled false, is_no_sensed true).
- `register_c07_turret_sense_object.py --verify`: 32/32 exprs present (26 exact + 3 input + 3 output, re-run độc lập lượt cron 21:15 +07, exit 0). SSOT đo từ đĩa: 11668/1735/1669/3129 (symbols +3, Done +1, contracts +1, schemas +2); comp slices 559, contracts 463; defense slices 210, contracts 209 không đổi (N2506 route comp shard theo java_source BuildingComp.java — tiền lệ N2267/N2284). Đúng kỳ vọng scope.
- Số slice N2506, KHÔNG phải N2285: N2285–N2505 đã có người dùng trên các branch khác (pump/bridge/drill/write-back + merge-wave line `codex/godot-all-debt-20261119`, KHÔNG nằm trên main; `git log --all` max N2505, không có N2506 ở đâu). Lấy N2285 sẽ đụng branch `slice/N2285-pump-dump-liquid` khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (72 subtests, 19.11s re-run độc lập lượt cron 21:15 +07, Godot trên PATH); neighbours 207 passed (684.99s, 20:06:52–20:18:18Z, exit 0, log hidden_files/n2506-neighbours.log); wiring 32 tests OK trong một batch (Ran 32 in 123.765s, không flake, log hidden_files/n2506-wiring.log); `git diff --check` OK.
- Gate: xong — main-thread GATE-START 13:45:49Z, GATE-EXIT 1 14:05:31Z (log full-suite-n2506-gate.log, chain log hidden_files/n2506-chain.log; hai launch trước 13:31:13Z và 13:35:06Z chết không EXIT — partial log full-suite-n2506-gate-partial-2worker-runs.log, worker-launch). Ran 6233 trong 1179.933s, failures=235, skipped=5 — xác minh độc lập: 235 FAIL = 235 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2284).
- Đỏ: không có test đỏ ngoài 235 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker.

## Bước tiếp theo

- Push N2506 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284).
- Slice tiếp theo: chọn từ deferred list — ứng viên đầu: logic-processor dispatch hook (LExecutor sense → turret sense → super.sense → senseObject fallback); dead/health/totalItems/camera* legs (khi có live input); powerNet* graph legs. calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-sense-object-handoff.md.
