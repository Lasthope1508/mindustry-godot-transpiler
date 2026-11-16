# Report N2398 — WallCrafter offload routing

**Slice:** N2398 — WallCrafter offload neighbour routing: the
N2223 advance now routes offloaded items through the shared
`dump_item_state` (the N2283 pattern) and exposes the routed
index + post-offload cursor. **Wave:** advances-22. **Commit:**
`de01819d3` on `slice/N2398-wall-crafter-offload-neighbour-routing`
(base `78a74e152`). **Files:** 5, +1033/−10.

## Source

Java: WallCrafter.java:214 (offload) before :220-221 (dump) —
the tick persists the offload cursor BEFORE timerDump, Java
order. The shared routing is `dump_item_state` (N2283 pattern).

## Implementation

The N2223 advance routes via the shared `dump_item_state`,
using the same frame inputs (`dump_neighbour_accepts` /
`can_dump`) and the same frame `cdump` cursor. The advance
gains `offload_neighbour_index` (−1 = stays home; offload stops
after the first success → NOT an array, unlike N2386) +
`cdump` (the post-offload cursor). The tick persists both keys
AFTER the advance write-back, `cdump` BEFORE timerDump (Java
order offload :214 before dump :220-221). The routed item lands
in the neighbour store through the N2353 helper (amount 1).

**Verify-first:** the N2223 advance never touched the cursor
(only the N2283 timerDump owns frame `cdump`);
`dump_item_state` advances the cursor 1×/neighbour checked =
Java-exact; NO double-advance. `produced(item, 1)` DEFERS (0
grep `produced` in the driver, no sector/team/net input).

## Commits

- Slice: `de01819d3` (5 files, +1033/−10).
- Integration cherry-pick: `9744e063c` (clean).
- Integration touch-up `293de3675` (the N2343 precedent):
  `tests/test_c07_wall_crafter_get_efficiency.py:188` pinned the
  old 7-key advance return — updated to 9 keys + comment fixed.
- Schema + contract fold landed in N2401.

## Tests

Targeted (new module
`tests.test_c07_wall_crafter_offload_routing`): 3/4 PASS + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15).
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12070/1820/1749/3290 (brief
estimated +1 — the shared cursor forces the extra `cdump`
return; the N2343 precedent). Audit stays 1336. DEFERRED
**#256 REWRITTEN IN PLACE** (offload routing live; `produced`
still deferred) — count stays 301. NO schema/contract upsert in
this slice — the fold awaited the coordinator serial N2401.

## Godot debt

- NEW proof `C07WallCrafterOffloadRoutingProof` (4 keys:
  `advance_exposes_offload_neighbour_index`,
  `live_tick_routes_offloaded_item_to_neighbour_frame`,
  `live_tick_offload_falls_back_to_inventory`,
  `live_tick_routed_item_leaves_crafter_without_frame`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
