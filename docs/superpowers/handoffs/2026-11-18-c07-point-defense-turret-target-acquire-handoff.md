# Handoff — N2239 PointDefenseTurret updateTile target acquire (C07)

## Status: GREEN, gate DONE (main thread, PID 2361, ~00:36–00:54). Test + proof xanh, gate sạch (chỉ Godot-absent), chờ 5-commit + push. SSOT 11544/1689/1620/3031. Targeted 4/4, family PointDefenseTurret 8/8, wiring 32/32 = 44/44; proof 8 semantic keys / 11 in JSON matches:true. Gate footer Ran 6049, failures=189, skipped=5, errors=0 — toàn bộ Godot-absent.

## Commits

- Slice: (this commit)
- Docs: (next commit)
- GOAL: (next commit)

## Scope

1 pure function `source_point_defense_turret_target_acquire_state(frame,
observed_bullets, team_id, x, y, range, delta)` trong
`SourcePointDefenseTurretBuildState.gd` → target/has_target/target_timer/
reacquired; **+ 1 driver tick line** (:288: driver gọi hàm với
`frame.get("observed_bullets", [])`, team_id, sprite position, range 180.0,
delta `seconds`).
- Timer 5.0s accumulator reset-to-0 (Interval.get — reset, không trừ
  interval, đúng Java).
- Invalidation theo id (pooled = !isAdded, PointDefenseTurret.java:69-71).
- Re-acquire min dst2 trong rect x±range (range 180f, Blocks.java:3838).
- Aim/rotation/reload/shoot (:76-101) + shouldConsume gate + coolant chờ
  slice riêng.
- Retarget KHÔNG bị block (tiền lệ ShockwaveTower observed_bullets N2190;
  driver map live bullets → observed dicts là wiring sau; driver chưa stamp
  gì cho tới lúc đó).

Java evidence (grep -n trên disk):
- PointDefenseTurret.java:20 `timerTarget = timers++`, :21 `retargetTime
  = 5f`, :60 `public @Nullable Bullet target;`, :65-67 retarget
  (`if(timer(timerTarget, retargetTime)){` /
  `target = Groups.bullet.intersect(x - range, y - range, range*2,
  range*2).min(b -> b.team != team && b.type().hittable, b ->
  b.dst2(this));`), :69-71 pooled invalidation (`if(target != null &&
  !target.isAdded()){ target = null; }`).
- TimerComp.java:8 `transient Interval timer = new Interval(6);`, :10-12
  `timer()` → `Interval.get`; Interval.java:24/29 (fire khi elapsed >=
  time, stamp fire time).
- Blocks.java:3838 range 180f (point-defense-turret def).

## RED

`test_c07_point_defense_turret_target_acquire.py`: Ran 4 in 0.610s,
FAILED (failures=2, errors=2), KeyError 'N2239' ×2 (main-thread re-run sau
khi đổi số từ N2238 — xem mục va chạm ở handoff N2238). Register --verify
25/25 exit 0 (script implements --verify, đã kiểm tra trước).

## GREEN (main thread re-run)

- Targeted 4/4 (16.090s, main-thread re-run).
- Family PointDefenseTurret 8/8 (2 module: power_status N2151 +
  target_acquire; pytest 35.41s, 64 subtests — main-thread re-run sau
  restart #36; worker log 31.61s).
- Wiring 32/32 (9/9 module OK ngay lượt đầu, main thread re-run sau
  restart #36 — worker bị timeout trước khi chạy wiring; log
  `n2239-wiring.log` của worker 0 byte).
- Tổng 44/44. `git diff --check` CLEAN (main thread).
- Proof 8 semantic keys / 11 trong JSON matches:true (keys:
  acquire_picks_closest_enemy_hittable, acquire_ignores_same_team,
  acquire_ignores_non_hittable, acquire_ignores_out_of_rect,
  acquire_runs_without_power, no_target_before_timer_fire,
  reacquire_replaces_valid_target_on_fire, target_cleared_when_pooled).

## SSOT

11544/1689/1620/3031 (symbols +4, ledger +1, contracts +1, schema +2).
N2239 done trong ledger. Defense shard change (PointDefenseTurret.java ở
defense/turrets/ nên match shard): defense_slices 167 → 168,
defense_api_contracts 166 → 167. 4 file sửa (family.gd + 4 SSOT canonical)
+ 2 file shard; untracked: test + register + proof.gd/.tscn
`C07PointDefenseTurretTargetAcquireProof`.
Deferred pool 279 → 280 (+1 Windows-proof debt, không resolve entry nào).

## Groups.java fix (RED-test fix, N2239)

Test input-evidence đọc unconditional `slice_sources` gồm
`core/src/mindustry/entities/Groups.java` — file KHÔNG tồn tại trên disk
(Groups sinh lúc build từ GroupDefs.java; `git ls-files` xác nhận không
tracked ở upstream rev 2bdedfed2; không có `class Groups` nào trong
core/src). Worker 00:15 sửa test: thay Groups.java → GroupDefs.java trong
slice_sources, kèm comment giải thích (test :99-106). GroupDefs.java tồn
tại trên disk. Expr `Groups.bullet.intersect` vẫn source-backed qua
PointDefenseTurret.java:66 (đã đọc). Đây là test-harness fix, không đụng
gameplay.

## Gate

Main thread, PID 2361, launch ~00:36, xong ~00:54 (log mtime 17:54 UTC −
1061.999s). Log `tools/mindustry_godot_transpiler/full-suite-n2239-gate.log`
(untracked, KHÔNG stage). Footer THỰC: Ran 6049 in 1061.999s, failures=189,
skipped=5, errors=0 — khớp đúng dự kiến. Đối chiếu: `AssertionError:
unexpectedly None` = 189, `FAIL:` = 189, `ERROR:` = 0, KeyError = 0 (cron
01:00 đếm trực tiếp trong log). Test reference N2239 nằm trong 189 (gate
log :483, Godot-absent). Cách tính (đã khớp): gate N2238 Ran 6049,
failures=190, errors=2 (189 Godot-absent + 1 FAIL state test N2239 + 2 ERROR
KeyError N2239). Sang gate N2239, module N2239 đã có trong Ran (không +4);
state test giờ PASS (function đã có, state test không cần Godot — bằng
chứng: mỗi slice trước chỉ +1 failure vào gate, đúng bằng test reference
của nó) → failures 190 − 1 = 189; 2 ERROR KeyError biến mất (ledger đã có
N2239) → errors 0; test reference N2239 vẫn fail Godot-absent như trước
(đã tính trong 189).

## Restart #36

VM restart ~00:3x (uptime 1 min lúc phát hiện) wipe javalang + pytest —
main thread cài lại javalang 0.13.0 (requirements.txt) + pytest 9.2.0 và
chạy lại family + wiring. Không gate nào đang chạy lúc restart (gate
N2238 đã xong trước đó).

## Next

Wiring → gate → report/spec + 5-commit + push N2239. Sau đó họ tiếp theo
theo backlog (suppression live + targets live list vẫn BLOCKED). Proofs
not yet run on Windows Godot — debt in GOAL.md §5.
