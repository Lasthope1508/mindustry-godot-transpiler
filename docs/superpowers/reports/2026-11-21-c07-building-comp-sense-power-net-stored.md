# Báo cáo — N2516 BuildingComp.sense() powerNetStored leg (C07) [DONE + PUSHED]

Ngày: 2026-11-21 ~11:53 +07 (GREEN), gate xong 12:23:15 +07, push ~12:3x +07.

## Trạng thái

- N2515 DONE + PUSHED (origin/main d9f55e2e).
- N2516 DONE + PUSHED (slice 8f09495d, docs TBD, GOAL TBD, status TBD, hashes TBD): `BuildingComp.sense()` `powerNetStored` leg — leg deferred thứ ba trong bốn powerNet leg BÊN TRONG `sense()` (BuildingComp.java:2116): `case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();`, với `power` là power module của building (`@Nullable PowerModule power;`, BuildingComp.java:80) và `power.graph.getLastPowerStored()` là last stored battery power của graph (`public float getLastPowerStored(){ return lastPowerStored; }`, PowerGraph.java:73-75; cập nhật :236 `lastPowerStored = getBatteryStored()`). KHÔNG có `* 60` ở đây — stored value là absolute amount (battery charge), không phải per-tick rate như powerNetIn/powerNetOut, nên trả về as-is. N2284 đã port 23 handled legs của `sense()` (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/powerNet* deferred; N2511 đã port `dead` (:2098), N2512 đã port `health` (:2101), N2513 đã port `totalItems` (:2107), N2514 đã port `powerNetIn` (:2114), N2515 đã port `powerNetOut` (:2115), N2516 port đúng leg `powerNetStored`, tiếp theo trong Java switch order. KHÔNG có driver tick (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_building_comp_sense_power_net_stored_state` (2 params power_is_null, last_power_stored; 3 keys: handled, sense_value, sense_value_is_nan) trong SourceTurretBuildState.gd:708, ngay SAU `source_building_comp_sense_power_net_out_state` (:668, kết thúc ~:707), TRƯỚC `source_turret_sense_object_state` (:749 — bị đẩy từ :708) (mirror Java order — sense() :2093 → senseObject() :2128; trong sense() dead :2098 → health :2101 → totalItems :2107 → powerNetIn :2114 → powerNetOut :2115 → powerNetStored :2116). `sense_value = 0.0` khi power null, else `last_power_stored` chính xác (float widen chính xác sang double; Java `sense()` returns double), không clamp, không làm tròn, KHÔNG `* 60`. `handled` luôn true (function này CHÍNH là powerNetStored leg, sensor cố định `powerNetStored` nên không có param sensor); `sense_value_is_nan` luôn false (leg không bao giờ ra NaN).
- KHÔNG sửa `source_building_comp_sense_state`: powerNetStored vẫn `handled:false` trong big dispatch cho tới slice wiring sau (tiền lệ N2508 Content leg, N2511 dead leg, N2512 health leg, N2513 totalItems leg, N2514 powerNetIn leg, N2515 powerNetOut leg sống cạnh N2284). KHÔNG có driver tick: powerNetStored leg là logic read; wiring vào live logic-executor driver tick là slice riêng sau (logic executor chưa có trong driver); live graph values chưa được stamp trong frame — stamping là frame work riêng, params của N2516 là live input slice đó sẽ cung cấp.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07BuildingCompSensePowerNetStoredProof.json, mtime 04:53:19Z ~11:53 +07, xác minh độc lập lượt cron 12:30 +07). 6 key semantic: power_net_stored_null_num (null → 0.0); power_net_stored_zero_num (0.0 → 0.0); power_net_stored_some_num (2.5 → 2.5, KHÔNG * 60 — absolute amount); power_net_stored_large_num (10.0 → 10.0 chính xác); power_net_stored_handled_true; power_net_stored_value_not_nan.
- `register_c07_building_comp_sense_power_net_stored.py --verify`: 10/10 exprs present (xác minh độc lập lượt này). SSOT đo từ đĩa: 11701/1745/1679/3149 (symbols +3, Done +1, contracts +1, schemas +2); comp slices 566, contracts 470 (+1/+1, N2516 vào comp shard — java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511/N2512/N2513/N2514/N2515); defense slices 210, contracts 209 không đổi. Đúng kỳ vọng scope.
- Số slice N2516, KHÔNG phải N2285: N2285–N2505 đã có trên branch khác (slice/N2285-pump-dump-liquid, integration/wave-advances-36-n2499-n2505), `git log --all` max là N2515. Lấy N2285 sẽ đụng khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (30 subtests, 20.33s, xác minh độc lập lượt này, Godot trên PATH); neighbours 247/247 sạch (0 flake, 247 passed trong 921.09s; NEIGHBOURS-START 04:38:15Z, NEIGHBOURS-EXIT 0 04:53:37Z, log hidden_files/n2516-chain.log); wiring 32 tests OK trong 142.052s (WIRING-START 04:53:37Z, WIRING-EXIT 0 04:55:59Z); `git diff --check` OK.
- Gate: chain + gate main-thread (script hidden_files/n2516-chain-main.sh). GATE-START 04:58:30Z, GATE-EXIT 1 05:23:15Z (log full-suite-n2516-gate.log, 164597 byte). Ran 6273 trong 1482.999s, failures=245, skipped=5 — xác minh độc lập: 245 FAIL = 245 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2515 — đúng 4 test mới của N2516, +1 failure là reference-graph test của N2516, Godot-absent vì chain script reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 245 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker cho slice. Môi trường: VM restart #16 lúc 03:34:45Z — TRƯỚC chain (04:38Z), KHÔNG có restart trong lúc chain/gate; gate chạy sau restart và sống tới EXIT; javalang 0.13.0 + pytest 9.2.0 importable OK (xác minh lượt này); port 7777 free. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy tắc repo.

## Bước tiếp theo

- Push N2516 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515).
- Slice tiếp theo: các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch order — powerNetCapacity (:2117, graph chưa live trong frame), camera* (:2122, cần UnitComp.sense delegation cho proxy unit). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-21-c07-building-comp-sense-power-net-stored-handoff.md.
