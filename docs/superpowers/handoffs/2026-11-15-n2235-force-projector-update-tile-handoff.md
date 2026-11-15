# N2235 ForceProjector updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- ForceProjector phaseHeat / radscl / warmup / buildup / broken / deflectBullets as a pure advance in `SourceForceProjectorBuildState.gd` (ForceProjector.java:207-268; realRadius :279-281; shieldConsumer :59-67).
- 10 result symbols. Timer cadence + consume() + live bullet scan + coolant live fill deferred.

## Key facts for the next agent

- **`broken` defaults TRUE** (ForceProjector.java:167 — scope said false, WRONG; a new shield starts broken, clears on the first tick when buildup ≤ 0).
- **coolantConsumer is NOT null** (constructor adds ConsumeCoolant when consumeCoolant=true, :84-86 — the scope's "null like N2230" suspicion was WRONG; the coolant branch is live-capable, the driver passes no-op defaults because the frame has no liquids store).
- Java ordering: radscl lerps toward the OLD warmup; the broken threshold uses the NEW phaseHeat; deflect runs LAST; hit decay runs BEFORE deflect and uses Time.delta; buildup is NOT clamped (negative clears broken); isInRegularPolygon includes Arc's loop-bound trap; shieldDamage = b.damage() * shieldDamageMultiplier (BulletType.java:665-666).
- Register: 107 exact exprs, 0 missing. DEFERRED: 266 (265 − 1 + 2 new: live fill + absorbExplosion). **Defense shard CHANGED**.
- 2 old DEFERRED entries now partly stale (phase-radius / phase-shield rows, broken / buildup rows) — for the cite-cleanup slice.
- Slice commit `fb0ed566` (branch `slice/N2235-force-projector-update-tile`, đã push 18:25); integration cherry-pick `4fdfa9ad`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07ForceProjectorUpdateTileProof` — 6 keys (`broken_sets_at_shield_health`, `buildup_cools_down`, `deflect_absorbs_bullet_in_polygon`, `live_tick_writes_advance_frame_keys`, `phase_heat_tracks_booster`, `radscl_follows_warmup`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
