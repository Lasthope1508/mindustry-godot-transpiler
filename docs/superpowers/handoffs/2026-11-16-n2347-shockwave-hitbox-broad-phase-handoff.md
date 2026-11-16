# Handoff N2347 — ShockwaveTower bullet scan hitbox broad phase

## What this slice did

Replaced the ShockwaveTower bullet scan's rect center test with the
Java-exact QuadTree hitbox-overlap broad phase. 8 files, +1200/−82,
commit `4c587214` on `slice/N2347-shockwave-hitbox-broad-phase`.

## Key facts for the next agent

- Pure `source_shockwave_tower_supplied_bullets_broad_hitbox_state(candidates,
  range_value, tower_x, tower_y)` → `{bullets}` (STRICT Rect.overlaps;
  hitbox = hitSize-sided square centered on the bullet).
- Missing hit_size → **4.0** (BulletType default — NOT 0.0, consistent
  with N2340). Missing x/y or non-Dict excluded; entries never rewritten.
- The pure filters hitbox overlap ONLY (team/hittable filtered by the
  N2327 pure after, ShockwaveTower.java:76). N2340 refinement stays
  chained after (idempotent re-filter). Tick unchanged.
- SSOT +1/+1/+1/+2 (1 symbol, java_source arc-core Rect.java). DEFERRED
  332→331 (−1+0, resolve #330).
- **N2327 outcomes CHANGE (simulated in Python first):** proof bullets
  carry no hit_size → default 4.0; (171,0)/(0,−171) now admitted (hitbox
  [169,173] straddles the 170 edge): mixed key 5→7, rect key 1→4. **N2327
  proof fixtures updated 171→173 in this slice → N2327 NEEDS RE-RUN** (a
  NEW re-run). N2327 live tick unchanged (1 target, 340 damage).
- **N2340 does NOT need a re-run** (live tick chain gives the same 2
  targets; edge_zero is now dropped by the broad phase instead of the
  refinement). Test pins N2327 + N2340 updated (FULL call pins).
- Re-scope: N2347 was originally the per-battery status write-back — the
  first worker found it STALE (live since N2082–N2083, proof GREEN);
  coordinator verified + re-scoped. Lesson: verify "no caller" WITHOUT
  head truncation (the scope grep was cut by `head -8`).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerBulletScanBroadHitboxProof` (6 keys) — never run.
- RE-RUN `C07ShockwaveTowerBulletScanProof` (N2327) with the updated fixtures.
