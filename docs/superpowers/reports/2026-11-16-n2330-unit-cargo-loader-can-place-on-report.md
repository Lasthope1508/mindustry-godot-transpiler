# Report N2330 — UnitCargoLoader canPlaceOn placement gate

**Slice:** N2330 — UnitCargoLoader canPlaceOn placement gate (composes the N2322
canCreate verdict; Block default `canPlaceOn` is true). **Wave:** advances-14.
**Commit:** `23850af0` on `slice/N2330-ucl-can-place-on` (base `f3f7af8e`).
**Files:** 5, +790/−1.

## Source

Java: `canPlaceOn` = `super.canPlaceOn(...) && Units.canCreate(team, unitType)`
(UnitCargoLoader.java:65-68; method body is actually :65-67, :68 is a blank line —
the worker kept the :65-68 cite for consistency with the DEFERRED entry and the
N2322 note). `Block.canPlaceOn` returns TRUE (Block.java:606-608, `return true;`
at :607), so the gate collapses to the N2322 verdict. `Units.canCreate`
(:115-117) / `getCap` (:119-126) as verified by N2322. drawPlace :70-75 (cap
warning, `canCreate` call at :73) defers to its own slice.

## Implementation

New pure `source_unit_cargo_loader_can_place_on_state(frame)` →
`{can_place_on}`: composes `source_unit_cargo_loader_can_create_state` (N2322,
via the N2140 bridge); the super call is modeled as `true` (Block default).
Documented limits (4) records canPlaceOn live (N2330); bar/draw/read-write
still defer; (6) drops "stays out of scope". No tick change, no follow-through
(the N2322 test pins the canCreate tick wiring — untouched; `can_create_inputs`
is exactly 11 keys).

## Commits

- Slice: `23850af0` (5 files, +790/−1).
- Integration cherry-pick: `952d1a64` (clean).

## Tests

Targeted (new module `tests.test_c07_unit_cargo_loader_can_place_on`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 8/8.
Siblings Ran 20 = 15 PASS + 5 proof, 0 other failures.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11961/1770/1702/3196 (exactly the SCOPE
estimate): symbol
`source_unit_cargo_loader_can_place_on_state_result.can_place_on`;
audit stays 1336. No shard changed (`unit_building_slices` only selects
UnitFactory.java, `block_slices` only selects Block.java).
DEFERRED 329→330 (−1+2: resolved #2 canPlaceOn / Units.canCreate rows;
added drawPlace rows :70-75 + live placement call site — the pure is live
but no placement path calls it yet; the `can_place_on_hook` at
SourceBlockGeometry.gd:1149-1151 has no caller passing a UCL hook, default
Block true).

## Godot debt

- NEW proof `C07UnitCargoLoaderCanPlaceOnProof` (6 keys:
  `can_place_on_when_can_create`, `cannot_place_on_when_capped`,
  `permissive_default_without_inputs`, `banned_type_cannot_place`,
  `no_cap_when_unit_cap_unused`, `uncapped_when_unit_cap_disabled`) — written
  but NEVER run; debt in GOAL.md §5. Pure-only proof, NO live-tick key —
  canPlaceOn is a placement gate, not tick wiring (per the brief).
