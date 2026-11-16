# Report N2411 — SolidPump dump neighbour live fill

**Slice:** N2411 — SolidPump `dumpLiquid` neighbour live fill:
a new fill scans the proximity ring live before the dump and
fills the 4 neighbour arrays in ring order, so `dumpLiquid`
no longer needs hand-seeded neighbour frames. **Wave:**
advances-24. **Commit:** `331d8bd47` on
`slice/N2411-solid-pump-dump-neighbour-live-fill` (base
`a0e246e1f`). **Files:** 5, +1210/−7.

## Source

Java: BuildingComp.java:896-905 (liquid proximity), :868-870
(acceptLiquid), :910-912 (canDumpLiquid); SolidPump.java:
901-905 (full guard shape); Blocks.java:2922 (result liquid
water). The N2286 pure takes the neighbour arrays as explicit
frame inputs (default []) and the tick supplies the frame
as-is.

## Implementation

New pure
`source_solid_pump_dump_neighbour_live_fill_state(game, cell,
size, result_liquid_id)` (after the tick function) — mirror of
the N2408 Fracker fill's def-result logic + the N2394 liquid
half's 4-array shape: fills
`dump_neighbour_liquid_amounts / capacities / accepts_liquid /
can_dump_liquid` in ring order. Amount from the neighbour frame
liquids module for the result id; capacity from the neighbour
def `liquidCapacity` (10.0 port default, 0.0 when no store);
accepts/canDump from the DEFAULT gates (acceptLiquid =
hasLiquids && consumesLiquid; canDumpLiquid defaults true).
No-frame outcome 0.0 / 0.0 / false / false. Conduits reported
no-frame. Frame-key list via runtime `load()` of
`SourcePlacedPowerGraphState` (N2371/BeamDrill precedent, no
new preload).

Tick wiring BEFORE the dump reads (old :642–645): supplied
arrays win (fill runs only when none of the 4 keys present, or
`dump_neighbour_live` refresh), origin cell read inline as
`fill_cell` (N2363 — cell bound after the enabled block,
mirroring the N2377 write-back), catalog size +
`advance_result_id` (water, Blocks.java:2922).

**Verify-first:** N2286 pure takes 4 parallel arrays, derives
has_liquids from capacity > 0; N2371 resolution path mirrored;
catalog verified from `content_registry.json` — cryofluid-mixer
consumes water (hasLiquids, 36f), plastanium-compressor
consumes oil (hasLiquids, 60f), electrolyzer consumes water
with NO hasLiquids key (size 3), melter no consumeLiquid row;
30-def hasLiquids gap NOT fixed (Java default false). Size-2
ring simulated + cross-checked against the N2377 pin (ring 0 =
(28,19)); proof footprints recomputed with `footprint_offset`
(size 3 → −1) and checked pairwise disjoint.

## Commits

- Slice: `331d8bd47` (5 files, +1210/−7).
- Integration cherry-pick: `5af70b9cf` (clean).

## Tests

Targeted (new module
`tests.test_c07_solid_pump_dump_neighbour_live_fill`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15).
Full gate (wave advances-24 integration, PID 1736, from 16:29): Ran 6651 tests in 1446.605s, FAILED (failures=338, skipped=5), 0 errors — 338/338 Godot-absent (333 inherited + 5 new proof tests N2410, N2411, N2412, N2414, N2415; N2409/N2413 add no proof test). Gate run 1 (PID 21111, from 16:13) was killed by VM restart #13 ~16:29 after ~16 min (no footer); javalang reinstalled, gate re-run.

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12112/1833/1765/3322
(exactly as estimated). Audit stays 1336. DEFERRED **#230
RESOLVED** (291→290, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07SolidPumpDumpNeighbourLiveFillProof` (6 keys:
  `fill_liquid_arrays_from_live_neighbours`,
  `fill_accepts_gate_requires_has_liquids`,
  `fill_accepts_gate_requires_consumes_liquid`,
  `fill_capacity_from_live_neighbour`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (pump 20→5 water, mixer
  0→15, cdump 0, `dump_neighbour_live` true)) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (N2286/N2377 proofs seed the 4
  arrays by hand → supplied-wins protects them; the N2292
  FractionFill live tick now runs the fill but places no
  neighbours → 8 no-frame entries, dump moves nothing, its
  pins unaffected).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) the catalog `hasLiquids` gap (30 defs); (3)
  ring dedup + team filter.
