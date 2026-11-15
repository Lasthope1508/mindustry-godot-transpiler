# N2237 MassDriver updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- MassDriver link / state-machine idle-accepting-shooting / reloadCounter / waitingShooters / rotation align / register+fire as a pure advance in `SourceMassDriverBuildState.gd` (MassDriver.java:133-221; fire() :290-317).
- 13 result symbols. dumpAccumulate / Time.run arrival / bullet entity deferred. Cross-building write-back returns `partner_waiting_shooters`; the driver writes both frames.

## Key facts for the next agent

- **Angles.near is STRICT `<`** (Angles.java:29-31 — the scope's "angleDist <= margin" is wrong; `<=` is Angles.within :19-21; ported locally as `_mass_driver_angles_near`, N2191 precedent).
- Line ranges corrected: dump :164-166; no-power skip :169-171; accepting :173-182; shooting :182-220; state switch :154-161; Time.run arrival :209-214; linkValid :346-349. Config handlers are at :58-59 (not "configure :353-357"). **shooterValid does NOT check team** (unlike linkValid).
- N2171 had no `items` frame key (`_initial_frame` was `{}`); the new frame is `{link: -1, rotation: 90.0, reload_counter: 0.0, state: "idle", waiting_shooters: [], items: {}}`.
- Driver runs the advance with NO enabled guard (noUpdateDisabled=false, N2231 precedent). Proof arithmetic validated by a Python simulation mirroring the GDScript exactly: 17/17 checks pass.
- One documented port limitation: if the post-cleanup current shooter has no record, the accepting branch keeps rotation (Java would aim one tick, then clean it next tick).
- Register: 76 exact exprs, 0 missing. DEFERRED: 266 (265 − 2 + 3 new: dumpAccumulate, Time.run arrival, bullet entity/DriverBulletData). **NO shard changes.**
- The kept DEFERRED entry `MassDriver link/config rows` is now partly stale (the tick tracks link state; only the config-UI part still defers).
- Slice commit `0b79b770` (branch `slice/N2237-mass-driver-update-tile`, đã push 18:28); integration cherry-pick `47fac343`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07MassDriverUpdateTileProof` — 6 keys (`reload_counter_decays`, `idle_accepts_waiting_shooter`, `shooting_registers_on_link`, `fire_transfers_items_and_resets_reload`, `no_fire_without_alignment`, `live_tick_writes_advance_frame_keys`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
