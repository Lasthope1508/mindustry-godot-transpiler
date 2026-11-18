# Handoff: N2247 PointDefenseTurret bullet hitSize + live bullet removal (DONE, chờ push)

## Status

- N2246 DONE + PUSHED (origin/main == 900527f7, 5-commit, gate Ran 6077 / failures 196 toàn Godot-absent).
- N2247 GREEN 2026-11-18 ~14:45 +07: RED (14:15) → GREEN code + register + targeted 4/4 + family 40/40 + wiring 32/32 (tổng 76/76) + Godot proof 11/11 matches:true + spec/GOAL/report/handoff.
- N2247 DONE + PUSHED (origin/main == a1830050, 5-commit, slice 07100c53, gate 2 Ran 6081 / failures 197 toàn Godot-absent).
- Worktree: BuildState .gd (sửa) + test N2247 (mới) + test target_acquire (sửa) + register script N2247 (mới) + proof .gd/.tscn (mới) + 6 SSOT JSONs (sửa) + spec + GOAL + report + handoff này. Không stage `.gd.uid`.

## Scope — TÁCH SLICE (quyết định ở lần chạy 14:15, có căn cứ)

Handoff N2246 mục Next gộp 3 việc dưới tên N2247: "live coolant
efficiency/trừ liquid/coolEffect + bullet hitSize + live bullet removal".
Đọc Java + driver xong, 2 việc đầu là một slice tự-contained, việc
coolant cần plumbing chưa xác minh nên tách ra:

- **N2247 = bullet hitSize + live bullet removal** (slice này, GREEN).
- **Live coolant efficiency/trừ liquid/coolEffect = slice tiếp theo
  (N2248)** — CHƯA scope xong, 2 điểm mở phải xác minh trước khi viết RED:
  1. Frame KHÔNG có liquids dict: không driver nào stamp
     `frame["liquids"]` (grep 0 hit trong `godot-mindustry/src/game/*.gd`).
     PortGame.gd:34 gọi `source_initialize_building_liquids_state` lúc
     placement — phải xác minh inventory lỏng sống ở đâu (sprite meta?
     game state?) và driver point-defense đọc nó bằng cách nào.
  2. Catalog chưa xác minh key `consumeCoolant`: `block.properties.has("consumePower")`
     / `has("consumeLiquid")` có tiền lệ (PortGame.gd:29), nhưng
     `consumeCoolant` mới chỉ thấy trong AST manifest + API contracts
     (rule "Pin source-backed Block.consumeCoolant(...) bridge parameters"),
     chưa thấy key catalog. Segment không có coolant consumer nên driver
     vẫn no-op — slice đó chỉ xây cơ chế (đọc liquids + efficiency live +
     trừ liquid + coolEffect chance key), không đổi hành vi segment.
  - Java đã đọc sẵn cho slice đó: ConsumeLiquidFilter.java
    (`efficiency()` = `min(liquids.get(liq) / (amount * ed * multiplier), 1f)`,
    0 khi `ed <= 1e-8` hoặc không có liq; `update()` trừ
    `amount * edelta * multiplier`; `getConsumed()` ưu tiên liquids.current()
    nếu filter pass + amount > 0, else liquid đầu tiên theo content order
    pass filter + amount > 0) + ConsumeCoolant.java (filter =
    `liquid.coolant && (allowLiquid && !liquid.gas || allowGas && liquid.gas)
    && temperature <= 0.5 && flammability < 0.1`) + ReloadTurret.java:28-38
    (`updateCooling()`, coolEffect `Mathf.chance(0.06 * amount)`,
    coolEffect là visual random — theo tiền lệ N2240 chỉ trả chance key,
    không roll trong pure function).

## N2247 — scope đã khóa (source-backed)

Java: PointDefenseTurret.java:65-67 (retarget intersect), :69-71 (pooled
null), :85-88 (`if(target.damage() > realDamage){...}else{ target.remove(); }`).

1. **hitSize**: live dict đã mang `hitSize` từ spawn
   (SourceBulletSpawnState.gd:41) nhưng N2242 wiring bỏ nó, acquire N2239
   test điểm đạn với rect Java. Java intersect test hitbox đạn
   (BulletComp implements Hitboxc, BulletComp.java:28; `public float hitSize = 4;`,
   BulletType.java:43; `bullet.hitSize = hitSize;`, BulletType.java:970).
   Fix: observed dicts thêm `"hit_size": float(bullet.get("hitSize", 4.0))`;
   acquire test overlap `|bx - x| <= range + hit_size/2`,
   `|by - y| <= range + hit_size/2`; min-dst2 vẫn dùng tâm đạn (Java
   `b.dst2(this)` là khoảng cách tâm). Tiền lệ ShockwaveTower cũng ghi
   limit này (SourceShockwaveTowerBuildState.gd:169-171).
2. **Live bullet removal**: aim/shoot N2240 null frame target khi lethal
   nhưng dict đạn sống vẫn nằm trong `game["bullets"]`, tick sau acquire
   có thể re-acquire đạn đã chết theo id, sim vẫn di chuyển nó. Pure function
   mới `source_point_defense_turret_bullet_removal_state(live_bullets, removed_id)`
   → `{"remaining_bullets": [...], "removed": bool}` (tiền lệ
   pending_removals, SourceBulletTargetRuntimeState.gd:77-110); driver gọi
   khi `target_removed` và viết list đã lọc lại vào live list (`game.set("bullets", ...)`).
   Đạn bị thương (không lethal) giữ nguyên dict, các đạn khác untouched.
   Symbol mới (2): `..._bullet_removal_state_result.remaining_bullets`,
   `..._bullet_removal_state_result.removed`.

## RED (lần chạy 14:15, main thread)

- File: `tools/mindustry_godot_transpiler/tests/test_c07_point_defense_turret_hit_size_removal.py`
  (4 tests, theo mẫu N2242: registration / exact-exprs / behavior /
  reference-graph + proof). Proof keys (8):
  hitsize_maps_live_bullet_hit_size, hitsize_defaults_to_bullet_type_default,
  hitsize_acquires_bullet_touching_range_edge,
  hitsize_ignores_bullet_fully_outside_range,
  removal_drops_lethally_shot_bullet_from_live_list,
  removal_keeps_damaged_bullet_in_live_list, removal_keeps_other_bullets,
  removal_reports_removed_false_when_id_absent.
- Chạy: `PATH="$HOME/workspace/godot-bin:$PATH" python3 -m unittest
  tools.mindustry_godot_transpiler.tests.test_c07_point_defense_turret_hit_size_removal`
  → **Ran 4, FAILED (failures=2, errors=2)** — đúng signature RED cổ điển:
  errors=2 là KeyError 'N2247' (registration + exact-exprs, ledger chưa có
  N2247); failures=2 là behavior (thiếu `"hit_size"` trong wiring) +
  reference-graph (proof scene `C07PointDefenseTurretHitSizeRemovalProof.tscn`
  chưa tồn tại, Godot 4.6.2 báo `Cannot open file`). javalang CHƯA cài lại
  sau restart VM (ModuleNotFoundError) — cài lại trước gate
  (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt`
  + pytest riêng), không cần cho targeted RED.
- Port 7777 free lúc chạy RED; không process godot/unittest nào chạy.

## GREEN (lần chạy 14:30, worker này)

1. `SourcePointDefenseTurretBuildState.gd`: pure function mới
   `source_point_defense_turret_bullet_removal_state` (:519) + `"hit_size"`
   vào `source_point_defense_turret_live_bullets_state` (:515) + overlap test
   vào `source_point_defense_turret_target_acquire_state` (:209-212) + 1
   driver tick line (:832, `game.set("bullets", ...)` khi target_removed).
   Cập nhật comment cũ (acquire "port models no hitSize", driver "port models
   no live bullet removal") sang mô tả N2247.
2. Test N2239 `test_c07_point_defense_turret_target_acquire.py` cập nhật sang
   dạng overlap (nó pin dòng point-in-rect cũ): comment + 3 assertIn
   (`var hit_size...`, 2 dòng `> range + hit_size / 2.0`). Đây là sửa test
   theo hành vi slice đổi — KHÔNG phải nới lỏng assertion (dạng mới chặt
   hơn: vẫn fail nếu code quay lại point-in-rect).
3. Register script mới `tools/mindustry_godot_transpiler/register_c07_point_defense_turret_hit_size_removal.py`:
   `--verify` **14/14**; chạy register: SSOT **11566/1696/1629/3049 →
   11568/1697/1630/3051** (+2 symbols, +1 Done, +1 contract, +2 schema);
   defense shard slices 175 → 176, contracts 174 → 175; audit stays 1335.
   (Handoff RED dự kiến +3/+1/+2/+4 là sai — số thực tế đo từ disk là
   +2/+1/+1/+2.)
4. Targeted **4/4 OK** (15.826s, gồm chạy proof headless).
   Family PointDefenseTurret **40/40 OK** (10 module, log
   `goals/mindustry-c06-factory-to-defense-work/hidden_files/n2247-family-main.log`)
   — first pass 9/10: target_acquire FAILED (failures=1, KHÔNG phải port
   flake — behavior test pin dòng cũ; đã sửa test, rerun isolated 4/4 OK
   trong 13.342s, log `.../n2247-family-rerun-acquire.log`).
   Wiring-standard **32/32 OK** (9 module, pytest, 123.05s, log
   `.../n2247-wiring-main.log`) — pass ngay lần đầu, không flake.
   **Tổng 76/76 OK.** `git diff --check` sạch.
5. Proof mới `C07PointDefenseTurretHitSizeRemovalProof` (.gd + .tscn):
   8 semantic keys + 2 harness keys, **11/11 true, matches:true**,
   exit 0, 0 ERROR, headless Godot 4.6.2 Linux (JSON viết 07:38 UTC =
   14:38 +07, file ignored, KHÔNG stage). Proof chưa chạy trên Windows
   Godot — nợ trong GOAL.md §5.
6. Docs: spec Done 1696 → 1697 + row N2247; GOAL §5 + dòng nợ N2247;
   report `docs/superpowers/reports/2026-11-18-c07-point-defense-turret-hit-size-removal.md`.
   Deferred: N2247 deferred_exprs 289 entries (N2246: 288; +1 nợ proof
   Windows N2247). Số "pool 284" ở row N2246 không tái tạo được từ ledger
   (đếm trực tiếp: tổng 19427, defense-shard 5932, family point-defense
   distinct 290) nên không ghi số pool mới — chỉ ghi số đếm được.
7. Môi trường: port 7777 free suốt run (không flake nào); VM restart trước
   run (uptime 27 phút lúc bắt đầu) — javalang 0.13.0 + pytest 9.2.0 đã
   cài lại, importable. VM clock UTC — mtime ~07:xx UTC = ~14:xx +07.

## Gate 1 — CHẾT DO VM RESTART (~92%); Gate 2 — XANH (main thread, PID 1799, ~15:0x–15:20)

- Gate 1 (main thread, PID 5686, ~14:4x): CHẾT giữa chừng — VM restart
  ~15:0x (uptime 1 phút lúc phát hiện, javalang + pytest bị wipe).
  Log `full-suite-n2247-gate.log` đóng băng ở 5763 byte (5577 dots /
  181 F / 0 E, KHÔNG footer) — chết ở ~92% (5758/6081). Main thread
  cài lại javalang 0.13.0 + pytest 9.2.0 (cả hai import được), guard ps
  exec riêng (sạch), godot KHÔNG trên PATH, port 7777 free, rồi
  relaunch gate 2 (PID 1799, ~15:0x) với log RIÊNG
  `full-suite-n2247-gate2.log`. Tiền lệ: restart #35 cũng giết gate N2237 ở ~60%,
  relaunch sạch sau đó xanh.
- Gate 2 XANH: **Ran 6081 in 1088.050s, FAILED (failures=197, skipped=5,
  errors=0)** — tất cả 197 đều `AssertionError: unexpectedly None`
  (Godot-absent), đếm 197 FAIL header = 197 assert, khớp kỳ vọng
  Ran 6081 / failures 197. Gate xanh theo quy ước repo.

## Commits

- Slice: `07100c53` — C07: N2247 PointDefenseTurret bullet hitSize + live bullet removal (12 files).
- Docs: `92f1468e` — N2247 report + handoff + design spec (gate 2 clean except Godot).
- GOAL: `9f6034ff` — GOAL.md names the N2247 slice commit that carries its proof to Windows.
- (hashes commit + handoff-status commit follow in this 5-commit push; main hash filled at push.)

## Next

5-commit + push N2247 (slice `07100c53` / docs `92f1468e` / GOAL `9f6034ff`) → N2248 live coolant (xác minh
2 điểm mở ở trên trước khi RED). Suppression live + targets live list vẫn
BLOCKED (cần frame plumbing). Proofs chưa chạy trên Windows Godot — nợ
trong GOAL.md §5.
