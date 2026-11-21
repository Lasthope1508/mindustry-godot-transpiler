# Báo cáo — N2515 BuildingComp.sense() powerNetOut leg (C07) [DONE + PUSHED]

Ngày: 2026-11-21 ~11:02 +07 (GREEN), gate xong 11:14:20 +07, push ~11:2x +07.

## Trạng thái

- N2514 DONE + PUSHED (origin/main 10574d77).
- N2515 DONE + PUSHED (slice 7a7bd733, docs TBD, GOAL TBD, status TBD, hashes TBD): `BuildingComp.sense()` `powerNetOut` leg — leg deferred thứ hai trong bốn powerNet leg BÊN TRONG `sense()` (BuildingComp.java:2115): `case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`, với `power` là power module của building (`@Nullable PowerModule power;`, BuildingComp.java:80) và `power.graph.getLastScaledPowerOut()` là last scaled power-out mỗi tick của graph (`public float getLastScaledPowerOut(){ return lastScaledPowerOut; }`, PowerGraph.java:49-51; cập nhật :234 `lastScaledPowerOut = powerNeeded / Time.delta`). `* 60` đổi giá trị mỗi tick sang rate mỗi giây. N2284 đã port 23 handled legs của `sense()` (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/powerNet* deferred; N2511 đã port `dead` (:2098), N2512 đã port `health` (:2101), N2513 đã port `totalItems` (:2107), N2514 đã port `powerNetIn` (:2114), N2515 port đúng leg `powerNetOut`, tiếp theo trong Java switch order. KHÔNG có driver tick (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_building_comp_sense_power_net_out_state` (2 params power_is_null, last_scaled_power_out; 3 keys: handled, sense_value, sense_value_is_nan) trong SourceTurretBuildState.gd:668, ngay SAU `source_building_comp_sense_power_net_in_state` (:629, kết thúc ~:667), TRƯỚC `source_turret_sense_object_state` (:708 — bị đẩy từ :668) (mirror Java order — sense() :2093 → senseObject() :2128; trong sense() dead :2098 → health :2101 → totalItems :2107 → powerNetIn :2114 → powerNetOut :2115). `sense_value = 0.0` khi power null, else `last_scaled_power_out * 60.0` chính xác (float * int literal 60; Java `sense()` returns double, float widen chính xác), không clamp, không làm tròn. `handled` luôn true (function này CHÍNH là powerNetOut leg, sensor cố định `powerNetOut` nên không có param sensor); `sense_value_is_nan` luôn false (leg không bao giờ ra NaN).
- KHÔNG sửa `source_building_comp_sense_state`: powerNetOut vẫn `handled:false` trong big dispatch cho tới slice wiring sau (tiền lệ N2508 Content leg, N2511 dead leg, N2512 health leg, N2513 totalItems leg, N2514 powerNetIn leg sống cạnh N2284). KHÔNG có driver tick: powerNetOut leg là logic read; wiring vào live logic-executor driver tick là slice riêng sau (logic executor chưa có trong driver); live graph values chưa được stamp trong frame — stamping là frame work riêng, params của N2515 là live input slice đó sẽ cung cấp.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07BuildingCompSensePowerNetOutProof.json, mtime 04:02:19Z ~11:02 +07, xác minh độc lập lượt cron 11:15 +07). 6 key semantic: power_net_out_null_num (null → 0.0); power_net_out_zero_num (0.0 → 0.0); power_net_out_some_num (2.5 → 150.0, đúng * 60 rate mỗi giây); power_net_out_large_num (10.0 → 600.0 chính xác); power_net_out_handled_true; power_net_out_value_not_nan.
- `register_c07_building_comp_sense_power_net_out.py --verify`: 10/10 exprs present (lượt worker). SSOT đo từ đĩa: 11698/1744/1678/3147 (symbols +3, Done +1, contracts +1, schemas +2); comp slices 565, contracts 469 (+1/+1, N2515 vào comp shard — java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511/N2512/N2513/N2514); defense slices 210, contracts 209 không đổi. Đúng kỳ vọng scope.
- Số slice N2515, KHÔNG phải N2285: N2285–N2505 đã có trên branch khác (slice/N2285-pump-dump-liquid, integration/wave-advances-36-n2499-n2505), `git log --all` max là N2514. Lấy N2285 sẽ đụng khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (30 subtests, lượt worker GREEN, Godot trên PATH); neighbours 243/243 sạch (0 flake, 243 passed trong 825.91s; NEIGHBOURS-START 03:17:23Z, NEIGHBOURS-EXIT 0 03:31:09Z, log hidden_files/n2515-chain.log); wiring 32 tests OK trong 131.024s (WIRING-START 03:31:09Z, WIRING-EXIT 0 03:33:21Z); `git diff --check` OK.
- Gate: launch main-thread relaunch (script hidden_files/n2515-gate-only-main.sh). GATE-START 03:47:44Z (worker launch, chết theo session — log partial full-suite-n2515-gate-partial-worker.log), GATE-START 03:49:49Z (main-thread relaunch), GATE-EXIT 1 04:14:20Z (log full-suite-n2515-gate.log, 163876 byte). Ran 6269 trong 1468.612s, failures=244, skipped=5 — xác minh độc lập: 244 FAIL = 244 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2514 — đúng 4 test mới của N2515, +1 failure là reference-graph test của N2515, Godot-absent vì chain script reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 244 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker cho slice. Môi trường: VM restart ~03:35Z (uptime 45 phút lúc 04:20Z) — SAU wiring (03:33Z), TRƯỚC gate (03:47Z); gate chạy sau restart và sống tới EXIT; javalang 0.13.0 + pytest 9.2.0 importable OK (xác minh lượt này); port 7777 free. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy tắc repo.

## Bước tiếp theo

- Push N2515 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514).
- Slice tiếp theo: các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch order — powerNetStored / powerNetCapacity (:2116-2117, graph chưa live trong frame), camera* (:2122, cần UnitComp.sense delegation cho proxy unit). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-21-c07-building-comp-sense-power-net-out-handoff.md.
