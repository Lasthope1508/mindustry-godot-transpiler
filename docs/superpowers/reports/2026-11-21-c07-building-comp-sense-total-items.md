# Báo cáo — N2513 BuildingComp.sense() totalItems leg (C07) [DONE + PUSHED]

Ngày: 2026-11-21 ~07:35 +07 (GREEN), gate xong 08:23:13 +07, push ~08:3x +07.

## Trạng thái

- N2512 DONE + PUSHED (origin/main 69d55c39).
- N2513 DONE + PUSHED (slice 1d726f35, docs TBD, GOAL TBD, status TBD, hashes TBD): `BuildingComp.sense()` `totalItems` leg — leg deferred thứ ba BÊN TRONG `sense()` (BuildingComp.java:2107): `case totalItems -> items == null ? 0 : items.total();`, với `items` là item module của building (`@Nullable ItemModule items;`, BuildingComp.java:81) và `items.total()` là tổng số item (`public int total(){`, ItemModule.java:174 — returns int). N2284 đã port 23 handled legs của `sense()` (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/powerNet* deferred; N2511 đã port `dead` (:2098), N2512 đã port `health` (:2101), N2513 port đúng leg `totalItems`, tiếp theo trong Java switch order. KHÔNG có driver tick (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_building_comp_sense_total_items_state` (2 params items_is_null, items_total; 3 keys: handled, sense_value, sense_value_is_nan) trong SourceTurretBuildState.gd:595, ngay SAU `source_building_comp_sense_health_state` (:566, kết thúc ~:594), TRƯỚC `source_turret_sense_object_state` (:629 — bị đẩy từ :595) (mirror Java order — sense() :2093 → senseObject() :2128; trong sense() dead :2098 → health :2101 → totalItems :2107). `sense_value = 0.0` khi items null, else `float(items_total)` chính xác (Java `sense()` returns double; int widen chính xác), không clamp, không làm tròn. `handled` luôn true (function này CHÍNH là totalItems leg, sensor cố định `totalItems` nên không có param sensor); `sense_value_is_nan` luôn false (leg không bao giờ ra NaN).
- KHÔNG sửa `source_building_comp_sense_state`: totalItems vẫn `handled:false` trong big dispatch cho tới slice wiring sau (tiền lệ N2508 Content leg, N2511 dead leg, N2512 health leg sống cạnh N2284). KHÔNG có driver tick: totalItems leg là logic read; wiring vào live logic-executor driver tick là slice riêng sau (logic executor chưa có trong driver); live inventory total chưa được stamp trong frame — stamping là frame work riêng, params của N2513 là live input slice đó sẽ cung cấp.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07BuildingCompSenseTotalItemsProof.json — GREEN lúc ~07:35 +07, xác minh lại độc lập lượt này 08:32 +07 khi chạy lại targeted, JSON viết lại vẫn 9/9 true). 6 key semantic: total_items_null_num (null → 0.0); total_items_empty_num (total 0 → 0.0); total_items_some_num (25 → 25.0 chính xác); total_items_large_num (1000 → 1000.0 chính xác); total_items_handled_true; total_items_value_not_nan.
- `register_c07_building_comp_sense_total_items.py --verify`: 10/10 exprs present, exit 0. SSOT đo từ đĩa: 11692/1742/1676/3143 (symbols +3, Done +1, contracts +1, schemas +2); comp slices 563, contracts 467 (+1/+1, N2513 vào comp shard — java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511/N2512); defense slices 210, contracts 209 không đổi. Đúng kỳ vọng scope.
- Số slice N2513, KHÔNG phải N2285: N2285–N2505 đã có trên branch khác (slice/N2285-pump-dump-liquid, integration/wave-advances-36-n2499-n2505), `git log --all` max là N2512. Lấy N2285 sẽ đụng khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (30 subtests, 17.74s pytest + 14.337s unittest re-run độc lập lượt cron 08:30 +07, Godot trên PATH); neighbours 235 passed, 0 failed trong 797.83s (NEIGHBOURS-START 00:40:00Z, NEIGHBOURS-EXIT 0 00:53:19Z, log hidden_files/n2513-chain.log); wiring 32 tests OK trong 124.872s (WIRING-START 00:53:19Z, WIRING-EXIT 0 00:55:24Z); `git diff --check` OK.
- Gate: launch main-thread (script hidden_files/n2513-gate-only-main.sh). GATE-START 01:03:01Z, GATE-EXIT 1 01:23:13Z (log full-suite-n2513-gate.log, 162476 byte). Ran 6261 trong 1210.614s, failures=242, skipped=5 — xác minh độc lập: 242 FAIL = 242 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2512 — đúng 4 test mới của N2513, +1 failure là reference-graph test của N2513, Godot-absent vì chain script reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 242 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker cho slice. Môi trường: không VM restart trong lúc chain/gate; javalang 0.13.0 + pytest 9.2.0 importable OK (xác minh lượt này); port 7777 free trước mỗi lần chạy proof. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy tắc repo.

## Bước tiếp theo

- Push N2513 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512).
- Slice tiếp theo: các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch order — powerNet* (:2114-2117, graph chưa live trong frame), camera* (:2122, cần UnitComp.sense delegation cho proxy unit). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-21-c07-building-comp-sense-total-items-handoff.md.
