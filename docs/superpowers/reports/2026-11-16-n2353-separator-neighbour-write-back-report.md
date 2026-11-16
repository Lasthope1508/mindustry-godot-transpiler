# Report N2353 — Separator offload neighbour write-back

**Slice:** N2353 — Neighbour item write-back helper + Separator offload wiring
(DEFERRED #322). **Wave:** advances-17. **Commit:** `77454fd69` on
`slice/N2353-neighbour-write-back-separator` (base `9282b27a`). **Files:** 6,
+1160/−11.

## Source

Java: BuildingComp.java:1001-1017 (offload/dump path), :1009. Separator
offload runs BEFORE dump (Java order). 14 exact exprs, all verified verbatim.

## Implementation

New shared helper `source_neighbour_item_write_back_state` on
SourceBuildingItemState: writes an offloaded item into the neighbour's frame
(a belt neighbour queues the item via the conveyor queue meta key; a
neighbour with no frame reports `no_frame`; no sprite reports `no_sprite`).
The Separator advance now exposes `offload_neighbour_index` /
`offload_routed` (unregistered API shape, the N2343 precedent — a
schema-sync slice later folds them into the advance result schema), and the
tick wires the helper after the advance. Index↔ring convention: index i =
ring cell i — live-fill slices must fill `dump_neighbour_*` in ring order.
Belt vs building is distinguished by the conveyor queue meta key (checked
first); meta-key coverage is 41 keys, enough for every family with a tick
frame (core/conduit/wall → no_frame).

## Commits

- Slice: `77454fd69` (6 files, +1160/−11).
- Integration cherry-pick: `087be8080` (clean).

## Tests

Targeted (new module `tests.test_c07_separator_neighbour_write_back`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 14/14. Siblings
7 modules Ran 28 (21 PASS + 7 proof Godot-absent), 0 other errors.
Full gate (wave advances-17 integration, PID 12882, 10:58–11:23): Ran
6468 tests in 1457.080s, FAILED (failures=293, skipped=5), 0 errors —
293/293 Godot-absent `AssertionError: unexpectedly None` (287 inherited +
6 new proof tests N2351–N2354, N2356–N2357; N2355 has no proof test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 11987/1789/1721/3234 (brief est +1
symbols low — the helper returns 3 keys). Audit stays 1336.
DEFERRED **326 → 326 (−1+1)**: resolved #322, +1 new entry (write-back
follow-ups #251/#248/#238/#266/#269/#279 + liquid helper
#254/#257/#260/#263/#276).

## Godot debt

- NEW proof `C07SeparatorNeighbourWriteBackProof` (7 keys:
  `advance_exposes_routed_neighbour_index`,
  `live_tick_routed_item_leaves_separator_without_frame`,
  `live_tick_writes_offloaded_item_to_neighbour_frame`,
  `write_back_belt_neighbour_queues_item`,
  `write_back_frame_neighbour_lands_item`,
  `write_back_no_frame_reports_no_frame`,
  `write_back_no_sprite_reports_no_sprite`) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run.
- Backlog: (a) schema-sync slice to fold `offload_neighbour_index` /
  `offload_routed` into the Separator advance result schema; (b) the other
  write-backs (#251/#248/#238/#266/#269/#279 + liquid helper
  #254/#257/#260/#263/#276) follow the N2353 helper in later waves.
