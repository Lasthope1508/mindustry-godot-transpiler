# Handoff N2439 — LightBlock drawPlace rows

## What this slice did

One pure-only draw-place pure
`source_light_block_draw_place_state` (no tick wiring): super
place (recorded, not registered) + dash circle + placeRadius2 +
calculateNodes CALL record + minimap color. draw()/drawLight()
untouched (live N2374). 5 files, commit `3e620901a` on
`slice/N2439-light-block-draw-place-rows`.

## Key facts for the next agent

- **offset = 0 for LightBlock** (Block.java:761, size 1 default)
  — the proof checks both offset 0 and 4.0.
- **Pal.placing = accent** (Pal.java:95). Illuminator radius 140f
  → dash 105.0, placeRadius2 450.1875; class default 200f →
  150.0/918.75.
- **calculateNodes is a CALL record** (N2396) — the node algorithm
  is not ported.
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #96 resolved (273→272).

## Godot debt (this slice)

- NEW proof `C07LightBlockDrawPlaceRowsProof` (6 keys) — never
  run.
