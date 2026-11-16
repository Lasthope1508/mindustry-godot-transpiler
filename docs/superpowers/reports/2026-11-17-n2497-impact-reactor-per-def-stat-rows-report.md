# Report N2497 — ImpactReactor per-def stat rows

**Slice:** N2497 — ImpactReactor per-def stat rows (DEFERRED #59).
**Wave:** advances-35. **Commit:** `6f357fd2c` on
`slice/N2497-impact-reactor-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +824/−1.

## Source

The def block (Blocks.java:2632-2645): `size = 4;` (:2634),
`health = 900;` (:2635), `powerProduction = 130f;` (:2636),
`itemDuration = 140f;` (:2637), `liquidCapacity = 80f;`
(:2640), `consumePower(25f);` (:2642),
`consumeItem(Items.blastCompound);` (:2643),
`consumeLiquid(Liquids.cryofluid, 0.25f);` (:2644),
requirements lead 500 / silicon 300 / graphite 400 /
thorium 100 / surge-alloy 250 / metaglass 250 (:2633).
Single def confirmed (only `new ImpactReactor(` in
Blocks.java). **Brief correction — wrong files for
size/health:** the brief said to verify the size/health
class values from ImpactReactor.java / PowerGenerator.java,
but neither file declares them — they are Block.java fields
(`public int size = 1;` :215, `public int health = -1;`
:190). Class defaults: itemDuration 60f
(ImpactReactor.java:20), liquidCapacity 30f (:26),
powerProduction 0f (declared in PowerGenerator.java:25
with NO initializer and never set by its constructor →
Java default 0f — the field lives on the generator side,
not ImpactReactor).

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_impact_reactor_per_def_stats_state(def_id)` →
{size, health, power_production, item_duration,
liquid_capacity, requirements} — the impact-reactor rows,
the CLASS defaults (size 1, health 40 post-init,
powerProduction 0f, itemDuration 60f, liquidCapacity 30f,
no requirements) for an unknown def id. **Fallback health
is 40, not −1 (coordinator ACCEPTED — same decision as
N2495/N2496):** the class field −1 is a sentinel, resolved
by `Block.init()` (:1378-1395) to `Mathf.round(1*1*40, 5)
= 40` (scaledHealth 40 default, no requirements → scaling
1f). The pure returns the post-init effective 40, with the
sentinel documented in the driver, register, test, and
proof.

**Verify-first findings:**
- The brief's def numbers were all correct.
- **Catalog gap (follow-through):**
  `content_registry.json` carries impact-reactor
  health/size/powerProduction/itemDuration/requirements
  but **no `liquidCapacity` key** — the pure reads 80f
  from Java. A catalog liquidCapacity-capture slice could
  follow.
- Proof live-input design: the class fallback feeds the
  N2450 stats pure with `has_cons_power=false` (the class
  has no ConsumePower — `consumePower(25f)` is def-only,
  Blocks.java:2642), so it never divides by the 0f class
  powerProduction; the def row yields production time
  140/60 s and the label "115.12 seconds ~ 21.16 seconds
  power equilibrium" (matches N2450).

## Commits

- Slice: `6f357fd2c` (5 files, +824/−1).
- Integration cherry-pick: `38084d36b` (clean).

## Tests

Targeted (new module
`tests.test_c07_impact_reactor_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (8 ImpactReactor modules) Ran 32 (24
PASS + 8 proof Godot-absent), 0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2 → 12427/1906/1860/3512** (exactly as
estimated). DEFERRED **#59 RESOLVED** (225→224, by entry TEXT).

## Godot debt

- NEW proof `C07ImpactReactorPerDefStatRowsProof` (6 keys:
  `stats_reactor`, `stats_size_health`,
  `stats_power_duration`, `stats_requirements`,
  `stats_class_fallback`, `stats_live_input`) — written but NEVER
  run; debt in GOAL.md §5.
- No old proof needs a re-run.
