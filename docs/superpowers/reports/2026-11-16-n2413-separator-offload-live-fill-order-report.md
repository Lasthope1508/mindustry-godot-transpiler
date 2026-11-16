# Report N2413 — Separator offload one-tick lag fix

**Slice:** N2413 — wiring fix: hoist the N2402 live fill
before the offload routing-context build so the Separator
offload reads the CURRENT tick's live-filled arrays instead of
the previous tick's. **Wave:** advances-24. **Commit:**
`ed3d99a32` on `slice/N2413-separator-offload-live-fill-order`
(base `a0e246e1f`). **Files:** 2, +147/−29.

## Source

Java order: offload (:160-161) before dump (:165-166)
(Separator.java); offload reads `this.cdump`
(BuildingComp.java:1003). In the driver the tick built the
offload routing context at :972 (from frame
`dump_neighbour_accepts` / `dump_neighbour_can_dump`) and ran
the updateTile advance at :973 — but `content_item_ids` was
only bound at :1026 and the N2402 live fill ran at :1045,
AFTER the advance. The lag was documented in the driver
comment (:963-968).

## Implementation

`content_item_ids` binding + the N2402 fill block (incl.
supplied-arrays-win guard) hoisted to before the offload
routing-context build; driver comments updated (:963–968 lag
text replaced with the new order + the judgment call: offload
uses the fill's first-held-item accepts, per-item routing for
the picked item waits for the per-item dump routing slice).
Fill still runs exactly once per tick (count pin = 2:
definition + one call site); timerDump reads the same frame
keys afterwards. No new pure, no new symbols.

**Live tick N2402 — NO CHANGE, no proof edit, no re-run.**
Trace evidence: the proof seeds progress 0.0 (bind default;
proof comment states "progress 0.0 so the advance crafts
nothing"); craft_time 35, source_delta 1 tick, efficiency 1.0
→ advance adds 1/35 ≈ 0.0286 < 1.0, so the `progress >= 1.0`
craft branch never runs, no pick, offload never runs —
regardless of fill order. The advance also touches nothing
else the timerDump reads (no craft → no consume, items/cdump
unchanged), and the fill still runs once before the timerDump
reads, so the live-tick expectations stand verbatim: progress
1/35, scrap 5→4, melter +1, cdump 0→1, clock 4+1→0.
N2343/N2281/N2361 proofs verified unaffected: all three seed
both arrays by hand, so the supplied-arrays-win guard skips
the fill either way. Proof file
`C07SeparatorDumpNeighbourLiveFillProof.gd` untouched.

**Pin test:** RED before the fix (failed at
`content_item_ids` bound after the routing call), GREEN after
— `test_separator_offload_live_fill_order_pins` PASS. No
Godot proof test in this module (N2382/N2355 precedent).
Family check: 17 tests across N2413 + N2402 + N2343 + N2281 +
N2361 modules — 13 pass, the only 4 failures are the
Godot-absent proof tests. One fix during GREEN: the comment
phrase spanned a line break, reworded to keep `live fill lands
BEFORE the advance (N2413)` on one line (N2148 lesson).

## Commits

- Slice: `ed3d99a32` (2 files, +147/−29).
- Integration cherry-pick: `d3daa99be` (clean).

## Tests

Targeted (new module
`tests.test_c07_separator_offload_live_fill_order`): pin test
PASS (no Godot proof test in this module).
Full gate (wave advances-24 integration, PID 1736, from 16:29): Ran 6651 tests in 1446.605s, FAILED (failures=338, skipped=5), 0 errors — 338/338 Godot-absent (333 inherited + 5 new proof tests N2410, N2411, N2412, N2414, N2415; N2409/N2413 add no proof test). Gate run 1 (PID 21111, from 16:13) was killed by VM restart #13 ~16:29 after ~16 min (no footer); javalang reinstalled, gate re-run.

## SSOT / DEFERRED

SSOT **+0/+0/+0/+0** (the N2302/N2303 fix-slice precedent —
wiring fix, no ledger entry). Re-ran the N2402 register: exit
0, `generated/` untouched; totals 12108/1832/1764/3320, audit
1336 — identical to the advances-23 integration baseline.
DEFERRED unchanged.

## Godot debt

- No new proof. No re-run (the N2402 live tick is unchanged —
  see the trace above).
