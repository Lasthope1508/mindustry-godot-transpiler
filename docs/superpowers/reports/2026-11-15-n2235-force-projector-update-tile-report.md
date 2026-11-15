# N2235 ForceProjector updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- ForceProjectorBuild.updateTile (ForceProjector.java:207-268): phaseValid / phaseHeat / consume timer / radscl / warmup / buildup / coolant / broken / hit / deflectBullets. realRadius = (radius + phaseHeat * phaseRadiusBoost) * radscl (:279-281); shieldConsumer hit=1f, buildup += shieldDamage (:59-67).
- Def force-projector (Blocks.java:1964-1976, single def): shieldHealth **750f** (class 700f), cooldownNormal **1.5f** (1.75f), cooldownLiquid **1.2f** (1.5f), consumeItem phaseFabric.boost(), consumePower 4f. Class: phaseUseTime 350f, phaseShieldBoost 400f, sides 6, shieldRotation 0f.
- **Scope corrections (all verified by grep): `broken` defaults TRUE** (ForceProjector.java:167 — scope said false, WRONG; a new shield starts broken and clears on the first tick when buildup ≤ 0); **coolantConsumer is NOT null** (constructor adds ConsumeCoolant when consumeCoolant=true, :84-86 — the scope's "null like N2230" suspicion was WRONG; the coolant branch is live-capable, the driver passes no-op defaults because the frame has no liquids store).
- Java ordering ported faithfully: radscl lerps toward the OLD warmup; the broken threshold uses the NEW phaseHeat; deflect runs LAST; hit decay runs BEFORE deflect and uses Time.delta; buildup is NOT clamped (negative clears broken); isInRegularPolygon ported faithfully including Arc's loop-bound trap; shieldDamage = b.damage() * shieldDamageMultiplier (BulletType.java:665-666).

## Implementation

- `SourceForceProjectorBuildState.gd`:
  - Pure `source_force_projector_update_tile_advance_state(frame, ...)` → 10 result symbols: phase_heat, radscl, warmup, buildup, broken, hit, consumed, absorbed_bullets, buildup_delta, real_radius.
  - Timer cadence + consume() application + live bullet scan + coolant live fill deferred (no timer helper / no live query on this base).

## Commits

- Slice `fb0ed566` (worker-N2235 re-spawned after daemon restart ~18:17, branch `slice/N2235-force-projector-update-tile`, 5 files +1451/−15; đã push 18:25, remote tip fb0ed566).
- Integration cherry-pick `4fdfa9ad`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +10/+1/+1/+2 → 11578/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 107/107, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2158 power: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +10/+1/+1/+2 → 11578/1676/1599/2989; audit 1336, legacy 0. **Defense shard CHANGED** (`defense_slices` + `defense_api_contracts`).
- DEFERRED 266 (265 − 1 resolved: ForceProjector updateTile advance + 2 new: live fill + absorbExplosion).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).
- 2 old DEFERRED entries now partly stale (phase-radius / phase-shield rows, broken / buildup rows — the tick now tracks them); flagged for the cite-cleanup slice.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07ForceProjectorUpdateTileProof` — 6 keys: `broken_sets_at_shield_health`, `buildup_cools_down`, `deflect_absorbs_bullet_in_polygon`, `live_tick_writes_advance_frame_keys`, `phase_heat_tracks_booster`, `radscl_follows_warmup`.
