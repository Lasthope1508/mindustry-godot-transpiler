# Report N2478 — BeamDrill canPlaceOn / drawPlace rows

**Slice:** N2478 — BeamDrill canPlaceOn / drawPlace rows
(DEFERRED #234, the new entry added by N2473). **Wave:**
advances-33. **Commit:** `2b301e11f` on
`slice/N2478-beam-drill-can-place-on-draw-place-rows` (base
`08b822909`). **Files:** 5, +1344/−3.

## Source

BeamDrill.java (core/src/mindustry/world/blocks/production/):
- canPlaceOn :198-214: for each of `size` lasers, walk `range`
  tiles along the rotation from nearbySide; on the FIRST solid
  tile, `if(drop != null && drop.hardness <= tier &&
  (blockedItems == null || !blockedItems.contains(drop))) return
  true;` then `break;` (the break is OUTSIDE the drop check —
  the first solid tile ends the laser's walk either way).
- drawPlace :137-195: per laser, same walk; `found` = the first
  mineable drop (count++), `invalidItem` = the unmineable drop;
  `multiple` when two lasers find different items; `len =
  Math.min(j, range - 1);` dashLine(found == null ? Pal.remove :
  Pal.placing, from p1 to p1 + d4*len, tilesize scale); speed
  text `bar.drillspeed` formatFloat(60f / getDrillTime(item) *
  count, 2) via drawPlaceText when item != null; single-item
  icon (iconSmall / 4f) when !multiple; `bar.drilltierreq` text
  when item == null && invalidItem != null.
- getDrillTime :216-218 (lookup live since N2473); blockedItems
  init live since N2473. nearbySide :936-944 (Block.java). The
  gate shape is the SAME as updateFacing :391 (live since
  N2339).

## Implementation

TWO pure-only pures (no tick wiring — the placement call sites
wait for their own slice): `source_beam_drill_can_place_on_state
(tile_x, tile_y, rotation, size, beam_range, tier, blocked_items,
world_tiles)` → {can_place_on} + `source_beam_drill_draw_place_
state(tile_x, tile_y, rotation, valid, size, beam_range, tier,
blocked_items, world_tiles, drill_time_base, drill_multipliers,
text_width)` → {dash_lines, speed_text, icon, tier_req_text} —
call records only (the renderer/UI draws them). Bundle KEYS
(`bar.drillspeed`, `bar.drilltierreq`), NOT rendered values
(the N2450 precedent).

**Verify-first findings:**
- **invalidItem is the LAST unmineable drop, NOT the first** —
  `invalidItem = drop;` overwrites every time (the brief said
  first — wrong).
- **item is the LAST found across lasers and is NOT nulled when
  multiple** (unlike updateFacing :408-410) — so the speed text
  still draws with the full count and only the icon is
  suppressed.
- **The dash length has NO off-by-one:** j is the solid tile's
  own index at the break, so the dash ends ON the solid tile,
  or on the last walked tile (j == range → len range-1) when
  nothing is found.
- **The GDScript walk is a WHILE loop, not a for loop:** after
  a GDScript `for j in range(n)` exhausts, j reads n − 1, while
  Java's for leaves j == range — the while loop keeps the Java
  value.
- The dash endpoints use the raw tile coords times tilesize (no
  offset), while the icon dx/dy DO use the Block offset (`offset
  = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761 — 4.0 for
  the size-2 plasma-bore, 0.0 for the size-3 large-plasma-bore).
- tilesize is the Java constant 8 (Vars.java:135 — NEVER the
  game tile_size 32, the N2375 lesson) and the icon size is
  iconSmall / 4f = 24f / 4f = 6.0 (Vars.java:139).
- The speed text carries the bundle KEY + the RAW value +
  decimals 2 (the renderer formats); the tier-req text carries
  the bundle KEY + valid=false HARDCODED (Java passes false,
  not the placement flag).
- canPlaceOn: the Team parameter is never read by the Java body
  (no team param); a null tile (out of the world) does NOT break
  the walk and a non-solid tile does not break it either. The
  origins come from the N2346 laser-origins pure (the same
  nearbySide geometry updateLasers uses, BeamDrill.java:368-373
  — no second copy of the switch).

## Commits

- Slice: `2b301e11f` (5 files, +1344/−3).
- Integration cherry-pick: `afd8cd3c8` (clean).

## Tests

Targeted (new module
`tests.test_c07_beam_drill_can_place_on_draw_place_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). Neighbours (14 BeamDrill
modules) Ran 56 (42 PASS + 14 proof Godot-absent), 0 errors.
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+2/+4 → 12387/1892/1846/3484** (symbols
+2 over the +3 estimate — the draw-place pure returns 4 keys).
DEFERRED **#234 RESOLVED + 1 NEW ENTRY** (234→234, by entry TEXT
— new: "BeamDrill canPlaceOn / drawPlace live placement call
site" — the pures are live but no placement path calls them yet).

## Godot debt

- NEW proof `C07BeamDrillCanPlaceOnDrawPlaceProof` (6 keys:
  `place_first_mineable`, `place_break_on_solid`,
  `place_dash_colors`, `place_speed_text`,
  `place_multiple_items`, `place_tier_req`) — written but NEVER
  run; debt in GOAL.md §5.
- No old proof needs a re-run.
