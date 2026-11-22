# Handoff — N2530 Turret `canControl()`: pure function cho Turret family (C07) [SCOPED]

## Status: DONE + PUSHED (lượt cron 12:15 +07 ngày 2026-11-22; slice 611231fe, docs TBD, GOAL TBD, status TBD)

- N2529 DONE + PUSHED ~10:45 +07 ngày 2026-11-22, origin/main == 50bde34b
  (5 commit: slice a1edad54 + docs 55c03447 + GOAL 3acf931d + status 59cdb8b8 +
  hashes 50bde34b).
- N2530 implement xong lượt này: 1 pure function
  `source_turret_can_control_state(player_controllable)` trong
  `SourceTurretBuildState.gd` (sau estimate_dps :630, trước can_heal) +
  register `register_c07_turret_can_control.py` + test
  `test_c07_turret_can_control.py` + proof `C07TurretCanControlProof.gd/.tscn`
  — KHÔNG driver tick. RED xác nhận fail đúng (KeyError 'N2530'); GREEN:
  targeted 4/4 (24 subtests), proof matches:true (8 semantic / 11 tổng),
  register --verify 8/8, `git diff --check` SẠCH.
- SSOT đo từ đĩa sau register: 11724/1759/1692/3175 (+1/+1/+1/+2 đúng dự kiến);
  defense shard 217/216; comp 572/475 KHÔNG đổi; deferred pool 487 (+2:
  1 DONE canControl + 1 nợ Windows).
- Hai lỗi lúc implement (đã sửa, không phải lỗi Java): (1) comment .gd
  wrap 2 dòng Java (`public boolean playerControllable = true;` và javadoc
  ControlBlock) khiến assertIn fail — đã gộp lại 1 dòng; (2) test
  reference-graph fail vì `godot` không có trên PATH của shell worker —
  chain script export `~/workspace/godot-bin` lên PATH (mẫu n2528/n2529),
  chạy lại targeted với PATH đó thì xanh.
- Neighbours + wiring + full gate ĐÃ XONG lượt cron 12:15 +07: neighbours
  303 passed trong 1014.26s (NEIGHBOURS-EXIT 0 04:11:43Z), wiring 32 tests
  OK trong 127.844s (WIRING-EXIT 0 04:13:51Z), gate Ran 6329 trong
  1221.013s, failures=259, skipped=5 — xác minh độc lập theo FAIL block:
  258 × `unexpectedly None` thuần + 1 × hydration pre-existing, 0 KeyError,
  0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1
  failure đúng mẫu vs N2529). Gate 2 lượt đầu chết (VM restart #25 lúc
  04:37Z + drain timeout), lượt 3 (GATE-START 04:50:41Z) sống tới
  GATE-EXIT 1 05:11:04Z. Chain log
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2530-chain.log`,
  gate log tools/mindustry_godot_transpiler/full-suite-n2530-gate.log.
- Commit + push mẫu 5 commit (slice 611231fe + docs + GOAL + status +
  hashes), bump Done 1758→1759, GOAL §5 thêm dòng nợ Windows sau dòng
  N2529. Không stage *.gd.uid / project.godot / arc-upstream/ /
  mindustry-upstream/ / proof .json.
- Không có gate/proof/process nào đang chạy; port 7777 free (kiểm tra
  đầu lượt: javalang 0.13.0, pytest 9.2.0).
- ĐÍNH CHÍNH SỐ HIỆU: bản nháp đầu của file này ghi N2528 là SAI — N2528 đã
  được scope lượt cron 07:05 là Turret `estimateDps()` (scope file
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2528-scoping.md`,
  `source_turret_estimate_dps_state`, chưa implement), và N2529 là ứng viên
  cho `BulletType.estimateDPS()` (Turret.java:329-333 đọc nó; BulletType.java:
  414-435 chưa port). Slice canControl này là **N2530**, scope sau N2528/N2529.
- N2530 = port `canControl()` của `TurretBuild` thành 1 pure function cho
  Turret family. Scope khóa lượt này, kiểm tra từ upstream Java + port +
  catalog trực tiếp trên đĩa.

## Scope (khóa)

- MỘT pure function mới `source_turret_can_control_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd` (chèn sau
  `source_turret_status_state`, :499–:573, trước
  `source_turret_can_heal_state` :574) + 1 register file + 1 test file +
  1 proof — KHÔNG driver tick call site (canControl() là read predicate,
  không phải per-tick; không caller nào đọc nó hôm nay, player control /
  UI là C11).
- Công thức (Turret.java:376-379, override ControlBlock default):
  `return player_controllable;` — trả đúng 1 key `can_control`.
- Tham số: `player_controllable: bool` duy nhất. Đây là block field
  `playerControllable` (Turret.java:97, default `true`), KHÔNG hardcode:
  hàm nhận param tường minh theo mẫu N2526/N2527 (param-driven, không đoán
  catalog trong hàm).
- Base bị override: `ControlBlock.java:15-17` default `canControl()` trả
  `true`; Turret thu hẹp thành field `playerControllable`. Không có
  per-def override trong Blocks.java (grep `playerControllable` trong
  Blocks.java = 0 kết quả) nên catalog hôm nay đồng nhất `true` — nhưng
  hàm vẫn nhận param để giữ trung thực với Java.
- KHÔNG nhầm với `canControlSelect` (BuildingComp.java:677, method khác,
  đã có stub `source_building_can_control_select_state` trong
  SourceBuildingControlState.gd) và KHÔNG nhầm với
  `SourceUnitLifecycleState.player_controllable_state` (mức Unit type,
  khác hàm).
- Mirror N2527 (test 4 file: registration, input-evidence, state,
  reference-graph; register `--verify`; proof 8 semantic keys + registry_valid
  + one_headquarter_per_ssot + matches, mẫu N2527).

## Java evidence (đọc trực tiếp lượt scope)

- `Turret.java:376-379` `canControl()`: `@Override` /
  `public boolean canControl(){` / `return playerControllable;` / `}`.
- `Turret.java:97` field: `public boolean playerControllable = true;`.
- `ControlBlock.java:15-17` default: `/** @return whether this block can
  be controlled at all. */` / `default boolean canControl(){` /
  `return true;` / `}`.
- `BuildTurret.java:103-105` `canControl()` trả `true` — family khác
  (BuildTurret), KHÔNG thuộc N2528.

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2524/N2527)

- DORMANT live hôm nay: canControl() là read predicate, không caller nào
  đọc nó hôm nay (player control / UI là C11), driver tick chưa gọi hàm
  này → live behavior KHÔNG đổi. Khi C11 player control về, hàm này là
  canonical owner duy nhất của Turret canControl().
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.

## Files (dự kiến, mirror N2527)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_can_control_state` (sau :573, defense shard, tiền lệ
  N2523/N2524/N2525/N2526/N2527: Turret.java route về defense).
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_can_control.py`
  (4 tests: registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_turret_can_control.py`
  (`--verify`).
- `C07TurretCanControlProof.gd` + `.tscn` (8 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- SSOT dự kiến (đo lại từ đĩa lượt đóng slice, mẫu N2527 +1/+1/+1/+2 so với
  trạng thái lúc đóng — lúc đó N2528 + N2529 đã xong):
  symbols/Done/contracts/schemas +1/+1/+1/+2;
  defense +1/+1; comp 572/475 KHÔNG đổi;
  deferred pool dự kiến +2 (1 ghi canControl() WIRED/DONE + 1 nợ Windows).
- Spec Done +1 + row N2530; GOAL §5 thêm dòng nợ Windows sau dòng N2529.

## Quy trình lượt implement (theo AGENTS.md + mẫu N2524/N2525/N2526/N2527)

1. RED tests trước (player_controllable true → can_control true /
   false → false; registration; input-evidence; reference-graph), chạy
   targeted xác nhận fail đúng.
2. GREEN minimal → targeted xanh → register `--verify`.
3. Neighbours + wiring + full gate — CHỈ main thread launch (worker KHÔNG
   launch; kiểm tra chain log không có START song song; kiểm tra sống sót
   sau 45–60s; kiểm tra lại javalang/pytest sau mỗi VM restart).
4. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với
   agent kia).
5. Gate xanh (phân rã theo FAIL block: N thuần + 1 hydration pre-existing)
   → commit + push mẫu 5 commit, bump Done +1 (đo từ đĩa). `git diff --check`
   SẠCH. Không stage *.gd.uid / project.godot / arc-upstream/ /
   mindustry-upstream/ / proof .json / full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2530-scope)

- Turret live hasAmmo() computation — DEFERRED (hasAmmo MUTATES ammo stack,
  Turret.java:703; cần caller slice đọc tick ammo stacks + canConsume live +
  ammoPerShot per-def; C11 status display đọc `status` cũng là slice sau).
- Turret range() consumers — findTarget (Turret.java:652-656, BLOCKED — live
  entity scan) + aim within-check rewire (slice consumer riêng).
- Turret sense frame per-graph split — DEFERRED (chờ PowerGraph.addGraph merge
  port; `addGraph` hiện chỉ là source-text constant `java_method_addGraph_20`,
  chưa port).
- Compose SenseI leg (N2510) với dispatch ở caller — chờ logic-executor driver
  (chưa có LExecutor instruction loop trong port).
- Live player-unit source cho `unit_is_player` — chờ player control.
- Turret liquid-module wiring (frame liquid state + coolant pick live) —
  BLOCKED cho driver tick của hàm N2525.
- LaserTurret shouldConsume() (LaserTurret.java:55) — needs a per-build
  bullets list + LaserTurret driver.
- calculateHeat — BLOCKED (live entity scan); findTarget — BLOCKED (live
  entity scan).

## Next sau N2530 (ứng viên theo thứ tự Turret.java, chưa scope)

- `fogRadius()` (Turret.java:420-423): `(range + (hasAmmo() ?
  peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier` — cần
  range() (N2526) + hasAmmo param + peekAmmo rangeChange + tilesize +
  fogRadiusMultiplier.
- `drawrot()` (Turret.java:359-362): `return rotation - 90;` — trivial.
- `getAmmoFraction()` base (Turret.java:324-327): `return 1f;` — trivial,
  KHÔNG phải slice (scope 07:05 đã xác nhận; bản ItemTurret đã có
  `get_ammo_fraction_state` từ base df47a96).
- LƯU Ý: `estimateDps()` (Turret.java:329-332) KHÔNG còn là ứng viên — đã là
  N2528 (scope 07:05); `BulletType.estimateDPS()` là ứng viên N2529.
