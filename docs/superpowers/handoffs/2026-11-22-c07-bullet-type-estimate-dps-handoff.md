# Handoff — N2529 BulletType `estimateDPS()`: pure function cho BulletType (C07) [DONE]

## Status: DONE + PUSHED (gate xanh theo mẫu Godot-absent, xác minh độc lập lượt cron 10:30 +07 ngày 2026-11-22; slice a1edad54, docs 55c03447, GOAL 3acf931d, status TBD)

- Main thread xác minh độc lập: targeted 4/4 (40 subtests) — LƯU Ý: lần chạy đầu KHÔNG có `godot` trên PATH fail 1 test reference-graph (`shutil.which('godot')` None); chạy lại với `~/workspace/godot-bin` trên PATH thì 4/4 xanh (đây là lỗi PATH của main thread, KHÔNG phải lỗi slice). Register `--verify` 34/34. Proof .json đọc trực tiếp: matches:true, 8/8 semantic keys + registry_valid + one_headquarter_per_ssot. `git diff --check` SẠCH. Ledger slices đo độc lập = 1758 (khớp Done +1).
- Chain neighbours+wiring launch từ MAIN THREAD (không phải worker): `n2529-chain-main.sh`, PID 12170, NEIGHBOURS-START 2026-11-22T02:24:52Z; kiểm tra sống sót sau 50s: còn sống, pytest đang chạy. Neighbours = bullet family (11 file) + consumer test_c07_turret_estimate_dps.py + test_source_symbols.py + test_source_catalog_validator.py + test_content_registry.py; wiring = 9 module live-loop như N2528. Neighbours run cuối EXIT 0 03:09:50Z (1162 passed, 1244.69s); wiring EXIT 0 03:11:59Z (32 tests OK, 129.236s). Gate CHẠY RIÊNG bằng `n2529-gate-only-main.sh` sau khi chain EXIT (mẫu N2528, Godot off PATH): GATE-START 03:15:45Z, GATE-EXIT 1 03:36:47Z, Ran 6325, failures=258 toàn Godot-absent (xác minh độc lập lượt cron 10:30 +07).
- N2529 implement xong lượt này (worker, không launch chain, không
  commit/push theo lệnh): 1 pure function
  `source_bullet_type_estimate_dps_state` trong
  `godot-mindustry/src/game/SourceBulletTypeDamageState.gd` (sau
  `shield_damage_state`, KHÔNG driver tick) + test file + register
  file + proof .gd/.tscn. RED trước: 4/4 fail (KeyError 'N2529'
  + assert thiếu hàm/proof). GREEN sau: targeted 4/4 (40 subtests),
  register `--verify` 34/34 exprs present, proof matches:true (8/8
  semantic keys + registry_valid + one_headquarter_per_ssot, chạy
  headless Godot 4.6.2 Linux trên VM, port 7777 free trước khi chạy,
  không chạy song song với agent kia). `git diff --check` SẠCH.
  Không stage gì (để file trên đĩa cho main thread).
- SSOT đo từ đĩa sau GREEN: 11723/1758/1691/3173 (symbols +3,
  Done +1, contracts +1, schemas +2 so với lúc đóng N2528
  11720/1757/1690/3171); bullet shard 94/94 (93/93 -> +1/+1);
  comp giữ 572/475. HIỆU CHỈNH so với scope: handoff dự kiến
  symbols +1, thực tế +3 (3 return keys estimate_dps/cached_dps/
  branch đều là symbol, tiền lệ N2526) — Done/contracts/schemas
  đúng dự kiến.
- Deferred pool: +4 entries mới (1 ghi estimateDPS() DONE + 1 nợ
  Windows + 1 wiring N2528→N2529 DEFERRED + 1 UnitType.estimateDps()
  DEFERRED); entry N2528 "BulletType.estimateDPS() live computation
  still DEFERRED" được giữ nguyên trong pool (không drop) và ghi DONE
  bởi entry mới, mẫu N2528.
- Còn lại cho main thread: gate ĐÃ XONG lượt cron 10:30 +07 (GATE-START 03:15:45Z, GATE-EXIT 1 03:36:47Z, Ran 6325, failures=258 toàn Godot-absent, xác minh độc lập theo FAIL block); commit + push mẫu 5 commit, bump Done 1758 (đã đo), GOAL §5 thêm dòng nợ Windows sau dòng N2528.

- N2528 DONE + PUSHED ~08:46 +07 ngày 2026-11-22, origin/main == HEAD == bbb68083
  (5 commit: slice 901a3e8a + docs b7ad33d4 + GOAL 9c85e4e9 + status 9ff5171a +
  hashes bbb68083). Không có gì thay đổi trên worktree từ lúc đó: git status
  chỉ còn *.gd.uid untracked (không bao giờ stage) + handoff N2530 (đã scope
  lượt 07:15, chưa implement) + handoffs/hidden_files/.
- Không có gate/proof/process nào đang chạy (ps sạch); port 7777 free;
  javalang OK.
- N2529 = port `estimateDPS()` của `BulletType` thành 1 pure function.
  Scope khóa lượt này, kiểm tra từ upstream Java + port + catalog trực tiếp
  trên đĩa.

## Scope (khóa)

- MỘT pure function mới `source_bullet_type_estimate_dps_state` trong
  `godot-mindustry/src/game/SourceBulletTypeDamageState.gd` (file damage
  của BulletType: hiện 3 hàm `damage_multiplier_state`,
  `building_damage_state`, `shield_damage_state`; estimateDPS là ước lượng
  sát thương nên thuộc file này, KHÔNG thuộc SourceBulletTypeCreateState.gd)
  + 1 register file + 1 test file + 1 proof — KHÔNG driver tick call site
  (estimateDPS() là read/estimate, không phải per-tick; caller duy nhất
  hôm nay là `source_turret_estimate_dps_state` N2528, nó đang nhận
  `peek_ammo_dps` làm param — wiring N2528 → N2529 là slice consumer riêng,
  KHÔNG làm trong N2529).
- Công thức (BulletType.java:414-435), giữ đúng thứ tự nhánh của Java:
  1. `cached_dps >= 0` → trả `cached_dps` (cache hit, không tính lại).
  2. `has_spawn_unit` → trả `spawn_unit_dps` (Java: `return
     spawnUnit.estimateDps();` — KHÔNG ghi cachedDps ở nhánh này).
  3. `has_despawn_unit` → trả `despawn_unit_dps` (tương tự, KHÔNG ghi
     cachedDps).
  4. Ngược lại: `sum = (damage + splash_damage * 0.75) * (pierce ?
     (pierce_cap == -1 ? 2 : clamp(pierce_cap, 1, 2)) : 1)`; nếu
     `has_frag_bullet` thì `sum += frag_bullet_dps * frag_bullets / 2`;
     `sum += spawn_bullets_dps_sum`; trả `sum` và `cached_dps` mới = `sum`
     (Java: `return cachedDps = sum;` — hàm pure trả giá trị cache mới qua
     key `cached_dps`, KHÔNG mutate state ngoài).
- Tham số (param-driven, mẫu N2528 — đệ quy + UnitType.estimateDps() chưa
  port nên đều là param, không đoán catalog trong hàm):
  `damage: float` (mặc định Java 1f, :41), `splash_damage: float` (0f,
  :109), `pierce: bool` (false, :53), `pierce_cap: int` (-1, :57),
  `cached_dps: float` (-1, :377), `has_spawn_unit: bool` +
  `spawn_unit_dps: float`, `has_despawn_unit: bool` +
  `despawn_unit_dps: float`, `has_frag_bullet: bool` +
  `frag_bullet_dps: float` + `frag_bullets: int` (9, :212),
  `spawn_bullets_dps_sum: float` (tổng `estimateDPS()` từng phần tử
  `spawnBullets`, caller cộng trước).
- Guard `fragBullet != this` (Java :425): caller truyền
  `has_frag_bullet = false` khi frag trỏ về chính nó (self-frag), hàm
  không tự phân biệt identity.
- Trả đúng các key: `estimate_dps`, `cached_dps` (giá trị Java sẽ lưu;
  nhánh spawn/despawn giữ nguyên input), `branch`
  (`cached` / `spawn_unit` / `despawn_unit` / `computed`).
- Vào bullet shard (`bullet_slices`, root_key `bullet`;
  `bullet_api_contracts` + `bullet_profile` đã đăng ký trong
  `source_ssot_modules.json`), KHÔNG vào defense shard (đây là BulletType,
  không phải Turret).
- Mirror N2528 (test 4 file: registration, input-evidence, state,
  reference-graph; register `--verify`; proof 8 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches, mẫu N2528).

## Java evidence (đọc trực tiếp lượt scope)

- `BulletType.java:414-435` `estimateDPS()`: `@return estimated damage per
  shot. this can be very inaccurate.` / `if(cachedDps >= 0f) return
  cachedDps;` / `if(spawnUnit != null) return spawnUnit.estimateDps();` /
  `if(despawnUnit != null) return despawnUnit.estimateDps();` / `float sum
  = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 :
  Mathf.clamp(pierceCap, 1, 2) : 1f);` / `if(fragBullet != null &&
  fragBullet != this) sum += fragBullet.estimateDPS() * fragBullets / 2f;`
  / `for(var other : spawnBullets) sum += other.estimateDPS();` /
  `return cachedDps = sum;`.
- Fields: `damage = 1f` (:41), `pierce` (:53), `pierceCap = -1` (:57),
  `splashDamage = 0f` (:109), `fragBullet = null` (:202),
  `fragBullets = 9` (:212), `spawnBullets = new Seq<>()` (:247),
  `spawnUnit` / `despawnUnit` null (:253-255), `cachedDps = -1` (:377).
- `UnitType.java:1132-1144` `estimateDps()`: `dpsEstimate =
  weapons.sumf(Weapon::dps)` (+ `/ 15f` nếu suicide qua
  `bullet.killShooter`) — CHƯA port (grep `estimate_dps` trong
  `SourceUnit*.gd` = 0 kết quả), nên `spawn_unit_dps` /
  `despawn_unit_dps` là param trong N2529; `UnitType.estimateDps()` là
  slice sau (ứng viên sau N2530).
- `Turret.java:329-333` `estimateDps()` (N2528) đọc
  `peekAmmo().estimateDPS()` — N2529 là hàm nó đang chờ; wiring N2528 →
  N2529 là slice consumer riêng sau N2529.
- Port hiện tại: KHÔNG có `source_bullet_type_estimate_dps*` nào
  (grep `estimate_dps|estimateDPS` trong `src/game/*.gd` chỉ ra Turret);
  `cachedDps` chỉ xuất hiện trong comment/register của N2528.

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2524/N2527/N2528)

- DORMANT live hôm nay: estimateDPS() là read/estimate, không caller nào
  đọc hàm mới hôm nay (N2528 vẫn nhận `peek_ammo_dps` làm param; C11 HUD /
  stats display đọc `estimate_dps` là slice sau) → live behavior KHÔNG
  đổi. Khi wiring consumer về, hàm này là canonical owner duy nhất của
  BulletType estimateDPS().
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.
- LƯU Ý trung thực: Java doc nói "this can be very inaccurate" — hàm giữ
  đúng công thức Java kể cả độ không chính xác đó (giống ±2° ở N2128:
  không "sửa" Java để proof đẹp hơn).

## Files (dự kiến, mirror N2528)

- `godot-mindustry/src/game/SourceBulletTypeDamageState.gd` — 1 hàm mới
  `source_bullet_type_estimate_dps_state` (bullet shard, tiền lệ các hàm
  damage của BulletType).
- `tools/mindustry_godot_transpiler/tests/test_c07_bullet_type_estimate_dps.py`
  (4 tests: registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_bullet_type_estimate_dps.py`
  (`--verify`).
- `C07BulletTypeEstimateDpsProof.gd` + `.tscn` (8 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches; proof .json KHÔNG
  stage).
- SSOT ĐÃ ĐO từ đĩa sau GREEN lượt implement 09:15 +07 (hiệu chỉnh
  dự kiến +1 symbols -> +3, tiền lệ N2526: 3 return keys = 3 symbols):
  symbols/Done/contracts/schemas 11720/1757/1690/3171 ->
  11723/1758/1691/3173 (+3/+1/+1/+2);
  bullet 93/93 -> 94/94 (+1/+1); comp 572/475 KHÔNG đổi;
  deferred pool +4 (1 ghi estimateDPS() DONE + 1 nợ Windows + 1 wiring
  N2528→N2529 DEFERRED + 1 UnitType.estimateDPS() DEFERRED).
- Spec Done +1 + row N2529; GOAL §5 thêm dòng nợ Windows sau dòng N2528.

## Quy trình lượt implement (theo AGENTS.md + mẫu N2524/N2525/N2526/N2527/N2528)

1. RED tests trước (cache hit → trả cached; spawnUnit branch → trả
   spawn_unit_dps, cached giữ -1; pierceCap -1 → ×2 / pierceCap 1..2 →
   clamp / không pierce → ×1; frag `* fragBullets / 2`; splash ×0.75;
   registration; input-evidence; reference-graph), chạy targeted xác nhận
   fail đúng. — XONG lượt 09:15: 4/4 fail (KeyError 'N2529').
2. GREEN minimal → targeted xanh → register `--verify`. — XONG lượt
   09:15: targeted 4/4 (40 subtests), `--verify` 34/34.
3. Neighbours + wiring + full gate — CHỈ main thread launch (worker KHÔNG
   launch; kiểm tra chain log không có START song song; kiểm tra sống sót
   sau 45–60s; kiểm tra lại javalang/pytest sau mỗi VM restart).
4. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với
   agent kia). — XONG lượt 09:15: matches:true, 8/8 semantic keys,
   headless Godot 4.6.2 Linux trên VM, port 7777 free, proof .json KHÔNG
   stage.
5. Gate xanh (phân rã theo FAIL block: N thuần + 1 hydration pre-existing)
   → commit + push mẫu 5 commit, bump Done +1 (đo từ đĩa). `git diff --check`
   SẠCH. Không stage *.gd.uid / project.godot / arc-upstream/ /
   mindustry-upstream/ / proof .json / full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2529-scope)

- `UnitType.estimateDps()` (UnitType.java:1132-1144, `weapons.sumf(Weapon::dps)`
  + suicide /15) — CHƯA port; là slice sau, `spawn_unit_dps` /
  `despawn_unit_dps` trong N2529 chỉ là param.
- Wiring N2528 → N2529 (Turret estimateDps đọc BulletType estimateDPS thay
  vì param `peek_ammo_dps`) — slice consumer riêng sau N2529.
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

## Next sau N2529 (đã scope, theo thứ tự)

- N2530 (Turret `canControl()`, đã scope lượt 07:15, handoff
  `2026-11-22-c07-turret-can-control-handoff.md`): 1 pure function
  `source_turret_can_control_state`, `return playerControllable;`
  (Turret.java:376-379), KHÔNG driver tick.
- Sau N2530: `fogRadius()` (Turret.java:420-423), `drawrot()`
  (Turret.java:359-362, `return rotation - 90;`), `UnitType.estimateDps()`
  (UnitType.java:1132-1144).
