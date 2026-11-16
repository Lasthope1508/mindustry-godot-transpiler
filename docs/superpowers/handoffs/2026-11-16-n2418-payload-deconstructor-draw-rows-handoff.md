# Handoff N2418 — PayloadDeconstructor draw / icons rows

## What this slice did

One pure-only draw pure
`source_payload_deconstructor_draw_state` (no tick wiring): base rect
+ 4 input regions (blends) + drawPayload + deconstructing shadow /
construct + scan line + top region + icons merged (N2396 precedent).
5 files, commit `540362142` on
`slice/N2418-payload-deconstructor-draw-rows`.

## Key facts for the next agent

- **`payload_present` is a separate input** — drawPayload draws the
  HELD payload, not `deconstructing`.
- **This Drawf.construct overload has no scan line** (shader rect
  only, Drawf.java:560-572); the scan line is the Deconstructor's
  own.
- **Sin is arc 3-arg, NOT absin** (size 5 → mag 17 / len 34).
- **`time` is the BUILD field** (N2233), caller-supplied.
- SSOT +8/+1/+1/+2 (est +6 — the brief listed 8 result keys).
  DEFERRED #5 resolved (286→285).

## Godot debt (this slice)

- NEW proof `C07PayloadDeconstructorDrawRowsProof` (6 keys) —
  never run.
