# Handoff — N2237 RepairTurret per-def stat rows verification (C07)

## Status: GREEN (gate running, relaunched PID 2078 after restart #35 killed PID 15308). Test + proof xanh, wiring xanh ngay lượt đầu. SSOT 11537/1687/1618/3027. Targeted 4/4, family RepairTurret 88/88, wiring 32/32 = 124/124; proof 5 semantic keys / 8 in JSON matches:true. Gate log `tools/mindustry_godot_transpiler/full-suite-n2237-gate.log`.

## Slice

N2237 = RepairTurret per-def stat rows verification — 1 pure function `source_repair_turret_per_def_stats_state(block_id)` trong `godot-mindustry/src/game/SourceRepairTurretBuildState.gd`, trả 5 keys `repair_speed` / `repair_radius` / `length` / `beam_width` / `pulse_radius`. Đóng đúng deferred entry "RepairTurret per-def stat rows (repairSpeed 0.45f/3f, repairRadius 60f/145f, length 5f/6f, beamWidth 0.73f/1.1f, pulseRadius 5f/6.1f, Blocks.java:6386-6406) -- static defs, wait for their own verification slice."

- KHÔNG có driver tick line (static read, tiền lệ N2233 range() / N2235 ambient volume).
- Hàm tái dùng 4 helper per-def đã có (`_repair_speed_for_block_id`, `_repair_radius_for_block_id`, `_beam_length_for_block_id`, `_beam_width_for_block_id`) + 1 helper mới `_pulse_radius_for_block_id` — không duplicate hằng số (quy tắc prefer existing names).

## Java evidence (xác minh bằng grep -n trên disk)

- Class defaults (RepairTurret.java): `public float repairRadius = 50f;` (:32), `public float repairSpeed = 0.3f;` (:33), `public float length = 5f;` (:35), `public float beamWidth = 1f;` (:36), `public float pulseRadius = 6f;` (:37).
- repair-point (Blocks.java:6386-6395): `repairSpeed = 0.45f;` (:6388), `repairRadius = 60f;` (:6389), `beamWidth = 0.73f;` (:6390), `pulseRadius = 5f;` (:6392); KHÔNG override length → 5f class default.
- repair-turret (Blocks.java:6397-6409): `length = 6f;` (:6399), `repairSpeed = 3f;` (:6400), `repairRadius = 145f;` (:6401), `beamWidth = 1.1f;` (:6403), `pulseRadius = 6.1f;` (:6404).
- powerUse (1f/5f) KHÔNG nằm trong slice này — đã có trong catalog consumePower/consumePowerCond; ambientSoundVolume đã xong N2235; coolantUse/coolantMultiplier là consumer row riêng, vẫn deferred.

## Kiểm tra ưu tiên 1 (suppression live + targets live list): VẪN BLOCKED

Kiểm lại từ disk ở lần này: không có `frame["units"] =` nào trong `godot-mindustry/src/game/*.gd`; không frame nào stamp `heal_suppressed` / `heal_suppression_time`. KHÔNG scope lại. Cả hai họ RepairTower + RepairTurret đã slice xong mọi method của RepairTower.java / RepairTurret.java, trừ các mục deferred còn lại: drawBeam jitter/pulse (cần model arc Rand — quá lớn cho một slice), display() (UI Table work, không phải pure state read), coolant optional consumer row (cần liquid-stock observation chưa có), ambient-sound live-loop driver call (cần game-level sink), suppression live (BLOCKED trên).

## Đăng ký SSOT (tiền lệ N2233/N2235: chỉ result symbols vào symbols dict)

- 1 input symbol (`block_id`, schema input) + 5 result symbols (`repair_speed`, `repair_radius`, `length`, `beam_width`, `pulse_radius`), 1 contract, 2 schema (input+result), 1 ledger row.
- java_method ledger: `RepairPointBuild` per-def stat rows (không có một Java method đơn — các giá trị là field overrides trong Blocks.java init blocks + class defaults RepairTurret.java); slice sources: RepairTurret.java + Blocks.java.
- Delta: symbols +5, ledger +1, contracts +1, schema +2 → **11537/1687/1618/3027**. NO shard change (RepairTurret.java không match shard nào — tiền lệ N2213-N2236).
- Deferred pool: 279 → **279** (resolve entry "RepairTurret per-def stat rows" bằng filter substring chính xác 'RepairTurret per-def stat rows' — KHÔNG chạm entry "RepairTower per-def stat rows"; +1 nợ proof Windows N2237 theo mẫu N2235).

## RED / GREEN / Proof

- RED 4 failed (classic, Ran 4 in 11.750s, failures=2, errors=2; KeyError 'N2237' ×1 trong log).
- Register --verify **23/23 exprs present** (script implements --verify, đã kiểm tra trước).
- GREEN targeted **4/4** (16.865s, main-thread re-run; worker log 15.708s), family RepairTurret **88/88** (22 module, pytest 312.78s, 1002 subtests — main thread chạy lại vì log family của worker 0 byte do timeout), wiring **32/32** (9/9 OK ngay lượt đầu, main thread) = **124/124**.
- Proof `C07RepairTurretPerDefStatsProof`: **5 semantic keys / 8 in JSON matches:true** (keys: stats_repair_point, stats_repair_turret, stats_class_default, stats_empty_defaults, has_no_driver_tick_line).
- `git diff --check` CLEAN (main thread).

## Gate

Launched sạch từ main thread (PID 2078, ~22:32–22:50, relaunched sau khi restart #35 kill PID 15308 ở ~60% tiến độ; log `tools/mindustry_godot_transpiler/full-suite-n2237-gate.log`, godot KHÔNG trên PATH, javalang 0.13.0 OK sau cài lại, không gate lạc, port trống). Footer DONE ~22:50: Ran 6041 in 1090.003s, failures=187, skipped=5, 0 errors — toàn bộ 187 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng `ERROR:`, 187 traceback = đúng 187 failure. LƯU Ý GUARD: lần thử launch đầu với guard `ps | grep -q '[u]nittest discover'` trong CÙNG chuỗi lệnh đã tự abort giả — shell của chính lệnh đó chứa text "unittest discover" (phần launch) nên guard tự match chính mình; KHÔNG có gate lạc nào thật (log file chưa tồn tại, ps sạch). Guard phải chạy ở exec RIÊNG, không chung chuỗi với lệnh launch.

## Môi trường

- Worker cron 22:00 TIMED OUT sau 900s giữa family (log family 0 byte) — main thread chạy lại family + wiring + viết handoff.
- VM restart #34 vẫn là restart gần nhất (javalang + pytest còn nguyên sau lần cài lại ở 20:45).

## Commits

- Slice: (this commit)
- Docs: (next commit)
- GOAL: (next commit)

## Next

Report + spec row (Done 1686 → 1687 + dòng N2237) + GOAL §5 debt line cho N2237 (nêu slice commit) + 5-commit + push sau footer gate. Sau N2237: suppression live + targets live list vẫn BLOCKED, hoặc họ tiếp theo theo backlog.
