# Handoff N2435 — OverdriveProjector draw rows

## What this slice did

One pure-only draw pure
`source_overdrive_projector_draw_rows_state` (no tick wiring):
base/top/ring + efficiency-scaled light + select/place dash
circles with caller-supplied selected blocks. 5 files, +1175/−1,
commit `15d176833` on
`slice/N2435-overdrive-projector-draw-rows`.

## Key facts for the next agent

- **Pure renamed vs the brief:** `..._draw_state` already belongs
  to the old display path N726 (PortGame.*) and upsert REPLACES
  the entry — the worker used `..._draw_rows_state` (N2372
  precedent) and verified N726 intact. **Later briefs must check
  pure names against the schema registry for collisions.**
- **No icons() override** → no icon_regions key (N2429 precedent).
- **f is computed AFTER the Lod guard** (inverse of MendProjector):
  f=0.0 when !lod_l2; base_call still recorded.
- SSOT +6/+1/+1/+2 (est +7). DEFERRED #141 resolved (273→272).

## Godot debt (this slice)

- NEW proof `C07OverdriveProjectorDrawRowsProof` (6 keys) — never
  run.
