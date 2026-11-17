# Handoff — N2232 RepairTower draw() + range() + warmup() (C07)

## Status: DONE + PUSHED (2026-11-17 ~17:2x +07; slice b570908e, main f8b1a81e). Test + proof + gate xanh. SSOT 11522/1682/1612/3015. Targeted 4/4, family RepairTower 36/36, wiring 32/32 = 72/72; proof 12 semantic keys / 15 in JSON matches:true. Gate Ran 6021, failures=182, skipped=5, 0 errors — toàn bộ Godot-absent. Windows Godot proof là nợ trong GOAL.md §5.

## Scope (chốt 2026-11-17 ~16:2x +07, file goals/hidden_files/n2232-scope.md)

**N2232 = `RepairTowerBuild.draw()` + `range()` + `warmup()` — GỘP trong một slice**, 3 pure function trong `SourceRepairTowerBuildState.gd`, **CÓ 1 driver tick line** (chỉ cho draw; 2 accessor là pure read, không tick line).

- `draw()` — RepairTower.java:94-109. Dòng sở hữu: `:97` gate, `:99-103` vòng tròn, `:104-105` hình vuông, `:108` glow additive (`:95 super.draw();` là Block-level, ngoài scope).
- `range()` — RepairTower.java:111-114 (`@Override` :111, `return range;` :113; Ranged interface, Ranged.java:5-6).
- `warmup()` — RepairTower.java:116-119 (`@Override` :116, `return warmup;` :118; override base BuildingComp.java:608-609 trả 0f).

Lý do gộp: `warmup()` là gate input của chính `draw()` (:97); `range()` là param per-def mà `draw()` cần (:103); cả hai chỉ là 1 dòng return — tách riêng mỏng hơn cả N2226 `init()` đã deferred. Tiền lệ gộp: N2231 (2 method), N2229 (2 function).

## Java evidence

- Class defaults (RepairTower.java:21-23): `range = 80f`; `circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f)`; `circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f`. Catalog Blocks.java:6575-6583 chỉ override `size = 2`, `range = 100f`, `healAmount = 1.5f`.
- `glow` region `@Load("@-glow")` (:25) → `unit-repair-tower-glow`. `Pal.heal = Color.valueOf("98ffa9")` (Pal.java:77). `Layer.effect = 110` (Layer.java:75), `Layer.blockAdditive = 31` (Layer.java:36).
- `Mathf.absin(in, scl, mag) = (sin(in, scl*2f, mag) + mag) / 2f` (Mathf.java:78-80) → `absin(t, 8, 0.5) = 0.25 * sin(t / 16) + 0.25`.
- `totalProgress` là FIELD của build (:53), khác method base trả `Time.time` — draw dùng FIELD, frame key `total_progress` đã stamp bởi N2228. `warmup` field :52, stamp bởi driver N2228.

## Implementation

- `source_repair_tower_draw_state(frame, x, y, range, time, circle_stroke, square_rad, square_spin_scl, glow_mag, glow_scl, glow_region)` (:174) → Dictionary 16 key, công thức inline, comment chứa đủ 32 EXACT_EXPRS. Gate `:97` thành key `visible` (không early return trong pure function — tiền lệ MendProjector draw_state); giá trị ở warmup ~= 0 rơi về ~= 0 qua công thức.
- `source_repair_tower_range_state(range)` (:182) → `{"range": range}`.
- `source_repair_tower_warmup_state(frame)` (:186) → `{"warmup": float(frame.get("warmup", 0.0))}`.
- Driver tick line (:265, trong `source_repair_tower_tick_buildings_state`, nhánh powered, sau heal advance N2228): `frame["game_time"]` tích lũy per-building + gọi draw state, stamp 16 key `draw_*`.
- `Time.time` là param `time` explicit (tiền lệ MendProjector draw_state — không frame key nào mang global time). **Phase deviation đã document trong code, không workaround**: per-building clock bắt đầu 0.0 ở tick đầu sau placement, khác Java global Time.time — tốc độ và chu kỳ chính xác, render ngoài gameplay theo ranh giới user; nếu port có global clock thì driver đổi time source, pure function không đổi.
- **Absin deviation đã document trong code, không workaround**: glow alpha dùng port helper `SourceMathState.source_absin(time, glow_scl, glow_mag)` với scl gốc (tiền lệ MendProjector/ThermalGenerator); công thức arc lệch hệ số chu kỳ 2x — sửa helper là việc của math slice riêng, không nhân `*2.0` ở đây. Proof key `draw_glow_alpha_nonzero_time_pins_port_formula` pin công thức port.

## RED (2026-11-17 ~16:3x +07)

- Targeted pytest: **4 failed in 2.82s** — classic RED (registration + input-evidence KeyError 'N2232', reference-graph, draw-state missing function). Register --verify **63/63 exprs present, exit 0**. Deferred pool 282 → 282 (drop 1 entry draw-family gộp, add 1 entry Windows-proof debt). SSOT chưa đổi lúc RED.

## GREEN (2026-11-17 ~16:4x +07, worker cron timeout ~16:45 trước khi viết handoff — main thread verify + viết handoff này)

- Targeted: **4 passed, 140 subtests, 15.50s** (worker) — main-thread re-run: **Ran 4 tests in 13.766s, OK**.
- Family RepairTower (9 module): **36 passed, 530 subtests, 123.05s** — đúng kỳ vọng 36/36 (32 cũ + 4 mới).
- Wiring (chuẩn 9 module / 32 test): **32/32**. Ghi chú flake: lượt chạy đầu của main thread 3 module FAILED, lượt chạy lại per-module 4 module FAILED — cả hai lượt đều fail CHỈ ở assert `ERROR:` với cùng lỗi `ERROR: [MCP Runtime] Failed to start server on port 7777: 22` (Godot của agent khác giữ port trong ~2 phút đầu), proof đều `matches:true`, key semantic đều true. Chạy lại cô lập 4 module sau khi port trống: **OK cả 4**. Đây là flake môi trường đã biết (tiền lệ N2200/N2212/N2216), KHÔNG phải regression của N2232.
- Proof Godot headless Linux: **12/12 key true + matches:true** (12 semantic / 15 trong JSON): draw_hidden_at_warmup_gate, draw_visible_above_gate, draw_mod_wraps, draw_circle_stroke_scales, draw_circle_radius_catalog_100, draw_square_half_size_and_rotation, draw_glow_alpha_at_time_zero, draw_glow_alpha_nonzero_time_pins_port_formula, draw_layers, draw_range_accessor, draw_warmup_accessor_reads_frame, has_driver_tick_line.
- `git diff --check` CLEAN (main thread).
- SSOT (verify từ disk): **11522/1682/1612/3015** — symbols +18, ledger +1, contracts +3, schema +6 so với N2231 (11504/1681/1609/3009). N2232 status done, 18 source symbols. **NO shard change** (5 file sửa: family .gd + 4 canonical SSOT; 4 file mới untracked: test, register, proof .gd/.tscn).

## Files

- Slice: `godot-mindustry/src/game/SourceRepairTowerBuildState.gd` (3 hàm + driver line), `godot-mindustry/src/generated/source_{symbol_registry,slice_ledger,api_contracts,state_schema}.json`, `tools/mindustry_godot_transpiler/tests/test_c07_repair_tower_draw.py`, `tools/mindustry_godot_transpiler/register_c07_repair_tower_draw.py`, `godot-mindustry/tools/runtime_proofs/C07RepairTowerDrawProof.gd` + `.tscn`.
- KHÔNG stage: proof `.json`, `*.gd.uid`, gate/working log.
- Logs: goals `hidden_files/n2232-red.log`, `n2232-green.log`, `n2232-wiring-*.log` (+ `*-rerun.log` cho 4 module flake), scope `n2232-scope.md`.

## Gate (2026-11-17 ~16:53–17:11 +07, main thread, PID 4704)

- Ran **6021** trong 1048.301s, failures=**182**, skipped=5, 0 errors — toàn bộ 182 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng ERROR. Đúng dự kiến (Ran ~6021, failures ~182). Log `tools/mindustry_godot_transpiler/full-suite-n2232-gate.log` (untracked, KHÔNG stage).

## Next

1. ~~Full gate từ main thread (đang chạy) → dự kiến Ran ~6021, failures ~182, skipped 5, 0 errors (toàn Godot-absent).~~ Xong ~17:11, đúng dự kiến.
2. Sau footer: report + design spec (Done 1681 → 1682 + dòng N2232) + GOAL §5 debt line N2232 + 5-commit + push (fetch + fast-forward origin/main trước — validation merge đáp xuống thường xuyên).
3. Tiếp theo: suppression live stamping + targets live list (vẫn BLOCKED — cần quan sát liquid-stock/heal-suppression frame plumbing), hoặc họ tiếp theo theo backlog.

## Commits

- Slice: b570908e
- Docs: b3d7a5e1
- GOAL: 0b5813c2
