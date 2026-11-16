# Handoff N2351 — UnitAssembler checkTier cross-building wiring

## What this slice did

Wired UnitAssembler module add/remove events into the factory tick so the
tier re-derives through the N2133 climb (sort, climb while max or max + 1,
stop at the first gap). 6 files, +1050/−7, commit `9f42a3950` on
`slice/N2351-unit-assembler-check-tier-wiring`.

## Key facts for the next agent

- Pure `source_unit_assembler_modules_event_state(modules, tier, event)` →
  `{modules, current_tier, tier_gap}`; cell-level helper
  `source_unit_factory_modules_event_for_cell_state` wires link-cell events.
- **Frame-input format (coordinator-defined):** `link`/`link_candidate` =
  `{"block", "cell": Vector2i}` — the getLink discovery slice MUST conform
  to this format.
- Wiring is defensive: a link without a cell is skipped; the 4 old UAM
  proofs keep block-only links unchanged. No old proof needs a re-run.
- Java addUnique dedupes by BUILD identity — two distinct tier-1 modules
  both enter ([1, 1]); remove drops ONE occurrence.
- SSOT +5/+1/+2/+4 (2 functions = 5 symbols, 2 contracts, 4 schemas).
  DEFERRED 326→326 (−1 #325 +1 getLink discovery + rewrite link/findLink
  rows).
- Worker 1 blocked 10:44 (link ref carried no cell) → coordinator re-scope
  10:45 → worker 2 re-spawned 10:46. The getLink discovery slice is a
  separate later slice (Java getLink scans
  `indexer.getFlagged(team, BlockFlag.unitAssembler)` team-wide +
  moduleFits — new infrastructure, not a proximity lookup).

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerCheckTierWiringProof` (11 keys) — never run.
