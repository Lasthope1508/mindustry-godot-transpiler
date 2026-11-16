# Report N2442 — StackRouter setStats / drawPlanRegion rows

**Slice:** N2442 — DuctRouter.setStats() + drawPlanRegion() +
minimapColor() + rotatedOutput() (StackRouter inherits
DuctRouter): two pure-only pures model the items-moved stat and
the plan region. **Wave:** advances-28. **Commit:** `b782ec48f`
on `slice/N2442-stack-router-stats-plan-rows` (base `682c75eb9`).
**Files:** 5, +891/−1.

## Source

setStats() (DuctRouter.java:48-52): super.setStats();
stats.add(Stat.itemsMoved, 60f / speed * itemCapacity,
StatUnit.itemsSecond). drawPlanRegion() (:60-63): rect(region,
plan.drawx(), plan.drawy()); rect(topRegion, plan.drawx(),
plan.drawy(), plan.rotation * 90). minimapColor() (:66-69):
build == null || sortItem == null ? 0 : sortItem.color.rgba().
rotatedOutput() (:72-74): return false. StackRouter extends
DuctRouter (StackRouter.java:11); itemCapacity = 10
(StackRouter.java:20); speed = 5f default (DuctRouter.java:19).

## Implementation

Two pures (the N2419 draw + plan precedent, pure-only, no tick
wiring):
- `source_stack_router_stats_state(speed, item_capacity)` →
  `{items_moved_per_second, stat_key, stat_unit}` — Java-exact
  `60.0 / speed * item_capacity` (divide first, left-assoc);
  tokens `"itemsMoved"` / `"itemsSecond"`.
- `source_stack_router_draw_plan_state(plan_x, plan_y, rotation,
  sort_item)` → `{base_call, top_call, minimap_color,
  rotated_output}` — base rect unrotated, top rect at rotation *
  90; `minimap_color` 0 when sort_item null, else the
  caller-supplied rgba8888 **int** (not a string token);
  `rotated_output` always false. sort_item is null-or-Dict
  `{name, color}` (N2433 precedent); a non-Dict sort_item carries
  no color so minimap reads 0 (documented input contract).

**Verify-first findings:**
- **No "stack-router" def exists** in Blocks.java — surge-router
  is the only StackRouter def (Blocks.java:2255-2268): `speed =
  6f` (:2259), NO itemCapacity override → rate 60/6*10 = 100.
  duct-router def (Blocks.java:2193-2200): `speed = 4f` (:2196),
  class itemCapacity 1 → 60/4*1 = 15. Both rates are covered by
  the proof alongside the class-default 60/5*10 = 120.
- **Line-number corrections** (the brief cited :20/:22): `speed
  = 5f` is DuctRouter.java:**19**; `itemCapacity = 10` is
  StackRouter.java:**20**. setStats is :48-52, drawPlanRegion
  :60-63, minimapColor :66-69, rotatedOutput :72-74 (the DEFERRED
  entry text :48-53/:59-64/:66-70 is kept as-is — that is the
  entry's own wording).
- **Tokens verified exact:** `itemsMoved = new
  Stat("itemsMoved", StatCat.items),` (Stat.java:52);
  `itemsSecond = new StatUnit("itemsSecond"),`
  (StatUnit.java:20). rgba() = rgba8888 int (arc
  Color.java:365-367). The proof uses the real surge-alloy color
  (Items.java:83, `Color.valueOf("f3e979")`) → 0xf3e979ff = Java
  signed int **-202802689**, asserted as such.

## Commits

- Slice: `b782ec48f` (5 files, +891/−1).
- Integration cherry-pick: `840d4a4a8` (clean).

## Tests

Targeted (new module `tests.test_c07_stack_router_stats_plan_rows`):
3/4 PASS (registration, exact-evidence 27/27 exprs verbatim,
row-state) + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15). RED
confirmed first (2 failures + 2 errors: KeyError 'N2442', missing
pures, Godot-absent proof).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+2/+4** → 12266/1859/1795/3382 (exactly
as estimated). Only the 4 canonical generated files changed — no
source_modules shard, audit report untouched. DEFERRED **#68
RESOLVED** (266→265, by entry TEXT — the rewritten text from the
advances-27 merge; no new entry).

## Godot debt

- NEW proof `C07StackRouterStatsPlanRowsProof` (6 keys:
  `stats_math`, `stats_tokens`, `plan_base`, `plan_top_rotdeg`,
  `plan_minimap`, `plan_rotated_output`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
