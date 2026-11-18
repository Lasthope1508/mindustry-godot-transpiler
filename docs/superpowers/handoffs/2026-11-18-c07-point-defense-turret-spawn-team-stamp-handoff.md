# Handoff — N2243 PointDefenseTurret spawn-side team stamp for live bullets (C07)

## Status: GATE 5 ĐÃ XONG — footer Ran 6065, failures=193, skipped 5, errors 0, toàn bộ Godot-absent (xác minh trực tiếp từ log: `unexpectedly None` = 193, `FAIL:` = 193, `ERROR:` = 0; mirror test PASS). N2243 GREEN 60/60 sau rename (targeted 4/4, family 24/24, wiring 32/32; proof 6 semantic keys / 9 in JSON matches:true). SSOT 11558/1693/1624/3039. Report + spec đã viết. CHƯA commit/push — đang làm 5-commit + push.

## Commits

- Slice: (this commit)
- Docs: (next commit)
- GOAL: (next commit)

## Scope

Stamp the firing turret's team onto each live bullet dict at spawn so
the N2242 wiring includes it with its real team (own-team fire excluded
by the N2239 acquire `b.team != team`). Threads `team_id` through:
sim (`SourceTurretSimulationState.gd:288`, reads the firing cell's team
from placed-block meta — `cell` is a Vector2i grid cell,
`fire_context`/`shot_context` carry no team) → bridge
(`SourceBulletRuntimePortBridge.gd:89-90`) → runtime
(`SourceBulletRuntimeState.gd:134`) →
`spawn_turret_bullet_from_state` (`SourceBulletSpawnState.gd:18`,
`team_id: int`) which stamps `"team": team_id` on the live bullet dict
(:41). Java evidence: `Turret.java:790` (passes `team` into the create
chain), `BulletType.java:954` (`bullet.team = team;`),
`BulletComp.java:29` (`@Import Team team`). Also updates the signature
pins in `test_playable.py` (13 pins). Closes the deferred entry added
by N2242 ("PointDefenseTurret spawn-side team stamp") — until this
slice, live bullets carried no team and the N2242 wiring excluded every
live bullet, so `should_consume` stayed false in live play.

## RED

`test_c07_point_defense_turret_spawn_team_stamp.py`: Ran 4 in 0.241s,
FAILED (failures=2, errors=2), KeyError 'N2243' ×2 (main-thread re-run).
Register --verify OK (worker).

## GREEN (verified by main thread from the logs + disk)

- Targeted 4/4 (Ran 4 in 17.832s, OK — worker log
  n2243-targeted-after-fix2.log).
- Family PointDefenseTurret 24/24 (6 module: power_status N2151 +
  target_acquire N2239 + aim_shoot N2240 + should_consume_cooling N2241
  + live_bullets_wiring N2242 + spawn_team_stamp N2243; main-thread run,
  log n2243-family-main.log).
- Wiring 32/32 (9/9 module chuẩn, pytest 128.49s — main-thread run, log
  n2243-wiring-main.log).
- Tổng 60/60. `git diff --check` CLEAN (main thread — recheck before
  commit).
- Proof 6 semantic keys / 9 trong JSON matches:true (keys:
  spawn_team_stamp_both_turrets_loaded,
  spawn_team_stamp_carries_firing_turret_team,
  spawn_team_stamp_first_turret_placed,
  spawn_team_stamp_second_team_carries_other_team,
  spawn_team_stamp_second_turret_placed,
  spawn_team_stamp_wiring_includes_both_with_correct_teams).
- Worker 06:45 timeout giữa GREEN (code + register xong, chưa có proof
  scene); worker 07:00 viết proof scene nhưng targeted 3/4 vì BLOCKER
  chữ ký (xem dưới); worker 07:15 sửa blocker + targeted 4/4 + proof
  xanh nhưng timeout trước family/wiring/docs/gate/commit.

## Blocker đã sửa (do chính N2243 gây ra — không phải regression)

The first GREEN signatures put mandatory `team_id: int` AFTER optional
`shoot_angle_degrees := 0.0` — GDScript forbids this. Bridge :89 and
runtime :134 both had the pattern → parse error → cascade "Could not
resolve super class inheritance from
SourcePortGameFacadePortBridge.gd" → `PortGame.gd` fails to load →
proof scene `_ready` :23 "Nonexistent function
'enter_campaign_playable_slice'" → no proof JSON, targeted 3/4
(failures=1). Fix (worker 07:15): reorder `team_id` BEFORE the optional
param in bridge :89, runtime :134, and sim call site :288
(`game.call("spawn_turret_bullet", bullet_origin, target, data, team_id,
shoot_angle_degrees)`), and update the test_playable.py pins to the
reordered form. Do NOT give team_id a default (-1 would be stamped as
a team and treated as enemy by acquire).

## SSOT

11558/1693/1623/3039 (symbols +1, ledger +1, contracts +0 sau khi gỡ
contract N2243, schema +2). N2243 done trong ledger. Defense shard
change: defense_slices 171 → 172, defense_api_contracts 170 → 170
(contract N2243 đã gỡ). Deferred pool 284 → 284 (resolve
1 spawn-side team stamp entry, +1 Windows-proof debt). Files: 4 .gd
(sim + bridge + runtime + spawn) + test_playable.py + register script
+ 5 SSOT JSON modified (source_api_contracts.json về lại HEAD — gỡ
contract là thay đổi duy nhất của N2243 ở file đó;
defense_api_contracts.json là file gitignored, đã gỡ entry);
untracked: test + register + proof .gd/.tscn
`C07PointDefenseTurretSpawnTeamStampProof`.

## Gate 1 — regression do chính N2243 (cron 08:00 phát hiện)

Footer: Ran 6065 tests in 1091.502s, FAILED (failures=203, skipped=5,
errors=0). Kỳ vọng 193. Chênh +10, toàn bộ do N2243:

- 9 lỗi catalog validator (2 errors): contract mới
  `SourceBulletSpawnState.spawn_turret_bullet_from_state`
  (return_type void) không được discovery nhận ra — validator chỉ
  discover hàm `source_` / `generated_` / `tile_`
  (`source_symbols.py:_discover_godot_owner_functions`), nên báo
  'facade/module function not discovered' + 'void return requires an
  explicit -> void implementation'. Đó là 8 test power
  generator/node slice + `test_real_catalog_report_preserves_open_p1_baseline`
  (2 errors trong report). Đây là contract owner KHÔNG prefix duy nhất
  trong 1624 contracts.
- 1 lỗi pin cũ trong test_playable.py:19520 —
  `test_port_game_uses_source_bullet_spawn_state` pin chuỗi
  `bullets.append({...})` KHÔNG có `"team": team_id` (worker chỉ cập
  nhật 13 signature pins, sót pin này).

Fix (cron 08:0x, KHÔNG đổi game — chỉ test + SSOT đăng ký):
1. Gỡ contract N2243 khỏi `source_api_contracts.json` và
   `defense_api_contracts.json` (xóa đúng entry, giữ nguyên phần còn
   lại byte-for-byte; JSON parse OK, contracts 1624 → 1623 / 170).
   Tiền lệ: 39 slice non-PortGame không có contract (họ `tile_*`,
   N1797–N1816...); validator chỉ duyệt contracts hiện có, không bắt
   buộc slice nào cũng có contract; policy
   `newSourceOwnerRequiresApiContract` chỉ kiểm tra flag = true.
   Result schema + result symbol vẫn ghi lại team đã stamp.
2. `test_playable.py:19520`: pin chuỗi append thêm `"team": team_id`
   (đúng thay đổi có chủ đích của N2243, Java-faithful — không phải
   nới assertion).
3. Register script: `has_contract True → False`, cập nhật docstring
   (SSOT 11558/1693/1623/3039, contracts +0) để chạy lại không đăng
   lại contract.
4. `git diff --check` sau sửa: CLEAN (kiểm tra lại trước commit).

Xác minh sau sửa (cron 08:0x): 10/10 test lỗi cũ chạy lại OK
(Ran 10 in 129.327s); register --verify 5/5 exprs present; targeted
N2243 4/4 OK với Godot trên PATH (Ran 4 in 18.148s; 1 test reference
chỉ chạy được khi có Godot — trước đó fail "unexpectedly None" giống
hệt trong gate 1, thuộc baseline 193). Port 7777 free khi chạy proof.

## Gate 2

Cron 08:0x, PID 9476, launch ~08:12 (guard ps ở exec riêng: không gate
nào đang chạy; javalang 0.13.0 OK; godot KHÔNG trên PATH — đúng
baseline như gate 1). Log
`tools/mindustry_godot_transpiler/full-suite-n2243-gate2.log` (gate 1
giữ nguyên làm bằng chứng). Dự kiến footer: Ran 6065, failures=193,
skipped=5, errors=0 — toàn bộ Godot-absent (đếm `AssertionError:
unexpectedly None` = số FAIL header trước khi commit). Nếu footer đúng
→ report/spec + 5-commit + push N2243.

## Gate 2 — CHẾT giữa chừng (cron 08:15 phát hiện)

PID 9476 không còn (ps không còn process python/unittest nào); log
`tools/mindustry_godot_transpiler/full-suite-n2243-gate2.log` đứng yên
ở 3861 byte (3685 dots / 171 F / 5 s, KHÔNG footer), mtime 01:13 UTC.
VM uptime 1:14 (boot 00:01 UTC) — không restart trong cửa sổ gate 2;
nguyên nhân có khả năng nhất: chết cùng session của cron run đã launch
nó (cách launch gate 2 không được ghi lại). Log gate 2 giữ nguyên làm
bằng chứng.

## Gate 3 — ĐANG CHẠY (cron 08:15 relaunch)

Launch ~08:17 +07, PID 10130 (`nohup setsid python3 -m unittest
discover -s tests -p "test_*.py" > full-suite-n2243-gate3.log 2>&1 <
/dev/null &`). Guard exec riêng: không unittest/discover/godot;
javalang 0.13.0 OK; godot KHÔNG trên PATH; `git diff --check` CLEAN;
port 7777 free. Xác minh sống: PID 10130, PPID 10102, SID 10130
(session riêng), log 3850 byte lúc ~+2.5 phút (3676 dots / 169 F /
5 s) và đang tăng — đã sống sót qua exec launch thoát. Dự kiến footer:
Ran 6065, failures=193, skipped=5, errors=0 — toàn bộ Godot-absent.
Nếu footer đúng → report/spec + 5-commit + push N2243.

## Gate 3 — CHẾT giữa chừng (main thread phát hiện)

Main thread ~08:2x nhìn thấy PID 10130 còn sống (02:46 elapsed, log
3863 byte, 3687 dots / 171 F / 0 E — đúng pace), nhưng 20 giây sau
kiểm tra lại thì PID đã KHÔNG còn, log đứng yên ở 3864 byte (3688
dots / 171 F / 0 E, KHÔNG footer). Chết ở ~60% tiến độ, đúng mẫu
gate 2. Bài học khẳng định lại: gate launch từ worker session chết
giữa chừng NGAY CẢ với `nohup setsid` — chỉ launch từ main thread
mới sống được.

## Gate 4 — launch (main thread, PID 10490)

Launch ~08:2x (guard ps ở exec riêng: không gate nào đang chạy;
javalang OK; godot KHÔNG trên PATH). Log
`tools/mindustry_godot_transpiler/full-suite-n2243-gate.log` — GHI ĐÈ
log gate 1 (footer + phân rã gate 1 được bảo toàn trong mục Gate 1
trên + MEMORY.md + nhật ký). 467 byte lúc +16s, 400 dots / 66 F / 0 E
— đang tăng. Footer xem 2 mục dưới.

## Gate 4 — ĐÃ XONG (cron 08:45 phát hiện), +1 LỖI THẬT — CHƯA PUSH

Footer (log `tools/mindustry_godot_transpiler/full-suite-n2243-gate.log`, mtime 01:40 UTC = 08:40 +07, 131771 byte): Ran 6065 tests in 1095.824s, FAILED (failures=194, skipped=5, errors=0). PID 10490 không còn chạy. Phân rã từ log (xác minh trực tiếp, cron 08:45): FAIL header 194; `AssertionError: unexpectedly None` 193 (192 plain + 1 `... : Godot required for hydration proof` — vẫn Godot-absent); ERROR 0. Lỗi duy nhất KHÔNG phải Godot-absent:

- `test_source_symbols.py:1766 test_source_ssot_defense_json_shards_declare_canonical_mirror_contracts`: `AssertionError: Items in the second set but not the first: 'SourceBulletSpawnState.spawn_turret_bullet_from_state'`. Test yêu cầu `set(defense_api_contracts) == {godot_owner của mọi defense slice}` — defense slices có 171 owner riêng biệt, defense contracts chỉ còn 170 sau khi fix gate 1 gỡ contract N2243. 192 baseline + 1 reference test N2243 (Godot-absent, đã dự kiến) + 1 mirror = 194. ✓ khớp.

Gốc rễ (fix gate 1 chưa hoàn chỉnh): việc gỡ contract sửa được 9 lỗi validator nhưng phá vỡ bất biến mirror của defense shard — mọi defense slice owner đều phải có contract. Hai test mâu thuẫn nhau với tên hàm hiện tại: mirror test bắt contract key đúng bằng owner; validator chỉ discover owner có prefix `source_`/`generated_`/`tile_` (`source_symbols.py:_discover_godot_owner_functions`), mà `spawn_turret_bullet_from_state` không có prefix. 4 hàm N2243 chạm vào đều không có contract (bridge/runtime `spawn_turret_bullet`, sim `simulate_turrets`, spawn `spawn_turret_bullet_from_state` — kiểm tra trực tiếp: 0 owner `SourceBulletSpawnState.*` / `SourceTurretSimulationState.*` / `SourceBulletRuntime*` trong contracts), nên KHÔNG có owner sẵn để đổi godot_owner sang. 52 slice khác không có contract (N1783–N1824, `PortGame.source_*` / `tile_*`) đều nằm NGOÀI defense shard nên không vi phạm mirror này; N2243 là defense slice duy nhất không có contract.

Hướng sửa (đã phân tích, CHƯA làm — cần main thread quyết):
1. (Khuyến nghị, đúng quy ước repo nhất) Đổi tên `spawn_turret_bullet_from_state` → `source_spawn_turret_bullet_from_state` (pure rename, không đổi gameplay) + đăng lại contract với owner mới (register script has_contract → True). Chạm: def SpawnState.gd:18 + call site RuntimeState.gd:141 + comment PointDefenseTurretBuildState.gd:449; pin test N2243 (:20, :51, :74, :121, :124) + test_playable.py (:19506, :19510); register script SPAWN_OWNER; SSOT (ledger + defense shard godot_owner, registry symbol godot_owner) qua chạy lại register script. Sau đó chạy lại targeted + family + wiring + proof rồi gate 5 (main thread launch).
2. Mở rộng discovery của validator để nhận hàm không prefix — đổi logic validation chung cho cả 1623 contracts, rủi ro lan rộng; không khuyến nghị.
3. Sửa mirror test để cho phép owner không contract — NỚI assertion để lấy pass, CẤM theo AGENTS.md. Không làm.
Sửa sai trong handoff này: `defense_api_contracts.json` KHÔNG phải file gitignored — nó được track (`git ls-files` có) và hiện tại sạch so với HEAD (gỡ contract đã đưa nó về lại HEAD, giống source_api_contracts.json).

## Gate 4 — ĐỎ +1 (main thread, PID 10490, ~08:2x–08:40)

Footer: Ran 6065 in 1095.824s, FAILED (failures=194, skipped=5,
errors=0). Kỳ vọng 193. Phân rã (main thread, từ log): 193
Godot-absent (`unexpectedly None` = 193 = FAIL headers 194 − 1) + 1
non-Godot duy nhất: `test_source_ssot_defense_json_shards_declare_canonical_mirror_contracts`
— "Items in the second set but not the first:
'SourceBulletSpawnState.spawn_turret_bullet_from_state'". Gốc rễ: fix
gate 1 (gỡ contract N2243) sửa 9 lỗi validator nhưng phá bất biến
mirror của defense shard (slices 171 owner vs contracts 170): mirror
bắt contract key đúng bằng owner, validator chỉ discover owner có
prefix `source_`/`generated_`/`tile_`. QUYẾT HƯỚNG SỬA (main thread,
08:45): rename `spawn_turret_bullet_from_state` →
`source_spawn_turret_bullet_from_state` (pure rename, không đổi
gameplay) + đăng lại contract (has_contract → True). Đổi: definition
(SourceBulletSpawnState.gd:18), call site duy nhất
(SourceBulletRuntimeState.gd:141), comment
(SourcePointDefenseTurretBuildState.gd:449), test exact_exprs, register
script, re-run register (SSOT entries được viết lại). Tên mới chưa
tồn tại ở đâu (đã grep — không collision). Sau rename: validator
discover được (prefix `source_`) → 9 lỗi validator vẫn sửa; mirror
thấy contract → hết lỗi; slices 171 vs contracts 171 cân bằng. Hai
hướng khác đã loại: mở rộng discovery của validator (rủi ro lan rộng),
nới mirror test (cấm theo AGENTS.md). Sau rename: targeted 4/4 →
family 24/24 → wiring 32/32 → proof → gate 5 (main thread launch).

Main thread, PID 6030, launch ~07:3x (guard ps ở exec riêng: không gate
nào đang chạy; javalang OK; godot KHÔNG trên PATH; `git diff --check`
CLEAN). Log `tools/mindustry_godot_transpiler/full-suite-n2243-gate.log`
(163 byte lúc +6s, 378 byte lúc +15s — đang tăng; PID 6030 sống, 333
dots / 44 F / 0 E lúc +15s). Dự kiến footer: Ran 6065, failures=193,
skipped=5, errors=0 — toàn bộ Godot-absent (baseline N2242 Ran 6061 /
192 failures + 4 tests mới + 1 failure reference mới của N2243). Kiểm
tra tại footer bằng cách đếm `AssertionError: unexpectedly None` = số
FAIL header trước khi commit.

## Next

## Gate 5 — ĐANG CHẠY (main thread, PID 4027)

Wiring sau rename: 32/32 PASS trong 237.41s (main thread, log
n2243-wiring-after-rename.log), port 7777 free. N2243 GREEN 60/60 sau
rename (targeted 4/4, family 24/24, wiring 32/32, proof 6 semantic /
9 JSON matches:true, mirror module 17 passed). Gate 5 launch ~09:23
(guard ps ở exec riêng: không gate nào đang chạy; javalang OK; godot
KHÔNG trên PATH; port 7777 free). Log
`tools/mindustry_godot_transpiler/full-suite-n2243-gate5.log`, 251
byte lúc +17s (238 dots / 12 F / 0 E — đang tăng). Dự kiến footer:
Ran 6065, failures=193, skipped=5, errors=0 — toàn bộ Godot-absent.
Kiểm tra tại footer bằng cách đếm `AssertionError: unexpectedly
None` = số FAIL header trước khi commit.

## Gate 5 — ĐÃ XONG (cron 10:00 phát hiện), GATE SẠCH NGOẠI TRỪ GODOT

Footer (log `tools/mindustry_godot_transpiler/full-suite-n2243-gate5.log`, mtime 02:55 UTC = 09:55 +07, 131002 byte): Ran 6065 tests in 1867.939s, FAILED (failures=193, skipped=5, errors=0). PID 4027 không còn chạy. Phân rã từ log (xác minh trực tiếp, cron 10:00): FAIL header 193; `AssertionError: unexpectedly None` 193 (192 plain + 1 `... : Godot required for hydration proof` — vẫn Godot-absent); ERROR 0; KeyError 0. Mirror test KHÔNG còn trong danh sách FAIL — PASS. 192 baseline + 1 reference test N2243 (Godot-absent, đã dự kiến) = 193. ✓ khớp dự kiến. → report/spec + 5-commit + push N2243.

## Next

Gate 5 footer → report/spec + 5-commit + push N2243.
Sau đó: suppression live + targets live list vẫn BLOCKED (cần frame plumbing); PointDefenseTurret draw/write/read/setStats/icons rows + live coolant efficiency/trừ liquid/coolEffect + bullet hitSize + live bullet removal. Proofs not yet run on Windows Godot — debt in GOAL.md §5.
