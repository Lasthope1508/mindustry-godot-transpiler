# Handoff N2426 — WallCrafter draw rows

## What this slice did

One pure-only draw pure `source_wall_crafter_draw_state` (no tick
wiring): base/top rects + rotator loop (rotation + a second
unrotated rect per edge tile) + plan region + place drillspeed text
+ icons. 5 files, +1018/−1, commit `e7dd7ecf1` on
`slice/N2426-wall-crafter-draw-rows`.

## Key facts for the next agent

- **Second rect in the rotator loop is real** (:244, no rotation,
  same vx/vy, Layer.blockOver).
- **`Strings.fixed` TRUNCATES** (arc Strings.java:735) — pure uses
  floor(v*100+0.0001)/100; proof probe 1.099 → "1.09".
- **cpos runs for EVERY edge tile** (before the solid check) — the
  loop draws all `size` rotators even for non-solid tiles (unlike
  N2301).
- **No def overrides draw** (N2419 check PASS).
- SSOT +6/+1/+1/+2 (est +5 — the brief listed 6 keys). DEFERRED
  #37 resolved (280→279).

## Godot debt (this slice)

- NEW proof `C07WallCrafterDrawRowsProof` (6 keys) — never run.
