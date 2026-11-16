# Handoff N2480 — PayloadDeconstructor breakBlock FX rows

## What this slice did

One pure-only FX call record (no tick wiring):
`source_payload_deconstructor_break_block_fx_state(finish,
deconstructing_size, x, y)` → {break_block_call} — {effect:
"Fx.breakBlock", x, y, scale: size / 8.0} when finish, null
otherwise. 5 files, +788/−4, commit `080986514` on
`slice/N2480-deconstructor-break-block-fx-rows`.

## Key facts for the next agent

- **Payload.size() is hitbox size in pixels** — build payload:
  block.size × tilesize; unit payload: unit.hitSize.
- **Divisor is the JAVA tilesize 8** (Vars.java:135), not the
  game tile_size 32.
- Size is caller-supplied (pre-tick frame — the N2233 advance
  nulls deconstructing in the same tick it returns finished).
- The renderer reads the third .at arg (e.rotation) as the size
  scale (Fx.java:288) — the record carries it as "scale".
- Finish verdict is caller-evaluated (the N2233 verdict).
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #95 resolved
  (234→233).

## Godot debt (this slice)

- NEW proof `C07DeconstructorBreakBlockFxProof` (6 keys) —
  never run.
