# Report N2495 — StackConveyor per-def stat rows

**Slice:** N2495 — StackConveyor per-def stat rows (DEFERRED #49).
**Wave:** advances-35. **Commit:** `2e12179c1` on
`slice/N2495-stack-conveyor-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +855/−1.

## Source

Two StackConveyor defs, both confirmed: plastanium-conveyor
(Blocks.java:2084-2089: `health = 90;` (:2085), `speed = 4f /
60f;` (:2086), `itemCapacity = 10;` (:2087),
`requirements(..., with(Items.plastanium, 1, Items.silicon,
1, Items.graphite, 1));` (:2088)) and surge-conveyor
(Blocks.java:2237-2253: health 130, speed 5f/60f,
itemCapacity 10, surge-alloy 1 / tungsten 1). **Brief
nuance — "Def: size 1": neither def sets size; size 1
comes from the Block class default (Block.java:215).** Same
for glow: neither def overrides glowAlpha 1f / glowColor
Pal.redLight (StackConveyor.java:34-35). Class defaults:
speed 0f (StackConveyor.java:38), itemCapacity 10 (:52),
glow 1f / Pal.redLight, no requirements (Block.java:356).

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_stack_conveyor_per_def_stats_state(def_id)` → {size,
speed, item_capacity, health, glow_alpha, glow_color,
requirements} — the def's rows for plastanium-conveyor /
surge-conveyor, the CLASS defaults for an unknown def id.
**Judgment call (coordinator ACCEPTED): the class-fallback
health is 40, not −1.** The class field is the sentinel
`public int health = -1;` (Block.java:190, "-1 to use
scaledHealth"), which Block.init() (Block.java:1378-1394)
fills to `round(size*size*scaledHealth, 5)` with
scaledHealth defaulting to 40 (:1381, no requirements to
scale it). A no-override def actually has health 40 after
init, so the fallback row carries 40, not the sentinel. The
proof pins 40. (This decision also governs N2496/N2497,
which report the same 40.)

**Verify-first findings:**
- The brief's numbers were all correct.
- The catalog ids are verified in content_registry.json:
  plastanium-conveyor / surge-conveyor, health 90/130,
  itemCapacity 10, requirements match the def blocks.
  Speed literals match the existing
  SOURCE_STACK_CONVEYOR_SPEED table.
- Catalog quirk, out of scope (flag only): the catalog
  lists plastanium-conveyor with hasPower true /
  consumesPower true even though the def has no hasPower
  line (Blocks.java:2084) — a possible catalog-generation
  quirk, flagged for a catalog slice, not touched here.
- The per-def stat call site on a placed stack conveyor
  waits for its own slice (no DEFERRED entry added — the
  pure is caller-read, like the N2442 stats pure).

## Commits

- Slice: `2e12179c1` (5 files, +855/−1).
- Integration cherry-pick: `0a7b22bd2` (clean).

## Tests

Targeted (new module
`tests.test_c07_stack_conveyor_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (5 StackConveyor modules) Ran 20 (15
PASS + 5 proof Godot-absent), 0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+1/+2 → 12428/1906/1860/3512** (exactly as
estimated). DEFERRED **#49 RESOLVED** (225→224, by entry TEXT; #48
plastanium power-scope entry stays).

## Godot debt

- NEW proof `C07StackConveyorPerDefStatRowsProof` (6 keys:
  `stats_conveyor`, `stats_speed_capacity`,
  `stats_health_glow`, `stats_requirements`,
  `stats_class_fallback`, `stats_live_input`) — written but NEVER
  run; debt in GOAL.md §5. The live input feeds the per-def rows
  into the N2457 stats pure (40 / 50 / 0 items-per-second).
- No old proof needs a re-run.
