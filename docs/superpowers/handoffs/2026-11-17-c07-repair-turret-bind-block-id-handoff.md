# Handoff — N2236 RepairTurret bind stamps `block_id` (C07)

## Status: DONE + PUSHED (slice 96357c4b, main fa03d0e5). Test + proof xanh, gate sạch (chỉ Godot-absent). SSOT 11532/1686/1617/3025. Targeted 4/4, family RepairTurret 84/84, wiring 32/32 = 120/120; proof 7 semantic keys / 10 in JSON matches:true. Gate DONE (main thread, PID 8320, ~21:2x–21:41): Ran 6037 in 1076.680s, failures=186, skipped=5, 0 errors — all 186 verified Godot-absent asserts (0 dòng ERROR:).

## Slice

N2236 = bind stamp: `source_repair_turret_bind_frame_state` ghi `frame["block_id"] = str(block.id)` ngay sau `var frame: Dictionary = _initial_frame()` trong `godot-mindustry/src/game/SourceRepairTurretBuildState.gd:48-65`. Đóng đúng giới hạn handoff N2235 đã ghi: frame live chưa có `block_id` nên loop ambient-sound N2235 resolve volume per-def (0.9/1.25) chưa kích hoạt trên frame live; sau slice này nó kích hoạt.

- KHÔNG hàm pure mới, KHÔNG đổi signature bind, KHÔNG sửa driver (`source_repair_turret_tick_buildings_state` :697 đã gọi bind; stamp đi theo đúng call đó, không cần tick line mới).
- Sửa 2 comment stale: bind (:53 "empty frame bound" → frame mang block_id); loop (:456-458 "do not stamp block_id yet ... its own later slice" → bind nay stamp).
- Nhánh already-bound (:58-60) trả frame cũ nguyên vẹn — frame đó đã được stamp ở lần bind đầu (cùng Dictionary object trong sprite meta), không cần stamp lại. Nhánh block null / không phải RepairTurret vẫn trả `{"applied": false, "frame": {}}` (không có block_id để stamp).

## Nguồn của `block_id` lúc bind — source-backed, không bịa

`str(block.id)` — port identity của block là id string (handoff N2234):
- Catalog: `content_registry.json:10800` `"id": "repair-point"`; driver :690-693 key `blocks_by_id[registered_block.id]`; proof dùng `blocks_by_id["repair-point"]`.
- Tiền lệ stamp đúng giá trị này vào frame: `SourceFactoryBuildState.gd:117` `frame["block_id"] = str(block.id)` (trong `source_bind_consumer_state`); tiền lệ stamp vào sprite meta: `SourcePlacedBlockState.gd:81` `sprite.set_meta(SOURCE_BLOCK_ID_META_KEY, block.id)`.
- Java identity: tên def là constructor arg — `repairPoint = new RepairTurret("repair-point"){{` (Blocks.java:6386), `repairTurret = new RepairTurret("repair-turret"){{` (Blocks.java:6397); bind = `Block.newBuilding()` (Block.java:1002, `public final Building newBuilding(){`).

## Kiểm tra

- (a) Cả hai đường gọi bind đều có `block_id` sẵn sàng: driver tick (:691-697) đọc `block_id` từ sprite meta (`SOURCE_BLOCK_ID_META_KEY`, đã stamp lúc placement qua `initialize_sprite`, SourcePlacedBlockState.gd:81), lookup cùng catalog block object rồi gọi bind — `str(block.id)` == đúng giá trị meta đó. Placement: grep toàn repo — KHÔNG có caller bind trực tiếp ở placement (chỉ driver :697 + 3 proof gọi bind); placement chỉ stamp meta, driver bind ở tick đầu. Cả hai đường đều đi qua cùng một bind với cùng catalog block object. → KHÔNG BLOCK. Không cần fallback sprite-meta trong bind (block param là nguồn duy nhất, đúng tiền lệ Factory).
- (b) Test hiện có nào pin frame rỗng của bind không: grep `applied` / `_initial_frame` / `frame == {}` trong `tests/test_c07_repair_turret_*.py` → 0 hit. Không test nào assert frame sau bind rỗng hay đếm key của frame. 3 proof gọi bind (PowerStatus :63, ShouldConsume :53, TargetAcquire :80) chỉ đọc key riêng của chúng sau bind/tick; thêm key `block_id` không phá chúng (đã xác minh bằng family run 84/84).
- Loop N2235 đọc `frame.get("block_id", "")` có fallback 1.0 → xanh nguyên vẹn khi frame chưa có key, và resolve per-def khi đã có.

## Đăng ký SSOT (tiền lệ N2108 turret-bind)

Bind RepairTurret chưa từng được đăng ký (không có `source_repair_turret_bind_frame_state_*` symbol/schema nào; ledger không slice nào sở hữu nó — N2174 chỉ đăng ký power row). N2236 đăng ký bind theo đúng shape N2108: 4 symbols (input `sprite`, `block`; result `applied`, `frame` — rule của `frame` ghi rõ frame bound mang `block_id = str(block.id)`), 1 contract, 2 schema (input+result), 1 ledger row. KHÔNG dùng symbol lồng `..._result.frame.block_id` (không có tiền lệ, registry phẳng `prefix_result.key`).
- java_method ledger: `Block.newBuilding()`; slice sources: RepairTurret.java + Blocks.java + Block.java + BuildingComp.java (loop tiêu thụ block_id).
- Delta: symbols +4, ledger +1, contracts +1, schema +2 → **11532/1686/1617/3025**. NO shard change (RepairTurret.java không match shard nào — tiền lệ N2213-N2235).
- Deferred pool: 278 → **279** (không resolve entry nào — không có entry pool nào nêu bind stamp; +1 nợ proof Windows N2236 theo mẫu N2235).

## RED / GREEN / Proof

- RED: main thread chạy 3 lần trong lúc lượt cron 21:00 đáp slice xuống — lần 1 failures=2, errors=2 (3.03s); lần 2 failures=1, errors=1 (proof .gd/.tscn chưa có — FileNotFoundError + Godot cannot open scene); lần 3 OK 4/4 (15.023s) sau khi register + proof + sửa bind đáp xuống. (Báo cáo worker 20:45 nói "RED chưa chạy" đã lỗi thời — slice đua lên GREEN trong lúc main thread kiểm chứng.)
- Register --verify **11/11 exprs present** (script implements --verify, đã kiểm tra trước).
- GREEN targeted **4/4** (15.023s, main-thread run), family RepairTurret **84/84** (21 module, pytest 296.97s, 948 subtests — worker cron 21:00), wiring **32/32** = **120/120**.
- Proof `C07RepairTurretBindBlockIdProof`: **7 semantic keys / 10 in JSON matches:true** (keys: bind_frame_repair_point_block_id, bind_frame_repair_turret_block_id, bind_already_bound_keeps_block_id, bind_non_repair_turret_applied_false, loop_volume_repair_point_bound, loop_volume_repair_turret_bound, driver_tick_stamps_block_id).

## Wiring flake (mẫu N2232/N2235 — va chạm hai chiều)

Lượt per-module unittest của main thread: 8/9 OK, `test_continuous_liquid_turret_live_loop` fail chỉ ở assert `ERROR:` với `Failed to start server on port 7777: 22`, proof matches:true (mọi key true). Nguyên nhân: lượt pytest wiring song song của worker cron 21:15 (PID 7680, log `n2236-wiring-main.log`) giữ port 7777 — va chạm hai chiều; lượt song song đó xong 31/32, fail duy nhất `test_battery_power_status_binding` cũng chỉ ở assert `ERROR:` (port). Main thread chạy lại cô lập cả 2 module fail lúc port trống → **OK ×2**. Flake môi trường, KHÔNG phải regression.

## Gate

Launched sạch từ main thread (PID 8320, log `tools/mindustry_godot_transpiler/full-suite-n2236-gate.log`, godot KHÔNG trên PATH, javalang 0.13.0 OK sau restart #34, không gate lạc, port trống). Footer DONE ~21:41: Ran 6037 in 1076.680s, failures=186, skipped=5, 0 errors — toàn bộ 186 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng `ERROR:`, 186 traceback = đúng 186 failure. SỰ CỐ GATE TRÙNG (mẫu N2233, lỗi của main thread): lần launch đầu của main thread đã đè lên gate của worker cron 21:15 (PID 8188, `-p "test_*.py"`, chung 1 log file) — lệnh ps trước-launch CÓ liệt kê nó nhưng chuỗi `&&` không dừng lại; đã kill CẢ HAI (8188 + 8210) và relaunch canonical (PID 8320) sau khi verify ps sạch. BÀI HỌC LẠI: ps trước-launch phải là GUARD dừng chuỗi, không chỉ in ra.

## Môi trường

- VM restart #34 (~20:2x) đã xóa javalang + pytest — worker cài lại javalang 0.13.0 + pytest 9.2.0 (main thread verify import được).
- VM clock chạy UTC — file mtime ~14:0x UTC = ~21:0x +07 (giải thích timestamp 14:08–14:10 của file N2236).
- Lỗi của main thread: lệnh `cp /dev/stdin` trong chuỗi RED đầu tiên đã BLOCK (đọc stdin không bao giờ tới) — shell kẹt 6 phút, phải kill PID 5597. Không bao giờ dùng `cp /dev/stdin` trong exec; ghi log bằng redirect `>` trực tiếp.

## Commits

- Slice: 96357c4b
- Docs: aaeb017c
- GOAL: 91ee3bc1

## Next

Report + spec row (Done 1685 → 1686 + dòng N2236) + GOAL §5 debt line cho N2236 (nêu slice commit) + 5-commit + push sau footer gate. Sau N2236: suppression live + targets live list vẫn BLOCKED, hoặc họ tiếp theo theo backlog.
