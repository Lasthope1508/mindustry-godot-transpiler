# Báo cáo — N2235 RepairTurret per-def ambientSoundVolume correction (C07)

Ngày: 2026-11-17 ~19:5x–20:3x +07. Slice trước N2234 DONE + PUSHED (main ce10a309, SSOT 11527/1684/1615/3021 — đã xác minh lại từ disk).

## Kết luận scoping

N2235 làm được, không còn blocker. Correction cho phát hiện ngoài scope của N2234: N2222 pin `ambientSoundVolume = 1f` cho cả hai def, nhưng Blocks.java override per-def — repair-point 0.9f (:6393), repair-turret 1.25f (:6408). 1 pure function trong `SourceRepairTurretBuildState.gd`, KHÔNG có driver tick line (read/catalog, tiền lệ sense() N2223 / setStats N2230). Giới hạn đã ghi: frame repair-turret live chưa stamp `block_id` — volume per-def kích hoạt khi caller đưa `block_id` vào frame; stamp `block_id` ở bind là slice riêng sau.

## Java đã pin (đọc từ disk)

- Blocks.java:6386 `repairPoint = new RepairTurret("repair-point"){{` + :6393 `ambientSoundVolume = 0.9f;`; :6397 `repairTurret = new RepairTurret("repair-turret"){{` + :6408 `ambientSoundVolume = 1.25f;`.
- RepairTurret.java:66-67 `ambientSound = Sounds.beamHeal;` / `ambientSoundVolume = 1f;` (class default); :25 `public class RepairTurret extends Block{`.
- BuildingComp.java:2270-2271 loop `if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){` / `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`; :2015-2017 `ambientVolume()` returns efficiency.
- Block.java:351, :353 `public Sound ambientSound = Sounds.none;` / `public float ambientSoundVolume = 0.05f;`.
- LƯU Ý line number: handoff N2234 + DEFERRED entry ghi repair-point là :6394 — SAI 1 dòng, đúng là :6393 (đã grep -n xác minh).

## RED (2026-11-17 ~19:5x +07)

- RED: Ran 4, FAILED (failures=2, errors=2) — classic RED (KeyError 'N2235' ×2, missing function, proof scene chưa viết). Register --verify 13/13 exit 0. SSOT chưa đổi lúc RED (11527/1684/1615/3021).

## GREEN (2026-11-17 ~20:0x +07, worker cron 19:45 TIMEOUT giữa wiring — main thread verify lại toàn bộ + chạy wiring còn lại + tự viết handoff)

- 1 hàm trong `SourceRepairTurretBuildState.gd`:
  - `source_repair_turret_ambient_sound_volume_state(block_id)` (:423) → `{"ambient_sound_volume": float}`: `"repair-point"` → 0.9; `"repair-turret"` → 1.25; def lạ/rỗng → 1.0 class default (qua const `SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME` đã có từ N2222).
  - Wire vào loop N2222: loop GIỮ NGUYÊN signature `(frame, headless)` — test N2222 pin chính xác signature đó; loop resolve volume qua hàm mới từ `frame.get("block_id", "")`; frame không có `block_id` → fallback 1.0, test N2222 xanh nguyên vẹn. Sửa comment stale "both defs share them".
  - KHÔNG có driver tick line (pure read/catalog).
- Proof `C07RepairTurretAmbientSoundVolumeProof.gd` + `.tscn` (mới): 7 key semantic đã pin.
- Register --verify 13/13; main() exit 0. SSOT từ disk: **11528/1685/1616/3023** — đúng delta dự kiến (symbols +1, Done +1, contracts +1, schema +2). N2235 trong ledger, status done. Audit stays 1335. KHÔNG đổi shard.
- Targeted **4/4 OK** (main-thread re-run: Ran 4 tests in 15.967s, OK; worker log 4 passed, 38 subtests passed in 14.88s).
- Family RepairTurret **80/80 OK** trong 268.11s (20 module).
- Wiring-standard **32/32 OK** (9 module, 9/9 OK lượt đầu) — xem ghi chú flake bên dưới.
- **Tổng 116/116 OK.** `git diff --check` sạch.
- Godot proof headless Linux: scene `C07RepairTurretAmbientSoundVolumeProof.tscn`, exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07RepairTurretAmbientSoundVolumeProof.json` (untracked, KHÔNG stage): **7 semantic key / 10 trong JSON, matches:true** — volume_repair_point_0_9, volume_repair_turret_1_25, volume_unknown_fallback_1_0, loop_volume_repair_point, loop_volume_repair_turret, loop_volume_no_block_id_fallback, has_no_driver_tick_line.
- Ghi chú wiring flake — va chạm song song, KHÔNG phải regression (tiền lệ N2232): worker 19:45 chạy wiring bằng pytest 1 lượt, log dừng giữa chừng ở module cuối `test_unit_factory_live_loop.py` (bị timeout cắt); main thread chạy lại wiring per-module bằng unittest: 7/9 OK, 2 module cuối FAIL chỉ ở assert `ERROR:` với `ERROR: [MCP Runtime] Failed to start server on port 7777: 1`, proof đều matches:true — do một lượt pytest wiring song song của worker khác (PID 14366) giữ port 7777; lượt song song đó xong sau: 32 passed in 137.34s (sạch); main thread chạy lại cô lập 2 module fail lúc port trống → OK ×2. Verdict wiring 32/32 đứng.
- Deferred pool: **278 → 278** (resolve 1 entry ambient correction, thêm 1 entry nợ proof Windows N2235; RepairTurret 29 entry, RepairTower 6 entry — không họ nào bị wipe).

## Gate toàn bộ (main thread, PID 14962, ~20:10–20:28 +07)

- Ran **6033** trong 1081.201s, failures=**185**, skipped=5, 0 errors — toàn bộ 185 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng `ERROR:`, 185 traceback = đúng 185 failure. Xong ~20:28 +07. Log `tools/mindustry_godot_transpiler/full-suite-n2235-gate.log` (untracked, KHÔNG stage).
- origin/main không di chuyển trước khi push: local main đã ở ce10a309 == origin/main, không cần fast-forward.

## Hashes

- 5-commit xong: slice (this commit), docs (next commit), GOAL (next commit) — đang push lên origin main.
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: suppression live + targets live list (vẫn BLOCKED), hoặc họ tiếp theo theo backlog; stamp `block_id` ở bind (để volume per-def kích hoạt trên frame live) là slice riêng sau. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
