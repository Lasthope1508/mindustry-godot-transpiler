# Report N2332 — StackRouter acceptItem intake gate

**Slice:** N2332 — StackRouter acceptItem intake gate (4-term override, NOT the
stricter parent DuctRouter gate). **Wave:** advances-14.
**Commit:** `a19a64f4` on `slice/N2332-stack-router-accept-item` (base `f3f7af8e`).
**Files:** 5, +827/−1.

## Source

Java: StackRouter OVERRIDE (StackRouter.java:89-93, method :90, return :91-92):
`!unloading && (current == null || item == current) && items.total() <
itemCapacity && (Edges.getFacingEdge(source.tile, tile).relativeTo(tile) ==
rotation)`. Parent DuctRouter is STRICTER (DuctRouter.java:160-164, method
:160, return :161-162: `current == null && items.total() == 0 && facing`) —
the port follows the override, and the difference is documented in the
docstring. The call `Edges.getFacingEdge(source.tile, tile).relativeTo(tile)`
has a **Tile** receiver, so it is `Tile.relativeTo(Tile)` (Tile.java:82-84,
adjacency table Tile.java:95-101), NOT `BuildingComp.relativeTo(Building)`
(:530, float-position — the one target() uses for `rel`); both return the
same 0–3 convention for adjacent tiles, but the correct cite is Tile.java:82
(SCOPE §0 cite corrected by the worker). Edges lives in **mindustry**, not
arc — `mindustry-upstream/core/src/mindustry/world/Edges.java:57-60`
(`getFacingEdge(Tile, Tile)`).

## Implementation

New pure `source_stack_router_accept_item_state(unloading, current, item,
items, item_capacity, facing_rel, rotation)` → `{accepts}`: exactly the 4
terms of the StackRouter override. Item compare by name string (N2225
precedent); total via shared `inventory.items_total` (faithful
`items.total()`). `facing_rel` is an int precomputed frame input (N2324
precedent) — NOT 2 positions: the port has no live tile geometry, and
Edges.getFacingEdge needs a world.tile lookup. The full Java chain is
documented in the docstring (Edges.java:57-60/62-63, Tile.java:82-84/95-101).

**No call site:** the tick has no intake path (verified by grep over the
whole driver + the N2240/N2324 tests: no acceptItem call is pinned, only the
target() gate expr + DEFERRED entry). acceptItem is a gate another building
calls when dumping/offloading (BuildingComp.java:1001-1016), so this slice
is pure + test + proof, no invented wiring. Documented limits (3) updated:
"acceptItem gate live (N2332)", keeping the N2240/N2324 pins.

**Nit (pre-existing, not fixed):** driver :209 cites the facing term as
"(StackRouter.java:90)" but the term is really at :92 (the signature is at
:90). The power test only pins the expr string, not line numbers, so no
impact.

## Commits

- Slice: `a19a64f4` (5 files, +827/−1).
- Integration cherry-pick: `588d62f7` (clean).

## Tests

Targeted (new module `tests.test_c07_stack_router_accept_item`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 21/21,
all grep-verified verbatim. RED before: 2 errors (KeyError N2332) + 2
failures as expected.
Siblings (StackRouter family: power_status, update_tile, target): Ran 12 =
9 PASS + 3 proof, all exactly Godot-absent.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11961/1770/1702/3196 (exactly the SCOPE
estimate): symbol `source_stack_router_accept_item_state_result.accepts`;
audit stays 1336. No shard changed.
DEFERRED 329→329 net 0 (−1+1: resolved #100 — the combined 'StackRouter
acceptItem / target rows' entry, target() live since N2324, acceptItem live
since this slice; added 'StackRouter acceptItem live fill' — no live caller
+ no live facing fill + handleItem application DuctRouter.java:179-184
still defers).

## Godot debt

- NEW proof `C07StackRouterAcceptItemProof` (6 keys:
  `accepts_when_idle_and_facing`, `rejects_when_unloading`,
  `rejects_when_current_differs`, `rejects_when_full` (boundary: total 9
  accepts, 10/11 reject), `rejects_when_wrong_facing` (incl. facing −1
  non-adjacent), `accepts_current_item_when_facing` (pins override-vs-
  parent: store 5/10 still accepts, the parent would reject)) — written
  but NEVER run; debt in GOAL.md §5.
