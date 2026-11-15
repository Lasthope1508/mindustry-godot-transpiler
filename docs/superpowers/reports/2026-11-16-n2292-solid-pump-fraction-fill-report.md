# N2292 SolidPump Fraction Fill — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## Source

onProximityUpdate (SolidPump.java:150-159): `super.onProximityAdded(); boost = sumAttribute(attribute, tile.x, tile.y) / size / size; validTiles = 0f; for(Tile other : tile.getLinkedTiles(tempTiles)){ if(canPump(other)){ validTiles += baseEfficiency / (size * size); } }`. canPump (SolidPump.java:80-83): `return tile != null && !tile.floor().isLiquid;`. sumAttribute (Block.java:575-582): attr null → 0; tile null → 0; else Σ `other.floor().attributes.get(attr)` over linked tiles, EXCEPT deep floors when `!floating && !placeableLiquid` (0 for deep). Fraction (SolidPump.java:124): `float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);`. env() (Attribute.java:31-34): state null → 0 else `Vars.state.envAttrs.get(this)`. baseEfficiency = 1f (SolidPump.java:26). **Def check (grep-verified):** water-extractor sets `attribute = Attribute.water` (Blocks.java:2927), `size = 2` (:2924), leaves floating/placeableLiquid at Block class defaults false (:212/:152) → deep floors contribute 0.

## Implementation

`SourceSolidPumpBuildState.gd`: pure `source_solid_pump_proximity_fraction_state(linked_tiles, block_size, base_efficiency, attribute_env, floating, placeable_liquid, has_attribute)` → {valid_tiles, boost, fraction}. validTiles = Σ canPump × baseEfficiency/(size²); boost = Σ floor attributes (0 for deep floors when !floating && !placeableLiquid) / size², 0 when attribute null; fraction = max(validTiles + boost + env, 0), env added only when attribute present. Tick wiring stamps valid_tiles/boost onto the frame BEFORE the N2220 advance (Java order), inside the enabled gate. **Trigger decision (the brief's simplest option):** recompute every enabled tick from frame inputs — documented in docstring + DEFERRED. New driver consts `SOURCE_SOLID_PUMP_SIZE := 2`, `SOURCE_SOLID_PUMP_BASE_EFFICIENCY := 1.0`. The N2220 advance is untouched (5-key return verified). **Extra findings:** the two linked-tile scans use the same tile set (getLinkedTiles vs getLinkedTilesAs, both walk the size×size footprint, Tile.java:474-525), so one frame input serves both sums; `pickedUp()` resets boost = validTiles = 0f (:100-102), made moot by per-tick recompute.

## Commits

Slice `bddb98ef` (worker-N2292, branch `slice/N2292-solid-pump-fraction-fill`, 5 files, +1029/−8, đã push, remote tip verified by ls-remote). Integration cherry-pick `7cae4fe5` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 26/26, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (36 tests across SolidPump power/should-consume/update-tile/dump-liquid + Pump dump-liquid + Fracker update-tile + MechanicalPump power/should-consume/update-tile): 27 pass, 9 fail, all 9 proof tests failing exactly Godot-absent — 0 other failures. Proof live-tick: valid_tiles 0.75, boost 0.1875, fraction 1.2375 at efficiency 0.5. Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11858/1738/1671/3134; audit stays 1336. DEFERRED 315 (313 − 1 resolved: SolidPump updateTile live fraction fill + 3 new: fraction linked-tiles live fill, attribute env live fill, onProximityUpdate trigger). Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

`C07SolidPumpFractionFillProof` — 6 keys: valid_tiles_counts_pumpable, boost_sums_attributes, deep_floor_excluded_when_not_floating, fraction_clamps_at_zero, env_adds_when_attribute_present, live_tick_fills_fraction (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
