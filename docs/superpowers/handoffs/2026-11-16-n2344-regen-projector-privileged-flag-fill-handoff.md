# Handoff N2344 — RegenProjector live privileged flag fill

## What this slice did

Filled the live privileged flag for RegenProjector updateTargets
candidates: the tick now stamps the pure verdict instead of literal
`false`, so privileged logic blocks are excluded from the N2338 narrow
pass on live ticks. 6 files, +2042/−14, commit `005f0e3d` on
`slice/N2344-regen-privileged-flag-fill`.

## Key facts for the next agent

- Pure `source_regen_projector_privileged_state(block_id)` →
  `{privileged}` (const SOURCE_REGEN_PROJECTOR_PRIVILEGED_BLOCK_IDS — the
  4 defs: world-processor / world-cell / world-message / world-switch,
  Blocks.java:6955/6965/6974/6981).
- Tick stamps the pure result replacing literal `false` at :871; the tick
  already reads `other_block_id` from SOURCE_BLOCK_ID_META_KEY (:866).
- N2277/N2338 pures untouched (docstring notes only).
- SSOT +1/+1/+1/+2 (1 symbol, Blocks.java). DEFERRED −1+0 (resolve #328).
- N2338 test pin changed (literal `'"privileged": false'` → new stamp
  string); NO proof re-run (no proof places a privileged block).
- Scope corrections: NONE.

## Godot debt (this slice)

- NEW proof `C07RegenProjectorPrivilegedFlagFillProof` (3 keys) — never run.
