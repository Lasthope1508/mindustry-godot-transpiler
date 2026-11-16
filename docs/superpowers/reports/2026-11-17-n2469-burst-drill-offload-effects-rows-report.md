# Report N2469 — BurstDrill updateTile offload effects rows

**Slice:** N2469 — BurstDrill offload effects (shake / drillSound /
drillEffect) as pure-only call records, plus the DEFERRED #91 entry
rewrite for the remaining neighbor routing. **Wave:** advances-32.
**Commit:** `b3b2fd8be` on
`slice/N2469-burst-drill-offload-effects-rows` (base `99a167e15`).
**Files:** 5, +907/−4.

## Source

BurstDrill.java (core/src/mindustry/world/blocks/production/):
offload effect lines :114-118 (Effect.shake / drillSound.at /
drillEffect.at on the timerDump dump). The timerDump dump itself is
live since N2282 (frame-local Interval-equivalent, 5f/time_scale,
BurstDrill.java:83-84). The offload neighbor acceptItem/handleItem
scan is BuildingComp.java:1001-1017.

## Implementation

One pure-only pure (no tick wiring — the N2468 precedent):
`source_burst_drill_offload_effects_state(cycle_complete,
was_visible, x, y, pitch_roll, effect_roll_x, effect_roll_y,
dominant_item_color)` → {shake, drill_sound, drill_effect}:
shake {intensity 2.0, duration 2.0} + drillSound {token
"drillImpact", pitch 1f + pitch_roll, volume 0.6f} + drillEffect
{token "Fx.shockwave", at (x + effect_roll_x, y + effect_roll_y),
dominant-item color} — all null unless cycle_complete &&
was_visible. The pitch + position rolls are caller-supplied; NO RNG
in the pure (the N2421 precedent).

**Verify-first findings:**
- **BOTH defs override the CLASS defaults** — shake = 4f
  (Blocks.java:3077/:3106) and drillEffect to a MultiEffect
  (impact-drill Blocks.java:3076, eruption-drill Blocks.java:
  3100-3105). The pure records the CLASS defaults (shake 2.0,
  Fx.shockwave); the per-def shake/effect rows wait for their own
  slice (the N2304 per-def precedent).
- drillEffectRnd stays 0f for both defs (BurstDrill.java:41, no def
  override), so the effect spawns at (x, y) exactly.
- The offload currently takes the no-neighbor fallback branch
  (handleItem(self(), item), BuildingComp.java:1017) via the shared
  inventory add_item_state helper, so a burst drill with an
  accepting neighbor still fills its own store — the neighbor
  routing waits for its own slice (the #91 entry rewrite records
  this).

## Commits

- Slice: `b3b2fd8be` (5 files, +907/−4).
- Integration cherry-pick: `30945e3f2` (clean).

## Tests

Targeted (new module
`tests.test_c07_burst_drill_offload_effects_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (7 BurstDrill modules): Ran 28 (21
PASS + 7 proof Godot-absent), 0 errors.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2 → 12371/1885/1837/3466** (exactly as
estimated). DEFERRED **#91 REWRITTEN IN PLACE** (238→238, by entry
TEXT): the FX half is live since N2469; the neighbor routing waits
for its own slice (merge-side rewrite — the test pins the entry text
from the N2468 base snapshot).

## Godot debt

- NEW proof `C07BurstDrillOffloadEffectsRowsProof` (6 keys:
  `effects_color`, `effects_fire`, `effects_gate_cycle`,
  `effects_gate_visible`, `effects_pitch`, `effects_position`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
