# Report N2394 — PayloadUnloader dump neighbour live fill

**Slice:** N2394 — PayloadUnloader `dump()` neighbour live fill: a
new fill scans the proximity ring live before the dump pure and
fills all 6 neighbour arrays (items / liquids / accepts / canDump)
in ring order, so `dump()` no longer needs hand-seeded neighbour
frames. **Wave:** advances-22. **Commit:** `2ab1b8a54` on
`slice/N2394-unloader-dump-neighbour-live-fill` (base `78a74e152`).
**Files:** 5, +1306/−4.

## Source

Java: BuildingComp.java:864-866 (`acceptItem` REQUIRES
`consumesItem`), :868-870 (`acceptLiquid`), :910-912
(`canDumpLiquid`), :1124-1126 (`canDump`); the dump pure reads
neighbour arrays it never filled (N2279 pattern). The fill mirrors
the resolve path of N2353/N2371 (game + cell + size + index →
ring cell → `block_sprite_at_cell` → first frame); neighbour def
via sprite `SOURCE_BLOCK_ID_META_KEY` → catalog `blocks_by_id`
(the N2381 precedent).

## Implementation

New pure `source_payload_unloader_dump_neighbour_live_fill_state`
— scans the proximity ring live before the dump pure and fills
all 6 neighbour arrays in ring order (index i = ring cell i, the
N2353 convention). Liquid amounts/capacities come from the
neighbour frame liquids modules; items from `frame["items"]`.
Accepts/canDump use ONLY the default BuildingComp gates
(`acceptItem` :864-866, `acceptLiquid` :868-870, `canDumpLiquid`
:910-912, `canDump` :1124-1126). The tick wires the fill before
the dump reads (after the `liquid_names_by_id` stamp); supplied
arrays win (the N2381 precedent) + a `dump_neighbour_live` flag
— proofs N2293/N2380/N2386 seed by hand and are unaffected.

**Judgment calls (all documented):** accepts-item collapses to
the FIRST held item by content order (the item pure offer);
no-frame = 0.0/0.0/false×4 (the N2353/N2371 precedent), a conduit
counts as no-frame; per-block overrides are OUT of scope — every
neighbour is judged by the default gate; the ring is NOT deduped
for multi-cell neighbours and has NO team filter (mirrors
N2353/N2371 — awaits a shared ring-geometry slice; the proof
pins the multi-press at both ring 5 and ring 6).

**Catalog gap (noted, NOT fixed):** 30 defs have consumeLiquid
rows but lack the `hasLiquids` key (e.g. electrolyzer) — the fill
uses the Java field default false. A catalog fix is a separate
slice.

## Commits

- Slice: `2ab1b8a54` (5 files, +1306/−4).
- Integration cherry-pick: `0f2639579` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_unloader_dump_neighbour_live_fill`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12074/1820/1750/3292 (the
N2279 pattern — contract + input/result schemas; the first
register run missed the upsert → +6/+1/+0/+0, fixed before the
final run). Audit stays 1336. DEFERRED **#248 RESOLVED**
(301→300, by entry TEXT; no new entry — the override-dispatch
follow-through is only a note).

## Godot debt

- NEW proof `C07PayloadUnloaderDumpNeighbourLiveFillProof` (6 keys:
  `fill_liquid_arrays_from_live_neighbour`,
  `fill_item_arrays_from_live_neighbour`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: 4 coal + 37.5 water
  → multi-press, cdump 7, dump_accum 0.9, dump_neighbour_live
  true)) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch for acceptItem/canDump (e.g. Separator canDump,
  StorageBlock open-item accept — with default gates only, the
  unloader CANNOT dump into vault/container/core); (2) per-item
  dump routing (Java try-later-items); (3) ring dedup + same-team
  filter; (4) the catalog `hasLiquids` gap (30 defs).
