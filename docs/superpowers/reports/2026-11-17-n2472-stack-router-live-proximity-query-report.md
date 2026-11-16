# Report N2472 — StackRouter live proximity query

**Slice:** N2472 — StackRouter live proximity query (DEFERRED #210
query half only; the handleItem application waits). The largest
slice of the wave. **Wave:** advances-32. **Commit:** `d89e6457d`
on `slice/N2472-stack-router-live-proximity-query` (base
`99a167e15`). **Files:** 5, +1345/−3.

## Source

BuildingComp.java: updateProximity() :1879-1903 builds the
proximity list (the same-team filter is :1887, `if(other == null
|| other.team != team) continue;`); relativeTo(Building) :530-540
(tile-offset: |dx|>|dy| → 0/2, else the y branch → 1/3 — a diagonal
offset takes the y branch). Edges.getEdges(size) (Edges.java:23-40)
is the proximity ring, angle-sorted. StackRouter.java:49 is the
handleItem application (`target.handleItem(this, current);`); the
trailing `target = target();` is :52 (line 51 is blank — the old
entry cited :51). BuildingComp.java:55 (tmpTiles ObjectSet) funnels
the Java proximity list into hash order.

## Implementation

One live-fill pure + tick wiring (the N2394 pattern):
`source_stack_router_proximity_neighbours_live_fill_state(world_
tiles, cell, size, team, team_map, accepts_map)` →
{proximity_neighbours}. The tick stamps frame["proximity_
neighbours"] BEFORE the target-list + advance (in the enabled
block); supplied lists win, OR a previously live-filled frame
refreshes every tick. The local is named `neighbours_filled` (NOT
`filled` — the N2416 lesson). New frame keys: team_by_tile,
accepts_item_by_tile, bookkeeping proximity_neighbours_live.

**Design decisions (verify-first):**
- **Proximity order** comes from updateProximity (:1879-1903), NOT
  onProximityUpdate (:1154-1156 is only `noSleep()` — the brief
  asked the wrong method). The ring sort is Mathf.angle with
  normalize [0,360) (arc Mathf.java:98-102) → size 1: east/north/
  west/south = rel 0/1/2/3 (d4 order).
- **The fill generates the ring INLINE — it does NOT use the shared
  helper** `source_block_proximity_cells_state`: the helper sorts
  atan2 WITHOUT normalizing, so it puts south first — differing
  from Java (east first). New finding for a shared ring-geometry
  follow-through; the helper is NOT fixed (out of scope).
- **Team source:** world_tiles carries only {solid, wall_drop}, no
  team → team_map is caller-supplied ("x,y"→team, the N2459
  minimal-extension precedent); **presence of the key in team_map
  IS the building signal**. A ring tile becomes a neighbour only
  when: tile known (world_tiles entry) AND a building exists
  (team_map key) AND same team.
- **Accepts source:** accepts_map is caller-supplied ("x,y"→bool —
  the acceptItem(this, current) answer for the router's current
  item); a missing key → false (the N2324 pure's default). Live
  per-neighbour-type acceptItem evaluation waits for its own slice.
- **id** = the ring tile's "x,y" key (the port's cell_key format).
  The fill does not read the solid flag.
- **Dedup:** proven unnecessary for size 1 (no building occupies 2
  adjacent ring tiles without covering the router cell); multiblock
  dedup for size > 1 waits for the N2394 follow-through.

**Deviations from the brief (Java wins):**
1. The signature adds a `team` param (the brief had none): Java's
   updateProximity filters same-team (:1887) — without the router's
   team the fill cannot reproduce proximity membership; an enemy
   entry in the list would rotate cdump off Java (proven with an
   [ally, enemy] example).
2. Cite :51 → :52 (trailing `target = target();` is :52).
3. Documented deviation — ObjectSet order: Java funnels the
   proximity list through an ObjectSet (tmpTiles, :55), so its
   final order is hash order, not reproducible from coordinates;
   the port uses the deterministic Edges scan order (documented in
   the driver + entry).

## Commits

- Slice: `d89e6457d` (5 files, +1345/−3).
- Integration cherry-pick: `22b4f2ed3` (clean).

## Tests

Targeted (new module
`tests.test_c07_stack_router_live_proximity_query`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (7 StackRouter modules): Ran 28 (21
PASS + 7 proof Godot-absent), 0 errors. Proof numbers sim-verified
in Python (ring order, rel, target composition, live-tick 10-handoff
sequence) — all match the proof asserts.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12369/1885/1837/3466** (exactly as
estimated). DEFERRED **#210 REWRITTEN IN PLACE** (238→238, by entry
TEXT): the live proximity query is live since N2472; the handleItem
application waits for its own slice (cross-frame write).

## Godot debt

- NEW proof `C07StackRouterLiveProximityQueryProof` (6 keys:
  `query_ring_order`, `query_rel_values`, `query_team_gate`,
  `query_accepts_map`, `query_supplied_wins`, `query_live_tick`) —
  written but NEVER run; debt in GOAL.md §5. Live tick expects: 10
  copper handoffs alternating east/north, handed_to
  ["29,21","28,22"]×5, cdump 2.
- No old proof needs a re-run.
