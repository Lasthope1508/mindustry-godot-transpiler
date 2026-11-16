# Report N2492 — ShockwaveTower per-def stat rows

**Slice:** N2492 — ShockwaveTower per-def stat rows (DEFERRED #36).
**Wave:** advances-35. **Commit:** `8ac2299da` on
`slice/N2492-shockwave-tower-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +719/−1.

## Source

The single def block (Blocks.java:2038-2044): `size = 3;`
(:2039), `range = 170f;` (:2040), `reload = 80f;` (:2041),
`requirements(Category.defense, with(Items.surgeAlloy, 50,
Items.silicon, 150, Items.oxide, 30, Items.tungsten, 100));`
(:2042-2043). Only ONE `new ShockwaveTower` exists in
Blocks.java — a single-def family. The class defaults
(ShockwaveTower.java:25-26): `public float range = 110f;`
(:25), `public float reload = 60f * 1.5f;` (:26); size 1 is
the Block class default (Block.java:215), requirements {}
(Block.java:356).

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_shockwave_tower_per_def_stats_state(def_id)` →
{size, range_value, reload_value, requirements} — the def's
rows for shockwave-tower, the CLASS defaults for an unknown
def id. The fallback reload is the EVALUATED 90.0 (the proof
pins 90f; the exact expr `public float reload = 60f * 1.5f;`
is cited in the driver, test, and register). The catalog row
(content_registry.json, shockwave-tower) carries size 3 /
range 170.0 / reload 80.0 / the same 4 requirements — it
matches the def block exactly.

**Verify-first findings:**
- The brief was correct on every point — no corrections
  needed.
- The live input feeds the def vs class reload into the
  N2390 sense pure: counter 45 → 45/80 = 0.5625 vs 45/90 =
  0.5 (bare ratio, NO clamp, ShockwaveTower.java:110).
- Follow-through (no DEFERRED entry — the pure is
  caller-read, N2442 precedent): the tick currently reads
  reload/range from the catalog block
  (`block.properties.get("reload", 60.0 * 1.5)`), not from
  this pure. A future slice could wire the pure as the
  tick's def-values source.

## Commits

- Slice: `8ac2299da` (5 files, +719/−1).
- Integration cherry-pick: `0e7c4f4a1` (clean).

## Tests

Targeted (new module
`tests.test_c07_shockwave_tower_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (12 ShockwaveTower modules) Ran 48 (36
PASS + 12 proof Godot-absent), 0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2 → 12425/1906/1860/3512** (exactly as
estimated). DEFERRED **#36 RESOLVED** (225→224, by entry TEXT).

## Godot debt

- NEW proof `C07ShockwaveTowerPerDefStatRowsProof` (6 keys:
  `stats_tower`, `stats_size_range`, `stats_reload`,
  `stats_requirements`, `stats_class_fallback`,
  `stats_live_input`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
