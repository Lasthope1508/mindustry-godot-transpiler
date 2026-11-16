# Report N2380 — PayloadUnloader dump LIQUID neighbour write-back

**Slice:** N2380 — Unloader dump exposes the handled neighbour; the
tick writes the dumped liquid into the neighbour store (LIQUID half
only — the ITEM half is a later follow-through). **Wave:**
advances-20. **Commit:** `2b39a7bc0` on
`slice/N2380-unloader-dump-liquid-write-back` (base `7b99d3d63`).
**Files:** 5, +1019/−10.

## Source

Java: PayloadUnloader.java:105; BuildingComp.java:896 (proximity
get), :905 (amount dumped), :918-919 (`next.handleLiquid` /
`liquids.remove`); LiquidModule.java:81-83 (current), :24 (current
defaults to liquid 0).

## Implementation

The dump advance exposes `dump_neighbour_index` (from the routing
`handled_index`, −1 when nothing moved) + **`dumped_liquid_name`**
(String). **Key collision handled:** the old `dumped_liquid` key is
already the FLOAT amount dumped (BuildingComp.java:905) — its
meaning is untouched; the new name rides a separate key.

**Name resolution via a frame input, not a new param:** the store
is id-indexed (`{"liquids", "current", "flow"}`, no names) and the
catalog helper only returns `liquid_id_by_name` (name→id). The tick
builds `liquid_names_by_id` from `catalog.get_many("liquid")`
(index == id — the PayloadLoader precedent) and stamps
`frame["liquid_names_by_id"]` before the dump call; the pure
resolves `liquid_names_by_id[int(current)]` with a bounds check.
The name rides a frame input because the N2293 test pins the exact
tick call string + count==2 — changing the signature would break
the sibling. The name is set whenever a current liquid resolves,
even when nothing moved (the Fracker `dumped_liquid` precedent);
the tick only calls the helper when `dumped_liquid > 0` AND the
handled index is ≥ 0. The tick reads `dump_cell` inline from
`origin_cell` meta (the N2363 note); no new preload (the driver
already preloads SourceBuildingLiquidState).

## Commits

- Slice: `2b39a7bc0` (5 files, +1019/−10).
- Integration cherry-pick: `aa94b4570` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_unloader_dump_liquid_write_back`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Siblings:
Ran 40 — 30/30 non-proof PASS, 10 failures all Godot-absent proof
tests (8 Unloader modules + liquid-neighbour-write-back +
fracker-dump-liquid), 0 other errors.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12040/1807/1738/3268 (the two new
symbols; 6 N2293 symbols re-listed). Audit stays 1336. The
schema/contract fold landed later in N2384. DEFERRED **#258
REWRITTEN IN PLACE, count stays 311** (LIQUID half live since
N2380, ITEM half still waits — verified: exactly 1 entry changed).

## Godot debt

- NEW proof `C07PayloadUnloaderDumpLiquidWriteBackProof` (3 keys:
  `advance_exposes_dump_neighbour_index_and_liquid_name`,
  `live_tick_writes_dumped_liquid_to_neighbour_frame`,
  `live_tick_dumped_liquid_leaves_unloader_without_frame`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the Unloader ITEM write-back (`dump_item_state`
  already returns `handled_index`; wiring through the N2353 helper
  needs its own slice, like N2368/N2369).
