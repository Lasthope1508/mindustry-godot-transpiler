# Handoff N2409 — Fix proof N2394 (multi-press size-3 cdump defect)

## What this slice did

Fixed proof N2394: the multi-press is size 3 (Blocks.java:1059),
not size 2 — its footprint covers ring 4 as well as 5/6, so the
live-tick cdump is 5, not 7, and the liquid amounts are
43.75/6.25/43.75, not 37.5/12.5/37.5. Press re-centred to
(31,20) (footprint (30..32, 19..21), zero origin overlap);
ring-4 fill asserts added; cdump + liquid asserts fixed;
"size-2" comment corrected. Simulation-verified (Python mirror
of the exact GDScript dump + fill semantics; the ring-4-ignored
variant reproduces the old values exactly). Static pins in the
N2394 test module (RED→GREEN). 2 files, +64/−21, commit
`1ebad3ddf` on `slice/N2409-fix-proof-n2394-cdump`.

## Key facts for the next agent

- **Simulation is the verification:** the proof cannot run on
  this VM — the numbers come from a Python mirror of
  `dump_liquid_state` + `dump_item_state` + `occupied_cells`
  (scratch, not committed). Transfers 25/12.5/6.25, cursor walk
  0→5→6→7→5.
- **The defect moved the LIQUID asserts too** — fixing only
  cdump would still leave the proof failing in Godot.
- SSOT +0. DEFERRED unchanged.

## Godot debt (this slice)

- **RE-RUN: proof N2394** — run the FIXED proof (cdump 5,
  liquid 43.75/6.25/43.75).
