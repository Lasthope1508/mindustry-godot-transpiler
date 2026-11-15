# Handoff N2218 — TractorBeamTurret shouldConsume Gate

**Status: DONE** (coordinator lượt 4 — wave turrets). Slice `cecb074e` trên branch `slice/N2218-tractor-beam-turret-should-consume` (base `7c791fac`, đã push 15:45, remote tip cecb074e). Integration `integration/wave-turrets-n2217-n2218`: cherry-pick `929e276e` + fix `4a186c78` + SSOT gộp `5b12011c` (11435/1659/1582/2955).

## What changed

- `SourceTractorBeamTurretBuildState.gd`: frame key `target` (default null), pure `source_tractor_beam_turret_should_consume_state(frame)` → `{"should_consume", "has_target"}` (gate = enabled && target != null); driver feed gate vào machinery.
- New: `test_c07_tractor_beam_turret_should_consume.py`, `register_c07_tractor_beam_turret_should_consume.py`, `C07TractorBeamTurretShouldConsumeProof.gd/.tscn` (6 keys).
- Driver wording fix: N2152 ghi cẩu thả "needs live bullet-target state" — TractorBeam target là **Unit**, không phải Bullet. Đã sửa 2 chỗ.

## Java ground truth

Gate `return super.shouldConsume() && target != null;` (TractorBeamTurret.java:141-143). super = BuildingComp default `return enabled;` (BuildingComp.java:755-756). Chain TractorBeamBuild → BaseTurretBuild → Building (grep: BaseTurret KHÔNG override shouldConsume). **Turret.java:364 KHÔNG nằm trong chain.** Target là **Unit** (:72). Retarget `Units.closestEnemy(...)` (:88-90), retargetTime 5f (:21). Def duy nhất parallax: size 2, range 300f, consumePower 3.3f (Blocks.java:3640-3653).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +2/+1/+1/+2 → 11433/1658/1581/2953 (slice riêng), audit 1336, legacy 0. Exact exprs 13. DEFERRED 257. Shard đổi: defense_slices.json + defense_api_contracts.json.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07TractorBeamTurretShouldConsumeProof` — 6 keys: gate_true_when_target_present, gate_false_when_target_null, gate_false_when_disabled, efficiency_zero_when_gate_false, efficiency_folds_power_when_gate_true, frame_target_default_null.
- N2152 power proof đã được seed target fixture (`4a186c78`) vì gate mới đóng trên frame trống — khi chạy Godot, N2152 phải vẫn PASS `efficiency_folds_power_min`.

## Deferred (không trong slice này)

- Live target retarget (Units.closestEnemy scan :88-90, retargetTime 5f) — no live fill sets frame["target"] yet. Pure flow-state retarget (N1232–N1260) tồn tại nhưng live tick không gọi.
- Coolant rows (second consumer).
