# Report N2425 — UnitAssemblerModule draw / drawPlace / drawPlanRegion / icons rows

**Slice:** N2425 — UnitAssemblerModule draw() + drawPlace +
drawPlanRegion + icons(): a new pure-only draw pure models the base
rect, blends-gated input side regions, the always-drawn side region,
the payload, the top region, the place delegation, and the plan
region. **Wave:** advances-26. **Commit:** `e26429d1d` on
`slice/N2425-unit-assembler-module-draw-rows` (base `cc1fe2ed0`).
**Files:** 5, +1205/−1.

## Source

draw() (UnitAssemblerModule.java:90-108): rect(region); 4 input side
regions (`drawSideRegion(inRegion, x, y, i - 2)` for `blends(i)` and
`i != rotation`); the always-drawn side region
(`drawSideRegion(rotation >= 2 ? sideRegion2 : sideRegion1, x, y,
rotation)`); payload.draw() on Layer.blockOver when a payload is
present; rect(topRegion) on Layer.blockOver + 0.1f. drawPlace
(:38-45): super.drawPlace + the link delegation
(`link.block.drawPlace(link.tile.x, link.tile.y, link.rotation,
true)`). drawPlanRegion (:54-58): base + side + top sub-calls.
icons() (:59-63): `{region, topRegion}`.

## Implementation

One pure-only draw pure `source_unit_assembler_module_draw_state`
(7 explicit inputs: `x_value, y_value, rotation, blends` — an Array
of 4 caller-supplied verdicts — `payload` (Variant null-or-dict),
`link` (Variant null-or-dict `{block, tile: {x, y}, rotation}`),
`plan` (Variant null-or-dict `{drawx, drawy, rotation}`)) — 8 result
symbols: `base_call`, `input_calls`, `side_call`, `payload_call`,
`top_call`, `place_call` (null when link is null; contains the
delegated target `{block, tile_x, tile_y, rotation, valid: true}`),
`plan_call` (null when plan is null; contains base+side+top
sub-calls), `icon_regions` (`["region", "topRegion"]`, the N2396
precedent). The pure NEVER calls getLink — the link is
caller-supplied (the N2358 discovery lives in the tick).

**Findings beyond the brief (all verify-first):**
1. **8th result key `side_call`:** the side region is ALWAYS drawn,
   not blends-gated like the input regions, so it cannot be folded
   into `input_calls` without breaking the proof's
   `input_calls.size()` assert (which follows blends). The brief
   listed 7 keys and estimated +6; the real count is 8.
2. **No `time_value`, no `size_value`:** draw()/drawPlace/
   drawPlanRegion/icons use neither.
3. **No drawer** (the N2419 check was run — draw() is a direct
   override, no drawer field).
4. **`super.drawPlace` is only recorded, not modeled** (the N2396
   MassDriver precedent — the canonical `draw_place_state` already
   ports Block.drawPlace; `place_call` models only the module's
   delegation).
5. **Cite note (not a blocker):** the DEFERRED entry cites :31-50
   but `drawPlanRegion` is actually at :54-58 (outside the range);
   drawPlace :38-45, icons :59-63, draw :90-108 all match. The slice
   ports drawPlanRegion :54-58 anyway, per the brief.
6. **drawSelect is NOT ported** (it belongs to the separate
   onRemoved/drawSelect entry). `payRotation = rotdeg()` is
   reported unconditionally (rotation × 90) even when the payload
   is null. No duplicate `var` in the new pure (the N2416 lesson).

## Commits

- Slice: `e26429d1d` (5 files, +1205/−1).
- Integration cherry-pick: `d9db88bcc` (clean).

## Tests

Targeted (new module
`tests.test_c07_unit_assembler_module_draw_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). All 48 EXACT_EXPRS verified verbatim against
upstream before writing.
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+8/+1/+1/+2** → 12179/1845/1778/3348 (**variance
vs the +6 estimate:** the brief listed 7 result keys and the est said
+6; the always-drawn side region needs its own 8th key). Audit stays
1336. DEFERRED **#31 RESOLVED** (280→279, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07UnitAssemblerModuleDrawRowsProof` (6 keys:
  `draw_base_inputs` (incl. the facing-exclusion `i != rotation` +
  side select), `draw_payload_branch`, `draw_top_region`,
  `draw_place_link`, `draw_plan_region`, `draw_icons_merged`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring) — but the
  N2425 docstring edit DID break the N2348 verification pin (see
  N2432: the pin asserted the stale 'No link/draw/onRemoved rows'
  text; fixed serially at integration, no proof file changed).
