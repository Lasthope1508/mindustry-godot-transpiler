# Handoff N2301 — WallCrafter getEfficiency live fill

## What this slice did

Ported `WallCrafter.getEfficiency` (WallCrafter.java:141-180) as pure
`source_wall_crafter_get_efficiency_state` → {efficiency, edge_efficiencies,
can_place_on, solid_tile_count, rotation}. The tick stamps `frame["efficiency_factor"]`
from `frame["wall_edge_tiles"]` each enabled tick BEFORE the N2223 advance — a live
cliff-crusher finally accumulates time. Commit `a78b498b`
(`slice/N2301-wall-crafter-get-efficiency`).

## Key facts for the next agent

- **BLOCK attributes, not floor attributes** — the N2292 SolidPump pure was NOT
  reused (different scan). `attribute = Attribute.sand` is WallCrafter.java:41 (the
  brief said :43, which is `output`).
- Frame input `wall_edge_tiles` = Array of {solid, attribute_value} in edge order;
  the pure takes the edge as given (no live world, no coordinate math). Missing
  tiles count as non-solid (0).
- Rotation comes live from sprite meta; size from catalog per def (2/3).
- **⚠️ N2223 + N2273 proofs are STALE now:** they seed `efficiency_factor = 1.0`,
  but the slice stamps it unconditionally each enabled tick (0.0 with an empty
  edge). Fix = seed `wall_edge_tiles` summing to 1.0 instead (N2300-precedent fix
  slices). N2283 + N2264 verified unaffected.
- DEFERRED entry 58 resolved; entry 169 rewritten (getEfficiency clause dropped).
  New entry: live edge-tile scan (no live tile scan fills the frame input yet).
- SSOT +5/+1/+1/+2 → 11893/1744/1678/3148.

## Godot debt (this slice)

Proof `C07WallCrafterGetEfficiencyProof` (6 keys) — written, NEVER run on this VM.
See GOAL.md §5. Run targeted test `tests.test_c07_wall_crafter_get_efficiency` with
Godot 4.6.2 on PATH, port 7777 free. Plus 2 proof fixes needed (N2223, N2273).
