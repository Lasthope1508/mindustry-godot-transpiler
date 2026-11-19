# Report — N2263 Turret heatReq fold (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~16:0x +07, lượt cron 16:00) — slice `7a5bbc88`, docs + GOAL + status sẽ ghi sau. Targeted 4/4 + proof matches:true 12/12 + register --verify 16/16 + gate Ran 6145, failures=213 toàn Godot-absent (đã xác minh độc lập).

- N2262 DONE + PUSHED (origin/main 3da46aee, slice f97d8dc0) — đã xác minh đầu lượt cron 16:00: git log 5 commit khớp, HEAD == origin/main == 3da46aee, worktree chỉ còn diff N2263 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_heat_req_state(heat_requirement: float, heat_total: float, side_heat: Array, heat_req: float) -> Dictionary` trong `SourceTurretBuildState.gd:498` + 1 driver tick nhánh duo, SAU tick logicControlTime N2261, TRƯỚC tick rotate sync N2262 (Java order :534-536 decay, :538-540 heatReq, :542-545 rotate sync, :595-596 turnToTarget, :601/:609 updateShooting).
- Java: `if(heatRequirement > 0){ heatReq = calculateHeat(sideHeat); }` (Turret.java:538-540); `public float heatRequirement = -1f;` (:53, duo KHÔNG override — block duo Blocks.java:3257-3331 không set heatRequirement); `public float heatReq;` + `public float[] sideHeat = new float[4];` (:295-296, default 0 / bốn 0); `public float calculateHeat(float[] sideHeat){` (BuildingComp.java:406) → `return calculateHeat(sideHeat, null);` (:407); `Arrays.fill(sideHeat, 0f);` (:411); per-side `sideHeat[Mathf.mod(relativeTo(build), 4)] += add;` (:436); `return heat;` (:460). Chỉ afflict (PowerTurret, `heatRequirement = 20f;`, Blocks.java:5122) và malign (PowerTurret, `heatRequirement = 144f;`, Blocks.java:6240) set heatRequirement > 0 trong số các turret.
- Pure function trả 2 result symbol `heat_req`, `side_heat`: heat_requirement <= 0 thì trả cả hai key nguyên vẹn (Java skip assignment); > 0 thì heat_req = heat_total, side_heat = array đã cho.
- Driver tick (SourceTurretBuildState.gd:795): `source_turret_heat_req_state(-1.0, 0.0, frame.get("side_heat", [0.0, 0.0, 0.0, 0.0]), float(frame.get("heat_req", 0.0)))` rồi stamp `frame["heat_req"]` + `frame["side_heat"]`. Duo requirement -1.0 → guard off live, heat_total 0.0 không bao giờ được gán (scan deferred), tick vẫn cần để frame mirror đúng field TurretBuild.
- Quyết định scope — calculateHeat live proximity scan (BuildingComp.java:410-461: duyệt proximity, chỉ HeatBlock cùng team, facing check, contactPoints, split /3 cho HeatConductor) KHÔNG làm trong N2263: BLOCKED, live entity scan cùng class với findTarget. Scan chờ slice riêng; fold chỉ nhận kết quả scan (heat_total + side_heat) làm input.

## RED

- `python3 -m unittest tests.test_c07_turret_heat_req` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2262. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2263'` (ledger chưa có entry N2263); state test FAIL vì pure function `source_turret_heat_req_state` chưa có; proof test FAIL vì `C07TurretHeatReqProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretHeatReqProof.tscn'`).

## GREEN (lượt cron 15:30; neighbours/wiring/gate lượt cron 16:00)

- Pure function + driver tick + register script + proof `C07TurretHeatReqProof` đã có; SSOT đúng kỳ vọng 11622/1713/1647/3085, defense 192/191; `git diff --check` OK.
- Targeted chạy lại: **Ran 4, OK (15.485s)**.
- Proof JSON `C07TurretHeatReqProof.json` (đọc trực tiếp lượt cron 16:00): **matches:true, 12/12 true** (9 keys heatReq + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **16/16 exprs present**.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof không seed gì trước tick; key heat_req_duo_live pin heat_req 0.0 + side_heat bốn 0 đúng field default).
- Neighbours 27 module — **XANH, đã xác minh độc lập lượt cron 16:00: 108 passed in 370.91s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2263-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 16:00: Ran 32 tests, OK (122.711s)** (log `n2263-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2263-gate.log`, chuỗi detached `n2263-chain.sh` PID 15483, launch ~15:21 +07, xong ~15:53 +07): **Ran 6145 trong 1086.831s, FAILED (failures=213, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt cron 16:00: 213 FAIL = 213 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, 0 AssertionError loại khác — toàn Godot-absent. So với gate N2262 (Ran 6141, failures=212): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2263 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2262); 3 test còn lại của slice không nằm trong FAIL list → pass trong gate. Lưu ý: chain log có 3 dòng NEIGHBOURS-START (08:21:01Z / 08:26:12Z / 08:27:04Z) — lần 08:26:12Z exit 1 ngay cùng giây rồi chạy lại 08:27:04Z và pass 108; log cuối cùng coherent, không ảnh hưởng kết quả (neighbours/wiring/gate đều đã xác minh độc lập từ log cuối).
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc launch chuỗi.

## Tiếp theo: N2264

- N2264 candidate — control() setters arm logicControlTime = 120 (Turret.java:384/:394, LAccess shoot/shootp + targetPos/targetPosition) — deferred lâu nhất trong danh sách dưới; hoặc efficiency fold :676 (`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`, cần heatReq live từ N2263 + cheating helper N2099).
