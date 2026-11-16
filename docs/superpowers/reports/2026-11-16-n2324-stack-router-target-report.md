# Report N2324 — StackRouter target() live proximity selection

**Slice:** N2324 — StackRouter target() live selection (pure simulating
consecutive DuctRouter.target() calls over frame proximity neighbours +
cdump rotation + tick wiring into the N2240 advance). **Wave:** advances-13.
**Commit:** `8d2ef755` on `slice/N2324-stack-router-target` (base `4349a660`).
**Files:** 6, +1002/−10.

## Source

`DuctRouter.target()` (DuctRouter.java:139–157 — the brief said :139–156;
cite corrected by the worker) scans proximity neighbours from the current
cdump; the first match wins and cdump advances by the number of neighbours
scanned — including the match (incrementDump runs on EVERY scanned
iteration, before the return on a match and at the end of the loop
otherwise, DuctRouter.java:148-153; incrementDump itself is
BuildingComp.java:1116-1120, `cdump = ((cdump + 1) % prox)` when prox != 0).
The match gate is `!(sortItem != null && (current == sortItem) != (rel ==
rotation)) && !(rel == (rotation + 2) % 4) && other.team == team &&
other.acceptItem(this, current)` (DuctRouter.java:148); rel is
relativeTo(other) (BuildingComp.java:530), precomputed per neighbour in the
frame input. The N2240 advance ported the StackRouter updateTile with an
explicit ordered targets list (each entry models one target() call result,
popped in order per handoff) — but the driver passed `[]` because no live
proximity query existed, so no live handoff ever happened.

## Implementation

New pure `source_stack_router_target_list_state(...)` → `{targets,
cdump_after}`, simulating consecutive target() calls over the frame
`proximity_neighbours` input: each call scans from the current cdump, the
first match wins, cdump advances by the neighbours scanned. A call that
scans the whole list without a match returns null and stops the sequence
(its cdump advance is a full size, i.e. a no-op modulo size). The pure
needs an extra `team` param (brief missed it). Tick wiring stamps cdump
only when `handed_off > 0`.

**Follow-through 6th file:** the N2240 test pinned the advance call with
the `[]` targets literal (:244) → the worker updated it to the live call.

**Trailing-call deviation (documented):** Java calls target() once more
after the final handoff; the port stops after the last handoff — recorded
in the driver docstring + a DEFERRED entry.

## Commits

- Slice: `8d2ef755` (6 files, +1002/−10).
- Integration cherry-pick: `4c4c9e8b` (clean).

## Tests

Targeted (new module `tests.test_c07_stack_router_target`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Exact-evidence 27/27. Siblings Ran 23
= 17 PASS + 6 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11951/1764/1696/3184 (exactly the SCOPE
estimate): symbols `source_stack_router_target_list_state_result.targets` /
`.cdump_after`; audit stays 1336. DEFERRED net 0 (−1+1: resolved the
StackRouter updateTile live-fill entry — the worker recorded it as #189,
SCOPE as #190, verified by entry TEXT at merge — + 1 new trailing-call
deviation entry).

## Godot debt

- NEW proof `C07StackRouterTargetProof` (6 keys:
  `target_scans_from_cdump`, `target_skips_backwards_neighbour`,
  `target_skips_rejecting_neighbour`, `target_skips_wrong_team`,
  `target_sort_item_routing`, `live_tick_passes_targets_to_advance`) —
  written but NEVER run; debt in GOAL.md §5.
