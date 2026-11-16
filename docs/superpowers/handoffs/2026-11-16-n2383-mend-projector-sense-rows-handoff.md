# Handoff N2383 — MendProjector sense rows

## What this slice did

New pure `source_mend_projector_sense_state` — progress →
`clampf(charge/reload, 0, 1)`; other sensors delegate via the
caller-supplied `super_value` (null = Float.NaN default). Pure-only
(no tick call site). 5 files, +888/−6, commit `f28611cfd` on
`slice/N2383-mend-projector-sense-rows`.

## Key facts for the next agent

- **super.sense is already modeled** via `SourceBuildingSenseState`
  (7 pures covering the BuildingComp.java:2093-2122 switch) — the
  pure takes an explicit `super_value`, no re-model.
- **No tick call site:** sense is called by logic (the processor),
  not the tick — pure-only like the N2372 draws. The
  logic-executor call site is port-wide, not a MendProjector
  deferral.
- Did NOT reuse the display `progress()` helper (no sensor
  dispatch; guards reload ≤ 0 → 0.0, lệch Java — charge/0 →
  +Inf → 1.0).
- SSOT +2/+1/+1/+2. DEFERRED 311→310 (#309 resolved).

## Godot debt (this slice)

- NEW proof `C07MendProjectorSenseRowsProof` (6 keys) — never run.
