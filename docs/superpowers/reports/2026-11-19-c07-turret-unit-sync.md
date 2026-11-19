# Report — N2260 Turret unit sync (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~13:2x +07, lượt cron 13:15) — slice `6e5acc29`, docs `0f279380`, GOAL `5ccbc0f9`, status TBD (pushed; origin/main advances with this status commit). Targeted 4/4 + proof matches:true 11/11 + register --verify 16/16 + gate Ran 6133, failures=210 toàn Godot-absent (đã xác minh độc lập).

- N2259 DONE + PUSHED (origin/main dbb7bbc7, slice e90d1466) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, HEAD == origin/main == dbb7bbc7, worktree sạch ngoại trừ diff N2260 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_unit_sync_state(unit_tile: Vector2i, rotation: float, unit_team: int, team_id: int, tile_team: int, block_size: float, tilesize: float) -> Dictionary` trong `SourceTurretBuildState.gd:408` + 1 driver tick nhánh duo, SAU tick charge N2259, TRƯỚC tick recoilOffset N2258 (Java order :529-531 sau charge :527, trước recoilOffset :532).
- Java: `unit.tile(this); unit.rotation(rotation); unit.team(team);` (Turret.java:529-531); `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);` (:291); tile() = `this.tile = tile;` + `maxHealth(tile.block.health);` + `health(tile.health);` + `hitSize(tile.block.size * tilesize * 0.7f);` + `set(tile);` (BlockUnitComp.java:17-25); team() = `if(tile != null && this.team != team){ this.team = team; if(tile.team != team){ tile.changeTeam(team); } }` (BlockUnitComp.java:78-86); rotation là field float thuần (RotComp.java, `@SyncField(false) @SyncLocal float rotation;`).
- Pure function trả 5 result symbol: `unit_tile` = tile truyền vào (link re-assert mỗi tick); `unit_rotation` = rotation; `unit_team` = team_id (hậu trạng thái luôn là team_id); `unit_hit_size` = block_size * tilesize * 0.7 (đã port sẵn ở SourceBlockGeometry.gd:863, scale 0.7 ở SourceBlockDefaults.gd:26); `tile_change_team_called` = (unit_team != team_id) && (tile_team != team_id) (guard ngoài + guard trong của team()).
- Driver tick (SourceTurretBuildState.gd:655-660): `source_turret_unit_sync_state(cell, float(frame.get("rotation", 90.0)), int(frame.get("unit_team", team_id)), team_id, team_id, 1.0, 8.0)` rồi stamp 5 key lên frame (`unit_tile` default cell, `unit_rotation` default 90.0, `unit_team` default team_id, `unit_hit_size` default 5.6, `tile_change_team_called` default false). Duo size = 1 (Block.java:215 default, không override), tilesize = 8 (Vars.tilesize = 8) → hit size live duo = 1 * 8 * 0.7 = 5.6. Default unit_team = team_id đúng vì unit được tạo trên team của building (`UnitTypes.block.create(team)`). Tick chạy TRƯỚC aim call nên controlled()/unit.controller() đọc được unit mirror tươi.
- Quyết định scope — shoot gate live :733 KHÔNG làm trong N2260: gate đã live qua tick aim/shoot N2250 (pure function đã implement `reloadCounter >= reload && !charging() && shootWarmup >= minWarmup`, driver đã gọi live với frame values; N2259 chứng minh thêm tương tác charging). N2260 là unit sync :529-531 theo đúng "Next" của handoff N2259.
- Quan hệ với port BlockUnitComp có sẵn (N1129–N1139, SourceBlockUnitState.gd): `tile_state` / `team_state` đã port các method BlockUnitComp cho generated-class bridge, nhưng `tile_state` cần tile_health live (frame chưa có key health — không có damage model cho turret building) nên driver tick KHÔNG gọi trực tiếp được; `source_turret_unit_sync_state` là pure function riêng cho call site turret driver (pattern N2250–N2259, 1 pure function + 1 driver tick), trả các key stamp được lên frame. Không xung đột symbol (owner khác nhau).

## RED (lượt cron 12:45)

- `python3 -m unittest tests.test_c07_turret_unit_sync`: **Ran 4, FAILED (failures=2, errors=2)** — registration + input-evidence ERROR (ledger N2260 chưa tồn tại → KeyError N2260), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretUnitSyncProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng, đúng mẫu RED của N2259.

## GREEN (lượt cron 12:45–13:00 — code đã có trên đĩa; lượt 13:00 xác minh độc lập)

- Pure function + driver tick + register script + proof `C07TurretUnitSyncProof` đã có; SSOT đúng kỳ vọng 11618/1710/1644/3079, defense 189/188; `git diff --check` OK.
- Targeted chạy lại: **Ran 4, OK (14.426s)**.
- Proof JSON `C07TurretUnitSyncProof.json` (đọc trực tiếp lượt 13:15): **matches:true, 11/11 true** (8 keys unit sync + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **16/16 exprs present**.
- Fix harness-only trong proof (không đụng game): lần chạy targeted đầu fail 1 key `unit_sync_duo_live` — proof kỳ vọng `unit_team == 0` (derelict default) nhưng `record_placed_block` default team_id = 1 (PortGame.gd:27, `team_id: int = 1`) nên frame live stamp unit_team = 1. Sửa proof: kỳ vọng 1 + comment. Chạy lại **4/4 OK**. 6/6 key direct pure-function đã xanh từ lần đầu — lỗi chỉ ở kỳ vọng team của proof.
- Neighbours 24 module — **XANH, đã xác minh độc lập lượt cron 13:00: 96 passed, 1042 subtests passed in 344.61s, NEIGHBOURS_EXIT:0** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2260-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 13:00: Ran 32 tests, OK, WIRING_EXIT:0** (log `n2260-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2260-gate.log`, PID 12466, launch ~13:01 +07 lượt cron 13:00, xong ~13:21 +07): **Ran 6133 trong 1104.046s, FAILED (failures=210, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt 13:15: 210 FAIL = 210 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2259 (Ran 6129, failures=209): +4 tests / +1 failure đúng bằng 4 test mới của slice. Lượt 13:15 KHÔNG launch gate mới (đã có discover PID 12466 đang chạy — guard ps); chỉ chờ nó xong rồi xác minh.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc launch gate.

## Tiếp theo: N2261

- N2261 candidate — LogicControlTime decay :534-536 (`if(logicControlTime > 0){ logicControlTime -= Time.delta; }`) hoặc rotate sync :542-545 (`((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4)`) — quyết định khi N2260 xong, theo backlog C07.
