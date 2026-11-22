# Handoff — N2531 Turret `fogRadius()`: pure function cho Turret family (C07) [DONE + PUSHED (slice 34cbcc90, docs 903bf260, GOAL b6d497fc, status fadcccac)]

## Status: DONE + PUSHED (lượt cron 14:00 +07 ngày 2026-11-22; slice 34cbcc90, docs 903bf260, GOAL b6d497fc, status fadcccac; push xong mới ghi origin/main ở đây sau khi push)

- N2530 DONE + PUSHED ~12:15 +07 ngày 2026-11-22, origin/main == eafdfdb4
  (5 commit: slice 611231fe + docs 1d874d53 + GOAL d1b8433a + status 9eb0cce7 +
  hashes eafdfdb4).
- N2531 slice commit 34cbcc90 (11 file, 1226 insertions) — main thread xác minh
  độc lập lượt này: targeted 4/4 (25 subtests, 16.86s, re-run lượt này);
  neighbours 307 passed trong 1014.57s (NEIGHBOURS-EXIT 0 06:33:22Z, 2 lượt
  partial trước 05:55/05:58 chết theo mẫu drain timeout, log giữ riêng);
  wiring 32 OK trong 123.116s (WIRING-EXIT 0 06:35:25Z); gate Ran 6333 trong
  1227.548s, failures=260, skipped=5 (GATE-START 06:36:01Z chết ~2 phút, partial
  giữ riêng n2531-gate-partial-run1-0636.log; GATE-START 06:38:00Z main-thread
  launch, GATE-EXIT 1 06:58:29Z) — phân rã theo FAIL block: 259 ×
  `AssertionError: unexpectedly None` thuần + 1 × hydration pre-existing
  (test_liquid_consumer_hydration.py:66), 0 KeyError, 0 return_schema_linkage,
  0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2530).
  Proof matches:true (8 semantic / 11 tổng, proof .json mtime 07:01:07Z —
  tái sinh bởi targeted re-run của main thread lượt này).
- N2531 = port `fogRadius()` của `TurretBuild` thành 1 pure function cho
  Turret family. Scope khóa lượt này, kiểm tra từ upstream Java + port +
  catalog trực tiếp trên đĩa (scope file
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2531-scoping.md`).

## Scope (khóa)

- MỘT pure function mới `source_turret_fog_radius_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd` (chèn sau
  `source_turret_can_control_state` :632, trước
  `source_turret_can_heal_state`) + 1 register file + 1 test file +
  1 proof — KHÔNG driver tick call site (fogRadius() là read, không phải
  per-tick; không caller nào đọc nó hôm nay, fog-of-war / draw logic là
  slice sau).
- Công thức (Turret.java:420-422, TurretBuild override):
  `(range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier`
  — trả đúng 1 key `fog_radius`.
- Tham số (param-driven, mẫu N2528/N2529/N2530, KHÔNG đoán catalog trong
  hàm): `range_value: float` (block field `range`, KHÔNG phải range() —
  xem lưu ý dưới), `has_ammo: bool`, `peek_ammo_range_change: float`,
  `tilesize: int`, `fog_radius_multiplier: float`.

## Java evidence (đọc trực tiếp lượt implement, khớp scope)

- `Turret.java:420-422` `fogRadius()`: `@Override` /
  `public float fogRadius(){` /
  `return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;` /
  `}`.
- `Turret.java:343-347` `range()`: peekAmmo() != null → `range +
  peekAmmo().rangeChange`, ngược lại `range`. LƯU Ý: fogRadius() dùng
  field `range` + rangeChange có điều kiện `hasAmmo()`, KHÔNG gọi
  range() — nhưng giá trị bằng range() khi hasAmmo đúng và peekAmmo !=
  null; khi hasAmmo sai thì bằng field range. Hàm vẫn nhận
  `range_value` là field range, giữ đúng công thức Java.
- `hasAmmo()` (Turret.java:698-712, `public boolean hasAmmo(){` :698)
  MUTATES ammo stack (`ammo.swap(ammo.size - 1, i);`, :703) + đọc
  `canConsume()` → KHÔNG tính trong hàm, là param `has_ammo`
  (deferred live hasAmmo, xem handoff N2530).
- `peekAmmo().rangeChange` là param (`public float rangeChange = 0f;`,
  BulletType.java:157; tiền lệ N2526 range() nhận `range_change` param).
- `tilesize`: `public static final int tilesize = 8;` (Vars.java:135).
- `fogRadiusMultiplier`: `public float fogRadiusMultiplier = 1f;`
  (BaseTurret.java:24, default 1f). Một per-def override:
  `fogRadiusMultiplier = 0.4f;` (Blocks.java:5627, scathe —
  `scathe = new ItemTurret("scathe"){{` :5211).
- `range`: `public float range = 80f;` (BaseTurret.java:21).
- KHÔNG nhầm với block-init fogRadius (BaseTurret.java:59:
  `fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);`)
  — đó là field init ở block level, KHÔNG phải TurretBuild.fogRadius()
  override. Cũng KHÔNG nhầm với `SourceBlockInitFlagsSourceTextState.gd`
  guard `if(fogRadius > 0){` (source-text, đã có).
- Chưa có hàm fog nào trong SourceTurretBuildState.gd trước slice này
  (scope đã grep `source_turret_fog` = 0). Stub `java_method_fogRadius_43`
  chỉ là source-text ở SourceBuildingSourceTextState.gd.

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2524/N2527)

- DORMANT live hôm nay: fogRadius() là read, không caller nào đọc nó hôm
  nay, driver tick chưa gọi hàm này → live behavior KHÔNG đổi. Khi
  fog-of-war / draw logic về, hàm này là canonical owner duy nhất của
  Turret fogRadius().
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.

## Files (mirror N2530)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_fog_radius_state` (sau :632, defense shard, Turret.java
  route về defense). Diff: +39 dòng.
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_fog_radius.py`
  (4 tests: registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_turret_fog_radius.py`
  (`--verify` 13/13).
- `C07TurretFogRadiusProof.gd` + `.tscn` (8 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- SSOT thay đổi (đo từ đĩa): symbols/Done/contracts/schemas
  11724/1759/1692/3175 → 11725/1760/1693/3177 (+1/+1/+1/+2);
  defense 217/216 → 218/217; comp 572/475 KHÔNG đổi;
  deferred pool 487 → 489 (+2: 1 ghi fogRadius() DONE + 1 nợ Windows).
  7 file modified (SourceTurretBuildState.gd + 6 SSOT JSON), 758 insertions.
- Spec Done +1 + row N2531; GOAL §5 thêm dòng nợ Windows sau dòng N2530 —
  XONG (docs commit 903bf260 + GOAL commit b6d497fc).

## Quy trình lượt implement (theo AGENTS.md + mẫu N2528/N2529/N2530)

1. RED tests trước, chạy targeted xác nhận fail đúng (4 failed, 13.18s).
2. GREEN minimal → targeted xanh 4/4 (25 subtests, 14.14s) → register
   `--verify` 13/13 → register chạy OK.
3. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với
   agent kia; export `~/workspace/godot-bin` lên PATH trước khi chạy test
   reference-graph/proof — `godot` không có trên PATH mặc định, bài học
   N2530): matches:true, 8 semantic keys xanh.
4. Neighbours + wiring + full gate — main thread launch lượt này, XONG:
   neighbours 307 passed (1014.57s), wiring 32 OK (123.116s), gate Ran 6333,
   failures=260 (259 × unexpectedly None thuần + 1 hydration pre-existing).
5. Gate xanh (phân rã theo FAIL block) → slice commit 34cbcc90 xong lượt này;
   docs + GOAL + status + hashes commit rồi push mẫu 5 commit, bump Done
   1759→1760 (đo từ đĩa). `git diff --check` SẠCH. Không stage *.gd.uid /
   project.godot / arc-upstream/ / mindustry-upstream/ / proof .json /
   full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2531-scope)

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

## Next sau N2531 (ứng viên theo thứ tự Turret.java, chưa scope)

- `drawrot()` (Turret.java:359-362): `return rotation - 90;` — trivial.
- `UnitType.estimateDps()` — đệ quy từ N2529 (spawnUnit/despawnUnit DPS
  hiện là param, chưa port thật).
