# Report N2449 — StackRouter config / sortItem rows

**Slice:** N2449 — DuctRouter config(Item) + configClear +
buildConfiguration + configured(): one pure-only config pure
models the sort-item transitions and the configured side effects.
**Wave:** advances-29. **Commit:** `bd1987909` on
`slice/N2449-stack-router-config-rows` (base `27b5ced7f`).
**Files:** 5.

## Source

config(Item.class, ...) (DuctRouter.java:44): `tile.sortItem =
item`. configClear (:45): `tile.sortItem = null`.
buildConfiguration (:124-127): `ItemSelection.buildTable(
DuctRouter.this, table, content.items(), () -> sortItem,
this::configure);`. configured (:128-135): super.configured +
if !headless: recache() + renderer.minimap.update(tile).

## Implementation

One pure-only pure `source_stack_router_config_state(action, item,
headless, current_sort_item)` (no tick wiring) — 4 result symbols:
`sort_item` (item when action "set", null when "clear",
`current_sort_item` unchanged when "none"), `recache_called`
(action != none && !headless), `minimap_updated` (action != none
&& !headless), `configure_call` (buildConfiguration CALL record —
the UI is NOT ported, the N2443 picker precedent). Action ∈
{"set", "clear", "none"} (discriminated input, the N2443
precedent); item is null-or-Dict {name, color} (the N2433
precedent). `config()` returns sortItem (:187-189), so the pure's
`sort_item` IS the post-action config() value.

**Verify-first findings:**
- `recache()` is `BuildingComp.recache()` (BuildingComp.java:
  1285-1287) — renderer-side cache invalidation, no pure state →
  CALL flag, as the brief defaulted. (Tile.recache(),
  Tile.java:358, is a different method; the configured() call is
  the Building one.)
- **No equality condition (N2443 lesson):** configClear registers
  under `void.class` (Block.java:922-924); `BuildingComp.
  configured` maps null → void.class (:1416), Item → Item.class
  (:1418); `InputHandler.tileConfig` calls `build.configured`
  unconditionally (:728) → a same-item configure still recaches +
  updates the minimap (covered by the `configured_minimap` proof
  key).
- `configurable = true` + `saveConfig = true` (DuctRouter.java:
  33-34) confirmed and recorded in the docstring.

**Follow-through (coordinator, at integration):** DEFERRED #65's
entry text also listed handleStack/handleItem/removeStack
(DuctRouter.java:166-185, current-item transfer, not config) —
this slice does not port those. `handleItem` application remains
tracked under the existing N2324/N2332 entries; `handleStack` /
`removeStack` had no other entry, so the coordinator ADDED a
narrow DEFERRED entry at merge (N2430 precedent): "DuctRouter
handleStack / removeStack rows (handleStack sets current,
:173-177; removeStack clears current, :166-171; ...)".

## Commits

- Slice: `bd1987909` (5 files).
- Integration cherry-pick: `4b8ea3223` (clean).

## Tests

Targeted (new module `tests.test_c07_stack_router_config_rows`):
3/4 PASS (registration, exact-evidence 23/23 exprs verbatim,
row-state) + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12295/1865/1802/3396 (exactly
as estimated). DEFERRED **#65 RESOLVED** (258→257, by entry TEXT;
read/write entry stays). Coordinator added the handleStack /
removeStack entry at merge (see above).

## Godot debt

- NEW proof `C07StackRouterConfigRowsProof` (6 keys: `config_set`,
  `config_clear`, `config_none`, `configured_headless`,
  `configured_minimap`, `build_configuration_call`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
