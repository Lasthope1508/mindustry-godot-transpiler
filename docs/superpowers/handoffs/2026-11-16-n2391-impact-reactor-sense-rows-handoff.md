# Handoff N2391 — ImpactReactor sense rows

## What this slice did

2 pures: `sense` — heat returns warmup directly (no clamp, no
ratio); `warmup()` accessor — a separate pure because the DRAWER
calls it, not logic. Also fixed the wrong driver docstring claiming
no sense override exists. Pure-only. 5 files, +935/−2, commit
`cc54e928e` on `slice/N2391-impact-reactor-sense-rows`.

## Key facts for the next agent

- **Correct cites:** sense override ImpactReactor.java:119-122;
  `warmup()` :104-106 (the brief said :114-116 — that is
  `ambientVolume()`); :124-127 is `write()`, not sense.
- **The parent `PowerGenerator.warmup()` returns
  `productionEfficiency` when enabled** — ImpactReactorBuild
  overrides it to return the raw warmup field; the port models the
  override.
- SSOT +3/+1/+2/+4. DEFERRED 306→305 (#96 resolved).
- Read/write rows (ImpactReactor.java:125-134) still wait under
  their existing entry.

## Godot debt (this slice)

- NEW proof `C07ImpactReactorSenseRowsProof` (6 keys) — never run.
