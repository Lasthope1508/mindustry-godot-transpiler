# Báo cáo — N2511 BuildingComp.sense() dead leg (C07) [DONE + PUSHED]

Ngày: 2026-11-21 ~05:18 +07 (GREEN), gate xong 05:39:45 +07, push ~05:5x +07.

## Trạng thái

- N2510 DONE + PUSHED (origin/main fee79e05).
- N2511 DONE + PUSHED (slice dcca355e, docs 8350bfe8, GOAL 11814f45, status 5f45c84f, hashes TBD): `BuildingComp.sense()` `dead` leg — leg deferred đầu tiên BÊN TRONG `sense()` (BuildingComp.java:2098): `case dead -> !isValid() ? 1 : 0;`, với `isValid()` (BuildingComp.java:2030-2032): `return tile.build == self() && !dead();`. N2284 đã port 23 handled legs của `sense()` (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/powerNet* deferred — dead deferred vì `isValid()` cần tile state chưa có trong frame. N2511 port đúng leg `dead`, đầu tiên trong Java switch order giữa các deferred legs. KHÔNG có driver tick (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_building_comp_sense_dead_state` (2 params tile_build_is_self, is_dead; 3 keys: handled, sense_value, sense_value_is_nan) trong SourceTurretBuildState.gd:537, ngay SAU `source_building_comp_sense_state` (:313, kết thúc ~:536), TRƯỚC `source_turret_sense_object_state` (:566 — bị đẩy từ :537) (mirror Java order — sense() :2093 → senseObject() :2128). `is_valid = tile_build_is_self and not is_dead` là đúng body `isValid()`; `sense_value` 0.0 khi valid, 1.0 khi không valid (`!isValid() ? 1 : 0`, :2098). `handled` luôn true (function này CHÍNH là dead leg, sensor cố định `dead` nên không có param sensor); `sense_value_is_nan` luôn false (leg không bao giờ ra NaN).
- KHÔNG sửa `source_building_comp_sense_state`: dead vẫn `handled:false` trong big dispatch cho tới slice wiring sau (tiền lệ N2508 Content leg sống cạnh N2284). KHÔNG có driver tick: dead leg là logic read; wiring vào live logic-executor driver tick là slice riêng sau (logic executor chưa có trong driver); tile state (`tile.build == self()`, `dead()`) chưa được stamp trong frame — stamping là frame work riêng.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07BuildingCompSenseDeadProof.json — GREEN ~05:18 +07). 6 key semantic: dead_tile_not_self_num (tile.build không phải self → 1); dead_is_dead_num (is_dead true → 1); alive_valid_zero (valid → 0); dead_both_invalid_num (cả hai invalid → 1, dạng short-circuit của `!isValid()`); dead_handled_true; dead_value_not_nan.
- `register_c07_building_comp_sense_dead.py --verify`: 11/11 exprs present, exit 0. SSOT đo từ đĩa: 11686/1740/1674/3139 (symbols +3, Done +1, contracts +1, schemas +2); comp slices 561, contracts 465 (+1/+1, N2511 vào comp shard — java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508); defense slices 210, contracts 209 không đổi. Đúng kỳ vọng scope.
- Số slice N2511, KHÔNG phải N2285: N2285–N2505 đã có trên branch khác (slice/N2285-pump-dump-liquid, integration/wave-advances-36-n2499-n2505), `git log --all` max là N2510. Lấy N2285 sẽ đụng khi merge.

## Test xanh/đỏ

- Xanh: targeted 4/4 (33 subtests, 14.84s pytest + 14.359s unittest re-run độc lập lượt cron 05:45 +07, Godot trên PATH); neighbours 225 passed + 2 failed flake port-7777 (761.44s, 22:02:14–22:14:56Z), re-run độc lập 2 module fail 8 passed trong 33.48s → thực chất 227/227; wiring 32 tests OK trong một batch (125.299s, exit 0, log hidden_files/n2511-chain.log); `git diff --check` OK.
- Gate: launch main-thread (script n2511-gate-only-main.sh) GATE-START 22:19:48Z, GATE-EXIT 1 22:39:45Z (log full-suite-n2511-gate.log, chain log hidden_files/n2511-chain.log). Ran 6253 trong 1195.247s, failures=240, skipped=5 — xác minh độc lập: 240 FAIL = 240 × `AssertionError: unexpectedly None` (239 plain + 1 suffix pre-existing `Godot required for hydration proof` ở test liquid_consumer_apply_hydration), 0 KeyError, 0 `return_schema_linkage`, 0 ERROR thật (240 hit grep `ERROR` đều là chữ trong `AssertionError`), toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2510 — đúng 4 test mới của N2511, +1 failure là reference-graph test của N2511, Godot-absent vì chain script reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 240 failure Godot-absent trong gate (mẫu đã biết) và 2 flake port-7777 ở neighbours (đã re-run xanh).

## Blocker

- Không có blocker cho slice. Môi trường: javalang 0.13.0 + pytest 9.2.0 vẫn còn sau gate (không bị wipe lượt này); port 7777 free trước mỗi lần chạy proof. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy tắc repo.

## Bước tiếp theo

- Push N2511 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280–N2284/N2506/N2507/N2508/N2509/N2510).
- Slice tiếp theo: các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch order — health (:2101, live building health chưa có trong frame), totalItems (:2107, live inventory total chưa có trong frame), powerNet* (:2114-2117, graph chưa live trong frame), camera* (:2122, cần UnitComp.sense delegation cho proxy unit). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-21-c07-building-comp-sense-dead-handoff.md.
