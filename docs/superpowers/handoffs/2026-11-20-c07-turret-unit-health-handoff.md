# Handoff — N2276 Turret unit live health state (C07) [DONE]

## Status: DONE (2026-11-20 ~06:3x +07 GREEN, gate xong 07:23 +07, chờ push lượt cron 07:30) — N2275 đã DONE + PUSHED (192a5bc6). Slice commit a5ccb08e. Gate xác minh độc lập từ log full-suite-n2276-gate.log: Ran 6197 in 1092.915s, failures=226, skipped=5, errors=0 — 226 FAIL = 226 × `AssertionError: unexpectedly None`, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2275, đúng 4 test mới; +1 failure là test reference-graph của chính N2276, Godot-absent trong môi trường gate vì chain script reset PATH không gồm godot-bin). Gate launch từ main thread (script n2276-gate-only-main.sh; GATE-START 23:47:22Z rồi 23:49:14Z rồi 00:05:05Z — lần chạy trọn vẹn là lần 3, GATE-EXIT 1 00:23:20Z; 2 lần đầu chết do VM restart, để lại full-suite-n2276-gate-partial-vm-restart.log). Targeted 4/4 (14 subtests, 18.61s, chạy lại độc lập lượt 07:30 với Godot trên PATH); register --verify 6/6; proof JSON matches:true 7/7 (4 semantic + matches + registry_valid + one_headquarter_per_ssot); SSOT đo từ đĩa 11652/1726/1660/3111; defense 203/202; neighbours 171 passed (551.44s); wiring 32/32 OK (123.313s).

## Scope (đã khóa, xác minh từ đĩa — xem hidden_files/n2276-scope.md)

- Slice: unit live health từ `BlockUnitComp.tile()` — dòng `health(tile.health);` (BlockUnitComp.java:22, dòng thứ hai của tile() body sau `this.tile = tile;`).
- `health(...)` gán field unit health (`float health;`, HealthComp.java:11; setter do component annotation processor sinh — không có method tường minh trong HealthComp.java, xác minh bằng grep: health field refs tại :11/:20/:36/:44/:48/:72/:74/:76/:104/:105/:110).
- Pure function: `source_turret_unit_health_state(tile_health: float) -> Dictionary`, trả 1 key `{"unit_health": tile_health}`. `health` là gán field thuần — không công thức.
- Live source (deferred "needs tile_health frame input" đã RESOLVED, không bịa giá trị): `SourcePlacedBlockState.health(sprite)` (SourcePlacedBlockState.gd:96-99) đọc sprite meta `source_block_health` (const :45), khởi tạo bằng block health lúc placement (`initialize_sprite` :82-86: `block_health_value(block)`, fallback `_default_health`); `game_health_at_cell(game, x, y)` (:101-103) resolve sprite tại cell. Driver đã có sprite + cell trong vòng lặp duo branch, nên tick đọc live placed-block health trực tiếp. Default 250.0 = duo full health lúc placement (Blocks.java:3319 `health = 250;`, cũng content_registry_blocks.json blocks/duo/properties/health = 250).
- New result-key symbol (không clash): `source_turret_unit_health_state_result.unit_health` — grep sạch trong generated JSONs + SourceTurretBuildState.gd. Lưu ý symbol cũ `PortGame.source_unit_health` (type_api_contracts, `unit_health.default` v.v.) đã tồn tại — owner/name khác, ghi lại slice PortGame đã sinh, KHÔNG phải Turret driver; không xung đột. Lưu ý `source_block_unit_tile_input.tile_health` (comp_api_contracts, PortGame.source_block_unit_tile_state N1139) cũng tồn tại — tương tự, owner/name khác, không xung đột. Chưa có key `unit_health` trong SourceTurretBuildState.gd trước slice (grep sạch).
- Driver tick placement + lý do: thứ tự Java trong tile() là :21 maxHealth, :22 health, :23 hitSize, :24 set. Tick N2275 cover maxHealth (:21) và tick unit sync N2260 cover hitSize (:23); cả hai nằm trong `source_turret_tick_buildings_state` sau tick charge N2259. health (:22) chạy THỨ HAI trong tile(), sau maxHealth — nên tick health đi ngay SAU tick maxHealth N2275 (:1340) và TRƯỚC tick unit sync N2260. Driver đọc `source_placed_block_state.health(sprite)`, stamp frame["unit_health"], default 250.0.
- Pure-function placement trong file: ngay SAU `source_turret_unit_max_health_state` (:442), TRƯỚC `source_turret_unit_world_position_state`, mirror thứ tự Java tile() (health :22 sau maxHealth :21, trước hitSize :23 / set :24).
- Proof keys (4 semantic + registry_valid + one_headquarter_per_ssot + matches = 7): unit_health_duo (trực tiếp 250.0 → 250.0), unit_health_other_value (trực tiếp 100.0 passthrough → 100.0), unit_health_stamped_to_frame, unit_health_damaged_live (sprite meta `source_block_health` set 100.0 trước tick → frame 100.0 sau tick; chứng minh driver đọc LIVE placed-block health, không phải hằng 250.0).
- SSOT sau GREEN (đo từ đĩa): symbols 11652 (+1), Done 1726 (+1), contracts 1660 (+1), schemas 3111 (+2) → 11652/1726/1660/3111; defense slices 202 → 203, contracts 201 → 202.

## GREEN (đã xong, lượt ~06:20–07:23 +07; xác minh độc lập lượt cron 07:30)

- Main thread xác minh độc lập lượt cron 07:30 (targeted 4/4, 14 subtests, 18.61s; register 6/6; proof JSON 7/7 true, matches:true; SSOT như trên; neighbours 171 passed; wiring 32/32 OK; gate log như trên) rồi viết docs + commit + push lượt này.
- Pure function `source_turret_unit_health_state` trong SourceTurretBuildState.gd:461 (1 param tile_health, 1 key unit_health).
- Driver tick trong `source_turret_tick_buildings_state` (:1358-1359): gọi pure function với `source_placed_block_state.health(sprite)` — live placed-block health (sprite meta `source_block_health`, set bằng block health lúc placement); stamp frame["unit_health"]; default fallback = duo live value 250.0. Đây là deferred "Unit live health re-sync từ tile()" mà N2275 đã ghi — nay RESOLVED, tile() đã cover đủ cho duo (:21 maxHealth N2275, :22 health N2276, :23 hitSize N2260, :24 set N2274).
- Proof C07TurretUnitHealthProof.gd + .tscn (4 keys trên). Proof JSON đọc trực tiếp: matches:true, 7/7 true (4 semantic + matches + registry_valid + one_headquarter_per_ssot), GREEN ~06:3x +07 (trong lần chạy neighbours với Godot trên PATH, test reference-graph chạy scene và assert matches); JSON đọc lại sau lần chạy targeted độc lập lượt 07:30 vẫn matches:true.
- `python3 register_c07_turret_unit_health.py --verify`: **6/6 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_unit_health.py -q`: **4 passed, 14 subtests passed in 18.61s** (số liệu main thread xác minh lượt 07:30, với Godot trên PATH — lưu ý: lần chạy không có Godot trên PATH thì test reference-graph fail `AssertionError: unexpectedly None`, đúng mẫu gate).
- Neighbours: **171 passed in 551.44s** (log `hidden_files/n2276-neighbours.log` trong goals hidden_files).
- Wiring: **32/32 OK** (Ran 32 tests in 123.313s; log `hidden_files/n2276-wiring.log`).
- `git diff --check` OK trước khi commit.
- File thay đổi (slice commit a5ccb08e): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts — không có file catalog/content_registry vì slice này không thêm catalog value, chỉ dùng duo health 250 đã có trong registry), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- Môi trường: gate script launch 3 lần (23:47:22Z, 23:49:14Z, 00:05:05Z) — 2 lần đầu chết do VM restart (log partial full-suite-n2276-gate-partial-vm-restart.log); lần chạy trọn vẹn là lần 3 (1092.915s, khớp GATE-EXIT 00:23:20Z).

## Tiếp theo (sau khi push)

1. Chọn slice tiếp theo từ deferred list (calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; các def ItemTurret khác ngoài duo).

## Deferred (không đổi, trừ unit live health đã xong ở N2276)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- Turret unit live health cho các def khác ngoài duo — pure function nhận tile_health làm param; chỉ duo được wire trong driver (live placed-block health, default 250.0).
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
