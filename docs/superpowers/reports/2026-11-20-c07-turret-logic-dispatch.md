# Báo cáo — N2507 Turret logic sense dispatch hook (C07) [DONE]

Ngày: 2026-11-20 ~21:47 +07 (GREEN), gate xong 23:08:08 +07, push ~23:3x +07.

## Trạng thái

- N2506 DONE + PUSHED (origin/main 254197a6).
- N2507 DONE (slice 39b0231b, docs TBD, GOAL TBD, status TBD, hashes TBD): LExecutor `SenseI.run()` dispatch hook cho duo — `public static class SenseI implements LInstruction{` (LExecutor.java:668, :681-718): null target + `dead` → `to.setnum(1)` (:685-687, checked FIRST); Senseable + LAccess → `objOut = se.senseObject(la)` (:695), `if(objOut == Senseable.noSensed){ to.setnum(se.sense(la)); }` (:697-699) else `to.setobj(objOut)` (:701-703); Senseable + Content → `to.setnum(se.sense(co))` (:692-693, DEFERRED); non-Senseable + size/bufferSize → length/size (:706-714, DEFERRED), else `to.setobj(null)` (:716). Composed functions: `senseObject()` (BuildingComp.java:2128-2136, N2506) + `sense()` (Turret.java:405-419, N2283; BuildingComp.java:2093-2126, N2284). Subtlety đã pin: `config` / `payloadType` trả null từ senseObject nhưng đó KHÔNG phải sentinel → dispatch viết obj null (`output_kind` "obj"), KHÔNG fallback sang numeric sense. KHÔNG có driver tick (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_logic_sense_dispatch_state` (5 params sensor, target_is_null, sense_object_handled, sense_object, sense_value; 4 keys: handled, output_kind, output_value, is_no_sensed) trong SourceTurretBuildState.gd, ngay SAU `source_turret_sense_object_state` (:537), TRƯỚC `source_turret_progress_state` (:566) (mirror Java order — SenseI.run :681-718 compose senseObject :2128-2136 + sense :2093-2126).
- KHÔNG có driver tick: dispatch hook là logic read; wiring vào live logic-executor driver tick là slice riêng sau (logic executor chưa có trong driver).
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07TurretLogicSenseDispatchProof.json — GREEN ~21:47 +07). 6 key semantic: null+dead → num 1.0; handled obj (type duo); noSensed → num fallback + is_no_sensed true; config null → obj (KHÔNG fallback); payloadType null → obj (KHÔNG fallback); unknown sensor → noSensed fallback.
- `register_c07_turret_logic_sense_dispatch.py --verify`: 29/29 exprs present (20 exact + 5 input + 4 output, re-run độc lập lượt cron 23:15 +07, exit 0). SSOT đo từ đĩa: 11672/1736/1670/3131 (symbols +4, Done +1, contracts +1, schemas +2); comp slices 559, contracts 463; defense slices 210, contracts 209 không đổi (N2507 canonical-only — java_source LExecutor.java, không có shard /logic/, chỉ sống ở canonical SSOT). Đúng kỳ vọng scope.
- Số slice N2507, KHÔNG phải N2285: N2285–N2505 đã có trên branch khác (slice/N2285-pump-dump-liquid, integration/wave-advances-36-n2499-n2505), `git log --all` max là N2506, không có branch N2507 nào. Lấy N2285 sẽ đụng khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (63 subtests, 17.37s GREEN; re-run độc lập lượt cron 23:15 +07 4/4 trong 19.07s, Godot trên PATH); neighbours 211 passed (696.99s, 14:54:49–15:06:27Z, exit 0, log hidden_files/n2507-neighbours.log); wiring 32 tests OK trong một batch (Ran 32 in 124.8s, log hidden_files/n2507-wiring.log); `git diff --check` OK.
- Gate: launch 1 GATE-START 15:19:02Z chết không EXIT (partial log full-suite-n2507-gate-partial-restart-1534z.log, VM restart ~15:34Z); launch 2 main-thread GATE-START 15:47:52Z, GATE-EXIT 1 16:08:08Z (log full-suite-n2507-gate.log, chain log hidden_files/n2507-chain.log). Ran 6237 trong 1214.760s, failures=236, skipped=5 — xác minh độc lập: 236 FAIL = 236 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2506).
- Đỏ: không có test đỏ ngoài 236 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker.

## Bước tiếp theo

- Push N2507 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284/N2506).
- Slice tiếp theo: chọn từ deferred list — ứng viên đầu: SenseI Content leg (`BuildingComp.sense(Content)`, BuildingComp.java:2139-2147, cần live items/liquids/payloads counts); SenseI non-Senseable size/bufferSize legs; dead/health/totalItems/camera* legs (khi có live input); powerNet* graph legs. calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-logic-dispatch-handoff.md.
