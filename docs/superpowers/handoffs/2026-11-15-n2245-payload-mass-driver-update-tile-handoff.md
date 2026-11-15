# N2245 PayloadMassDriver updateTile Advance Part 1 (Frame + State) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- PayloadMassDriver frame/state advance as a pure advance in `SourcePayloadMassDriverBuildState.gd` (PayloadMassDriver.java:155-234): link refresh, charge discharge, curSize/targetSize, effectDelayTimer, charging reset, reload decay, shooter cleanup, state switch, dump, no-power return.
- 13 result symbols: link, charge, cur_size, target_size, effect_delay_timer, charging, reload_counter, waiting_shooters, state, pay_length, pay_rotation, pay_vector, loaded.

## Key facts for the next agent

- **updateTile ends :332** (not :347). No-power return :232-234. **Shooter validity is INLINE (:199-202) — NO shooterValid helper — and does NOT check team.** `same_block` = BLOCK-id match (2 defs are different blocks). **Charge/timer use RAW Time.delta; reload decay uses edelta.** Dump payLength is NOT clamped at 0.
- **The frame stores pay_vector as a {"x":, "y":} dict** (the N2231 precedent). The N2246 branches read Vector2 — the tick wiring converts at the boundary (2 helpers added at integration). Do NOT change one side's form without updating the conversion.
- turret_rotation / last_other / payload are read-only in part 1 (written by the N2246 branches / transfer). moveOutPayload is PURE vector/rotation form only (front() + pushOutput + dumpPayload defer).
- Register: 87 exact exprs + 25 backed exprs, 0 missing. DEFERRED: 286 (updateTile advance entry reworded to the branches half + 3 new). **Payload shard CHANGED**.
- Slice commit `d995b023` (branch `slice/N2245-payload-mass-driver-update-tile`, đã push 19:50); integration cherry-pick `5573dcd3`; SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07PayloadMassDriverUpdateTileProof` — 6 keys (`charge_discharges_when_idle`, `reload_counter_decays`, `state_switches_to_accepting`, `state_switches_to_shooting`, `dump_unloads_when_idle`, `no_power_skips_branches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
