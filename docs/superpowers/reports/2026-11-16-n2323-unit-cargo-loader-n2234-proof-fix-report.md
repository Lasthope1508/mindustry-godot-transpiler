# Report N2323 — UnitCargoLoader N2234 proof fix (seed nitrogen 1.0)

**Slice:** N2323 — fix N2234 proof (seed nitrogen 1.0 on the sprite liquids
meta before the live tick; the live tick went stale when the N2249 liquid
row went live). **Wave:** advances-13.
**Commit:** `4d3cf69a` on `slice/N2323-ucl-n2234-proof-fix` (base `4349a660`).
**Files:** 1, +21/−1.

## Source

The unit-cargo-loader def consumes nitrogen 10f/60f
(`consumeLiquid(Liquids.nitrogen, 10f / 60f);`, Blocks.java:2279 — the brief
said :2277; cite corrected by the worker). The N2249 liquid row is live, so
the folded efficiency is the min over power + liquid and an unseeded loader
folds 0. The N2234 proof's live-tick key `live_tick_advances_cargo_frame`
(proof :99–154 after the fix; :94–134 at base) stamps power_status 0.5 but
seeded no nitrogen, so it expected efficiency 0.5 after ticking while the
live fold gives 0 — STALE since N2249. Same class as N2176/N2213/N2227/N2222
(fixed by N2309–N2312), N2195 (N2300), N2223/N2273 (N2302/N2303). The
pure-call keys are NOT stale (they call the advance directly with explicit
efficiency) — only the live tick needed the seed.

## Implementation

FIX slice: the proof seeds nitrogen 1.0 on the sprite liquids meta before
the first tick (the N2322 pattern, `source_set_state` over
`SOURCE_BUILDING_LIQUIDS_META_KEY`); the driver syncs that same dict
reference into the frame each tick, so the live liquid row folds 1.0 and the
min stays the stamped power 0.5. Two ticks at eff 0.5 consume
2 × (10/60 × 0.5) = 1/6 ≈ 0.167 nitrogen, so the 1.0 seed has a 6× margin
and no re-seed is needed. 3 new preloads (SourceLiquidModuleState,
SourcePlacedBlockState, SourceContentRegistryRuntimeState) to resolve the
nitrogen id from the liquid catalog. No driver, test, or register change —
no ledger entry, SSOT +0.

## Commits

- Slice: `4d3cf69a` (1 file, +21/−1).
- Integration cherry-pick: `45853d27` (clean).

## Tests

Targeted (existing module `tests.test_c07_unit_cargo_loader_update_tile`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Siblings (UCL modules) Ran
16 = 12 PASS + 4 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT +0 (fix slice, no ledger entry, no new symbols); audit stays 1336.
DEFERRED unchanged.

## Godot debt

- RE-RUN of N2234 proof `C07UnitCargoLoaderUpdateTileProof` (fixture
  changed — nitrogen seed added) — never run; debt in GOAL.md §5. No new
  proof.
