# Report N2421 — RepairTurret draw / drawBeam / drawSelect / drawPlace / icons rows

**Slice:** N2421 — RepairTurret drawBeam (static) + draw() +
drawSelect + drawPlace + icons(): a new pure-only draw pure models
all of them, with the drawBeam RNG draws as caller-supplied inputs.
**Wave:** advances-25. **Commit:** `6326660ee` on
`slice/N2421-repair-turret-draw-rows` (base `e4e57bca3`). **Files:**
5, +1181/−1.

## Source

icons() (RepairTurret.java:102-104): `{baseRegion, region}`.
drawPlace (:95-99): super + `Drawf.dashCircle(x*tilesize+offset,
y*tilesize+offset, repairRadius, Pal.accent)`. drawSelect (:177-179):
`Drawf.dashCircle(x, y, repairRadius, Pal.accent)`. draw() (:164-174):
rect(baseRegion); z Layer.turret; shadow(region, x-size/2, y-size/2,
rotation-90); rect(region, x, y, rotation-90); drawBeam(...).
drawBeam (static, :106-150): rand.setSeed(id + target id); if target
!= null: origin = pos + trns(rotation, length); lastEnd = target -
origin, setLength(max(2, len)); lastEnd += offset.trns(rand.random(360f)
+ Time.time/2f, sin(Time.time + rand.random(200f), 55f,
rand.random(hitSize*0.2, hitSize*0.45))).rotate(target rotation); +=
origin. If strength > 0.01: z Layer.flyingUnit+1; f = (Time.time/85 +
rand.random(1)) % 1; alpha 1-Interp.pow5In(f); stroke(strength*
pulseStroke); circle(lastEnd, 1 + f*pulseRadius); laser + laserTop
(Drawf.laser, width strength*beamWidth).

## Implementation

One pure-only draw pure `source_repair_turret_draw_state` (18
explicit params) returning `base_call`, `shadow_call`, `region_call`,
`beam_call` (null when strength ≤ 0.01), `select_call`, `place_call`,
`icon_regions`, plus `last_end`/`offset_after`/`beam_seed`
diagnostics. **No RNG in the pure:** the 4 rand draws (angle 360f,
phase 200f, magnitude range, f 1f) are caller-supplied roll inputs;
the pure computes the beam geometry deterministically from them
(same convention as caller-supplied `time_value`).

**Findings beyond the brief (all source-backed):**
1. **Shadow shift is FLOAT, not int:** Java is `size / 2f` — the
   repair-point (size 1) shifts 0.5, the inverse of the N2396
   MassDriver int-division trap. Proof asserts both 1.0 and 0.5.
2. **drawBeam DISCARDS the input offset:** `offset.trns(...)` SETS
   the vector (arc Vec2.java:40-42), so the pre-draw offset value is
   unused; the pure reports `offset_after` = the jitter vector Java
   overwrites it with (unchanged when target is null).
3. **setLength no-op at len 0** (arc Vec2.java:299-308): a target
   exactly at the beam origin leaves lastEnd (0,0) — the pure guards
   the divide; proof covers it (rotation 0, exact origin) plus the
   min-length-2 stretch.
4. **The two drawBeam branches are independent:** the target branch
   runs even at strength ≤ 0.01 (lastEnd still updates); the beam
   draws even with a null target (at held lastEnd). Proof asserts
   both.
5. **Arc 3-arg sin** is `sin(radians/scl)*mag` (Mathf.java:90-92),
   computed with plain GDScript `sin()` per the N2415 precedent
   (Java's table lookup differs by <1e-3); proof uses `roll_phase =
   55π/2` so the sin is exactly 1.

## Commits

- Slice: `6326660ee` (5 files, +1181/−1).
- Integration cherry-pick: `24d59a815` (clean).

## Tests

Targeted (new module `tests.test_c07_repair_turret_draw_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). All 59 EXACT_EXPRS verified verbatim in
upstream.
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+1/+2** → 12138/1838/1770/3332 (**variance
vs the +6 estimate:** the 7th symbol is `icon_regions`, registered
per the N2396 precedent). Audit stays 1336. DEFERRED **#52
RESOLVED** (286→285, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07RepairTurretDrawRowsProof` (6 keys:
  `draw_base_shadow_region`, `draw_beam_with_target`,
  `draw_beam_weak_strength`, `draw_beam_target_null`,
  `draw_select_place`, `draw_icons`) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
