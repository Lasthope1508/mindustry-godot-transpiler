# Handoff N2421 — RepairTurret draw rows

## What this slice did

One pure-only draw pure `source_repair_turret_draw_state` (18
explicit params, no tick wiring): base + shadow + region + drawBeam
+ drawSelect/drawPlace dash circles + icons merged (N2396). The 4
drawBeam RNG draws are caller-supplied roll inputs — NO RNG in the
pure. 5 files, +1181/−1, commit `6326660ee` on
`slice/N2421-repair-turret-draw-rows`.

## Key facts for the next agent

- **Shadow shift is FLOAT `size/2f`** (size 1 → 0.5) — inverse of
  the N2396 int-div trap.
- **drawBeam DISCARDS the input offset** (`offset.trns` SETS it);
  pure reports `offset_after`.
- **setLength no-op at len 0** (pure guards the divide).
- **The two drawBeam branches are independent** (target branch runs
  at strength ≤ 0.01; beam draws with null target at held lastEnd).
- SSOT +7/+1/+1/+2 (est +6 — icon_regions is the 7th). DEFERRED
  #52 resolved (286→285).

## Godot debt (this slice)

- NEW proof `C07RepairTurretDrawRowsProof` (6 keys) — never run.
