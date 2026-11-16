# Handoff N2434 — StackConveyor draw rows

## What this slice did

One pure-only draw pure `source_stack_conveyor_draw_state` (no tick
wiring): cached base/edge/input slices + glow by power.status +
interpolated stack + sized item. 8 result symbols (cached/glow/
stack/item + stack_x/stack_y/stack_angle/item_size). 5 files,
+1197/−1, commit `c4e93f0c0` on
`slice/N2434-stack-conveyor-draw-rows`.

## Key facts for the next agent

- **Stack/item z lift** (brief gap — Java wins): blockAdditive +
  0.01f when glow found, else block − 0.1f; recorded on both
  calls, proof pins both cases.
- **Near/front are Variants** (null = no building, bool =
  squareSprite) so the null half of the gate is exact.
- **No icons() override** (Block default) → no icon_regions key.
  **blendprox caller-supplied** (N2239 never tracks it).
  Interpolate t UNCLAMPED like Java; glow draws BEFORE the early
  return.
- SSOT +8/+1/+1/+2 (exact est). DEFERRED #61 resolved (273→272).

## Godot debt (this slice)

- NEW proof `C07StackConveyorDrawRowsProof` (6 keys) — never run.
