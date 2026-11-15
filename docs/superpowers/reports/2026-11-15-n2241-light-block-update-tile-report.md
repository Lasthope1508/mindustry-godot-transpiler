# N2241 LightBlock updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- LightBuild.updateTile (LightBlock.java:104-106): smoothTime = lerpDelta(smoothTime, timeScale, 0.1f) — the WHOLE updateTile.
- Def illuminator (Blocks.java:6763-6768): brightness 0.75f, radius 140f, consumePower 0.05f.
- **Scope corrections (all verified by grep): smoothTime init is 1f** (LightBlock.java:69 — not 0f); updateTile :104-106 (not :104-107); drawLight :127-128. **NO `light_radius_scale`** — the clamp min(smoothTime, 2f) is draw, not updateTile, and waits for its own slice (hence SSOT only +1).
- **Line divergence (see STATUS.md): N2189 already did this advance on the batch line** — the first LightBlock advance on the wave line is this slice, not a duplicate here. N2189 is a SUPERSET (registers smooth_time + light_radius_scale); the unification plan (STATUS.md, written 18:30) merges N2189's broader function with this slice's cite corrections into one 8-key proof. Do NOT delete or renumber either slice before unification.

## Implementation

- `SourceLightBlockBuildState.gd`:
  - Pure `source_light_block_smooth_time_state(frame, ...)` → 1 result symbol: smooth_time. A pre-slice frame folds to 1.0 through the `.get()` default (N2223 precedent).
  - The drawLight radius clamp + brightness fold wait for their own slice (existing LightBlock drawLight DEFERRED entry covers them).

## Commits

- Slice `341b9bc5` (worker-N2241, daemon-restart survivor, branch `slice/N2241-light-block-update-tile`, 5 files +540/−6; đã push 18:21, remote tip 341b9bc5).
- Integration cherry-pick `2215a10b`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +1/+1/+1/+2 → 11569/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 94/94 — 82 of N2185 + 12 new, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2185 power: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +1/+1/+1/+2 → 11569/1676/1599/2989; audit 1336, legacy 0. **Power shard CHANGED** (`power_slices` + `power_api_contracts`).
- DEFERRED 264 (265 − 1 resolved: LightBlock updateTile advance + 0 new).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07LightBlockUpdateTileProof` — 6 keys: `smooth_time_lerps_toward_time_scale`, `smooth_time_holds_at_time_scale`, `smooth_time_decays_when_time_scale_drops`, `smooth_time_converges_after_ticks`, `frame_defaults_to_java_initial`, `live_tick_writes_advance_frame_keys`.
