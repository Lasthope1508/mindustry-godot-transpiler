# Report N2322 — UnitCargoLoader live canCreate check

**Slice:** N2322 — UnitCargoLoader live canCreate check (Units.canCreate pure over getCap via the N2140 bridge; frame can_create_inputs, permissive default). **Wave:** advances-12.
**Commit:** `ea28be9b` on `slice/N2322-unit-cargo-loader-can-create` (base `0b18eff8`).
**Files:** 6, +986/−10.

## Source

Java gates unit creation on the team cap: `Units.canCreate(team, unitType)`
(Units.java:115-117) over `getCap(team)` (Units.java:119–126 — the brief said
:120–125; signature is :119, uncapped :122–124, clamped return :125; cite
corrected by the worker). `canPlaceOn` is :65–68 (call at :66); :73 is the
drawPlace call. The UCL unitType is UnitTypes.manifold
(UnitCargoLoader.java:24); manifold has NO useUnitCap override
(UnitTypes.java:4568–4593) — keeps the default `useUnitCap = true`
(UnitType.java:205); the only `useUnitCap = false` in UnitTypes.java is :4612
(assemblyDrone). The N2234 pure takes `can_create: bool = true`
(SourceUnitCargoLoaderBuildState.gd:193) but the driver passed the defaults
null/true (:466), so the cap was never evaluated live.

## Implementation

New pure `source_unit_cargo_loader_can_create_state(frame)` → `{can_create,
cap}`, composing the existing N2140 helpers (`SourceUnitUpdateState.cap_state`
+ `SourceUnitRuntimeState.source_units_can_create_state`) instead of
duplicating math. Frame input `can_create_inputs` dict (11 keys);
absent/non-dict/empty → permissive `{true, 2147483647}` (driver const
`SOURCE_UNIT_CARGO_LOADER_UNIT_CAP_MAX`). The tick evaluates the pure before
the advance and passes the live verdict as the 5th arg.

**Follow-through 6th file:** the N2234 test pinned the 3-arg advance call
INCLUDING the closing paren → the worker updated it to the 5-arg call +
comment (N2314/N2315 precedent).

**⚠️ FLAG (fix slice for advances-13): the N2234 proof's live tick looks
STALE at base** — it stamps no nitrogen but expects efficiency 0.5 after
ticking; since the N2249 liquid row went live, an unstamped loader folds
efficiency to 0 (same class as N2176/N2213/N2227/N2222). Recorded in
STATUS.md. The N2322 proof stamps nitrogen explicitly and does not depend on
it.

## Commits

- Slice: `ea28be9b` (6 files, +986/−10).
- Integration cherry-pick: `4cf4bd92` (clean).

## Tests

Targeted (new module `tests.test_c07_unit_cargo_loader_can_create`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 20/20. Siblings
(UCL 5 modules) Ran 20 = 15 PASS + 5 proof, 0 other failures.
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11935/1757/1689/3170 (exactly the SCOPE
estimate): symbols `source_unit_cargo_loader_can_create_state_result.can_create`
/ `.cap`; audit stays 1336. DEFERRED 323 (−1 canCreate entry + 1 new: live
unit-count source).

## Godot debt

- NEW proof `C07UnitCargoLoaderCanCreateProof` (**8 keys** — the brief
  suggested 6; the worker added the permissive-default + live-tick keys, both
  core to the contract: `banned_type_cannot_create`, `can_create_below_cap`,
  `cannot_create_at_cap`, `live_tick_blocks_build_when_capped`,
  `no_cap_when_unit_cap_unused`, `permissive_default_without_inputs`,
  `uncapped_when_unit_cap_disabled`, `variable_cap_adds_team_bonus`) —
  written but NEVER run; debt in GOAL.md §5.
