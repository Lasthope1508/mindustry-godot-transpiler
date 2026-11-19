# Handoff — N2272 Turret canConsume heat gate (C07) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-20 ~02:30 +07, lượt cron 02:30) — N2271 đã DONE + PUSHED (b21b55f2). Slice commit 5968f4f5, docs 456f54e6, GOAL bd203b10. Gate xác minh độc lập từ log full-suite-n2272-gate.log: Ran 6181 in 1178.143s, failures=222, skipped=5, errors=0 — 222 FAIL header = 222 × "unexpectedly None", 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2271, đúng 4 test mới; +1 failure là test reference-graph của chính N2272, Godot-absent trong môi trường gate). Gate launch từ main thread (PID 9364, script n2272-gate-only-main.sh, GATE-START 19:02:17Z, GATE-EXIT 1 19:21:56Z). Targeted chạy lại độc lập lượt 02:30: 4/4 (35 subtests, 16.70s); register --verify 15/15; proof JSON matches:true 14/14; SSOT đo từ đĩa 11644/1722/1656/3103; defense 199/198; neighbours 155 passed (500.17s); wiring 32/32 OK (126.989s).

## Scope (đã khóa, xác minh từ đĩa)

- Slice TurretBuild.canConsume() heat gate (Turret.java:623-629): `public boolean canConsume(){` / `if(heatRequirement > 0 && heatReq <= 0f){` / `return false;` / `}` / `return super.canConsume();` / `}`. `heatRequirement` defaults to -1 (Turret.java:52-53, `/** Minimum input heat required to fire. */ public float heatRequirement = -1f;`) và `heatReq` là live per-build field (Turret.java:295, `public float heatReq;`), recomputed by calculateHeat — vẫn BLOCKED (live proximity scan, BuildingComp.java:410-461), nên gate nhận heat_req làm live input parameter.
- Catalog: CHỈ afflict (`heatRequirement = 20f;`, Blocks.java:5122) và malign (`heatRequirement = 144f;`, Blocks.java:6240) set positive requirement trong số turret. Các setter khác trong Blocks.java (surge crucible, cyanogen / phase synthesizer) là HeatCrafter block, không phải turret. Mọi turret khác đọc default -1 → gate pass-through super_can_consume không đổi. Không extractor change ở slice này — catalog đã có giá trị từ N2270 (afflict 20.0, malign 144.0, duo không có key).
- Thiết kế (theo pattern N2268/N2269/N2271): 1 pure function `source_turret_can_consume_heat_gate_state(heat_requirement, heat_req, super_can_consume)` trong SourceTurretBuildState.gd:950 (sau source_turret_charge_sound_state, trước driver tick), 1 key {can_consume} — false đúng khi heat_requirement > 0 và heat_req <= 0 (guard :625), super_can_consume còn lại (pass-through :628). KHÔNG driver tick: canConsume() được đánh giá mỗi lần check consumption, không phải mỗi tick, và driver chưa có shouldConsume gate (tiền lệ N2268/N2269/N2271). N2270 fold là nửa efficiency của cùng rule (unheated afflict/malign fold efficiency về 0 nhưng vẫn consume); gate này là nửa consumption.
- 11 proof keys: catalog_afflict_20, catalog_malign_144, catalog_duo_default_neg1, gate_closed_afflict_no_heat, gate_open_afflict_heated, gate_closed_malign_no_heat, gate_open_malign_heated, gate_passthrough_duo_super_true, gate_passthrough_duo_super_false, gate_super_false_blocks_heated, gate_negative_heat_req_closed.
- SSOT sau GREEN (đo từ đĩa): symbols 11644 (+1), Done 1722 (+1), contracts 1656 (+1), schemas 3103 (+2) → 11644/1722/1656/3103; defense slices 198 → 199, contracts 197 → 198. Symbols chỉ +1 vì slice chỉ thêm 1 function, không thêm catalog entry mới (đúng kỳ vọng, khác N2271 +3).

## GREEN (đã xong, lượt 01:45–02:01)

- Worker lượt 01:45 spawn làm RED → GREEN → proof → neighbours → wiring; worker timeout sau GREEN, chưa viết handoff/report/spec, chưa launch gate. Main thread xác minh độc lập lượt 02:01 (targeted 4/4, 35 subtests; register 15/15; proof 14/14; SSOT như trên; neighbours 155 passed; wiring 32 OK) rồi viết script gate-only n2272-gate-only-main.sh (giữ nguyên log neighbours/wiring, PATH reset không godot) và launch từ MAIN THREAD (PID 9364).
- Pure function `source_turret_can_consume_heat_gate_state` trong SourceTurretBuildState.gd:950 (3 params, 1 key), KHÔNG driver tick.
- Proof C07TurretCanConsumeHeatGateProof.gd + .tscn (11 keys trên). Proof JSON đọc trực tiếp: matches:true, 14/14 true (11 semantic + matches + registry_valid + one_headquarter_per_ssot).
- `python3 register_c07_turret_can_consume_heat_gate.py --verify`: **15/15 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_can_consume_heat_gate.py -q`: **4 passed, 35 subtests, 16.70s** (chạy lại độc lập lượt 02:30, PATH có godot).
- Neighbours: **155 passed (500.17s)**, exit 0, log `hidden_files/n2272-neighbours.log` (goals hidden_files).
- Wiring: **32/32 OK (126.989s)**, exit 0, log `hidden_files/n2272-wiring.log`.
- `git diff --check` OK.
- File thay đổi (slice commit 5968f4f5): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts; audit report tái sinh giống hệt, không diff), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- Môi trường: pytest 9.2.0 + javalang OK (không cần reinstall lượt này); port 7777 trống; không có unittest/godot process nào chạy lúc bắt đầu lượt 02:30.
- SỰ CỐ NHỎ lượt 02:30: targeted chạy lần đầu 1 failed (test reference-graph, `godot` không có trên PATH của cron exec env — đúng sự cố 01:00, không phải regression); chạy lại với PATH=~/workspace/godot-bin → 4/4, 35 subtests, 16.70s.

## Tiếp theo (sau khi push)

1. Chọn slice tiếp theo từ deferred list (charge effect BulletType.chargeEffect — cần shootType bullet-effect representation; maxHealth/health re-sync; queuedBullets đã xong ở N2269; canConsume heat gate đã xong ở N2272).

## Deferred (không đổi, trừ canConsume heat gate đã xong ở N2272)

- Turret charge effect (BulletType.chargeEffect, Turret.java:749) — chờ slice riêng (cần shootType bullet-effect representation).
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- Unit maxHealth/health re-sync từ tile(); unit world position từ set(tile); findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
