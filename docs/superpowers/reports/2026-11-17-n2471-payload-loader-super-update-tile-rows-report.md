# Report N2471 — PayloadLoader super.updateTile payload update rows

**Slice:** N2471 — PayloadLoader super.updateTile payload.update
CALL record (pure-only). **Wave:** advances-32. **Commit:**
`a69b8d425` on `slice/N2471-payload-loader-super-update-tile-rows`
(base `99a167e15`). **Files:** 5, +766/−1.

## Source

PayloadBlock.java (core/src/mindustry/world/blocks/payloads/):
PayloadBlockBuild.updateTile() :158-162 — `if(payload != null){` +
`payload.update(null, this);` (:160). The callee behaviour:
BuildPayload.update :52-57 (sets build.tile = emptyTile and calls
build.updatePayload), UnitPayload.update :51-53 (delegates to the
unit type). PayloadLoaderBuild extends
PayloadBlockBuild<BuildPayload> (PayloadLoader.java:86).

## Implementation

One pure-only pure (no tick wiring):
`source_payload_loader_payload_update_state(payload)` →
{payload_update_call} — null when the payload is null (the
`if(payload != null){` gate, PayloadBlock.java:159), else {method:
"payload.update", unit_holder: null, building_holder: "self",
payload_kind: "BuildPayload" | "UnitPayload"}. The callee's entity
behaviour is NOT ported — there is no live payload entity in the
port.

**Verify-first findings:**
- The N2231 payload contract carries NO kind key → kind is
  caller-supplied, default "BuildPayload" (Java-exact: the Loader
  extends PayloadBlockBuild<BuildPayload>, PayloadLoader.java:86).
- The call ALWAYS runs when payload != null:
  BuildPayload.update's gate (`if(unitHolder != null && ...)
  return;`, BuildPayload.java:53) short-circuits with the Loader's
  null unit holder — so no extra gate is modeled.
- **#139 confirmed NOT a duplicate** — the generic PayloadBlock
  entry noting the PMD call site (PayloadMassDriver.java:156) —
  left in place.

## Commits

- Slice: `a69b8d425` (5 files, +766/−1).
- Integration cherry-pick: `46a7c7b20` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_loader_super_update_tile_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (9 PayloadLoader modules): Ran 36 (27
PASS + 9 proof Godot-absent), 0 errors.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12369/1885/1837/3466** (exactly as
estimated). DEFERRED **#104 RESOLVED** (238→237, by entry TEXT).

## Godot debt

- NEW proof `C07PayloadLoaderSuperUpdateTileRowsProof` (6 keys:
  `update_call_build`, `update_call_unit`,
  `update_gate_null_holder`, `update_holders`, `update_kind`,
  `update_null`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
