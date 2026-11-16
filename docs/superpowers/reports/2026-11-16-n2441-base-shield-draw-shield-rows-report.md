# Report N2441 — BaseShield drawShield / drawSelect rows

**Slice:** N2441 — BaseShield.drawShield() + drawSelect(): a new
pure-only draw pure models the shield poly (animated vs static
branch), the hit-tinted color, and the select dash circle.
**Wave:** advances-28. **Commit:** `9afd5ac83` on
`slice/N2441-base-shield-draw-shield-rows` (base `682c75eb9`).
**Files:** 5, +893/−2.

## Source

drawShield() (BaseShield.java:125-147): if !broken: radius =
radius() (= smoothRadius, :101-103); z Layer.shields;
color(shieldColor == null ? team.color : shieldColor, Color.white,
Mathf.clamp(hit)); if renderer.animateShields: Fill.poly(x, y,
sides, radius); else: Lines.stroke(1.5f); alpha(0.09f +
Mathf.clamp(0.08f * hit)); Fill.poly(x, y, sides, radius);
alpha(1f); Lines.poly(x, y, sides, radius); reset. Then reset.
drawSelect() (:106-110): super.drawSelect() + Drawf.dashCircle(x,
y, radius, team.color) — the FIELD radius, NOT radius() =
smoothRadius. Fields (:20-23): radius = 200f, sides = 24,
shieldColor nullable.

## Implementation

One pure-only draw pure `source_base_shield_draw_shield_state`
(no tick wiring) — 4 result symbols: `shield_call` (null when
broken; z Layer.shields + color mix shieldColor/team → white by
clamp(hit)), `fill_call` (Fill.poly: animated branch without its
own alpha / static branch with alpha 0.09 + clamp(0.08*hit) —
branch + alpha recorded), `line_call` (null in the animated
branch; Lines.poly + stroke 1.5f in the static branch),
`dash_call` (drawSelect dashCircle — super.drawSelect recorded,
NOT ported). New driver consts `SOURCE_BASE_SHIELD_SIDES := 24`,
`SOURCE_BASE_SHIELD_LAYER_SHIELDS := 125`. The scan/advance logic
is untouched (the sqrtf N2337 area not modified).

**Verify-first findings:**
- **Defs:** shield-projector (Blocks.java:2048-2054) overrides
  nothing; large-shield-projector sets only `radius = 400f;`
  (Blocks.java:2060). Neither def overrides sides or shieldColor
  → both are driver consts / explicit params.
- `Layer.shields = 125` (Layer.java:87); `Mathf.clamp(float)` is
  [0,1] (arc Mathf.java:402-404); `Draw.color(a, b, s)` lerps a→b
  by s (arc Draw.java:234-236); `animateShields` is the Renderer
  flag (Renderer.java:42, settings-loaded at :168) → a
  caller-supplied bool; `Drawf.dashCircle(x, y, rad, color)`
  (Drawf.java:398).
- **dashCircle uses the FIELD radius** (200f/400f), never
  smoothRadius — proven by the proof key with deliberately
  different fixture radii (smooth 150.0 vs field 200.0/400.0).
  `dash_call` survives `broken` (drawSelect has no broken gate);
  shield/fill/line calls are null when broken; `line_call` is
  null in the animated branch.
- **The static fill alpha is `0.09 + clamp(0.08 * hit)` with the
  sum NOT clamped** (0.09..1.09 in Java) — recorded exactly,
  including hit=2.0 → 0.25 in the proof.
- One correction vs the worker's first draft: drawPlace spans
  BaseShield.java:76-80, not :77-82 (grep-verified); the comment
  was fixed before commit. drawPlace itself stays deferred under
  the radius/sides entry.

## Commits

- Slice: `9afd5ac83` (5 files, +893/−2).
- Integration cherry-pick: `9dbe46cda` (clean).

## Tests

Targeted (new module `tests.test_c07_base_shield_draw_shield_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). RED confirmed first (Ran 4,
failures=2, errors=2: KeyError N2441 + pure missing + Godot-absent
proof).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12263/1859/1794/3380 (exactly
as estimated). Shards touched: `defense_slices.json` +
`defense_api_contracts.json` (defense-block precedent, N2328);
audit stays 1336. DEFERRED **#12 RESOLVED** (266→265, by entry
TEXT; no new entry).

## Godot debt

- NEW proof `C07BaseShieldDrawShieldRowsProof` (6 keys:
  `draw_shield_broken_gate`, `draw_shield_animated_branch`,
  `draw_shield_static_alpha`, `draw_shield_color_null_vs_set`,
  `draw_shield_hit_clamp`, `draw_select_dash_field_radius`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
