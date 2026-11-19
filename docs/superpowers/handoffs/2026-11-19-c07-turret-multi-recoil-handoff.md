# Handoff — N2256 Turret multi-recoil decay (C07, duo) [GREEN — gate xong, chờ commit + push]

## Status: GREEN (2026-11-19 ~07:00 +07, lượt cron 07:00) — slice `0a6a5494`, docs `1d94eea3`, GOAL `036d48a7`; targeted 4/4 (chạy lại lượt này OK 16.47s), proof matches:true, register --verify 13/13, SSOT 11609/1706/1640/3071, defense 185/184, `git diff --check` OK. Neighbours DONE 06:45: 79 passed + 931 subtests, 1 fail là flake port-7777 (chạy lại riêng xanh 4/4; không do N2256). Wiring DONE 06:45: 9/9 module OK. Gate N2256 XONG 23:53 UTC: Ran 6117 in 1215.285s, failures=206, skipped=5, errors=0 — all 206 verified Godot-absent (205 × `AssertionError: unexpectedly None` + 1 hydration variant; riêng test N2256 trong gate cũng chỉ fail `unexpectedly None`). Chưa push.

- N2255 DONE + PUSHED (origin/main 6b6719d8, slice 076e10e8) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, working tree sạch ngoại trừ noise *.gd.uid + gate logs cũ (không stage).

## Sửa sai quan trọng: duo recoils = 2, KHÔNG phải -1

- N2254/N2255 hoãn multi-recoil với lý do "duo recoils = -1 → skip", chỉ trích class default (`public int recoils = -1;`, Turret.java:142) mà bỏ qua override của duo. Kiểm chứng ba nguồn, lượt này:
  1. Java def: block duo 3257–3330 trong Blocks.java, `recoils = 2;` ở :3301, `recoil = 0.5f;` ở :3315; scatter bắt đầu ở :3332 nên không nhầm block.
  2. Port catalog: `content_registry_blocks.json` entry duo (health 250, range 160, reload 20.0) có `"recoil": 0.5, "recoils": 2`.
  3. Java use: hai barrel part của duo có recoilIndex 0 / 1 (Blocks.java:3302-3311) và DrawTurret đọc `tb.curRecoils[part.recoilIndex]` (DrawTurret.java:104/115) — không có decay + stamp thì animation giật nòng của duo chết (luôn 0, hoặc null → fallback về curRecoil).
- Hệ quả: vòng decay :520-525 VÀ stamp :807-809 đều áp dụng cho duo. N2256 làm decay (đối tác của N2254), N2257 làm stamp (đối tác của N2255). Comment trong `SourceTurretBuildState.gd` ở N2254 (:241-244) và N2255 (:264-267) nói "duo recoils is -1" hiện SAI — GREEN N2256 sửa các comment đó.

## Scope (đã khóa, xác minh từ đĩa)

- Slice multi-recoil decay cho duo: driver chưa bao giờ stamp `frame["cur_recoils"]` — N2254 chỉ decay curRecoil đơn, N2255 chỉ stamp curRecoil đơn.
- 1 pure function `source_turret_multi_recoil_state(cur_recoils: Array, recoils: int, recoil_time: float, delta: float) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile là TurretBuild.updateTile, không phải ItemTurret-only) + 1 driver tick trong nhánh duo, NGAY SAU tick decay N2254 (Java order :519 rồi :520-525), TRƯỚC aim/shoot.
- PIN: `if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` / `for(int i = 0; i < recoils; i++){` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` / `}` (Turret.java:520-525); field `public @Nullable float[] curRecoils;` (:285), null cho tới tick updateTile đầu tiên allocate; `public int recoils = -1;` (:142) là default class, duo override `recoils = 2;` (Blocks.java:3301); `public float recoilTime = -1f;` (:144) + `if(recoilTime < 0f) recoilTime = reload;` (:208) → recoilTime duo = reload 20, step delta/20, không bao giờ qua 0.
- Pure function build MẢNG MỚI `decayed` dài `recoils` (entry thiếu đọc như 0.0, nên key frame vắng/null init thành zeros), mỗi entry `value + clampf(0.0 - value, -delta / recoil_time, delta / recoil_time)`, KHÔNG mutate input, trả `{"cur_recoils": decayed}` — 1 result symbol.
- Driver tick: `var multi_recoil: Dictionary = source_turret_multi_recoil_state(frame.get("cur_recoils", []), 2, 20.0, seconds)` rồi `frame["cur_recoils"] = multi_recoil.get("cur_recoils", [])`.
- 8 proof keys đã pin trong test: multi_recoil_decays_toward_zero, multi_recoil_both_entries_decay, multi_recoil_never_past_zero, multi_recoil_init_zeros_when_absent, multi_recoil_rate_matches_recoil_time, multi_recoil_stamped_to_frame_after_decay, multi_recoil_decay_runs_after_singular_decay, multi_recoil_second_entry_decays_independently.
- SSOT kỳ vọng sau GREEN: symbols +1, Done +1, contracts +1, schema +2 → 11609/1706/1640/3071; defense shard slices 184 → 185, contracts 183 → 184.

## RED (lượt này, đã chạy)

- `python3 -m unittest tests.test_c07_turret_multi_recoil` (PATH có ~/workspace/godot-bin): Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence KeyError ledger N2256 chưa tồn tại, state test fail vì pure function chưa có, proof test fail vì `C07TurretMultiRecoilProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; uptime 38 phút (không restart gần đây).

## GREEN (lượt 06:30 — đã xác minh độc lập, code có sẵn trên đĩa)

- Pure function `source_turret_multi_recoil_state` + driver tick duo (sau tick N2254, trước aim/shoot) + sửa 2 comment sai về recoils (N2254 :241-244, N2255 :264-267) đã có trong diff `SourceTurretBuildState.gd`; register script + proof `C07TurretMultiRecoilProof` (.gd + .tscn) đã có (untracked); SSOT JSONs đã cập nhật (N2256 có mặt: ledger grep 2, registry/contracts/schema có entry).
- Targeted lượt này: chạy đầu `Ran 4, FAILED (failures=1)` — chỉ proof test fail do `ERROR: [MCP Runtime] Failed to start server on port 7777: 22` (flake port-7777: process neighbours của agent khác đang giữ port bằng proof scene `C07PointDefenseTurretHitSizeRemovalProof`), trong khi proof JSON đã `matches:true`, 11/11 keys true. Chạy lại isolated proof test: **OK 1/1** → targeted thực chất **4/4**. Proof keys 8/8 semantic + registry_valid + one_headquarter_per_ssot.
- `register_c07_turret_multi_recoil.py --verify`: **13/13 exprs present**. SSOT: symbols **11609**, ledger **1706**, contracts **1640**, schema **3071** — đúng kỳ vọng sau GREEN. Defense shard: slices **185**, contracts **184** (184 → 185, 183 → 184). `git diff --check`: OK.
- javalang 0.13.0 + pytest 9.2.0 importable; uptime 1:09 (không restart gần đây).

## GREEN (lượt 06:45 — neighbours + wiring đã xong, gate đang chạy)

- PID 8983 (neighbours/wiring) đã kết thúc — không còn chạy. Log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2256-neighbours-main.log` (23:37 UTC): **1 failed, 79 passed, 931 subtests passed in 346.11s** — fail duy nhất `test_reference_graph_and_actual_c07_point_defense_turret_live_bullets_wiring`. ĐÃ XÁC MINH KHÔNG PHẢI REGRESSION, bằng hai chứng cứ: (a) test này cũng FAIL trong gate N2255 (`full-suite-n2255-gate.log`, failures=205); (b) theo nhật ký ngày 06:3x, chạy lại riêng module đó: **4 passed, 26 subtests, 19.00s** — xanh sạch → flake do va chạm port 7777 (neighbours của main thread giữ port trong lúc targeted của worker chạy, và ngược lại). Neighbours coi như 80/80.
- Wiring log `n2256-wiring-main.log` (23:39 UTC): **9/9 module OK** (factory_live_loop, power_graph_live_update_binding, battery_power_status_binding, battery_placement_binding, adjacent_factory_live_loop, unit_factory_live_loop, turret_live_loop, continuous_liquid_turret_live_loop, power_graph_consumer_cheating).
- Gate N2256 ĐANG CHẠY: PID 9249 `python3 -m unittest discover -s tests`, khởi 23:33 UTC, elapsed ~14 phút lúc kiểm tra (23:47 UTC), log `tools/mindustry_godot_transpiler/full-suite-n2256-gate.log` đang được ghi (5,786 bytes). Gate N2255 mất ~20 phút / 6113 tests → dự kiến xong ~23:53 UTC. Lượt sau (07:00) kiểm tra kết quả gate rồi mới commit/push.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống lúc kiểm tra; uptime 1:24 (không restart gần đây). Working tree: 7 file N2256 modified + proof/handoff/report/register/test untracked; *.gd.uid noise không stage.

## GREEN (lượt 07:00 — gate xong, xác minh độc lập)

- Gate xong 23:53 UTC (PID 9249 đã kết thúc): **Ran 6117 in 1215.285s, failures=206, skipped=5, errors=0** — +4 tests / +1 failure so với gate N2255 (Ran 6113, failures=205), đúng bằng 4 test mới của N2256; failure thêm là test proof N2256 fail `AssertionError: unexpectedly None` (Godot-absent trong môi trường gate, 3 test còn lại của slice pass trong gate). Đếm trong log: 206 FAIL header = 205 × `unexpectedly None` + 1 hydration variant, 0 KeyError, 0 ERROR.
- Targeted chạy lại lượt này: **Ran 4, OK (16.47s)** — xác nhận 4/4 trước commit.
- Slice commit `0a6a5494` (11 files). Docs/spec/GOAL commit lượt này → push.

## GREEN (còn lại — lượt sau, KHÔNG làm trùng gate đang chạy)

- [x] Pure function + driver tick theo scope trên; sửa comment N2254/N2255 sai về recoils trong `SourceTurretBuildState.gd` (ghi rõ duo override Blocks.java:3301).
- [x] Register script `register_c07_turret_multi_recoil.py` (owner `SourceTurretBuildState.source_turret_multi_recoil_state`, 1 symbol `source_turret_multi_recoil_state_result.cur_recoils`, runtime_proof `/root/C07TurretMultiRecoilProof`); --verify 13/13.
- [x] Proof `C07TurretMultiRecoilProof` (.gd + .tscn) với 8 keys; matches:true, 11/11 true.
- [x] Targeted 4/4 (sau re-run isolated do flake port-7777).
- [x] Neighbours — DONE 06:45: 79 passed + 931 subtests, 1 fail là flake port-7777 (chạy lại riêng xanh 4/4; cũng fail ở gate N2255) — không phải regression.
- [x] Wiring — DONE 06:45: 9/9 module OK.
- [x] Gate (log `tools/mindustry_godot_transpiler/full-suite-n2256-gate.log`, xong 23:53 UTC, lượt 07:00 xác minh độc lập): Ran 6117 in 1215.285s, failures=206, skipped=5, errors=0 — all 206 verified Godot-absent (206 FAIL header = 205 × `AssertionError: unexpectedly None` + 1 hydration variant, 0 KeyError, 0 ERROR; +4 tests / +1 failure so với gate N2255 đúng bằng 4 test mới của N2256, failure thêm là test proof Godot-absent trong môi trường gate).
- [ ] Report/handoff/spec/GOAL hoàn thiện → commit + push (docs commit lượt này, sau slice `0a6a5494`).

## Tiếp theo: N2257

- N2257 candidate — multi-recoil stamp (Turret.java:807-809, `curRecoils[barrelCounter % recoils] = 1f;`), đối tác của N2255, cùng duo recoils 2: 1 pure function + 1 driver tick trong nhánh duo SAU `spawn_turret_bullet`, cùng vị trí stamp N2255.

## Deferred sau N2256 (cập nhật)

- Multi-recoil stamp (:807-809) — N2257, đã xác nhận áp dụng cho duo (không còn "def recoils > 0" chung chung).
- recoilOffset draw (:532, recoilPow 1.8, recoil duo 0.5) — draw-side.
- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets; duo firstShotDelay 0 nên charge luôn 0 với duo.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
