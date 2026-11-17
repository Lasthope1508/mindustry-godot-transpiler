# Handoff — N2234 RepairTurret senseObject() legs (C07)

## Status: GREEN + gate xanh, chờ push (2026-11-17 ~19:3x +07, main-thread verified). Test + proof + gate xanh, chưa push. SSOT 11527/1684/1615/3021. Targeted 4/4, family RepairTurret 76/76, wiring 32/32 = 112/112; proof 7 semantic keys / 10 in JSON matches:true. Gate Ran 6029, failures=184, skipped=5, 0 errors — toàn bộ Godot-absent. Proofs not yet run on Windows Godot — debt in GOAL.md §5.

## Scope (chốt 2026-11-17 ~18:5x +07, file goals/hidden_files/n2234-scope.md)

**N2234 = `RepairPointBuild.senseObject()` — 4 legs + default**, 1 pure function trong `SourceRepairTurretBuildState.gd`, đặt ngay sau `source_repair_turret_sense_state` (kề sense() N2223), **KHÔNG có driver tick line** (logic read, không phải tick write; logic-processor dispatch hook là slice riêng sau).

- Ưu tiên 1 (suppression live + targets live list): VẪN BLOCKED — kiểm lại từ disk ở lần này: không có `frame["units"] =` nào trong `godot-mindustry/src/game/*.gd`; không frame nào stamp `heal_suppressed` / `heal_suppression_time` (chỉ có `frame.get("heal_suppressed")` read trong SourceBuildTurretBuildState.gd, không stamp). KHÔNG scope lại.
- (a) config-display: CHỌN senseObject() legs. `display()` (BuildingComp.java:1556) KHÔNG làm: vẫn là UI Table work, không phải pure state read — giữ deferred.
- (b) drawBeam jitter/pulse: KHÔNG làm — cần model arc Rand (xorshift128+ + murmurHash3, arc-upstream/arc-core/src/arc/math/Rand.java) với đúng semantics 64-bit + float đơn của Java; quá lớn cho một slice, giữ deferred.
- (c) family tiếp theo: KHÔNG — (a) còn làm được, theo đúng thứ tự giao việc.
- KHÔNG bắt đầu C08 inventory.

## Java evidence

- `senseObject()` — BuildingComp.java:2128-2136 (`public Object senseObject(LAccess sensor){ return switch(sensor){ case type -> block; case firstItem -> items == null ? null : items.first(); case config -> block.configSenseable() ? config() : null; case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null; default -> noSensed; }; }`).
- Unhandled sensor → `noSensed` sentinel (`Object noSensed = new Object();`, Senseable.java:6), logic converts to numeric `sense()` fallback (`if(objOut == Senseable.noSensed){` / `to.setnum(se.sense(la));`, LExecutor.java:697-698) — port reports `handled: false` + `is_no_sensed: true` (tiền lệ sense() N2223 `sense_value_is_nan`).
- RepairPointBuild is the building (`public class RepairPointBuild extends Building implements Ranged, RotBlock{`, RepairTurret.java:153) of the block (`public class RepairTurret extends Block{`, RepairTurret.java:25).

## Implementation

- `source_repair_turret_sense_object_state(sensor, block_id)` (:475) → `{"handled": bool, "sense_object": Variant, "is_no_sensed": bool}` (mẫu 3-key của sense() N2223):
  - `type` → `{"handled": true, "sense_object": block_id, "is_no_sensed": false}` (port identity của block là id string).
  - `firstItem` → `{"handled": true, "sense_object": null, "is_no_sensed": false}` (RepairTurret không có items — `items == null` luôn đúng).
  - `config` → `{"handled": true, "sense_object": null, "is_no_sensed": false}` (RepairTurret `configSenseable()` false — không có config).
  - `payloadType` → `{"handled": true, "sense_object": null, "is_no_sensed": false}` (RepairTurret không mang payload).
  - unknown → `{"handled": false, "sense_object": null, "is_no_sensed": true}` (noSensed sentinel).

## Phát hiện ngoài scope (KHÔNG sửa trong slice này — cần correction slice riêng)

- N2222 pin `ambientSoundVolume = 1f` và ghi "both defs share them", nhưng Blocks.java override per-def: repair-point `ambientSoundVolume = 0.9f;` (:6393 — scope ghi :6394, lệch 1 dòng), repair-turret `ambientSoundVolume = 1.25f;` (:6408). Loop hiện tại dùng 1.0 cho cả hai def — sai so với catalog. Đã ghi vào DEFERRED của register N2234 (entry "RepairTurret per-def ambientSoundVolume correction") để không mất dấu.

## RED (2026-11-17 ~18:5x +07)

- Targeted: **4 failed** (pytest; KeyError 'N2234' ×2 trong log) — classic RED. Register --verify **26/26 exprs present, exit 0** (script implements --verify, đã kiểm tra trước). SSOT lúc RED: 11524/1683/1614/3019 (baseline N2233).

## GREEN (2026-11-17 ~19:0x +07, worker cron 18:45 TIMEOUT trước khi viết handoff — main thread verify lại toàn bộ + tự viết handoff)

- Targeted: **4/4 OK** — main-thread re-run: **Ran 4 tests in 15.973s, OK** (worker log: 4 passed, 62 subtests passed in 14.70s).
- Family RepairTurret (19 module): **76 passed in 254.55s** — đúng kỳ vọng 76/76 (72 cũ + 4 mới).
- Wiring (chuẩn 9 module / 32 test): **32/32** — 9/9 log OK.
- Proof Godot headless Linux: **7/7 key semantic true + matches:true** (7 semantic / 10 trong JSON): sense_object_type_repair_point, sense_object_type_repair_turret, sense_object_first_item_null, sense_object_config_null, sense_object_payload_type_null, sense_object_unknown_is_no_sensed, has_no_driver_tick_line.
- `git diff --check` CLEAN (main thread).
- SSOT (verify từ disk): **11527/1684/1615/3021** — symbols +3, ledger +1, contracts +1, schema +2 so với N2233 (11524/1683/1614/3019). N2234 status done; 3 source symbols (result.handled / .sense_object / .is_no_sensed). **NO shard change** (5 file sửa: family .gd + 4 canonical SSOT; 4 file mới untracked: test, register, proof .gd/.tscn).
- Deferred pool: **282 → 278** (senseObject deferral đã resolve + ghi thêm ambient correction entry + Windows-proof debt; RepairTurret 29 entry, RepairTower 6 entry — không họ nào bị wipe; entry senseObject còn lại chỉ là BuildTurret sense rows (họ khác) và display() rows (đã cập nhật text "senseObject done at N2234")).

## Files

- Slice: `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (1 hàm), `godot-mindustry/src/generated/source_{symbol_registry,slice_ledger,api_contracts,state_schema}.json`, `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_sense_object.py`, `tools/mindustry_godot_transpiler/register_c07_repair_turret_sense_object.py`, `godot-mindustry/tools/runtime_proofs/C07RepairTurretSenseObjectProof.gd` + `.tscn`.
- KHÔNG stage: proof `.json`, `*.gd.uid`, gate/working log.
- Logs: goals `hidden_files/n2234-red.log`, `n2234-green-targeted.log`, `n2234-family.log`, `n2234-wiring-*.log`, scope `n2234-scope.md`; gate log `tools/mindustry_godot_transpiler/full-suite-n2234-gate.log`.

## Next

1. Full gate từ main thread (đang chạy) → dự kiến Ran ~6029, failures ~184, skipped 5, 0 errors (toàn Godot-absent).
2. Sau footer: report + design spec (Done 1683 → 1684 + dòng N2234) + GOAL §5 debt line N2234 + 5-commit + push (fetch + fast-forward origin/main trước — validation merge đáp xuống thường xuyên).
3. Tiếp theo: correction slice per-def ambientSoundVolume (0.9f/1.25f), hoặc suppression live + targets live list (vẫn BLOCKED), hoặc họ tiếp theo theo backlog.

## Commits

- Slice: 20e107f3
- Docs: d2dd4aeb
- GOAL: 1a2ce609
