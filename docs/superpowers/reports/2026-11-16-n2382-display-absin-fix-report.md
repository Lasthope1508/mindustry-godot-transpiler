# Report N2382 — Display-path absin fix (Mend + Overdrive)

**Slice:** N2382 — FIX SLICE: the display-path `top_alpha` passes
the DOUBLED absin scale, Java-exact. **Wave:** advances-20.
**Commit:** `0bc32f127` on `slice/N2382-display-absin-fix` (base
`7b99d3d63`). **Files:** 3, +34/−4.

## Source

Java: Mathf.java:78-80 (`absin(in,scl,mag) =
(sin(in, scl*2f, mag)+mag)/2f`); MendProjector.java:152 and
OverdriveProjector.java:145 — BOTH use `50f / Mathf.PI2` (verified
identical, so no scope reduction was needed).

## Implementation

One-token change in each display file: `50.0 /
source_math_defaults.PI2` → `100.0 /
source_math_defaults.PI2` in `SourceMendProjectorDisplayState.gd:86`
and `SourceOverdriveProjectorDisplayState.gd:69` (the formula is
untouched). The port helper `(sin(v/scl)*0.5+0.5)*mag` satisfies
helper(v, s) == Java(v, s/2), so the doubled scale is Java-exact —
matching the N2372 precedent
(`SourceMendProjectorBuildState.gd:693` already passes
`100.0 / SOURCE_PI2`). A repo-wide grep found the undoubled pattern
in exactly 4 places (2 display files + 2 pins) — all fixed. No
other display path uses the undoubled scale.

## Commits

- Slice: `0bc32f127` (3 files, +34/−4).
- Integration cherry-pick: `97a6940e1` (clean).

## Tests

RED confirmed first: the 2 pin tests failed exactly on the 100.0
assert. GREEN: targeted 3/3 PASS (2 pins in `test_playable.py` +
new arithmetic pin test
`test_display_path_absin_doubled_scale_matches_java_absin` —
helper(v, 100/PI2) == Java absin(v, 50/PI2) at v = 0, 25, 50, 100,
157, 314, places=9, plus a not-equal check at v=25 proving the
undoubled scale genuinely differs); siblings 3/3 PASS; extra
math-helper neighbours 2/2 PASS. **Total 8/8, 0 errors.**
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT **+0**, DEFERRED 0 — fix slice, no register, no new module,
no proof. Closes the N2372 follow-through item ("display path
passes undoubled 50/PI2").

## Godot debt

- No new proof. **No re-run needed:** the only `top_alpha` proof
  hit pins `top_alpha == 0.0` only in the HIDDEN (lod_l2=false)
  branch (`C07MendProjectorDrawRowsProof.gd:130`), unaffected by
  the scale change. No proof pins oscillation speed.
  `test_source_symbols.py` pins are Java-verbatim `java_expr`
  strings (still `50f / Mathf.PI2` in Java) — correctly untouched.
