# Report N2408 — Fracker dumpLiquid neighbour live fill

**Slice:** N2408 — Fracker `dumpLiquid` neighbour live fill: a
new fill scans the proximity ring live before the dump and
builds one neighbour dict per ring cell in the exact N2284
shape, so `dumpLiquid` no longer needs hand-seeded neighbour
entries. **Wave:** advances-23. **Commit:** `fa77277fb` on
`slice/N2408-fracker-dump-liquid-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1232/−7.

## Source

Java: BuildingComp.java:896-905 (`Building other =
proximity.get((i + dump) % proximity.size);`), :868-870
(acceptLiquid), :910-912 (canDumpLiquid), :980-982; Block
:778-779; Fracker :42; Blocks :2966/:2971. The N2284 dump takes
the neighbour entries as an explicit frame input
(`frame["dump_liquid_neighbours"]`, default []) and the tick
supplies the frame as-is. The fill mirrors the N2371 resolution
path (ring → `block_sprite_at_cell` → first
`SOURCE_CONSUMER_FRAME_META_KEYS` frame; liquids module under
`frame["liquids"]`).

## Implementation

New pure
`source_fracker_dump_liquid_neighbour_live_fill_state(game,
cell, size, result_liquid_id)` — scans the live proximity in
ring order and builds one neighbour dict per ring cell in the
exact N2284 shape (amount / capacity / accepts / has_liquids /
can_dump / liquids_present / destination_present /
relative_to), with amount/capacity from the neighbour liquids
module + def `liquidCapacity`, accepts/canDump from the DEFAULT
gates (acceptLiquid = hasLiquids && consumesLiquid oil;
canDumpLiquid = true). The tick wires the fill BEFORE the N2284
dump reads `frame["dump_liquid_neighbours"]`, same enabled
block, origin cell inline (N2363 note). Supplied arrays win
(N2381 precedent); a live-filled frame refreshes every tick via
`dump_liquid_neighbours_live`.

**Pin note:** the cite-sweep test pins the frame-sync at driver
line 633, so the fill pure lives AFTER the tick function and the
frame-key list comes from a runtime `load()` (N2371 precedent),
not a preload — the direct preload is cycle-free (105-file
power-graph closure excludes this driver) but the pin rules it
out.

**Catalog gap (noted, NOT fixed):** 30 defs (e.g.
electrolyzer, advanced-launch-pad) have consumeLiquid rows but
no `hasLiquids` key, read as Java default false. Oil consumers
are plastanium-compressor + coal-centrifuge (hasLiquids true)
and advanced-launch-pad (no hasLiquids key).

## Commits

- Slice: `fa77277fb` (5 files, +1232/−7).
- Integration cherry-pick: `f15381827` (clean).

## Tests

Targeted (new module
`tests.test_c07_fracker_dump_liquid_neighbour_live_fill`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15).
Neighbour checks: N2284 dump test 3/4 + cite-sweep line-633 pin
+ N2371 write-back test 3/4 all pass (only their pre-existing
Godot proofs fail Godot-absent).
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 12096/1826/1758/3308
(brief estimated +2 symbols, but the fill returns a single
result key — the register decides). Audit stays 1336. DEFERRED
**#230 RESOLVED** (298→297, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07FrackerDumpLiquidNeighbourLiveFillProof` (6
  keys: `fill_liquid_entries_from_live_neighbours`,
  `fill_accepts_gate_requires_has_liquids`,
  `fill_accepts_gate_requires_consumes_liquid`,
  `fill_capacity_from_live_neighbour`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: 20 oil → 5,
  compressor takes 15 — 10 at ring 5 + 5 at ring 6 — cdump
  wraps to 0, `dump_liquid_neighbours_live` true)) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (supplied entries win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) the catalog `hasLiquids` gap (30 defs); (3)
  ring dedup + team filter (shared ring-geometry slice).
