# Report N2459 — WallCrafter getEfficiency live edge-tile scan

**Slice:** N2459 — WallCrafter getEfficiency() live edge-tile
scan: one live-fill pure + tick wiring stamps
frame["wall_edge_tiles"] from the world tiles before the N2301
recompute. **Wave:** advances-30. **Commit:** `b03fbca6f` on
`slice/N2459-wall-crafter-edge-tiles-live-fill` (base `4e4dc1a7c`).
**Files:** 5, +1113/−2.

## Source

getEfficiency() (WallCrafter.java:141-180): cornerX = tx −
(size−1)/2, cornerY = ty − (size−1)/2 (INTEGER division), s = size;
for i = 0..size−1: rotation 0 → (cornerX+s, cornerY+i); 1 →
(cornerX+i, cornerY+s); 2 → (cornerX−1, cornerY+i); 3 →
(cornerX+i, cornerY−1). cpos callback (:167-169, the draw-rotator
callback — NOT ported, N2426 already takes facing tiles
caller-supplied). Tile other = world.tile(rx, ry) (:171); if other
!= null && other.solid() (:172): at = other.block().attributes.get(
attribute) (:173); eff += at; ctile if at > 0 (:174-176, the
highlight callback — NOT ported). `attribute = Attribute.sand`
(:41; Blocks.java:3008/:3022); sizes 2/3 (Blocks.java:3007/:3021).

## Implementation

One live-fill pure (the N2394/N2414 pattern) + tick wiring:
`source_wall_crafter_edge_tiles_live_fill_state(world_tiles,
wall_attribute_by_tile, cell, size, rotation)` →
`{wall_edge_tiles}` — Java-exact facing-edge walk, always exactly
`size` entries in edge order, exact N2301 Dict shape `{solid,
attribute_value}`; a missing/null/non-solid tile →
`{solid: false, attribute_value: 0.0}`. `wall_attribute_by_tile`
is a caller-supplied Dict "x,y" → float (the minimal extension,
N2414 precedent — `world_tiles` carries only {solid, wall_drop}
and `wall_drop` is the drop ITEM, not the block attribute; the
producer gap is documented in the pure + register, no tile
producer invented). Tick wiring stamps frame["wall_edge_tiles"]
BEFORE the N2301 recompute, supplied-wins (fill only when the
frame carries no `wall_edge_tiles`, N2381) OR when the
`wall_edge_tiles_live` flag is set (N2394 refresh flag), and
rebinds the local `wall_edge_tiles` after the fill. The fill call
uses `edge_filled` (not `filled` — the N2416 duplicate-var lesson;
the N2301 call already owns `filled` in that scope).

**Verify-first findings:** all brief cites exact — NO corrections.
The driver docstring previously said the scan was "DEFERRED #242"
(stale numbering from an older merge) — updated to "live since
N2459". The worker REWROTE the `WallCrafter updateTile live fill`
DEFERRED entry in place (the N2301/N2398 precedent) to record that
the live edge-tile scan is live since N2459 — the coordinator's
merge script took the rewritten text.

## Commits

- Slice: `b03fbca6f` (5 files, +1113/−2).
- Integration cherry-pick: `a6f5d6724` (clean).

## Tests

Targeted (new module
`tests.test_c07_wall_crafter_edge_tiles_live_fill`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM
(user order 2026-11-15). Neighbours N2301 + N2426: Ran 8, 6 PASS +
2 proof FAILs, both exactly Godot-absent (supplied-wins protects
the N2301 proof, which seeds `wall_edge_tiles` by hand). Rest of
the WallCrafter family (7 modules): Ran 28, 21 PASS + 7 proof
FAILs, all exactly Godot-absent. No pin breakage.
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 12313/1872/1813/3418 (exactly
as estimated). 1 new symbol
`source_wall_crafter_edge_tiles_live_fill_state_result.
wall_edge_tiles`. Changed shards: the 4 canonical SSOT files +
`production_api_contracts/slices/state_schema/symbols.json` (audit
report unchanged). DEFERRED **#210 RESOLVED** (253→252, by entry
TEXT) + the WallCrafter updateTile live fill entry rewritten in
place (see above); no new entry.

## Godot debt

- NEW proof `C07WallCrafterEdgeTilesLiveFillProof` (6 keys:
  `edge_coords_rot0`, `edge_coords_rot1` (folds rot 2/3, size-3
  large def), `edge_solid_gate`, `edge_missing_tile`,
  `edge_supplied_wins`, `edge_live_tick` — a cliff-crusher at
  (28,21), solid edge (30,21)/(30,22) at 0.5 each →
  efficiency_factor 1.0, N2301 live-tick numbers) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (supplied-wins protects the N2301
  proof).
