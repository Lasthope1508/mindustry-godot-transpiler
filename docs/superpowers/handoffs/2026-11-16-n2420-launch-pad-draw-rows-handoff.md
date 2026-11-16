# Handoff N2420 — LaunchPad draw rows

## What this slice did

One pure-only draw pure `source_launch_pad_draw_state` (16 explicit
params, no tick wiring): liquid branch (null unless hasLiquids +
drawLiquid) + super.draw + 4×lightSteps light loop + shadow + pod +
icons (["previewRegion"]). New helper `_launch_pad_mathf_curve`
(first Mathf.curve in the port) + const SOURCE_LAUNCH_PAD_D8EDGE.
5 files, commit `ad76ea5bb` on `slice/N2420-launch-pad-draw-rows`.

## Key facts for the next agent

- **Def constants:** lightColor eab678 / lightStep 1f / lightSteps 3
  / liquidPad 2f / bottomColor Pal.darkerMetal; drawLiquid null by
  default, oil only on advanced (liquidCapacity 40f).
- **draw() is :104–136** (brief said :104–140; acceptItem starts
  :138). drawTiledFrames loop recorded as a CALL (N2396).
- **N2400 pin:** this pure's `liquid_capacity` input broke the
  N2400 `assertNotIn` pin — fixed by serial N2424 at integration.
- SSOT +6/+1/+1/+2. DEFERRED #45 resolved (286→285).

## Godot debt (this slice)

- NEW proof `C07LaunchPadDrawRowsProof` (6 keys) — never run.
