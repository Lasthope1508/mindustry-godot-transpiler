# Report N2456 — ItemBridge drawPlace / drawPlanConfigTop link preview

**Slice:** N2456 — ItemBridge.drawPlace() + drawPlanConfigTop():
two pure-only pures model the placement dash lines + link rect/arrow
and the plan-config bridge preview. **Wave:** advances-30.
**Commit:** `cd396a4d9` on
`slice/N2456-item-bridge-draw-place-rows` (base `4e4dc1a7c`).
**Files:** 5, driver +168/−1.

## Source

drawPlace() (ItemBridge.java:118-142): super.drawPlace; link =
findLink(x, y); 4 dash lines (Drawf.dashLine, Pal.placing, d4[i]
from tilesize/2+2 to range*tilesize); if link != null && Manhattan
dist > 1: rot = link.absoluteRelativeTo(x, y); w/h per :133-134;
Lines.rect; Draw.rect("bridge-arrow", link + d4(rot)*tilesize,
rot*90). drawPlanConfigTop (:82-96): if plan.config is Point2 p &&
|p.x| <= range && |p.y| <= range && (p.x == 0 || p.y == 0):
findPlan → otherReq != null → drawBridge(plan, ox, oy, 0).
drawBridge (:98-115): guard Mathf.zero(bridgeOpacity); stroke
bridgeWidth; v1 = (o − req) setLength(tilesize/2f = 4.0); Lines.line
bridgeRegion req+v1 → o−v1; arrowRegion at midpoint, Angles.angle +
flip.

## Implementation

Two pure-only pures (no tick wiring):
- `source_item_bridge_draw_place_state(tile_x, tile_y, range, link)`
  → `{dash_calls, link_rect, arrow_call}`. `link` is caller-supplied
  ({x, y} Dict or null — the output of the existing find_link pure,
  driver :830; findLink is NOT re-ported). dash_calls = 4 dash lines
  in d4 order (with segments per the Drawf overload); link_rect =
  null unless Manhattan > 1; arrow_call uses the region literal
  "bridge-arrow".
- `source_item_bridge_draw_plan_config_top_state(plan_x, plan_y,
  plan_config, range, other_req, bridge_opacity, bridge_width)` →
  `{bridge_call}` + diagnostics `config_valid`/`find_x`/`find_y`/
  `skipped_reason` (`invalid_config` / `no_other_req` /
  `zero_opacity` — unregistered diagnostics, the N2421 precedent).
  bridge_call = the drawBridge geometry (line req+v1 → o−v1, arrow
  at midpoint with Angles.angle + flip 0).

**Verify-first findings:**
1. **No separate "item-bridge" def:** Blocks.java has only one
   `new ItemBridge(` — phase-conveyor (`range = 12;`, :2118). The
   pure takes `range` as a param (def-agnostic).
2. **The "N2435" precedent for other_req caller-supplied does NOT
   exist** — the N2435 register has no line about findPlan/other_req.
   The worker changed the cite to the N2429 precedent (caller-
   supplied, same driver, verified).
3. **`absoluteRelativeTo` is called ON the link tile** — an east
   link has rot **2** (not 0); the proof covers all 4 rots (east 2,
   north 3, west 0, south 1) + a degenerate w=h=0 rect for a
   diagonal link.
4. **The Geometry.d4 comment "starting at the left" is WRONG vs
   the values** — values win: 0 east (+x), 1 north, 2 west, 3
   south.
5. Mathf.zero = |v| ≤ 1e-6 (verified); Angles.angle = atan2(dy,dx)
   in degrees, [0,360) via the `source_angles_angle` helper; a
   zero-length v1 stays zero (Vec2.setLength2); config (0,0)
   PASSES the plan gate; Pal.placing = accent (Pal.java:95). All 62
   EXACT_EXPRS verified verbatim before the test was written.
6. **Self-caught bug before commit:** the param named `range`
   shadows GDScript's builtin `range()` in the dash loop (`for i in
   range(4)` would fail at runtime under Godot) — fixed to
   `for i in 4:`.

## Commits

- Slice: `cd396a4d9` (5 files, driver +168/−1).
- Integration cherry-pick: `9c656a393` (clean).

## Tests

Targeted (new module
`tests.test_c07_item_bridge_draw_place_rows`): 3/4 PASS
(registration, exact-evidence 62/62 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+2/+4** → 12316/1872/1814/3420 (exactly
as estimated). Shards changed: registry, ledger, contracts, schema
(audit report + manifest unchanged). DEFERRED **#93 RESOLVED**
(253→252, by entry TEXT — verified `DEFERRED[92]` matched before
removal; no new entry).

## Godot debt

- NEW proof `C07ItemBridgeDrawPlaceRowsProof` (6 keys: `dash_calls`,
  `link_rect_gate`, `link_rect_values`, `arrow_call`,
  `plan_bridge_valid`, `plan_bridge_invalid` — incl. the 1e-6
  epsilon both ways, the range-12 boundary, config (0,0), and a
  diagonal link) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
