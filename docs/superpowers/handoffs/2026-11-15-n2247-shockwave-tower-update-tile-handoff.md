# N2247 ShockwaveTower updateTile Advance (Fire) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- ShockwaveTower fire as a pure advance in `SourceShockwaveTowerBuildState.gd` (ShockwaveTower.java:73-104): fire gate, bullet scan, wave damage with falloff, heat set/decay.
- 5 result symbols: fired, reload_counter, heat, targets, wave_damage.

## Key facts for the next agent

- **`heat = 1f` is :82, `reloadCounter = 0f` is :83** (not :81/:84 as the scope + N2187 docstring said — the stale :84 cite is now removed from DEFERRED). `Events.fire(Trigger.shockwaveTowerUse)` is :99.
- **NO potentialEfficiency deviation** — the frame already has `potential_efficiency` stamped by apply_update_consumption_state. **Do NOT add edelta again** — N2187 already advances reloadCounter every tick.
- Live tick wiring runs the advance with `check_ready=false` + empty candidate list (no timer infra, no live bullet query) — no live fire, only heat decay live.
- Register: 36 exact exprs, 0 missing. DEFERRED: 285 (fire-reset + shape/timer + updateTile advance resolved/reworded + 4 new live-fill entries). **Defense shard CHANGED**.
- Slice commit `a46b276b` (branch `slice/N2247-shockwave-tower-update-tile`, đã push 19:49); integration cherry-pick `66626216`; SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07ShockwaveTowerUpdateTileProof` — 6 keys (`fire_gate_needs_charge_and_timer`, `scan_filters_enemy_hittable`, `wave_damage_falloff_formula`, `target_removed_below_wave_damage`, `heat_set_on_fire`, `heat_decays_every_tick`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
