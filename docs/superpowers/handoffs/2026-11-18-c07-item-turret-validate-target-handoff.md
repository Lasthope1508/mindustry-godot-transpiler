# Handoff — N2251 ItemTurret validateTarget (C07) [GATE XONG — CHỜ COMMIT/PUSH]

## Status: GATE XONG (lượt cron 2026-11-19 ~00:0x +07 xác minh từ log) — slice commit 0ecc5608, HEAD 0d1a5c15 + slice. Targeted 4/4 (chạy lại 19.09s) + family + wiring + proof xanh + gate 2 xanh (Ran 6097, failures 201 toàn Godot-absent). CHỜ commit docs/GOAL + push.

- Targeted 4/4 (main-thread re-run, 18.61s, 37 subtests): lần chạy đầu 3 passed + 1 failed ở test proof — chỉ do port-7777 MCP bind ERROR (flake môi trường, proof JSON lúc đó đã `matches:true`, 8/8 keys true); chạy lại riêng test proof 1 passed, 8 subtests, 22.86s; chạy lại full targeted 4 passed.
- Family `-k item_turret`: 111 passed + 1 failed (cùng flake port-7777 trong batch — proof test của N2251 fail khi chạy chung, pass khi chạy riêng); 213 subtests.
- Wiring 32/32, 250 subtests, 185.43s (log `tools/mindustry_godot_transpiler/n2251-wiring.log`, set 9 module chuẩn N2184).
- Proof `C07ItemTurretValidateTargetProof.json`: `matches:true`, 11/11 true (8 semantic keys + registry_valid + one_headquarter_per_ssot + matches).
- SSOT đo từ đĩa: symbols 11589 (+2 đúng kỳ vọng), ledger có N2251. `git diff --check` CLEAN.
- Gate full ĐÃ chạy + xác minh (lượt cron 00:00, 2026-11-19): gate 1 (`full-suite-n2251-gate.log`, 5728 bytes) CHẾT không footer; gate 2 (`full-suite-n2251-gate2.log`) **Ran 6097 in 1082.363s, failures=201, skipped=5, errors=0** — đếm trực tiếp từ log: 201 FAIL header, cả 201 đều `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR, 0 KeyError; test reference-graph N2251 fail cùng kiểu (`assertIsNotNone(godot)`) trong gate nhưng pass ở targeted. Gate xanh theo quy ước repo. Targeted chạy lại bởi lượt cron 00:00: **4/4, 37 subtests, 19.09s**. Register `--verify` chạy lại: **25/25**. SSOT đo lại từ đĩa lúc 00:00: **11589/1701/1635/3061** — schema thực tế +2 (2 result keys), không phải +1 như kỳ vọng ở dưới; defense slices 180, contracts 179.
- LƯU Ý mâu thuẫn: 1 lượt chạy song song (ghi trong ~/memory/2026-11-18.md ~23:0x) đo wiring 30/32 (2 failed, 1 là test_power_graph_consumer_cheating reference test, 1 chưa xác định) — lượt đó chạy trong lúc có process pytest/Godot khác va chạm port 7777. Lượt này wiring 32/32, và chạy riêng `test_power_graph_consumer_cheating` 4/4 OK (24.70s) → 2 fail kia nhiều khả năng là flake port-7777, không phải regression từ driver change N2251. Gate full sẽ là bằng chứng quyết định.

- Test RED `test_c07_item_turret_validate_target.py` (4 tests, mẫu N2250) + register script `register_c07_item_turret_validate_target.py` + `--verify` 25/25.
- Targeted RED: 4 failed in 1.11s–4.58s (pytest, PATH += ~/workspace/godot-bin; `godot` không có sẵn trên PATH mặc định):
  - registration: `KeyError: 'N2251'` (ledger chưa có N2251) — đúng kỳ vọng.
  - evidence: `KeyError: 'N2251'` — đúng kỳ vọng.
  - behavior: `AssertionError: 'static func source_item_turret_validate_target_state(...)' not found in SourceItemTurretBuildState.gd` — hàm chưa tồn tại, đúng kỳ vọng.
  - proof: Godot 4.6.2 returncode 1, `ERROR: Cannot open file 'res://tools/runtime_proofs/C07ItemTurretValidateTargetProof.tscn'` — proof chưa tồn tại, đúng kỳ vọng.
- javalang 0.13.0 + pytest 9.2.0 đã cài sẵn (kiểm tra import OK trước khi chạy, không cần cài lại).
- Port 7777 trống; không chạy Godot proof trong lượt này (chỉ test RED gọi Godot và fail vì thiếu scene).
- Không sửa file .gd nào, không stage/commit/push gì, không chạy gate full.

## Scope (đã khóa, xác minh từ đĩa — xem `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2251-item-turret-validate-target-scope.md`)

- Slice validateTarget: pure predicate, không scan. findTarget (bestEnemy/bestTarget, Turret.java:651-662) vẫn HOÃN — cần live entity list, cùng họ BLOCKED với suppression/targets live list.
- `validateTarget()` (Turret.java:631-633): `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();`
- `Units.invalidateTarget` (Units.java:151-157) + overload không range (Units.java:160-162) → range = Float.MAX_VALUE → mệnh đề range CHẾT trong validateTarget: pure function KHÔNG nhận param range.
- `canHeal()` (Turret.java:635-637): `targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals()`.

## Pin đã đo ở bước RED (từ đĩa, KHÔNG đoán)

- **Team.derelict id = 0** — Team.java:33: `derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),` (sharded 1, crux 2, malis 3, green 4, blue 5, neoplastic 6).
- **targetHealing default false** — Turret.java:95: `public boolean targetHealing = false;`. Duo def (Blocks.java:3257–3324) KHÔNG set targetHealing (grep exit 1) → duo targetHealing = false, nhánh derelict chết với duo; pure function vẫn nhận `target_same_team_effective` đã resolve sẵn để các def ItemTurret sau dùng được.
- **controlled()/logicControlled()**: Turret.java:441-443 `controlled(){ return unit.isPlayer(); }`, :445-447 `logicControlled(){ return logicControlTime > 0; }` (field `public float curRecoil, heat, logicControlTime = -1;`, Turret.java:284). Trong port: KHÔNG có frame flag `controlled`/`logic_controlled` nào trong SourceTurretBuildState.gd hay SourceItemTurretBuildState.gd (grep 0 kết quả) — driver/proof stamp từ frame với default false; live player/logic wiring chờ slice riêng.
- **Lệch scope (ghi nhận, không sửa scope)**: scope nói driver "nhận target_valid hardcode `true` ở SourceTurretBuildState.gd:285" — trên đĩa driver truyền `bool(frame.get("has_target", false))` làm target_valid (dòng gọi aim/shoot). GREEN thay bằng `bool(validate.get("valid", false))` theo đúng thiết kế (thay verdict tính được, không phải thay literal true).
- Frame target dict hiện có keys {"x", "y", "vx", "vy", "hit_size"} (proof fixture C07ItemTurretAimShootProof.gd:129) — KHÔNG có team/health/targetable; các bool đó driver/test stamp từ frame với default vacuous (health_valid / unit_targetable true, same_team / controlled / logic_controlled false), KHÔNG bịa key mới vào dict target.

## Thiết kế slice (đã khóa ở RED, test đã pin)

- 1 pure function `source_item_turret_validate_target_state(target_is_null: bool, target_same_team_effective: bool, target_health_valid: bool, target_unit_targetable: bool, controlled: bool, logic_controlled: bool) -> Dictionary:` trong `SourceItemTurretBuildState.gd`.
- Công thức: `invalidate = target_is_null or target_same_team_effective or not target_health_valid or not target_unit_targetable`; `valid = not invalidate or controlled or logic_controlled` (kể cả target null, controlled/logicControlled vẫn cứu valid = true, đúng Java `||`).
- Result keys: `valid`, `target_cleared` (= !valid).
- 1 dòng driver tick ở đầu nhánh duo trong `source_turret_tick_buildings_state` (trước lệnh gọi aim/shoot N2250): gọi pure function với các bool từ frame (`frame.get("target", null) == null`, `target_same_team_effective` / `target_health_valid` / `target_unit_targetable` / `controlled` / `logic_controlled`); nếu !valid → `frame["target"] = null`, `frame["has_target"] = false`; và thay arg target_valid của lệnh gọi aim/shoot bằng `validate.get("valid", false)`.
- 8 proof keys đã pin trong test: `validate_null_target_invalid`, `validate_same_team_invalid`, `validate_dead_target_invalid`, `validate_untargetable_unit_invalid`, `validate_controlled_saves_invalid_target`, `validate_logic_controlled_saves_invalid_target`, `validate_healthy_enemy_valid`, `validate_driver_clears_invalid_target`.

## SSOT baseline (đo từ đĩa 2026-11-18, = trạng thái N2250)

- symbols 11587 / Done 1700 / contracts 1634 / schemas 3059.
- Defense shard slices 179, contracts 178.
- Kỳ vọng sau GREEN: symbols +2 (2 result keys), Done +1, contracts +1, schema +1 → 11589/1701/1635/3060; defense shard slices 179 → 180. (Xác minh lại từ đĩa ở bước GREEN — không lấy số này làm bằng chứng.) **SỬA 00:00: schema thực tế +2 → 3061 (2 result keys valid/target_cleared); SSOT chốt 11589/1701/1635/3061.**

## GREEN plan (đã xong 2026-11-18 ~23:1x +07, main thread — xem Status)

1. Pure function + comment Java lines đã pin trong `SourceItemTurretBuildState.gd`, theo đúng chữ ký test RED đã khóa (6 bool params, thứ tự như test). ✅ (worker GREEN, main thread verify từ git diff)
2. 1 dòng driver tick trong `SourceTurretBuildState.gd` (đầu nhánh duo, trước lệnh gọi aim/shoot N2250): gọi pure function, clear target khi invalid, thay arg target_valid bằng verdict. ✅
3. Register main đã chạy → ledger N2251; targeted 4/4 → family + wiring → Godot proof mới `C07ItemTurretValidateTargetProof` (.gd + .tscn, headless Godot 4.6.2 Linux; 8 proof keys đã pin trong test). ✅ — proof JSON `matches:true`, 11/11 true.
4. Gate full: CHỈ main thread launch, sau khi ps sạch (không còn pytest/unittest). ✅ ĐÃ chạy + xác minh ở lượt cron 00:00 — gate 2 Ran 6097, failures 201 toàn Godot-absent (xem Status). Không commit/push khi chưa đủ điều kiện (test + proof + gate xanh) — nay đã đủ.

## Commits

- Slice `0ecc5608` — C07: N2251 ItemTurret validateTarget (1 pure function + driver tick for duo, proof 8 keys).
- Docs `059a737d` — report + handoff + design spec.
- GOAL `0f04cc2e` — GOAL.md §5 names the slice commit.
- (hashes / handoff-status theo sau — xem report)
