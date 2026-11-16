# Handoff N2413 — Separator offload one-tick lag fix

## What this slice did

Hoisted `content_item_ids` + the N2402 fill block to before
the offload routing-context build, so the offload reads the
CURRENT tick's live-filled arrays (was: previous tick's). Fill
still runs exactly once per tick. Driver comments updated with
the new order + the judgment call (offload uses the fill's
first-held-item accepts; per-item routing for the picked item
waits). Static order-pin test (RED→GREEN). 2 files, +147/−29,
commit `ed3d99a32` on
`slice/N2413-separator-offload-live-fill-order`.

## Key facts for the next agent

- **N2402 live tick UNCHANGED — no re-run:** the proof seeds
  progress 0.0 and craft_time 35, so the advance never crafts
  in that tick and the offload never runs regardless of fill
  order. N2343/N2281/N2361 seed arrays by hand (unaffected).
- **Judgment call:** offload routing uses first-held-item
  accepts (same approximation as timerDump); per-item routing
  for the picked item is a later slice.
- SSOT +0. DEFERRED unchanged.

## Godot debt (this slice)

- None (no new proof, no re-run).
