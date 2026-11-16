# Handoff N2348 — UnitAssemblerModule tier stamp

## What this slice did

Stamped the UnitAssemblerModule tier (class default 1) onto the frame
every tick. 5 files, +830/−1, commit `9f5612f8` on
`slice/N2348-uam-tier-stamp`.

## Key facts for the next agent

- Pure `source_unit_assembler_module_tier_state(block_id, tier_default)` →
  `{tier}` (class default 1 via const
  SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT; pure def-agnostic).
- Tick stamps frame["tier"] every tick (own block after `wired`, before
  the power-consumer fold — unconditional, overwrites stale seeds, runs
  even when disabled). Catalog has no tier key + def sets no tier
  (Blocks.java:6566-6573).
- **moduleFits takes NO tier term** (UnitAssembler.java:338-351 geometry
  only — the brief/SCOPE "moduleFits/sort" was half wrong); tier is used
  only in the checkTier sort (:364-369).
- **checkTier pure ALREADY live since N2133** — the remaining work is
  cross-building wiring (feed modules' stamped frame["tier"] into the
  assembler frame `modules` list on updateModules/removeModule,
  UnitAssembler.java:355-362) — a new DEFERRED entry.
- SSOT +1/+1/+1/+2 (1 symbol). DEFERRED net 0 (resolve #40 + 1 new).
- Manual merge with N2345 at integration (docstring segment :89 only);
  coordinator fix `888c552a` updated this slice's test pin to the merged
  `No link/draw/onRemoved rows`.
- Follow-through: none. NO re-run (frame["tier"] is a new key).

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleTierStampProof` (5 keys) — never run.
