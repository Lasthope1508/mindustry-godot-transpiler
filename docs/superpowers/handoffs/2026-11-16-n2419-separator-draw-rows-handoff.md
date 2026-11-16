# Handoff N2419 — Separator draw rows

## What this slice did

Two pure-only draw pures (no tick wiring) porting the FULL DrawMulti
composition both defs use (Blocks.java:1246/:1266):
`source_separator_draw_state` (bottom / liquid tile / spinner / base
+ light + icons) and `source_separator_draw_plan_state` (plan bottom
/ spinner / fullIcon / team overlay). The brief assumed DrawDefault
(Separator.java:25) — wrong for both live defs. 5 files, commit
`fa6b62d82` on `slice/N2419-separator-draw-rows`.

## Key facts for the next agent

- **Drawer is DrawMulti, not DrawDefault** — both defs override it
  identically.
- **drawLight is super-only** — no DrawMulti member overrides it.
- **Icons:** ["-bottom", "-spinner", region] (DrawLiquidTile adds
  nothing). liquidCapacity: separator 40 / disassembler 72.
- SSOT +10/+1/+2/+4 (est +5/+1/+1/+2 — 2 pures). DEFERRED #36
  resolved (286→285).

## Godot debt (this slice)

- NEW proof `C07SeparatorDrawRowsProof` (9 keys) — never run.
