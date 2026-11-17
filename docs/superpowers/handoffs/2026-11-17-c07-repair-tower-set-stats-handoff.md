# Handoff — N2230 RepairTower setStats() (C07)

## Status: GREEN (2026-11-17 ~14:0x +07). Test + proof xanh, chưa gate, chưa push.

- Hashes: slice 64b06843, docs d0da254f, GOAL c6235f85.

## RED (2026-11-17 ~13:3x +07)

- RED: Ran 4, failures=2, errors=2 (KeyError 'N2230' ×2 — registration + exact-evidence), register --verify 14/14 exit 0, SSOT chưa đổi 11497/1679/1606/3003 (verified từ disk).
- 2 failures: `test_repair_tower_set_stats_state` (chưa có hàm `source_repair_tower_set_stats_state` trong `SourceRepairTowerBuildState.gd`) + `test_reference_graph_and_actual_c07_repair_tower_set_stats` (`AssertionError: unexpectedly None` — godot KHÔNG có trên PATH, `shutil.which('godot')` trả None; binary ở `~/workspace/godot-bin/godot`, giống các slice trước).
- javalang 0.13.0 + pytest 9.2.0 importable (kiểm đầu lần chạy, không cần cài lại). Port 7777 trống. `git diff --check` sạch. KHÔNG stage/commit/push gì ở lần này (đúng lệnh: không commit/push slice chưa đủ điều kiện).
- `range` làm tên tham số GDScript đã verify parse được: `--check-only` trên đúng signature đã pin, Godot 4.6.2 exit 0, không lỗi.
- Untracked noise trong worktree (có từ trước, KHÔNG phải của lần này, KHÔNG stage): `*.gd.uid`, gate logs `full-suite-*.log`, thư mục `hidden_files/` ở repo root (log N2218–N2220 từ 16/11).

## Scope (scope 13:15 + hiệu chỉnh RED)

- N2230 = `RepairTower.setStats()` (RepairTower.java:35-41) — 1 pure function, NO driver tick line (stat read / UI, không phải per-tick — tiền lệ N2224 RepairTurret setStats).
- Hàm: `source_repair_tower_set_stats_state(range: float, heal_amount: float, tilesize: float) -> Dictionary` trong `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`.
- Trả `{"stats": [{"stat": "range", "value": range_blocks, "unit": "blocks"}, {"stat": "repairSpeed", "value": repair_speed_per_second, "unit": "perSecond"}]}` với `range_blocks = range / tilesize`, `repair_speed_per_second = heal_amount * 60.0` (shape đã pin ở scope, mirror thứ tự `stats.add` của Java).
- Một result symbol duy nhất: `source_repair_tower_set_stats_state_result.stats`.

## Java pins

- `stats.add(Stat.range, range / tilesize, StatUnit.blocks);` (RepairTower.java:38)
- `stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);` (RepairTower.java:39)
- `super.setStats();` (:37) là Block-level stat work (N1696) — KHÔNG thuộc slice này (N2224 precedent).
- Class defaults (RepairTower.java:21, :24): `range = 80f`, `healAmount = 1f`.
- Catalog overrides (Blocks.java:6579-6580): `range = 100f`, `healAmount = 1.5f`.
- Giá trị kỳ vọng với catalog: range 100 / 8 = **12.5 blocks**, repairSpeed 1.5 * 60 = **90 /s**.
- `tilesize` 8 (Vars.java:135 — N2220 precedent).
- Hàm nhận `range` / `heal_amount` làm tham số — KHÔNG hardcode 100f / 1.5f trong hàm (class default vs catalog override phải test được qua tham số).

## RED decisions (đã chốt ở RED)

1. Return shape `{"stats": [...]}` theo scope (không dùng flat keys kiểu N2224): faithful với Java — một list các stat row theo đúng thứ tự `stats.add`.
2. Symbols +1 (không phải +5): scope estimate +5 copy từ N2224 (flat return 5 keys) là sai với shape này — slice chỉ trả một list `stats` nên chỉ có 1 result symbol. SSOT dự kiến sau GREEN: **11498/1680/1607/3005** (symbols +1, Done +1, contracts +1, schema +2).
3. KHÔNG driver tick line: test assert bằng grep có giới hạn — cắt body của `source_repair_tower_tick_buildings_state` (từ `static func ...` đến `static func` tiếp theo hoặc EOF) và assertNotIn tên hàm mới. GREEN đặt hàm mới ở đâu cũng được, miễn không gọi nó trong driver.
4. Proof key `no_driver_tick_line`: proof .gd đọc source của state script bằng FileAccess và grep body driver — kiểm runtime thật, KHÔNG hardcode true. Test pin 4 key: `range_in_blocks`, `repair_speed_per_second`, `class_defaults_via_params`, `no_driver_tick_line`.
5. DEFERRED carry từ N2229 qua import (không retype): filter bỏ đúng 2 entry lumped chứa cả `RepairTower` + `setStats` (entry 151 cũ + entry 280 của N2229), thay bằng 1 entry giữ lại deferral draw/drawSelect/drawPlace/range/warmup kèm line refs + 1 entry nợ proof Windows N2230. Pool giữ 281 entry; các entry setStats của family khác (UnitAssemblerModule, StackRouter, ImpactReactor, BuildTurret) và entry nợ proof Windows của RepairTurret N2224 còn nguyên (đã verify bằng import runtime).
6. KHÔNG shard change: `java_source` là RepairTower.java (không phải ConsumeLiquid.java như N2229) nên không cần `generated_owner: ''`.

## KHÔNG scope

- `draw()` body (RepairTower.java:94-114) / `drawSelect()` (:117-119) / `drawPlace()` (:43-48) / accessors `range()` / `warmup()` — ứng viên N2231+.
- Suppression live (`heal_suppressed` stamp + `healSuppressionTime` / `Time.time` plumbing; `Fx.regenSuppressParticle` spawn deferred) — N2228 deferred.
- `frame["targets"]` live list (list-returning `Units.nearby` query) — N2228 deferred.
- `timeScale != 1` (BuildingComp.java:98, default 1f) — deferred chung.

## Proof math pinned (4 semantic keys)

1. `range_in_blocks` — range 100f / tilesize 8 = 12.5 blocks.
2. `repair_speed_per_second` — healAmount 1.5f * 60 = 90 /s.
3. `class_defaults_via_params` — range 80f / healAmount 1f qua tham số → 10 blocks / 60 perSecond (chứng minh hàm không hardcode catalog).
4. `no_driver_tick_line` — proof đọc source, grep body driver: không có dòng gọi hàm mới trong `source_repair_tower_tick_buildings_state`.

## Files theo mẫu N2224/N2229 (RED đã viết 2 file, GREEN viết tiếp)

- test `tools/mindustry_godot_transpiler/tests/test_c07_repair_tower_set_stats.py` (4 tests) — RED DONE.
- register `tools/mindustry_godot_transpiler/register_c07_repair_tower_set_stats.py` (CÓ --verify, 14/14) — RED DONE, CHƯA chạy main() (chưa chạm SSOT JSON).
- proof `godot-mindustry/tools/runtime_proofs/C07RepairTowerSetStatsProof.gd` + `.tscn` (JSON qua RuntimeProofState.write_proof, không stdout) — GREEN viết.
- RED log: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2230-red.log` (Ran 4, failures=2, errors=2).
- Scope: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2230-scope.md`.

## SSOT trước RED

- 11497/1679/1606/3003 (verified từ disk; N2229 done). N2230 CHƯA có trong ledger. Dự kiến GREEN delta: symbols +1, Done +1, contracts +1, schema +2 → **11498/1680/1607/3005**. KHÔNG đổi shard (verify từ `git status` ở GREEN).

## GREEN (2026-11-17 ~14:0x +07, verified từ log)

- Hàm `source_repair_tower_set_stats_state(range, heal_amount, tilesize)` trong `SourceRepairTowerBuildState.gd` (ngay trước driver, sau heal_advance): `range_blocks = range / tilesize`, `repair_speed_per_second = heal_amount * 60.0`, trả `{"stats": [...]}` 2 row đúng thứ tự Java; comment trích đủ 10 EXACT_EXPRS. KHÔNG driver tick line.
- Proof `C07RepairTowerSetStatsProof.gd` + `.tscn` (mới): 4 key đã pin; `no_driver_tick_line` đọc source bằng FileAccess và grep body driver — kiểm runtime thật, KHÔNG hardcode true.
- Register --verify 14/14; main() exit 0. SSOT từ disk: **11498/1680/1607/3005** — đúng delta dự kiến (symbols +1, Done +1, contracts +1, schema +2). N2230 trong ledger, status done. KHÔNG đổi shard (`git diff --stat`: 5 file, +427 — state script + 4 SSOT canonical).
- Targeted **4/4 OK** trong 16.79s (30 subtests), gồm proof test headless.
- Family RepairTower **28/28 OK** trong 103.57s (24 cũ + 4 mới; log `hidden_files/n2230-family.log`).
- Wiring-standard **32/32 OK** trong 136.70s (9 module; log `hidden_files/n2230-wiring.log`).
- **Tổng 64/64 OK.** `git diff --check` sạch.
- Godot proof headless Linux: scene `C07RepairTowerSetStatsProof.tscn`, exit 0, 0 ERROR, port 7777 trống trước proof. JSON `godot-mindustry/tools/runtime_proofs/C07RepairTowerSetStatsProof.json` (untracked, KHÔNG stage): **4 semantic key / 7 trong JSON, matches:true** — range_in_blocks 12.5, repair_speed_per_second 90, class_defaults_via_params 10 blocks / 60 perSecond, no_driver_tick_line true.
- javalang 0.13.0 + pytest 9.2.0 importable (kiểm đầu lần chạy, không cần cài lại). Godot chạy qua `PATH="$HOME/workspace/godot-bin:$PATH"` (binary `~/workspace/godot-bin/godot`, KHÔNG có trên PATH mặc định — tiền lệ N2224).
- Không stage/commit/push gì ở lần này (chưa đủ điều kiện: gate chưa chạy).

## Còn lại (main thread)

- Full gate từ main thread (gate chạy từ worker sẽ chết theo session — tiền lệ N2229; dự kiến Ran ~6013, failures ~180 Godot-absent, skipped=5, 0 errors), rồi 5-commit pattern + push theo quy trình (spec Done 1679 → 1680 + row N2230; GOAL.md §5 dòng nợ Windows cho N2230 ghi đúng hash slice commit; proof chưa chạy trên Windows Godot — nợ như N2212-N2229).
- Sau N2230: RepairTower còn draw()/drawSelect()/drawPlace() + suppression live + targets live list (N2231+), hoặc family tiếp theo theo backlog. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)

## Checklist lần chạy sau (GREEN)

- javalang importable (kiểm đầu lần chạy; VM restart xóa pip hệ thống — cài lại nếu cần).
- Viết hàm + comment Java exprs (10 exprs trong EXACT_EXPRS phải có mặt trong `SourceRepairTowerBuildState.gd` — test assertIn).
- Viết proof .gd + .tscn với 4 key đã pin; `no_driver_tick_line` grep body driver bằng FileAccess.
- Chạy targeted 4/4 → family RepairTower → wiring 32/32 → register main() → kiểm SSOT 11498/1680/1607/3005 → gate toàn bộ (main thread) → push khi đủ điều kiện.
- Port 7777 trống trước proof; không chạy proof scene song song với agent Godot khác.
- `git diff --check` sạch; KHÔNG stage `*.gd.uid` / proof `.json` / gate logs / `hidden_files/` ở repo root.
- Không commit/push khi chưa đủ điều kiện (test + proof + gate xanh).
