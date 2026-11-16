# Report N2452 — Accelerator getCursor rows

**Slice:** N2452 — Accelerator.getCursor(): one pure-only pure
composes the existing canLaunch gate with the environment half
and returns the cursor. **Wave:** advances-29. **Commit:**
`4847a6b24` on `slice/N2452-accelerator-get-cursor-rows` (base
`27b5ced7f`). **Files:** 5.

## Source

canLaunch() (Accelerator.java:239-240): `isValid() &&
!net.client() && state.isCampaign() && efficiency > 0f &&
power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f
&& progress >= 1f && !launching;`. getCursor() (:243-246):
`@Override` :243, signature :244, `return canLaunch() ?
SystemCursor.hand : super.getCursor();` :245. BuildingComp.
getCursor() (BuildingComp.java:1683-1684): `block.configurable &&
interactable(player.team()) ? SystemCursor.hand :
SystemCursor.arrow;`.

## Implementation

One pure-only pure `source_accelerator_get_cursor_state(gate_can_launch,
is_valid, is_client, is_campaign, configurable, interactable)`
(no tick wiring) — 2 result symbols: `can_launch` (=
gate_can_launch && is_valid && !is_client && is_campaign) and
`cursor` ("hand" when can_launch, else "hand" iff configurable &&
interactable, else "arrow"). `gate_can_launch` is the
caller-supplied output of the existing N2271
`source_accelerator_can_launch_state` (driver line 231 — covers
efficiency / battery / progress / launching) — NOT recomputed.

**Verify-first findings:**
- **Accelerator sets `configurable = true;`** (Accelerator.java:
  77) — the super-hand branch is live for this def whenever
  interactable. Recorded in driver + register docstrings.
- **Cite correction:** getCursor is Accelerator.java:243-246
  (@Override :243, signature :244, return :245). The DEFERRED
  entry's ":242-244" is off by one (:242 is blank); the brief's
  ":244-245" is correct. The worker also fixed the stale driver
  drawSelect docstring citation (:243 → :245 for the return expr).
- Siblings re-verified after the driver text touch (N2271 launch,
  N2373 draw rows, N2422 bar rows): each still 3/4 PASS + proof
  Godot-absent only, no regressions.

## Commits

- Slice: `4847a6b24` (5 files).
- Integration cherry-pick: `7a6b0b106` (clean).

## Tests

Targeted (new module `tests.test_c07_accelerator_get_cursor_rows`):
3/4 PASS (registration, exact-evidence 12/12 exprs verbatim,
row-state) + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15). RED
confirmed first (Ran 4, failures=2, errors=2).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12293/1865/1802/3396 (exactly
as estimated). DEFERRED **#251 RESOLVED** (258→257, by entry TEXT
— base = merged DEFERRED-after-advances-28.py; no new entry).

## Godot debt

- NEW proof `C07AcceleratorGetCursorRowsProof` (6 keys:
  `cursor_hand_launch`, `cursor_super_hand`, `cursor_arrow`,
  `env_invalid`, `env_client`, `env_not_campaign`) — written but
  NEVER run; debt in GOAL.md §5. The proof composes the real
  N2271 gate output as `gate_can_launch`.
- No old proof needs a re-run (pure-only, no tick wiring).
