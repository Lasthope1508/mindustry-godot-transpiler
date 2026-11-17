# Handoff — N2238 RepairTower per-def stat rows verification (C07)

## Status: GREEN, gate running (main thread, PID 9063, launch ~23:4x). Test + proof xanh, chờ gate rồi 5-commit + push. SSOT 11540/1688/1619/3029. Targeted 4/4, family RepairTower 40/40, wiring 32/32 = 76/76; proof 4 semantic keys / 7 in JSON matches:true. Dự kiến footer Ran ~6049, failures ~189, errors=2 (2 KeyError 'N2239' của test RED PointDefenseTurret — không phải regression), skipped 5.

## Commits

- Slice: (this commit)
- Docs: (next commit)
- GOAL: (next commit)

## Scope

1 pure function `source_repair_tower_per_def_stats_state(block_id)` trong
`SourceRepairTowerBuildState.gd` (:217), trả 3 keys `range` / `heal_amount` /
`size`; tái dùng 3 helper per-def (`_range_for_block_id` :186,
`_heal_amount_for_block_id` :196, `_size_for_block_id` :207) — không duplicate
hằng số. KHÔNG driver tick line (static read, tiền lệ N2233/N2235/N2237).
Đóng deferred entry "RepairTower per-def stat rows (size 2, range 100f,
healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583)".

Java evidence (grep -n trên disk):
- Class defaults: RepairTower.java:21 `range = 80f`, :24 `healAmount = 1f`;
  size default Block.java:215 `public int size = 1;`.
- unit-repair-tower Blocks.java:6575-6583: `size = 2`, `range = 100f`,
  `healAmount = 1.5f` (requirements graphite 90 / silicon 90 / tungsten 80,
  consumePower 1f, consumeLiquid ozone 3f/60f — power/ozone KHÔNG trong slice
  này, đã có catalog/driver riêng).
- setStats rows (RepairTower.java:39-40: `Stat.range, range / tilesize`,
  `Stat.repairSpeed, healAmount * 60f`) là presentation riêng, không trong
  slice này.

## RED

`test_c07_repair_tower_per_def_stats.py`: Ran 4, failures=2, errors=2
(KeyError 'N2238' ×2). Register --verify 12/12 exit 0 (script implements
--verify, đã kiểm tra trước).

## GREEN (main thread re-run)

- Targeted 4/4 (15.743s, main-thread re-run).
- Family RepairTower 40/40 (10 module, pytest 152.18s, 560 subtests —
  main thread; worker tuyên bố 40/40 nhưng KHÔNG để lại log family trên đĩa).
- Wiring 32/32 (9/9 module OK ngay lượt đầu, main thread, không flake).
- Tổng 76/76. `git diff --check` CLEAN.
- Proof 4 semantic keys / 7 trong JSON matches:true (keys:
  stats_unit_repair_tower, stats_class_default, stats_empty_defaults,
  has_no_driver_tick_line).

## SSOT

11540/1688/1619/3029 (symbols +3, ledger +1, contracts +1, schema +2).
N2238 done trong ledger. NO shard change (4 file sửa: family.gd + 4 SSOT
canonical; untracked: test `test_c07_repair_tower_per_def_stats.py` +
register `register_c07_repair_tower_per_def_stats.py` + proof.gd/.tscn
`C07RepairTowerPerDefStatsProof`).
Deferred pool 279 → 279 (resolve 1 "RepairTower per-def stat rows", +1
Windows-proof debt; RepairTower 6 / RepairTurret 30 entries — không họ nào
bị wipe).

## Gate

DONE (main thread, PID 9063, ~23:40–23:58). Ran 6049 trong 1071.624s,
failures=190, errors=2, skipped=5 — 189 `AssertionError: unexpectedly None`
(Godot-absent) + 1 FAIL `test_point_defense_turret_target_acquire_state`
(RED N2239, assert function chưa tồn tại) + 2 ERROR KeyError 'N2239' (RED
N2239, slice chưa đăng ký) — KHÔNG phải regression. Footer khớp dự kiến
(Ran 6049 = 6041 + 8; failures 187 → 190 = +1 Godot-absent proof test N2238,
+1 Godot-absent proof test RED N2239, +1 FAIL semantic RED N2239). Log
`tools/mindustry_godot_transpiler/full-suite-n2238-gate.log` (untracked,
KHÔNG stage).

## Số hiệu N2238 bị trùng — ĐÃ XỬ LÝ (main thread)

Lượt cron 23:00 scope N2238 = PointDefenseTurret updateTile target acquire
và viết RED test (`test_c07_point_defense_turret_target_acquire.py`, chỉ có
file test + scope, CHƯA đăng ký ledger). Lượt cron 23:15 làm RepairTower
per-def stats và tính số tiếp theo từ ledger (Done 1687 → N2238), đăng ký
N2238 = RepairTower. Va chạm làm test PointDefenseTurret hỏng thêm
(Ran 4, failures=3, errors=4 — registration test đọc ledger['N2238'] =
entry RepairTower, godot_owner mismatch).

Cách xử lý: slice đã đăng ký (RepairTower) GIỮ số N2238; slice chưa đăng ký
(PointDefenseTurret) đổi số → **N2239**: 8 tham chiếu 'N2238' trong test file
→ 'N2239', scope file `n2238-scope.md` → `n2239-scope.md`, red log →
`n2239-red.log`. File RepairTower KHÔNG chạm (test 9× N2238, register 7×
N2238 nguyên vẹn). Sau đổi số, RED N2239 sạch lại: Ran 4 in 0.610s,
FAILED (failures=2, errors=2), KeyError 'N2239' ×2.

## Next

Gate → report/spec + 5-commit + push N2238. Sau đó N2239 PointDefenseTurret
target acquire GREEN. Suppression live + targets live list vẫn BLOCKED.
Proofs not yet run on Windows Godot — debt in GOAL.md §5.
