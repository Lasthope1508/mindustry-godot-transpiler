# Báo cáo — N2236 RepairTurret bind stamps `block_id` (C07)

Ngày: 2026-11-17 ~20:5x–21:5x +07. Slice trước N2235 DONE + PUSHED (main 91c5cb4b, SSOT 11528/1685/1616/3023 — đã xác minh lại từ disk).

## Kết luận scoping

N2236 làm được, không còn blocker. Đóng đúng giới hạn handoff N2235 đã ghi: frame live chưa có `block_id` nên loop ambient-sound N2235 resolve volume per-def (0.9/1.25) chưa kích hoạt trên frame live; sau slice này nó kích hoạt. KHÔNG hàm pure mới, KHÔNG đổi signature bind, KHÔNG sửa driver (`source_repair_turret_tick_buildings_state` :697 đã gọi bind; stamp đi theo đúng call đó, không cần tick line mới). Scope chốt trong goals/hidden_files/n2236-scope.md.

## Java đã pin (đọc từ disk)

- Blocks.java:6386 `repairPoint = new RepairTurret("repair-point"){{`; :6397 `repairTurret = new RepairTurret("repair-turret"){{`.
- Block.java:1002 `public final Building newBuilding(){` (bind = `Block.newBuilding()`).
- Catalog: `content_registry.json:10800` `"id": "repair-point"`; driver :690-693 key `blocks_by_id[registered_block.id]`; proof dùng `blocks_by_id["repair-point"]`.
- Tiền lệ stamp đúng giá trị này vào frame: `SourceFactoryBuildState.gd:117` `frame["block_id"] = str(block.id)` (trong `source_bind_consumer_state`); tiền lệ stamp vào sprite meta: `SourcePlacedBlockState.gd:81` `sprite.set_meta(SOURCE_BLOCK_ID_META_KEY, block.id)`.
- Cả hai đường gọi bind đều có `block_id` sẵn sàng: driver tick (:691-697) đọc `block_id` từ sprite meta (đã stamp lúc placement qua `initialize_sprite`, SourcePlacedBlockState.gd:81), lookup cùng catalog block object rồi gọi bind — `str(block.id)` == đúng giá trị meta đó. Placement: grep toàn repo — KHÔNG có caller bind trực tiếp ở placement (chỉ driver :697 + 3 proof gọi bind). → KHÔNG BLOCK, không cần fallback sprite-meta trong bind.
- Test hiện có nào pin frame rỗng của bind không: grep `applied` / `_initial_frame` / `frame == {}` trong `tests/test_c07_repair_turret_*.py` → 0 hit. Không test nào assert frame sau bind rỗng hay đếm key của frame.

## RED (2026-11-17 ~21:0x +07)

- RED: main thread chạy 3 lần trong lúc lượt cron 21:00 đáp slice xuống — lần 1 failures=2, errors=2 (3.03s); lần 2 failures=1, errors=1 (proof .gd/.tscn chưa có — FileNotFoundError + Godot cannot open scene); lần 3 OK 4/4 (15.023s) sau khi register + proof + sửa bind đáp xuống. (Báo cáo worker 20:45 nói "RED chưa chạy" đã lỗi thời — slice đua lên GREEN trong lúc main thread kiểm chứng.)
- Register --verify 11/11 exit 0. SSOT chưa đổi lúc RED (11528/1685/1616/3023).

## GREEN (2026-11-17 ~21:0x–21:2x +07)

- KHÔNG hàm pure mới trong `SourceRepairTurretBuildState.gd`:
  - `source_repair_turret_bind_frame_state` (:48) stamp `frame["block_id"] = str(block.id)` (:64) ngay sau `var frame: Dictionary = _initial_frame()`.
  - Nhánh already-bound (:58-60) trả frame cũ nguyên vẹn — frame đó đã được stamp ở lần bind đầu (cùng Dictionary object trong sprite meta), không cần stamp lại. Nhánh block null / không phải RepairTurret vẫn trả `{"applied": false, "frame": {}}` (không có block_id để stamp).
  - Sửa 2 comment stale: bind (:53 "empty frame bound" → frame mang block_id); loop (:456-458 "do not stamp block_id yet ... its own later slice" → bind nay stamp).
  - KHÔNG có driver tick line (driver :697 đã gọi bind).
- Proof `C07RepairTurretBindBlockIdProof.gd` + `.tscn` (mới): 7 key semantic đã pin.
- Register --verify 11/11; main() exit 0. SSOT từ disk: **11532/1686/1617/3025** — đúng delta dự kiến (symbols +4, Done +1, contracts +1, schema +2). N2236 trong ledger, status done. Audit stays 1335. KHÔNG đổi shard.
- Targeted **4/4 OK** (main-thread run: Ran 4 tests in 15.023s, OK).
- Family RepairTurret **84/84 OK** trong 296.97s (21 module, 948 subtests — worker cron 21:00).
- Wiring-standard **32/32 OK** (9 module) — xem ghi chú flake bên dưới.
- **Tổng 120/120 OK.** `git diff --check` sạch.
- Godot proof headless Linux: scene `C07RepairTurretBindBlockIdProof.tscn`, exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07RepairTurretBindBlockIdProof.json` (untracked, KHÔNG stage): **7 semantic key / 10 trong JSON, matches:true** — bind_frame_repair_point_block_id, bind_frame_repair_turret_block_id, bind_already_bound_keeps_block_id, bind_non_repair_turret_applied_false, loop_volume_repair_point_bound, loop_volume_repair_turret_bound, driver_tick_stamps_block_id.
- Ghi chú wiring flake — va chạm hai chiều, KHÔNG phải regression (tiền lệ N2232/N2235): lượt per-module unittest của main thread: 8/9 OK, `test_continuous_liquid_turret_live_loop` fail chỉ ở assert `ERROR:` với `Failed to start server on port 7777: 22`, proof matches:true — do lượt pytest wiring song song của worker cron 21:15 (PID 7680, log `n2236-wiring-main.log`) giữ port 7777; lượt song song đó xong 31/32, fail duy nhất `test_battery_power_status_binding` cũng chỉ ở assert `ERROR:` (port). Main thread chạy lại cô lập cả 2 module fail lúc port trống → OK ×2. Verdict wiring 32/32 đứng.
- Deferred pool: **278 → 279** (không resolve entry nào — không có entry pool nào nêu bind stamp; +1 nợ proof Windows N2236 theo mẫu N2235).

## Gate toàn bộ (main thread, PID 8320, ~21:2x–21:41 +07)

- Ran **6037** trong 1076.680s, failures=**186**, skipped=5, 0 errors — toàn bộ 186 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng `ERROR:`, 186 traceback = đúng 186 failure. Xong ~21:41 +07. Log `tools/mindustry_godot_transpiler/full-suite-n2236-gate.log` (untracked, KHÔNG stage).
- SỰ CỐ GATE TRÙNG (mẫu N2233, lỗi của main thread): lần launch đầu của main thread đã đè lên gate của worker cron 21:15 (PID 8188, `-p "test_*.py"`, chung 1 log file) — lệnh ps trước-launch CÓ liệt kê nó nhưng chuỗi `&&` không dừng lại; đã kill CẢ HAI (8188 + 8210) và relaunch canonical (PID 8320) sau khi verify ps sạch. BÀI HỌC LẠI: ps trước-launch phải là GUARD dừng chuỗi, không chỉ in ra.
- origin/main không di chuyển trước khi push: local main đã ở 91c5cb4b == origin/main, không cần fast-forward.

## Môi trường

- VM restart #34 (~20:2x) đã xóa javalang + pytest — worker cài lại javalang 0.13.0 + pytest 9.2.0 (main thread verify import được).
- VM clock chạy UTC — file mtime ~14:0x UTC = ~21:0x +07 (giải thích timestamp 14:08–14:10 của file N2236).
- Lỗi của main thread: lệnh `cp /dev/stdin` trong chuỗi RED đầu tiên đã BLOCK (đọc stdin không bao giờ tới) — shell kẹt 6 phút, phải kill PID 5597. Không bao giờ dùng `cp /dev/stdin` trong exec; ghi log bằng redirect `>` trực tiếp.

## Hashes

- 5-commit xong: slice (this commit), docs (next commit), GOAL (next commit) — đang push lên origin main.
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: suppression live + targets live list (vẫn BLOCKED), hoặc họ tiếp theo theo backlog. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
