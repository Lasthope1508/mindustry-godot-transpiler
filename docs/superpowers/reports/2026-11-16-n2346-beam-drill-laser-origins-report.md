# Report N2346 — BeamDrill updateLasers origins

**Slice:** N2346 — BeamDrill updateLasers origins / nearbySide geometry
(DEFERRED #329). **Wave:** advances-16. **Commit:** `f26b7bd9` on
`slice/N2346-beam-drill-laser-origins` (base `4f31a099`). **Files:** 5,
+1156/−6.

## Source

Java: updateLasers BeamDrill.java:368-373; nearbySide is
**Block.java:936–944** (not :936–947 as the brief said — :946–948 is
`getEdges`); the BeamDrill.java:240 lazy call (`if(lasers[0] == null)
updateLasers();` in updateTile) — updateLasers is not *only*
onProximityUpdate. `SourceBlockGeometry.gd` untouched (nearbySide has no
other caller in the port).

## Implementation

New pure `source_beam_drill_laser_origins_state(tile_x, tile_y, rotation,
size)` → `{lasers: [{x, y}...]}`, one origin per laser in laser order.
nearbySide geometry is driver-local inside the pure; corner = tile −
(size−1)/2 with Java integer division; the rotation switch 0–3 is verbatim
from Block.java; an unmatched rotation keeps the fresh `new Point2()`
default (0, 0) — the Java no-default-switch behavior. The tick stamps
`frame["lasers"]` + `frame["lasers_last_change"]` only when `tile_changes`
moves (the N2277 pattern, sentinel −2, first tick always refreshes) plus
the direct BeamDrill.java:240 analog (an empty lasers array refreshes);
placed BEFORE the consumption fold and the facing scan (Java order:
updateLasers :364 before updateFacing :365), NOT gated on enabled
(onProximityUpdate semantics). Rotation comes from the sprite meta
SOURCE_BUILD_ROTATION_META_KEY (default 0, set by the placement path);
tile from sprite `origin_cell`; size from the catalog per def. The initial
frame now carries `"lasers": []` + `"lasers_last_change": -2`. The N2339
facing-scan pure, its tick stamp, and its return are byte-identical
(pinned by test asserts).

## Commits

- Slice: `f26b7bd9` (5 files, +1156/−6).
- Integration cherry-pick: `447218fc` (clean).

## Tests

Targeted (new module `tests.test_c07_beam_drill_laser_origins`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 35/35 across 7
upstream files incl. arc Point2.java. Siblings: all 6 BeamDrill modules
Ran 24 — 18/18 non-proof PASS, 6 failures all Godot-absent proofs. All 11
proof expectations verified by simulating the pure logic in Python (rot 0
sizes 1/2/3, all 4 rotations, size 4/5 corner formula, size 0, invalid
rotations 4/−1).
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11977/1782/1714/3220, exactly as
estimated (1 symbol: `source_beam_drill_laser_origins_state_result.lasers`,
Array, java_expr `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`).
Shards changed: production_api_contracts, production_slices,
production_state_schema, production_symbols. Audit stays 1336.
DEFERRED **332 → 332 (rewrite in place, net 0)**: entry #329 rewritten —
updateLasers geometry live since N2346; live facing-tile fill +
lastItem/facing[] still wait. Base was the merged
DEFERRED-after-advances-15.py (332 entries).

## Godot debt

- NEW proof `C07BeamDrillLaserOriginsProof` (6 keys:
  `rotation_zero_origins`, `all_rotations_origins`,
  `corner_formula_even_odd_sizes`, `laser_count_matches_size`,
  `invalid_rotation_keeps_fresh_origin`, `live_tick_stamps_laser_origins`)
  — written but NEVER run; debt in GOAL.md §5. Live tick uses plasma-bore,
  no seed needed: tick 1 stamps [(30,20),(30,21)]; rotate to 1 +
  tile_changes bump re-stamps [(28,22),(29,22)]; rotate to 2 without a bump
  holds the gate; facing_amount stays 0 throughout.
- Follow-through: verified safe, no fix slice needed — no old BeamDrill
  proof reads `frame["lasers"]` (a new key); N2155/N2195/N2202/N2256/N2289/
  N2339 all green in the sibling run. NO re-runs needed.
- Scope corrections: (1) nearbySide is Block.java:936–944, not :936–947;
  (2) the drop-loop cross-reference is entry 187, not 190 (190 was the
  advances-14 numbering); (3) the BeamDrill.java:240 lazy call found
  (covered by the first-tick refresh + the empty-lasers gate clause).
- For the next agent: the live facing-tile fill slice (still deferred in
  #329) can now read `frame["lasers"]` as its ray origins — the wiring
  point is documented in the tick comment.
