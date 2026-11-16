# Report N2391 — ImpactReactor sense rows

**Slice:** N2391 — ImpactReactor `sense()` rows: `sense(LAccess.heat)`
= warmup + the `warmup()` accessor. **Wave:** advances-21.
**Commit:** `cc54e928e` on `slice/N2391-impact-reactor-sense-rows`
(base `d35c67781`). **Files:** 5, +935/−2.

## Source

Java: ImpactReactor.java:119-122 (the `sense` override —
`sense(LAccess.heat)` returns `warmup`), :104-106 (`warmup()`
returns the raw warmup field), :124-127 (the `write()` override —
NOT the sense cite); PowerGenerator.java:105 (the parent
`warmup()` returns `productionEfficiency` when enabled — the
ImpactReactorBuild override returns the raw field instead);
DrawPlasma.java:32, 42 (the drawer scales light/alpha by
`build.warmup()`).

## Implementation

**2 pures, not 1** — the call shape differs:
- `source_impact_reactor_sense_state(sensor, warmup, super_value =
  null)` — heat returns the frame warmup **directly** (no clamp,
  no ratio — unlike the N2383 MendProjector progress clamp); other
  sensors return the caller-supplied `super_value` (null = the
  BuildingComp default branch). Result symbols: `value`,
  `is_heat`.
- `source_impact_reactor_warmup_state(warmup)` — `warmup()` is
  called by the **drawer** (DrawPlasma scales light/alpha by
  `build.warmup()`), not by logic, so a drawer caller must not go
  through a sensor dispatch Java never gives it. Result symbol:
  `value`.

**Pure-only, verified:** grep finds no tick call site for
sense/warmup in the driver (comments only).

**Corrections worth knowing (verified against upstream Java):**
1. The driver docstring claiming no sense override existed was
   WRONG — fixed in this slice. The sense override exists at
   ImpactReactor.java:119-122; the DEFERRED cite :124-127 is the
   `write()` override. No existing test pinned the wrong docstring
   line (verified by grep before editing).
2. **The brief itself was off on `warmup()`:** it said :114-116,
   but that is `ambientVolume()`. `warmup()` is at
   ImpactReactor.java:104-106 — cited correctly everywhere (test,
   register, driver, proof).

## Commits

- Slice: `cc54e928e` (5 files, +935/−2).
- Integration cherry-pick: `e0edc682f` (clean).

## Tests

Targeted (new module `tests.test_c07_impact_reactor_sense_rows`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+2/+4** → 12054/1813/1742/3276 (3 symbols:
`source_impact_reactor_sense_state_result.value`, `.is_heat`,
`source_impact_reactor_warmup_state_result.value`). Audit stays
1336. DEFERRED **306 → 305** (resolves #96, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07ImpactReactorSenseRowsProof` (6 keys:
  `sense_heat_zero`, `sense_heat_partial`, `sense_heat_full`,
  `sense_super_sensor`, `sense_super_default`,
  `sense_live_frame_values` (live frame: warmup 0.5 → one N2192
  advance tick at delta 60.0 → 0.53, sensed by both pures)) — the
  warmup pure is checked inside the heat-zero/partial/full and
  live-frame keys — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the logic call site for `sense()` (port-wide
  logic-executor concern) and the drawer call site for `warmup()`
  (under the existing ImpactReactor draw rows entry) — both
  intentionally undeferred here, no new DEFERRED entries.
  Read/write rows (ImpactReactor.java:125-134) still wait under
  their existing entry.
