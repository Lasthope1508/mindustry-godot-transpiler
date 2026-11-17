# Báo cáo — N2237 RepairTurret per-def stat rows verification (C07)

Ngày: 2026-11-17 ~22:0x–22:5x +07. Slice trước N2236 DONE + PUSHED (main 14d923f7, SSOT 11532/1686/1617/3025 — đã xác minh lại từ disk).

## Kết luận scoping

N2237 làm được, không còn blocker. Đóng đúng deferred entry "RepairTurret per-def stat rows (repairSpeed 0.45f/3f, repairRadius 60f/145f, length 5f/6f, beamWidth 0.73f/1.1f, pulseRadius 5f/6.1f, Blocks.java:6386-6406)". 1 hàm pure mới, KHÔNG có driver tick line (static read, tiền lệ N2233 range() / N2235 ambient volume). powerUse (1f/5f) KHÔNG nằm trong slice này — đã có trong catalog consumePower/consumePowerCond; ambientSoundVolume đã xong N2235; coolantUse/coolantMultiplier là consumer row riêng, vẫn deferred.

## Java đã pin (đọc từ disk)

- Class defaults (RepairTurret.java): `repairRadius = 50f;` (:32), `repairSpeed = 0.3f;` (:33), `length = 5f;` (:35), `beamWidth = 1f;` (:36), `pulseRadius = 6f;` (:37).
- repair-point (Blocks.java:6386-6395): `repairSpeed = 0.45f;` (:6388), `repairRadius = 60f;` (:6389), `beamWidth = 0.73f;` (:6390), `pulseRadius = 5f;` (:6392); KHÔNG override length → 5f class default.
- repair-turret (Blocks.java:6397-6409): `length = 6f;` (:6399), `repairSpeed = 3f;` (:6400), `repairRadius = 145f;` (:6401), `beamWidth = 1.1f;` (:6403), `pulseRadius = 6.1f;` (:6404).

## RED (2026-11-17 ~22:0x +07)

- RED 4 failed (classic, Ran 4 in 11.750s, failures=2, errors=2; KeyError 'N2237' ×1 trong log).
- Register --verify 23/23 exit 0.

## GREEN (2026-11-17 ~22:0x–22:3x +07)

- 1 hàm pure mới trong `SourceRepairTurretBuildState.gd`:
  - `source_repair_turret_per_def_stats_state(block_id)` trả 5 keys `repair_speed` / `repair_radius` / `length` / `beam_width` / `pulse_radius`.
  - Tái dùng 4 helper per-def đã có (`_repair_speed_for_block_id`, `_repair_radius_for_block_id`, `_beam_length_for_block_id`, `_beam_width_for_block_id`) + 1 helper mới `_pulse_radius_for_block_id` — không duplicate hằng số.
  - KHÔNG có driver tick line (static read).
- Proof `C07RepairTurretPerDefStatsProof.gd` + `.tscn` (mới): 5 key semantic đã pin.
- Register --verify 23/23; main() exit 0. SSOT từ disk: **11537/1687/1618/3027** — đúng delta dự kiến (symbols +5, Done +1, contracts +1, schema +2). N2237 trong ledger, status done. Audit stays 1335. KHÔNG đổi shard.
- Targeted **4/4 OK** (main-thread re-run: Ran 4 tests in 16.865s, OK).
- Family RepairTurret **88/88 OK** trong 312.78s (22 module, 1002 subtests — main thread chạy lại vì log family của worker 0 byte do timeout).
- Wiring-standard **32/32 OK** (9 module, 9/9 OK ngay lượt đầu, không flake).
- **Tổng 124/124 OK.** `git diff --check` sạch.
- Godot proof headless Linux: scene `C07RepairTurretPerDefStatsProof.tscn`, exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07RepairTurretPerDefStatsProof.json` (untracked, KHÔNG stage): **5 semantic key / 8 trong JSON, matches:true** — stats_repair_point, stats_repair_turret, stats_class_default, stats_empty_defaults, has_no_driver_tick_line.
- Deferred pool: **279 → 279** (resolve entry "RepairTurret per-def stat rows" bằng filter substring chính xác — KHÔNG chạm entry "RepairTower per-def stat rows"; +1 nợ proof Windows N2237 theo mẫu N2235).

## Gate toàn bộ (main thread, PID 2078, ~22:32–22:50 +07)

- Ran **6041** trong 1090.003s, failures=**187**, skipped=5, 0 errors — toàn bộ 187 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng `ERROR:`, 187 traceback = đúng 187 failure. Xong ~22:50 +07. Log `tools/mindustry_godot_transpiler/full-suite-n2237-gate.log` (untracked, KHÔNG stage).
- Gate này là lần relaunch: VM restart #35 (~22:28) kill gate đầu (PID 15308) ở ~60% tiến độ (log 3837 bytes, 3667 dots, 165 F, 0 E, không footer) và xóa javalang + pytest — main thread cài lại javalang 0.13.0 (requirements.txt) + pytest 9.2.0 (riêng; requirements.txt KHÔNG chứa pytest) rồi relaunch PID 2078 sau khi verify ps sạch ở exec riêng.
- LƯU Ý GUARD (mẫu N2233/N2236): lần thử launch đầu với guard `ps | grep -q '[u]nittest discover'` trong CÙNG chuỗi lệnh đã tự abort giả — shell của chính lệnh đó chứa text "unittest discover" nên guard tự match chính mình; KHÔNG có gate lạc nào thật (log file chưa tồn tại, ps sạch). Guard phải chạy ở exec RIÊNG, không chung chuỗi với lệnh launch.
- origin/main không di chuyển trước khi push: local main đã ở 14d923f7 == origin/main, không cần fast-forward.

## Môi trường

- Worker cron 22:00 TIMED OUT sau 900s giữa family (log family 0 byte) — main thread chạy lại family + wiring + viết handoff.
- VM clock chạy UTC — file mtime ~15:0x UTC = ~22:0x +07.

## Hashes

- 5-commit xong: slice (hash), docs (hash), GOAL (hash) — đang push lên origin main.
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: suppression live + targets live list (vẫn BLOCKED), hoặc họ tiếp theo theo backlog. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
