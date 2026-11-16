# Report N2379 — LiquidBridge doDump neighbour write-back

**Slice:** N2379 — LiquidBridge doDump exposes the handled neighbour;
the tick writes the dumped liquid into the neighbour store. **Wave:**
advances-20. **Commit:** `bfafb77b2` on
`slice/N2379-liquid-bridge-dodump-liquid-write-back` (base
`7b99d3d63`). **Files:** 5, +940/−8.

## Source

Java: LiquidBridge.java:30 (dumps `liquids.current()`);
LiquidModule.java:24 (`private Liquid current = content.liquid(0);`);
BuildingComp.java:896 (proximity get), :918-919
(`next.handleLiquid` / `liquids.remove`).

## Implementation

The doDump advance exposes `dump_neighbour_index` (shared routing
`handled_index`, first handled neighbour, −1 when nothing moved) +
`dumped_liquid_id` (the module current id). The pure signature is
unchanged (the N2287 test pins the call shape). The tick wires the
shared N2371 helper after the doDump write-back when
`dumped_amount > 0`, with `origin_cell` read inline as `dump_cell`
and catalog size (phase-conduit size 1; size-1 ring 0 = offset
(0,−1), verified from the ring generator + angle sort).

**Scope correction — the pure exposes the ID, not a name:**
LiquidBridge dumps `liquids.current()` — ANY liquid, not a def
constant like the Fracker's `"oil"` — and the pure has no catalog
input (frame / had_valid_link / liquids / capacity / neighbours
only), so it cannot resolve a name. The tick resolves the name
through `liquid_names_by_id`, built once per tick from
`catalog.get_many("liquid")` (the PayloadLoader precedent: index =
liquid id), then passes the name to the helper, which re-resolves
it to the id. Water is liquid id 0 (first in `Liquids.load()` and
`content_registry.json` liquids[0]).

## Commits

- Slice: `bfafb77b2` (5 files, +940/−8).
- Integration cherry-pick: `a3ccb5a9d` (clean).

## Tests

Targeted (new module
`tests.test_c07_liquid_bridge_dump_write_back`): 3/4 PASS + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Siblings: 6 modules
(LiquidBridge ×4, liquid neighbour write-back, Fracker dump) —
Ran 24, 18 PASS, 6 failures all Godot-absent proofs, 0 other
errors.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12040/1807/1738/3268 (the two new
symbols). Audit stays 1336. The schema/contract fold landed later
in N2384. DEFERRED **311 → 310** (resolves #247, by entry TEXT;
built on the MERGED base, not a slice snapshot).

## Godot debt

- NEW proof `C07LiquidBridgeDumpWriteBackProof` (3 keys:
  `advance_exposes_dump_neighbour_index`,
  `live_tick_writes_dumped_liquid_to_neighbour_frame`,
  `live_tick_dumped_liquid_leaves_bridge_without_frame`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
