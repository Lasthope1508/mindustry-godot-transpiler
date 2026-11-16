# Report N2486 — BurstDrill per-def shake/effect rows

**Slice:** N2486 — BurstDrill per-def shake/effect rows (the
per-def half of DEFERRED #88; the per-neighbour capacity
refinement + produced stats still wait — the entry is rewritten
in place). **Wave:** advances-34. **Commit:** `09ed6f8e1` on
`slice/N2486-burst-drill-per-def-shake-effect-rows` (base
`ad308cf7e`). **Files:** 5, +831/−2.

## Source

Blocks.java: impact-drill (`impactDrill = new
BurstDrill("impact-drill"){{`, :3070): `drillEffect = new
MultiEffect(Fx.mineImpact, Fx.drillSteam,
Fx.mineImpactWave.wrap(Pal.redLight, 40f));` (:3076) and `shake
= 4f;` (:3077). Eruption-drill (`eruptionDrill = new
BurstDrill("eruption-drill"){{`, :3093): `drillEffect = new
MultiEffect(` (:3100) with Fx.mineImpact, Fx.drillSteam,
`Fx.dynamicSpikes.wrap(Liquids.hydrogen.color, 30f),` (:3103)
and `Fx.mineImpactWave.wrap(Liquids.hydrogen.color, 45f)`
(:3104), and `shake = 4f;` (:3106). The Fx tokens are exact
(mineImpact Fx.java:2655; drillSteam :1474; mineImpactWave
:2662; dynamicSpikes :737). A MultiEffect fires its children in
order at the same x/y/rotation/color/data (MultiEffect.java:7,
:19-20), so the token list order IS the firing order. The wrap
second arg is a ROTATION (`public WrapEffect wrap(Color color,
float rotation){`, Effect.java:101 — WrapEffect.create passes
its own rotation + color to the wrapped effect, ignoring the
caller's, WrapEffect.java:37-39). The shake feeds
`Effect.shake(shake, shake, this);` (BurstDrill.java:115).
drillSound / drillSoundVolume do NOT differ per def (`public
Sound drillSound = Sounds.drillImpact;`, BurstDrill.java:32;
`public float drillSoundVolume = 0.6f;`, :33).

## Implementation

One pure-only per-def pure (the N2304 per-def precedent, NO
tick wiring): `source_burst_drill_per_def_offload_effects_state(def_id)`
→ {shake, drill_effect} — shake 4.0 + the def's MultiEffect
children as an ordered token list for impact-drill /
eruption-drill, and the CLASS defaults (shake 2.0,
["Fx.shockwave"]) for an unknown def id (the N2304 fallback
precedent). The N2469 pure is UNCHANGED.

**Verify-first findings:**
- The wrap colors are recorded as TOKENS ("Pal.redLight",
  "Liquids.hydrogen.color"), not resolved Colors (Pal.redLight
  is Color.valueOf("feb380"), Pal.java:138; Liquids.hydrogen is
  Color.valueOf("9eabf7"), Liquids.java:83) — the N2469 token
  precedent.
- drillEffectRnd stays 0f for both defs (BurstDrill.java:41,
  no def override), so the effect spawns at (x, y) exactly.
- The register was built on the stale N2482 234-entry
  DEFERRED list (still contains 5 advances-33-resolved
  entries, missing 2 advances-33 new entries) — the merge
  allowlisted the stale-base artifacts by diffing that list
  against the merged 231 base.

## Commits

- Slice: `09ed6f8e1` (5 files, +831/−2).
- Integration cherry-pick: `8d9ea9e95` (clean).

## Tests

Targeted (new module
`tests.test_c07_burst_drill_per_def_shake_effect_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (10 BurstDrill modules) Ran 40 (30
PASS + 10 proof Godot-absent), 0 errors.
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2 → 12403/1899/1853/3498** (exactly as
estimated). DEFERRED **#88 REWRITTEN IN PLACE** (231→231, by entry
TEXT — per-def shake/effect rows live, per-neighbour capacity
refinement + produced stats still wait).

## Godot debt

- NEW proof `C07BurstDrillPerDefShakeEffectRowsProof` (6 keys:
  `shake_impact`, `shake_eruption`, `effect_impact`,
  `effect_eruption`, `class_fallback`, `per_def_live_input`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
