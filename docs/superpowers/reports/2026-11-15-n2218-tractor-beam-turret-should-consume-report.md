# N2218 TractorBeamTurret shouldConsume Gate — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave turrets, integration branch `integration/wave-turrets-n2217-n2218`, base `7c791fac`).

## Source

- TractorBeamTurret.java:141-143 — `return super.shouldConsume() && target != null;`
- BuildingComp.java:755-756 — super default `return enabled;`
- TractorBeamTurret.java:72 — target is a **unit**: `@Nullable Unit target;`
- TractorBeamTurret.java:88-90 — retarget `Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround))`; retargetTime 5f (:21)
- Blocks.java:3640-3653 — only def `parallax`: size 2, range 300f, consumePower 3.3f
- BuildingComp.java:1960 + 1992-1994 — efficiency fold

## Super-chain verification (grep, không tin blind)

TractorBeamBuild (:71) → BaseTurretBuild → Building. Grep xác nhận BaseTurret.java KHÔNG override shouldConsume. **`Turret.java:364` (`isShooting || reloadCounter < reload`) KHÔNG nằm trong chain** (TractorBeamTurret extends BaseTurret, không phải Turret).

## Implementation

- `SourceTractorBeamTurretBuildState.gd`:
  - Frame key `target`, default null (`_initial_frame()` giờ `{"target": null}`)
  - Pure `source_tractor_beam_turret_should_consume_state(frame)` → `{"should_consume", "has_target"}` (gate = enabled && target != null; gate đọc `frame["enabled"]` internal)
  - Driver feed gate vào machinery
- Proof `C07TractorBeamTurretShouldConsumeProof.gd/.tscn`: inject unit fixture tối thiểu `{"type": "dart"}` (chỉ null-ness được đọc); 6 keys: gate_true_when_target_present, gate_false_when_target_null, gate_false_when_disabled, efficiency_zero_when_gate_false, efficiency_folds_power_when_gate_true, frame_target_default_null.
- Coolant là second consumer của TractorBeamTurret — KHÔNG trong slice này.
- Live retarget DEFERRED (Units.closestEnemy scan :88-90, retargetTime 5f; no live fill sets frame["target"] yet). Lưu ý: TractorBeam đã có pure function flow-state mô hình retarget (N1232–N1260, `retarget_state` với `Units.closestEnemy` trong SourceTractorBeamTurretBuildUpdateTileFlowState.gd) nhưng KHÔNG được live tick gọi — live retarget vẫn deferred.

## Driver wording fix (worker phát hiện khi verify)

Driver N2152 ghi cẩu thả "needs live bullet-target state" — TractorBeam target là **Unit**, không phải Bullet. Worker đã sửa wording trong 2 chỗ của driver + docstring, để lần sau không ai nhầm với PointDefense (bullet).

## Commits

- Slice `cecb074e` (worker-N2218, branch `slice/N2218-tractor-beam-turret-should-consume`, 5 files +816/−16; đã push 15:45, remote tip cecb074e).
- Integration cherry-pick `929e276e`; fix `4a186c78` seed target fixture vào proof N2152 (power proof expect `efficiency_folds_power_min`; tick không reset key mới — đã verify).
- SSOT gộp `5b12011c` (wave turrets): 11435/1659/1582/2955 (slice riêng +2/+1/+1/+2 → 11433/1658/1581/2953).

## Tests

- RED (trước GREEN): Ran 4, failures=2, errors=2 — registration + exact-evidence `KeyError: 'N2218'`, gate-state fail thiếu hàm, proof fail `AssertionError: unexpectedly None`.
- Pre-register (sau GREEN): failures=1, errors=2 — đúng mẫu kỳ vọng (gate-state PASS).
- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+2/+1/+1/+2 → 11433/1658/1581/2953; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 13**, tất cả verify verbatim trong upstream (TractorBeamTurret.java / BuildingComp.java / Blocks.java).
- **DEFERRED: 257 entries** — copy nguyên văn DEFERRED-after-wave-plans.py, REMOVE entry gộp turret, ADD 1 entry wording rộng: "TractorBeamTurret live target retarget + coolant rows + updateTile advance…". Test assert cả merged-gone lẫn new-present.
- **Shard đổi: `source_modules/defense_slices.json` + `source_modules/defense_api_contracts.json`** (chỉ thêm N2218) + 4 file SSOT chính. Ledger diff chỉ thêm duy nhất key `N2218`.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07TractorBeamTurretShouldConsumeProof` — 6 keys (xem Implementation). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
