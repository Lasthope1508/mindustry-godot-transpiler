# Report N2365 — N2357 proof re-seed (100 cells)

**Slice:** N2365 — Re-seed the N2357 proof's small pair after the
N2364 tile-size fix. **Wave:** advances-18 (coordinator-serial).
**Commit:** `678a3df5a` on `integration/wave-advances-18-n2358-n2364`
(no slice branch — coordinator-serial after integration).
**Files:** 5, +57/−39.

## Source

Java: Vars.java:135 (tilesize 8). The N2364 fix made the N2357
proof's 40-cell small pair link under Java math (40 × 8 = 320 < 700),
breaking key `large_def_range_2100_live_link`, which asserts both
stay idle.

## Implementation

Small pair moved 40 → 100 cells apart (small_b (68,26) → (128,26),
pos (128<<16)|26; 100 × 8 = 800 > 700 stays idle; the large pair
stays 40 cells: 320 < 2100 still links). The driver computes distance
purely from cell coords × 8 with no world lookup, so the move is
safe. Also updated: the N2364 test pin (comment + 2 new asserts
`100 * java_tilesize/game_tile_size > small_range`; the pin's tail
section also asserted the OLD fixture — `'40 cells * 32 ='` and
`Vector2i(68, 26)` — updated to `'100 * 8 = 800 world units'`,
`Vector2i(128, 26)` + `assertNotIn('Vector2i(68, 26)')`); the N2357
test module comment; the N2245 register tilesize description (:493 —
removed "; the game tile_size when set", now cites N2364) + register
re-run (description-only diff, 1 line in source_state_schema.json).

## Tests

Targeted Ran 9 (7 PASS + 2 proof Godot-absent). SSOT +0.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT +0, DEFERRED 0 (proof re-seed + description fix).

## Godot debt

- No new proof.
- **N2357 proof `C07PayloadMassDriverLargeVariantProof` NEEDS A
  RE-RUN** — the proof fixture changed (small pair 40 → 100 cells);
  noted on its GOAL.md §5 entry.
- Lesson: a fix slice's test pin can assert the OLD fixture in its
  tail — update the pin together with the proof.
