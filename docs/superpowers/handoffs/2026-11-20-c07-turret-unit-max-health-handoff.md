# Handoff — N2275 Turret unit maxHealth state (C07) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-20 ~05:10 +07 GREEN, gate xong 05:53 +07, push lượt cron 06:00) — N2274 đã DONE + PUSHED (46d4b30e). Slice commit 67f55503, docs b9d63b3e, GOAL 2ad588c9, status 1ffb4104. Gate xác minh độc lập từ log full-suite-n2275-gate.log: Ran 6193 in 1131.347s, failures=225, skipped=5, errors=0 — 225 FAIL = 225 × "assertIsNotNone(godot)" (`AssertionError: unexpectedly None`), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2274, đúng 4 test mới; +1 failure là test reference-graph của chính N2275, Godot-absent trong môi trường gate vì chain script reset PATH không gồm godot-bin). Gate launch từ main thread (script n2275-gate-only-main.sh; GATE-START 22:32:00Z rồi 22:34:37Z — lần chạy trọn vẹn là lần 2, GATE-EXIT 1 22:53:30Z; lần đầu không để lại log). Targeted 4/4 (14 subtests, 17.54s, chạy lại độc lập lượt 06:00); register --verify 6/6; proof JSON matches:true 7/7 (4 semantic + matches + registry_valid + one_headquarter_per_ssot); SSOT đo từ đĩa 11651/1725/1659/3109; defense 202/201; neighbours 167 passed (538.06s); wiring 32/32 OK (122.411s).

## Scope (đã khóa, xác minh từ đĩa — xem hidden_files/n2275-scope.md)

- Slice: unit maxHealth từ `BlockUnitComp.tile()` — dòng `maxHealth(tile.block.health);` (BlockUnitComp.java:21, dòng đầu tiên của tile() body sau `this.tile = tile;`).
- Duo health = 250 — xác minh CẢ hai chỗ: Blocks.java:3319 `health = 250;` (trong `duo = new ItemTurret("duo"){{...}}`, Blocks.java:3257-3331) VÀ `godot-mindustry/src/generated/source_modules/content_registry_blocks.json`: blocks/duo/properties/health = 250.
- Pure function: `source_turret_unit_max_health_state(block_health: float) -> Dictionary`, trả 1 key `{"unit_max_health": block_health}`. `maxHealth(...)` gán field unit maxHealth (HealthComp.java:13 `transient float maxHealth = 1f;`; setter do component annotation processor sinh — không có method tường minh trong HealthComp.java, xác minh bằng grep: chỉ field refs tại :13/:21/:44/:48/:104/:116).
- New result-key symbol (không clash): `source_turret_unit_max_health_state_result.unit_max_health`. Lưu ý symbol cũ `block_unit_tile.max_health_call` (PortGame.source_block_unit_tile_state, java_expr `maxHealth(tile.block.health);`) đã tồn tại — nó ghi lại call trong slice PortGame đã sinh, KHÔNG phải Turret driver; owner/name khác, không xung đột. Chưa có key `unit_max_health` trong registry/schema/SourceTurretBuildState.gd trước slice (grep sạch).
- Driver tick placement + lý do: thứ tự Java trong tile() là :21 maxHealth, :22 health, :23 hitSize, :24 set. Tick unit sync N2260 cover hitSize (:23) và tick N2274 cover set (:24); cả hai nằm trong `source_turret_tick_buildings_state` sau tick charge N2259. maxHealth (:21) chạy ĐẦU TIÊN trong tile(), trước hitSize/set — nên tick maxHealth đi ngay TRƯỚC tick unit sync N2260 (sau tick charge), KHÔNG đi sau nó. Driver truyền duo health 250.0 (Blocks.java:3319), stamp frame["unit_max_health"], default 250.0.
- Pure-function placement trong file: ngay TRƯỚC `source_turret_unit_world_position_state` (sau `source_turret_unit_sync_state`), mirror thứ tự Java tile() (maxHealth :21 trước hitSize :23 / set :24).
- Nửa còn lại của tile() KHÔNG ở slice này: `health(tile.health);` (:22) — LIVE tile health, frame không có tile_health input → vẫn DEFERRED, không bịa giá trị. `hitSize` (:23) xong N2260, `set(tile)` (:24) xong N2274 — không làm lại.
- Proof keys (4 semantic + registry_valid + one_headquarter_per_ssot + matches = 7): unit_max_health_duo (trực tiếp 250.0 → 250.0), unit_max_health_other_value (trực tiếp 500.0 passthrough → 500.0), unit_max_health_stamped_to_frame, unit_max_health_duo_live (frame 250.0 sau tick, duo cell (28,21)).
- SSOT sau GREEN (đo từ đĩa): symbols 11651 (+1), Done 1725 (+1), contracts 1659 (+1), schemas 3109 (+2) → 11651/1725/1659/3109; defense slices 201 → 202, contracts 200 → 201. Symbols +1 vì slice đăng ký 1 result-key symbol (unit_max_health) cho 1 function mới.

## GREEN (đã xong, lượt ~05:05–05:15 +07; xác minh độc lập lượt cron 06:00)

- Main thread xác minh độc lập lượt cron 06:00 (targeted 4/4, 14 subtests, 17.54s; register 6/6; proof JSON 7/7 true, matches:true; SSOT như trên; neighbours 167 passed; wiring 32/32 OK; gate log như trên) rồi viết docs + commit + push lượt này.
- Pure function `source_turret_unit_max_health_state` trong SourceTurretBuildState.gd:442 (1 param block_health, 1 key unit_max_health).
- Driver tick trong `source_turret_tick_buildings_state` (:1319-1320): gọi pure function với 250.0 — duo health 250 (Blocks.java:3319, cũng content_registry_blocks.json blocks/duo/properties/health = 250); stamp frame["unit_max_health"]; default fallback = duo live value 250.0. Live tile health (`health(tile.health);`, :22) KHÔNG stamp ở đây: frame không có live tile_health input.
- Proof C07TurretUnitMaxHealthProof.gd + .tscn (4 keys trên). Proof JSON đọc trực tiếp: matches:true, 7/7 true (4 semantic + matches + registry_valid + one_headquarter_per_ssot), GREEN ~05:10 +07 (scene tạo 05:07, neighbours bắt đầu 05:13); JSON đọc lại sau lần chạy targeted độc lập lượt 06:00 vẫn matches:true.
- `python3 register_c07_turret_unit_max_health.py --verify`: **6/6 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_unit_max_health.py -q`: **4 passed, 14 subtests passed in 17.54s** (số liệu main thread xác minh lượt 06:00, với Godot trên PATH — lưu ý: lần chạy đầu không có Godot trên PATH thì test reference-graph fail `assertIsNotNone(godot)`, đúng mẫu gate).
- Neighbours: **167 passed in 538.06s** (log `hidden_files/n2275-neighbours.log` trong goals hidden_files).
- Wiring: **32/32 OK** (Ran 32 tests in 122.411s; log `hidden_files/n2275-wiring.log`).
- `git diff --check` OK trước khi commit.
- File thay đổi (slice commit 67f55503): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts — không có file catalog/content_registry vì slice này không thêm catalog value, chỉ dùng duo health 250 đã có trong registry), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- Môi trường: gate script launch 2 lần (22:32:00Z, 22:34:37Z) — lần chạy trọn vẹn là lần 2 (1131.347s, khớp GATE-EXIT 22:53:30Z); không VM restart, không chết giữa chừng.

## Tiếp theo (sau khi push)

1. Chọn slice tiếp theo từ deferred list (live tile health `health(tile.health)` — cần tile_health frame input; calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; các def ItemTurret khác ngoài duo).

## Deferred (không đổi, trừ unit maxHealth đã xong ở N2275)

- `health(tile.health);` live tile health (BlockUnitComp.java:22) — cần live tile_health frame input, chưa có.
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- Unit maxHealth/health re-sync từ tile(): maxHealth xong N2275; health vẫn deferred (xem trên); findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
