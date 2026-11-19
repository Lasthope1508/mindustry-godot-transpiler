# Handoff — N2269 Turret queuedBullets counter + charging() gate (C07) [GREEN, chờ gate]

## Status: DONE + PUSHED (2026-11-19 ~22:15 +07, lượt cron 22:15) — slice `188a1ac3`, docs `8cf2143f`, GOAL `a3c88d44`. Targeted 4/4 + proof matches:true 15/15 + register --verify 36/36 + gate Ran 6169, failures=219 toàn Godot-absent (đã xác minh độc lập).

## Scope (đã khóa, xác minh từ đĩa)

- Slice Turret queuedBullets counter + charging() gate (Turret.java:293, :715-717, :731-740, :741-777): `public int queuedBullets = 0;` (:293); `charging()` (:715-717): `public boolean charging(){` / `return queuedBullets > 0 && shoot.firstShotDelay > 0;` / `}`; `updateShooting()` (:731-740): `protected void updateShooting(){` / `if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){` / `shoot(type);` / `reloadCounter %= reload;` / `}`; `shoot()` (:741-777): `protected void shoot(BulletType type){` — pattern callback `queuedBullets++;` (:754), delay > 0 thì hoãn: `if(delay > 0f){` / `Time.run(delay, () -> {` / `bullet(type, xOffset, yOffset, angle, mover);` / `});` (:756-764), ngược lại bắn ngay (:765); `bullet()` (:772-777): `protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){` / `queuedBullets --;` (:773). updateShooting() chạy từ updateTile() (`updateShooting();`, :601/:609).
  - Nhánh delay > 0 còn phát charge sound khi bắt đầu bắn: `if(shoot.firstShotDelay > 0){` / `chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));` (:747-748) — `/** Sound emitted when shoot.firstShotDelay is >0 and shooting begins. */` (:125). Sound/effect KHÔNG model trong slice này (chờ slice riêng).
  - Field default: `public float firstShotDelay = 0;` (ShootPattern.java:11). Def duy nhất set firstShotDelay là lancer: `lancer = new PowerTurret("lancer"){{` / `range = 165f;` / `shoot.firstShotDelay = 40f;` / `reload = 80f;` (Blocks.java:3560-3567). Duo không set (Blocks.java:3257-3331) → delay 0, charging() luôn false, bullet delay-0 bắn ngay → counter luôn 0.
  - `public float minWarmup = 0f;` (Turret.java:76) là floor warmup trong gate :733.
- 1 pure function `source_turret_queued_bullets_state(queued_bullets, first_shot_delay, queued_now, fired_now, reload_counter, reload, shoot_warmup, min_warmup)` (8 params, 4 keys: queued_bullets, charging, can_shoot, reload_counter_after) trong `SourceTurretBuildState.gd` (sau `source_turret_configured_dispatch_state`, trước `source_turret_tick_buildings_state`). charging tính trên counter TRƯỚC update (thứ tự :733 — gate đọc counter trước khi shoot() queue); queued_after = queued + queued_now - fired_now; can_shoot = reload ready + không charging + warmup >= floor; reload_counter_after = fmod(reload_counter, reload) khi gate pass, ngược lại giữ nguyên. KHÔNG driver tick — delayed bullets là Time.run callback, không có tương đương trong driver; gate tính theo shoot event, không phải per tick (tiền lệ N2248/N2264/N2266/N2267/N2268), proof gọi direct.
- 12 proof keys: qb_queue_increments, qb_fire_decrements, qb_charging_true_lancer, qb_charging_false_no_queue, qb_charging_false_zero_delay, qb_gate_blocks_while_charging, qb_gate_allows_when_ready, qb_gate_blocks_reload_not_ready, qb_gate_blocks_warmup_low, qb_cross_tick_blocks_next_shot, qb_lancer_live, qb_duo_live.
- SSOT sau GREEN (đo từ đĩa): symbols 11638 (+4), Done 1719 (+1), contracts 1653 (+1), schemas 3097 (+2) → 11638/1719/1653/3097. Shard defense: slices 196 (+1), contracts 195 (+1) — slice đi shard defense vì java_source là Turret.java (tiền lệ N2265/N2266); comp giữ nguyên 557/461.

## RED (lượt này, chạy + xác minh)

- `python3 register_c07_turret_queued_bullets.py --verify`: **36/36 exprs present** (24 exact + 8 input + 4 output).
- `python3 -m unittest tests.test_c07_turret_queued_bullets` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2268. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2269'` (ledger chưa có entry N2269); state test FAIL vì pure function `source_turret_queued_bullets_state` chưa có; proof test FAIL vì `C07TurretQueuedBulletsProof.tscn` chưa tồn tại.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_queued_bullets.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_queued_bullets.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt này, chạy + xác minh)

- Viết pure function `source_turret_queued_bullets_state` (SourceTurretBuildState.gd, sau `source_turret_configured_dispatch_state`, 8 params, 4 keys queued_bullets/charging/can_shoot/reload_counter_after).
- Viết proof `C07TurretQueuedBulletsProof` (.gd + .tscn, mirror `C07TurretConfiguredDispatchProof`, 12 keys; duo live đặt tại cell 28,21 như N2211/N2268).
- `python3 register_c07_turret_queued_bullets.py`: SSOT 11638/1719/1653/3097 (đúng kỳ vọng +4/+1/+1/+2); `--verify` 36/36.
- Targeted `python3 -m unittest tests.test_c07_turret_queued_bullets`: **Ran 4, OK** (15.344s, proof matches:true, 12 semantic / 15 tổng). Port 7777 trống trước proof. Proof JSON đọc trực tiếp: matches:true, 15/15 true. LƯU Ý: lần chạy GREEN đầu tiên FAIL 1 (key qb_cross_tick_blocks_next_shot: tick 3 kỳ vọng charging false + can_shoot true, nhưng charging tính trên counter pre-update theo thứ tự :733 nên tick 3 vẫn charging true — kỳ vọng sai, không phải code sai) — sửa bằng cách thêm tick 4 (queue rỗng → charging false, gate mở lại), chạy lại 4/4 OK. Bài học: gate :733 đọc counter đầu tick, callback Time.run chỉ drain counter sau đó.
- `git diff --check` OK.
- File thay đổi (chưa commit): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts shards; audit report tái sinh giống hệt, không diff), test + register + proof .gd/.tscn + handoff này (mới, chưa track). Proof .json không stage (theo quy tắc). Không stage/commit gì ở bước GREEN.
- Chain script đã sẵn sàng: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2269-chain-main.sh` (bash -n OK) — neighbours 33 module (32 cũ + test_c07_turret_queued_bullets) → wiring 9 module / 32 tests → full gate, log vào `hidden_files/n2269-chain.log`, `n2269-neighbours.log`, `n2269-wiring.log`, `tools/mindustry_godot_transpiler/full-suite-n2269-gate.log`. KHÔNG tự launch — main thread launch bằng setsid nohup (tiền lệ N2266/N2267/N2268).

## Tiếp theo (main thread)

- Gate #4 đã xác minh độc lập lượt 22:15: Ran 6169, failures=219 toàn Godot-absent (219 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +1 failure là test reference-graph của chính N2269). Neighbours EXIT 0 (132 passed — ghi từ lượt 22:00; file n2269-neighbours.log bị ghi đè bởi chain trùng launch nhầm lúc 22:15, đã kill ngay trong ~1 phút, không ảnh hưởng gate log); wiring Ran 32 OK. LƯU Ý: lượt 22:15 launch nhầm chain #5 trùng khi gate #4 đã xong 22:04 — đã kill ngay; bài học: đọc chain.log + nhật ký lượt trước trước khi launch chain mới.
- Commit + push N2269 (5 commit theo mẫu N2266/N2267/N2268: slice + docs + GOAL + status + hashes), rồi làm N2270 từ deferred list (xem report).

## Deferred (không đổi, trừ queuedBullets đang làm)

- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0 — DONE bởi slice này (N2269); là mục deferred trong handoff N2268.
- Turret charge sound / charge effect cho firstShotDelay > 0 — effects/sound chờ slice riêng; N2269 chỉ pin nhánh firstShotDelay > 0 tồn tại (Turret.java:747-748).
- Turret configured() handler bodies — handler là Cons2 closure do block đăng ký (Block.config, Block.java:926-929); dispatch chỉ báo handler chạy. Duo không có handler nên không có body nào để model cho duo.
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Efficiency fold cho def khác ngoài duo (afflict 20f / malign 144f là PowerTurret, consumption branch riêng).
- Turret control() shootp live wiring — logic executor chưa có trong driver, không driver tick nào resolve target_position_deferred.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
