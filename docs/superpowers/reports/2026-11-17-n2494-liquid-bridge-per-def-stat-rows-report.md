# Report N2494 — LiquidBridge per-def stat rows

**Slice:** N2494 — LiquidBridge per-def stat rows (DEFERRED #42).
**Wave:** advances-35. **Commit:** `73ba4c09c` on
`slice/N2494-liquid-bridge-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +837/−1.

## Source

The def block (Blocks.java:2385-2397): `range = 12;`
(:2386), `liquidCapacity = 100f;` (:2387), `arrowPeriod =
0.9f;` (:2389), `arrowTimeScl = 2.75f;` (:2390),
`requirements(..., with(Items.phaseFabric, 5, Items.silicon,
7, Items.metaglass, 20, Items.titanium, 10));` (:2391).
**The brief's "Def: size 1" is true as a value but size is
NOT set in the def block** — it inherits `public int size =
1;` (Block.java:215); the size symbol's java_source is
Block.java, the only non-Blocks.java symbol. **The brief's
"verify class defaults from LiquidBridge.java" is
imprecise:** LiquidBridge.java sets NO stat field (only
constructor flags, :11-16). The class defaults live on the
parents: range/arrows on ItemBridge (`public int range;`
:27 — no initializer, so Java default **0**; arrowPeriod
0.4f / arrowTimeScl 6.2f, :37-38) and size/liquidCapacity/
requirements on Block.

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_liquid_bridge_per_def_stats_state(def_id)` → {size,
range, liquid_capacity, arrow_period, arrow_time_scl,
requirements} — the phase-conduit rows, the CLASS defaults
for an unknown def id. **Judgment call (coordinator
ACCEPTED): the liquidCapacity fallback is 10.0, NOT −1.0.**
The −1f field (Block.java:77) is a pre-init sentinel;
Block.init() replaces it with `liquidCapacity =
Mathf.round(10f * consumeAmount);` (Block.java:1418), and
LiquidBridge has no liquid consumers so consumeAmount stays
1f → 10f. This matches the 10.0 port precedent
(SourceFactoryBuildState; the N2412 live fill in this same
driver) and the N2495/N2497 health-40 post-init precedent.
**Follow-through:** the conflicting Pump precedent
(`_liquid_capacity_for_block_id` returns −1f for unknown
defs, claiming "exactly as Java would") is questionable —
no loaded block ever has −1f at runtime; reconciling it is
a later slice.

**Verify-first findings:**
- The brief's numbers were all confirmed from the def
  block; the catalog ids are verified (phase-conduit,
  content_registry.json requirements match Java exactly).
- **The family has TWO LiquidBridge defs, not one:**
  bridge-conduit (range 4 / capacity 100f,
  Blocks.java:2374-2384) + phase-conduit;
  reinforced-bridge-conduit is DirectionLiquidBridge (a
  different class, confirmed). bridge-conduit still falls
  back to the class defaults until its own entry (#38 in
  the 218 file) — deliberately NOT pinned in this proof,
  so #38 does not need to edit this proof file.
- Catalog quirk, out of scope (flag only):
  content_registry.json says bridge-conduit `hasPower:
  true` + `consumesPower: true`, but the Java def sets
  `hasPower = false;` (Blocks.java:2380). Pre-existing
  deviation; not touched. The catalog also carries no
  size/liquidCapacity/arrow keys for phase-conduit.

## Commits

- Slice: `73ba4c09c` (5 files, +837/−1).
- Integration cherry-pick: `6449bb1ff` (clean).

## Tests

Targeted (new module
`tests.test_c07_liquid_bridge_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (8 LiquidBridge modules) Ran 32 (24
PASS + 8 proof Godot-absent), 0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2 → 12427/1906/1860/3512** (exactly as
estimated). DEFERRED **#42 RESOLVED** (225→224, by entry TEXT;
neighbours #40 bridge-conduit and #41 reinforced-bridge-conduit stay).

## Godot debt

- NEW proof `C07LiquidBridgePerDefStatRowsProof` (6 keys:
  `stats_bridge`, `stats_range_capacity`, `stats_arrows`,
  `stats_requirements`, `stats_class_fallback`,
  `stats_live_input`) — written but NEVER run; debt in GOAL.md §5.
  The live input feeds the N2275 transport pure (def flow 50.0 vs
  fallback 10.0).
- No old proof needs a re-run.
