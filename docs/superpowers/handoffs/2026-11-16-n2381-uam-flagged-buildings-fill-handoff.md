# Handoff N2381 — UAM live flagged-buildings index fill

## What this slice did

New pure `source_unit_assembler_module_flagged_candidates_state`
filters placed buildings to same-team UnitAssembler builds and
emits N2358 descriptors; the tick fills `frame["link_candidates"]`
from the live scan before the N2358 discovery + N2370 stamp. 5
files, +1117/−14, commit `05ddb523b` on
`slice/N2381-uam-flagged-buildings-fill`.

## Key facts for the next agent

- **Supplied wins — EXTENDED:** the fill runs only when the frame
  has NEITHER `link_candidates` NOR `link_candidate` (N2351's
  modules sit far from the placed assembler — a naive fill would
  let discovery overwrite the seed with null).
- **Live-refresh marker:** stamped frames carry
  `link_candidates_live` and re-scan every tick (frames persist;
  without it the first fill goes stale forever). Empty scan on a
  live-filled frame clears the stale list; on a fresh frame it
  stamps nothing.
- area_size = 13 def constant (Blocks.java:6529/6544/6559); pure
  defaults to class default 11. Descriptor x/y use Java tilesize
  8, not game 32.
- SSOT +3/+1/+1/+2. DEFERRED 311→310 (#304 resolved; #305 + #307
  rewritten in place).
- N2358/N2370/N2351 proofs are re-run candidates (tick path
  changed) but should stay green by construction — no §5 entry.

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleFlaggedBuildingsFillProof`
  (13 keys) — never run.
