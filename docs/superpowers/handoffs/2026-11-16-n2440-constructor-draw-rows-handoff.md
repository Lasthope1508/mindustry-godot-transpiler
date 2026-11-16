# Handoff N2440 — Constructor draw rows

## What this slice did

One pure-only draw pure `source_constructor_draw_state` (13
inputs, no tick wiring): base/out + recipe shadow + blockbuild
shader loop (CALL record) + scan line (arc 3-arg sin) + payload
CALL + top + drawSelect icon + place effect. 9 result symbols.
5 files, +1284/−1, commit `0e5af70e6` on
`slice/N2440-constructor-draw-rows`.

## Key facts for the next agent

- **Place-effect scale = RECIPE size** (BuildPayload.java:86-88),
  proof pins 2.0/4.0. **size_value is the PRODUCER size**
  (drawSelect dx/dy) — not the recipe size.
- **+4 params beyond the brief:** size_value + draw_scl/xscl/yscl.
  Defs size 3/0.6f + size 5/0.75f, no drawer override. Scan z 41,
  top z 41.1 (Layer.blockBuilding 40).
- **Sin is arc 3-arg, NOT absin.**
- SSOT +9/+1/+1/+2 (exact est). DEFERRED #9 resolved (266→265).

## Godot debt (this slice)

- NEW proof `C07ConstructorDrawRowsProof` (6 keys) — never run.
