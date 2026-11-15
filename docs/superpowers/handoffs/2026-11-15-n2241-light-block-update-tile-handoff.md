# N2241 LightBlock updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- LightBlock smoothTime lerpDelta toward live timeScale as a pure advance in `SourceLightBlockBuildState.gd` (LightBlock.java:104-106 — the WHOLE updateTile).
- 1 result symbol: smooth_time. The drawLight radius clamp + brightness fold wait for their own slice.

## Key facts for the next agent

- **smoothTime init is 1f** (LightBlock.java:69 — not 0f); updateTile :104-106 (not :104-107); drawLight :127-128. NO `light_radius_scale` (the clamp is draw, deferred).
- **Line divergence (see STATUS.md): N2189 already did this advance on the batch line.** This slice is the first LightBlock advance on the WAVE line, not a duplicate here. N2189 is a SUPERSET (smooth_time + light_radius_scale); the unification plan merges N2189's broader function with this slice's cite corrections into one 8-key proof. Do NOT delete or renumber either slice before unification.
- Register: 94 exact exprs (82 of N2185 + 12 new), 0 missing. DEFERRED: 264 (265 − 1 + 0 new). **Power shard CHANGED**.
- Slice commit `341b9bc5` (branch `slice/N2241-light-block-update-tile`, đã push 18:21); integration cherry-pick `2215a10b`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07LightBlockUpdateTileProof` — 6 keys (`smooth_time_lerps_toward_time_scale`, `smooth_time_holds_at_time_scale`, `smooth_time_decays_when_time_scale_drops`, `smooth_time_converges_after_ticks`, `frame_defaults_to_java_initial`, `live_tick_writes_advance_frame_keys`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
