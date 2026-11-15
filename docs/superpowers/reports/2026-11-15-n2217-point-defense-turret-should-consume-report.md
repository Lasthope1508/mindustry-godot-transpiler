# N2217 PointDefenseTurret shouldConsume Gate — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave turrets, integration branch `integration/wave-turrets-n2217-n2218`, base `7c791fac`).

## Source

- PointDefenseTurret.java:105-107 — `return super.shouldConsume() && target != null;`
- BuildingComp.java:755-756 — super default `return enabled;`
- PointDefenseTurret.java:59 — target is a **bullet**: `public @Nullable Bullet target;`
- PointDefenseTurret.java:66 — retarget `Groups.bullet.intersect(...).min(...)`; :70-72 — clear when `!target.isAdded()`
- Blocks.java:3835-3847 — only def `segment`: size 2, range 180f, consumePower 8f, reload 8f
- BuildingComp.java:1960 + 1992-1994 — efficiency fold

## Super-chain verification (grep, không tin blind)

PointDefenseBuild (:58) → ReloadTurretBuild (ReloadTurret.java:25) → BaseTurretBuild (BaseTurret.java:113) → Building. Grep xác nhận ReloadTurret.java + BaseTurret.java KHÔNG override shouldConsume. **`Turret.java:364` (`isShooting || reloadCounter < reload`) KHÔNG nằm trong chain** (PointDefenseTurret extends BaseTurret, không phải Turret) — đã ghi cảnh báo vào gate comment + test assert cả expr đó lẫn `Turret.java:364`.

## Implementation

- `SourcePointDefenseTurretBuildState.gd`:
  - Frame key `target`, default null (`_initial_frame()` giờ `{"target": null}`)
  - Pure `source_point_defense_turret_should_consume_state(frame)` → `{"should_consume": enabled and target != null, "has_target": target != null}` (thứ tự theo Java: super trước, target sau); gate đọc `frame["enabled"]` internal
  - Driver feed gate vào machinery (`var gate ...` + `bool(gate.get("should_consume", true))`)
- Proof `C07PointDefenseTurretShouldConsumeProof.gd/.tscn`: inject bullet fixture tối thiểu `{"type": "bullet"}` (chỉ null-ness được đọc); 6 keys: gate_true_when_target_present, gate_false_when_target_null, gate_false_when_disabled, efficiency_zero_when_gate_false, efficiency_folds_power_when_gate_true, frame_target_default_null.
- Coolant là second consumer của PointDefenseTurret — KHÔNG trong slice này.
- Live retarget DEFERRED (Groups.bullet scan :65-67, isAdded clear :70-72, rotation / reloadCounter / beam :78-103; no live fill sets frame["target"] yet).

## Commits

- Slice `dc2efa45` (worker-N2217, branch `slice/N2217-point-defense-turret-should-consume`, 5 files +800/−16; đã push 15:46, remote tip dc2efa45).
- Integration cherry-pick `d0fc7ee7`; fix `4a186c78` seed target fixture vào proof N2151 (power proof expect `efficiency_folds_power_min`; tick không reset key mới — đã verify).
- SSOT gộp `5b12011c` (wave turrets): 11435/1659/1582/2955 (slice riêng +2/+1/+1/+2 → 11433/1658/1581/2953).

## Tests

- RED (trước GREEN): Ran 4, failures=2, errors=2 — registration + exact-evidence `KeyError: 'N2217'`, gate-state fail thiếu hàm, proof fail `AssertionError: unexpectedly None`.
- Pre-register (sau GREEN): failures=1, errors=2 — đúng mẫu kỳ vọng (gate-state PASS).
- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+2/+1/+1/+2 → 11433/1658/1581/2953; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 14**, tất cả verify verbatim trong upstream (PointDefenseTurret.java / BuildingComp.java / Blocks.java).
- **DEFERRED: 257 entries** — copy nguyên văn DEFERRED-after-wave-plans.py, REMOVE entry gộp turret ("PointDefenseTurret updateTile advance / shouldConsume gate; TractorBeamTurret …"), ADD 1 entry wording rộng live-fill. Test assert cả merged-gone lẫn new-present.
- **Shard đổi: `source_modules/defense_slices.json` + `source_modules/defense_api_contracts.json`** (chỉ thêm N2217) + 4 file SSOT chính. Ledger diff chỉ thêm duy nhất key `N2217`.
- Anomaly thoáng qua (worker báo): ngay sau register exit 0, lần check đầu báo `KeyError: 'N2217'` dù counts đã là số mới; check lại ngay sau đó entry đầy đủ, ledger diff chỉ có N2217, targeted 3/4 PASS. Coordinator verify lại khi tích hợp: ledger có N2217 status done + đủ 2 symbols, không tái hiện — coi như đọc thoáng qua.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07PointDefenseTurretShouldConsumeProof` — 6 keys (xem Implementation). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
