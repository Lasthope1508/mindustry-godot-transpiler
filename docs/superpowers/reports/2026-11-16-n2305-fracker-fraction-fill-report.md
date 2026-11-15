# Report N2305 — Fracker live fraction fill

**Slice:** N2305 — Fracker live fraction fill delegates to N2292 SolidPump pure. **Wave:** advances-10.
**Commit:** `ab74a162` on `slice/N2305-fracker-fraction-fill` (base `fa627ace`).
**Files:** 5, +2026/−11.

## Source

`SolidPumpBuild.onProximityUpdate()` (SolidPump.java:150-159, inherited by
FrackerBuild — Fracker has NO onProximityUpdate override, Fracker.java:7
`Fracker extends SolidPump`); `canPump` (SolidPump.java:80-83);
`sumAttribute` (Block.java:575-582); fraction (SolidPump.java:124).

**Scope correction — the brief was WRONG about the def:** the brief said Fracker
sets NO attribute (inherits NULL) → fraction = validTiles only. REALITY: the
only Fracker def (oil-extractor, Blocks.java:2964-2979) sets
`attribute = Attribute.oil` (Blocks.java:2972) + `baseEfficiency = 0f`
(Blocks.java:2973, overriding the 1f class default) → validTiles is ALWAYS 0,
fraction = boost + env ONLY — the opposite of the brief. The worker implemented
the Java-correct version. Lesson: ALWAYS check the def in Blocks.java, not just
the class file (grep of Fracker.java found no attribute because it's set on the
def). Entry 35's cites (:118/:137-147) confirmed stale; the resolved DEFERRED
entry is #32 in the merged base, not #35 (the brief used older numbering).

## Implementation

Pure `source_fracker_proximity_fraction_state(linked_tiles, attribute_env)`
delegating to the N2292 SolidPump pure; consts `SOURCE_FRACKER_SIZE := 3`,
`SOURCE_FRACKER_BASE_EFFICIENCY := 0.0`; the wrapper binds size 3,
baseEfficiency 0f, has_attribute true. Tick wiring before the N2224 advance
(N2224's 7-key return verified still holding).

## Commits

- Slice: `ab74a162` (5 files, +2026/−11).
- Integration cherry-pick: `2eec2424` (clean).

## Tests

Targeted `tests.test_c07_fracker_fraction_fill`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Exact-evidence 30/30. Siblings Ran 44 = 33 PASS + 11 proof + Pump
Ran 28 = 20 PASS + 8 proof, 0 other failures.
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 11925/1750/1686/3164 (brief estimated +5
symbols — the pure mirrors N2292's 3 keys); audit stays 1336. DEFERRED 327
(325 − 1 entry #32 resolved + 3 new: linked-tiles live fill, attribute env live
fill, onProximityUpdate trigger).

## Godot debt

NEW proof `C07FrackerFractionFillProof` (6 keys:
`valid_tiles_zero_with_zero_base_efficiency`, `boost_sums_oil_attributes`,
`deep_floor_excluded_when_not_floating`, `fraction_clamps_at_zero`,
`env_adds_when_attribute_present`, `live_tick_fills_fraction`) — written but
NEVER run; debt in GOAL.md §5.
