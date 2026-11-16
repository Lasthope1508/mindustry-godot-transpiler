# Report N2474 — Radar fogRadius rows

**Slice:** N2474 — Radar fogRadius() accessor as one pure-only
pure. **Wave:** advances-32. **Commit:** `65e83b4d0` on
`slice/N2474-radar-fog-radius-rows` (base `99a167e15`). **Files:**
5, +735/−1.

## Source

Radar.java (core/src/mindustry/world/blocks/defense/): fogRadius()
:55-57 (`return fogRadius * progress * smoothEfficiency;` — the
field times the build progress times the smoothed efficiency, in
that order, Java left-to-right). The field itself is `public int
fogRadius = -1;` (Block.java:348); the Radar constructor sets the
class default `fogRadius = 10;` (Radar.java:33 — a constructor
assignment, NOT a field declaration and NOT a def-block
assignment); the single radar def overrides it to `fogRadius = 34;`
(Blocks.java:1991). Build fields :49-51 (progress, lastRadius = 0f,
smoothEfficiency = 1f). The updateTile gate
`if(Math.abs(fogRadius() - lastRadius) >= 0.5f){` is :63 with the
write `lastRadius = fogRadius();` at :65; the drawSelect dash
radius is fogRadius() * tilesize (:81).

## Implementation

One pure-only pure (no tick wiring):
`source_radar_fog_radius_state(fog_radius_field, progress,
smooth_efficiency)` → {fog_radius} = fog_radius_field * progress *
smooth_efficiency, Java-exact multiplication order. The radar tick
is live (N2173 power row + N2190 updateTile advance + N2427 draw
rows) but NOTHING modeled the fogRadius() accessor itself: the
N2190 advance computes fog_radius_now INLINE and the N2427 draw
pure takes fog_radius_live as a caller-supplied input — neither
exposes the accessor as a source-backed pure. This pure COMPUTES
the input the update_tile + draw pures already take as
caller-supplied; the caller wires it later (replacing the inline
fog_radius_now in the advance and feeding the draw pure).

**Verify-first findings:**
- `fogRadius = 10` is a CONSTRUCTOR assignment (Radar.java:33);
  the field default is −1 (Block.java:348); only the `radar` def
  overrides to 34 (Blocks.java:1991). The pure takes the field as
  an input so either value works — the proof pins both (10 vs 34).
- fogRadius() is :55-57, not :55-56.
- **The proof pins the formula order with `==` exact**: 0.1×3×3
  left-to-right = 0.9000000000000001 ≠ 0.9 reordered — the order
  matters in double arithmetic.

## Commits

- Slice: `65e83b4d0` (5 files, +735/−1).
- Integration cherry-pick: `1813d911a` (clean).

## Tests

Targeted (new module `tests.test_c07_radar_fog_radius_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). Neighbours (3 Radar modules): Ran 12 (9
PASS + 3 proof Godot-absent), 0 errors.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12369/1885/1837/3466** (exactly as
estimated). DEFERRED **#124 RESOLVED** (238→237, by entry TEXT).

## Godot debt

- NEW proof `C07RadarFogRadiusRowsProof` (6 keys: `fog_def`,
  `fog_formula_order`, `fog_full`, `fog_half_efficiency`,
  `fog_live_input`, `fog_zero_progress`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run.
