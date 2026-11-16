# Report N2333 — LaunchPad acceptItem gate

**Slice:** N2333 — LaunchPad acceptItem gate (total < capacity AND
(accept_multiple OR total == 0 OR first == item)). **Wave:** advances-14.
**Commit:** `24ff62bf` on `slice/N2333-launch-pad-accept-item` (base `f3f7af8e`).
**Files:** 5, +458/−1.

## Source

Java: `LaunchPadBuild.acceptItem` (LaunchPad.java:138-140, method :138,
return line :139 — the brief cite is exact):
`items.total() < itemCapacity && (acceptMultipleItems || items.total() == 0
|| items.first() == item)`. `acceptMultipleItems` is on `LaunchPad` itself
(LaunchPad.java:40, `public boolean acceptMultipleItems = false;`), NOT
StorageBlock. The launch-pad def sets it true (Blocks.java:6796); the
advanced-launch-pad keeps the false default. `itemCapacity` is 100 for both
defs (Blocks.java:6793/6803); the Block class default is 10 (Block.java:75).
The catalog carries `itemCapacity: 100` for both defs but does NOT carry
`acceptMultipleItems` (verified in `content_registry_blocks.json`) — so the
pure takes it as an explicit parameter; the driver would stamp it from the
block id at wiring time (launchTime precedent). The brief's "catalog hay def
constant?" question is answered: def constant, not in catalog.

## Implementation

New pure `source_launch_pad_accept_item_state(frame, item, item_capacity,
accept_multiple_items, item_order)` → `{accepts}`: `total < capacity AND
(accept_multiple OR total == 0 OR first == item)`, plus private helper
`_launch_pad_first_item` mirroring StackRouter (content-id-order scan over
catalog `item_names_by_id`, item compared by name string per N2225).
Documented limits gained (6) acceptItem gate LIVE (N2333).

**No driver call site:** driver grep acceptItem was 0 hits before this slice,
so pure + test + proof only, no invented wiring; the test pins this with
`assertNotIn('source_launch_pad_accept_item_state(frame, ')`. The N2186/N2238/
N2253 test files were read in full before editing — no intake/advance-call
pins conflict with this slice.

**Key-name deviation (brief-permitted):** the brief suggested both
`accepts_same_item_when_partial` and `accepts_first_item_match`, which
overlap; the worker used `first_item_uses_content_order` for the 6th key to
distinctly test the content-id-order first() scan (mixed copper+lead:
first-in-order accepts, other rejects, single-item pad).

## Commits

- Slice: `24ff62bf` (5 files, +458/−1).
- Integration cherry-pick: `1784546d` (clean).

## Tests

Targeted (new module `tests.test_c07_launch_pad_accept_item`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 16/16,
all grep-verified verbatim upstream.
Siblings (LaunchPad family: power_status, should_consume N2186, update_tile
N2238, liquid_row N2253): 12/12 non-proof PASS, each proof test Godot-absent
only.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11961/1770/1702/3196 (exactly the SCOPE
estimate): symbol `source_launch_pad_accept_item_state_result.accepts`
(LaunchPad.java, `LaunchPadBuild.acceptItem()`); audit stays 1336. Only the
4 canonical generated files changed; no shard/module changes.
DEFERRED 329→329 net 0 (−1+1: resolved #62 `LaunchPad acceptItem rows`;
added `LaunchPad acceptItem driver wiring` — pure live, no call site yet;
wiring waits for the frame-items-intake design).

## Godot debt

- NEW proof `C07LaunchPadAcceptItemProof` (6 keys: `accepts_when_empty`,
  `accepts_same_item_when_partial`,
  `rejects_other_item_when_partial_single`,
  `accepts_any_when_multiple_allowed`, `rejects_when_full`,
  `first_item_uses_content_order`) — written but NEVER run; debt in
  GOAL.md §5.
