# Báo cáo scoping — N2229 RepairTower ozone consumer (C07)

Ngày: 2026-11-17 ~11:3x +07. Slice trước N2228 DONE + PUSHED (main 0aaea22c, SSOT 11493/1678/1604/2999 — đã xác minh lại từ disk).

## Kết luận scoping

N2229 làm được, không còn blocker. Câu hỏi mở từ N2228 — "liquid-stock observation chưa frame nào mang" — đã có đáp án từ tiền lệ N2187 (ImpactReactor cryofluid): frame mang dict `frame["liquids"]` (mặc định `{}`), hàm drain đọc `liquids.get("cryofluid", 0.0)` và clamp theo stock. N2229 dùng đúng mẫu đó cho ozone, cộng thêm phần N2187 chưa làm: **fold** `ConsumeLiquid.efficiency` vào first pass.

## Java đã pin (đọc từ disk)

- `consumeLiquid(Liquids.ozone, 3f / 60f)` (Blocks.java:6583); catalog: `consumeLiquid: [{"amount": 0.05, "liquid": "ozone"}]`.
- Fold (ConsumeLiquid.java:42-48): `ed = edelta() * efficiencyScale()`; `ed <= 1e-8` → 0; `min(stock / (amount * ed * multiplier), 1)`. Ở first pass efficiency được assume 1.0 (BuildingComp.java:1966-1967), `efficiencyScale()` mặc định 1f, multiplier mặc định 1f (Consume.java:18) → fold = `min(stock / (0.05 * delta * time_scale), 1.0)`.
- Drain (ConsumeLiquid.java:37-38): `remove(ozone, 0.05 * edelta * 1)` với edelta = efficiency đã fold × delta; clamp theo stock (LiquidModule.java:124-127). Chỉ chạy khi `update && efficiency > 0` (BuildingComp.java:1997-2000).
- Row ozone ≤ 1e-7 (không phải power) → `should_consume_power = false` (BuildingComp.java:1972-1974; port: `update_consumption_non_optional_pass_state`).

## Quyết định RED quan trọng

Absent ≠ zero (tiền lệ N2191 shouldConsume, N2174 coolant): row chỉ fold khi `frame["liquids"]` có key `"ozone"`; không có key thì giữ nguyên power-only fold — nếu không mọi tower chưa có liquid observation sẽ dừng heal (regression). Dict có `{"ozone": 0.0}` (tank rỗng đã quan sát) → fold 0. Drain chỉ chạy khi có observation; không có thì drain 0.

## Thiết kế slice

- 2 pure function trong `SourceRepairTowerBuildState.gd`: `source_repair_tower_ozone_row_state` (fold, row `{"result", "is_power": false}` append vào `required_results` cùng power row) + `source_repair_tower_ozone_consume_state` (drain, trả `ozone_drained` + `liquids`). RED decision mở: dùng generic `SourceConsumeLiquidState.efficiency_state`/`update_state` (N2007) hay inline như power row.
- Driver tick line sau `apply_update_consumption_state`, trước refresh/heal (Java: updateConsumption second pass trước updateTile). Không thêm `time_scale` riêng — dùng `seconds` như N2228.
- 7 semantic key cho proof (6 theo scope 11:15 + 1 bổ sung lần này): ozone_row_full_stock_efficiency_one / ozone_row_partial_stock_caps_efficiency / ozone_row_absent_preserves_power_only / ozone_drains_per_tick_while_efficiency_positive / no_drain_when_efficiency_zero / drain_clamps_at_stock / ozone_empty_clears_should_consume_power (bổ sung: row ≤ 1e-7 → should_consume_power=false, BuildingComp.java:1972-1974).
- Dự kiến GREEN delta: 11497/1679/1605/3001 (symbols +4, Done +1, contracts +1, schema +2). Không đổi shard.
- Files theo mẫu N2228, tên theo scope 11:15: test + register `test_c07_repair_tower_ozone_consume.py` / `register_c07_repair_tower_ozone_consume.py` (có --verify, kiểm trước khi chạy) + proof `C07RepairTowerOzoneConsumeProof.gd/.tscn`.

## Trạng thái

- javalang 0.13.0 OK, port 7777 trống, `git diff --check` sạch, HEAD == origin/main == 0aaea22c.
- Lưu ý: scope 11:15 (`hidden_files/n2229-scope.md`, goal workspace) đã tồn tại trước lần chạy này; lần này scope độc lập từ disk và hội tụ cùng kết luận. Handoff/report đã chỉnh lại theo scope 11:15 (tên file `ozone_consume`, delta +4, không dùng `time_scale` riêng); bổ sung duy nhất: proof key `ozone_empty_clears_should_consume_power` + pin `CONSUME_EFFICIENCY_EPSILON`.
- Không commit/push gì ở lần này (scoping, chưa đủ điều kiện slice). Handoff chi tiết: `docs/superpowers/handoffs/2026-11-17-c07-repair-tower-ozone-consumer-handoff.md`.
- Bước tiếp theo: RED (viết 4 tests + register + proof scene, chạy targeted xác nhận fail cổ điển).

## Hoàn tất — N2229 DONE (2026-11-17 ~13:0x +07)

- RED ~11:45 +07: Ran 4, failures=2, errors=2 (KeyError 'N2229' ×2 — thiếu hàm + chưa register), register --verify 41/41, SSOT chưa đổi 11493/1678/1604/2999.
- GREEN ~12:0x +07: 2 pure function `source_repair_tower_ozone_row_state(frame, delta)` (:97) + `source_repair_tower_ozone_consume_state(frame, delta)` (:107) trong `SourceRepairTowerBuildState.gd` + driver tick lines (:205/:213) — row fold vào first pass cùng power row, drain ở second pass sau `apply_update_consumption_state`, trước refresh/heal. Targeted 4/4 OK trong 15.68s (pytest, 69 subtests; main-thread re-run 17.97s); family RepairTower 24/24 OK trong 92.22s (pytest, 310 subtests); wiring 32/32 OK (9 module; main-thread re-run 25 + 7). Tổng GREEN 60/60. Proof headless Linux: `C07RepairTowerOzoneConsumeProof`, 7 semantic key / 10 trong JSON, matches:true.
- Register: --verify 41/41. Lần chạy main đầu FAILED — KeyError 'generated_owner' trong `build_extension_shard` (consumer_slices shard mirror key; tiền lệ N2007: `generated_owner: ''`); sửa register-only, chạy lại exit 0. Không đổi test/proof.
- SSOT sau register: 11497/1679/1606/3003 (symbols +4, Done +1, contracts +2, schema +4). Handoff dự kiến contracts +1 / schema +2 là sai: 2 function → 2 contracts + 4 schema (input+result mỗi function). SHARD CHANGE: consumer_slices 106 → 107, consumer_api_contracts +31 dòng — ozone consumer khớp consumer shard (khác N2228).
- Gate toàn bộ (main thread, PID 2446, ~12:35, log `tools/mindustry_godot_transpiler/full-suite-n2229-gate.log`): Ran 6009 trong 1268.977s, failures=179, skipped=5, 0 errors — toàn bộ 179 là `AssertionError: unexpectedly None` (Godot-absent), 0 dòng ERROR. Xong ~12:57 +07. VM restart #32 (~12:27) giết gate đầu (PID 13491, không footer) và xóa javalang + system pytest — worker cài lại (javalang 0.13.0, pytest 9.2.0), main thread chạy lại gate.
- Hashes: (bổ sung ở commit hash-naming).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: RepairTower còn draw()/drawSelect()/setStats()/drawPlace() + suppression live + targets live list, hoặc family tiếp theo theo backlog. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
