# N2237 MassDriver updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- MassDriverBuild.updateTile (MassDriver.java:133-221): link / state-machine idle-accepting-shooting / reloadCounter / waitingShooters / rotation align / fire / dumpAccumulate. linkValid :346-349; shooterValid :342-344; fire() :290-317 (reloadCounter=1f, items leave the self frame immediately, bullet damage = totalUsed/2f); Time.run arrival cleanup :209-214 deferred; dump :164-166; no-power skip :169-171.
- Def mass-driver (Blocks.java:2167-2174, single def): itemCapacity 120, reload **200f** (class 100f :33), range 440f, consumePower 1.75f. Class: rotateSpeed 5f, minDistribute 10, bulletSpeed 5.5f, bulletLifetime 200f, translation 7f, shake 3f.
- **Scope corrections (all verified by grep): Angles.near is STRICT `<`** (`return angleDist(a, b) < range;`, Angles.java:29-31 — the scope's "angleDist <= margin" is wrong; `<=` is Angles.within :19-21; ported locally as `_mass_driver_angles_near` over shared angleDist, N2191 precedent). Line ranges corrected: dump :164-166 (not :166-168); no-power skip :169-171 (not :170-172); accepting :173-182 (not :174-182); shooting :182-220 (not :183-217); state switch :154-161 (not :153-163); Time.run arrival :209-214 (not :208-213); linkValid :346-349 (not :346-350). Config handlers are at :58-59, not "configure :353-357" (that's `config()` at :353-356). **shooterValid does NOT check team** (unlike linkValid — the shooter record carries no team flag). N2171 had no `items` frame key (`_initial_frame` was `{}`).

## Implementation

- `SourceMassDriverBuildState.gd`:
  - Pure `source_mass_driver_update_tile_advance_state(frame, ...)` (15 params, N2225/N2231 style) → 13 result symbols: link, rotation, reload_counter, state, waiting_shooters, items, partner_waiting_shooters, fired, fired_items, fired_total, bullet_damage, bullet_speed, bullet_lifetime.
  - Explicit `linked` dict + `shooters` dict (keyed by packed pos), content-id `item_order` for fire; cross-building write-back returns `partner_waiting_shooters`, the driver writes both frames. Driver runs the advance with **no enabled guard** (MassDriver `noUpdateDisabled=false`, N2231 precedent); world coords are cell × tile_size (game `tile_size`, default 8, Vars.java:135); `within` is strict dst2 < range² (N2229 precedent). Reuses `source_angles_move_toward` / `source_angles_angle` / drill inventory helpers.
  - One documented port limitation: if the post-cleanup current shooter has no record (sprite gone), the accepting branch keeps rotation instead of aiming at its stale position (Java would aim one tick, then clean it next tick).
  - Proof arithmetic validated by a Python simulation of the advance mirroring the GDScript exactly: 17/17 checks pass (decay 0.9975, clamp 0, accept rotate 90→85, fire 20 items/damage 10.0, cap 120/damage 60.0, all three no-fire cases, timescale bullet).

## Commits

- Slice `0b79b770` (worker-N2237 re-spawned after daemon restart ~18:17, branch `slice/N2237-mass-driver-update-tile`, 5 files +1343/−3; đã push 18:28, remote tip 0b79b770).
- Integration cherry-pick `47fac343`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +13/+1/+1/+2 → 11581/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 76/76, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2171 power: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +13/+1/+1/+2 → 11581/1676/1599/2989; audit 1336, legacy 0. **NO shard changes.**
- DEFERRED 266 (265 − 2 resolved: updateTile advance + fire/bullet rows, fire() fully ported as pure + 3 new: dumpAccumulate, Time.run arrival, bullet entity/DriverBulletData).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).
- Flag: the kept DEFERRED entry `MassDriver link/config rows` says "needs tile/link state the tick does not track yet" — now partly stale, since the tick tracks link state (frame key + driver gather); only the config-UI part still defers. Kept verbatim per the copy rule.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07MassDriverUpdateTileProof` — 6 keys: `reload_counter_decays`, `idle_accepts_waiting_shooter`, `shooting_registers_on_link`, `fire_transfers_items_and_resets_reload`, `no_fire_without_alignment`, `live_tick_writes_advance_frame_keys`.
