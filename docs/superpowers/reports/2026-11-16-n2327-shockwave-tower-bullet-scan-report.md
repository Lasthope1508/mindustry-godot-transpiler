# Report N2327 — ShockwaveTower live bullet scan

**Slice:** N2327 — ShockwaveTower live bullet scan (Groups.bullet.intersect
rect + enemy/hittable filter over frame bullet candidates, wired into the
N2247 advance). **Wave:** advances-13.
**Commit:** `a0e06bc3` on `slice/N2327-shockwave-bullet-scan` (base
`4349a660`).
**Files:** 6, +1047/−9.

## Source

Java scans at fire-gate time: `Groups.bullet.intersect(x - range, y -
range, range * 2, range * 2, b -> { if(b.team != team && b.type.hittable){
targets.add(b); } })` (ShockwaveTower.java:75–79) — RECT intersect (not a
circle) + enemy team + hittable filter. Range: class 110f
(ShockwaveTower.java:25) / def 170f (Blocks.java:2038-2044) — the catalog
carries 170.0, fallback 110.0. `hittable` defaults true
(BulletType.java:143 — the brief said :147; cite corrected by the worker).
`intersect` is the QuadTree hitbox overlap query (EntityGroup.java:195,
consumer overload) — the port tests bullet CENTERS against the rect
(inclusive), a documented deviation (see below). The N2247 advance ported
the fire gate + wave damage with an explicit `bullet_candidates` list but
the driver passed `[]`; N2318 wired timerCheck (check_ready live).

## Implementation

New pure `source_shockwave_tower_supplied_bullets_state(candidates,
range_value, tower_x, tower_y, tower_team)` → `{bullets}` (the pure needs
an extra `tower_team` param — brief missed it): filter frame candidates by
in-rect [x±range, y±range] INCLUSIVE (a rect corner (range, range) is IN
even though dst > range) + team != tower team + hittable == true. Missing
x/y → EXCLUDED; missing team → own team (excluded); missing hittable →
true. Tick wiring runs the scan BEFORE the advance call and passes the
filtered list instead of `[]`.

**Follow-through 6th file:** the N2318 test pinned the advance call (:173)
— the brief missed it; the worker self-detected and updated it.

**Rect-vs-hitbox deviation (documented):** Java's intersect is QuadTree
hitbox STRICT overlap; the port uses center-in-rect inclusive (N2277
precedent). The worker added NO separate DEFERRED entry — the coordinator
added the refinement entry at integration (DEFERRED merge).

## Commits

- Slice: `a0e06bc3` (6 files, +1047/−9).
- Integration cherry-pick: `63fe603f` (clean).

## Tests

Targeted (new module `tests.test_c07_shockwave_tower_bullet_scan`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 13/13.
Siblings Ran 16 = 12 PASS + 4 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11950/1764/1696/3184 (exactly the SCOPE
estimate): symbol `source_shockwave_tower_supplied_bullets_state_result.bullets`;
audit stays 1336. DEFERRED net 0 (−1+1, resolved entry 224).

## Godot debt

- NEW proof `C07ShockwaveTowerBulletScanProof` (6 keys:
  `scan_admits_enemy_hittable_in_rect`, `scan_excludes_out_of_rect`,
  `scan_excludes_own_team`, `scan_excludes_non_hittable`,
  `empty_candidates_empty`, `live_tick_passes_scanned_bullets`) — written
  but NEVER run; debt in GOAL.md §5.
