# Report N2418 — PayloadDeconstructor draw / icons rows

**Slice:** N2418 — PayloadDeconstructor draw() + icons(): a new
pure-only draw pure models the base rect, input regions, payload,
shadow/construct, scan line, top region, and icons. **Wave:**
advances-25. **Commit:** `540362142` on
`slice/N2418-payload-deconstructor-draw-rows` (base `e4e57bca3`).
**Files:** 5.

## Source

draw() (PayloadDeconstructor.java:58-89): rect(region); 4 input
regions (`if(blends(i)) Draw.rect(inRegion, x, y, (i*90)-180)`);
z Layer.blockOver; drawPayload() (PayloadBlock.java:246); if
deconstructing != null: set(x+payVector.x, y+payVector.y,
payRotation); drawShadow(1f-progress); Drawf.construct(x, y,
deconstructing.icon(), Pal.remove, BuildPayload ? 0f :
payRotation-90f, 1f-progress, 1f-progress, time); scan line
`Lines.lineAngleCenter(x + Mathf.sin(time, 20f, tilesize/2f *
block.size - 3f), y, 90f, block.size * tilesize - 6f)`; rect(topRegion).
icons() (:40-42): `{region, topRegion}`.

## Implementation

One pure-only draw pure
`source_payload_deconstructor_draw_state(x, y, blends,
payload_present, deconstructing, progress, time_value,
size_value)` — 8 result keys (base_call, input_calls, payload_call,
shadow_call, construct_call, scan_line, top_call, icon_regions).

**Verify-first findings:**
- `drawPayload()` draws the HELD payload, a different field from
  `deconstructing` — so the pure takes a separate `payload_present`
  bool (the brief's input list didn't name it).
- The `Drawf.construct` overload here (Drawf.java:560-572) is a
  shader rect ONLY — no scan line of its own (unlike the Building
  overload); the scan line is the Deconstructor's own line, drawn
  after `Draw.color(Pal.remove)` + `Draw.alpha(1f)` in the same
  lambda.
- Sin is the arc 3-arg form (`sin(time/20f) * mag`), NOT absin:
  size 5 → magnitude 17 / length 34; size 3 → 9 / 18.
- Inner shadow geometry (`BuildPayload` squareShadow sized
  `block.size * tilesize * 1.85f` / `UnitPayload` drawSoftShadow)
  needs payload block-size/unit-type data the N2233 descriptor
  doesn't carry — documented in the pure comment; the pure reports
  call + alpha + position + kind. No new DEFERRED entry added.
- `time` is the BUILD field (`time += edelta()`, N2233 advance),
  caller-supplied as `time_value` — not `Time.time`.

## Commits

- Slice: `540362142` (5 files).
- Integration cherry-pick: `8616c88c1` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_deconstructor_draw_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). 41 exact exprs, all verified verbatim in upstream.
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+8/+1/+1/+2** → 12139/1838/1770/3332 (**variance
vs the +6 estimate:** the brief listed 8 result keys and the est said
+6 — all 8 are distinct draw calls with their own Java exprs, so all
8 were registered rather than leaving source-backed results
unregistered). Audit stays 1336. DEFERRED **#5 RESOLVED** (286→285,
by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07PayloadDeconstructorDrawRowsProof` (6 keys:
  `draw_base_inputs`, `draw_no_deconstructing`,
  `draw_deconstructing_shadow_construct`, `draw_scan_line`,
  `draw_icons_merged`, `draw_construct_rotation` (BuildPayload 0f
  vs payRotation−90f)) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
