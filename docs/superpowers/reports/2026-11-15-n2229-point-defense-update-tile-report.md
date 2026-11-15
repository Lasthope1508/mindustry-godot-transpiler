# N2229 PointDefenseTurret updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-3, integration branch `integration/wave-advances-3-n2229-n2234`, base `ff82ab1d`).

## Source

- PointDefenseBuild.updateTile (PointDefenseTurret.java:62-103): retarget (:65-67) via `Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this))` — RECTANGLE intersect (not a circle), min by RAW dst2 (no hitSize subtraction, unlike Units.closestEnemy); pooled clear (:70-72) `if(target != null && !target.isAdded()) target = null;`; cooling (:74-76) `if(coolant != null) updateCooling();` (ReloadTurret.java:28-41); look-at-target (:78-103): guard `target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable`; rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta()); reloadCounter += edelta(); shoot when Angles.within(rotation, dest, shootCone) && reloadCounter >= reload: realDamage = bulletDamage * state.rules.blockDamage(team); if target.damage() > realDamage → reduce, else remove; effects + sound; reloadCounter = 0.
- updateCooling (ReloadTurret.java:28-41): if canReload() (reloadCounter < reload) && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0: capacity = filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? current.heatCapacity : 0.4f); amount = coolant.amount * coolant.efficiency(this); coolant.update(this); reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier() (= 1f); chance effect deferred.
- **Coolant is null for segment** (def has no ConsumeCoolant consumer; BaseTurret.init :50-51 findConsumer returns null) → the cooling branch never runs live; modeled with explicit coolant params, default no-op (N2226 multiplier precedent).
- Def segment (Blocks.java:3835-3847, single def): range 180f, consumePower 8f, size 2, shootLength **5f** (class 3f), bulletDamage **30f** (class 10f), reload **8f** (ReloadTurret class default 10f, PointDefense ctor 30f — DEF WINS). Class: rotateSpeed 20f (:39), retargetTime 5f (:21), shootCone 5f (:32), coolantMultiplier 2f (ctor :42).

## Implementation

- `SourcePointDefenseTurretBuildState.gd`:
  - Pure `source_point_defense_turret_update_tile_advance_state(frame, ...)` → 6 result symbols: target, rotation, reload_counter, fired, target_damage_remaining, target_removed.
  - Retarget cadence deferred (no timer helper) — pure takes explicit `bullets` candidates list + `retarget_tick` bool (N2226 precedent); driver passes `false` live.
  - Target dict needs `added` flag (default true) for the pooled clear; shot outcome is a pure result (`target_damage_remaining` / `target_removed`), never applied to a live bullet.
  - Rotation uses `SourceMathState.source_angles_move_toward` (already in port).
  - File naming: test/register carry the `_turret` infix (`test_c07_point_defense_turret_update_tile.py`) — differs from the brief but matches the driver name; accepted at integration.

## Commits

- Slice `bee50025` (worker-N2229 re-spawn after VM restart 4, branch `slice/N2229-point-defense-update-tile`, 5 files +1291/−10; đã push 17:43, remote tip bee50025).
- Integration cherry-pick `c024a31e`; SSOT gộp `b5129382` (wave advances-3): 11568/1675/1598/2987 (slice riêng +6/+1/+1/+2 → 11513/1670/1593/2977).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 81/81, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Targeted wave (6 module): Ran 24, 18 PASS + 6 proof Godot-absent. Neighbours 12 module power+gate: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-3: Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors — 175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).

## SSOT / DEFERRED

- SSOT slice riêng +6/+1/+1/+2 → 11513/1670/1593/2977; audit 1336, legacy 0. Defense shards đổi (`defense_slices` + `defense_api_contracts`).
- DEFERRED 260 (260 − 1 resolved retarget+advance + 1 new "PointDefenseTurret updateTile live fill" — timer cadence + live bullet scan fill + coolant live fill + damage application).
- DEFERRED gộp sau wave advances-3: 265 entries (260 − 14 resolved + 19 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PointDefenseUpdateTileProof` — 7 keys: retarget_picks_closest_hittable_bullet, pooled_target_clears, rotation_moves_toward_target, reload_counter_charges_and_fires, shot_reduces_bullet_damage, shot_removes_weak_bullet, live_tick_writes_advance_frame_keys.
