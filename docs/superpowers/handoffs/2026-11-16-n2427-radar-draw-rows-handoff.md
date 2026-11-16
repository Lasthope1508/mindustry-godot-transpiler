# Handoff N2427 — Radar draw rows

## What this slice did

One pure-only draw pure `source_radar_draw_state` (no tick wiring):
base/region/glow + select dash circle + place dash circle + icons.
5 files, commit `3c7ef85fd` on `slice/N2427-radar-draw-rows`.

## Key facts for the next agent

- **fogRadius() method ≠ field** — method = fogRadius × progress ×
  smoothEfficiency (Radar.java:55-57); the pure takes both inputs
  (proof: half-discovery select 136 vs place 272).
- **Absin double-scale** (pure passes glow_scl×2.0 into
  source_absin; proof pins t=0 and t=5π).
- **Colors ride as String tokens** (SSOT has no Color type).
- SSOT +6/+1/+1/+2 (est +5). DEFERRED #44 + #45 resolved (280→278).

## Godot debt (this slice)

- NEW proof `C07RadarDrawRowsProof` (6 keys) — never run.
