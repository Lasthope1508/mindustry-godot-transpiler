# Báo cáo — N2241 PointDefenseTurret updateTile shouldConsume gate + coolant updateCooling (C07)

Ngày: 2026-11-18 ~02:4x–04:00 +07. Slice trước N2240 DONE + PUSHED (main bcfff708, SSOT 11552/1690/1621/3033 — đã xác minh lại từ disk).

## Kết luận scoping

N2241 làm được, không còn blocker. 2 hàm pure mới + driver tick lines. Phần còn lại của updateTile: coolant call :74-76 + shouldConsume() :105-107. Aim/rotation/reload/shoot đã xong ở N2240; live coolant efficiency, trừ liquid và coolEffect DEFERRED (def segment không có coolant consumer).

## Java đã pin (đọc từ disk)

- PointDefenseTurret.java:105-107 shouldConsume = `super.shouldConsume() && target != null`.
- Super chain là Building.shouldConsume() == enabled (BuildingComp.java:755-757) — TurretBuild.shouldConsume() (Turret.java:364, isShooting || reloadCounter < reload) KHÔNG nằm trong chain (nhánh sibling, PointDefenseBuild extends ReloadTurretBuild trực tiếp) — KHÔNG dùng.
- updateCooling từ ReloadTurret.java:28-38 (`coolantMultiplier = 2f`; `canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0`; capacity = heatCapacity của liquid đang tiêu thụ, mặc định 0.4f; `reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier()`; `coolant.update(this)`; chance 0.06 * amount cho coolEffect).
- Def segment Blocks.java:3838-3846 KHÔNG có coolant consumer → driver call là no-op trung thực (has_coolant=false).

## HẬU QUẢ SỐNG (trung thực Java)

Chưa có bullet wiring thì frame không có observed_bullets → target null → should_consume false → efficiency về 0 (BuildingComp.java:1947); xấp xỉ "máy chạy khi enabled" của N2151 kết thúc ở slice này; proof phải đưa observed target vào mới thấy tiêu thụ.

## RED (2026-11-18 ~02:4x +07)

- RED 4 failed (Ran 4 in 1.114s, failures=2, errors=2; KeyError 'N2241' ×2 — main-thread re-run).
- Register --verify 37/37 exit 0.

## GREEN (2026-11-18 ~02:5x–03:13 +07)

- 2 hàm pure mới trong `SourcePointDefenseTurretBuildState.gd`:
  - `source_point_defense_turret_should_consume_state(frame)` (:354) trả `{"should_consume": bool}` = `enabled && target != null`.
  - `source_point_defense_turret_cooling_state(frame, has_coolant, coolant_amount, coolant_efficiency, heat_capacity, coolant_multiplier, reload, edelta)` (:380) trả cooling boost / coolant consumed / reload counter.
  - + driver tick lines: consumption branch thay `bool(frame.get("enabled", true))` bằng pure-function call; cooling call trước aim/shoot half.
- Proof `C07PointDefenseTurretShouldConsumeCoolantProof.gd` + `.tscn` (mới): 8 key semantic đã pin.
- Register --verify 37/37; main() exit 0. SSOT từ disk: **11556/1691/1622/3035** — đúng delta dự kiến (symbols +4, Done +1, contracts +1, schema +2). N2241 trong ledger, status done. Defense shard change: defense_slices 169 → 170, defense_api_contracts 168 → 169.
- Targeted **4/4 OK** (main-thread re-run: Ran 4 tests in 15.737s, OK — sau khi sửa prefix test, xem dưới).
- Family PointDefenseTurret **16/16 OK** trong 59.27s (4 module: power_status N2151 + target_acquire N2239 + aim_shoot N2240 + should_consume_cooling — worker log, sau khi sửa 2 scene dưới).
- Wiring-standard **32/32 OK** (9 module, 9/9 OK ngay lượt đầu — main thread, 133.36s).
- **Tổng 52/52 OK.** `git diff --check` sạch (kiểm tra lại trước commit).
- Godot proof headless Linux: scene `C07PointDefenseTurretShouldConsumeCoolantProof.tscn`, exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretShouldConsumeCoolantProof.json` (untracked, KHÔNG stage — file ignored): **8 semantic key / 11 trong JSON, matches:true** — 5 cooling (cooling_boosts_reload_counter, cooling_reports_coolant_consumed, cooling_skipped_when_coolant_efficiency_zero, cooling_skipped_when_reloaded, cooling_skipped_without_coolant) + 3 should-consume (should_consume_true_when_enabled_with_target, should_consume_false_when_disabled, should_consume_false_without_target) (proof ~03:13 +07, mtime JSON 20:13 UTC).
- Deferred pool: **281 → 282** (+1 nợ proof Windows N2241, không resolve entry nào).

## Harness fixes (main thread + worker, KHÔNG đụng gameplay/driver)

1. Test prefix (main thread): test :275 chờ `..._SHOULD_CONSUME_COOLING_PROOF` nhưng scene in `..._SHOULD_CONSUME_COOLANT_PROOF` (tên file/scene/prefix đều Coolant) → sửa test sang COOLANT_PROOF.
2. NEIGHBOUR REGRESSION (thật, driver đúng Java — xem `goal hidden_files/n2241-neighbour-regression.md`): family 14/16 trước khi sửa scene — N2151 power_status FAIL (efficiency_folds_power_min False) + N2240 aim_shoot FAIL (4 key shoot False). Gốc rễ: driver tính efficiency TRƯỚC khi retarget stamp target, nên tick đầu acquire có edelta = 0, không bắn — thứ tự này ĐÚNG Java (`Building.update()` gọi `updateConsumption()` :2274 TRƯỚC `updateTile()` :2277; BuildingComp.java:1947). Sửa 2 proof scene (worker 03:15, harness-only): AimShoot thêm 1 tick sau khi seed bullets (tick A acquire, tick B bắn); PowerStatus stamp target sống lên frame trước tick. Sau sửa: family 16/16.

## Gate toàn bộ (main thread, PID 5187, ~03:3x–03:54 +07)

- Ran **6057** trong 1098.601s, failures=**191**, skipped=5, errors=**0** — cả 191 đều là `AssertionError: unexpectedly None` (Godot-absent; đếm trực tiếp trong log: `unexpectedly None` = 191, `FAIL:` = 191, `ERROR:` = 0, KeyError = 0). Test reference N2241 nằm trong 191 (gate log Godot-absent như dự kiến). KHÔNG phải regression. Log `tools/mindustry_godot_transpiler/full-suite-n2241-gate.log` (untracked, KHÔNG stage).
- Đối chiếu footer: Ran 6053 → 6057 (+4 test N2241); failures 190 → 191 (+1 test reference của slice mới, Godot-absent); errors 0 → 0. Khớp đúng dự kiến trong handoff.
- VA CHẠM GATE: cron 03:30 launch gate trùng (python PID 5200) ghi cùng log với gate của main thread (PID 5187) — đã kill gate trùng lúc 20:37 UTC, chỉ giữ 5187. Đoạn progress-dot đầu log bị xen kẽ ~1 phút đầu của 2 gate, nhưng footer do 5187 ghi cuối nên sạch — đã xác minh bằng đếm trực tiếp, không chỉ đọc footer.
- origin/main không di chuyển trước khi push: local main đã ở bcfff708 == origin/main, không cần fast-forward.

## Môi trường

- Worker 03:00 timeout giữa GREEN (targeted 3/4 do lỗi prefix test, family 12/16 do chạy thiếu godot PATH, wiring chưa chạy); worker 03:15 sửa 2 scene + chạy targeted/family xong, wiring bị abort giữa chừng (log 457 byte, mới 2 module); main thread chạy lại wiring. Logs worker ở `tools/mindustry_godot_transpiler/n2240-*.log` (không phải hidden_files/ — lần sau tìm log bằng `find`) và goal hidden_files/n2241-*.log.
- VM khởi động lại ~03:00 +07 (uptime 1h lúc 04:00); javalang OK lúc launch gate, godot KHÔNG trên PATH (gate chạy từ main thread, PID 5187, ~03:3x–03:54).
- VM clock chạy UTC — file mtime ~20:1x UTC = ~03:1x +07.

## Hashes

- 5-commit xong: slice (this commit), docs (next commit), GOAL (next commit) — đang push lên origin main.
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: slice tiếp theo theo backlog — driver map live bullets → observed dicts wiring (lúc đó should_consume sống thật); suppression live + targets live list vẫn BLOCKED. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
