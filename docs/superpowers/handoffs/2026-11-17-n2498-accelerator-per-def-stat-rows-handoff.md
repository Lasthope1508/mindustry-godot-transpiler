# Handoff N2498 — Accelerator per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_accelerator_per_def_stats_state`
returns {size, scaled_health, power_buffer_requirement,
requirements}; unknown def → CLASS defaults. 5 files,
+778/−1, commit `676e95bb4` on
`slice/N2498-accelerator-per-def-stat-rows`.

## Key facts for the next agent

- Def (Blocks.java:6823-6832): size 7 / scaledHealth 80 /
  powerBufferRequirement 1_000_000f / copper 16000 /
  silicon 11000 / thorium 13000 / titanium 12000 /
  surge-alloy 6000 / phase-fabric 5000 (campaignOnly).
  Single def. Accelerator.java is in campaign/.
- Cross-check: 7×7×80 = 3920 = catalog health.
- **Class-fallback scaledHealth is −1.0, not 40**
  (coordinator ACCEPTED): the key exposes the FIELD
  itself (declared default −1, the "unset" sentinel
  init checks — N2490 precedent: fallback = field
  declaration values). **Consistent with, not in conflict
  with, the N2495/N2496/N2497 health-40 decision** (that
  key exposes EFFECTIVE health, where −1 is never real).
- powerBufferRequirement class default 0f (uninitialized
  field, Accelerator.java:41 — Java float default).
- Live input feeds the def requirement into the N2422 bar
  pure (500k/1M → fraction 0.5 bar present; fallback 0f
  → bar absent).
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #64 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07AcceleratorPerDefStatRowsProof` (6 keys)
  — never run.
