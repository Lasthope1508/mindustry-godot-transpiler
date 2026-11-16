# Report N2467 — ItemBridge checkAccept facing rows

**Slice:** N2467 — ItemBridge checkAccept: one pure-only pure
models the facing acceptance gate (linked shortcut + linkValid +
relativeTo facing comparison). **Wave:** advances-31.
**Commit:** `9119630a3` on
`slice/N2467-item-bridge-check-accept-rows` (base `43a5c79ad`).
**Files:** 5, +837/−1.

## Source

ItemBridge.java (core/src/mindustry/world/blocks/distribution/):
checkAccept :441-462: `protected boolean checkAccept(Building
source, Tile link){ if(tile == null || linked(source)) return true;
if(linkValid(tile, link)){ int rel = relativeTo(link); var facing =
Edges.getFacingEdge(source, this); int rel2 = facing == null ? -1 :
relativeTo(facing); //this is a bug, but it is kept for
compatibility, see: https://github.com/Anuken/Mindustry/issues/
9257#issuecomment-1801998747 /* <commented-out incoming loop> */
return rel != rel2; } return false; }`
`linked(source)` :464-466: `source instanceof ItemBridgeBuild &&
linkValid(source.tile, tile) && source.link == pos()`.

## Implementation

One pure-only pure (no tick wiring):
`source_item_bridge_check_accept_state(tile_null, is_linked,
link_valid, rel, rel2)` → `{accepts}`. All inputs caller-supplied
(the N2435 precedent): tile_null (tile == null), is_linked
(linked(source)), link_valid (the linkValid verdict for (tile,
link) — the output of the existing linkValid logic), rel
(relativeTo(link)), rel2 (relativeTo(facing edge), or -1 when the
facing edge is null). Logic exactly per Java: tile_null ||
is_linked → true; link_valid → (rel != rel2); else false.
**The commented-out incoming loop (:450-456) is NOT ported** — it is
commented out in Java (a kept-for-compat bug, issue #9257);
documented in driver + register.

**Verify-first findings (Java wins — the relativeTo finding decides
the proof):**
1. **`relativeTo` is a THIRD option beyond the brief's two:**
   `BuildingComp.relativeTo(Tile)` (:526-528) →
   `relativeTo(int,int)` (:545-546) → `Tile.absoluteRelativeTo`
   (Tile.java:114). NOT `Tile.relativeTo` (:82-84) and NOT
   `BuildingComp.relativeTo(Building)` (:530, float-position).
   **This decides the proof:** for a non-adjacent link (up to range
   12), `Tile.relativeTo` returns −1 but `absoluteRelativeTo`
   returns the true direction (0–3).
2. `Edges.getFacingEdge(Building, Building)` is Edges.java:**52-55**,
   not :57-60 — :57-60 is the (Tile, Tile) overload. checkAccept
   calls the Building overload (:446 `getFacingEdge(source,
   this)`).
3. checkAccept is **:441-462**, not :441-463 (:463 is a blank line).
   The DEFERRED entry still says :441-463.
4. `linked(source)` confirmed exactly as briefed (:464-466).
5. The acceptItem/acceptLiquid call sites are already covered by the
   existing live-items-intake entry — NO new DEFERRED entry.

## Commits

- Slice: `9119630a3` (5 files, +837/−1).
- Integration cherry-pick: `3160166c8` (clean).

## Tests

Targeted (new module
`tests.test_c07_item_bridge_check_accept_rows`): 3/4 PASS
(registration, exact-evidence 26/26 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Neighbours (11 ItemBridge
modules): Ran 44 (33 PASS + 11 proof Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 12342/1879/1827/3446 (exactly
as estimated). One result symbol
`source_item_bridge_check_accept_state_result.accepts`. DEFERRED
**#99 RESOLVED** (246→245, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07ItemBridgeCheckAcceptRowsProof` (6 keys:
  `accept_tile_null`, `accept_linked`, `accept_facing_mismatch`,
  `accept_facing_match`, `accept_no_facing`,
  `accept_link_invalid`) — written but NEVER run; debt in GOAL.md
  §5.
- No old proof needs a re-run (pure-only, no tick wiring).
