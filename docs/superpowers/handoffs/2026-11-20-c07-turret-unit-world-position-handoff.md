# Handoff — N2274 Turret unit world position state (C07) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-20 ~04:45 +07, lượt cron 04:45) — N2273 đã DONE + PUSHED (34c947c6). Slice commit 40e856d7, docs 57a3e659, GOAL e5e9c750, status TBD. Gate xác minh độc lập từ log full-suite-n2274-gate.log: Ran 6189 in 1141.082s, failures=224, skipped=5, errors=0 — 224 FAIL header = 223 × "assertIsNotNone(godot)" + 1 hydration proof ("Godot required for hydration proof", cùng nguyên nhân), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2273, đúng 4 test mới; +1 failure là test reference-graph của chính N2274, Godot-absent trong môi trường gate vì chain script reset PATH không gồm godot-bin). Gate launch từ main thread (script n2274-gate-only-main.sh, PID 10769, GATE-START 21:22:43Z, GATE-EXIT 1 21:41:46Z). Targeted 4/4 (32 subtests, 17.99s, chạy lại độc lập lượt 04:45); register --verify 16/16; proof JSON matches:true 11/11 (8 semantic + matches + registry_valid + one_headquarter_per_ssot); SSOT đo từ đĩa 11650/1724/1658/3107; defense 201/200; neighbours 163 passed (529.26s); wiring 32/32 OK (2 fail ban đầu flake port 7777, rerun 2/2 OK).

## Scope (đã khóa, xác minh từ đĩa)

- Slice Turret unit world position — nửa `set(tile)` của `BlockUnitComp.tile()` mà N2260 đã defer ("Unit world position from set(tile) -- waits for a world-position representation decision: the frame works in cells while set() positions the unit in world coordinates."). Quyết định ở slice này (xem hidden_files/n2274-scope.md): frame VẪN làm việc theo cell (`unit_tile`, N2260) VÀ stamp thêm world position bằng đúng công thức Java — không phát minh representation mới.
- Java pins (xác minh từ đĩa): `BlockUnitComp.tile()` (BlockUnitComp.java:17-25): `set(tile);` (:24, last line, sau `maxHealth` / `health` / `hitSize`); `PosComp.set(Position pos)` (PosComp.java:23-25): `set(pos.getX(), pos.getY());` — unit x/y CHÍNH LÀ world coordinates của tile; `Tile.getX()` = `drawx()` (Tile.java:727-729); `Tile.getY()` = `drawy()` (:732-734); `Tile.drawx()` = `block().offset + worldx()` (:175-177); `Tile.drawy()` = `block().offset + worldy()` (:179-181); `Tile.worldx()` = `x * tilesize` (:166-168); `Tile.worldy()` = `y * tilesize` (:170-172); `Block.offset` (Block.java:761, afterPatch): `offset = ((size + 1) % 2) * tilesize / 2f;` — size 1 → 0, size 2 → 4.0 (tilesize/2), size 3 → 0. Call site: `unit.tile(this);` (Turret.java:529) — CÙNG call site với unit sync N2260 (:529-531), nên driver tick đi ngay sau tick unit sync N2260 và trước tick recoilOffset N2258 (thứ tự Java :529-531 sync, :532 offset). Port đã có helper, không cần geometry mới: `SourceBlockGeometry.tile_drawx_state` (:819) và `tile_drawy_state` (:823), trên `tile_worldx_state` / `tile_worldy_state` (:811/:815).
- 8 proof keys: unit_tile_reasserted, unit_world_duo_live, unit_world_offset_even_size2, unit_world_offset_odd_size3, unit_world_origin_cell, unit_world_stamped_to_frame, unit_world_x_duo_size1, unit_world_y_duo_size1.
- SSOT sau GREEN (đo từ đĩa): symbols 11650 (+3), Done 1724 (+1), contracts 1658 (+1), schemas 3107 (+2) → 11650/1724/1658/3107; defense slices 200 → 201, contracts 199 → 200. Symbols +3 vì slice đăng ký 3 result-key symbols (unit_world_x / unit_world_y / unit_tile) cho 1 function mới.

## GREEN (đã xong, lượt ~04:00 +07)

- Main thread xác minh độc lập lượt cron 04:45 (targeted 4/4, 32 subtests, 17.99s; register 16/16; proof JSON 11/11 true, matches:true; SSOT như trên; neighbours 163 passed; wiring rerun sạch; gate log như trên) rồi viết docs + commit + push lượt này.
- Pure function `source_turret_unit_world_position_state` trong SourceTurretBuildState.gd:442 (3 params cell, block_size, tilesize; 3 keys unit_world_x / unit_world_y / unit_tile — unit_tile re-assert link, giống N2260).
- Driver tick trong `source_turret_tick_buildings_state` (:1318-1321): gọi pure function với (cell, 1.0, 8.0) — duo size 1.0 (Block.java:215 default, never overridden), tilesize 8.0 (Vars.tilesize); stamp frame["unit_world_x"] / frame["unit_world_y"] / frame["unit_tile"]; default fallback = duo live values cho cell (offset 0, tilesize 8 → cell * 8). Duo live (28,21) → (224.0, 168.0).
- Proof C07TurretUnitWorldPositionProof.gd + .tscn (8 keys trên). Proof JSON đọc trực tiếp: matches:true, 11/11 true (8 semantic + matches + registry_valid + one_headquarter_per_ssot), GREEN ~04:00 +07, chạy lại lượt 04:45 vẫn matches:true.
- `python3 register_c07_turret_unit_world_position.py --verify`: **16/16 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_unit_world_position.py -q`: **4 passed, 32 subtests passed in 17.99s** (số liệu main thread xác minh lượt 04:45, với Godot trên PATH — lưu ý: lần chạy đầu không có Godot trên PATH thì test reference-graph fail `assertIsNotNone(godot)`, đúng mẫu gate).
- Neighbours: **163 passed in 529.26s** (collected 163, 0 failed); log `hidden_files/n2274-neighbours.log` (goals hidden_files).
- Wiring: **32/32 OK** — chạy đầu 30 passed / 2 failed (reference-graph: factory_live_loop, power_graph_live_update — flake port 7777, ERROR: Failed to start server on port 7777 dù proof matches:true), rerun riêng 2 tests OK; log `hidden_files/n2274-wiring.log` + `hidden_files/n2274-wiring-rerun.log`.
- `git diff --check` OK trước khi commit.
- File thay đổi (slice commit TBD): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts — không có file catalog/content_registry vì slice này không thêm catalog value, chỉ dùng helper geometry có sẵn), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- Môi trường: port 7777 có va chạm trong lúc chain chạy (wiring fail ban đầu) — đã rerun sạch, không phải regression; gate chạy trọn vẹn từ main thread, không VM restart, không chết giữa chừng.

## Tiếp theo (sau khi push)

1. Chọn slice tiếp theo từ deferred list (unit maxHealth/health re-sync từ tile(); calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; các def ItemTurret khác ngoài duo).

## Deferred (không đổi, trừ unit world position đã xong ở N2274)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health); findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
