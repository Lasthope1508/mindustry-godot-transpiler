# Handoff — N2281 Turret canHeal() live derivation (C07) [GREEN, chờ gate main-thread]

## Status: DONE + PUSHED (slice 6865ec40, docs 59ac3a51, GOAL 464738b0; cập nhật lượt cron 15:15 +07 — gate lần 2 main-thread xong GATE-EXIT 1 08:06:49Z, Ran 6217 trong 1142.721s, failures=231, skipped=5; xác minh độc lập: 231 FAIL = 231 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent; lần 1 PID 10819 chết do VM restart ~14:33 +07, launch trùng của worker 07:47Z bị kill theo quy tắc). Neighbours XONG 191/191, exit 0, 07:05:12–07:15:54Z; wiring XONG 32 tests OK, exit 0, 07:15:54–07:18:03Z. N2280 đã DONE + PUSHED (df426c4e). Slice commit 6865ec40, docs 59ac3a51, GOAL 464738b0, status TBD. Targeted 4/4 (19 subtests, re-run độc lập main thread ~15:1x, 19.48s); register --verify 10/10 (main thread re-run độc lập ~15:1x, exit 0); proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, main thread xác minh); SSOT đo từ đĩa 11658/1731/1665/3121; `git diff --check` OK. KHÔNG launch thêm gì khi gate đang chạy; KHÔNG chạy proof scene song song (va chạm port 7777).

## Scope (đã khóa, xác minh từ đĩa — xem docs/superpowers/handoffs/hidden_files/n2281-scope.md)

- Slice: Turret `canHeal()` derivation — `protected boolean canHeal(){ return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals(); }` (Turret.java:635-637).
- `public boolean targetHealing = false;` (Turret.java:95). Duo KHÔNG bao giờ set targetHealing (grep khối duo Blocks.java:3257-3331: không có) → false cho duo.
- `public boolean collidesTeam = false;` (BulletType.java:127). Duo ammo catalog (content_registry_blocks.json, godot-mindustry/src/generated/source_modules/) không có key collidesTeam → default false.
- `public boolean heals(){ return healPercent > 0 || healAmount > 0; }` (BulletType.java:447-449); `healPercent = 0f` (:165), healAmount default 0f. Duo ammo (copper/graphite/silicon BasicBulletType, Blocks.java:3259-3295) không set healPercent/healAmount, catalog cũng không có key → heals() false cho duo.
- `hasAmmo()` là `public boolean hasAmmo(){` (Turret.java:698) — driver đọc live `not duo_entries.is_empty()` (duo ammo stacks, tiền lệ N2240/N2247).
- Pure function: `source_turret_can_heal_state(target_healing: bool, has_ammo: bool, ammo_collides_team: bool, ammo_heals: bool) -> Dictionary`, trả `{"can_heal": target_healing and has_ammo and ammo_collides_team and ammo_heals}` — Java :636 verbatim. Placement: ngay TRƯỚC `source_turret_logic_controlled_state` (SourceTurretBuildState.gd:162 — mirror Java order: validateTarget :491 gọi canHeal, trước isShooting :492).
- Driver tick placement: trong duo branch, ngay TRƯỚC tick logic_controlled (:1382-1383, trước lời gọi validateTarget): stamp `frame["can_heal"]` từ `target_healing` = false literal, `has_ammo` = `not duo_entries.is_empty()` (live), `ammo_collides_team` = `bool(duo_ammo_data.get("collidesTeam", false))` (default BulletType.java:127), `ammo_heals` = `bool(float(duo_ammo_data.get("healPercent", 0.0)) > 0.0 or float(duo_ammo_data.get("healAmount", 0.0)) > 0.0)` (BulletType.java:447-449). KHÔNG rewire validateTarget, KHÔNG đổi gameplay.
- Consumers (KHÔNG rewire): canHeal() được validateTarget gọi (Turret.java:632, `canHeal() ? Team.derelict : team`) và findTarget gọi (:660, `if(target == null && canHeal()){ target = Units.findAllyTile(...); }`). Cả hai đều cần live entity scan nên CHƯA rewire — stamp-only như N2280. Effective-team resolution trong validateTarget vẫn đọc frame["target_same_team_effective"] (do test/fixture stamp), chờ findTarget slice; can_heal live sẽ feed nó khi đó.
- Proof keys (6 semantic + registry_valid + one_headquarter_per_ssot + matches = 9): can_heal_true_all_clauses (true,true,true,true → true), can_heal_false_when_not_target_healing (false,true,true,true → false), can_heal_false_when_no_ammo (true,false,true,true → false), can_heal_false_when_ammo_not_collides_team (true,true,false,true → false), can_heal_false_when_ammo_not_heals (true,true,true,false → false), can_heal_stamped_to_frame (driver: duo mặc định, 1 tick → key present, false).
- New result-key symbols (1): `source_turret_can_heal_state_result.can_heal`. Expected SSOT sau GREEN: 11658/1731/1665/3121 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 207 → 208, contracts 206 → 207.
- Register script `register_c07_turret_can_heal.py` mirror N2280, import DEFERRED từ `register_c07_turret_is_active`. Test file `tests/test_c07_turret_can_heal.py` mirror N2280 (4 tests). EXACT_EXPRS (5, đều verbatim trong upstream): `protected boolean canHeal(){`, `return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();`, `public boolean targetHealing = false;`, `public boolean collidesTeam = false;`, `return healPercent > 0 || healAmount > 0;` — expr 4-5 nằm trong BulletType.java nên SLICE_SOURCES gồm Turret.java + BulletType.java; register --verify kỳ vọng 10/10 (5 exact + 4 input + 1 output).
- SSOT baseline (đo từ đĩa trước GREEN): symbols 11657, Done 1730, contracts 1664, schemas 3119; defense slices 207, contracts 206. Sau GREEN: 11658/1731/1665/3121; defense 208/207.
- NOT this slice: validateTarget effective-team rewire (`canHeal() ? Team.derelict : team`, Turret.java:632) — chờ findTarget slice; findTarget ally-tile acquisition (:660) — BLOCKED, live entity scan; các def ItemTurret khác ngoài duo (epic nhiều slice); calculateHeat (BLOCKED); shootp live wiring (cần logic executor); `controlled()` (cần player unit); LaserTurret shouldConsume() (cần bullets live list); activation early-return skip (vacuous cho mọi def hiện tại).
- Deferred sau slice này: calculateHeat live proximity scan vẫn BLOCKED; shootp live wiring; findTarget BLOCKED; các def ItemTurret khác ngoài duo; live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture); `controlled()` live wiring (cần player unit); LaserTurret shouldConsume() consumer wiring (cần bullets live list); activation early-return skip (vacuous cho mọi def hiện tại); validateTarget effective-team live wiring (feed từ can_heal khi findTarget slice tới).

## GREEN (đã xong, lượt ~14:0x +07)

- Pure function `source_turret_can_heal_state` trong SourceTurretBuildState.gd:162 (4 params, 1 key) — ngay TRƯỚC `source_turret_logic_controlled_state`.
- Driver tick trong `source_turret_tick_buildings_state` (:1382-1383): gọi pure function với false literal / `not duo_entries.is_empty()` / `bool(duo_ammo_data.get("collidesTeam", false))` / healPercent-healAmount live, stamp frame["can_heal"], ngay trước tick logic_controlled và trước lời gọi validateTarget.
- RED trước GREEN: targeted 4 failed như kỳ vọng (chưa có pure function / driver tick / proof / SSOT đăng ký).
- Proof C07TurretCanHealProof.gd + .tscn (6 keys trên). Proof JSON đọc trực tiếp từ đĩa: matches:true, 9/9 true (6 semantic + matches + registry_valid + one_headquarter_per_ssot), GREEN ~14:0x +07 (trong lần chạy targeted với Godot trên PATH).
- `python3 register_c07_turret_can_heal.py --verify`: **10/10 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_can_heal.py -q` (từ tools/mindustry_godot_transpiler, Godot trên PATH): **4 passed, 19 subtests passed in 16.89s**.
- Neighbours: **191 passed** trong 641.78s (exit 0, 07:05:12–07:15:54Z; log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2281-neighbours.log`).
- Wiring: **32 tests OK** trong 128.851s (exit 0, 07:15:54–07:18:03Z; log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2281-wiring.log`).
- Gate: **XONG** — lần 1 (PID 10819, GATE-START 07:19:16Z) chết do VM restart ~07:33Z; lần 2 relaunch main-thread GATE-START 07:46:12Z, GATE-EXIT 1 08:06:49Z (log `tools/mindustry_godot_transpiler/full-suite-n2281-gate.log`, chain log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2281-chain.log`): Ran 6217 trong 1142.721s, failures=231, skipped=5 — xác minh độc lập: 231 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2280). Launch trùng của worker 07:47Z bị kill theo quy tắc (partial log, không tổng kết). Đủ điều kiện commit + push N2281 (slice + docs + GOAL + status + hashes, theo mẫu N2280).
- `git diff --check` OK.
- File thay đổi (slice commit TBD): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- SSOT đo từ đĩa sau GREEN: symbols 11658 (+1), Done 1731 (+1), contracts 1665 (+1), schemas 3121 (+2) → 11658/1731/1665/3121; defense slices 208, contracts 207. Đúng kỳ vọng scope.

## Tiếp theo (sau khi gate xong — main thread)

1. Commit + push N2281 (slice + docs + GOAL + status + hashes, theo mẫu N2280) — gate đã xanh theo mẫu, đã xác minh độc lập.
2. Chọn slice tiếp theo từ deferred list: N2282 — chọn từ deferred list: calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; `controlled()` live wiring cần player unit; LaserTurret shouldConsume() cần bullets live list; các def ItemTurret khác ngoài duo; validateTarget effective-team live wiring chờ findTarget slice.

## Deferred (không đổi, trừ canHeal() nay đã live)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
- `controlled()` live wiring (needs a player unit).
- LaserTurret shouldConsume() consumer wiring — cần bullets live list; chênh một tick snapshot (Java updateConsumption trước updateTile).
- Activation early-return skip — vacuous cho mọi def hiện tại.
- validateTarget effective-team live wiring (`canHeal() ? Team.derelict : team`, Turret.java:632) — chờ findTarget slice; can_heal live sẽ feed nó.
- findTarget ally-tile acquisition (`if(target == null && canHeal()){...}`, Turret.java:660) — BLOCKED, live entity scan.
