# Handoff N2425 — UnitAssemblerModule draw rows

## What this slice did

One pure-only draw pure `source_unit_assembler_module_draw_state`
(7 explicit inputs, no tick wiring): base rect + blends-gated input
side regions + always-drawn side region + payload + top region +
place delegation + plan region + icons merged (N2396). The link is
caller-supplied — the pure NEVER calls getLink. 5 files, +1205/−1,
commit `e26429d1d` on
`slice/N2425-unit-assembler-module-draw-rows`.

## Key facts for the next agent

- **8th key `side_call`** — the side region is always drawn, not
  blends-gated; it cannot fold into `input_calls`.
- **No time/size inputs** — the Java draw family uses neither.
- **drawSelect NOT ported** (separate entry). `super.drawPlace`
  recorded, not modeled (N2396).
- **Cite note:** drawPlanRegion is at :54-58, outside the DEFERRED
  entry's :31-50 range.
- SSOT +8/+1/+1/+2 (est +6). DEFERRED #31 resolved (280→279).

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleDrawRowsProof` (6 keys) — never
  run.
