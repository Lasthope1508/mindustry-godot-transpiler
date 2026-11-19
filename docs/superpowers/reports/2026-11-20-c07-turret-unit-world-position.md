# Báo cáo — N2274 Turret unit world position state (C07) [DONE + PUSHED]

Ngày: 2026-11-20 ~04:00 +07 (GREEN), gate xong 04:41 +07, push lượt cron 04:45.

## Trạng thái

- N2273 DONE + PUSHED (origin/main 34c947c6). Không có gì thay đổi về N2273.
- N2274 DONE + PUSHED (slice TBD, docs TBD, GOAL TBD, status TBD): Turret unit world position — nửa còn lại của `BlockUnitComp.tile()` mà N2260 đã defer ("Unit world position from set(tile)"). Gate xác minh độc lập từ log: Ran 6189, failures=224, skipped=5 — toàn Godot-absent (223 × `assertIsNotNone(godot)` + 1 hydration proof cùng nguyên nhân, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR).

## Làm được lượt này (GREEN)

- 1 pure function `source_turret_unit_world_position_state` (3 params cell, block_size, tilesize; 3 keys: unit_world_x, unit_world_y, unit_tile) trong SourceTurretBuildState.gd:442 — frame vẫn làm việc theo cell (N2260 `unit_tile`) VÀ stamp thêm world position bằng đúng công thức Java: `Tile.getX()/getY()` = `drawx()/drawy()` = `block().offset + worldx()/worldy()`, `worldx() = x * tilesize`, `Block.offset = ((size + 1) % 2) * tilesize / 2f` (size lẻ → 0, size chẵn → tilesize/2). Không phát minh representation mới — dùng lại helper `SourceBlockGeometry.tile_drawx_state / tile_drawy_state`.
- Driver tick trong `source_turret_tick_buildings_state` (:1318-1321), ngay sau tick unit sync N2260 và trước tick recoilOffset N2258 (đúng thứ tự Java Turret.java:529-531 sync, :532 offset) — duo size 1.0, tilesize 8.0; duo live (28,21) → (224.0, 168.0).
- Proof 8 keys: matches:true, 11/11 true (đọc trực tiếp từ C07TurretUnitWorldPositionProof.json, ~04:00 +07; chạy lại độc lập lượt 04:45 vẫn matches:true).
- `register_c07_turret_unit_world_position.py --verify`: 16/16 exprs present. SSOT đo từ đĩa: 11650/1724/1658/3107 (symbols +3, Done +1, contracts +1, schemas +2); defense slices 201, contracts 200.

## Test xanh/đỏ

- Xanh: targeted 4/4 (32 subtests, 17.99s — chạy lại độc lập lượt 04:45 với Godot trên PATH); neighbours 163 passed (529.26s); wiring 32/32 OK (chạy đầu 30 passed / 2 failed flake port 7777, rerun riêng 2/2 OK); `git diff --check` OK.
- Gate (log full-suite-n2274-gate.log, chuỗi n2274-gate-only-main.sh launch từ main thread PID 10769; GATE-START 21:22:43Z, GATE-EXIT 1 21:41:46Z): Ran 6189 in 1141.082s, failures=224, skipped=5, errors=0 — toàn Godot-absent (+4 tests / +1 failure so với gate N2273, đúng 4 test mới; +1 failure là test reference-graph của chính N2274).
- Đỏ: chỉ 224 test Godot-absent trong gate (môi trường gate không có Godot trên PATH theo thiết kế chuỗi — đúng mẫu mọi slice trước; chain script reset PATH không gồm godot-bin). Wiring chạy đầu 2 failed do va chạm port 7777 trong lúc chain chạy (ERROR: Failed to start server on port 7777 dù proof matches:true) — đã rerun riêng sạch, không phải regression.

## Blocker

- Không có blocker. Gate chạy trọn vẹn từ main thread, không VM restart, không chết giữa chừng.

## Bước tiếp theo

- Chọn slice tiếp theo từ deferred list (unit maxHealth/health re-sync từ tile(); calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED) — lượt cron sau.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-unit-world-position-handoff.md.
