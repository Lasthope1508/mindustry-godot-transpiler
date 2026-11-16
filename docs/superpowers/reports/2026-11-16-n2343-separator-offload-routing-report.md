# Report N2343 — Separator offload neighbor routing

**Slice:** N2343 — Separator offload neighbor routing (the proximity
acceptItem/canDump scan in offload()). **Wave:** advances-15. **Commit:**
`208b72fd` on `slice/N2343-separator-offload-routing` (base `c89f1d09`).
**Files:** 13, +1652/−10.

## Source

Java: `offload()` (BuildingComp.java:1001-1015 — the brief's :1001-1016
includes a trailing blank line; the DEFERRED text keeps :1001-1016 to
match the existing entry); `other.handleItem` is :1009 (not :1011).
`offload_item_state` (SourceDrillInventoryRuntimeState.gd:115-143);
Separator advance :274, tick call :647 (no routing_context); dump frame
inputs :679-680.

## Implementation

New pure `source_separator_offload_routing_context_state(neighbour_accepts,
neighbour_can_dump, dump_cursor)` → `{neighbors: [{accepts_item, can_dump,
item_count: 0}], dump_cursor}` via inventory key constants; scan/cursor
verified vs BuildingComp.java:1001-1016 + offload_item_state (:115-143):
rotate the cursor first, inspect from the saved value; a routed pick
leaves the cursor past the handler, a full refused scan returns it to the
start (the N2286 full-cycle invariant). The tick builds the context
before the advance call (:647) and passes it as the 8th argument.
**Advance fix (found during verification):** a context without dump_cursor
now defaults it from frame cdump — the old default-{} path let
offload_item_state start at 0 and return cdump 0 on fallback, clobbering
a nonzero frame cursor on every context-less craft (no pinned behaviour
changes — N2222 proof craft frames carry cdump 0/absent).

Worker decisions: REUSED the N2281 dump frame inputs
`dump_neighbour_accepts`/`dump_neighbour_can_dump` (Java has ONE proximity
list — the brief's `offload_*` example would have created a synonym pair,
AGENTS.md rule); mismatched arrays → scan the longer array with
bounds-checked reads (missing = false, dump_item_state precedent).

## Commits

- Slice: `208b72fd` (13 files, +1652/−10).
- Integration cherry-pick: `bc0f040d` (conflict in the 4 canonical
  generated JSONs — resolved --ours; the register re-run at SSOT merge
  regenerated the entries).

## Tests

Targeted (new module `tests.test_c07_separator_offload_routing`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 14/14. Siblings
6 Separator modules Ran 24 = 18 PASS + 6 proof Godot-absent, 0 other
failures.
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11971/1777/1709/3210 (not +1 as
estimated — the pure returns 2 keys); shards comp_api_contracts +
comp_slices only, java_source BuildingComp. Audit stays 1336.
DEFERRED net 0 (resolve #154 + 1 new: Separator offload neighbour
write-back, BuildingComp.java:1009 — routed items leave without landing
in a neighbour store; live fill stays on the N2281 dump entry #257, shared
inputs).

## Godot debt

- NEW proof `C07SeparatorOffloadRoutingProof` (6 keys:
  `routing_context_builds_neighbors`, `routing_context_empty_neighbors`,
  `offload_routes_to_accepting_neighbor`,
  `offload_falls_back_without_accepting_neighbor`,
  `offload_respects_item_capacity`, `live_tick_routes_offloaded_item`) —
  written but NEVER run; debt in GOAL.md §5. The live tick seeds slag 1.0
  (N2252/N2281 pattern).
- Follow-through: N2222 + N2281 test pins updated (7-arg → 8-arg advance
  call string); NO re-run needed (neither scene touched, neither live tick
  crafts).
