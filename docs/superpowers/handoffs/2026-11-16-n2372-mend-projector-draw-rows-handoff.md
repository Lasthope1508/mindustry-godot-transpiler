# Handoff N2372 — MendProjector draw rows

## What this slice did

MendProjector draw / drawSelect / drawPlace / drawLight pures
(pure-only, no tick wiring). 5 files, +1220/−5, commit `41aa653de` on
`slice/N2372-mend-projector-draw-rows`.

## Key facts for the next agent

- **Schema-name collision: upsert REPLACES existing schemas.** A new
  pure whose result schema name already exists destroys the old keys —
  the first register run overwrote 11 display keys. Renamed
  `draw_state` → `draw_rows_state`; re-run purely additive. Always
  check whether a schema name already exists before registering.
- **absin Java-exact at DOUBLED scale:** helper(v,s) == Java(v,s/2)
  (Mathf.java:78-80). Pures pass 100/PI2 (draw) + 8f (select).
- `f` is reported even when hidden (Java computes f before the guard).
- SSOT +5/+1/+3/+6. DEFERRED 316→315 (#1 sense-only, #23 removed).
- Follow-through: display-path `draw_state` (MendProjector + Overdrive)
  passes undoubled 50/PI2 → 2× Java speed; needs its own slice.

## Godot debt (this slice)

- NEW proof `C07MendProjectorDrawRowsProof` (7 keys) — never run.
