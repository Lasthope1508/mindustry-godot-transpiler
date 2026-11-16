# Report N2463 — LiquidBridge link / findLink / linkValid rows

**Slice:** N2463 — LiquidBridge linkValid + findLink + config
(point2/integer/clear/none): three pure-only pures model the
inherited ItemBridge link state for the LiquidBridge driver.
**Wave:** advances-31. **Commit:** `47215d191` on
`slice/N2463-liquid-bridge-link-rows` (base `43a5c79ad`).
**Files:** 5, +1083/−1.

## Source

ItemBridge.java (core/src/mindustry/world/blocks/distribution/) —
LiquidBridge INHERITS these methods (LiquidBridge.java, 33 lines in
world/blocks/liquid/, overrides ONLY updateTransport/doDump —
verified by grep):
- linkValid :145-165: linkValid(tile, other) → linkValid(tile, other,
  true); the 3-arg version: `if(other == null || tile == null ||
  !positionsValid(tile.x, tile.y, other.x, other.y)) return false;`
  then `((other.block() == tile.block() && tile.block() == this) ||
  (!(tile.block() instanceof ItemBridge) && other.block() == this))
  && (other.team() == tile.team() || tile.block() != this) &&
  (!checkDouble || ((ItemBridgeBuild)other.build).link !=
  tile.pos())`.
- positionsValid :157-165: same x → |dy| <= range; same y → |dx| <=
  range; else false.
- findLink :167-173: `Tile tile = world.tile(x, y); if(tile != null
  && lastBuild != null && linkValid(tile, lastBuild.tile) &&
  lastBuild.tile != tile && lastBuild.link == -1){ return
  lastBuild.tile; } return null;`
- link = -1 :198. config() :500-501: `return Point2.unpack(link).
  sub(tile.x, tile.y);` — RELATIVE Point2. Config handlers :64/:66.

## Implementation

Three pure-only pures (no tick wiring — mirror N2460/N2461):
- `source_liquid_bridge_link_valid_state(...)` → `{link_valid}`.
  **10 params, not the brief's 9** — the worker added
  `tile_is_item_bridge` (tile.block() instanceof ItemBridge). The
  Java block conjunct has 4 DISTINCT predicates; the brief's 9
  covered 3. Rendering `!(tile.block() instanceof ItemBridge)` as
  `!tile_is_bridge` misreads the cross-def case (tile is a
  different-def ItemBridge, e.g. phase-conveyor, vs other is a
  bridge-conduit) — Java says INVALID, and the case is reachable via
  `linked()` (ItemBridge.java:465, `linkValid(source.tile, tile)`).
  The proof pins the cross-def case + the non-bridge tile case
  (second disjunct + team escape).
- `source_liquid_bridge_find_link_state(tile, last_build,
  link_valid)` → `{found_tile}`. **Deviation from the brief:** the
  brief's signature (tile_exists, last_build, link_valid) cannot
  evaluate `lastBuild.tile != tile` — the pure takes `tile` as a
  Variant Dict {x, y}-or-null instead (the N2461 precedent);
  `tile != null` IS the tile-exists check. `last_build` is
  null-or-Dict {tile: {x, y}, link: int} (the game lastBuild store,
  caller-supplied).
- `source_liquid_bridge_config_state(action, point, tile,
  current_link)` → `{link, config_value}`. Action ∈ {"point2",
  "integer", "clear", "none"}; "point2": link = pack(point + tile);
  "integer": link = point; "clear": link = -1; "none": unchanged.
  config_value = the relative Point2 {x, y} = unpack(link) − tile
  (the config() getter — so :500 is covered by this pure).

**ItemBridge.config() has NO null check** (unlike MassDriver.config()
:353) — a null tile NPEs in Java, so `config_value = null` on a null
tile is a DOCUMENTED FALLBACK (the N2461 precedent), not a Java line.
Recorded in driver + register + proof.

**Untouched:** `source_liquid_bridge_auto_link_placement_state`
(:364, placement-time N2199) is intact; the tick still recomputes
`had_valid_link` via the N2197 linkValid pure — NO rewire
(pure-only). Range varies by def (bridge-conduit 4, phase-conduit
12, Blocks.java:2388), so `positions_valid` is caller-supplied.

**Verify-first findings (line cites — brief off by 1-2):**
- link = -1 is ItemBridge.java:**198** (brief/DEFERRED said :202 —
  :202 is `wasMoved, moved, hadValidLink`).
- positionsValid **:157-165** (brief :159-166).
- config() **:500-501** (:502 is `}`).
- phase-conduit `range = 12;` is Blocks.java:**2388** (not 2389).

## Commits

- Slice: `47215d191` (5 files, +1083/−1).
- Integration cherry-pick: `f7fe3f0b6` (clean).

## Tests

Targeted (new module
`tests.test_c07_liquid_bridge_link_rows`): 3/4 PASS (registration,
exact-evidence, row-state) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Neighbours (7 LiquidBridge + 11 ItemBridge modules):
Ran 72 (54 PASS + 18 proof Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+3/+6** → 12345/1879/1829/3450 (exactly
as estimated). 4 result symbols: `link_valid`, `found_tile`, `link`,
`config_value`. DEFERRED **#48 RESOLVED** (246→245, by entry TEXT;
no new entry).

## Godot debt

- NEW proof `C07LiquidBridgeLinkRowsProof` (6 keys:
  `link_valid_true`, `link_valid_positions`, `link_valid_double`,
  `find_link_found`, `find_link_last_build`,
  `config_point2_relative` — the config key covers integer/clear/
  none/unknown/null-tile) — written but NEVER run; debt in GOAL.md
  §5.
- No old proof needs a re-run (pure-only, no tick wiring).
