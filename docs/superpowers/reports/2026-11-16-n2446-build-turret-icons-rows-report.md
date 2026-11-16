# Report N2446 — BuildTurret icons rows (amend N2431 draw pure)

**Slice:** N2446 — BuildTurret icons(): an AMEND slice (the fix
precedent N2416/N2424) that adds the `icon_regions` key to the
already-registered N2431 draw pure and fixes the stale driver
line. NO new pure, NO new ledger entry, NO new proof — the N2431
proof file is untouched, so no re-run is created. **Wave:**
advances-28. **Commit:** `179a6597e` on
`slice/N2446-build-turret-icons-rows` (base `682c75eb9`).
**Files:** 3, +58/−39.

## Source

icons() (BuildTurret.java:88-90): `return new TextureRegion[]{
baseRegion, region};`. draw :234-251, write :259-264, read
:267-278, sense :281-287, senseObject :289-295.

## Implementation

- `source_build_turret_draw_state` in
  SourceBuildTurretBuildState.gd returns the new result key
  `icon_regions` = `["baseRegion", "region"]` (`var icon_regions:
  Array = ["baseRegion", "region"]`, the N2433 StackRouter
  precedent). No separate icons() pure — a 0-arg pure FAILS the
  register (the N2396 precedent).
- The N2431 register
  (`register_c07_build_turret_draw_rows.py`) was amended IN PLACE
  (upsert REPLACES the whole entry — the N2435 lesson — so no new
  register was written): `icon_regions` added to the draw outputs
  (Array, java_expr `return new TextureRegion[]{baseRegion,
  region};`), by_slice list now 6 symbols, EXACT_EXPRS + 2 icons
  exprs, DEFERRED replaced with the merged advances-27 base (266)
  minus entry #266 → 265 entries (verified identical to
  base-minus-266 by parsed-list comparison).
- The stale driver line :129 was rewritten: "The draw rows are
  live (N2431, + icons N2446), the sense rows are live (N2437);
  the write / read rows (BuildTurret.java:259-278) wait for their
  own slices." (write/read range verified first in
  BuildTurret.java: write :259-264, read :267-278); the
  documented-limits (7) notes icons N2446.
- The N2431 test module pins were updated (registration pin: 6
  symbols + deferred count 279 → 265 + assert the icons entry
  absent; state test pins both icons exprs, the `var icon_regions`
  line, and the `"icon_regions": icon_regions,` return key). The
  breaking pin was the exact `source_symbols` list in the
  registration test (not an exact-dict assert as the brief
  guessed) — updated, not loosened.

**Verify-first findings:**
- No test pinned the stale :129 phrase (grep for `232-319` in
  tests: no hits), so the line was rewritten freely; the new text
  avoids the sense test's `assertNotIn` phrase (`Read / write /
  sense (BuildTurret.java:259-295) wait for their own slices.`).
- `test_source_symbols.py` has no N2431 pins (only unrelated
  N1666/N1732 icon_regions matches) — no update needed.
- The DEFERRED swap also drops entries resolved by waves
  advances-26/27 (the base moved from advances-25 to
  advances-27) — an expected consequence of the rebase, not a
  scope change. At SSOT merge this shows as 15 DEFERRED entries
  leaving the N2431 ledger snapshot (all resolved by
  advances-26/27) plus `build_call`/rotation reorder noise from
  the upsert; the registry keeps all 6 draw symbols.

## Commits

- Slice: `179a6597e` (3 files, +58/−39).
- Integration cherry-pick: `00eb2bcf9` (clean).

## Tests

Targeted (existing module `tests.test_c07_build_turret_draw_rows`,
no new module): Ran 4, 3/4 PASS (registration, exact-evidence,
row-state) + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15). The
proof file is untouched (0 diffs under `runtime_proofs/`).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+0/+0/+0** → 12260/1858/1793/3378 (exactly
as estimated; 1 symbol:
`source_build_turret_draw_state_result.icon_regions`, registered
under N2431 with `java_source` BuildTurret.java). DEFERRED **#266
RESOLVED** (266→265, by entry TEXT — confirmed 1-based entry
#266, the last entry of the 266-entry advances-27 base; no new
entry).

## Godot debt

- NO new proof (amend slice — the N2431 proof already covers the
  draw pure; the `icon_regions` key is pinned by the pin/live
  tests, not the proof file).
- NO re-run (the N2431 proof file is untouched).
