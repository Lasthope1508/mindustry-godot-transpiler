# Report N2347 — ShockwaveTower bullet scan hitbox broad phase

**Slice:** N2347 — ShockwaveTower bullet scan hitbox broad phase (DEFERRED
#330). **Wave:** advances-16. **Commit:** `4c587214` on
`slice/N2347-shockwave-hitbox-broad-phase` (base `4f31a099`). **Files:** 8,
+1200/−82.

## Source

Java: `Groups.bullet.intersect` is a QuadTree HITBOX overlap query
(EntityGroup.java:195); STRICT Rect.overlaps (QuadTree.java:190-191 /
Rect.java:274-276); the bullet hitbox is a type-hitSize-sided square
centered on the bullet (`public float hitSize = 4;`, BulletType.java:43;
`bullet.hitSize = hitSize;`, BulletType.java:970; `rect.setCentered(x, y,
hitSize, hitSize);`, HitboxComp.java:65-67).

## Implementation

New pure `source_shockwave_tower_supplied_bullets_broad_hitbox_state(candidates,
range_value, tower_x, tower_y)` → `{bullets}`: a hitbox-overlap filter
only — it does NOT re-filter team / hittable (the N2327 pure does that
after the broad call, ShockwaveTower.java:76). It never rewrites an entry:
admitted entries are the candidate dicts themselves, in candidate order,
like Java's Seq<Bullet>. A missing x or y key EXCLUDES the candidate (the
N2327 precedent); a non-Dictionary entry is excluded the same way. A
missing hit_size defaults to 4.0 (the BulletType default — NOT 0.0,
consistent with N2340). The N2327 scan pure now calls the broad pure
INSTEAD of the rect center test (the rect test is deleted entirely from
the driver); the N2340 refinement stays chained after it, re-filtering the
same overlap — idempotent, harmless. The tick is unchanged (it already
passed candidates through scan → refine → advance).

**Re-scope note:** N2347 was originally scoped as the per-battery status
write-back at the distribute step. The first worker found the whole brief
STALE (the write-back loop already exists at
SourceFactoryRuntimeState.gd:1088-1091, from commit 93b2b86d
"N2082–N2083", and BatteryPowerStatusProof is GREEN on Windows Godot
2026-11-13) and stopped correctly with no commit. The coordinator verified
independently and re-scoped N2347 to this broad phase (the number was
never committed anywhere, so reuse is safe). **Coordinator scoping error:**
the caller grep was truncated by `head -8` (the `battery_distribute_state`
matches crowded out the setter line) — lesson: when verifying "no caller",
grep the function name alone with NO head truncation. The #331 entry is
rewritten in place at the advances-16 merge (the REAL remainder is
launch-drain per-battery scaling — see the wave DEFERRED notes).

## Commits

- Slice: `4c587214` (8 files, +1200/−82).
- Integration cherry-pick: `66b2b2f3` (clean).

## Tests

Targeted (new module
`tests.test_c07_shockwave_tower_bullet_scan_broad_hitbox`): 3/4 PASS (RED
confirmed 2F+2E) + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
11/11. Siblings: 8 ShockwaveTower modules Ran 32 (24 PASS + 8 proof
Godot-absent).
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11977/1782/1714/3220, exactly as
estimated (1 symbol:
`source_shockwave_tower_supplied_bullets_broad_hitbox_state_result.bullets`,
java_source arc-core Rect.java). Audit stays 1336.
DEFERRED **332 → 331 (−1+0)**: resolve #330 (rect broad phase drops
straddling hitboxes), no new entry. Base was the merged
DEFERRED-after-advances-15.py (332 entries).

## Godot debt

- NEW proof `C07ShockwaveTowerBulletScanBroadHitboxProof` (6 keys:
  `broad_admits_straddling_hitbox`, `broad_admits_edge_hitbox`,
  `broad_drops_degenerate_edge_hitbox`, `broad_defaults_missing_hit_size`,
  `broad_empty_stays_empty`, `live_tick_passes_broad_bullets`) — written
  but NEVER run; debt in GOAL.md §5. Live tick seeds cyanogen 10.0 (the
  N2340 pattern): straddler x=395 hs8 + center → 2 targets, 340 damage
  each, counter 0, heat 0.9875 — a discriminator vs the old chain's 1
  target.
- **Follow-through — SIMULATED in Python with the pure logic (the N2340
  pattern) BEFORE concluding: N2327 proof outcomes CHANGE** — its proof
  bullets carry no hit_size, so they read the BulletType default 4.0, and
  the (171, 0) / (0, −171) bullets the old rect dropped are now admitted
  (hitbox [169, 173] straddles the 170 edge): the mixed key goes 5 → 7
  admitted and the rect key goes 1 → 4. **The N2327 PROOF is updated by
  this slice** (the out-of-rect fixtures move 171 → 173, restoring the old
  expectations — verified by the same simulation) and **N2327 needs a
  Godot RE-RUN** (a NEW re-run — N2327 was never in the re-run list).
  The N2327 live tick is UNCHANGED (enemy_in / own_in / enemy_out at
  (224, 168): 1 target, 340 damage). **N2340 needs NO re-run**: its pure
  keys call the untouched refinement, and its live tick chain gives the
  same 2 targets (center_zero + edge_four, 340 each) — the edge_zero
  bullet the old rect admitted is now dropped by the broad phase instead
  of the refinement, same final list. Both tests pin the rect center test
  lines — FULL call pins, moved to the broad call (the N2335/N2340
  precedent).
