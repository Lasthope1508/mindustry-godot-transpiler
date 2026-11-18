# Handoff — N2249 PointDefenseTurret persistence-integration (C07)

## Status: DONE + PUSHED (2026-11-18 20:0x +07) — origin/main == 767b645f (slice d6f7537d, gate 3 Ran 6089 / failures 199 Godot-absent / skipped 5 / errors 0)

Gate 2 (`full-suite-n2249-gate2.log`, main thread PID 11299) ĐÃ CÓ FOOTER:
Ran 6089 tests in 1094.627s, FAILED (failures=210, skipped=5), 0 ERROR.
Phân rã (main thread đếm trực tiếp từ log): 199 × `unexpectedly None`
(Godot-absent, đúng kỳ vọng) + **11 FAIL thật, MỚI so với gate N2248**
(N2248: 198 fail, toàn Godot-absent; 11 test này đều PASS ở gate N2248).
11 FAIL thật: 1 `test_playable` canonical-owner-surface
(`legacyUnregisteredOwnerCount` 2 ≠ 0) + 8 power generator/node slice
(`implementation_linkage: contract SourceT…`) + 1 catalog validator
baseline (2 errors ≠ 0) + 1 `test_source_symbols` audit facade-aliases
(`legacyUnregisteredOwnerCount` 2 ≠ 0). Nguyên nhân: owner đăng ký là
`SourceTurretRuntimePortBridge.*` thay vì `PortGame.*` → validator không
discover được facade function (cùng họ lỗi N2243).

Fix (worker cron 19:15): `WRITE/READ_BRIDGE_OWNER` trong register script +
pins test → `PortGame.*`, xóa 2 key hợp đồng cũ, chạy lại register.
Xác minh từ đĩa (main thread, lượt 19:3x + xác minh lại lượt 19:30):
SSOT 11577/1699/1633/3057 (không đổi), ledger N2249
`godot_owner = PortGame.source_point_defense_turret_build_write_state`,
audit `legacyUnregisteredOwnerCount = 0`, `git diff --check` CLEAN,
9 file modified đúng scope. Targeted 4/4 OK (lượt 19:3x). Lượt 19:30
chạy lại 11 test lỗi cũ theo nhóm nhỏ: validator 1/1 OK, audit +
playable + power-icons 3/3 OK, 8 power tests 8/8 OK — cả 11 đều xanh
sau fix (chạy lẻ/nhóm nhỏ, chưa phải full gate).

Gate 3 (`full-suite-n2249-gate3.log`, `python3 -m unittest discover -s tests`,
PID 3274, launch ~19:35 +07) ĐÃ XONG ~19:53 (lượt 20:00 xác minh từ đĩa):
Ran 6089 in 1082.178s, FAILED (failures=199, skipped=5, errors=0) — tất
cả 199 đều `AssertionError: unexpectedly None` (Godot-absent), 199 FAIL
header = 199 assert, 0 ERROR header, khớp kỳ vọng. Gate xanh theo quy
ước repo. Chờ commit/push theo 5-commit (slice → docs → GOAL → hashes →
handoff-status, push sau commit 4 rồi xác minh origin/main trước khi
ghi Status DONE + PUSHED).

RED đã chạy xong, đúng mẫu handoff: targeted 4 tests → failures=2,
errors=2. Test file
`tools/mindustry_godot_transpiler/tests/test_c07_point_defense_turret_persistence_integration.py`
+ register script
`tools/mindustry_godot_transpiler/register_c07_point_defense_turret_persistence_integration.py`
+ proof `C07PointDefenseTurretPersistenceIntegrationProof` (.gd + .tscn)
đã viết, chưa commit. Register `--verify`: 20/20 exprs present.
2 errors: registration + exact-evidence đều KeyError 'N2249' (ledger
chưa có slice). 2 failures: state test thiếu preload const bridge;
proof test Godot parse error "Cannot find member
PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_WRITE_STATE /
..._READ_STATE in SourceRuntimeOwnerTurretRegistry.gd" (đúng tín
hiệu RED — consts chưa tồn tại). Port 7777 trống trước proof, không
va chạm agent khác. Lần chạy sau làm GREEN theo mục "GREEN plan"
dưới đây.

GREEN đã xong (lượt cron 18:30, xác minh từ đĩa lúc 18:46 +07): 2 hàm
bridge + preload const trong `SourceTurretRuntimePortBridge.gd`, 2 consts
registry trong `SourceRuntimeOwnerTurretRegistry.gd` — diff khớp từng
assertion của test (chữ ký, body delegate, comment Java evidence, tên
consts); `git diff --check` CLEAN. Register main đã chạy: ledger N2249
có mặt, godot_owner
`SourceTurretRuntimePortBridge.source_point_defense_turret_build_write_state`,
2 symbols `..._build_write/read_state_result.rotation` trong registry.
SSOT đúng kỳ vọng: 11577/1699/1633/3057, defense shard slices 178.
Proof JSON `C07PointDefenseTurretPersistenceIntegrationProof.json`:
matches:true, 8/8 key true (headless Linux). Targeted 4/4 + family +
wiring KHÔNG chạy lại trong lượt này vì gate đang chạy (tránh tranh
port 7777 + nhiễu gate) — gate sẽ chạy các test đó; chờ footer gate
để chốt. Gate 1 (`full-suite-n2249-gate.log`) CHẾT sớm ở 281 byte
(~280 test, 1 F, không footer) — mẫu worker-launched chết giữa chừng.
Gate 2 (`full-suite-n2249-gate2.log`, PID 11299, `setsid nohup`,
launch 18:46) ĐÃ XONG 19:04: Ran 6089, failures=210 (199 Godot-absent
+ 11 FAIL thật mới — xem Status). Đã fix owner → `PortGame.*` (lượt
19:15) và launch gate 3 (PID 3274, ~19:35) — xem Status.

## Scope

Nối 2 pure function write/read của N2245 (`source_point_defense_turret_write_state`
/ `source_point_defense_turret_read_state`, `SourcePointDefenseTurretBuildState.gd`
:685/:702) vào bề mặt PortGame-callable, để một save/load stream tương lai
gọi được chúng — theo đúng nghĩa "persistence-integration" mà handoff N2217
(RepairTurret) và N2245 đã hoãn lại: "the port has no save/load stream to
call these functions yet — wiring them into a save/load path waits for a
persistence-integration slice (deferred)".

Phạm vi dự kiến (quyết định cuối ở RED):

1. 2 hàm bridge trong `godot-mindustry/src/game/SourceTurretRuntimePortBridge.gd`
   (nơi đang chứa bridge write/read của TractorBeamTurret, :221/:227):
   - `source_point_defense_turret_build_write_state(rotation_value: float) -> Dictionary`
     → gọi `source_point_defense_turret_write_state({"rotation": rotation_value})`
     (adapter mỏng, không bịa behaviour: chỉ gói rotation thành frame).
   - `source_point_defense_turret_build_read_state(saved_rotation: float) -> Dictionary`
     → gọi `source_point_defense_turret_read_state(saved_rotation)`.
2. 2 const registry trong `godot-mindustry/src/game/SourceRuntimeOwnerTurretRegistry.gd`,
   theo tên bridge:
   - `PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_WRITE_STATE := "port_game.source_point_defense_turret_build_write_state"`
   - `PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_READ_STATE := "port_game.source_point_defense_turret_build_read_state"`
3. KHÔNG có driver tick line (persistence không phải per-tick; tiền lệ N2217/N2245).
4. KHÔNG có biến thể `generated_*_bridge_state`: pattern đó cần stub
   `java_inner_class_PointDefenseBuild_method_write_*/read_*`, và grep toàn
   `godot-mindustry/src/` ngày 2026-11-18 xác nhận KHÔNG tồn tại stub
   `java_inner_class_PointDefense*` nào. Không bịa stub generated.
5. KHÔNG chạm gameplay, KHÔNG chạm frame/tick hiện có.

## Java evidence (đã đọc lại ngày 2026-11-18)

`mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java:117-128`:

```java
@Override
public void write(Writes write){
    super.write(write);
    write.f(rotation);
}

@Override
public void read(Reads read, byte revision){
    super.read(read, revision);
    rotation = read.f();
}
```

PointDefenseTurret KHÔNG override `version()` → save version là default 0
của BuildingComp (`return 0;`, BuildingComp.java:669-671), đã pin bởi const
`POINT_DEFENSE_TURRET_SAVE_VERSION := 0` (N2245). Read khôi phục rotation
vô điều kiện, không có guard `revision >= 1` như RepairTurret — nên bridge
read KHÔNG lấy tham số revision.

## Tiền lệ đã kiểm chứng (2026-11-18, trên đĩa)

- TractorBeamTurret: bridge write/read trong `SourceTurretRuntimePortBridge.gd`
  (:221/:227) + consts `PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_WRITE/READ_STATE`
  trong `SourceRuntimeOwnerTurretRegistry.gd` (:8/:9) — nhưng bridge đó delegate
  tới `source_tractor_beam_turret_lifecycle_state.build_write_state` kiểu
  generated (kèm `generated_build_write_bridge_state` gọi
  `java_inner_class_TractorBeamBuild_method_write_4`). PointDefense không có
  lifecycle-state file kiểu đó, không có stub generated → chỉ lấy phần đặt tên
  + vị trí file, không lấy phần generated.
- ItemTurret: `SourceItemTurretBuildPortBridge.gd:68` có
  `source_item_turret_build_write_state(ammo_entries)` delegate tới
  `source_item_turret_build_state.write_state(...)` — cùng hình bridge mỏng.
- PortGame.gd hiện KHÔNG gọi bất kỳ bridge `*_build_write_state` /
  `*_build_read_state` nào (grep 2026-11-18: 0 caller), và không file nào
  ngoài PortBridge/Registry gọi bridge write của ItemTurret hay TractorBeam.
  → Port chưa có save/load stream thật; slice này chỉ tạo bề mặt callable +
  đăng ký registry, KHÔNG tạo stream save/load. Tạo stream là slice khác,
  ngoài phạm vi N2249.
- Registry hiện chỉ có 1 const PointDefense:
  `PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_SET_STATS_STATE`
  (`SourceRuntimeOwnerTurretRegistry.gd:104`). Pure function PointDefense
  được driver gọi trực tiếp từ `SourceFactoryRuntimeState.gd`, không qua bridge.

## SSOT baseline (xác minh từ đĩa 2026-11-18, khớp handoff N2248)

- `source_symbol_registry.json` symbols: **11575**
- `source_slice_ledger.json` slices: **1698**
- `source_api_contracts.json` contracts: **1631**
- `source_state_schema.json` schemas: **3053**
- Audit `totalSourceFunctions`: 1335.

## GREEN plan (lần chạy sau — RED đã xong 18:15)

1. `SourceTurretRuntimePortBridge.gd`: thêm preload const
   `source_point_defense_turret_build_state` + 2 hàm bridge mỏng
   (write bọc `{"rotation": rotation_value}`, read truyền thẳng
   `saved_rotation`), kèm comment Java evidence như test pin.
   Đặt cạnh các hàm `source_tractor_beam_turret_build_write/read_state`
   (:221/:227).
2. `SourceRuntimeOwnerTurretRegistry.gd`: thêm 2 consts cạnh
   `PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_SET_STATS_STATE` (:104).
3. Chạy targeted 4/4 → chạy `register_..._persistence_integration.py`
   (main) → targeted lại 4/4 → family PointDefenseTurret + wiring →
   gate (main thread launch, kiểm tra javalang sau restart) → 5-commit
   + push (không stage `*.gd.uid`, proof `.json`, gate logs).
   SSOT kỳ vọng sau GREEN: symbols 11575 → 11577, Done 1698 → 1699,
   contracts 1631 → 1633, schema 3053 → 3057; defense shard slices
   177 → 178.
4. Proofs chưa chạy trên Windows Godot — nợ trong GOAL.md §5.

## RED plan (đã xong 18:15 — giữ lại làm hồ sơ)

- Test mới `tools/mindustry_godot_transpiler/tests/test_c07_point_defense_turret_persistence_integration.py`
  (4 tests, theo mẫu N2245/N2248) + register script
  `tools/mindustry_godot_transpiler/register_c07_point_defense_turret_persistence_integration.py`.
- RED kỳ vọng: KeyError 'N2249' + thiếu bridge/consts + proof Godot-absent
  (mẫu failures=2, errors=2).
- Proof mới `C07PointDefenseTurretPersistenceIntegrationProof` (.gd + .tscn):
  bridge write trả đúng rotation / bridge read khôi phục đúng rotation /
  bridge write/read chỉ trả rotation (1 key) / registry consts đúng tên.
  Kiểm tra port 7777 trống trước khi chạy proof; không chạy song song với
  agent khác đang test Godot.
- Quyết định cần chốt ở RED: tên file test/register + số entry SSOT tăng
  thêm (2 bridge + 2 consts; schema/contract đếm theo validator thực tế,
  không đoán trước).
- Sau GREEN: family PointDefenseTurret + wiring chuẩn, rồi gate (main thread
  launch, kiểm tra javalang còn không sau restart), rồi 5-commit + push theo
  đúng quy trình (không stage `*.gd.uid`, proof `.json`, gate logs).

## Blocked / deferred (không thuộc N2249)

- Live driver wiring cho coolant vẫn BLOCKED (catalog capture) — từ N2248.
- Suppression live + targets live list vẫn BLOCKED (cần frame plumbing).
- Save/load stream thật (caller của các bridge write/read) — slice riêng sau này.
- Proofs chưa chạy trên Windows Godot — nợ trong GOAL.md §5.

## Commits

- Slice: `d6f7537d` — C07: N2249 PointDefenseTurret persistence-integration (13 files).
- Docs: `dd114d09` — N2249 report + handoff + design spec (gate 3 clean except Godot).
- GOAL: `4e4cc934` — GOAL.md names the N2249 slice commit that carries its proof to Windows.
- Hashes: `767b645f` — N2249 report + handoff name slice/docs/GOAL hashes.
- Handoff-status commit follows; origin/main sau push 4 commit đầu: `767b645f`.
