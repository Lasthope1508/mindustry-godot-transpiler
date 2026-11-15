# N2236 BaseShield updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- BaseShieldBuild.updateTile (BaseShield.java:88-99): smoothRadius lerp; radius() = smoothRadius; bulletConsumer absorb (:27-36); unitConsumer repel (:38-57).
- Defs shield-projector (Blocks.java:2048, radius class default 200f) + large-shield-projector (:2056, radius 400f), both editorOnly, consumePower 5f.
- **Scope correction: the scope MISSED the instakill branch** (`if(overlapDst > unit.hitSize * 1.5f) unit.kill()`, BaseShield.java:43-45) — ported as the `killed_units` pure result (boundary STRICT).
- **broken is NEVER set live** (only init false :83 + save read :167; hit only in a comment :33; no buildup field exists). lerpDelta = lerp(from, to, clamp(progress * Time.delta)) (Mathf.java:430-432); Vec2.setLength on a zero vector stays 0; Units.nearbyEnemies filters within (radius + hitSize/2) + enemies only.

## Implementation

- `SourceBaseShieldBuildState.gd`:
  - Pure `source_base_shield_update_tile_advance_state(frame, ...)` → 4 result symbols: smooth_radius, absorbed_bullets, repelled_units, killed_units.
  - Scan / absorb / repel all run on the SMOOTH radius; live scan fill + application deferred (explicit candidates, N2226 precedent).

## Commits

- Slice `bfb1f442` (worker-N2236, daemon-restart survivor, branch `slice/N2236-base-shield-update-tile`, 5 files +1220/−10; đã push 18:25, remote tip bfb1f442).
- Integration cherry-pick `ff8f6220`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +4/+1/+1/+2 → 11572/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 72/72, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2159 power: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +4/+1/+1/+2 → 11572/1676/1599/2989; audit 1336, legacy 0. **Defense shard CHANGED** (`defense_slices` + `defense_api_contracts`).
- DEFERRED 265 (265 − 1 resolved: BaseShield updateTile advance + 1 new: live fill).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).
- Flags: the 'BaseShield radius / sides rows' entry is now stale in its "tick does not track yet" clause; the 'BaseShield broken / hit rows' entry should become broken/hit only (no buildup field exists) — for the cite-cleanup slice.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07BaseShieldUpdateTileProof` — 6 keys: `absorb_blocks_enemy_bullet`, `absorb_ignores_same_team`, `live_tick_writes_advance_frame_keys`, `no_repel_outside_radius`, `repel_pushes_enemy_unit`, `smooth_radius_tracks_efficiency`.
