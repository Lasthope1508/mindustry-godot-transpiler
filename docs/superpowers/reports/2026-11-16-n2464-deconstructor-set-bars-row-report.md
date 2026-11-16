# Report N2464 — PayloadDeconstructor setBars row

**Slice:** N2464 — PayloadDeconstructor setBars: one pure-only pure
models the progress bar (bar.progress label + Pal.ammo + raw
progress fraction). **Wave:** advances-31. **Commit:** `f3e39b2de`
on `slice/N2464-deconstructor-set-bars-row` (base `43a5c79ad`).
**Files:** 5, +746/−1.

## Source

PayloadDeconstructor.java (core/src/mindustry/world/blocks/payloads/):
setBars :45-49: `super.setBars(); addBar("progress",
(PayloadDeconstructorBuild e) -> new Bar("bar.progress", Pal.ammo,
() -> e.progress));` `progress` is the build field
(PayloadDeconstructor.java:54) — the N2276 advance tracks it as
frame["progress"] (driver :195).

## Implementation

One pure-only pure (no tick wiring):
`source_payload_deconstructor_bar_state(progress)` → `{label,
color, fraction}`. label = "bar.progress" (the Bar constructor takes
the bundle KEY directly here — NOT a Dict; the N2450 Dict form
applies only when Java calls Core.bundle.format with args, which
this bar does not). color = "Pal.ammo" (token, Pal.java:64,
`ff8947`). fraction = progress RAW — the pure does NOT clamp (Bar
clamps [0,1] at render).

**Verify-first finding (1 deviation, conclusion unchanged):**
the brief cited the clamp as "Bar.java:33/:80". Verify: **:33 is
the clamp in the Prov-form constructor** (Bar.java:31-40) — this bar
does NOT use that form. This bar uses the 3-arg String ctor
(:23-29); the ctor stores RAW (`lastValue = value =
fraction.get();`, :27); the clamp is only at draw (:80). The pure
still does NOT clamp — the correction is recorded in driver +
register + test comments. Everything else in the brief was exact:
`addBar("progress", ...)` (PayloadDeconstructor.java:48),
`bar.progress = Build Progress` (bundle.properties:1299).

## Commits

- Slice: `f3e39b2de` (5 files, +746/−1).
- Integration cherry-pick: `b7419dffc` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_deconstructor_bar_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). RED before GREEN confirmed (registration/exact
KeyError N2464, state missing pure). Neighbours (11
PayloadDeconstructor modules): Ran 44 (33 PASS + 11 proof
Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12344/1879/1827/3446 (exactly
as estimated). Symbols:
`source_payload_deconstructor_bar_state_result.{label, color,
fraction}`. DEFERRED **#3 RESOLVED** (246→245, by entry TEXT; no
new entry).

## Godot debt

- NEW proof `C07PayloadDeconstructorBarRowsProof` (6 keys:
  `bar_label`, `bar_color`, `bar_fraction_zero`,
  `bar_fraction_half`, `bar_fraction_full`,
  `bar_fraction_raw_overfull`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
