# Handoff N2327 — ShockwaveTower live bullet scan

## What this slice did

Wired the ShockwaveTower live bullet scan: a new pure filters frame bullet
candidates by rect + enemy team + hittable, and the tick passes the
filtered list into the N2247 advance (replacing the `[]` literal). 6
files, +1047/−9, commit `a0e06bc3` on
`slice/N2327-shockwave-bullet-scan`.

## Key facts for the next agent

- Pure `source_shockwave_tower_supplied_bullets_state(candidates,
  range_value, tower_x, tower_y, tower_team)` → `{bullets}` (extra
  `tower_team` param — brief missed it).
- Filter: in rect [x±range, y±range] INCLUSIVE (a rect corner (range,
  range) is IN even though dst > range) + team != tower team + hittable
  == true. Missing x/y → EXCLUDED; missing team → own team (excluded);
  missing hittable → true.
- Range: class 110f (ShockwaveTower.java:25) / def 170f
  (Blocks.java:2038-2044) — catalog 170.0, fallback 110.0.
- The scan runs BEFORE the advance call (Java order: intersect runs in
  updateTile when the fire gate opens).
- **The N2318 test pin was updated in this slice** (:173) — the brief
  missed it; the worker self-detected.
- Scope corrections: hittable is BulletType.java:143 (brief said :147).
- **Rect-vs-hitbox deviation:** Java's intersect is QuadTree hitbox STRICT
  overlap; the port uses center-in-rect inclusive (N2277 precedent). The
  worker added NO separate DEFERRED entry — the coordinator added the
  refinement entry at integration.
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED net 0 (−1+1,
  resolved entry 224).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerBulletScanProof` (6 keys) — never run.
