# Handoff — N2241 PointDefenseTurret updateTile shouldConsume gate + coolant (C07)

## Status: DONE + PUSHED (slice 64091326, main 2ef037b3). Test + proof xanh, gate sạch trừ Godot-absent (Ran 6057, failures=191, skipped=5, errors=0). SSOT 11556/1691/1622/3035. Targeted 4/4, family PointDefenseTurret 16/16, wiring 32/32 = 52/52; proof 8 semantic keys / 11 in JSON matches:true.

## Commits

- Slice: 64091326
- Docs: de65d796
- GOAL: 9396917d

## Scope

2 pure functions trong `SourcePointDefenseTurretBuildState.gd`:
- `source_point_defense_turret_should_consume_state(frame)` (:354) →
  `{"should_consume": bool}` = `enabled && target != null`
  (PointDefenseTurret.java:105-107; super chain là
  Building.shouldConsume() == enabled, BuildingComp.java:755-757 —
  TurretBuild.shouldConsume() (Turret.java:364) KHÔNG nằm trong chain,
  nhánh sibling, không dùng).
- `source_point_defense_turret_cooling_state(frame, has_coolant,
  coolant_amount, coolant_efficiency, heat_capacity,
  coolant_multiplier, reload, edelta)` (:380) → cooling boost /
  coolant consumed / reload counter (ReloadTurret.java:28-38,
  `updateCooling`).
- **+ driver tick lines**: consumption branch thay
  `bool(frame.get("enabled", true))` bằng pure-function call; cooling
  call trước aim/shoot half (PointDefenseTurret.java:74-76). Def segment
  KHÔNG có coolant consumer → driver call là no-op trung thực
  (has_coolant=false); live coolant efficiency, trừ liquid và
  coolEffect DEFERRED.

HẬU QUẢ SỐNG (trung thực Java): chưa có bullet wiring thì frame không
có observed_bullets → target null → should_consume false → efficiency
về 0 (BuildingComp.java:1947); xấp xỉ "máy chạy khi enabled" của N2151
kết thúc ở slice này; proof phải đưa observed target vào mới thấy tiêu
thụ.

## RED

`test_c07_point_defense_turret_should_consume_cooling.py`: Ran 4 in
1.114s, FAILED (failures=2, errors=2), KeyError 'N2241' ×2 (main-thread
re-run). Register --verify 37/37 exit 0.

## GREEN (main thread re-run targeted + wiring; family từ log worker — đầy đủ)

- Targeted 4/4 (15.737s main-thread re-run sau khi sửa prefix test;
  worker log pytest 4 passed, 48 subtests, 15.12s).
- Family PointDefenseTurret 16/16 (4 module: power_status N2151 +
  target_acquire N2239 + aim_shoot N2240 + should_consume_cooling;
  pytest 59.27s — worker log, sau khi sửa 2 scene dưới).
- Wiring 32/32 (9/9 module chuẩn, pytest 133.36s — main thread).
- Tổng 52/52. `git diff --check` CLEAN (main thread, trước khi launch gate).
- Proof 8 semantic keys / 11 trong JSON matches:true (keys: 5 cooling
  — cooling_boosts_reload_counter, cooling_reports_coolant_consumed,
  cooling_skipped_when_coolant_efficiency_zero,
  cooling_skipped_when_reloaded, cooling_skipped_without_coolant — +
  3 should-consume — should_consume_true_when_enabled_with_target,
  should_consume_false_when_disabled,
  should_consume_false_without_target).
- Worker 03:00 timeout giữa GREEN (targeted 3/4 do lỗi prefix test,
  family 12/16 do chạy thiếu godot PATH, wiring chưa chạy); worker
  03:15 sửa 2 scene + chạy targeted/family xong, wiring bị abort giữa
  chừng (log 457 byte, mới 2 module); main thread chạy lại wiring.
  Logs worker ở goal hidden_files/n2241-*.log.

## Harness fixes (main thread + worker, KHÔNG đụng gameplay/driver)

1. Test prefix (main thread): test :275 chờ
   `C_07_POINT_DEFENSE_TURRET_SHOULD_CONSUME_COOLING_PROOF` nhưng
   scene in `C_07_POINT_DEFENSE_TURRET_SHOULD_CONSUME_COOLANT_PROOF`
   (tên file/scene/prefix đều Coolant) → sửa test sang COOLANT_PROOF.
2. NEIGHBOUR REGRESSION (thật, driver đúng Java — xem
   `goal hidden_files/n2241-neighbour-regression.md`): family 14/16
   trước khi sửa scene — N2151 power_status FAIL
   (efficiency_folds_power_min False) + N2240 aim_shoot FAIL (4 key
   shoot False). Gốc rễ: driver tính efficiency TRƯỚC khi retarget
   stamp target, nên tick đầu acquire có edelta = 0, không bắn — thứ
   tự này ĐÚNG Java (`Building.update()` gọi `updateConsumption()`
   :2274 TRƯỚC `updateTile()` :2277; BuildingComp.java:1947).
   Sửa 2 proof scene (worker 03:15): AimShoot thêm 1 tick sau khi seed
   bullets (tick A acquire, tick B bắn); PowerStatus stamp target sống
   lên frame trước tick. Sau sửa: family 16/16.

## SSOT

11556/1691/1622/3035 (symbols +4, ledger +1, contracts +1, schema +2).
N2241 done trong ledger. Defense shard change: defense_slices 169 →
170, defense_api_contracts 168 → 169. 7 file sửa (family.gd + 4 SSOT
canonical + 2 shard) + 2 proof scene sửa (N2151 + N2240, harness-only);
untracked: test + register + proof.gd/.tscn
`C07PointDefenseTurretShouldConsumeCoolantProof`.
Deferred pool 281 → 282 (+1 Windows-proof debt, không resolve entry nào).

## Gate

Main thread, PID 5187, launch ~03:3x (guard ps ở exec riêng: không gate
nào đang chạy; javalang OK; godot KHÔNG trên PATH). Log
`tools/mindustry_godot_transpiler/full-suite-n2241-gate.log`. FOOTER ĐÃ
VỀ (~03:54): Ran 6057 in 1098.601s, failures=191, skipped=5, errors=0 —
đếm trực tiếp: `AssertionError: unexpectedly None` = 191, `FAIL:` = 191,
`ERROR:` = 0, KeyError = 0 — toàn bộ Godot-absent, đúng dự kiến (Ran 6053 →
6057, failures 190 → 191). VA CHẠM: cron 03:30 launch gate trùng (PID
5200) ghi cùng log — đã kill lúc 20:37 UTC, chỉ giữ 5187; đoạn
progress-dot đầu log bị xen kẽ ~1 phút, footer do 5187 ghi cuối nên sạch.

## Next

Gate → report/spec + 5-commit + push N2241 (đang làm ở lần chạy 04:00). Sau đó họ tiếp theo theo
backlog (driver map live bullets → observed dicts wiring — lúc đó
should_consume sống thật; suppression live + targets live list vẫn
BLOCKED). Proofs not yet run on Windows Godot — debt in GOAL.md §5.
