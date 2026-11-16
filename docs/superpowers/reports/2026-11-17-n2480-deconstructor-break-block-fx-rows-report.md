# Report N2480 — PayloadDeconstructor breakBlock FX rows

**Slice:** N2480 — PayloadDeconstructor Fx.breakBlock finish
effect (DEFERRED #95). **Wave:** advances-33.
**Commit:** `080986514` on
`slice/N2480-deconstructor-break-block-fx-rows` (base
`08b822909`). **Files:** 5, +788/−4.

## Source

PayloadDeconstructor.java (core/src/mindustry/world/blocks/
payloads/): finish :190-194 — `if(canProgress){
Fx.breakBlock.at(x, y, deconstructing.size() / tilesize);
deconstructing = null; accum = null; }` (the finish gate itself
is `if(progress >= 1f){` :179 + `if(canProgress){` :190). The
N2233 advance clears deconstructing / accum on finish WITHOUT
the effect — this slice adds the effect only.

## Implementation

One pure-only FX call record (no tick wiring — the effect call
site waits for its own slice):
`source_payload_deconstructor_break_block_fx_state(finish,
deconstructing_size, x, y)` → {break_block_call} — when finish
is true: {effect: "Fx.breakBlock", x, y, scale:
deconstructing_size / 8.0}; null otherwise (the N2397
null-when-absent precedent).

**Verify-first findings:**
- **Payload.size() is the hitbox size in pixels** (`float
  size();`, Payload.java:27): a BuildPayload is `return build.
  block.size * tilesize;` (BuildPayload.java:86-88), a
  UnitPayload is `return unit.hitSize;` (UnitPayload.java:
  99-101) — so size() / tilesize is the block size in tiles
  for a build payload and hitSize / 8 for a unit payload.
- **The divisor is the JAVA tilesize** (`public static final
  int tilesize = 8;`, Vars.java:135), NOT the game tile_size 32
  (the N2364 lesson).
- The N2233 deconstructing descriptor (kind / requirements /
  build_time) carries NO size key, so the size is a
  caller-supplied float input in pixels, captured BEFORE the
  advance clears deconstructing (the advance returns finished
  but nulls deconstructing in the same tick, so the caller
  reads the size from the pre-tick frame).
- The effect is Fx.breakBlock (`breakBlock = new Effect(12,
  e -> {`, Fx.java:285), and its renderer reads the third .at
  arg (e.rotation) as the size scale (`Lines.square(e.x, e.y,
  tilesize / 2f * e.rotation + e.fin() * 3f);`, Fx.java:288) —
  so the record carries the value under the "scale" key.
- The finish verdict is caller-evaluated (the N2233 finished
  verdict — true exactly when progress reached 1f and the
  rounding check passed); the pure does NOT re-implement the
  finish gate.

## Commits

- Slice: `080986514` (5 files, +788/−4).
- Integration cherry-pick: `e31ea8d8f` (clean).

## Tests

Targeted (new module
`tests.test_c07_deconstructor_break_block_fx_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (13 Deconstructor modules) Ran 52 (39
PASS + 13 proof Godot-absent), 0 errors.
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12383/1892/1845/3482** (exactly
as estimated). DEFERRED **#95 RESOLVED** (234→233, by entry TEXT).

## Godot debt

- NEW proof `C07DeconstructorBreakBlockFxProof` (6 keys:
  `fx_on_finish`, `fx_null_when_not_finished`,
  `fx_scale_size_1`, `fx_scale_size_2`, `fx_tilesize_8`,
  `fx_live_input`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
