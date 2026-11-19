# Handoff — N2268 BuildingComp configured() dispatch effect (C07, duo) [GREEN, chờ gate]

## Status: DONE + PUSHED (2026-11-19 ~21:0x +07, lượt cron 21:00) — slice `1d030ba5`, docs `a4066f68`, GOAL `aee0d36d`. Targeted 4/4 + proof matches:true 15/15 + register --verify 36/36 + gate Ran 6165, failures=218 toàn Godot-absent (đã xác minh độc lập).

## Scope (đã khóa, xác minh từ đĩa)

- Slice BuildingComp configured() dispatch effect (BuildingComp.java:1414-1432): `configured(null, p1)` handler dispatch theo type — Item/Block/Liquid/UnitType → block.configurations handler; Building → copy config đệ quy. Đây là mục "Tiếp theo: N2268" trong handoff N2267.
  - Type resolution (:1415-1416): `//null is of type void.class; anonymous classes use their superclass.` / `Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();`
  - Instanceof overrides (:1418-1421): `if(value instanceof Item) type = Item.class;` / `if(value instanceof Block) type = Block.class;` / `if(value instanceof Liquid) type = Liquid.class;` / `if(value instanceof UnitType) type = UnitType.class;`
  - Player builder stamps last access (:1423-1425): `if(builder != null && builder.isPlayer()){` / `updateLastAccess(builder.getPlayer());` / `}` — updateLastAccess (:1437-1439): `public void updateLastAccess(Player player){` / `lastAccessed = player.coloredName();` / `}`; field `transient String lastAccessed;` (:70); isPlayer (UnitComp.java:949-950): `public boolean isPlayer(){` / `return controller instanceof Player;` / `}`.
  - Dispatch (:1427-1435): `if(block.configurations.containsKey(type)){` / `block.configurations.get(type).get(this, value);` / `}else if(value instanceof Building build){` / `//copy config of another building` / `var conf = build.config();` / `if(conf != null && !(conf instanceof Building)){` / `configured(builder, conf);` / `}` — handler chạy khi có đăng ký cho resolved type; ngược lại Building value copy config đệ quy, tối đa 1 cấp (guard loại conf là Building nên lần đệ quy không bao giờ vào lại nhánh copy).
  - Configurations map (Block.java:402): `public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();`, điền bởi `public <T, E extends Building> void config(Class<T> type, Cons2<E, T> config){` / `configurations.put(type, config);` (:926-929) và configClear (:921-924) với `configurations.put(void.class, (tile, value) -> cons.get((E)tile));` (handler void.class cho value null). `config()` mặc định (BuildingComp.java:2024-2027): `public Object config(){` / `return null;`.
  - Duo: không đăng ký configuration nào (không có `config(` trong ItemTurret.java, Turret.java, ReloadTurret.java, BaseTurret.java) → map rỗng, không handler nào chạy; config() trả null → nhánh copy không bao giờ đệ quy → configured() là noop cho duo. Proof phản ánh đúng: duo live toàn false.
- 1 pure function `source_turret_configured_dispatch_state(value_kind, value_is_anonymous, superclass_kind, has_handler, building_config_kind, builder_is_player)` (6 params, 4 keys: resolved_type, handler_applied, config_copied, last_access_updated) trong `SourceTurretBuildState.gd` (sau `source_turret_super_control_state`, trước `source_turret_tick_buildings_state`). KHÔNG driver tick — configured() event-driven (tiền lệ N2248/N2264/N2266/N2267), logic executor chưa có trong driver, proof gọi direct. Handler body không model: handler là Cons2 closure do block đăng ký (Block.config), duo không có handler nào.
- 12 proof keys: configured_item_handler, configured_block_handler, configured_liquid_handler, configured_unit_type_handler, configured_null_void_handler, configured_anonymous_uses_superclass, configured_building_copies_config, configured_building_no_copy_when_config_null, configured_building_no_copy_when_config_building, configured_handler_beats_building_copy, configured_player_updates_last_access, configured_duo_live.
- SSOT sau GREEN (đo từ đĩa): symbols 11634 (+4), Done 1718 (+1), contracts 1652 (+1), schemas 3095 (+2) → 11634/1718/1652/3095. Shard comp: slices 557 (+1), contracts 461 (+1) — slice đi shard comp vì java_source là BuildingComp.java (tiền lệ N2267); defense giữ nguyên 195/194.

## RED (lượt này, chạy + xác minh)

- `python3 register_c07_turret_configured_dispatch.py --verify`: **36/36 exprs present** (26 exact + 6 input + 4 output).
- `python3 -m unittest tests.test_c07_turret_configured_dispatch` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2267. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2268'` (ledger chưa có entry N2268); state test FAIL vì pure function `source_turret_configured_dispatch_state` chưa có; proof test FAIL vì `C07TurretConfiguredDispatchProof.tscn` chưa tồn tại.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_configured_dispatch.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_configured_dispatch.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt này, chạy + xác minh)

- Viết pure function `source_turret_configured_dispatch_state` (SourceTurretBuildState.gd, sau `source_turret_super_control_state`, 6 params, 4 keys resolved_type/handler_applied/config_copied/last_access_updated).
- Viết proof `C07TurretConfiguredDispatchProof` (.gd + .tscn, mirror `C07TurretSuperControlProof`, 12 keys; duo live đặt tại cell 28,21 như N2211/N2267).
- `python3 register_c07_turret_configured_dispatch.py`: SSOT 11634/1718/1652/3095 (đúng kỳ vọng +4/+1/+1/+2); `--verify` 36/36.
- Targeted `python3 -m unittest tests.test_c07_turret_configured_dispatch`: **Ran 4, OK** (15.131s, proof matches:true, 12 semantic / 15 tổng). Port 7777 trống trước proof. Proof JSON đọc trực tiếp: matches:true, 15/15 true. LƯU Ý: lần chạy GREEN đầu tiên FAIL 1 (state test: signature `public void configured(@Nullable Unit builder, @Nullable Object value){` chưa nằm trong comment .gd — chỉ có tên hàm trong comment mở đầu) — sửa bằng cách thêm 1 dòng comment chứa đúng signature, chạy lại 4/4 OK. Bài học N2267 nhắc lại: mọi chuỗi assertIn phải nằm nguyên trên 1 dòng trong file .gd.
- `git diff --check` OK.
- File thay đổi (chưa commit): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + comp_slices + comp_api_contracts shards; audit report tái sinh giống hệt, không diff), test + register + proof .gd/.tscn + handoff này (mới, chưa track). Proof .json không stage (theo quy tắc). Không stage/commit gì ở bước GREEN.
- Chain script đã sẵn sàng: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2268-chain-main.sh` (bash -n OK) — neighbours 32 module (31 cũ + test_c07_turret_configured_dispatch) → wiring 9 module / 32 tests → full gate, log vào `hidden_files/n2268-chain.log`, `n2268-neighbours.log`, `n2268-wiring.log`, `tools/mindustry_godot_transpiler/full-suite-n2268-gate.log`. KHÔNG tự launch — main thread launch bằng setsid nohup (tiền lệ N2266/N2267).

## Tiếp theo (main thread)

- Gate đã xác minh độc lập lượt cron 21:00: Ran 6165, failures=218 toàn Godot-absent (217 × `AssertionError: unexpectedly None` + 1 hydration-proof variant cùng nguyên nhân; 0 KeyError, 0 `return_schema_linkage`, 0 ERROR). Neighbours 127 passed / 1 failed (coolant port-7777 flake, matches:true — environmental, không phải regression); wiring 32/32 OK. Commit + push N2268 (5 commit theo mẫu N2266/N2267: slice + docs + GOAL + status + hashes), rồi làm N2269 từ deferred list (xem report).

## Deferred (không đổi, trừ configured() dispatch đang làm)

- BuildingComp configured() dispatch effect (BuildingComp.java:1414-1432) — DONE bởi slice này (N2268); là mục tiếp theo trong handoff N2267.
- Turret configured() handler bodies — handler là Cons2 closure do block đăng ký (Block.config, Block.java:926-929); dispatch chỉ báo handler chạy. Duo không có handler nên không có body nào để model cho duo.
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Efficiency fold cho def khác ngoài duo (afflict 20f / malign 144f là PowerTurret, consumption branch riêng).
- Turret control() shootp live wiring — logic executor chưa có trong driver, không driver tick nào resolve target_position_deferred; pure function N2266 chờ executor slice gọi từ arm :398.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
