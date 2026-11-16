# Handoff N2477 — BeamDrill drop loop + time reset

## What this slice did

One NEW drop-loop pure (not an amend of the N2195 advance):
`source_beam_drill_drop_loop_state` computes drillTime via the
inlined N2473 lookup, lastDrillSpeed per :249, and on threshold
runs the drop loop (one item per facing tile with a drop,
capacity re-checked per tile) then resets time with `%=`. The
tick wires it after the N2195 advance and before the timerDump
dump. 5 files, +1248/−21, commit `3778b4462` on
`slice/N2477-beam-drill-drop-loop`.

## Key facts for the next agent

- **Capacity gate INSIDE the loop** (:256) — 9/10 takes exactly
  one more item.
- **`time %= drillTime` is a reset, not a subtraction** — the
  loop runs ONCE per tick even when time > 2x drillTime.
- **produced() reported as counts, not written** — no sector
  stats in the port; NEW DEFERRED entry (produced() sector
  stats). Tick stamps frame["produced"].
- updateFacing body range is :375-411 (method opens :375).
- The drop loop reads frame["facing_tiles"] in the advance —
  the N2352 ordering pin was narrowed by serial N2483 at
  integration (pins scoped to the tick).
- SSOT +7/+1/+1/+2 (symbols +5 over est — 7 result keys).
  DEFERRED #119 resolved + 1 new entry (234→234).

## Godot debt (this slice)

- NEW proof `C07BeamDrillDropLoopProof` (6 keys) — never run.
