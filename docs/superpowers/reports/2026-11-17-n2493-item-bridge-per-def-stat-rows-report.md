# Report N2493 — ItemBridge per-def stat rows

**Slice:** N2493 — ItemBridge per-def stat rows (DEFERRED #39).
**Wave:** advances-35. **Commit:** `65471c416` on
`slice/N2493-item-bridge-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +777/−1.

## Source

The def block (Blocks.java:2116-2125): `requirements(...,
with(Items.phaseFabric, 5, Items.silicon, 7, Items.lead, 10,
Items.graphite, 10));` (:2117), `range = 12;` (:2118),
`transportTime = 2f;` (:2119), `arrowPeriod = 0.9f;` (:2120),
`arrowTimeScl = 2.75f;` (:2121). The def block sets NO size —
size 1 is the Block class default (Block.java:215), so the
def and class fallback agree on size. The class fallback is
0/0f, not a named constant: `public int range;`
(ItemBridge.java:27) and `public float transportTime;` (:28)
have NO initializer → Java defaults 0 / 0f; arrowPeriod
0.4f / arrowTimeScl 6.2f (:37/:38). Only ONE `new
ItemBridge(` exists in Blocks.java (phase-conveyor);
bridge-conveyor is `BufferedItemBridge extends ItemBridge`
(BufferedItemBridge.java:9) — a different class, out of
scope as briefed.

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_item_bridge_per_def_stats_state(def_id)` → {size,
range_value, transport_time, arrow_period, arrow_time_scl,
requirements} — the def's rows for phase-conveyor, the CLASS
defaults for an unknown def id. **Key naming deviation from
the brief:** the brief's dict says `range`; the port uses
`range_value` (the N2490 precedent — `range` shadows the
GDScript builtin, the N2456 lesson). The symbol type is
`int` (Java `public int range`), not float. The catalog row
(content_registry_blocks.json, phase-conveyor) agrees
exactly with the def block.

**Verify-first findings:**
- The brief's numbers were all correct — no corrections
  needed.
- The live input feeds the rows into the N2197 linkValid
  pure: a 12-cell link validates under the def range 12 and
  fails under the class range 0.
- The per-def stat call site on a placed bridge waits for
  its own slice — no DEFERRED entry added (the N2442 /
  N2490 caller-read precedent).

## Commits

- Slice: `65471c416` (5 files, +777/−1).
- Integration cherry-pick: `a98061905` (clean).

## Tests

Targeted (new module
`tests.test_c07_item_bridge_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (17 ItemBridge-family modules: 13
item-bridge + liquid-bridge shouldConsume + 3 dump write-back modules
that reference the driver) Ran 68 (51 PASS + 17 proof Godot-absent),
0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2 → 12427/1906/1860/3512** (exactly as
estimated). DEFERRED **#39 RESOLVED** (225→224, by entry TEXT).

## Godot debt

- NEW proof `C07ItemBridgePerDefStatRowsProof` (6 keys:
  `stats_bridge`, `stats_range_time`, `stats_arrows`,
  `stats_requirements`, `stats_class_fallback`,
  `stats_live_input`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
