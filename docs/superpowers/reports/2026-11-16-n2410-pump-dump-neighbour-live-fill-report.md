# Report N2410 — Pump dump neighbour live fill

**Slice:** N2410 — Pump `dumpLiquid` neighbour live fill: a
new fill scans the proximity ring live before the dump and
fills the 4 neighbour arrays in ring order, so `dumpLiquid`
no longer needs hand-seeded neighbour frames. **Wave:**
advances-24. **Commit:** `f8374d855` on
`slice/N2410-pump-dump-neighbour-live-fill` (base `a0e246e1f`).
**Files:** 5, +1301/−3.

## Source

Java: BuildingComp.java:868-870 (acceptLiquid), :896/:901-905
(liquid proximity), :910-912 (canDumpLiquid), :980-982; Block
:778-779; Pump.java:114/:140/:160/:178-179; Blocks.java:2308
(80f) / :2310 (size 2). The N2285 pure takes the neighbour
arrays as explicit frame inputs (default []) and the tick
supplies the frame as-is. The driver is
`SourceMechanicalPumpBuildState.gd` (`SourcePumpBuildState.gd`
does not exist — confirmed).

## Implementation

New pure
`source_mechanical_pump_dump_neighbour_live_fill_state(game,
cell, size, liquid_drop, liquid_id_by_name)` (after the tick
function, N2408 placement) — mirror of the N2394 liquid half +
N2408 Fracker fill: ring from
`source_block_proximity_cells_state`, sprite via
`block_sprite_at_cell`, frame via first
`SOURCE_CONSUMER_FRAME_META_KEYS` meta (runtime `load` of
`SourcePlacedPowerGraphState`, N2371/BeamDrill/N2408 precedent
— no preload added), amounts from the neighbour liquids
module, capacities from the neighbour def `liquidCapacity`
(10.0 port default, 0.0 with no store), accepts/canDump from
the DEFAULT gates (acceptLiquid = hasLiquids && consumesLiquid;
canDumpLiquid default true). No-frame outcome 0.0/0.0/false/
false; conduit is no-frame (Conduit.java:242-244 override, out
of scope).

**Liquid input choice (brief asked):** takes the NAME
(`liquid_drop: Variant`) + `liquid_id_by_name`, mirroring the
N2285 dump pure — the consumeLiquid rows match on the NAME,
and the amount read resolves the id through the same map;
resolving to an id first would lose the name the row match
needs (the tick carries no reverse map). Null drop → no
accepts, no amounts; capacities still fill (N2394 precedent).

Tick wiring BEFORE the :574–577 reads, inside the enabled
block: `proximity`, `cell`, `block`, `liquid_id_by_name` all
verified in scope (no N2363 workaround needed). Supplied
arrays win (N2381 precedent — the N2285/N2378 proofs seed all
4 arrays by hand) + `dump_neighbour_live` refresh flag.

**Note (documented, no pure change):** the N2285 dump pure's
hardcoded `other_has_liquids`/`liquids_present` true now
covers rejecting neighbours too, but routing stays correct via
the accepts gate.

**Verify-first:** size-2 ring computed and cross-checked
against the N2371/N2378 pin (ring 0 = (28,19)). Proof defs
verified in the catalog: cryofluid-mixer (water, hasLiquids,
36f), plastanium-compressor (oil, hasLiquids, 60f),
electrolyzer (water, 50f, NO hasLiquids key — confirmed it
still gets a liquids store via `record_placed_block`
hydration, so the capacity/gate contrast is real), melter (no
consumeLiquid rows). No null/non-list consumeLiquid values
anywhere. **Catalog gap (NOT fixed):** 30 defs carry
consumeLiquid rows but lack `hasLiquids` — the fill reads the
Java field default false (N2394 precedent).

## Commits

- Slice: `f8374d855` (5 files, +1301/−3).
- Integration cherry-pick: `e354b6212` (clean).

## Tests

Targeted (new module
`tests.test_c07_pump_dump_neighbour_live_fill`): 3/4 PASS
(registration, exact-evidence 18/18, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Siblings (6 pump
modules) Ran 23 → only their 6 proof tests fail, 0 other
errors. One self-caught fix during GREEN: the asserted string
`live-filled since N2410` was split across comment lines
(N2148 lesson) — fixed to a single line.
Full gate (wave advances-24 integration, PID 1736, from 16:29): Ran 6651 tests in 1446.605s, FAILED (failures=338, skipped=5), 0 errors — 338/338 Godot-absent (333 inherited + 5 new proof tests N2410, N2411, N2412, N2414, N2415; N2409/N2413 add no proof test). Gate run 1 (PID 21111, from 16:13) was killed by VM restart #13 ~16:29 after ~16 min (no footer); javalang reinstalled, gate re-run.

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12112/1833/1765/3322
(exactly as estimated; 4 new result symbols — the 4 arrays).
Audit stays 1336. DEFERRED **#228 RESOLVED** (291→290, by
entry TEXT; no new entry).

## Godot debt

- NEW proof `C07PumpDumpNeighbourLiveFillProof` (6 keys:
  `fill_liquid_arrays_from_live_neighbours`,
  `fill_accepts_gate_requires_has_liquids`,
  `fill_accepts_gate_requires_consumes_liquid`,
  `fill_capacity_from_live_neighbour`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (rotary-pump at (28,20) on
  shallow water, no seeded arrays: 0.4 pumped → 0.2 dumped to
  the cryofluid-mixer at ring 3, cdump wraps 0,
  `dump_neighbour_live` stamped)) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) the catalog `hasLiquids` gap (30 defs); (3)
  ring dedup + team filter.
