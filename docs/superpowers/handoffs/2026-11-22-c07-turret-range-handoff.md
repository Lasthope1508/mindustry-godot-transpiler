# Handoff — N2526 Turret `range()` / `minRange()` / `trackingRange()` accessors: pure function cho Turret family (C07) [DONE]

## Status: DONE + PUSHED (gate lượt 4 xanh theo mẫu Godot-absent, xác minh độc lập lượt cron 05:00 +07 ngày 2026-11-22; slice cf949d7a, docs 97dc8203, GOAL 057295b4, status 5321486f)

- N2525 DONE + PUSHED ~02:22 +07 ngày 2026-11-22, origin/main == HEAD == 6faf7e09
  (5 commit: slice c4fb3409 + docs 5e5dc8e5 + GOAL 71d79b2c + status 6eff12f9 + hashes 6faf7e09).
- N2526 implement xong (worker các lượt cron 02:45–04:45): 1 pure function
  `source_turret_range_state` + register + test + proof, chưa commit.
  Main thread lượt 04:00 xác minh độc lập: targeted 4/4 OK (29 subtests),
  register --verify 17/17, proof matches:true (8 semantic keys, đọc trực tiếp
  C07TurretRangeProof.json); lượt 05:00 xác minh lại: targeted 4/4 OK
  (29 subtests, 16.92s, godot-bin trên PATH), register --verify 17/17,
  proof matches:true (8 semantic + registry_valid + one_headquarter_per_ssot +
  matches = 11/11, đọc trực tiếp C07TurretRangeProof.json, mtime 22:03Z —
  tạo lại bởi targeted re-run của main thread lượt này, nội dung không đổi).
- Chain main-thread lượt 02:45 (n2526-chain-main.sh, log hidden_files/n2526-chain.log):
  NEIGHBOURS-START 19:56:17Z → EXIT 0 20:12:11Z, **287 passed trong 953.22s, 0 fail**
  (+4 tests so với N2525 = đúng 4 test mới); WIRING-START 20:12:11Z → EXIT 0
  20:14:17Z, **32 tests OK trong 126.019s**.
- Gate full-suite 4 lượt (chain log hidden_files/n2526-chain.log, log
  tools/mindustry_godot_transpiler/full-suite-n2526-gate.log):
  lượt 1 GATE-START 20:16:37Z, CHẾT ~20:37Z do VM restart #21 (PID1 20:37:29Z,
  không GATE-EXIT; restart #21 KHÔNG wipe javalang/pytest — cả hai vẫn chạy
  được sau restart); lượt 2 worker relaunch 20:48:16Z (PID 3140) SAI script
  (không GATE-START trong chain log, log dạng pytest thay vì unittest),
  chết ~20:50Z theo session worker, partial giữ riêng
  hidden_files/full-suite-n2526-gate-partial-run2-2048.log (partial lượt 1 bị
  worker ghi đè, không giữ được); lượt 3 main thread GATE-START 20:51:43Z →
  GATE-EXIT 1 21:12:51Z, Ran 6313 failures=264 — FAIL THẬT, không phải flake;
  lượt 4 GATE-START 21:34:36Z → GATE-EXIT 1 21:56:47Z, Ran 6313 trong 1329.130s,
  failures=255, skipped=5 — xác minh độc lập theo FAIL block: **254 ×
  unexpectedly None thuần + 1 × hydration pre-existing**
  (test_live_block_shared_consumers_and_optional_efficiency_runtime,
  test_liquid_consumer_hydration.py:66, baseline hằng số), 0 KeyError, 0
  return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng
  mẫu vs N2525 — đúng 4 test mới, +1 failure là reference-graph test của N2526).
  Lượt này đóng slice: docs + GOAL + status + 5 commit push, Done 1754→1755.
- **Gate lượt 3 FAIL THẬT — root cause + fix (ghi rõ để lần sau nhận diện):**
  264 = 254 None thuần + 1 hydration + **8 × return_schema_linkage + 1 ×
  catalog validator** (test_real_catalog_report_preserves_open_p1_baseline).
  Root cause duy nhất: `_contract_result_schema_name` trong
  `tools/mindustry_godot_transpiler/mindustry_port/source_symbols.py` (bản cũ)
  trả candidate đầu tiên `source_turret_range_result` (legacy của
  PortGame.source_turret_range, chỉ có key `range`) mà không kiểm tra keys —
  contract mới khai `return_keys=[range, min_range, tracking_range]` nên
  `min_range`/`tracking_range` bị báo "not in result schema". Schema trên đĩa
  đã đủ 3 key (register chạy đúng), chỉ resolver sai. Fix (cùng slice commit
  này): resolver mới ưu tiên candidate đầu tiên mà keys phủ đủ return_keys,
  fallback candidate đầu tiên. Không đụng gameplay, chỉ sửa hàm validation
  trong tool. Xác minh độc lập: `validate_source_catalog` errors=[] /
  unknown_return_keys=[] / missing=[]; 20/20 test ở 10 module bị ảnh hưởng
  xanh (39 subtests); gate lượt 4 về 0 linkage — fix đúng.
- N2526 = port 3 accessor `range()` / `minRange()` / `trackingRange()` của
  `TurretBuild` thành 1 pure function cho Turret family (cả 3 cùng đọc
  `peekAmmo()` và cùng được `findTarget()` / `updateTile()` tiêu thụ).
  Scope khóa lượt 02:45, kiểm tra từ upstream Java + port + catalog trực tiếp
  trên đĩa.

## Scope (khóa)

- MỘT pure function mới `source_turret_range_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd:443` + 1 register file +
  1 test file + 1 proof — KHÔNG driver tick call site (frame chưa stamp
  `range`/`min_range`/`tracking_range` live; các consumer là slice sau).
- Công thức (Turret.java:334-350, giữ nguyên thứ tự Java):
  `min_range_out = min_range + min_range_change if has_peek_ammo else min_range`
  (`minRange()`, :334-338);
  `range_out = range_value + range_change if has_peek_ammo else range_value`
  (`range()`, :340-346);
  `tracking_range_out = range_out + maxf(range_value, tracking_range) - range_value`
  (`trackingRange()`, :348-350, với `trackingRange` đã normalize theo `init()`
  :217 `trackingRange = Math.max(range, trackingRange)`).
- Tham số: `frame, range_value, min_range, tracking_range, has_peek_ammo,
  range_change, min_range_change`. Trả đúng 3 key `range` / `min_range` /
  `tracking_range`.
- `has_peek_ammo` = `peekAmmo() != null` (ammo stack non-empty), KHÁC
  `hasAmmo()` (hasAmmo còn fold `canConsume()` — Turret.java:705-708). Tick đã
  có peeked ammo data (`duo_ammo_data`, `peek_turret_ammo` trả dict
  `{"item","speed","reloadMultiplier","rangeChange",...}`).
- QUYẾT ĐỊNH lượt implement: **normalize `trackingRange` trong hàm**
  (`maxf(range_value, tracking_range)` trước công thức :348-350). Lý do: caller
  truyền raw catalog (duo trackingRange absent → 0f) thì công thức thô cho
  `range_out + 0 - 160 = range_change`, SAI (Java đúng là `range()` vì `init()`
  đã normalize thành 160). Normalize trong hàm là verbatim Turret.java:217,
  không phải default bịa.
- KHÔNG rewire aim inline: `SourceItemTurretBuildState.gd:506`
  (`shoot_range = range + range_change + hit_size / 1.9`) là within-check,
  không phải `range()` — giữ nguyên; rewire aim sang hàm mới là slice consumer
  riêng. KHÔNG đụng `findTarget`: chỉ ghi consumer tương lai; findTarget vẫn
  BLOCKED.

## Java evidence (đọc trực tiếp lượt scope)

- `Turret.java:334-338` `minRange()`: `if(peekAmmo() != null){ return minRange
  + peekAmmo().minRangeChange; } return minRange;`
- `Turret.java:340-346` `range()`: `if(peekAmmo() != null){ return range +
  peekAmmo().rangeChange; } return range;`
- `Turret.java:348-350` `trackingRange()`: `return range() + trackingRange -
  range;` (dùng `range()` đã cộng ammo, trừ `range` field gốc)
- `Turret.java:217-219` `init()` normalization (def-time, phải giữ):
  `trackingRange = Math.max(range, trackingRange);`
- `Turret.java:72/:74` class defaults: `trackingRange = 0f`, `minRange = 0f`.
- `BulletType.java:97/:157/:163` bullet defaults: `reloadMultiplier = 1f`,
  `rangeChange = 0f`, `minRangeChange = 0f`.
- Call sites Java (để slice consumer sau dùng, KHÔNG làm trong N2526):
  `findTarget()` (`Turret.java:655-656`, `float trackRange = trackingRange(),
  range = range();` — findTarget vẫn BLOCKED vì live entity scan);
  `updateTile()` `within(target, range() + hitSize/1.9f)` (`:590`).
- Catalog / def (đọc trực tiếp): `content_registry.json`: `range` có per-def
  (duo 160, scatter 220.0, salvo 190.0, foreshadow 500.0, hail 235.0, lancer
  165.0); `minRange`/`trackingRange` ABSENT ở mọi def → class defaults 0f.
  `minRangeChange`: KHÔNG def nào trong `Blocks.java` set → default 0f mọi nơi
  hôm nay (param vẫn cần để đúng Java khi content đổi). `rangeChange` per-ammo
  (nhiều def): duo graphite 16f (`Blocks.java:3276`); các def khác
  32f/40f/56f/70f/80f/8f/-120f/24f… `minRange = 50f` duy nhất ở ripple
  (`Blocks.java:4076`, def ripple `:3954`). `trackingRange = range * 1.4f` ở
  2 def: smite (`Blocks.java:5913`, def `:5655`) và malign (`:6256`, def
  `:5925`). Duo ammo (`Blocks.java:3259-3295`): copper — không override
  (1.0/0/0); graphite — reloadMultiplier 0.8, rangeChange 16; silicon —
  reloadMultiplier 1.5, rangeChange 0.

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2241/N2524)

- DORMANT live hôm nay: frame turret chưa stamp `range` / `min_range` /
  `tracking_range` live, driver tick chưa gọi hàm này → live behavior KHÔNG
  đổi. Khi consumer slices về (findTarget / aim within-check), hàm này là
  canonical owner duy nhất của 3 accessor.
- Không đổi gameplay: chỉ thêm pure function + register + test + proof (+
  validator fix trong tool, không đụng game).

## Files (dự kiến, mirror N2525)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_range_state` (:443, defense shard, tiền lệ N2523/N2524/N2525:
  Turret.java route về defense).
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_range.py` (4 tests:
  registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_turret_range.py` (`--verify`).
- `C07TurretRangeProof.gd` + `.tscn` (8 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- `tools/mindustry_godot_transpiler/mindustry_port/source_symbols.py` —
  validator fix `_contract_result_schema_name` (12 dòng, xem trên).
- SSOT: +3 symbols / +1 Done / +1 contracts / +2 schemas (đo từ đĩa lượt đóng
  slice, khớp ước tính scope 11718: 11715/1754/1687/3165 →
  11718/1755/1688/3167); defense 213/212 → 214/213;
  comp 572/475 KHÔNG đổi; deferred pool 472 → 475 (+3: 1 ghi range accessors
  WIRED + 1 ghi consumer findTarget/aim vẫn DEFERRED + 1 nợ Windows).
- Spec Done 1754 → 1755 + row N2526; GOAL §5 thêm dòng nợ Windows sau dòng N2525
  (§5 dòng 488).

## Quy trình lượt implement (theo AGENTS.md + mẫu N2524/N2525)

1. RED tests trước (duo copper/graphite/silicon + ripple minRange 50 + smite/malign trackingRange 1.4× + no-ammo branch), chạy targeted xác nhận fail đúng.
2. GREEN minimal → targeted xanh → register `--verify`.
3. Neighbours + wiring + full gate — CHỈ main thread launch (worker KHÔNG launch; kiểm tra chain log không có START song song; kiểm tra sống sót sau 45–60s; kiểm tra lại javalang/pytest sau mỗi VM restart).
4. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với agent kia).
5. Gate xanh (phân rã theo FAIL block: N thuần + 1 hydration pre-existing) → commit + push mẫu 5 commit, bump Done 1754→1755. `git diff --check` SẠCH. Không stage *.gd.uid / project.godot / arc-upstream/ / mindustry-upstream/ / proof .json / full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2526-scope)

- Turret range() consumers — findTarget (Turret.java:652-656, BLOCKED — live entity scan) + aim within-check rewire (slice consumer riêng).
- Turret sense frame per-graph split — DEFERRED (chờ PowerGraph.addGraph merge port; `addGraph` hiện chỉ là source-text constant `java_method_addGraph_20`, chưa port).
- Compose SenseI leg (N2510) với dispatch ở caller — chờ logic-executor driver (chưa có LExecutor instruction loop trong port).
- Live player-unit source cho `unit_is_player` — chờ player control.
- Turret liquid-module wiring (frame liquid state + coolant pick live) — BLOCKED cho driver tick của hàm N2525.
- LaserTurret shouldConsume() (LaserTurret.java:55) — needs a per-build bullets list + LaserTurret driver.
- calculateHeat — BLOCKED (live entity scan); findTarget — BLOCKED (live entity scan).
