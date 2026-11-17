# Handoff — N2235 RepairTurret per-def ambientSoundVolume correction (C07)

## Status: GREEN (2026-11-17 ~20:0x +07, main-thread verified). Test + proof xanh, gate sạch (chỉ Godot-absent), chưa push. SSOT 11528/1685/1616/3023. Targeted 4/4, family RepairTurret 80/80, wiring 32/32 = 116/116; proof 7 semantic keys / 10 in JSON matches:true. Gate DONE (main thread, PID 14962, ~20:10–20:28): Ran 6033 in 1081.201s, failures=185, skipped=5, 0 errors — all 185 verified Godot-absent asserts (0 dòng ERROR:).

## Scope (chốt 2026-11-17 ~19:5x +07, file goals/hidden_files/n2235-scope.md)

**N2235 = correction: per-def `ambientSoundVolume` cho RepairTurret.** 1 pure function mới trong `SourceRepairTurretBuildState.gd`, đặt ngay trước `source_repair_turret_ambient_sound_loop_state` (kề loop N2222), **KHÔNG có driver tick line** (read/catalog, tiền lệ sense() N2223 / setStats N2230).

- `source_repair_turret_ambient_sound_volume_state(block_id: String) -> Dictionary` → `{"ambient_sound_volume": float}`:
  - `"repair-point"` → 0.9 (Blocks.java:6393 `ambientSoundVolume = 0.9f;`)
  - `"repair-turret"` → 1.25 (Blocks.java:6408 `ambientSoundVolume = 1.25f;`)
  - def lạ / rỗng → 1.0, class default (RepairTurret.java:67 `ambientSoundVolume = 1f;`, qua const `SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME` đã có từ N2222)
- Wire vào loop: loop GIỮ NGUYÊN signature 2 tham số `(frame, headless)` — test N2222 pin chính xác signature đó (`assertIn` dòng signature), đổi signature sẽ phá test cũ. Loop resolve volume qua hàm mới từ `frame.get("block_id", "")` (tiền lệ đọc `block_id` từ frame: SourceAdjacentFactoryBuildState.gd:150, SourceFactoryBuildState.gd:149, SourceUnitFactoryBuildState.gd:1457). Frame không có `block_id` → fallback class default 1.0, nên test N2222 xanh nguyên vẹn (backward-compat).
- Sửa comment stale trong loop ("both defs share them" — sai, Blocks.java override per-def). Giữ nguyên const `SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME := 1.0` (giờ là fallback của resolver) và dòng return của loop (test N2222 pin nó).
- Giới hạn đã ghi: frame repair-turret live chưa stamp `block_id` (bind tạo frame rỗng; driver đọc block_id từ sprite meta, không stamp vào frame) — volume per-def kích hoạt khi caller đưa `block_id` vào frame (proof làm vậy); stamp `block_id` ở bind là slice riêng sau. Loop vốn không có driver call (sound side effect, chưa có sink — N2222), nên không thêm tick line.

## Java evidence

- Blocks.java:6386 `repairPoint = new RepairTurret("repair-point"){{` + :6393 `ambientSoundVolume = 0.9f;`; :6397 `repairTurret = new RepairTurret("repair-turret"){{` + :6408 `ambientSoundVolume = 1.25f;`.
- RepairTurret.java:66-67 `ambientSound = Sounds.beamHeal;` / `ambientSoundVolume = 1f;` (class default); :25 `public class RepairTurret extends Block{`.
- BuildingComp.java:2270-2271 `if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){` / `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`; :2015-2017 `public float ambientVolume(){` / `return efficiency;`.
- Block.java:351, :353 `public Sound ambientSound = Sounds.none;` / `public float ambientSoundVolume = 0.05f;`.
- LƯU Ý line number: handoff N2234 + DEFERRED entry ghi repair-point là :6394 — SAI 1 dòng, đúng là :6393 (đã grep -n xác minh). Register N2235 dùng :6393; filter DEFERRED theo substring 'ambientSoundVolume correction' để không phụ thuộc số dòng sai đó.

## RED (2026-11-17 ~19:5x +07)

- Targeted: **4 failed** (pytest; KeyError 'N2235' ×2 trong log) — classic RED. Register --verify **13/13 exprs present, exit 0** (script implements --verify, đã kiểm tra trước). SSOT lúc RED: 11527/1684/1615/3021 (baseline N2234).

## GREEN (2026-11-17 ~20:0x +07, worker cron 19:45 TIMEOUT giữa wiring — main thread verify lại toàn bộ + chạy wiring còn lại + tự viết handoff)

- Targeted: **4/4 OK** — main-thread re-run: **Ran 4 tests in 15.967s, OK** (worker log: 4 passed, 38 subtests passed in 14.88s).
- Family RepairTurret (20 module): **80 passed in 268.11s** — đúng kỳ vọng 80/80 (76 cũ + 4 mới).
- Wiring (chuẩn 9 module / 32 test): **32/32** — xem ghi chú flake bên dưới.
- Proof Godot headless Linux: **7/7 key semantic true + matches:true** (7 semantic / 10 trong JSON): volume_repair_point_0_9, volume_repair_turret_1_25, volume_unknown_fallback_1_0, loop_volume_repair_point, loop_volume_repair_turret, loop_volume_no_block_id_fallback, has_no_driver_tick_line.
- `git diff --check` CLEAN (main thread).
- SSOT (verify từ disk): **11528/1685/1616/3023** — symbols +1, ledger +1, contracts +1, schema +2 so với N2234 (11527/1684/1615/3021), đúng scope estimate. N2235 status done; 1 result symbol (`..._volume_state_result.ambient_sound_volume`). **NO shard change** (5 file sửa: family .gd + 4 canonical SSOT; 4 file mới untracked: test, register, proof .gd/.tscn).
- Deferred pool: **278 → 278** (resolve 1 entry ambient correction, thêm 1 entry nợ proof Windows N2235; RepairTurret 29 / RepairTower 6 entry — không họ nào bị wipe).

## Ghi chú wiring flake — va chạm song song, KHÔNG phải regression (tiền lệ N2232)

- Worker 19:45 chạy wiring bằng pytest 1 lượt: log dừng giữa chừng ở module cuối `test_unit_factory_live_loop.py` (bị timeout cắt) — 8 module đầu toàn dấu chấm pass, module cuối chưa kết luận.
- Main thread chạy lại wiring per-module bằng unittest: **7/9 OK**, 2 module cuối FAIL — `test_continuous_liquid_turret_live_loop` (failures=1) + `test_power_graph_consumer_cheating` (failures=1) — cả hai fail CHỈ ở assert `ERROR:` với `ERROR: [MCP Runtime] Failed to start server on port 7777: 1`, proof đều matches:true (mọi key true). Nguyên nhân: một lượt pytest wiring song song của worker khác (PID 14366, log `n2235-wiring-mainverify2.log`) đang chạy cùng lúc và giữ port 7777 — va chạm hai chiều.
- Lượt song song đó xong sau: **32 passed in 137.34s** (sạch). Main thread chạy lại cô lập 2 module fail lúc port trống → **OK ×2**. Verdict wiring 32/32 đứng.

## Files

- Slice: `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (1 hàm + wire vào loop + sửa comment stale), `godot-mindustry/src/generated/source_{symbol_registry,slice_ledger,api_contracts,state_schema}.json`, `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_ambient_sound_volume.py`, `tools/mindustry_godot_transpiler/register_c07_repair_turret_ambient_sound_volume.py`, `godot-mindustry/tools/runtime_proofs/C07RepairTurretAmbientSoundVolumeProof.gd` + `.tscn`.
- KHÔNG stage: proof `.json`, `*.gd.uid`, gate/working log.
- Logs: goals `hidden_files/n2235-red.log`, `n2235-green-targeted.log`, `n2235-family.log`, `n2235-wiring.log` (bản pytest của worker, dừng giữa chừng), `n2235-wiring-*.log` (per-module của main thread) + `*-rerun.log` (2 module chạy lại cô lập), `n2235-wiring-mainverify2.log` (lượt song song của worker khác, 32 passed), scope `n2235-scope.md`; gate log `tools/mindustry_godot_transpiler/full-suite-n2235-gate.log`.

## Next

1. Full gate từ main thread — DONE ~20:28: Ran 6033 in 1081.201s, failures=185, skipped=5, 0 errors (toàn Godot-absent; 0 dòng `ERROR:`). Log `tools/mindustry_godot_transpiler/full-suite-n2235-gate.log`.
2. Report + design spec (Done 1684 → 1685 + dòng N2235) + GOAL §5 debt line N2235 + 5-commit + push — main thread (cron 20:30) đang làm. origin/main không di chuyển (ce10a309), không cần fast-forward.
3. Tiếp theo: suppression live + targets live list (vẫn BLOCKED) hoặc họ tiếp theo theo backlog; stamp `block_id` ở bind (để volume per-def kích hoạt trên frame live) là slice riêng sau.

## Commits

- Slice: 0a1b5247
- Docs: 1093c7c7
- GOAL: fc6dc5b0
