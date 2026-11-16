# Report N2428 — RepairTower draw / drawSelect / drawPlace / setStats / range / warmup rows

**Slice:** N2428 — RepairTower draw() + drawSelect + drawPlace +
setStats + range() + warmup(): two pure-only pures model the draw
calls and the stat rows. **Wave:** advances-26. **Commit:**
`00616ae12` on `slice/N2428-repair-tower-draw-rows` (base
`cc1fe2ed0`). **Files:** 5, +1132/−1.

## Source

draw() (RepairTower.java): super.draw() (always present, runs
before the gate); the circle (`Drawf.dashCircle` at
`circleStroke`), the square (rotating at `squareSpinScl`, radius
`squareRad`), and the glow (absin `glowMag`/`glowScl`, color
Pal.heal) — all empty when warmup ≤ 0.001. drawSelect/drawPlace:
dash circles at the range. setStats: Stat.range (range/tilesize)
+ Stat.repairSpeed (healAmount×60). range() returns the def range;
warmup() returns the heal warmup. Def unit-repair-tower overrides
only range 100f + healAmount 1.5f (Blocks.java:6575-6583); all draw
constants are class defaults (circleStroke 3f, squareRad 3f,
squareSpinScl 0.8f, glowMag 0.5f, glowScl 8f, circleColor/glowColor
Pal.heal).

## Implementation

Two pures (the N2419 precedent):
- `source_repair_tower_draw_state` — `super_call` (always present),
  `circle_call` / `square_call` / `glow_call` (empty when warmup ≤
  0.001), `select_call`, `place_call`.
- `source_repair_tower_stats_state` — `range_blocks` (Stat.range,
  range/tilesize), `repair_per_second` (Stat.repairSpeed,
  healAmount×60), `range_value`, `warmup_value`.

**Verify-first findings:** offset 4.0 for the size-2 def; Pal.heal
`98ffa9`, Pal.placing = accent; Layer.effect 110, Layer.blockAdditive
31; absin Java-exact at the **doubled scale**
(`source_absin(time, glowScl*2, glowMag)`, N2372/N2382). Added
`tile_x`/`tile_y` int inputs to the draw pure — drawPlace takes
tile coords (`x*tilesize+offset`), which the world x/y inputs
cannot serve; the proof verifies place center (84, 164) for tile
(10, 20) + offset 4. Stat rows are Dicts carrying stat/value/unit
tokens (matching the draw-call-dict precedent); accessors are plain
floats.

## Commits

- Slice: `00616ae12` (5 files, +1132/−1).
- Integration cherry-pick: `9a2a76ec9` (clean).

## Tests

Targeted (new module `tests.test_c07_repair_tower_draw_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). RED confirmed first (2 failures + 2
errors before GREEN).
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+10/+1/+2/+4** → 12181/1845/1779/3350
(**variance vs the +6 estimate:** the brief counted only the draw
pure's 6 results; the stats pure adds 4 more result symbols — 2 stat
rows + 2 accessors). Audit stays 1336. DEFERRED **#52 RESOLVED**
(280→279, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07RepairTowerDrawRowsProof` (6 keys:
  `draw_warmup_gate`, `draw_circle`, `draw_square_glow`,
  `draw_select_place`, `draw_stats`, `draw_accessors`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
