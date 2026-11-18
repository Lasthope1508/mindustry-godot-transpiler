# Báo cáo — N2251 ItemTurret validateTarget (C07)

Ngày: 2026-11-18 ~22:15–2026-11-19 ~00:0x +07. Slice trước N2250 DONE + PUSHED (main 0d1a5c15, SSOT 11587/1700/1634/3059).

## Kết luận scoping

N2251 làm được: slice validateTarget cho ItemTurret (duo) — pure predicate, không scan. `validateTarget()` (Turret.java:631-633) gọi overload `invalidateTarget` không range (Units.java:160-162, range = Float.MAX_VALUE) nên mệnh đề range CHẾT — pure function KHÔNG nhận param range. 1 pure function `source_item_turret_validate_target_state` (6 bool params, 2 keys: valid, target_cleared) trong `SourceItemTurretBuildState.gd:251` + 1 dòng driver tick trong driver chung `source_turret_tick_buildings_state` (`SourceTurretBuildState.gd:304` gọi pure function, `:311` clear target khi invalid, `:315` thay arg target_valid của lệnh gọi aim/shoot N2250 bằng verdict). Hoãn sang slice sau: findTarget (Turret.java:651-662, cần live entity scan, cùng họ BLOCKED với suppression/targets live list), live wiring cho controlled/logicControlled + các bool team/health/targetable (driver stamp từ frame với default vacuous).

## Java đã pin (đọc từ disk)

- `validateTarget()` (Turret.java:631-633): `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();`
- `Units.invalidateTarget` (Units.java:151-157): 4 mệnh đề live — target null, cùng effective team, Healthc không valid, Unit không targetable; overload không range (Units.java:160-162).
- **Team.derelict id = 0** — Team.java:33. **targetHealing default false** — Turret.java:95; duo không set (Blocks.java:3257–3324) → với duo nhánh derelict chết, effective team luôn là turret team.
- `canHeal()` (Turret.java:635-637): `targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals()`.
- `controlled()` (Turret.java:441-443): `unit.isPlayer()`; `logicControlled()` (Turret.java:445-447): `logicControlTime > 0`. Trong port chưa có frame flag `controlled`/`logic_controlled` — driver/proof stamp từ frame với default false; live player/logic wiring chờ slice riêng.
- Công thức: `invalidate = target_is_null or target_same_team_effective or not target_health_valid or not target_unit_targetable`; `valid = not invalidate or controlled or logic_controlled` (kể cả target null, controlled/logicControlled vẫn cứu valid = true, đúng Java `||`).

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_item_turret_validate_target.py` (4 tests: registration / input-evidence / behavior / reference-graph) + register script `tools/mindustry_godot_transpiler/register_c07_item_turret_validate_target.py` + proof `C07ItemTurretValidateTargetProof` (.gd + .tscn).
- Chạy RED: 4 failed — registration + evidence `KeyError: 'N2251'` (ledger chưa có N2251), behavior `AssertionError: 'static func source_item_turret_validate_target_state(...)' not found`, proof Godot returncode 1 (`ERROR: Cannot open file 'res://tools/runtime_proofs/C07ItemTurretValidateTargetProof.tscn'`) — đúng kỳ vọng.

## GREEN (main thread ~23:1x +07; lượt cron 00:00 chạy lại targeted)

- Pure function + comment Java lines đã pin trong `SourceItemTurretBuildState.gd:251`, đúng chữ ký test RED đã khóa (6 bool params). Driver tick `SourceTurretBuildState.gd:304-315`: verdict invalid → `frame["target"] = null`, `frame["has_target"] = false`; arg target_valid của aim/shoot = `validate.get("valid", false)`.
- Register script `--verify` **25/25** (lượt cron 00:00 chạy lại, 25/25 exprs present). Ledger N2251 status done. SSOT **11587/1700/1634/3059 → 11589/1701/1635/3061** (+2 symbols, +1 Done, +1 contract, +2 schema); defense shard slices 179 → 180, defense_api_contracts 178 → 179.
- Lệch kỳ vọng đã sửa: handoff scope kỳ vọng schema +1 (→ 3060) — thực tế +2 (2 result keys valid/target_cleared) → 3061, đo lại từ đĩa ở lượt cron 00:00.
- Targeted **4/4 OK, 37 subtests, 19.09s** — lượt cron 00:00 chạy lại từ đầu (PATH += ~/workspace/godot-bin). Family `-k item_turret`: 111 passed + 1 failed (flake port-7777 trong batch — proof test của N2251 fail khi chạy chung, pass khi chạy riêng); 213 subtests. Wiring **32/32, 250 subtests, 185.43s** (9 module chuẩn N2184, log `n2251-wiring.log`).
- Godot proof headless Linux: scene `C07ItemTurretValidateTargetProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07ItemTurretValidateTargetProof.json` (ignored, KHÔNG stage): **8 keys + matches, 11/11 true, matches:true** — validate_null_target_invalid, validate_same_team_invalid, validate_dead_target_invalid, validate_untargetable_unit_invalid, validate_controlled_saves_invalid_target, validate_logic_controlled_saves_invalid_target, validate_healthy_enemy_valid, validate_driver_clears_invalid_target, registry_valid, one_headquarter_per_ssot.
- `git diff --check` sạch.

## Gate — XANH (lượt cron 00:00 xác minh từ log)

- Gate 1 (`full-suite-n2251-gate.log`, 5728 bytes): CHẾT giữa chừng, không có footer (không có dòng `Ran `) — mẫu quen thuộc của gate worker-launched.
- Gate 2 (`full-suite-n2251-gate2.log`, mtime 16:51 UTC = 23:51 +07): **Ran 6097 tests in 1082.363s, FAILED (failures=201, skipped=5, errors=0)** — xác minh bằng Python đếm trực tiếp từ log: 201 FAIL header, cả 201 đều chứa `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR header, 0 KeyError. Trong đó có test reference-graph của N2251 (`test_reference_graph_and_actual_c07_item_turret_validate_target`, `assertIsNotNone(godot)` → unexpectedly None) — fail Godot-absent trong môi trường gate, nhưng pass trong targeted run khi Godot có trên PATH. Gate xanh theo quy ước repo (failures toàn Godot-absent).
- Slice đủ điều kiện commit + push: targeted + family + wiring + proof + gate đều xanh.

## Môi trường

- Port 7777 trống trước mọi lần chạy, không va chạm agent khác; ps sạch (không còn pytest/unittest/Godot) lúc 00:00.
- javalang 0.13.0 + pytest 9.2.0 còn importable lúc 00:00 (không cần cài lại).
- VM clock chạy UTC — file mtime ~17:0x UTC = ~00:0x +07.

## Hashes

- Slice `0ecc5608` / docs `059a737d` / GOAL `0f04cc2e` (handoff-status commit follows; main hash filled at push).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: commit + push N2251 → sau N2251: ItemTurret bullet spawn / findTarget, hoặc family tiếp theo trong backlog; live coolant driver wiring + suppression/targets live list vẫn BLOCKED.
