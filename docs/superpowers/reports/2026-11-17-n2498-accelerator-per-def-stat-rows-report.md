# Report N2498 — Accelerator per-def stat rows

**Slice:** N2498 — Accelerator per-def stat rows (DEFERRED #64).
**Wave:** advances-35. **Commit:** `676e95bb4` on
`slice/N2498-accelerator-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +778/−1.

## Source

The def block (Blocks.java:6823-6832): `requirements(...,
with(Items.copper, 16000, Items.silicon, 11000,
Items.thorium, 13000, Items.titanium, 12000,
Items.surgeAlloy, 6000, Items.phaseFabric, 5000));` (:6824,
with `BuildVisibility.campaignOnly`), `powerBufferRequirement
= 1_000_000f;` (:6826), `size = 7;` (:6827),
`scaledHealth = 80;` (:6831). Cross-checked against
`content_registry.json` (size 7, scaledHealth 80, health
3920, same requirements) — and 7×7×80 = 3920 = the catalog
health. **Single def confirmed** (only one `new
Accelerator(` in Blocks.java). Accelerator.java is in
`campaign/`, as the brief said. Class defaults: size 1
(Block.java:215), scaledHealth −1 (Block.java:188),
powerBufferRequirement 0f (the field is uninitialized —
`public float powerBufferRequirement;`,
Accelerator.java:41 — Java float default), requirements {}
(Block.java:356).

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_accelerator_per_def_stats_state(def_id)` → {size,
scaled_health, power_buffer_requirement, requirements} —
the accelerator rows, the CLASS defaults for an unknown
def id. **Judgment call (coordinator ACCEPTED): the
scaledHealth class fallback is −1, not 40.** The CLASS
field default is `public float scaledHealth = -1;`
(Block.java:188), the "unset" sentinel. The 40 is the
*Block.init() resolution* (`if(scaledHealth < 0){
scaledHealth = 40;`, Block.java:1380-1381, × healthScaling
sum = 1f for an unknown def with no requirements), already
ported in SourceBlockInitHealthState
(`block_health.default_scaled_health`). Per the N2490
precedent (fallback = field declaration values) and the
port's own SSOT (`block_health.scaled_health_field`:
"Block.scaledHealth source field default"), the pure
returns **−1.0** for an unknown def, with the init
resolution documented in the driver comment, register
docstring/rule, test, and proof. **This is consistent
with the N2495/N2496/N2497 health-40 decision, not in
conflict with it:** the `scaled_health` key exposes the
FIELD itself (whose declared default −1 is a meaningful
"unset" sentinel that init checks), whereas the `health`
key in those slices exposes EFFECTIVE health (where −1 is
never a real value, so the post-init 40 is correct). Both
choices are semantically consistent per key.

**Verify-first findings:**
- The brief's numbers were ALL correct (verified, not
  trusted).
- The live input feeds the def requirement into the N2422
  bar pure: 500k/1M → fraction 0.5 bar present; fallback
  0f → bar absent.
- No new DEFERRED entries added. The per-def stat call
  site (a placed accelerator reading these rows) waits for
  its own slice — no entry added (the N2442 precedent,
  noted in the register docstring).

## Commits

- Slice: `676e95bb4` (5 files, +778/−1).
- Integration cherry-pick: `fb7410364` (clean).

## Tests

Targeted (new module
`tests.test_c07_accelerator_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (11 Accelerator modules) Ran 44 (33
PASS + 11 proof Godot-absent), 0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2 → 12425/1906/1860/3512** (exactly as
estimated). DEFERRED **#64 RESOLVED** (225→224, by entry TEXT).

## Godot debt

- NEW proof `C07AcceleratorPerDefStatRowsProof` (6 keys:
  `stats_accelerator`, `stats_size_health`,
  `stats_power_buffer`, `stats_requirements`,
  `stats_class_fallback`, `stats_live_input`) — written but NEVER
  run; debt in GOAL.md §5.
- No old proof needs a re-run.
