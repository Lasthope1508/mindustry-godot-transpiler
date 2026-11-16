# Report N2477 — BeamDrill drop loop + time reset + lastDrillSpeed

**Slice:** N2477 — BeamDrill drop loop (DEFERRED #119), the
drop loop + time reset + lastDrillSpeed from updateTile.
**Wave:** advances-33. **Commit:** `3778b4462` on
`slice/N2477-beam-drill-drop-loop` (base `08b822909`).
**Files:** 5, +1248/−21.

## Source

BeamDrill.java (core/src/mindustry/world/blocks/production/):
updateTile :244-262 — `updateFacing();` :244; `float multiplier
= Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);`
:246; `float drillTime = getDrillTime(lastItem);` :247;
`boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency,
0.1f);` :248; `lastDrillSpeed = (facingAmount * multiplier *
timeScale) / drillTime * efficiency;` :249; `time += edelta() *
multiplier;` :251; `if(time >= drillTime){ for(Tile tile :
facing){ Item drop = tile == null ? null : tile.wallDrop();
if(items.total() < itemCapacity && drop != null){ items.add(
drop, 1); produced(drop); } } time %= drillTime; }` :253-261.
getDrillTime :216-218 (`return drillTime /
drillMultipliers.get(item, 1f);` — the lookup is live since
N2473). Per-def drillTime: 160f (Blocks.java:3042,
plasma-bore) / 100f (:3055, large-plasma-bore). lastItem is set
by updateFacing (:375-411 — the body range, the method opens
:375, not :376 as the brief said).

## Implementation

One NEW drop-loop pure (the worker's choice over amending the
N2195 advance — the advance keeps moving time, the pure runs
after it and before the timerDump dump :264-266):
`source_beam_drill_drop_loop_state(frame, time_scale,
drill_time_base, drill_multipliers, item_capacity, size,
beam_range, tier, blocked_items)` → {last_item, facing,
drill_time, last_drill_speed, time, items, produced} — computes
drillTime via the inlined N2473 lookup, lastDrillSpeed per
:249, and on threshold runs the drop loop (one item per facing
tile with a drop) then resets time with `%=` (a reset, not a
subtraction: the loop runs ONCE per tick even when time exceeds
2x drillTime). The tick wires the pure after the N2195 advance
and stamps the results onto the frame.

**Verify-first findings:**
- **The capacity gate sits INSIDE the loop** (:256) — items.
  total() is re-checked PER tile: a store at 9/10 takes
  exactly one more item.
- **produced() is reported as counts, not written** — produced
  (item, amount) (BuildingComp.java:1039-1046) writes sector.
  info.handleProduction + item.unlock() when the sector exists
  and the team is the default team; no sector stats exist in
  the port (the WallCrafter N2398 precedent). The pure reports
  produced counts per item and the tick stamps them onto
  frame["produced"] — the sector-stats write waits for its own
  slice (NEW DEFERRED entry).
- The facing[] dests + lastItem come from updateFacing
  (:375-411): `facing[p] = dest;` (:404), the null-out
  `if(multiple){ lastItem = null; }` (:408-409), over the
  mineable gate :391. The pure re-walks the facing rays for
  them (the frame carries rays, not Tile[] dests).
- The 1f default is honoured on two layers: the call site
  passes 1f + arc ObjectFloatMap.get(key, defaultValue)
  (:286, null key → default :287 — the lastItem-null case).
- Until this slice landed, time grew unbounded (the N2195
  advance moved it but nothing reset it).

## Commits

- Slice: `3778b4462` (5 files, +1248/−21).
- Integration cherry-pick: `98961c3bc` (clean).

## Tests

Targeted (new module `tests.test_c07_beam_drill_drop_loop`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Neighbours (14 BeamDrill
modules) Ran 56 (42 PASS + 14 proof Godot-absent), 0 errors.
**Integration note:** the drop loop reads frame["facing_tiles"]
in the advance — the N2352 ordering pin (file-wide .index())
went stale and was narrowed by serial N2483 at integration
(pins scoped to the tick function; tick order intact).
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+1/+2 → 12389/1892/1845/3482** (symbols
+5 over the +2 estimate — the pure returns 7 result keys).
DEFERRED **#119 RESOLVED + 1 NEW ENTRY** (234→234, by entry TEXT
— new: "BeamDrill produced() sector stats").

## Godot debt

- NEW proof `C07BeamDrillDropLoopProof` (6 keys:
  `drop_threshold`, `drop_time_reset`, `drop_capacity_gate`,
  `drop_last_drill_speed`, `drop_multiplier`, `drop_live_tick`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
