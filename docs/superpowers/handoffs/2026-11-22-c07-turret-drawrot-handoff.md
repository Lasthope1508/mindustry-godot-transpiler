# Handoff — N2532 Turret `drawrot()`: pure function cho Turret family (C07) [DONE + PUSHED (slice 4aedbbf6, docs 710afe02, GOAL 6c36b912)]

## Status: DONE + PUSHED (lượt cron 15:45 +07 ngày 2026-11-22; slice 4aedbbf6, docs 710afe02, GOAL 6c36b912; push xong mới ghi origin/main ở đây sau khi push)

- N2531 DONE + PUSHED ~14:00 +07 ngày 2026-11-22, origin/main == 7155d98b
  (5 commit: slice 34cbcc90 + docs 903bf260 + GOAL b6d497fc + status fadcccac +
  hashes 7155d98b).
- N2532 slice commit 4aedbbf6 (11 file, 1100 insertions) — main thread xác minh
  độc lập lượt này: targeted 4/4 (22 subtests, 18.86s, re-run lượt này);
  neighbours 311 passed trong 1025.47s (NEIGHBOURS-EXIT 0 07:44:37Z, lượt
  partial trước 07:25 chết ~1 phút, log giữ riêng
  n2532-neighbours-partial-run1-0725.log); wiring 32 OK trong 126.151s
  (WIRING-EXIT 0 07:46:43Z); gate Ran 6337 trong 1230.789s, failures=261,
  skipped=5 (GATE-START 07:48:04Z chết theo VM restart #27 lúc 08:05Z,
  partial giữ riêng full-suite-n2532-gate-partial-restart27.log; GATE-START
  08:18:08Z chết ~90s sau launch, partial giữ riêng
  full-suite-n2532-gate-partial-run2-0818.log; GATE-START 08:20:25Z
  main-thread launch, GATE-EXIT 1 08:40:58Z) — phân rã theo FAIL block:
  261 FAIL = 260 × `AssertionError: unexpectedly None` thuần + 1 × hydration
  pre-existing (test_liquid_consumer_hydration.py:66, message `Godot
  required for hydration proof` — chuỗi hydration xuất hiện 2 lần nhưng cả
  2 lần thuộc CÙNG 1 failure block), 0 KeyError, 0 return_schema_linkage,
  0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2531).
  Proof matches:true (8 semantic / 11 tổng, proof .json đọc trực tiếp lượt
  này — tái sinh 08:47:59Z bởi targeted re-run của main thread).
- N2532 = port `drawrot()` của `TurretBuild` thành 1 pure function cho
  Turret family. Scope khóa lượt implement, kiểm tra từ upstream Java + port
  + catalog trực tiếp trên đĩa (scope file
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2532-scoping.md`).

## Scope (khóa)

- MỘT pure function mới `source_turret_drawrot_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd` (:704, chèn sau
  `source_turret_fog_radius_state` :665-702, trước
  `source_turret_can_heal_state`) + 1 register file + 1 test file +
  1 proof — KHÔNG driver tick call site (drawrot() là read, không phải
  per-tick; caller duy nhất là draw code, rendering nằm ngoài game).
- Công thức (Turret.java:359-362, TurretBuild override):
  `rotation - 90` — trả đúng 1 key `drawrot`.
- Tham số (param-driven, mẫu N2528–N2531, KHÔNG đoán catalog trong
  hàm): `rotation: float` — aim rotation tính bằng độ, field
  `BaseTurret.java:114` (`public float rotation = 90;`), mặc định 90.

## Java evidence (đọc trực tiếp lượt implement, khớp scope)

- `Turret.java:358-362` `drawrot()`: `@Override` /
  `public float drawrot(){` / `return rotation - 90;` / `}`.
- `rotation` là field của `BaseTurretBuild`, KHÔNG phải `Building.rotation`:
  `BaseTurret.java:114` `public float rotation = 90;` — aim rotation tính
  bằng độ, mặc định 90. Nó SHADOW field `Building.rotation` (0-3 quadrants);
  bằng chứng: `Turret.java:543-544` comment `//sync underlying rotation;
  0-3 rotation is a shadowed field` + `((Building)this).rotation =
  Mathf.mod(Mathf.round(rotation / 90f), 4);`.
- Vòng đời của `rotation` (khẳng định đây là aim rotation, không phải
  quadrant): cập nhật mỗi tick `Turret.java:666` (`rotation =
  Angles.moveToward(rotation, targetRot, rotateSpeed * delta() *
  potentialEfficiency);`); persist `write.f(rotation)` :834 /
  `rotation = read.f();` :843; sync giữ nguyên :855-859; khởi tạo lúc đặt
  `Turret.java:273` (`turret.rotation = tile.build.rotdeg();`).
- Base method bị override: `BuildingComp.java:586-589` —
  `public float drawrot(){ return block.rotate && block.rotateDraw ?
  rotation * 90 : 0f; }` (dùng quadrant `rotation * 90`). Turret override
  BỎ QUA `block.rotate` / `block.rotateDraw`, dùng aim rotation − 90.
  KHÔNG nhầm với `SourceBuildingDrawState.drawrot_state` (quadrants × 90)
  — đó là port của base, khác hàm. KHÔNG nhầm với
  `SourcePointDefenseTurretBuildState.gd:678` `var draw_rotation: float =
  rotation - 90.0` (key `"draw_rotation"`, port của
  `PointDefenseBuild.draw()`, khác hàm, khác key — không clash).
- Override duy nhất trong cây Turret: grep `drawrot` toàn
  `mindustry-upstream/core/src` chỉ trúng `BuildingComp.java:587` (base),
  `Turret.java:359` (override này), và các caller draw `DrawTurret.java`,
  `DrawDefault.java:13` (`Draw.rect(..., build.drawrot())`). Không có
  `ItemTurret` / `TractorBeamTurret` / `PointDefenseTurret` override riêng —
  mọi subclass Turret thừa hưởng override này.
- Caller đều là draw code (rendering), không có caller logic nào.

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2524/N2527/N2531)

- DORMANT live hôm nay: drawrot() là read, không caller nào đọc nó hôm
  nay, driver tick chưa gọi hàm này → live behavior KHÔNG đổi. Khi slice
  Turret draw về, hàm này là canonical owner duy nhất của Turret drawrot().
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.
  Java không guard clamp/wrap trong drawrot() (Turret.java:584 chỉ guard
  trong updateTile, không trong drawrot) nên rotation âm và >360 đi qua
  nguyên vẹn.

## Files (mirror N2531)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_drawrot_state` (:704, defense shard, Turret.java route
  về defense). Diff: +39 dòng.
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_drawrot.py`
  (4 tests: registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_turret_drawrot.py`
  (`--verify` 6/6, xác minh lượt này).
- `C07TurretDrawrotProof.gd` + `.tscn` (8 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- SSOT thay đổi (đo từ đĩa lượt này): symbols/Done/contracts/schemas
  11725/1760/1693/3177 → 11726/1761/1694/3179 (+1/+1/+1/+2);
  defense 218/217 → 219/218; comp 572/475 KHÔNG đổi (không file comp nào
  sửa trong slice này); deferred pool 489 → 491 (+2: 1 ghi drawrot() DONE
  + 1 nợ Windows). 7 file modified (SourceTurretBuildState.gd + 6 SSOT
  JSON), 677 insertions.
- Spec Done +1 + row N2532; GOAL §5 thêm dòng nợ Windows sau dòng N2531 —
  XONG (docs commit + GOAL commit lượt này).

## Quy trình lượt implement (theo AGENTS.md + mẫu N2528–N2531)

1. RED tests trước, chạy targeted xác nhận fail đúng (lượt implement).
2. GREEN minimal → targeted xanh 4/4 → register `--verify` 6/6 →
   register chạy OK (xác minh lại lượt này: targeted 4/4, 22 subtests,
   18.86s; register 6/6).
3. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với
   agent kia; export `~/workspace/godot-bin` lên PATH trước khi chạy test
   reference-graph/proof — `godot` không có trên PATH mặc định, bài học
   N2530): matches:true, 8 semantic keys xanh (proof .gd mtime 07:21:20Z
   ~14:21 +07; .json đọc trực tiếp lượt này, tái sinh 08:47:59Z bởi
   targeted re-run của main thread).
4. Neighbours + wiring + full gate — main thread launch lượt này, XONG:
   neighbours 311 passed (1025.47s), wiring 32 OK (126.151s), gate Ran
   6337, failures=261 (260 × unexpectedly None thuần + 1 hydration
   pre-existing).
5. Gate xanh (phân rã theo FAIL block) → slice commit 4aedbbf6 xong lượt
   này; docs + GOAL + status + hashes commit rồi push mẫu 5 commit, bump
   Done 1760→1761 (đo từ đĩa). `git diff --check` SẠCH. Không stage
   *.gd.uid / project.godot / arc-upstream/ / mindustry-upstream/ /
   proof .json / full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2532-scope)

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

## Next sau N2532 (ứng viên theo thứ tự Turret.java, chưa scope)

- `UnitType.estimateDps()` (UnitType.java:1132-1144): `dpsEstimate =
  weapons.sumf(Weapon::dps)`, suicide bullet (`killShooter`) thì `/= 15f`,
  cache `dpsEstimate` (khởi −1) — đệ quy/caching, cần scope riêng:
  `Weapon.dps` là param hay slice khác, cache ghi ở đâu (pure function
  không giữ state), `dpsEstimate` init ở đâu.
- `calculateHeat` vẫn BLOCKED, `findTarget` BLOCKED.
