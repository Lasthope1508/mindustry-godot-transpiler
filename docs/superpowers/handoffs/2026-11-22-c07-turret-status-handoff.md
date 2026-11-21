# Handoff — N2527 Turret `status()`: pure function cho Turret family (C07) [DONE]

## Status: DONE + PUSHED (gate lượt 2 xanh theo mẫu Godot-absent, xác minh độc lập lượt cron 06:45 +07 ngày 2026-11-22; slice bd0ea3c8, docs ef5272e3, GOAL d19606df, status TBD)

- N2526 DONE + PUSHED ~05:00 +07 ngày 2026-11-22, origin/main == HEAD == 19d62d1c
  (5 commit: slice cf949d7a + docs 97dc8203 + GOAL 057295b4 + status 5321486f + hashes 19d62d1c).
- N2527 implement xong (worker các lượt cron 05:15–06:30): 1 pure function
  `source_turret_status_state` + register + test + proof, chưa commit.
  Main thread lượt 06:45 xác minh độc lập: targeted 4/4 OK (29 subtests,
  16.16s, godot-bin trên PATH), register --verify 16/16, proof matches:true
  (8 semantic keys, đọc trực tiếp C07TurretStatusProof.json, mtime 23:16Z).
- Chain main-thread (log hidden_files/n2527-chain.log):
  NEIGHBOURS-START 22:49:36Z → EXIT 1 23:05:53Z, **290 passed + 1 failed
  (draw flake port-7777: test_reference_graph_and_actual_c07_point_defense_turret_draw)
  trong 976.44s**; re-run file draw isolated **4 passed / 36 subtests trong
  16.22s** → 291/291 SẠCH (log hidden_files/n2527-draw-flake-rerun.log);
  WIRING-START 23:05:53Z → EXIT 0 23:07:58Z, **32 tests OK trong 124.712s**.
  (Worker chain 2x START 22:35:24Z + 22:39:27Z, không EXIT, chết theo cron
  timeout — partial giữ riêng hidden_files/n2527-chain-partial-worker-2235.log
  + hidden_files/n2527-neighbours-partial-run1-2238.log.)
- Gate full-suite 2 lượt (chain log hidden_files/n2527-chain.log, log
  tools/mindustry_godot_transpiler/full-suite-n2527-gate.log):
  lượt 1 GATE-START 23:17:29Z worker-launch, chết ~1-2 phút (PID 6760 gone,
  không GATE-EXIT, không restart); lượt 2 main thread GATE-START 23:19:33Z →
  GATE-EXIT 1 23:40:16Z, Ran 6317 trong 1241.131s, failures=256, skipped=5 —
  xác minh độc lập theo FAIL block: **255 × unexpectedly None thuần + 1 ×
  hydration pre-existing** (test_liquid_consumer_hydration.py:66, baseline
  hằng số), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent
  (+4 tests / +1 failure đúng mẫu vs N2526 — đúng 4 test mới, +1 failure là
  reference-graph test của N2527).
  Lượt này đóng slice: docs + GOAL + status + 5 commit push, Done 1755→1756.
- Không có VM restart mới (PID1 vẫn 22:38:41Z). javalang 0.13.0 OK.
- N2527 = port `status()` của `TurretBuild` thành 1 pure function cho Turret
  family (Turret leg `enabled && !hasAmmo()` → noInput TRƯỚC super; super
  legs theo BuildingComp.status()).
  Scope khóa lượt 05:15, kiểm tra từ upstream Java + port + catalog trực tiếp
  trên đĩa.

## Scope (khóa)

- MỘT pure function mới `source_turret_status_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd:499` + 1 register file +
  1 test file + 1 proof — KHÔNG driver tick call site (status() là read
  function, không phải per-tick; không caller nào đọc nó hôm nay, UI/status
  display là C11).
- Công thức (Turret.java:369-372 + BuildingComp.java:632-646, giữ nguyên thứ tự Java):
  Turret leg: `if enabled and not has_ammo: return noInput` (:369-372);
  super: `if !enabled: return logicDisable` (:632-634);
  `if !shouldConsume(): return noOutput` (:635-637, qua
  `source_turret_should_consume_state(frame, reload)` của N2524);
  `if efficiency <= 0 || !productionValid(): return noInput` (:638-640);
  `return fmod(tick / 30.0, 1.0) < efficiency ? active : noInput` (:641-646).
- Tham số: `frame, tick, has_ammo, reload`. Trả đúng 1 key `status`.
- `has_ammo` là bool param, KHÔNG tính trong hàm: `hasAmmo()` MUTATES ammo
  stack (`ammo.swap(ammo.size - 1, i);`, Turret.java:703) nên không thể là
  pure read; boolean tương đương (không swap) là `canConsume() && size > 0 &&
  (any entry amount >= ammoPerShot || cheating())`.
- `reload` là per-def reload time (default 10f, ReloadTurret.java:10), đọc từ
  catalog `block.properties` với default 10.0 (tiền lệ tick :2665) — KHÔNG
  hardcode duo.
- `tick` là float param tường minh, không đọc từ frame (tiền lệ RepairTurret
  `source_repair_turret_status_state`, N2221).
- `productionValid()` là canonical true default
  (source_building_access_state.production_valid_state(),
  BuildingComp.java:759-761 — không override trong
  world/blocks/defense/turrets/ hay world/blocks/defense/).
- Status strings là SourceBuildingAccessState constants
  ("logicDisable" / "noOutput" / "noInput" / "active").
- Mirror `source_repair_turret_status_state` (N2221).

## Java evidence (đọc trực tiếp lượt scope)

- `Turret.java:369-372` `status()`: `public BlockStatus status(){` /
  `if(enabled && !hasAmmo()) return BlockStatus.noInput;` /
  `return super.status();`
- `BuildingComp.java:632-646` super `status()`: `if(!enabled){ return
  BlockStatus.logicDisable; }` / `if(!shouldConsume()){ return
  BlockStatus.noOutput; }` / `if(efficiency <= 0 || !productionValid()){
  return BlockStatus.noInput; }` / `return ((state.tick / 30f) % 1f) <
  efficiency ? BlockStatus.active : BlockStatus.noInput;`
- `Turret.java:364-366` shouldConsume leg (N2524):
  `return isShooting || reloadCounter < reload;`
- `ReloadTurret.java:10` `public float reload = 10f;`
- `Turret.java:703` hasAmmo swap: `ammo.swap(ammo.size - 1, i);`
- `Turret.java:624-629` heat gate trong canConsume();
  `BuildingComp.java:1917-1919` canConsume() live = `potentialEfficiency > 0`;
  `Turret.java:53` heatRequirement default -1f (chỉ afflict 20f / malign 144f
  dương, Blocks.java:5122/:6240).
- `Turret.java:49` ammoPerShot default 1; per-def: ripple 2, foreshadow 5,
  spectre 2, diffuse 3, titan 4, smite 15, malign 2
  (Blocks.java:4069/:4225/:4443/:4521/:4791/:5639/:5736).
- `BuildingComp.java:759-761` productionValid(): `return true;`

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2241/N2524)

- DORMANT live hôm nay: status() là read function, không caller nào đọc nó
  hôm nay (UI/status display là C11), driver tick chưa gọi hàm này → live
  behavior KHÔNG đổi. Khi C11 status display về, hàm này là canonical owner
  duy nhất của Turret status().
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.

## Files (dự kiến, mirror N2526)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_status_state` (:499, defense shard, tiền lệ N2523/N2524/N2525/N2526:
  Turret.java route về defense).
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_status.py` (4 tests:
  registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_turret_status.py` (`--verify`).
- `C07TurretStatusProof.gd` + `.tscn` (8 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- SSOT: +1 symbol / +1 Done / +1 contracts / +2 schemas (đo từ đĩa lượt đóng
  slice: 11718/1755/1688/3167 → 11719/1756/1689/3169);
  defense 214/213 → 215/214; comp 572/475 KHÔNG đổi;
  deferred pool 475 → 478 (+3: 1 ghi status() WIRED/DONE + 1 ghi live hasAmmo()
  computation vẫn DEFERRED + 1 nợ Windows).
- Spec Done 1755 → 1756 + row N2527; GOAL §5 thêm dòng nợ Windows sau dòng N2526
  (§5 dòng 488).

## Quy trình lượt implement (theo AGENTS.md + mẫu N2524/N2525/N2526)

1. RED tests trước (no-ammo / logicDisable beats no-ammo / no-consume /
   zero-efficiency / active partial-efficiency / tick edge), chạy targeted xác nhận fail đúng.
2. GREEN minimal → targeted xanh → register `--verify`.
3. Neighbours + wiring + full gate — CHỈ main thread launch (worker KHÔNG launch; kiểm tra chain log không có START song song; kiểm tra sống sót sau 45–60s; kiểm tra lại javalang/pytest sau mỗi VM restart).
4. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với agent kia).
5. Gate xanh (phân rã theo FAIL block: N thuần + 1 hydration pre-existing) → commit + push mẫu 5 commit, bump Done 1755→1756. `git diff --check` SẠCH. Không stage *.gd.uid / project.godot / arc-upstream/ / mindustry-upstream/ / proof .json / full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2527-scope)

- Turret live hasAmmo() computation — DEFERRED (hasAmmo MUTATES ammo stack,
  Turret.java:703; cần caller slice đọc tick ammo stacks + canConsume live +
  ammoPerShot per-def; C11 status display đọc `status` cũng là slice sau).
- Turret range() consumers — findTarget (Turret.java:652-656, BLOCKED — live entity scan) + aim within-check rewire (slice consumer riêng).
- Turret sense frame per-graph split — DEFERRED (chờ PowerGraph.addGraph merge port; `addGraph` hiện chỉ là source-text constant `java_method_addGraph_20`, chưa port).
- Compose SenseI leg (N2510) với dispatch ở caller — chờ logic-executor driver (chưa có LExecutor instruction loop trong port).
- Live player-unit source cho `unit_is_player` — chờ player control.
- Turret liquid-module wiring (frame liquid state + coolant pick live) — BLOCKED cho driver tick của hàm N2525.
- LaserTurret shouldConsume() (LaserTurret.java:55) — needs a per-build bullets list + LaserTurret driver.
- calculateHeat — BLOCKED (live entity scan); findTarget — BLOCKED (live entity scan).
