# Report N2416 — Fix duplicate `var filled` redeclarations (Godot parse error)

**Slice:** N2416 — fix slice: the SECOND real Godot error reported by
the user (reviewing wave-23): duplicate `var filled` declarations in
the same tick function, a GDScript parse error that blocks the proof
from launching. **Wave:** advances-25 (took number N2416; the scoped
draw/bar wave shifted +1 to N2417–N2423, the N2337 precedent).
**Commit:** `038b47a7a` on `slice/N2416-fix-duplicate-var-filled`
(base `da035c391`). **Files:** 9, +180/−21.

## Source

GDScript forbids redeclaring a local in the same function scope. Three
tick functions declared `var filled` more than once:
- `SourceFrackerBuildState.gd`, `source_fracker_tick_buildings_state`
  (:588): :802 linked-tiles fill (N2414), :806 proximity fraction
  (N2305), :853 dump-liquid neighbour fill (N2408) — THREE.
- `SourceBeamDrillBuildState.gd`,
  `source_beam_drill_tick_buildings_state` (:859): :1161 facing-tiles
  fill (N2339), :1226 dump neighbour fill (N2405).
- `SourceSolidPumpBuildState.gd`,
  `source_solid_pump_tick_buildings_state` (:489): :616 proximity
  fraction (N2292), :664 dump neighbour fill (N2411).

The user hit the Fracker :832 (wave-23 numbering) and BeamDrill :1226
errors on branch `integration/wave-advances-23-n2402-n2408`; the
SolidPump one and the Fracker third declaration exist only on the
newest line. All line numbers verified 100% by grep before the fix.

## Implementation

Keep the FIRST `filled` declaration in each function, rename the later
ones (+ their write-back `.get(...)` uses): Fracker :806 →
`fraction_filled`, :853 → `dump_filled`; BeamDrill :1226 →
`dump_filled`; SolidPump :664 → `dump_filled`. Driver diff is 21+/21−
renames only — no logic, call order, or pure-signature change.

**Whole-repo sweep:** 16 files contain `var filled`; only the 3
functions above violate (Fracker x3, BeamDrill x2, SolidPump x2).
After the fix: 0 violations. Separator/BurstDrill/ItemBridge/
MassDriver/Deconstructor/Pump/LiquidBridge/Unloader/WallCrafter each
have 1 — clean.

**Finding beyond the brief: 5 test files needed pin updates.** No test
pinned the `var filled = ...` string, but 8 pins cover the write-back
`filled.get(...)` / `filled[...]` strings — without updating them, 5
targeted modules would FAIL (not Godot-absent). Per the brief's
verify-first instruction (and the N2235 precedent), the pins were
updated to the new names (string-only change, no assertion-logic
change): test_c07_fracker_fraction_fill (:190–191),
test_c07_fracker_linked_tiles_live_fill (:208–209),
test_c07_fracker_dump_liquid_neighbour_live_fill (:202),
test_c07_beam_drill_dump_neighbour_live_fill (:197, :201),
test_c07_solid_pump_dump_neighbour_live_fill (:197). Total 9 files,
over BRIEF-COMMON's 5-file limit but required by the brief's own
verify-first direction. Proof `.gd` files have their own local
`filled` (not driver pins) — untouched.

**Backport (done by the main agent, not this slice):** commit
`bbcd71e88` on `integration/wave-advances-23-n2402-n2408`, pushed +
ls-remote verified 17:00 — Fracker :785 → fraction_filled, :832 →
dump_filled; BeamDrill :1226 → dump_filled; test pins updated (5
files, 13 insertions). SolidPump was NOT backported (only 1 `var
filled` on wave-23). Targeted on wave-23: Ran 12 (9 PASS + 3 proof
Godot-absent). Note: the backport renamed :785 too (this slice kept
the first declaration as `filled`); both variants pass.

## Commits

- Slice: `038b47a7a` (9 files, +180/−21).
- Integration cherry-pick: `99ae94aeb` (first attempt failed
  transiently — filesystem hiccup, same class as the worktree-add
  flakes; retry clean, content identical: 9 files, 180+/21−).

## Tests

New module `tests.test_c07_duplicate_var_filled_fix` (3 tests: count
≤1 per tick function, new names + write-backs exist, whole-repo
sweep): RED before the fix (Ran 3, failures=3), GREEN after (3/3
PASS). Targeted + neighbours (13 modules): Ran 51, 39 PASS + 12
failures, all 12 proof tests failing exactly Godot-absent
(`AssertionError: unexpectedly None`), 0 other errors. Correct module
name: `test_c07_beam_drill_facing_tiles_fill` (plural — the brief
misspelled it).
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT **+0/+0/+0/+0** (the N2337/N2409/N2413 fix-slice precedent —
rename-only fix, no ledger entry). DEFERRED unchanged.

## Godot debt

- No new proof. No re-run (no proof file changed; the fix only
  unblocks parsing).
- The user can re-run the wave-23 proofs after pulling
  `integration/wave-advances-23-n2402-n2408` (tip `bbcd71e88`).
