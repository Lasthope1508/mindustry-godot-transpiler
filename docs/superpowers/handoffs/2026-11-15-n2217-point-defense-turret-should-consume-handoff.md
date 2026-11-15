# Handoff N2217 — PointDefenseTurret shouldConsume Gate

**Status: DONE** (coordinator lượt 4 — wave turrets). Slice `dc2efa45` trên branch `slice/N2217-point-defense-turret-should-consume` (base `7c791fac`, đã push 15:46, remote tip dc2efa45). Integration `integration/wave-turrets-n2217-n2218`: cherry-pick `d0fc7ee7` + fix `4a186c78` + SSOT gộp `5b12011c` (11435/1659/1582/2955).

## What changed

- `SourcePointDefenseTurretBuildState.gd`: frame key `target` (default null), pure `source_point_defense_turret_should_consume_state(frame)` → `{"should_consume": enabled and target != null, "has_target": target != null}`; driver feed gate vào machinery.
- New: `test_c07_point_defense_turret_should_consume.py`, `register_c07_point_defense_turret_should_consume.py`, `C07PointDefenseTurretShouldConsumeProof.gd/.tscn` (6 keys).

## Java ground truth

Gate `return super.shouldConsume() && target != null;` (PointDefenseTurret.java:105-107). super = BuildingComp default `return enabled;` (:755-756). Chain PointDefenseBuild → ReloadTurretBuild → BaseTurretBuild → Building (grep: ReloadTurret/BaseTurret KHÔNG override shouldConsume). **Turret.java:364 KHÔNG nằm trong chain.** Target là **Bullet** (:59). Def duy nhất segment: size 2, range 180f, consumePower 8f, reload 8f (Blocks.java:3835-3847).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +2/+1/+1/+2 → 11433/1658/1581/2953 (slice riêng), audit 1336, legacy 0. Exact exprs 14. DEFERRED 257. Shard đổi: defense_slices.json + defense_api_contracts.json.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PointDefenseTurretShouldConsumeProof` — 6 keys: gate_true_when_target_present, gate_false_when_target_null, gate_false_when_disabled, efficiency_zero_when_gate_false, efficiency_folds_power_when_gate_true, frame_target_default_null.
- N2151 power proof đã được seed target fixture (`4a186c78`) vì gate mới đóng trên frame trống — khi chạy Godot, N2151 phải vẫn PASS `efficiency_folds_power_min`.

## Deferred (không trong slice này)

- Live bullet-target retarget (Groups.bullet scan :65-67, isAdded clear :70-72, rotation / reloadCounter / beam :78-103) — no live fill sets frame["target"] yet.
- Coolant rows (second consumer).
