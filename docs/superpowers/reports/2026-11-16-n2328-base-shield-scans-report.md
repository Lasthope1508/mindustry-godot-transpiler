# Report N2328 — BaseShield live bullet + enemy-unit scans

**Slice:** N2328 — BaseShield live bullet scan + live enemy-unit scan (2
filter pures + tick wiring into the N2236 advance). **Wave:** advances-13.
**Commit:** `51d72e56` on `slice/N2328-base-shield-scans` (base `4349a660`).
**Files:** 6, +1019/−13.

## Source

Java: `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency,
0.05f);` (BaseShield.java:89); `float rad = radius();` (:91, radius() =
smoothRadius AFTER the lerp); `if(rad > 1){` (:93);
`Groups.bullet.intersect(x - rad, y - rad, rad * 2f, rad * 2f,
bulletConsumer);` (:96); `Units.nearbyEnemies(team, x, y, rad + 10f,
unitConsumer);` (:97). nearbyEnemies filters `u.within(x, y, radius +
u.hitSize/2f)` (Units.java:482–488) — enemy-only by construction, the
advance checks no team. `within` is STRICT squared dst2 < dst²
(Position.java:44–46). The bulletConsumer narrow check (enemy + absorbable
+ STRICT within rad) and the unitConsumer overlapDst/kill/repel
(BaseShield.java:38–56) were ALREADY ported by the N2236 advance; this
slice only adds the SCANS. All brief/SCOPE cites verified correct by the
worker (BaseShield lerp :89 / rad :91 / gate :93 / intersect :96 /
nearbyEnemies :97; unitConsumer :38–56; Units.nearbyEnemies :482–488).

## Implementation

2 new pure functions (N2297/N2299 precedent — 2 pures → 2 contracts + 4
schemas):
1. `source_base_shield_supplied_bullets_state(candidates, rad, building_x,
   building_y)` → `{bullets}`: RECT broad phase [x±rad, y±rad] INCLUSIVE
   (center-in-rect, N2277 precedent — a bullet at the rect corner (rad,
   rad) is IN). NO team/hittable filter here (the advance does the narrow
   check). Missing x/y → EXCLUDED.
2. `source_base_shield_supplied_enemy_units_state(candidates, rad,
   building_x, building_y, team_id)` → `{enemy_units}`: enemy team +
   STRICT within (dst2 < (rad + 10 + hitSize/2)² — exactly at the range is
   OUT). Missing x/y → EXCLUDED; missing hit_size → 0.0 (N2226
   precedent); missing team → own team (excluded).

**The rad problem:** rad is computed INSIDE the advance (after the lerp),
but the tick needs rad BEFORE the advance call to run the scans. The
driver computes `rad_after` with the SAME shared lerp helper + const the
advance uses — deterministic, same result. The `rad > 1` gate lives at the
TICK (mirror Java :93): rad <= 1 → both scans empty. Candidates read from
frame `bullet_candidates` / `enemy_unit_candidates` (default [] — frame
inputs; live Groups.bullet / Units queries still defer).

**Follow-through 6th file:** the N2236 test pinned the full advance call
with `[], []` (:249) → the worker updated it to the live call.

## Commits

- Slice: `51d72e56` (6 files, +1019/−13).
- Integration cherry-pick: `3bc6d537` (clean).

## Tests

Targeted (new module `tests.test_c07_base_shield_scans`): 3/4 PASS + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). Exact-evidence 18/18. Siblings Ran 12 =
9 PASS + 3 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+2/+4** → 11951/1764/1697/3186 (exactly the SCOPE
estimate): symbols `source_base_shield_supplied_bullets_state_result.bullets`
/ `source_base_shield_supplied_enemy_units_state_result.enemy_units`;
audit stays 1336. DEFERRED net 0 (−1+1).

## Godot debt

- NEW proof `C07BaseShieldScansProof` (6 keys:
  `bullet_scan_admits_in_rect`, `bullet_scan_excludes_out_of_rect`,
  `unit_scan_admits_enemy_in_range`, `unit_scan_excludes_out_of_range`,
  `scans_empty_when_radius_small`, `live_tick_passes_scanned_lists`) —
  written but NEVER run; debt in GOAL.md §5.
