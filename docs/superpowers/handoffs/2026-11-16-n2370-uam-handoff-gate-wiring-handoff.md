# Handoff N2370 — UnitAssemblerModule handoff-gate moduleFits wiring

## What this slice did

The UAM tick stamps `frame["module_fits"]` from the N2358 fits pure
over the current link's candidate descriptor before the N2248 advance.
Wiring-only, 5 files, +965/−7, commit `27c627a50` on
`slice/N2370-uam-handoff-gate-wiring`.

## Key facts for the next agent

- **Supplied-only stamping:** stamp only when `link_candidates` is
  supplied. An unconditional false stamp would break the N2248/N2314
  proofs (they seed module_fits=true, block-only link, no candidates).
  The false default still holds for unseeded live frames via the
  advance default.
- Current link = post-discovery link_candidate when the advance will
  refresh, else the frame link. Gate cite is
  UnitAssemblerModule.java:138.
- SSOT +0/+1/+0/+0 (re-lists 7 N2358 fits symbols). DEFERRED 316→316
  (net 0; live-fill entry rewritten in place: moduleFits LIVE,
  wasOccupied still waits).

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleHandoffFitsWiringProof` (5 keys) —
  never run.
