# Handoff N2330 — UnitCargoLoader canPlaceOn placement gate

## What this slice did

Wired the UnitCargoLoader placement gate: a new pure composes the N2322
canCreate verdict (Block default `canPlaceOn` is true, so the gate collapses
to it). 5 files, +790/−1, commit `23850af0` on
`slice/N2330-ucl-can-place-on`.

## Key facts for the next agent

- Pure `source_unit_cargo_loader_can_place_on_state(frame)` →
  `{can_place_on}`: composes `source_unit_cargo_loader_can_create_state`
  (N2322, via the N2140 bridge); the super call is modeled as `true`
  (Block.java:606-608).
- No tick change, no follow-through (the N2322 test pins the canCreate tick
  wiring — untouched; `can_create_inputs` is exactly 11 keys).
- Nit: method body is UnitCargoLoader.java:65-67 (:68 is a blank line); the
  :65-68 cite is kept for consistency with the DEFERRED entry + the N2322
  note.
- DEFERRED 329→330 (−1 #2 + 2 new: drawPlace rows :70-75 + live placement
  call site — the `can_place_on_hook` at SourceBlockGeometry.gd:1149-1151
  has no caller passing a UCL hook yet).
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). No shard changed.

## Godot debt (this slice)

- NEW proof `C07UnitCargoLoaderCanPlaceOnProof` (6 keys, pure-only, NO
  live-tick key) — never run.
