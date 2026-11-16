# Report N2381 — UAM live flagged-buildings index fill

**Slice:** N2381 — the UAM tick fills `link_candidates` from a live
team-wide flagged scan, so getLink discovery works on live frames.
**Wave:** advances-20. **Commit:** `05ddb523b` on
`slice/N2381-uam-flagged-buildings-fill` (base `7b99d3d63`).
**Files:** 5, +1117/−14.

## Source

Java: UnitAssemblerModule.java:66 (`flags =
EnumSet.of(BlockFlag.unitAssembler)`); UnitAssembler.java:338-351
(moduleFits); BlockIndexer.java:599 (append-on-index order);
UnitAssemblerModule.java:65-69 (getLink).

## Implementation

New pure `source_unit_assembler_module_flagged_candidates_state(
buildings, team_id)` filters tick-gathered placed buildings to
same-team UnitAssembler builds and emits N2358 descriptors
(`{"block", "cell", "rotation", "size", "area_size", "x", "y"}`).
The tick fills `frame["link_candidates"]` from the live scan (the
N2277 `placed_blocks` precedent, gathered once per tick) before the
N2358 discovery + N2370 stamp.

**Scope corrections (all verified at this pin):**
- **Flag lookup = implementation check:** `flags` is set class-wide
  in the UnitAssembler constructor (:66), so all 3 defs carry it;
  no UnitAssembler subclass exists; the catalog carries no flags
  key.
- **Supplied wins — EXTENDED:** the fill must ALSO skip a frame
  seeding `link_candidate` directly. N2358 module-three, N2370,
  N2351, N2248, N2299, N2314 all seed it and run the live tick;
  N2351's modules sit far from the placed assembler, so a naive
  fill would let discovery overwrite the seed with null and break
  the `[1, 1]` wiring expectation. The fill runs only when the
  frame has NEITHER `link_candidates` NOR `link_candidate`.
- **Live-refresh marker:** stamped frames carry
  `link_candidates_live` (port bookkeeping, the `frame["rotation"]`
  precedent) and re-scan every tick — without it the first fill
  would go stale forever since the frame persists. An empty scan
  on a fresh frame stamps nothing (preserves seeded candidates;
  fresh frames read link null from the advance default); on a
  live-filled frame it clears the stale list.
- **area_size = 13** def constant (all 3 defs, Blocks.java:6529/
  6544/6559; the catalog has no areaSize key, the N2348 precedent);
  the pure defaults to the class default 11 when absent.
  Descriptor x/y via `tile_drawx/y_state` + Block offset + Java
  tilesize 8 (not game 32 — the N2364/N2375 lesson); rotation from
  sprite meta; order = placed_blocks insertion order, matching
  Java append-on-index.

## Commits

- Slice: `05ddb523b` (5 files, +1117/−14).
- Integration cherry-pick: `acd07f5fd` (clean).

## Tests

Targeted (new module
`tests.test_c07_unit_assembler_module_flagged_buildings_fill`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15).
Siblings: 9 UAM modules Ran 36 — 27 non-proof PASS, 9 failures
all the Godot proof tests, 0 other errors.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12041/1807/1739/3270 (3 symbols:
`..._flagged_candidates_state_result.{candidates, checked,
matched}`). Audit stays 1336. No shard pickup (java_source
UnitAssemblerModule.java matches no shard selection). DEFERRED
**311 → 310** (−1: #304 resolved; #305 link/findLink + #307
updateTile live fill rewritten in place as LIVE since N2381).

## Godot debt

- NEW proof `C07UnitAssemblerModuleFlaggedBuildingsFillProof`
  (13 keys: 6 pure — same-team only, descriptor format, default
  area_size 11, malformed skip, empty list, input order — + 7
  live-tick — no-assembler null, fills 2 descriptors, discovery
  links the fit, no-fit null, supplied-wins, seeded-kept,
  refresh adds 3rd assembler) — written but NEVER run; debt in
  GOAL.md §5. Reuses the N2358 fit geometry (tank (28,20) /
  module (28,26), dst 48).
- **Re-run candidates (no §5 entry — verified by construction):**
  the N2358/N2370/N2351 proofs run the changed tick path, but
  seeded frames never fill (the fill skips frames carrying
  `link_candidates` or `link_candidate`), so they should stay
  green. The Godot side may re-run them as a smoke check.
