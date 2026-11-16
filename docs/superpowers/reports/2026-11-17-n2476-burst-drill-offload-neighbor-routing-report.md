# Report N2476 — BurstDrill updateTile offload neighbor routing

**Slice:** N2476 — BurstDrill offload neighbor routing (the
routing half of DEFERRED #89; the per-def shake/effect rows stay
— the entry is rewritten in place). **Wave:** advances-33.
**Commit:** `e98b7a597` on
`slice/N2476-burst-drill-offload-neighbor-routing` (base
`08b822909`). **Files:** 5, +1164/−13.

## Source

BuildingComp.java (core/src/mindustry/entities/comp/):
offload :1001-1017 (`produced(item, 1); int dump = this.cdump;
for(int i = 0; i < proximity.size; i++){ incrementDump(
proximity.size); Building other = proximity.get((i + dump) %
proximity.size); if(other.acceptItem(self(), item) &&
canDump(other, item)){ other.handleItem(self(), item); return; } }
handleItem(self(), item);` — cdump advances EVERY scanned
iteration, the scan starts at the cdump snapshot, the fallback
is handleItem(self(), item)). incrementDump :1116-1120
(`cdump = ((cdump + 1) % prox);`, guarded `if(prox != 0){`).
BurstDrill.java: the offload branch :106-109 (`if(dominantItems
> 0 && progress >= drillTime && items.total() < itemCapacity){
for(int i = 0; i < dominantItems; i++){ offload(dominantItem); }
}` + `invertTime = 1f; progress %= drillTime;`). The FX
:114-118 are live since N2469 (class defaults).

## Implementation

One routing pure + advance loop threading + tick refresh/
write-back: `source_burst_drill_offload_route_state(
neighbour_accepts_item, neighbour_can_dump, cdump,
offloaded_item_name)` → {routed_index, cdump_after} — routes
ONE offloaded item (the scan starts at the cdump snapshot,
incrementDump runs BEFORE each check, so the cursor advances
once per scanned neighbour INCLUDING the handling one; a full
refused scan returns it to its start — the N2286 full-cycle
invariant). The port reuses the shared rotation helper
(SourceBuildingItemDumpState.increment_dump_cursor_state — the
dump path's helper, no duplicate modulo). The advance loops
this pure once per dominant item with the cdump threaded across
items; the tick lands each routed item in the neighbour store
through the N2353 helper (the N2360 dump write-back precedent)
and the fallback keeps the current add_item_state path.

**Verify-first findings:**
- **The N2403 dump neighbour arrays are STALE at offload time**
  — the fill ran before the timerDump pure, and the store has
  since changed (an empty store at fill time answers all-false
  even with an accepting neighbour). The tick REFRESHES them
  for the dominant item before the advance, through the same
  fill: the probe frame holds one dominant item (`{"items":
  {dominant_item_name: 1}}`), so the fill's first-held pick IS
  the dominant item (the fill reads only frame["items"]).
  Live-managed frames only (dump_neighbour_live — the N2403
  gate): a frame with supplied arrays keeps its seed for the
  offload too. This refresh is the second call site of the
  fill — the N2403 pin (count 2) went stale and was narrowed
  by serial N2483 at integration.
- The cursor is the Building field `transient int cdump;`
  (BuildingComp.java:68, 0). The gate arrays are per-neighbour
  acceptItem / canDump in PROXIMITY order (index i is ring
  cell i, the N2353 convention).
- produced() is recorded per item by the advance (the
  N2398 precedent) — the offloaded count is the per-item
  produced call.

## Commits

- Slice: `e98b7a597` (5 files, +1164/−13).
- Integration cherry-pick: `15b5269e0` (clean).

## Tests

Targeted (new module
`tests.test_c07_burst_drill_offload_neighbor_routing`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (9 BurstDrill modules) Ran 36 (27
PASS + 9 proof Godot-absent), 0 errors.
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2 → 12384/1892/1845/3482** (exactly as
estimated). DEFERRED **#89 REWRITTEN IN PLACE** (234→234, by entry
TEXT — routing live, per-def shake/effect rows still wait).

## Godot debt

- NEW proof `C07BurstDrillOffloadNeighborRoutingProof` (6 keys:
  `route_first_accepting`, `route_skips_rejecting`,
  `route_fallback`, `route_cdump_advances`, `route_loop_cdump`,
  `route_live_tick` — live tick: ring 20, eruption-drill at
  (25,19)-area, surge-smelter takes 2 copper, melter 0, cdump
  14, progress 0.5, invert_time 1.0) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run.
