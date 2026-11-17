# Handoff — N2231 RepairTower drawSelect() + drawPlace() (C07)

## Status: GREEN (2026-11-17 ~15:3x +07, main-thread verified). Test + proof xanh, gate xong ~15:51 (Ran 6017, failures=181, skipped=5, 0 errors — toàn bộ Godot-absent), chưa push. SSOT 11504/1681/1609/3009. Targeted 4/4 OK (16.628s, main-thread re-run), family RepairTower 32/32, wiring 32/32 = 68/68; proof 9 semantic keys / 12 in JSON matches:true. Gate log tools/mindustry_godot_transpiler/full-suite-n2231-gate.log (main thread, PID 10237, ~15:33).

- Scope: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2231-scope.md` (viết ~14:5x, verify lại ở RED từ Java + disk).
- RED log: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2231-red.log` (4 failed).

## RED (2026-11-17 ~15:1x +07)

- RED: 4 failed trong 3.32s (chạy lại --tb=no: 4 failed trong 0.60s): KeyError 'N2231' ×2 (registration + exact-evidence), AssertionError thiếu hàm `source_repair_tower_draw_select_state` (state test), AssertionError 1 != 0 — Godot không load được scene proof `C07RepairTowerDrawSelectPlaceProof.tscn` (chưa viết). Register --verify 24/24 exit 0. SSOT chưa đổi 11498/1680/1607/3005, N2231 chưa có trong ledger.
- DEFERRED pool carry qua import từ register N2230: 281 → 282, drop đúng 1 entry lumped (draw/drawSelect/drawPlace/range/warmup), thay bằng 2 entry mới (draw()/range()/warmup() deferred + nợ proof Windows N2231).
- Môi trường: VM restart xóa pip hệ thống — javalang + pytest KHÔNG importable đầu lần chạy, đã cài lại (javalang 0.13.0, pytest 9.2.0). Port 7777 trống. Godot chạy qua `PATH="$HOME/workspace/godot-bin:$PATH"`.
- `git diff --check` sạch. KHÔNG stage/commit/push gì ở lần này (đúng lệnh: không commit/push slice chưa đủ điều kiện).

## Scope (chốt ~14:5x, verify ở RED)

- N2231 = `RepairTower.drawSelect()` + `RepairTower.drawPlace()` — 2 pure function, NO driver tick line (UI placement/selection, không phải per-tick — tiền lệ N2220).
- `drawPlace(int x, int y, int rotation, boolean valid)` — RepairTower.java:44-48. Dòng sở hữu duy nhất: `:47` `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);` (`super.drawPlace(...)` :45 là Block-level, ngoài scope — tiền lệ N2220.)
- `drawSelect()` — RepairTower.java:122-124. Dòng sở hữu duy nhất: `:123` `Drawf.dashCircle(x, y, range, Pal.placing);`
- `range`: class default `80f` (:21); catalog unit-repair-tower `100f` (Blocks.java:6579). `size = 2` (Blocks.java:6578).
- `tilesize` 8 (Vars.java:135). `offset` cho size 2: `((size + 1) % 2) * tilesize / 2f` (Block.java:761) = **4.0**.
- Cả 2 call site dùng màu `Pal.placing` (khác RepairTurret dùng `Pal.accent`).

## Function đã pin (GREEN viết)

Trong `godot-mindustry/src/game/SourceRepairTowerBuildState.gd`:

1. `source_repair_tower_draw_select_state(x: float, y: float, range: float) -> Dictionary`
   → `{"center": Vector2(x, y), "radius": range, "color": "Pal.placing"}`
2. `source_repair_tower_draw_place_state(tile_x: int, tile_y: int, range: float, tilesize: float, block_offset: float) -> Dictionary`
   → `{"center": Vector2(tile_x * tilesize + block_offset, tile_y * tilesize + block_offset), "radius": range, "color": "Pal.placing"}`

- Frame keys in/out: **không có** — pure UI geometry, không đọc frame.
- Driver tick line: **KHÔNG** (test assert grep body `tick_buildings` như N2230).
- Params per-def, không hardcode: `range` 100f catalog / 80f class default qua tham số; `block_offset` 4.0 qua tham số (single def, không cần helper như turret).
- Comment trong hàm phải chứa đủ 10 EXACT_EXPRS (test assertIn) — gồm `range / tilesize` (RepairTower.java:38, setStats) và `range = 100f;` / `public static final int tilesize = 8;`.
- Proof keys đã pin (9 key): `select_center_at_building_position`, `select_radius_catalog_100`, `select_radius_class_default_80`, `select_color_is_placing`, `place_center_converts_tile_to_world`, `place_center_applies_block_offset`, `place_radius_catalog_100`, `place_color_is_placing`, `no_driver_tick_line` (proof đọc source, grep body driver — kiểm runtime thật, KHÔNG hardcode true).
- SSOT delta dự kiến (verify lại ở GREEN bằng register main(), đừng pin cứng): symbols +6, Done +1, contracts +2, schema +4 → **11504/1681/1609/3009**. KHÔNG đổi shard.

## KHÔNG scope (để slice sau)

- `draw()` body (:94-110) — ứng viên N2232: warmup gate `<= 0.001f`, `mod = totalProgress % 1f`, `Lines.stroke/circle`, `Fill.square` với `Time.time / squareSpinScl`, `Drawf.additive` glow — cần plumbing `Time.time` + glow region.
- Accessors `range()` (:112-114) / `warmup()` (:117-119) — 1 dòng return mỗi cái; gợi ý gộp với N2232 `draw()` (warmup là gate input của draw) hoặc một slice accessor riêng.
- Suppression live (`heal_suppressed` stamp + `checkSuppression()` plumbing) — vẫn BLOCKED, chưa có frame nào stamp suppression; deferred từ N2228.
- `frame["targets"]` live list — vẫn BLOCKED, `frame["units"]` chưa bao giờ được stamp; deferred từ N2228.
- `super.drawPlace()` / `super.draw()` (vẽ block base) — Block-level, ngoài scope.

## Files theo mẫu N2220/N2230 (RED đã viết 2 file, GREEN viết tiếp)

- test `tools/mindustry_godot_transpiler/tests/test_c07_repair_tower_draw_select_place.py` (4 tests) — RED DONE.
- register `tools/mindustry_godot_transpiler/register_c07_repair_tower_draw_select_place.py` (CÓ --verify, 24/24) — RED DONE, CHƯA chạy main() (chưa chạm SSOT JSON).
- proof `godot-mindustry/tools/runtime_proofs/C07RepairTowerDrawSelectPlaceProof.gd` + `.tscn` (JSON qua RuntimeProofState.write_proof, không stdout) — GREEN viết.
- RED log: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2231-red.log` (4 failed).
- Scope: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2231-scope.md`.

## SSOT trước RED

- 11498/1680/1607/3005 (verified từ disk; N2230 done). N2231 CHƯA có trong ledger. Dự kiến GREEN delta: symbols +6, Done +1, contracts +2, schema +4 → **11504/1681/1609/3009**. KHÔNG đổi shard.

## Checklist lần chạy sau (GREEN)

- javalang importable (kiểm đầu lần chạy; VM restart xóa pip hệ thống — cài lại nếu cần).
- Viết 2 hàm + comment Java exprs (10 exprs trong EXACT_EXPRS phải có mặt trong `SourceRepairTowerBuildState.gd` — test assertIn).
- Viết proof .gd + .tscn với 9 key đã pin; `no_driver_tick_line` grep body driver bằng FileAccess.
- Chạy targeted 4/4 → family RepairTower → wiring 32/32 → register main() → kiểm SSOT 11504/1681/1609/3009 → gate toàn bộ (main thread) → push khi đủ điều kiện.
- Port 7777 trống trước proof; không chạy proof scene song song với agent Godot khác.
- `git diff --check` sạch; KHÔNG stage `*.gd.uid` / proof `.json` / gate logs / `hidden_files/` ở repo root.
- Không commit/push khi chưa đủ điều kiện (test + proof + gate xanh).
