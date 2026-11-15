# N2236 BaseShield updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- BaseShield smoothRadius / bullet absorb / unit repel + instakill as a pure advance in `SourceBaseShieldBuildState.gd` (BaseShield.java:88-99; bulletConsumer :27-36; unitConsumer :38-57).
- 4 result symbols. Live scan fill + application deferred.

## Key facts for the next agent

- **The scope MISSED the instakill branch** (`if(overlapDst > unit.hitSize * 1.5f) unit.kill()`, BaseShield.java:43-45) — ported as the `killed_units` pure result (boundary STRICT).
- **radius() = smoothRadius** — scan / absorb / repel all run on the SMOOTH radius.
- **broken is NEVER set live** (only init false :83 + save read :167; hit only in a comment :33; no buildup field exists).
- lerpDelta = lerp(from, to, clamp(progress * Time.delta)) (Mathf.java:430-432); Vec2.setLength on a zero vector stays 0; Units.nearbyEnemies filters within (radius + hitSize/2) + enemies only.
- Register: 72 exact exprs, 0 missing. DEFERRED: 265 (265 − 1 + 1 new: live fill). **Defense shard CHANGED**.
- Flags: the 'BaseShield radius / sides rows' entry is now stale in its "tick does not track yet" clause; the 'BaseShield broken / hit rows' entry should become broken/hit only (no buildup) — for the cite-cleanup slice.
- Slice commit `bfb1f442` (branch `slice/N2236-base-shield-update-tile`, đã push 18:25); integration cherry-pick `ff8f6220`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07BaseShieldUpdateTileProof` — 6 keys (`absorb_blocks_enemy_bullet`, `absorb_ignores_same_team`, `live_tick_writes_advance_frame_keys`, `no_repel_outside_radius`, `repel_pushes_enemy_unit`, `smooth_radius_tracks_efficiency`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
