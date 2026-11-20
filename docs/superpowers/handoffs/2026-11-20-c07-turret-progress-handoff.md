# Handoff — N2282 Turret progress() live derivation (C07) [GREEN, gate xong — chờ commit/push]

## Status: DONE + PUSHED (slice ef382162, docs df9e35f3, GOAL ebf98a9f; cập nhật lượt cron 16:30 +07 — gate main-thread xong GATE-EXIT 1 09:23:59Z, Ran 6221 trong 1202.575s, failures=232, skipped=5; xác minh độc lập: 232 FAIL = 232 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent; launch trùng detached setsid của worker 08:49:39Z bị kill theo quy tắc (GATE-DUP-KILL 08:51:45Z)). Neighbours XONG 195 passed, exit 0, 08:35:13–08:45:53Z; wiring XONG 32 tests OK, exit 0, 08:45:53–08:47:57Z. N2281 đã DONE + PUSHED (397d7cd2). Slice commit ef382162, docs df9e35f3, GOAL ebf98a9f, status TBD. Targeted 4/4 (17 subtests, re-run độc lập main thread ~16:3x, 16.61s, Godot trên PATH); register --verify 8/8 (main thread re-run độc lập ~16:3x, exit 0); proof JSON matches:true 8/8 (đọc trực tiếp từ đĩa, main thread xác minh); SSOT đo từ đĩa 11659/1732/1666/3123; `git diff --check` OK.

## Scope (đã khóa — xem docs/superpowers/handoffs/hidden_files/n2282-scope.md)

- Slice: Turret `progress()` derivation — `public float progress(){ return Mathf.clamp(reloadCounter / reload); }` (Turret.java:425-427).
- `reloadCounter`: `public float reloadCounter;` (ReloadTurret.java:26). Driver đã stamp live `frame["reload_counter"]` từ aim tick (N2250/N2269), capped at reload bởi updateReload :720-723.
- `reload`: `public float reload = 10f;` (ReloadTurret.java:10); duo override `reload = 20f;` (Blocks.java:3317) — driver tick truyền literal 20.0, giống aim call.
- `Mathf.clamp(float)`: `return Math.max(Math.min(value, 1f), 0f);` (arc Mathf.java:402-404) → GDScript `clampf(value, 0.0, 1.0)`.
- Pure function: `source_turret_progress_state(reload_counter: float, reload: float) -> Dictionary`, trả `{"progress": clampf(reload_counter / reload, 0.0, 1.0)}` — Java :426 verbatim. Placement: ngay TRƯỚC `source_turret_is_shooting_state` (mirror Java order: progress :425-427 trước isShooting :440-442).
- Driver tick: trong duo branch, ngay SAU stamp `frame["reload_counter"]` (:1683) và TRƯỚC stamp `frame["shot"]`: stamp `frame["progress"]` từ `float(frame.get("reload_counter", 0.0))` và `20.0`. KHÔNG rewire sense(), KHÔNG đổi gameplay.
- Consumer duy nhất: sense() LAccess.progress (`case progress -> progress();`, Turret.java:414) — sense dispatch là slice riêng sau, slice này stamp-only như N2280/N2281.
- Proof keys (5 semantic + registry_valid + one_headquarter_per_ssot + matches = 8): progress_zero_at_empty_counter (0.0/20.0 → 0.0), progress_half_at_half_counter (10.0/20.0 → 0.5), progress_one_at_full_counter (20.0/20.0 → 1.0), progress_clamped_above_reload (25.0/20.0 → 1.0), progress_stamped_to_frame (driver: duo mặc định, 1 tick → key present, 0.0 <= value <= 1.0).
- New result-key symbol (1): `source_turret_progress_state_result.progress`. Expected SSOT sau GREEN: 11659/1732/1666/3123 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 208 → 209, contracts 207 → 208.
- Register script `register_c07_turret_progress.py` mirror N2281 (import DEFERRED từ `register_c07_turret_can_heal`). Test file `tests/test_c07_turret_progress.py` mirror N2281 (4 tests). EXACT_EXPRS (5, đều verbatim): `public float progress(){`, `return Mathf.clamp(reloadCounter / reload);`, `case progress -> progress();`, `return Math.max(Math.min(value, 1f), 0f);`, `reload = 20f;` — expr 4 nằm trong arc-core/src/arc/math/Mathf.java, expr 5 trong Blocks.java nên SLICE_SOURCES gồm Turret.java + Mathf.java + Blocks.java; register --verify kỳ vọng 8/8 (5 exact + 2 input + 1 output).
- SSOT baseline (đo từ đĩa trước GREEN): symbols 11658, Done 1731, contracts 1665, schemas 3121; defense slices 208, contracts 207.

## GREEN (đã xong, xác minh độc lập main thread lượt cron 15:45 +07)

- Pure function `source_turret_progress_state` trong SourceTurretBuildState.gd:224 (2 params, 1 key) — ngay TRƯỚC `source_turret_is_shooting_state`.
- Driver tick trong `source_turret_tick_buildings_state` (:1711-1724): gọi pure function với `float(frame.get("reload_counter", 0.0))` / `20.0`, stamp frame["progress"], ngay sau stamp reload_counter và trước stamp shot.
- Proof C07TurretProgressProof.gd + .tscn. Proof JSON đọc trực tiếp từ đĩa: matches:true, 8/8 true (5 semantic + matches + registry_valid + one_headquarter_per_ssot).
- `python3 register_c07_turret_progress.py --verify`: **8/8 exprs present**, exit 0 (re-run độc lập main thread).
- Targeted: `python3 -m pytest tests/test_c07_turret_progress.py -q` (từ tools/mindustry_godot_transpiler, Godot trên PATH): **4 passed, 17 subtests passed in 16.54s** (re-run độc lập main thread).
- Neighbours: **195 passed** trong 639.64s (exit 0, 08:35:13–08:45:53Z; log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2282-neighbours.log`).
- Wiring: **32 tests OK** trong 123.220s (exit 0, 08:45:53–08:47:57Z; log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2282-wiring.log`).
- `git diff --check`: SẠCH (chạy độc lập main thread lượt cron 16:30 +07).
- File thay đổi (slice commit TBD): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- SSOT đo từ đĩa sau GREEN: symbols 11659 (+1), Done 1732 (+1), contracts 1666 (+1), schemas 3123 (+2) → 11659/1732/1666/3123; defense slices 209, contracts 208. Đúng kỳ vọng scope.
- javalang 0.13.0 OK (kiểm tra trước gate); port 7777 free; ps guard chạy exec RIÊNG trước launch: không có pytest/unittest/godot/gate nào đang chạy.

## Gate (xong — main thread, lần 1)

- Launch: `bash ~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2282-gate-only-main.sh` từ main thread lượt cron 15:45 +07 (session proc_a62421b533a1), GATE-START 08:49:58Z, PID script 9015 / unittest 9018. Log `tools/mindustry_godot_transpiler/full-suite-n2282-gate.log`. GATE-EXIT 1 09:23:59Z.
- Kết quả (xác minh độc lập lượt cron 16:30 +07, từ dòng summary cuối log): Ran 6221 trong 1202.575s, failures=232, skipped=5 — 232 FAIL = 232 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2281).
- Launch trùng: một agent khác launch gate detached setsid (PID 8979/8982, GATE-START 08:49:39Z, script tạo bằng sed từ n2281-gate-only-main.sh) — chen vào giữa ps guard và launch của lượt này. Đã kill 08:51:45Z theo quy tắc (ghi GATE-DUP-KILL vào n2282-chain.log); launch main-thread được giữ.
- Sau gate xanh theo mẫu: commit + push N2282 theo mẫu 5 commit của N2280/N2281 (slice + docs [handoff + report + spec] + GOAL §5 + status + hashes). Nhớ bump Done total trong docs commit (lỗi cũ N2280: quên bump 1729→1730).

## Tiếp theo (sau khi gate xong — main thread)

1. Xác minh gate độc lập từ summary log, `git diff --check`, commit + push N2282 (5 commit theo mẫu N2280/N2281).
2. Chọn slice tiếp theo từ deferred list — ứng viên: sense() LAccess dispatch (Turret.java:405-419, progress live sẽ feed nó); calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; `controlled()` live wiring cần player unit; LaserTurret shouldConsume() cần bullets live list; các def ItemTurret khác ngoài duo; validateTarget effective-team live wiring chờ findTarget slice.

## Deferred (không đổi, trừ progress() nay đã live)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
- `controlled()` live wiring (needs a player unit).
- LaserTurret shouldConsume() consumer wiring — cần bullets live list; chênh một tick snapshot (Java updateConsumption trước updateTile).
- Activation early-return skip — vacuous cho mọi def hiện tại.
- validateTarget effective-team live wiring (`canHeal() ? Team.derelict : team`, Turret.java:632) — chờ findTarget slice; can_heal live sẽ feed nó.
- findTarget ally-tile acquisition (`if(target == null && canHeal()){...}`, Turret.java:660) — BLOCKED, live entity scan.
- sense() LAccess dispatch (Turret.java:405-419) — slice riêng sau; progress live sẽ feed nó.
