# Handoff N2445 — UCL drawPlace rows

## What this slice did

One pure-only draw-place pure
`source_unit_cargo_loader_draw_place_state` (no tick wiring):
warning_call (drawPlaceText "bar.cargounitcap", null when
can_create). 1 result symbol. canPlaceOn NOT re-ported (live
N2330). 5 files, +791/−1, commit `c4999282e` on
`slice/N2445-ucl-draw-place-rows`.

## Key facts for the next agent

- **drawPlaceText x/y are TILE coords** (Block.java:546 converts
  inside the callee). Color is valid ? Pal.accent : Pal.remove
  (derived by the caller from `valid`).
- **Bundle key exact:** bar.cargounitcap = "Cargo Unit Cap
  Reached". Rotation is NOT a param (only super.drawPlace uses
  it).
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #241 resolved (266→265).

## Godot debt (this slice)

- NEW proof `C07UnitCargoLoaderDrawPlaceRowsProof` (6 keys) —
  never run.
