# Handoff N2340 — ShockwaveTower bullet scan hitbox refinement

## What this slice did

Chained a hitbox-overlap refinement after the N2327 rect scan: bullets
whose hitbox straddles the rect edge are admitted, degenerate edge points
are dropped. 13 files, +1618/−8, commit `851c9a1e` on
`slice/N2340-shockwave-hitbox-refinement`.

## Key facts for the next agent

- Pure `source_shockwave_tower_supplied_bullets_hitbox_state(candidates,
  range_value, tower_x, tower_y)` → `{bullets}`. Missing `hit_size`
  defaults to **4.0** (BulletType default — NOT N2335's 0.0).
- Hitbox = hitSize-sided square centered on the bullet
  (HitboxComp.java:67); STRICT overlap (Rect.java:274-276).
- The N2327 pure + N2247 advance are untouched (only a doc-comment
  sentence each). The tick passes the refined list into the advance.
- DEFERRED net 0 (resolve #321 + 1 new: rect broad phase drops straddling
  hitboxes). SSOT +1/+1/+1/+2 (exactly the SCOPE estimate).
- N2327 does NOT need a re-run from N2340 (scene untouched; simulated
  outcome identical).
- All 6 proof key expectations were verified by simulating the pure logic
  in Python (live tick: 2 targets, waveDamage 160, 500→340, heat 0.9875).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerBulletScanHitboxProof` (6 keys) — never run.
