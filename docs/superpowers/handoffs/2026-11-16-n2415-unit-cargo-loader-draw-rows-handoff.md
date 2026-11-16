# Handoff N2415 — UnitCargoLoader draw rows

## What this slice did

One pure-only draw pure
`source_unit_cargo_loader_draw_state` (no tick wiring): base
rect + EITHER Drawf.construct (unit null: icon, progress,
alpha, time, size 20f, shader time, scan line) OR poly ring
(unit present: sides 6, radius 8f, rotation = time×1f, stroke
= 1.8×readyness). 5 files, +994/−1, commit `2b39225c4` on
`slice/N2415-unit-cargo-loader-draw-rows`.

## Key facts for the next agent

- **Def constants:** polyStroke 1.8f / polyRadius 8f /
  polySides 6 / polyRotateSpeed 1f / polyColor Pal.accent
  (:27-30, no def override). Construct size = 3×8−4 = 20f.
- **No absin here** — the scan-line sin is the arc 3-arg form
  (Mathf.java:90-92); the N2372/N2382 double-scale precedent
  does not apply.
- **Icon rides the draw pure** as `construct_icon`
  (`"unitType.fullIcon"`, the literal Java expr) — UCL has no
  `icons()` override (N2396 precedent).
- Time is caller-supplied (`time_value`); the pure takes
  explicit params, no frame dict.
- SSOT +6/+1/+1/+2. DEFERRED #3 resolved (291→290).

## Godot debt (this slice)

- NEW proof `C07UnitCargoLoaderDrawRowsProof` (6 keys) —
  never run.
