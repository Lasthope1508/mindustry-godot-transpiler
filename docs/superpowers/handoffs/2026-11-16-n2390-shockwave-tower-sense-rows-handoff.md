# Handoff N2390 — ShockwaveTower sense / warmup rows

## What this slice did

2 pures: `sense` — progress = BARE ratio `reload_counter /
reload_value`, NO clamp; `warmup` — returns `heat`. Pure-only. 5
files, +940/−2, commit `c990db90b` on
`slice/N2390-shockwave-tower-sense-rows`.

## Key facts for the next agent

- **Progress is a BARE ratio, NO clamp** (Java-exact,
  ShockwaveTower.java:109-112) — the 1.5 over-reload case proves
  it.
- **2 pures, one Java method each** (the N2383 + N2356
  precedents).
- SSOT +3/+1/+2/+4. DEFERRED 306→305 (#65 resolved).
- Logic call site for `sense()` + display call site for `warmup()`
  are port-wide concerns, not ShockwaveTower deferrals.

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerSenseRowsProof` (6 keys) — never run.
