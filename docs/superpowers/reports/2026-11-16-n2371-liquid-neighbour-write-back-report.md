# Report N2371 — Liquid neighbour write-back helper + Fracker dumpLiquid wiring

**Slice:** N2371 — The shared liquid neighbour write-back helper
(mirror of the N2353 item helper), the shared routing reporting
`handled_index`, and the Fracker dumpLiquid wiring. **Wave:**
advances-19. **Commit:** `c10447a62` on
`slice/N2371-liquid-neighbour-write-back` (base `46b1b951b`).
**Files:** 10, +1375/−15.

## Source

Java: BuildingComp.java:872-874 (handleLiquid = `liquids.add`),
:877/:881/:886 (dumpLiquid), :896 (proximity get), :905 (transfer
scale), :915-917 (flow computed BEFORE the accept guard), :918
(`next.handleLiquid(self(), liquid, flow)`); Fracker.java:42
(`dumpLiquid(result);`); Blocks.java:2966 (`result = Liquids.oil;`),
:2322/2329/2337/2410 (four Conduit-class defs). 17 exact exprs, all
verified verbatim.

## Implementation

Three parts, N2353 pattern:
- (a) Helper `source_neighbour_liquid_write_back_state(game, cell,
  size, neighbour_index, liquid, amount)` on SourceBuildingLiquidState
  → {written, reason, neighbour_cell}. Frame neighbour → frame liquids
  via shared `source_add_state` + set_meta (N2142 precedent); conduit
  neighbour → sprite-meta LiquidModule. Guards: invalid_amount /
  invalid_liquid / invalid_index / unknown_liquid / no_sprite /
  no_frame / no_liquids_store.
- (b) Shared routing `dump_liquid_state` returns `handled_index`
  (first eligible index whose transfer actually moved liquid, −1 when
  nothing moved); the owning register
  `register_building_liquid_dump_slice.py` was updated (contract
  return_keys + result schema only, NOT the symbol loop — the N2367
  lesson).
- (c) Fracker advance exposes `dump_neighbour_index` + `dumped_liquid`
  (\"oil\", both return paths); the tick wires the helper after the
  dump write-back when `dumped_amount > 0` (origin_cell read inline
  as `dump_cell`, catalog size — the N2363 note).

⚠️ SCOPE CORRECTIONS (all verified in code): (1) Conduit has NO queue
— the brief's belt analogy is wrong; Conduit never overrides
handleLiquid, so the default `liquids.add` lands in its LiquidModule
on the sprite `source_building_liquids` meta (N2090 precedent). (2)
FOUR Conduit-class defs, not three (conduit / pulse-conduit /
plated-conduit / reinforced-conduit); detection is frame-meta OR block
id. (3) `handled_index` needs handle AND flow: a refusing neighbour
still computes flow (flow is computed before the accept guard,
:915–917), and a full neighbour handles a zero flow — handled =
`handle_liquid_called AND flow_value > 0`. (4) Preload cycles
(transitive closure): the frame-key list comes from runtime `load()`
(BeamDrill precedent) and the conduit key is a local const. (5)
Multi-recipient: a dump reaching several neighbours reports only the
FIRST handled index, so the Fracker write-back lands the total there
— documented deviation, split deferred.

The worker also fixed 2 sibling tests the slice broke (N2284
exact-return 5-key assertion; the cite-sweep pin, frame-sync line
623→633).

## Commits

- Slice: `c10447a62` (10 files, +1375/−15).
- Integration cherry-pick: `440d9ed3c` (clean).

## Tests

Targeted (new module `tests.test_c07_liquid_neighbour_write_back`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
17/17. Siblings: Fracker family (dump_liquid, fraction_fill,
liquid_row, power_status, should_consume, update_tile, item_row),
pump/solid-pump dump, N2353, N2363 — all 3/4 with only their Godot
proofs failing; `test_building_unit_payload_slice` 12/12 OK; 2 audit
tests OK, 0 other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12024/1800/1730/3252, exactly as
estimated (6 symbols: helper written/reason/neighbour_cell + Fracker
dump_neighbour_index/dumped_liquid + routing
`building_dump_liquid.handled_index`; new helper contract + input /
result schemas). Audit stays 1336. The Fracker schema/contract fold
landed later in N2376. DEFERRED **319 → 319** (the register base was
the stale N2363 list at 319, not the merged 316 — the coordinator
merged by entry TEXT; −1 Fracker write-back standalone + 1 new
liquid follow-ups entry).

## Godot debt

- NEW proof `C07LiquidNeighbourWriteBackProof` (7 keys:
  `write_back_frame_neighbour_lands_liquid`,
  `write_back_conduit_neighbour_lands_liquid`,
  `write_back_no_frame_reports_no_frame`,
  `write_back_no_sprite_reports_no_sprite`,
  `advance_exposes_dump_neighbour_index`,
  `live_tick_writes_dumped_liquid_to_neighbour_frame`,
  `live_tick_dumped_liquid_leaves_fracker_without_frame`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: Pump dump (#257), SolidPump dump (#260),
  LiquidBridge doDump (#263), PayloadUnloader dump (#276) wire the
  helper with their routed index exactly like the Fracker (the routing
  already reports `handled_index` for all of them); then the
  multi-recipient per-neighbour split, and a core store mapping (core
  neighbours still drop with `no_frame`).
