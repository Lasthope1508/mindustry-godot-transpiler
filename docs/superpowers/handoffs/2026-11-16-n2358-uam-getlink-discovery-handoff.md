# Handoff N2358 — UnitAssemblerModule getLink discovery

## What this slice did

Added the moduleFits geometry pure + getLink discovery over an
explicit candidate list; the tick fills `frame["link_candidate"]`
before the N2248 advance. 5 files, +1200/−17, commit `dc5f5de6a` on
`slice/N2358-uam-getlink-discovery`.

## Key facts for the next agent

- `source_unit_assembler_module_fits_state`: spawn uses assembler
  rot/pos; dx/dy + relativeTo use module rot (proof pins module rot 3
  vs assembler rot 0); reuses `tile_relative_float_state`, d4 tables
  local + posmod, Mathf.equal inline 1e-6.
- `source_unit_assembler_module_get_link_state`: discovery over an
  EXPLICIT candidate list, first fit, returns the N2351 format
  `{"block", "cell": Vector2i}` or null; skips malformed entries.
- Tick fill ONLY when `frame.has("link_candidates")` (N2352 precedent
  — preserves N2248/N2351 proofs).
- SSOT +10/+1/+2/+4 (fits pure echoes intermediates). DEFERRED 326→326
  (−1 getLink discovery #318 1-based +1 live flagged-buildings index
  fill).
- Follow-through: the handoff gate (UAM.java:138) still reads the
  frame predicate `module_fits` (default false) — wiring the fits pure
  into the gate is a separate slice.

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleGetLinkDiscoveryProof` (14 keys) —
  never run.
