# Báo cáo — N2249 PointDefenseTurret persistence-integration (C07)

Ngày: 2026-11-18 ~18:15–20:0x +07. Slice trước N2248 DONE + PUSHED (main 3fc0661c, SSOT 11575/1698/1631/3053).

## Kết luận scoping

N2249 làm được: nối 2 pure function write/read của N2245 (`source_point_defense_turret_write_state` / `source_point_defense_turret_read_state`) vào bề mặt PortGame-callable — 2 hàm bridge mỏng trong `SourceTurretRuntimePortBridge.gd` + 2 const registry trong `SourceRuntimeOwnerTurretRegistry.gd`, NO driver tick line (persistence không phải per-tick; tiền lệ N2217/N2245). Save/load stream thật (caller của các bridge write/read) vẫn chưa có — slice riêng sau này, không thuộc N2249. Live driver wiring cho coolant vẫn BLOCKED (catalog capture) — từ N2248. Suppression live + targets live list vẫn BLOCKED (cần frame plumbing).

## Java đã pin (đọc từ disk)

- `PointDefenseTurret.java:117-128`: `write()` ghi `rotation` (`write.f(rotation)`), `read()` khôi phục `rotation` (`read.f()`) vô điều kiện, không guard `revision >= 1` như RepairTurret — nên bridge read KHÔNG lấy tham số revision.
- PointDefenseTurret KHÔNG override `version()` → save version default 0 của BuildingComp (`BuildingComp.java:669-671`), đã pin bởi const `POINT_DEFENSE_TURRET_SAVE_VERSION := 0` (N2245).
- KHÔNG có biến thể `generated_*_bridge_state`: pattern đó cần stub `java_inner_class_PointDefenseBuild_method_write_*/read_*`, grep toàn `godot-mindustry/src/` ngày 2026-11-18 xác nhận KHÔNG tồn tại stub `java_inner_class_PointDefense*` nào.
- Tiền lệ: TractorBeamTurret bridge write/read (`SourceTurretRuntimePortBridge.gd:221/:227`) + consts registry (:8/:9); ItemTurret `SourceItemTurretBuildPortBridge.gd:68` bridge mỏng delegate tới `source_item_turret_build_state.write_state(...)`. PortGame.gd hiện KHÔNG gọi bất kỳ bridge `*_build_write_state` / `*_build_read_state` nào (grep 2026-11-18: 0 caller) — Port chưa có save/load stream thật.

## RED (lượt cron 18:15)

- Test `tools/mindustry_godot_transpiler/tests/test_c07_point_defense_turret_persistence_integration.py` (4 tests: registration / input-evidence / behavior / reference-graph) + register script `tools/mindustry_godot_transpiler/register_c07_point_defense_turret_persistence_integration.py` + proof `C07PointDefenseTurretPersistenceIntegrationProof` (.gd + .tscn).
- Chạy RED: **Ran 4, FAILED (failures=2, errors=2)** — đúng mẫu: errors=2 là KeyError 'N2249' (registration + exact-evidence, ledger chưa có slice); failures=2 là state test thiếu preload const bridge + proof test Godot parse error "Cannot find member PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_WRITE_STATE / ..._READ_STATE in SourceRuntimeOwnerTurretRegistry.gd" (consts chưa tồn tại). Port 7777 trống trước proof, không va chạm agent khác.

## GREEN (lượt cron 18:30, main thread xác minh 18:46 +07)

- 2 hàm bridge trong `SourceTurretRuntimePortBridge.gd`: `source_point_defense_turret_build_write_state(rotation_value: float)` (bọc `{"rotation": rotation_value}` → `source_point_defense_turret_write_state`) + `source_point_defense_turret_build_read_state(saved_rotation: float)` (truyền thẳng → `source_point_defense_turret_read_state`), kèm preload const + comment Java evidence.
- 2 consts trong `SourceRuntimeOwnerTurretRegistry.gd` cạnh `PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_SET_STATS_STATE` (:104): `PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_WRITE_STATE` / `..._READ_STATE`.
- Register script `--verify` **20/20** exprs present. SSOT **11575/1698/1631/3053 → 11577/1699/1633/3057** (+2 symbols, +1 Done, +2 contracts, +4 schema); defense shard slices 177 → 178, contracts 176 → 177; audit `totalSourceFunctions` 1335 → 1337, `legacyUnregisteredOwnerCount` 0.
- Targeted **4/4 OK**. Family PointDefenseTurret + wiring KHÔNG chạy lại riêng trong lượt này vì gate đang chạy (tránh tranh port 7777 + nhiễu gate) — full gate chạy các test đó.
- Godot proof headless Linux: scene `C07PointDefenseTurretPersistenceIntegrationProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretPersistenceIntegrationProof.json` (untracked, KHÔNG stage): **8 semantic key + matches, 9/9 true, matches:true** — bridge_write_returns_rotation, bridge_write_returns_only_rotation, bridge_read_restores_rotation, bridge_read_returns_only_rotation, bridge_write_read_round_trip, registry_consts_match_bridge_names, registry_valid, one_headquarter_per_ssot.
- `git diff --check` sạch.

## Gate — XANH (main thread)

- Gate 1 (`full-suite-n2249-gate.log`) CHẾT sớm ở 281 byte (~280 test, 1 F, không footer) — mẫu worker-launched chết giữa chừng.
- Gate 2 (main thread, PID 11299, launch 18:46, xong 19:04, log `full-suite-n2249-gate2.log`): **Ran 6089, FAILED (failures=210, skipped=5, errors=0)** — 199 Godot-absent + **11 FAIL thật, MỚI so với gate N2248** (1 `test_playable` canonical-owner-surface + 8 power generator/node slice + 1 catalog validator baseline + 1 `test_source_symbols` audit facade-aliases; nguyên nhân: owner đăng ký là `SourceTurretRuntimePortBridge.*` thay vì `PortGame.*` → validator không discover được facade function, cùng họ lỗi N2243).
- Fix (lượt cron 19:15): `WRITE/READ_BRIDGE_OWNER` trong register script + pins test → `PortGame.*`, xóa 2 key hợp đồng cũ, chạy lại register. Xác minh từ đĩa: SSOT 11577/1699/1633/3057 (không đổi), ledger N2249 `godot_owner = PortGame.source_point_defense_turret_build_write_state`, audit `legacyUnregisteredOwnerCount = 0`. Chạy lại 11 test lỗi cũ theo nhóm nhỏ: validator 1/1 OK, audit + playable + power-icons 3/3 OK, 8 power tests 8/8 OK — cả 11 đều xanh sau fix.
- Gate 3 (main thread, PID 3274, launch ~19:35, log `full-suite-n2249-gate3.log`): **Ran 6089 in 1082.178s, FAILED (failures=199, skipped=5, errors=0)** — tất cả 199 đều `AssertionError: unexpectedly None` (Godot-absent), đếm 199 FAIL header = 199 assert, 0 ERROR header, khớp kỳ vọng Ran 6089 / failures 199. Gate xanh theo quy ước repo (failures toàn Godot-absent).

## Môi trường

- Port 7777 free lúc chạy proof + gate 3 (không va chạm agent validation).
- VM clock chạy UTC — file mtime ~12:5x UTC = ~19:5x +07.

## Hashes

- Slice `d6f7537d` / docs `dd114d09` / GOAL `4e4cc934` (handoff-status commit follows; main hash filled at push).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: push N2249 → sau N2249: họ PointDefenseTurret còn save/load stream thật (slice riêng); live driver wiring cho coolant vẫn BLOCKED (catalog capture).
