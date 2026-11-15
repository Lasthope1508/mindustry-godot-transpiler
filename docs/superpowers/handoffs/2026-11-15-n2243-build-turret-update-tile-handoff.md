# N2243 BuildTurret updateTile Advance Part 1 (Sync + Warmup) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- BuildTurret updateTile sync + warmup as a pure advance in `SourceBuildTurretBuildState.gd` (BuildTurret.java:121-140): rotation follow, lookAt, suppression zeroing, multipliers, warmup lerp.
- 7 result symbols: rotation, unit_look_angle, efficiency, potential_efficiency, build_speed_multiplier, speed_multiplier, warmup.

## Key facts for the next agent

- **Rotation init is 90.0** (BaseTurret.java:114 + unit init block BuildTurret.java:99-101) — NOT 0.0. Java order: rotation is read BEFORE the lookAt; the warmup reads efficiency AFTER the suppression zeroing.
- **checkSuppression() = isHealSuppressed() + Fx** — the advance reads the existing `heal_suppressed` key (N2215); do NOT add a `suppressed` synonym.
- **:121-140 never reads isControlled()** — the controlled branch is N2244's. potential_efficiency defaults to the folded efficiency (BuildingComp.java:1989). The lerp uses the UNSCALED Time.delta; only the multipliers use timeScale.
- The N2244 plan-logic function sits AFTER this one in Java order (merged at integration, commit `340cec5d`); `_initial_frame` is the union of both slices' keys.
- Register: 37 exact exprs, 0 missing. DEFERRED: 283 (the updateTile advance entry reworded to the plan-logic half). **Defense shard CHANGED**.
- Slice commit `aaaf97ff` (branch `slice/N2243-build-turret-update-tile`, đã push 19:49); integration cherry-pick `f1ed1729`; SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07BuildTurretUpdateTileProof` — 6 keys (`rotation_follows_unit`, `look_at_when_building`, `suppression_zeroes_efficiency`, `multipliers_scale_with_potential`, `warmup_lerps_when_building`, `warmup_decays_when_idle`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
