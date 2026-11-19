# Report — N2269 Turret queuedBullets counter + charging() gate (C07) [GREEN, chờ gate]

## Status: DONE + PUSHED (2026-11-19 ~22:15 +07, lượt cron 22:15) — slice `188a1ac3`, docs `8cf2143f`, GOAL `a3c88d44`. Targeted 4/4 + proof matches:true 15/15 + register --verify 36/36 + gate Ran 6169, failures=219 toàn Godot-absent (đã xác minh độc lập).

- N2268 DONE + PUSHED (origin/main 6cfc8b8e, slice 1d030ba5) — đã xác minh đầu lượt cron 21:15: git log 5 commit khớp, HEAD == origin/main == 6cfc8b8e, worktree sạch ngoại trừ noise *.gd.uid (không stage) + log cũ full-suite-*.log / hidden_files/ ở repo root (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_queued_bullets_state(queued_bullets, first_shot_delay, queued_now, fired_now, reload_counter, reload, shoot_warmup, min_warmup)` (8 params, 4 keys: queued_bullets, charging, can_shoot, reload_counter_after) trong `SourceTurretBuildState.gd` (sau `source_turret_configured_dispatch_state`, trước `source_turret_tick_buildings_state`). KHÔNG driver tick — delayed bullets là Time.run callback, không có tương đương trong driver; gate tính theo shoot event (tiền lệ N2248/N2264/N2266/N2267/N2268), proof gọi direct. Sound/effect charge không model (chờ slice riêng).
- Java (Turret.java): `public int queuedBullets = 0;` (:293); `charging()` (:715-717): `public boolean charging(){ return queuedBullets > 0 && shoot.firstShotDelay > 0; }`; `updateShooting()` (:731-740): `if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){ shoot(type); reloadCounter %= reload; }`; `shoot()` (:741-777): pattern callback `queuedBullets++;` (:754), delay > 0 thì `Time.run(delay, () -> { bullet(...); });` (:756-764), ngược lại bắn ngay (:765); `bullet()` (:772-777): `queuedBullets --;` (:773). updateShooting() chạy từ updateTile() (:601/:609). Nhánh delay > 0 phát charge sound (:747-748): `chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));` — `/** Sound emitted when shoot.firstShotDelay is >0 and shooting begins. */` (:125).
- Field default `public float firstShotDelay = 0;` (ShootPattern.java:11); def duy nhất set là lancer: `lancer = new PowerTurret("lancer"){{` / `range = 165f;` / `shoot.firstShotDelay = 40f;` / `reload = 80f;` (Blocks.java:3560-3567). Duo không set → delay 0, charging luôn false, bullet delay-0 bắn ngay → counter luôn 0. `public float minWarmup = 0f;` (Turret.java:76).
- charging tính trên counter TRƯỚC update (thứ tự :733); queued_after = queued + queued_now - fired_now; reload_counter_after = fmod khi gate pass.
- 12 proof keys: qb_queue_increments, qb_fire_decrements, qb_charging_true_lancer, qb_charging_false_no_queue, qb_charging_false_zero_delay, qb_gate_blocks_while_charging, qb_gate_allows_when_ready, qb_gate_blocks_reload_not_ready, qb_gate_blocks_warmup_low, qb_cross_tick_blocks_next_shot, qb_lancer_live, qb_duo_live. Duo live đặt tại cell 28,21 như N2211/N2268.
- SSOT sau GREEN (đo từ đĩa): symbols 11638 (+4), Done 1719 (+1), contracts 1653 (+1), schemas 3097 (+2) → 11638/1719/1653/3097. Shard defense: slices 196 (+1), contracts 195 (+1) — slice đi shard defense vì java_source là Turret.java (tiền lệ N2265/N2266); comp giữ nguyên 557/461.

## RED (lượt cron 21:15)

- `python3 register_c07_turret_queued_bullets.py --verify`: **36/36 exprs present** (24 exact + 8 input + 4 output).
- `python3 -m unittest tests.test_c07_turret_queued_bullets` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2268. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2269'` (ledger chưa có entry N2269); state test FAIL vì pure function `source_turret_queued_bullets_state` chưa có; proof test FAIL vì `C07TurretQueuedBulletsProof.tscn` chưa tồn tại.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_queued_bullets.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_queued_bullets.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt cron 21:15)

- Pure function + register script + proof `C07TurretQueuedBulletsProof` đã có; SSOT đúng kỳ vọng 11638/1719/1653/3097 (xác minh từ đĩa: registry symbols 11638, ledger slices 1719, contracts 1653, schemas 3097, defense_slices 196 / defense_api_contracts 195); `git diff --check` OK.
- Targeted chạy lượt 21:15: **Ran 4, OK (15.344s)**, port 7777 trống trước proof. LƯU Ý: lần chạy GREEN đầu tiên FAIL 1 (key qb_cross_tick_blocks_next_shot: tick 3 kỳ vọng charging false + can_shoot true, nhưng charging tính trên counter pre-update theo thứ tự :733 nên tick 3 vẫn charging true — kỳ vọng sai, không phải code sai) — sửa bằng cách thêm tick 4 (queue rỗng → charging false, gate mở lại), chạy lại 4/4 OK.
- Proof JSON `C07TurretQueuedBulletsProof.json` (đọc trực tiếp): **matches:true, 15/15 true** (12 keys qb_* + `matches` + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify` chạy lại: **36/36 exprs present**.
- Chain script `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2269-chain-main.sh` đã sẵn sàng (bash -n OK) — neighbours 33 module → wiring 9 module / 32 tests → full gate. KHÔNG tự launch — main thread launch bằng setsid nohup (tiền lệ N2266/N2267/N2268; worker-launched gate chết giữa chừng).
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover / chain nào đang chạy đầu lượt.
- Không stage/commit gì ở bước GREEN (chỉ có file slice + SSOT + handoff/report/spec này, chưa track hoặc modified; *.gd.uid, full-suite-*.log cũ, hidden_files/ ở repo root không stage).

## Tiếp theo: N2270

- Gate #4 đã xác minh độc lập lượt 22:15: Ran 6169, failures=219 toàn Godot-absent (219 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR); neighbours EXIT 0 (132 passed); wiring Ran 32 OK. LƯU Ý: lượt 22:15 launch nhầm chain #5 trùng khi gate #4 đã xong 22:04 — đã kill ngay trong ~1 phút, không ảnh hưởng gate log; file n2269-neighbours.log bị ghi đè (chỉ còn chain.log NEIGHBOURS-EXIT 0 + số liệu ghi từ lượt 22:00). Commit + push N2269 (5 commit theo mẫu N2266/N2267/N2268: slice + docs + GOAL + status + hashes), rồi làm N2270 từ deferred list trong handoff N2269: efficiency fold cho def khác ngoài duo (afflict 20f / malign 144f là PowerTurret, consumption branch riêng); Turret control() shootp live wiring (cần logic executor); unit maxHealth/health re-sync từ tile() (cần live tile_health); unit world position từ set(tile); các def ItemTurret khác ngoài duo; charge sound/effect cho firstShotDelay > 0. calculateHeat live proximity scan và findTarget vẫn BLOCKED — live entity scan.
