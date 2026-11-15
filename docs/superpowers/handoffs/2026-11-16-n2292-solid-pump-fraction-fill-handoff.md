# N2292 SolidPump Fraction Fill — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## What this slice did

SolidPump live fraction fill: ported onProximityUpdate (validTiles + boost) as a pure, stamped before the N2220 advance. Pure `source_solid_pump_proximity_fraction_state` → {valid_tiles, boost, fraction}.

## Key facts for the next agent

- onProximityUpdate (SolidPump.java:150-159): `boost = sumAttribute(attribute, tile.x, tile.y) / size / size;` + validTiles loop over linked tiles with canPump (`validTiles += baseEfficiency / (size * size)`).
- canPump (SolidPump.java:80-83): `tile != null && !tile.floor().isLiquid`.
- sumAttribute (Block.java:575-582): attr null → 0; tile null → 0; else Σ floor attributes, EXCEPT deep floors when `!floating && !placeableLiquid` (0 for deep).
- Fraction (SolidPump.java:124): `Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0)`.
- **Def check:** water-extractor sets `attribute = Attribute.water` (Blocks.java:2927), `size = 2` (:2924), floating/placeableLiquid at Block defaults false → deep floors contribute 0.
- **Trigger:** recompute every enabled tick from frame inputs (the brief's simplest option) — documented in docstring + DEFERRED.
- The two linked-tile scans use the same tile set (getLinkedTiles vs getLinkedTilesAs), so one frame input serves both sums. `pickedUp()` resets boost/validTiles to 0f — moot due to per-tick recompute.
- SSOT +3/+1/+1/+2 → 11858/1738/1671/3134 (audit 1336). Exact-evidence 26/26. DEFERRED 315 (−1 +3 new).

## Godot debt (this slice)

`C07SolidPumpFractionFillProof` — 6 keys: valid_tiles_counts_pumpable, boost_sums_attributes, deep_floor_excluded_when_not_floating, fraction_clamps_at_zero, env_adds_when_attribute_present, live_tick_fills_fraction (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_solid_pump_fraction_fill`. Do NOT mark done until it passes there.
