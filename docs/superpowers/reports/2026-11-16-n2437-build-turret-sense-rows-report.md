# Report N2437 — BuildTurret sense / senseObject rows

**Slice:** N2437 — BuildTurret sense() + senseObject(): two
pure-only pures model the unit delegation for buildX/buildY and
building/breaking, with the super fallback otherwise. **Wave:**
advances-27. **Commit:** `62d0d7092` on
`slice/N2437-build-turret-sense-rows` (base `91ee0f1dc`). **Files:**
5, +994/−1.

## Source

sense() (BuildTurret.java:281-287): switch(sensor){ case buildX,
buildY -> unit.sense(sensor); default -> super.sense(sensor); }.
senseObject() (:289-295): switch(sensor){ case building, breaking
-> unit.senseObject(sensor); default -> super.senseObject(sensor);
}. The unit is the BlockUnitc currently building — a live object
the pure never queries directly.

## Implementation

Two pures (the N2387/N2390/N2391 precedent):
- `source_build_turret_sense_state(sensor, unit_build_x,
  unit_build_y, super_value=null)` → `{value, delegated}` —
  buildX/buildY return the caller-supplied unit plan coordinate,
  other sensors return caller-supplied super_value.
- `source_build_turret_sense_object_state(sensor, unit_building,
  unit_breaking, super_value=null)` → `{value, delegated}` —
  building/breaking return the caller-supplied unit descriptor
  (Variant null-or-dict), other sensors return super_value.
Driver docstring: added "(8) Sense rows live (N2437)"; the trailing
line now reads "Read / write (BuildTurret.java:259-278) wait for
their own slices."

**Findings beyond the brief (all Java-verified):**
1. The brief said "arc LAccess" — WRONG: LAccess is
   `mindustry.logic.LAccess` (mindustry-upstream, not
   arc-upstream). Exact tokens: buildX/buildY (LAccess.java:
   54-55), building/breaking (:59-60).
2. `unit.sense(buildX/buildY)` = the plan tile x/y, or −1 when
   not building (UnitComp.java:290-291);
   `unit.senseObject(building/breaking)` = the plan tile's build,
   or null (UnitComp.java:323-324). The pure only delegates; it
   never computes −1/null itself.
3. **The super defaults differ between the two overloads:** the
   sense default is Float.NaN → null (BuildingComp.java:2123),
   but the senseObject default is the sentinel `noSensed`
   (BuildingComp.java:2134; `Object noSensed = new Object();`,
   Senseable.java:6) — NOT null. The port models noSensed as
   value null + no_sensed true (the canonical sense_object_state
   precedent); the noSensed→numeric fallback lives in the logic
   executor (LExecutor.java:697-700), not in this pure. The proof
   key `sense_object_default_super` pins both faces (type via
   super + no_sensed true).
4. A stale line already in the driver, NOT from this slice (left
   untouched, N2431 also left it): "The draw / write / read /
   sense rows (BuildTurret.java:232-319) wait for their own
   slices." still claims draw + sense wait for their own slices
   even though both are live (N2431, N2437) — a cleanup candidate
   for a later coordinator/fix slice.

## Commits

- Slice: `62d0d7092` (5 files, +994/−1).
- Integration cherry-pick: `d13076509` (clean).

## Tests

Targeted (new module `tests.test_c07_build_turret_sense_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). RED confirmed first
(failures=2, errors=2).
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+2/+4** → 12222/1852/1787/3366 (exactly
as estimated; 4 result symbols — value + delegated × 2 pures).
Generated diff purely additive (+678/−0, 6 files: 4 canonical +
shards `defense_api_contracts.json` + `defense_slices.json`); no
manifest drift, no audit-report change. DEFERRED **#90 RESOLVED**
(273→272, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07BuildTurretSenseRowsProof` (6 keys:
  `sense_build_x_delegate`, `sense_build_y_delegate`,
  `sense_default_super`, `sense_object_building_delegate`,
  `sense_object_breaking_delegate`, `sense_object_default_super`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
