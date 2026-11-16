# Report N2481 — SolidPump updateEffect chance rows

**Slice:** N2481 — SolidPump updateEffect chance rows
(DEFERRED #90; the dump half of the old combined entry is live
since N2286 — this slice is ONLY the effect chance). **Wave:**
advances-33. **Commit:** `97777de7b` on
`slice/N2481-solid-pump-update-effect-chance-rows` (base
`08b822909`). **Files:** 5, +857/−3.

## Source

SolidPump.java (core/src/mindustry/world/blocks/production/):
- updateEffect Fx.none :23 (class default);
  updateEffectChance 0.02f :24.
- Chance gate :131-132: `if(Mathf.chance(delta() *
  updateEffectChance)) updateEffect.at(x + Mathf.range(size *
  2f), y + Mathf.range(size * 2f));` — INSIDE the pump branch
  (`efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f`,
  :125-126).

## Implementation

One pure-only chance row (no tick wiring — the effect call
sites that would spawn the Fx effect wait for renderer/effect
slices, the N2421 draw precedent):
`source_solid_pump_update_effect_chance_state(pump_branch_open,
source_delta, time_scale, update_effect_chance, update_effect,
x, y, chance_roll, range_roll_x, range_roll_y)` →
{effect_call} — {effect: <updateEffect token>, x, y} when the
gate passes and the roll hits, null otherwise.

**Verify-first findings:**
- **NO RNG in the pure** (the N2421/N2468 precedent): the
  chance roll + the two position rolls are caller-supplied
  already-rolled inputs — the position rolls arrive
  ALREADY-RANGED (the N2421 magnitude precedent), so the pure
  never sees the size, only the offsets.
- **Mathf.chance is `return d >= 1f || rand.nextFloat() < d;`**
  (arc Mathf.java:240-241) — the d >= 1f short-circuit fires
  unconditionally, and the comparison is STRICT < (a roll
  exactly at the threshold misses).
- Mathf.range(r) is random(-r, r) (arc Mathf.java:220-221), so
  the position rolls span [-size * 2f, size * 2f] = [-4f, 4f]
  for the size-2 water-extractor (Blocks.java:2924).
- delta() is Time.delta * timeScale (BuildingComp.java:
  1922-1923); the pure takes source_delta + time_scale like
  the N2220 advance (the family precedent) and computes delta
  inside.
- **The water-extractor def overrides NEITHER updateEffect
  nor updateEffectChance** (Blocks.java:2920-2930 — the
  Blocks.java updateEffect hits are Drill defs and the Fracker
  oil-extractor), so the live call records the Fx.none token
  (`none = new Effect(0, 0f, e -> {}),`, Fx.java:30) — the pure
  still records the call with that token, and takes the token +
  the chance as params (the N2475 repair_radius precedent) so
  a def override would pass through verbatim.
- The chance gate sits INSIDE the pump branch (:126), so the
  pure takes pump_branch_open as a caller-evaluated bool and
  does NOT recompute efficiency / typeLiquid (the N2397
  precedent — the N2220 advance owns the gate; the advance
  computes it inline, there is no separate gate key).

## Commits

- Slice: `97777de7b` (5 files, +857/−3).
- Integration cherry-pick: `cf84857be` (clean).

## Tests

Targeted (new module
`tests.test_c07_solid_pump_update_effect_chance_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (8 SolidPump modules) Ran 32 (24 PASS
+ 8 proof Godot-absent), 0 errors.
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12383/1892/1845/3482** (exactly
as estimated). DEFERRED **#90 RESOLVED** (234→233, by entry TEXT).

## Godot debt

- NEW proof `C07SolidPumpUpdateEffectChanceProof` (6 keys:
  `fx_roll_hit`, `fx_roll_miss`, `fx_gate_closed`,
  `fx_position_rolls`, `fx_none_token`, `fx_live_input`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
