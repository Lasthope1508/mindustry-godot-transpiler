# Handoff N2469 — BurstDrill offload effects rows

## What this slice did

One pure-only pure (no tick wiring): `source_burst_drill_offload_
effects_state` reports the shake/sound/drillEffect call records for
the timerDump offload (CLASS defaults: shake 2.0, Fx.shockwave).
5 files, +907/−4, commit `b3b2fd8be` on
`slice/N2469-burst-drill-offload-effects-rows`.

## Key facts for the next agent

- **Per-def rows are NOT ported** — both defs override shake = 4f
  (Blocks.java:3077/:3106) + drillEffect to a MultiEffect. The pure
  records CLASS defaults; per-def rows wait for their own slice
  (the N2304 precedent).
- **Neighbor routing is NOT ported** — the offload takes the
  no-neighbor fallback (handleItem(self()), :1017). The #91 entry
  now says so; the routing waits for its own slice.
- drillEffectRnd is 0f for both defs → the effect spawns at (x, y)
  exactly; the position rolls are caller-supplied anyway.
- SSOT +3/+1/+1/+2 (exact est). DEFERRED #91 rewritten in place
  (238→238).

## Godot debt (this slice)

- NEW proof `C07BurstDrillOffloadEffectsRowsProof` (6 keys) — never
  run.
