# Report N2306 — RepairTower live scan

**Slice:** N2306 — RepairTower live scan (supplied_damaged from frame unit candidates). **Wave:** advances-10.
**Commit:** `3c2d6629` on `slice/N2306-repair-tower-live-scan` (base `fa627ace`).
**Files:** 5, +1103/−14.

## Source

`Units.nearby(team, x, y, range, damaged)` (RepairTower.java:62-66;
refreshInterval 6f); `damaged` = `health < maxHealth - 0.001f`
(HealthComp.java:47-49). The N2227 advance takes `supplied_damaged` as a param
(driver :131); this slice wires `frame["supplied_damaged"]` (default []) into it
(N2226 frame-fallback precedent). Def: size 2, range 100f, healAmount 1.5f
(Blocks.java:6575-6583).

**Scope correction — the brief's "in range" gloss was incomplete:** Java is not
`distance <= range`. `Units.nearby` (Units.java:445-451) admits only
`unit.within(x, y, radius + unit.hitSize/2f)`, and `within` is a STRICT squared
check (`return Mathf.dst2(...) < dst*dst;`, Position.java:44-46) — a unit exactly
at range + hitSize/2 is OUT. The pure implements the exact predicate (N2226
RepairTurret precedent). Distance is the CENTER distance, not the turret's
dst−hitSize/2 value. All other brief cites verified exact
(RepairTower.java:19/:21/:59/:62-66; 14 EXACT_EXPRS verbatim in upstream).

## Implementation

Pure `source_repair_tower_supplied_damaged_state(candidates, range, tower_x,
tower_y)`; `SOURCE_REPAIR_TOWER_RANGE := 100.0`; tick wiring (scan → stamp
`frame["supplied_damaged"]` → advance). Missing `hit_size` reads as 0.0 (point
unit); missing health/max_health/distance-or-x/y → EXCLUDED per brief. Team
filter is the caller's (Java visits the tower team's tree only, Units.java:435-436);
checks run in Java order (range first, damaged second), so exclusion counts need
not sum to candidate count. N2227 advance and N2213 gate logic untouched (only
comments + the tick's refill source changed); the tick's tower position uses the
N2226/N2280 drawx/drawy precedent.

## Commits

- Slice: `3c2d6629` (5 files, +1103/−14).
- Integration cherry-pick: `f7a0acc9` (clean).

## Tests

Targeted `tests.test_c07_repair_tower_live_scan`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Exact-evidence 14/14. Siblings (RepairTower + RepairTurret) Ran 36 =
27 PASS + 9 proof, 0 other failures.
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+1/+2** → 11927/1750/1686/3164, exactly as expected;
audit stays 1336. DEFERRED 326 (325, entry 167 REWRITTEN — scan clause dropped,
heal application kept — + 1 new: live unit-candidate query). The worker's entry
numbers were 0-based ("entry 166" = merged #167).

## Godot debt

NEW proof `C07RepairTowerLiveScanProof` (6 keys: `damaged_in_range_supplied`,
`healthy_excluded`, `out_of_range_excluded`, `empty_candidates_empty`,
`live_tick_refills_targets`, `gate_opens_with_target`) — written but NEVER run;
debt in GOAL.md §5. Flags from this slice (coordinator-verified, fix slices in
advances-11): three RepairTower proofs have stale live-tick keys since N2250
(N2176 power, N2213 gate, N2227 updateTile — they seed no ozone, so the N2250
liquid row folds their live-tick efficiency to 0.0 instead of 0.5); entry 157
was stale (clause satisfied by N2227) and was dropped at integration.
