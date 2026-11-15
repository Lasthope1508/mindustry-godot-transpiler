# N2247 ShockwaveTower updateTile Advance (Fire) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- ShockwaveTowerBuild.updateTile() (ShockwaveTower.java:73-104): fire gate :73 (`potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)`); bullet scan :75 (Groups.bullet.intersect); wave damage :90-93; heat set :82; reloadCounter reset :83; effects/sound/shake :84-86; Events.fire(Trigger.shockwaveTowerUse) :99; heat decay :104.
- **Scope corrections (all verified by grep): `heat = 1f` is :82** (not :81); **`reloadCounter = 0f` is :83** (not :84 as the scope + the N2187 docstring said — the stale :84 cite in the old DEFERRED fire-reset entry is now removed); `Events.fire(Trigger.shockwaveTowerUse)` is :99, guard :98. **NO potentialEfficiency deviation** — the driver frame already has `potential_efficiency` stamped by apply_update_consumption_state, so the fire gate reads the correct live value.
- Class: range 110f :25, reload 90f :26, bulletDamage 160 :27, falloffCount 20f :28, shake 2f :29, checkInterval 8f :31, cooldownMultiplier 1f :34. Single def shockwave-tower (Blocks.java:2038-2044; driver docstring says range 170f / reload 80f — def overrides class; the pure function takes per-def params).

## Implementation

- `SourceShockwaveTowerBuildState.gd`:
  - Pure `source_shockwave_tower_update_tile_advance_state(frame, ...)` → 5 result symbols: fired, reload_counter, heat, targets, wave_damage.
  - Did NOT add edelta again — N2187 already advances reloadCounter every tick (driver line 133). Live tick wiring runs the advance after the charge in the existing guard with `check_ready=false` + empty candidate list (no timer infra, no live bullet query — N2229 precedent), so there is no live fire, only heat decay live.
  - `_initial_frame` now returns `{"reload_counter": 0.0, "heat": 0.0, "targets": []}`.

## Commits

- Slice `a46b276b` (worker-N2247, branch `slice/N2247-shockwave-tower-update-tile`, 5 files +648/−4; đã push 19:49, remote tip a46b276b).
- Integration cherry-pick `66626216` (clean); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +5/+1/+1/+2 → 11647/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 36/36, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Siblings N2187/N2177: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +5/+1/+1/+2 → 11647/1692/1614/3019; audit 1336, legacy 0. **Defense shard CHANGED** (`defense_slices` + `defense_api_contracts`).
- DEFERRED 285 (283 − 3 + 5: fire-reset + shape/timer + updateTile advance entries resolved/reworded; 4 new: live timer fill, live bullet scan fill, wave effects/sound/shake, wave damage application on live bullets).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07ShockwaveTowerUpdateTileProof` — 6 keys: `fire_gate_needs_charge_and_timer`, `scan_filters_enemy_hittable`, `wave_damage_falloff_formula`, `target_removed_below_wave_damage`, `heat_set_on_fire`, `heat_decays_every_tick`.
