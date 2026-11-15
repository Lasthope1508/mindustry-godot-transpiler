# N2269 MendProjector Booster Timer (timer-gated consume) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave dynamic/special, coordinator lượt 8).

## What this slice did

Booster timer consume in `SourceMendProjectorBuildState.gd` (mender silicon boost Blocks.java:1929; mend-projector phaseFabric boost :1941; `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){ consume(); }`, MendProjector.java:102-104; `useTime = 400f` :31). Pure `source_mend_projector_timer_use_state` → `{fired, elapsed_after, threshold}` (frame-local Interval-equivalent: threshold = duration/time_scale; time_scale ≤ 0 → never fires; reset to 0.0 on fire). The tick accumulates `timer_use_elapsed` every tick unconditionally; BETWEEN the advance and the heal scan (Java order :102-104 before :106+), when `optional_efficiency > 0` AND the timer fires AND can_heal → DIRECT removal of 1 booster item per def (N2263 helper) + elapsed reset. NO row added; advance/heal scan untouched.

## Key facts for the next agent

**Verified line numbers**: TimerComp.timer :10-13 (NOT :11-14 — signature :10, infinite check :11, get :12, brace :13); timer if :102, consume() :103, brace :104 (the DEFERRED entry's ":101-103" is off by one); Interval.check :28-30. **First-fire deviation (documented)**: Java fires (nearly) immediately after placement; the frame-local clock delays the first fire by one full interval — waits for a global-clock timer-infra slice. **can_heal defaults true** (suppression untracked, N2184 precedent). Register: 15 exact exprs, all grep-verified verbatim. DEFERRED: 289 (289 − 1 resolved + 1 new: first-fire deviation). Slice commit `1791376a` (branch `slice/N2269-mend-projector-booster-timer`, đã push). Integration cherry-pick `516296e0`.

## Godot debt (this slice)

`C07MendProjectorBoosterTimerProof` — 6 keys: timer_fires_at_use_time, timer_no_fire_below_threshold, timer_requires_positive_optional, timer_consume_removes_booster_item, timer_uses_per_def_stack, timer_no_fire_when_time_scale_zero. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
