# Handoff — N2263 Turret heatReq fold (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~16:0x +07, lượt cron 16:00) — slice `7a5bbc88`, docs `f733a003`, GOAL `2eae450a`, status `e1266ccb` (pushed; origin/main advances with this status commit). Targeted 4/4 OK + proof matches:true 12/12 + register --verify 16/16 + SSOT 11622/1713/1647/3085 + neighbours 108 passed + wiring 32 OK + gate Ran 6145, failures=213 toàn Godot-absent (đã xác minh độc lập).

- N2262 DONE + PUSHED (origin/main 3da46aee, slice f97d8dc0) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == 3da46aee, worktree sạch ngoại trừ noise *.gd.uid (không stage). javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy. `git diff --check` OK lượt này.

## Scope (đã khóa, xác minh từ đĩa)

- Slice heatReq fold cho duo: driver C07 mới (`SourceTurretBuildState.source_turret_tick_buildings_state`, nhánh duo) chưa bao giờ fold heatReq — `heatRequirement` của TurretBuild là float, `heatReq` là field float, `sideHeat` là float[4], và updateTile() fold nó mỗi tick (`if(heatRequirement > 0){ heatReq = calculateHeat(sideHeat); }`, Turret.java:538-540), sau logicControlTime decay :534-536, trước rotate sync :542-545. N2263 là tick live trên driver mới, KHÔNG làm lại path legacy (không có path legacy cho heatReq fold).
- 1 pure function `source_turret_heat_req_state(heat_requirement: float, heat_total: float, side_heat: Array, heat_req: float) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile() là TurretBuild, không phải ItemTurret-only) + 1 driver tick trong nhánh duo, SAU tick logicControlTime N2261, TRƯỚC tick rotate sync N2262, stamp frame["heat_req"] + frame["side_heat"].
- PIN Java: `if(heatRequirement > 0){` / `heatReq = calculateHeat(sideHeat);` (Turret.java:538-540); `public float heatRequirement = -1f;` (Turret.java:53, duo KHÔNG override — block duo Blocks.java:3257-3331 không set heatRequirement); `public float heatReq;` + `public float[] sideHeat = new float[4];` (Turret.java:295-296, default 0 / bốn 0); `public float calculateHeat(float[] sideHeat){` (BuildingComp.java:406) → `return calculateHeat(sideHeat, null);` (:407); `Arrays.fill(sideHeat, 0f);` (:411); per-side `sideHeat[Mathf.mod(relativeTo(build), 4)] += add;` (:436); `return heat;` (:460). Chỉ afflict (PowerTurret, `heatRequirement = 20f;`, Blocks.java:5122) và malign (PowerTurret, `heatRequirement = 144f;`, Blocks.java:6240) set heatRequirement > 0 trong số các turret.
- calculateHeat live proximity scan (BuildingComp.java:410-461: duyệt proximity, chỉ HeatBlock cùng team, facing check, contactPoints từ size/diff, split /3 cho HeatConductor splitHeat) là live entity scan — BLOCKED, cùng class với findTarget. Scan chờ slice riêng; fold chỉ nhận kết quả scan (heat_total + side_heat) làm input.
- Pure function: heat_requirement <= 0 thì trả cả hai key nguyên vẹn (Java skip assignment); > 0 thì heat_req = heat_total, side_heat = array đã cho. Trả 2 result symbol `heat_req`, `side_heat`.
- Driver tick: `var heat_req_state: Dictionary = source_turret_heat_req_state(-1.0, 0.0, frame.get("side_heat", [0.0, 0.0, 0.0, 0.0]), float(frame.get("heat_req", 0.0)))` rồi stamp `frame["heat_req"]` + `frame["side_heat"]`. Duo requirement -1.0 → guard off live, heat_total 0.0 không bao giờ được gán (deferred scan), tick vẫn cần để frame mirror đúng field TurretBuild.
- 9 proof keys đã pin trong test: heat_req_guard_off_keeps_value, heat_req_guard_on_assigns_total, heat_req_zero_requirement_keeps, heat_req_side_heat_stamped, heat_req_side_heat_kept_when_off, heat_req_malign_total, heat_req_partial_total, heat_req_stamped_to_frame, heat_req_duo_live.
- SSOT kỳ vọng sau GREEN: symbols +2, Done +1, contracts +1, schema +2 → 11622/1713/1647/3085 (schema đếm schema object: input + result = 2/slice, giống N2259-N2262); defense shard slices 191 → 192, contracts 190 → 191.
- Quyết định scope — calculateHeat live proximity scan KHÔNG làm trong N2263 (BLOCKED, live entity scan). HeatReq fold cho def khác ngoài duo chưa wire (pure function nhận params, chỉ duo có driver tick; afflict 20f và malign 144f là 2 turret duy nhất có requirement dương).

## RED (lượt này, chạy + xác minh độc lập)

- `python3 -m unittest tests.test_c07_turret_heat_req` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2262. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2263'` (ledger chưa có entry N2263); state test FAIL vì pure function `source_turret_heat_req_state` chưa có; proof test FAIL vì `C07TurretHeatReqProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretHeatReqProof.tscn'`).
- Register --verify: **16/16 exprs present** (10 exact + 6 input/output java_expr).
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_heat_req.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_heat_req.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt này, đã chạy + đã xác minh)

- Pure function `source_turret_heat_req_state` (SourceTurretBuildState.gd, sau `source_turret_rotate_sync_state`) + driver tick trong nhánh duo SAU tick logicControlTime N2261, TRƯỚC tick rotate sync N2262 — đúng scope. Java lines đã xác minh lại từ đĩa trước khi viết: Turret.java:538-540 / :53 / :295-296 / Blocks.java:3257-3331 (duo không set heatRequirement) / :5122 afflict 20f / :6240 malign 144f / BuildingComp.java:406-407, :411, :436, :460. Comment của tick rotate sync đã cập nhật: heatReq tick chạy ngay trên nó (không còn "(own slice)").
- Register script `register_c07_turret_heat_req.py`: **--verify 16/16 exprs present**; đã chạy — SSOT **11622/1713/1647/3085** (symbols +2, Done +1, contracts +1, schema +2 đúng kỳ vọng); defense slices 192, contracts 191 (shard rebuild tự động).
- Proof `C07TurretHeatReqProof` (.gd + .tscn): targeted **Ran 4, OK (15.485s)**; JSON đã đọc trực tiếp từ Godot headless chạy lại: **matches:true, 9/9 semantic true + registry_valid + one_headquarter_per_ssot (12/12)**.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof không seed gì trước tick; key heat_req_duo_live pin heat_req 0.0 + side_heat bốn 0 đúng field default).
- `git diff --check` — **OK lượt này** (sạch).
- Chuỗi detached đã launch lượt này (script `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2263-chain.sh`, PID 15483, `setsid nohup ... &`, start 2026-11-19T08:21:01Z): neighbours (pytest 27 module, kỳ vọng 108 tests) → wiring (`unittest tests.test_turret_live_loop`, kỳ vọng Ran 32 OK) → gate (`python3 -m unittest discover -s tests`, KHÔNG godot-bin trong PATH, log `tools/mindustry_godot_transpiler/full-suite-n2263-gate.log`). Tiến độ trong `n2263-chain.log` + `n2263-neighbours.log` / `n2263-wiring.log`. LƯU Ý lượt sau: KHÔNG launch thêm gate khi chuỗi còn chạy — check `ps aux | grep n2263-chain` + chain log trước.

## Gate (lượt cron 16:00, đã xác minh độc lập)

- Chuỗi detached `n2263-chain.sh` (PID 15483, start ~15:21 +07) đã xong: neighbours **108 passed in 370.91s** (log `n2263-neighbours.log`), wiring **Ran 32, OK (122.711s)** (log `n2263-wiring.log`), gate **Ran 6145 in 1086.831s, failures=213, skipped=5, errors=0** (log `full-suite-n2263-gate.log`, xong ~15:53 +07).
- Xác minh độc lập: 213 FAIL = 213 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. +4 tests / +1 failure so với gate N2262 đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2263 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2262). Lưu ý: chain log có 3 dòng NEIGHBOURS-START (08:21:01Z / 08:26:12Z / 08:27:04Z) — lần 08:26:12Z exit 1 ngay cùng giây rồi chạy lại 08:27:04Z và pass 108; log cuối cùng coherent, không ảnh hưởng kết quả.
- Proof JSON đã đọc trực tiếp: matches:true, 12/12 true (9 keys heatReq + registry_valid + one_headquarter_per_ssot).

## Tiếp theo: N2264

- N2264 candidate — control() setters arm logicControlTime = 120 (Turret.java:384/:394, LAccess shoot/shootp + targetPos/targetPosition) — deferred lâu nhất trong danh sách dưới; hoặc efficiency fold :676 (`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`, cần heatReq live từ N2263 + cheating helper N2099).

## Deferred (không đổi, trừ heatReq fold đã xong)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan (proximity walk, facing/rotation checks, contact-point math, split-heat /3).
- control() setters arm logicControlTime = 120 (:384/:394, LAccess shoot/shootp + targetPos/targetPosition).
- Efficiency fold :676 (cần heatReq live — nay đã có từ N2263 — + cheating helper).
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
