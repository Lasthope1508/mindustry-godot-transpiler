# Handoff N2433 — StackRouter draw rows

## What this slice did

One pure-only draw pure `source_stack_router_draw_state` (no tick
wiring): cached parent draw (base + sort center OR top rect) + glow
by power.status + drawSelect + icons merged (N2396). New consts
SOURCE_STACK_ROUTER_GLOW_ALPHA 1.0 / GLOW_COLOR "Pal.redLight".
5 files, +992/−1, commit `8af4edaff` on
`slice/N2433-stack-router-draw-rows`.

## Key facts for the next agent

- **Def sets neither glow constant** — class defaults 1f /
  Pal.redLight ("feb380") apply.
- **Glow gate is STRICT > 0** (power_status −1 = power-null
  sentinel). **Cached split into base/sort/top** (N2431 split).
- **#70 refined at merge:** icons() live via this slice; setStats /
  drawPlanRegion / minimapColor / rotatedOutput still wait.
- SSOT +6/+1/+1/+2 (exact est). DEFERRED #68 resolved (273→272).

## Godot debt (this slice)

- NEW proof `C07StackRouterDrawRowsProof` (6 keys) — never run.
