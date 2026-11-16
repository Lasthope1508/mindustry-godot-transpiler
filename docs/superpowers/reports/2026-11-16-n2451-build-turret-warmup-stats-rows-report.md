# Report N2451 — BuildTurret warmup / setStats rows

**Slice:** N2451 — BuildTurret.warmup() + setStats(): two
pure-only pures model the warmup accessor and the buildSpeed stat.
**Wave:** advances-29. **Commit:** `40888bad2` on
`slice/N2451-build-turret-warmup-stats-rows` (base `27b5ced7f`).
**Files:** 5, +757/−1.

## Source

setStats() (BuildTurret.java:81-84): `stats.addPercent(Stat.
buildSpeed, buildSpeed);`. warmup() (:254-255): `return warmup;`
— an override of the BuildingComp default `return 0f;`
(BuildingComp.java:608-610); the field is ticked live since N2243
(lerp :139). Class default `buildSpeed = 1f` (:33); the
build-tower def sets `buildSpeed = 1.5f` (Blocks.java:2003).

## Implementation

Two pure-only pures (the N2442 precedent, no tick wiring):
- `source_build_turret_warmup_state(warmup)` → `{warmup_value}`
  — accessor returning the caller-supplied warmup verbatim.
- `source_build_turret_stats_state(build_speed)` → `{stat_key,
  stat_value}` — stat_key `"buildSpeed"` (Stat.java:30),
  stat_value = buildSpeed RAW; percent formatting is a
  display-time UI concern (the N2422 precedent; `addPercent`
  does `(int)(value * 100)` only at display, Stats.java:38).
Driver docstring: added "(9) Warmup / stats rows live (N2451)";
the write/read line (N2446) untouched.

## Commits

- Slice: `40888bad2` (5 files, +757/−1).
- Integration cherry-pick: `d64014a48` (clean).

## Tests

Targeted (new module `tests.test_c07_build_turret_warmup_stats_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+2/+4** → 12294/1865/1803/3398 (exactly
as estimated). Generated diff was purely additive (+524/−0, incl.
defense shards). Audit totalSourceFunctions unchanged at 1336.
DEFERRED **#85 RESOLVED** (258→257, by entry TEXT; no new entry).
Read/write (#84) and per-def (#86) entries stay.

## Godot debt

- NEW proof `C07BuildTurretWarmupStatsRowsProof` (6 keys:
  `warmup_zero`, `warmup_value`, `warmup_one`, `stats_key`,
  `stats_value_def`, `stats_value_class`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
