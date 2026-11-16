# Report N2377 — SolidPump dumpLiquid neighbour write-back

**Slice:** N2377 — SolidPump dump exposes the handled neighbour; the
tick writes the dumped water into the neighbour store. **Wave:**
advances-20. **Commit:** `b5cd8a13a` on
`slice/N2377-solid-pump-dump-liquid-write-back` (base `7b99d3d63`).
**Files:** 5, +913/−9.

## Source

Java: SolidPump.java:140 (`dumpLiquid(result);`); BuildingComp.java:896
(proximity get), :902 (ofract), :918-919 (`next.handleLiquid` /
`liquids.remove`); Blocks.java:2922 (`result = Liquids.water;`).

## Implementation

The dump advance exposes `dump_neighbour_index` (from the shared
routing `handled_index`, −1 when nothing moved) + `dumped_liquid`
(the def constant `"water"`). `dumped_amount` already existed, so no
duplicate key. The pure has a single return path, so one dict carries
both new keys. The tick wires the shared N2371 helper
`source_neighbour_liquid_write_back_state` after the dump write-back
when `dumped_amount > 0` and the index is ≥ 0, reading `origin_cell`
inline as `dump_cell` (the `cell` local binds after the enabled block
— the N2363 note), catalog size. A failed write-back drops the water
with no fallback to the pump (the N2353 precedent). The driver doc
limits now read "neighbour write-back live since N2377".

## Commits

- Slice: `b5cd8a13a` (5 files, +913/−9).
- Integration cherry-pick: `21173d296` (clean).

## Tests

Targeted (new module
`tests.test_c07_solid_pump_dump_liquid_write_back`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Siblings: 7 modules
(SolidPump dump/update/fraction/power/should-consume, N2371 liquid
write-back, Fracker dump), each Ran 4 with only its own proof failing
Godot-absent, 0 other errors.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12040/1807/1738/3268 (the two new
symbols; 3 N2286 symbols re-listed per the N2321 precedent). Audit
stays 1336. The schema/contract fold landed later in N2384.
DEFERRED **311 → 310** (resolves #244, by entry TEXT from the merged
base; live fill #243, campaign unlock #245, updateEffect #137, and
the follow-ups entry #308 stay).

## Godot debt

- NEW proof `C07SolidPumpDumpLiquidWriteBackProof` (3 keys:
  `advance_exposes_dump_neighbour_index`,
  `live_tick_writes_dumped_liquid_to_neighbour_frame`,
  `live_tick_dumped_liquid_leaves_pump_without_frame`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- FLAG from this slice (fixed by N2385): the N2371 proof pins
  `cursor_after == 1` for its 1-neighbour cases, but the shared
  routing + full-cycle invariant give 0 — a latent error, since
  the N2371 proof never ran.
