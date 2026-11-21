# Báo cáo — N2512 BuildingComp.sense() health leg (C07) [DONE + PUSHED]

Ngày: 2026-11-21 ~06:1x +07 (GREEN), gate xong 07:08:10 +07, push ~07:2x +07.

## Trạng thái

- N2511 DONE + PUSHED (origin/main 82a501d5).
- N2512 DONE + PUSHED (slice d0d4bbd7, docs b4ab1fc5, GOAL da22af06, status TBD, hashes TBD): `BuildingComp.sense()` `health` leg — leg deferred thứ hai BÊN TRONG `sense()` (BuildingComp.java:2101): `case health -> health;`, với `health` là field health hiện tại của building (`float health;`, HealthComp.java:11 — BuildingComp mixes HealthComp). N2284 đã port 23 handled legs của `sense()` (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/powerNet* deferred; N2511 đã port `dead` (:2098), N2512 port đúng leg `health`, tiếp theo trong Java switch order. KHÔNG có driver tick (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_building_comp_sense_health_state` (1 param health; 3 keys: handled, sense_value, sense_value_is_nan) trong SourceTurretBuildState.gd:566, ngay SAU `source_building_comp_sense_dead_state` (:537, kết thúc ~:565), TRƯỚC `source_turret_sense_object_state` (:566 — bị đẩy xuống :595) (mirror Java order — sense() :2093 → senseObject() :2128; trong sense() dead :2098 → health :2101). `sense_value = health` chính xác, không clamp, không làm tròn, không đổi qua `healthf()` (`healthf()` là accessor khác, HealthComp.java:20 — KHÔNG phải leg này). `handled` luôn true (function này CHÍNH là health leg, sensor cố định `health` nên không có param sensor); `sense_value_is_nan` luôn false (leg không bao giờ ra NaN).
- KHÔNG sửa `source_building_comp_sense_state`: health vẫn `handled:false` trong big dispatch cho tới slice wiring sau (tiền lệ N2508 Content leg, N2511 dead leg sống cạnh N2284). KHÔNG có driver tick: health leg là logic read; wiring vào live logic-executor driver tick là slice riêng sau (logic executor chưa có trong driver); live building health chưa được stamp trong frame — stamping là frame work riêng, param của N2512 là live input slice đó sẽ cung cấp.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07BuildingCompSenseHealthProof.json — GREEN lúc ~06:1x +07, xác minh lại độc lập lượt này 07:18 +07 khi chạy lại targeted, JSON viết lại vẫn 9/9 true). 6 key semantic: health_full_num (100.0 → 100.0); health_damaged_num (37.5 → 37.5); health_zero_num (0.0 → 0.0); health_fractional_num (12.25 → 12.25 chính xác); health_handled_true; health_value_not_nan.
- `register_c07_building_comp_sense_health.py --verify`: 9/9 exprs present, exit 0. SSOT đo từ đĩa: 11689/1741/1675/3141 (symbols +3, Done +1, contracts +1, schemas +2); comp slices 562, contracts 466 (+1/+1, N2512 vào comp shard — java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511); defense slices 210, contracts 209 không đổi. Đúng kỳ vọng scope.
- Số slice N2512, KHÔNG phải N2285: N2285–N2505 đã có trên branch khác (slice/N2285-pump-dump-liquid, integration/wave-advances-36-n2499-n2505), `git log --all` max là N2511. Lấy N2285 sẽ đụng khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (29 subtests, 18.93s pytest + 14.063s unittest re-run độc lập lượt cron 07:15 +07, Godot trên PATH); neighbours 231 passed, 0 failed trong 755.41s (NEIGHBOURS-START 23:16:35Z relaunch main-thread sau khi chain worker-launch chết, NEIGHBOURS-EXIT 0 23:29:11Z, log hidden_files/n2512-chain.log); wiring 32 tests OK trong 128.753s (WIRING-START 23:29:11Z, WIRING-EXIT 0 23:31:20Z); `git diff --check` OK.
- Gate: launch main-thread (script hidden_files/n2512-gate-only-main.sh). Lần 1 GATE-START 23:32:37Z chết do VM restart #14 23:36:55Z (log partial full-suite-n2512-gate-partial-restart-2336z.log); relaunch main-thread GATE-START 23:47:58Z, GATE-EXIT 1 ~00:08:10Z (log full-suite-n2512-gate.log, 1942 KB). Ran 6257 trong 1210.653s, failures=241, skipped=5 — xác minh độc lập: 241 FAIL = 241 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2511 — đúng 4 test mới của N2512, +1 failure là reference-graph test của N2512, Godot-absent vì chain script reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 241 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker cho slice. Môi trường: VM restart #14 lúc 23:36:55Z đã wipe javalang + pytest, đã cài lại 0.13.0 / 9.2.0 trước khi relaunch gate (xác minh importable OK); port 7777 free trước mỗi lần chạy proof. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy tắc repo.

## Bước tiếp theo

- Push N2512 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284/N2506/N2507/N2508/N2509/N2510/N2511).
- Slice tiếp theo: các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch order — totalItems (:2107, live inventory total chưa có trong frame), powerNet* (:2114-2117, graph chưa live trong frame), camera* (:2122, cần UnitComp.sense delegation cho proxy unit). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-21-c07-building-comp-sense-health-handoff.md.
