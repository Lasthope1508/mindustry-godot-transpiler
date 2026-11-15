# N2243 BuildTurret updateTile Advance Part 1 (Sync + Warmup) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- BuildTurretBuild.updateTile() sync half (BuildTurret.java:121-140): `unit.tile(this);` / `unit.team(team);` (:122-123, no port effect — the frame inputs ARE the unit's state); `rotation = unit.rotation();` (:126); `if(unit.activelyBuilding()){` + `unit.lookAt(angleTo(unit.buildPlan()));` (:128-130); `if(checkSuppression()){` + `efficiency = potentialEfficiency = 0f;` (:132-133); `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);` / `unit.speedMultiplier(potentialEfficiency * timeScale);` (:136-137); `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);` (:139).
- **Scope corrections (all verified by grep): rotation init is 90.0** (`public float rotation = 90;`, BaseTurret.java:114 — not 0.0), matching the unit init block (`unit.rotation(90f);`, BuildTurret.java:99-101). **checkSuppression() = isHealSuppressed() + Fx** (BuildingComp.java:1336-1347), so the advance reads the existing `heal_suppressed` key from N2215 — NO new `suppressed` synonym (N2228 precedent). **:121-140 never reads isControlled()** (the controlled branch belongs to N2244), so NO `controlled` input.
- Single def build-tower (Blocks.java:1997-2006): size 3, range 200f, buildSpeed 1.5f, consumePower 3f, nitrogen second consumer.

## Implementation

- `SourceBuildTurretBuildState.gd`:
  - Pure `source_build_turret_update_tile_advance_state(frame, ...)` → 7 result symbols: rotation, unit_look_angle, efficiency, potential_efficiency, build_speed_multiplier, speed_multiplier, warmup. Java order matters: rotation is read BEFORE the lookAt (:126 precedes :128-130), so this tick's rotation is the pre-lookAt unit rotation; the warmup reads efficiency AFTER the suppression zeroing (:139 after :133).
  - potential_efficiency defaults to the folded efficiency (`potentialEfficiency = efficiency;`, BuildingComp.java:1989, N2227 precedent); apply_update_consumption_state stamps the live value after the fold. The lerp reuses shared SourceMathState.source_lerp_delta with the UNSCALED Time.delta — only the multipliers use the scaled timeScale.
  - `_initial_frame` rotation 90.0, warmup 0.0, unit_look_angle 90.0, multipliers 0.0. The live unit-state fill waits for its own slice (no live Unit object behind the frame inputs).

## Commits

- Slice `aaaf97ff` (worker-N2243, branch `slice/N2243-build-turret-update-tile`, 5 files +719/−3; đã push 19:49, remote tip aaaf97ff).
- Integration cherry-pick `f1ed1729` (clean); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +7/+1/+1/+2 → 11649/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 37/37, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Siblings N2184/N2215: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +7/+1/+1/+2 → 11649/1692/1614/3019; audit 1336, legacy 0. **Defense shard CHANGED** (`defense_slices` + `defense_api_contracts`).
- DEFERRED 283 (283 − 1 + 1: the updateTile advance entry reworded down to the plan-logic half for N2244).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07BuildTurretUpdateTileProof` — 6 keys: `rotation_follows_unit`, `look_at_when_building`, `suppression_zeroes_efficiency`, `multipliers_scale_with_potential`, `warmup_lerps_when_building`, `warmup_decays_when_idle`.
