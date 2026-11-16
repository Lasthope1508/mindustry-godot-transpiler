# Report N2433 — StackRouter draw / drawCached rows

**Slice:** N2433 — StackRouter draw() + drawCached() + drawSelect()
(DuctRouter parent): a new pure-only draw pure models the cached
parent draw, the power-status glow, the select call, and the icons.
**Wave:** advances-27. **Commit:** `8af4edaff` on
`slice/N2433-stack-router-draw-rows` (base `91ee0f1dc`). **Files:**
5, +992/−1.

## Source

drawCached() (StackRouter.java:73-75): `super.draw()` — the parent
DuctRouter draw() (DuctRouter.java:83-92): rect(region, x, y); if
sortItem != null: color(sortItem.color), rect("center", x, y),
color(); else: rect(topRegion, x, y, rotdeg()). draw()
(StackRouter.java:78-87): if glowRegion.found() && power != null &&
power.status > 0: z Layer.blockAdditive; color(glowColor, glowAlpha
* power.status); blend additive; rect(glowRegion, x, y, rotation *
90); blend(); color(). drawSelect() (DuctRouter.java:93-99):
super.drawSelect() + drawItemSelection(sortItem). icons()
(DuctRouter.java:55-57): `{region, topRegion}`.

## Implementation

One pure-only draw pure `source_stack_router_draw_state(x, y,
rotation: int, sort_item, power_status, glow_found, glow_color,
glow_alpha)` — no tick wiring. 6 result symbols: `cached_base_call`,
`cached_sort_call`, `cached_top_call`, `glow_call`, `select_call`,
`icon_regions` (icons folded in, the N2396 precedent; StackRouter
itself does not override icons()). New driver consts
`SOURCE_STACK_ROUTER_GLOW_ALPHA := 1.0`,
`SOURCE_STACK_ROUTER_GLOW_COLOR := "Pal.redLight"`.

**Verify-first findings:** the surge-router def
(Blocks.java:2255-2268) sets NEITHER glowColor nor glowAlpha → class
defaults 1f / Pal.redLight (`"feb380"`, Pal.java:138); no drawer
override; `rotdeg() = rotation * 90` (BuildingComp.java:582-584).
The glow gate is STRICT > 0 (power_status −1 = power-null sentinel).
`draws_icon` is true iff sort_item is set (`if(selection != null)`,
BuildingComp.java:1249-1250). The brief's result-key list named 4
keys but the SSOT estimate was +6 — the worker split the cached draw
into base/sort/top (the N2431 base/shadow/region split) to reconcile
both.

**Follow-through (coordinator, at integration):** DEFERRED #70
(StackRouter setStats/icons/drawPlanRegion) now partially overlaps —
`icons()` is live via this slice's `icon_regions`, but
setStats/drawPlanRegion/minimapColor/rotatedOutput still wait. The
coordinator refined the #70 entry text in place at merge (the
N2395/N2398 precedent) to record icons live.

## Commits

- Slice: `8af4edaff` (5 files, +992/−1).
- Integration cherry-pick: `e1127ceed` (clean).

## Tests

Targeted (new module `tests.test_c07_stack_router_draw_rows`): 3/4
PASS (registration, exact-evidence incl. all 35 exact exprs verbatim
in upstream, row-state) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). RED confirmed first (failures=2, errors=2).
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12224/1852/1786/3364 (exactly
as estimated). No `source_modules` shard changed (no shard selects
StackRouter.java — the N2181 precedent); audit report unchanged.
DEFERRED **#68 RESOLVED** (273→272, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07StackRouterDrawRowsProof` (6 keys:
  `draw_cached_sort_item`, `draw_cached_top`, `draw_glow_gate`,
  `draw_glow_alpha`, `draw_select_call`, `draw_icons`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
