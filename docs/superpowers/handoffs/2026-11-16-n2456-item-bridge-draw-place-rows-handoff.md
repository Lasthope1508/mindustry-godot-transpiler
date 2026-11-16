# Handoff N2456 — ItemBridge drawPlace rows

## What this slice did

Two pure-only pures (no tick wiring):
`source_item_bridge_draw_place_state` (dash_calls + link_rect +
arrow_call; link caller-supplied from the existing find_link pure)
+ `source_item_bridge_draw_plan_config_top_state` (bridge_call +
diagnostics). 5 files, driver +168/−1, commit `cd396a4d9` on
`slice/N2456-item-bridge-draw-place-rows`.

## Key facts for the next agent

- **No "item-bridge" def exists** — only phase-conveyor (range
  12); the pure takes range as a param.
- **absoluteRelativeTo is called ON the link tile** — east link
  rot 2, not 0. **Geometry.d4 values:** 0 east, 1 north, 2 west,
  3 south (the "starting at the left" comment is wrong).
- **Self-caught bug:** param `range` shadowed the builtin
  `range()` — fixed to `for i in 4:`.
- SSOT +4/+1/+2/+4 (exact est). DEFERRED #93 resolved (253→252).

## Godot debt (this slice)

- NEW proof `C07ItemBridgeDrawPlaceRowsProof` (6 keys) — never run.
