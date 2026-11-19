# Handoff — N2260 Turret unit sync (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~13:2x +07, lượt cron 13:15) — slice `6e5acc29`, docs `0f279380`, GOAL `5ccbc0f9`, status TBD (pushed; origin/main advances with this status commit). Targeted 4/4 + proof matches:true 11/11 + register --verify 16/16 + gate Ran 6133, failures=210 toàn Godot-absent (đã xác minh độc lập).

- N2259 DONE + PUSHED (origin/main dbb7bbc7, slice e90d1466) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == dbb7bbc7, worktree sạch ngoại trừ noise *.gd.uid (không stage).

## Scope (đã khóa, xác minh từ đĩa)

- Slice unit sync cho duo: driver C07 mới (`SourceTurretBuildState.source_turret_tick_buildings_state`, nhánh duo) chưa bao giờ stamp unit mirror — `unit` là BlockUnitc riêng của mỗi turret (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291), và updateTile() đồng bộ nó mỗi tick (`unit.tile(this); unit.rotation(rotation); unit.team(team);`, Turret.java:529-531), sau charge :527, trước recoilOffset :532. N2260 là tick live trên driver mới, KHÔNG làm lại path legacy (không có path legacy cho unit sync).
- 1 pure function `source_turret_unit_sync_state(unit_tile: Vector2i, rotation: float, unit_team: int, team_id: int, tile_team: int, block_size: float, tilesize: float) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile() là TurretBuild, không phải ItemTurret-only) + 1 driver tick trong nhánh duo, SAU tick charge N2259, TRƯỚC tick recoilOffset N2258.
- PIN Java: `unit.tile(this);` / `unit.rotation(rotation);` / `unit.team(team);` (Turret.java:529-531); `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);` (:291); tile() = `this.tile = tile;` + `maxHealth(tile.block.health);` + `health(tile.health);` + `hitSize(tile.block.size * tilesize * 0.7f);` + `set(tile);` (BlockUnitComp.java:17-25); team() = `if(tile != null && this.team != team){ this.team = team; if(tile.team != team){ tile.changeTeam(team); } }` (BlockUnitComp.java:78-86); rotation là field float thuần (RotComp.java, `@SyncField(false) @SyncLocal float rotation;`); `set(Position pos)` → `set(pos.getX(), pos.getY())` (PosComp.java:23-25). Thứ tự Java trong updateTile (:490-532) đã pin: :502-515 warmup → :519 decay curRecoil → :520-525 multi-recoil decay → :526 heat → :527 charge → **:529-531 unit sync** → :532 recoilOffset → :595-596 turnToTarget → :601/:609 updateShooting → :733 shoot gate.
- Pure function: `unit_tile` = tile truyền vào (link re-assert mỗi tick; tile là `this` nên null guard luôn true tại call site này); `unit_rotation` = rotation (field assignment thuần, không công thức); `unit_team` = team_id (team() set this.team = team khi guard ngoài qua; khi đã bằng thì vẫn giữ team_id — hậu trạng thái luôn là team_id); `unit_hit_size` = `block_unit_tile_hit_size(block_size, tilesize)` = block_size * tilesize * 0.7 (đã port sẵn ở SourceBlockGeometry.gd:863, scale 0.7 ở SourceBlockDefaults.gd:26); `tile_change_team_called` = (unit_team != team_id) && (tile_team != team_id) (guard ngoài + guard trong của team()). Trả 5 result symbol.
- Driver tick: `var unit_sync: Dictionary = source_turret_unit_sync_state(cell, float(frame.get("rotation", 90.0)), int(frame.get("unit_team", team_id)), team_id, team_id, 1.0, 8.0)` rồi stamp 5 key lên frame (`unit_tile` default cell, `unit_rotation` default 90.0, `unit_team` default team_id, `unit_hit_size` default 5.6, `tile_change_team_called` default false). Duo size = 1 (Block.java:215 default, không override), tilesize = 8 (Vars.tilesize = 8; SourceWorldDefaults TILESIZE 8.0) → hit size live duo = 1 * 8 * 0.7 = 5.6. Default unit_team = team_id đúng vì unit được tạo trên team của building (`UnitTypes.block.create(team)`). Tick chạy TRƯỚC aim call nên controlled()/unit.controller() đọc được unit mirror tươi.
- 8 proof keys đã pin trong test: unit_tile_reasserted, unit_rotation_follows_building, unit_team_follows_building, unit_hit_size_duo, unit_team_no_change_team_when_synced, unit_team_change_team_when_drifted, unit_sync_stamped_to_frame, unit_sync_duo_live.
- SSOT kỳ vọng sau GREEN: symbols +5, Done +1, contracts +1, schema +2 → 11618/1710/1644/3079 (schema đếm schema object: input + result = 2/slice, giống N2259 +2 — KHÔNG phải +5); defense shard slices 188 → 189, contracts 187 → 188.
- Quyết định scope — shoot gate live :733 KHÔNG làm trong N2260: gate đã live qua tick aim/shoot N2250 (pure function đã implement `reloadCounter >= reload && !charging() && shootWarmup >= minWarmup`, driver đã gọi live với frame values; N2259 chứng minh thêm tương tác charging). N2260 là unit sync :529-531 theo đúng "Next" của handoff N2259.
- Quan hệ với port BlockUnitComp có sẵn (N1129–N1139, SourceBlockUnitState.gd): `tile_state` / `team_state` đã port các method BlockUnitComp cho generated-class bridge, nhưng `tile_state` cần tile_health live (frame chưa có key health — không có damage model cho turret building) nên driver tick KHÔNG gọi trực tiếp được; `source_turret_unit_sync_state` là pure function riêng cho call site turret driver (pattern N2250–N2259, 1 pure function + 1 driver tick), trả các key stamp được lên frame. Không xung đột symbol (owner khác nhau).

## RED (lượt này, đã chạy + đã xác minh độc lập)

- `python3 -m unittest tests.test_c07_turret_unit_sync` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2259. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2260'` (ledger chưa có entry N2260); state test FAIL vì pure function `source_turret_unit_sync_state` chưa có; proof test FAIL vì `C07TurretUnitSyncProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretUnitSyncProof.tscn'`).
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_unit_sync.py` + handoff này (untracked). Không stage/commit gì ở bước RED.

## GREEN (lượt cron 12:45, đã chạy + đã xác minh độc lập)

- Pure function `source_turret_unit_sync_state` (SourceTurretBuildState.gd, sau `source_turret_charge_state`) + driver tick trong nhánh duo SAU tick charge N2259, TRƯỚC tick recoilOffset N2258 — đúng scope. Java lines đã xác minh lại từ đĩa trước khi viết: Turret.java:529-531 / :291, BlockUnitComp.java:18/:23/:79-83.
- Register script `register_c07_turret_unit_sync.py`: **--verify 16/16 exprs present**; đã chạy — SSOT **11618/1710/1644/3079** (symbols +5, Done +1, contracts +1 đúng kỳ vọng; schema +2 = 3079, KHÔNG phải 3082 như handoff RED ghi — schema đếm schema object, input + result = 2/slice, giống N2259 +2); defense slices 189, contracts 188.
- Proof `C07TurretUnitSyncProof` (.gd + .tscn): targeted **Ran 4, OK (15.511s)**; JSON đã đọc trực tiếp: **matches:true, 8/8 semantic true + registry_valid + one_headquarter_per_ssot**.
- **Fix harness-only trong proof (không đụng game):** lần chạy targeted đầu fail 1 key `unit_sync_duo_live` — proof kỳ vọng `unit_team == 0` (derelict default) nhưng `record_placed_block` default team_id = 1 (PortGame.gd:27, `team_id: int = 1`) nên frame live stamp unit_team = 1. Sửa proof: kỳ vọng 1 + comment. Chạy lại **4/4 OK**. 6/6 key direct pure-function đã xanh từ lần đầu — lỗi chỉ ở kỳ vọng team của proof.
- Neighbours (24 module: 12 PointDefenseTurret + 3 ItemTurret + 8 turret slices warmup/recoil_heat/multi_recoil/multi_recoil_stamp/shoot_stamp/recoil_offset/charge/unit_sync + test_turret_live_loop, kỳ vọng 96 tests) — **XANH, đã xác minh độc lập lượt cron 13:00: 96 passed, 1042 subtests passed in 344.61s, NEIGHBOURS_EXIT:0** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2260-neighbours.log`). Wiring (9 module live-loop) — **XANH, đã xác minh độc lập lượt cron 13:00: Ran 32 tests, OK, WIRING_EXIT:0** (log `n2260-wiring.log`). Targeted chạy lại độc lập lượt 13:00: **Ran 4, OK (14.426s)**. Proof JSON đọc trực tiếp: matches:true, 8/8 semantic true + registry_valid + one_headquarter_per_ssot. SSOT đọc trực tiếp: symbols 11618 / slices 1710 / contracts 1644 / schemas 3079; defense slices 189, contracts 188.

## GREEN (chưa làm)

- [x] Pure function + driver tick theo scope trên.
- [x] Register script `register_c07_turret_unit_sync.py`: **--verify 16/16 exprs present**; đã chạy — SSOT **11618/1710/1644/3079** (kỳ vọng đã sửa: schema +2, không phải +5); defense slices 189, contracts 188.
- [x] Proof `C07TurretUnitSyncProof` (.gd + .tscn) với 8 keys; JSON `matches:true`, 8/8 semantic true + registry_valid + one_headquarter_per_ssot.
- [x] Targeted 4/4 OK.
- [x] Neighbours + wiring xanh (xác minh độc lập lượt 13:00: neighbours 96/96, wiring 32/32).
- [x] Gate (log `tools/mindustry_godot_transpiler/full-suite-n2260-gate.log`, PID 12466, launch ~13:01 +07 lượt cron 13:00, xong ~13:21 +07): **Ran 6133 trong 1104.046s, FAILED (failures=210, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập: 210 FAIL = 210 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2259 (Ran 6129, failures=209): +4 tests / +1 failure đúng bằng 4 test mới của slice. Lượt cron 13:15 KHÔNG launch gate mới (đã có discover PID 12466 đang chạy — guard ps); chỉ chờ nó xong rồi xác minh.
- [x] Report/handoff/spec/GOAL hoàn thiện → commit + push (KHÔNG stage *.gd.uid / logs / project.godot) — gate đã xanh.

## Tiếp theo: N2261 (sau N2260)

- LogicControlTime decay :534-536 (`if(logicControlTime > 0){ logicControlTime -= Time.delta; }`) hoặc rotate sync :542-545 (`((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4)`) — quyết định khi N2260 xong, theo backlog C07.

## Deferred (không đổi)

- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
