# Báo cáo — N2281 Turret canHeal() live derivation (C07) [DONE, chờ push]

Ngày: 2026-11-20 ~14:0x +07 (GREEN), gate xong 15:06:49 +07, push ~15:2x +07.

## Trạng thái

- N2280 DONE + PUSHED (origin/main df426c4e).
- N2281 DONE, chờ push (slice commit TBD, docs TBD, GOAL TBD, status TBD, hashes TBD): Turret canHeal() live derivation — `protected boolean canHeal(){ return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals(); }` (Turret.java:635-637) — targetHealing false cho duo (Turret.java:95, duo không set), collidesTeam default false (BulletType.java:127, catalog không có key), heals() false cho duo (BulletType.java:447-449, duo ammo không set healPercent/healAmount). Cả hai consumer Java (validateTarget :632, findTarget :660) đều cần live entity scan nên KHÔNG rewire — stamp-only như N2280.

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_turret_can_heal_state` (4 params target_healing, has_ammo, ammo_collides_team, ammo_heals; 1 key: can_heal) trong SourceTurretBuildState.gd:162, ngay TRƯỚC `source_turret_logic_controlled_state` (mirror Java order — validateTarget :491 gọi canHeal trước isShooting :492).
- Driver tick trong `source_turret_tick_buildings_state` (:1382-1383), ngay TRƯỚC tick logic_controlled và trước lời gọi validateTarget, stamp `frame["can_heal"]` từ `false` literal (target_healing), `not duo_entries.is_empty()` (has_ammo, live), `bool(duo_ammo_data.get("collidesTeam", false))` (default BulletType.java:127), `bool(float(duo_ammo_data.get("healPercent", 0.0)) > 0.0 or float(duo_ammo_data.get("healAmount", 0.0)) > 0.0)` (BulletType.java:447-449).
- KHÔNG rewire consumer nào: effective-team resolution trong validateTarget vẫn đọc frame["target_same_team_effective"] (do test/fixture stamp), chờ findTarget slice; can_heal live sẽ feed nó khi đó.
- Proof 6 keys: matches:true, 9/9 true (đọc trực tiếp từ C07TurretCanHealProof.json — GREEN ~14:0x +07). Key `can_heal_stamped_to_frame` chứng minh driver stamp live (duo mặc định, 1 tick → key present, false).
- `register_c07_turret_can_heal.py --verify`: 10/10 exprs present (re-run độc lập main thread ~15:1x, exit 0). SSOT đo từ đĩa: 11658/1731/1665/3121 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 208, contracts 207. Đúng kỳ vọng scope.

## Test xanh/đỏ

- Xanh: targeted 4/4 (19 subtests, 19.48s re-run độc lập main thread ~15:1x, Godot trên PATH); neighbours 191 passed (641.78s, exit 0, log hidden_files/n2281-neighbours.log); wiring 32 tests OK trong một batch (Ran 32 in 128.851s, không flake, log hidden_files/n2281-wiring.log); `git diff --check` OK.
- Gate: xong — lần 1 (PID 10819, GATE-START 07:19:16Z) chết do VM restart ~07:33Z; lần 2 relaunch main-thread GATE-START 07:46:12Z, GATE-EXIT 1 08:06:49Z (log full-suite-n2281-gate.log, chain log hidden_files/n2281-chain.log). Ran 6217 trong 1142.721s, failures=231, skipped=5 — xác minh độc lập: 231 FAIL = 231 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2280). Một launch trùng của worker lúc 07:47Z đã bị kill theo quy tắc (partial log, không có tổng kết).
- Đỏ: không có test đỏ ngoài 231 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker. Port 7777 free trước mỗi proof run (đã kiểm tra bằng `ss -ltn | grep 7777`).

## Bước tiếp theo

- Push N2281 (slice + docs + GOAL + status + hashes, theo mẫu N2280).
- Slice tiếp theo: N2282 — chọn từ deferred list (calculateHeat vẫn BLOCKED; shootp live wiring cần logic executor; findTarget BLOCKED; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice).
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-can-heal-handoff.md.
