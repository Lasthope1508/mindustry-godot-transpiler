# Handoff N2431 — BuildTurret draw rows

## What this slice did

One pure-only draw pure `source_build_turret_draw_state` (9
explicit params, no tick wiring): base + shadow + region + glow
additive by warmup + drawBuilding call when efficiency > 0. 5
files, commit `a1d76dce8` on `slice/N2431-build-turret-draw-rows`.

## Key facts for the next agent

- **Shadow shift = field elevation** (init-lifted size/2f = 1.5
  for the size-3 build-tower) — not the RepairTurret literal.
- **Glow alpha = warmup × 0.9** (heatColor Pal.accent.a(0.9f)).
  **build_call gate is strict > 0.**
- **icons() NOT ported** (BuildTurret.java:88-90) and no DEFERRED
  entry covered it — the coordinator added one at merge.
- SSOT +5/+1/+1/+2 (est +4 — the brief listed 5 keys). DEFERRED
  #96 resolved (280→279).

## Godot debt (this slice)

- NEW proof `C07BuildTurretDrawRowsProof` (6 keys) — never run.
