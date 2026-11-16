# Report N2434 — StackConveyor draw / drawCached rows

**Slice:** N2434 — StackConveyor draw() + drawCached(): a new
pure-only draw pure models the cached base/edge/input slices, the
power-status glow, the interpolated stack, and the sized item.
**Wave:** advances-27. **Commit:** `c4e93f0c0` on
`slice/N2434-stack-conveyor-draw-rows` (base `91ee0f1dc`). **Files:**
5, +1197/−1.

## Source

drawCached() (StackConveyor.java:124-149): rect(regions[state], x,
y, rotdeg()); the edge loop (blendprox bit clear → edgeRegion at
(rotation − i) * 90); stateLoad inputs (blendprox bit set && i != 0
&& near != null && !near.block.squareSprite → sliced regions[0]
bottom at ±tilesize*0.75f); stateUnload front (bit 0 set && front !=
null && !front.block.squareSprite → sliced top). draw()
(:151-192): z Layer.block − 0.1f; the glow branch (glowRegion.found()
&& power != null && power.status > 0f: edgeGlowRegion when
stateLoad, else glowRegion); early return if link == −1 || from ==
null || lastItem == null; the position interpolate (t = 1 −
cooldown, Interp.linear); the angle lerp with wraparound (3→0: a =
−90; 0→3: a = 360); the stack rect (lerp(a, b, smooth(1 −
clamp(cooldown*2, 0, 1)))); the item rect (size = itemSize *
lerp(min(items.total()/itemCapacity, 1), 1, 0.4)).

## Implementation

One pure-only draw pure `source_stack_conveyor_draw_state` — 8
result symbols: `cached_call`, `glow_call`, `stack_call`,
`item_call`, `stack_x`, `stack_y`, `stack_angle`, `item_size`.

**Verify-first findings:**
- State constants 0/1/2, `regions[state]` = `@-#` length-3 array,
  `itemSize` 5f, `glowAlpha` 1f / `glowColor` Pal.redLight with NO
  def override on either plastanium- or surge-conveyor.
- `Interp.smooth = a*a*(3-2a)` (arc Interp.java:11),
  `Interp.linear` identity, `Mathf.mod` = `((x%n)+n)%n` →
  GDScript `posmod` is the exact match; `d4x`/`d4y`
  {1,0,-1,0}/{0,1,0,-1}; `rotdeg()` = rotation*90; `sliced`
  bottom/top = botHalf/topHalf (Autotiler.java:55-57).
- **No icons() override** on StackConveyor (Block.java:976
  default) → no `icon_regions` key; region tokens ride the draw
  pure symbolically (N2396 precedent).
- **Brief gap, Java wins:** the brief did not mention the
  stack/item z lift — Java sets `Draw.z(Layer.blockAdditive +
  0.01f)` when the glow region is found (StackConveyor.java:
  182-184), else the stack/item draw at Layer.block − 0.1f. The
  pure records this z on both `stack_call` and `item_call`, and
  the proof pins both cases.
- **Input-shape note:** the brief listed `near_square` (Array 4
  bool) and `front_square` (bool), but Java also gates on `near
  != null` / `front() != null`. The pure takes them as Variants
  (null = no building, bool = squareSprite) so the null half of
  the gate is exact; documented in register + driver.
- `blendprox` is caller-supplied (N2239 never tracks it;
  onProximityUpdate stays deferred under its own entry). The
  interpolate t = 1 − cooldown is UNCLAMPED like Java
  (extrapolates past the from tile when cooldown > 1); the glow
  draws before the early return, so `glow_call` can be non-null
  while stack/item are null — both pinned in the proof.

## Commits

- Slice: `c4e93f0c0` (5 files, +1197/−1).
- Integration cherry-pick: `ee755eeeb` (clean).

## Tests

Targeted (new module `tests.test_c07_stack_conveyor_draw_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). 58 exact exprs, all verified
verbatim against upstream (incl. arc Interp/Geometry/Mathf).
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+8/+1/+1/+2** → 12226/1852/1786/3364 (exactly
as estimated). No `source_modules` shard changed; audit report
unchanged. DEFERRED **#61 RESOLVED** (273→272, by entry TEXT; no
new entry).

## Godot debt

- NEW proof `C07StackConveyorDrawRowsProof` (6 keys:
  `draw_cached_load`, `draw_cached_unload`, `draw_glow`,
  `draw_stack`, `draw_item_size`, `draw_early_return`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
