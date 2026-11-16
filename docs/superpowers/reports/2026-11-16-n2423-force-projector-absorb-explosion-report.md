# Report N2423 — ForceProjector absorbExplosion rows

**Slice:** N2423 — ForceProjector absorbExplosion(): a new pure-only
pure models the absorb gate, hit, and buildup delta. **Wave:**
advances-25. **Commit:** `e14717dfd` on
`slice/N2423-force-projector-absorb-explosion` (base `e4e57bca3`).
**Files:** 5, +866/−1.

## Source

absorbExplosion (ForceProjector.java:269-277): `boolean absorb =
!broken && Intersector.isInRegularPolygon(sides, x, y, realRadius(),
shieldRotation, ex, ey); if(absorb){ absorbEffect.at(ex, ey); hit =
1f; buildup += damage * crashDamageMultiplier; } return absorb;`
`public float crashDamageMultiplier = 2f;` (ForceProjector.java:45).
realRadius() = (radius + phaseHeat * phaseRadiusBoost) * radscl
(:279-281) — live since the N2235 advance (result key real_radius).
Callers verified: Damage.java:113 (`s.absorbExplosion(x, y,
damagePerWave)`) and UnitComp.java:906 (`s.absorbExplosion(x, y,
crashDamage)`) — explosion handling, not updateTile.

## Implementation

One pure-only pure
`source_force_projector_absorb_explosion_state(broken, ex, ey,
damage, sides, building_x, building_y, real_radius,
shield_rotation, hit, crash_damage_multiplier =
SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER)` — **REUSES**
`source_force_projector_is_in_regular_polygon` from N2235 (signature
verified first), no re-port; **pure-only, no tick wiring** (test pin:
only 1 call-shaped occurrence in the driver — the definition itself).
New const `SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER := 2.0`
(class value :45, no def override). Returns `absorb`, `hit_value`
(1f when absorb, else the incoming hit), `hit_set` (true only when
absorb — distinguishes "just set" from "already 1f"), `buildup_delta`
(damage×2f when absorb, else 0). The N2235 docstring was updated
("absorbExplosion … is NOT updateTile and is not ported here" → live
N2423, only FX defers).

**Findings beyond the brief:** Java line numbers corrected —
absorbExplosion is :269–277 (the old N2235 note said :271–281);
`ExplosionShield` interface method is at :6 (first written :7, fixed
after grep); `broken = true` is at :165 (the N2235 docstring says
:167 — used :165 in this register, other N2235 text untouched).

## Commits

- Slice: `e14717dfd` (5 files, +866/−1).
- Integration cherry-pick: `cb82243e2` (clean).

## Tests

Targeted (new module
`tests.test_c07_force_projector_absorb_explosion`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). 30/30 EXACT_EXPRS verified verbatim. Sibling
check: the N2235 module still holds 3/4 PASS + proof Godot-absent
(the docstring edit broke nothing).
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12135/1838/1770/3332 (**variance
vs the +3 estimate:** the brief's design splits hit into 2 keys
(hit_value + hit_set) + absorb + buildup_delta = 4 symbols; the est
seems to have counted hit as 1 key). Audit stays 1336. DEFERRED
**#148 RESOLVED + 1 narrow entry ADDED** (the absorbEffect FX row —
precedent PayloadDeconstructor Fx.breakBlock / LaunchPad launch
sound): the register list is 290 (it copied the N2415 list, a
stale base — the coordinator merged by entry TEXT, taking only the
genuine delta: remove #148 + add the FX entry).

## Godot debt

- NEW proof `C07ForceProjectorAbsorbExplosionProof` (6 keys:
  `absorb_true_inside_polygon`, `absorb_false_outside_polygon`,
  `absorb_false_when_broken`, `buildup_delta_math`, `hit_set`,
  `edge_damage_zero`) — written but NEVER run; debt in GOAL.md §5.
  Proof geometry verified with a Python port of the same ray-cast
  algorithm (9/9 checks OK, incl. (95,50) outside the hexagon but
  inside the rect, and (0,95) outside at rotation 0 but inside at
  rotation 30).
- No old proof needs a re-run (pure-only, no tick wiring).
