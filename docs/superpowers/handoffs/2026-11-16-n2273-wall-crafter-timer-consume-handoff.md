# N2273 WallCrafter Timer Use — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## What this slice did

WallCrafter timerUse booster consume: frame-local Interval-equivalent pure `source_wall_crafter_timer_use_state`. Frame key `timer_use_elapsed` accumulates unconditionally each tick before the enabled-gate; the check runs after the advance (eff from the N2223 return dict); on fire with itemValid && eff > 0 → DIRECT removal of 1 graphite + reset elapsed. The N2223 advance is NOT modified.

## Key facts for the next agent

- **Duration is 80f for the only def with a booster** — 120f is only the class default (WallCrafter.java:45) which cliff-crusher keeps (no item consumer, so the timer never fires consume); large-cliff-crusher overrides `boostItemUseTime = 60f / 0.75f;` (Blocks.java:3032) = **80f** → the timer live-fires at 80f. The driver resolves the per-def duration via helper `_wall_crafter_boost_item_use_time_for_block` (the catalog has no boostItemUseTime property); the pure takes duration as a param; test + proof cover both 120f and 80f.
- **First-fire deviation (documented in docstring + DEFERRED)**: Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval.
- `eff` computed :196-206 (not :193-206 — :193 is the warmup line). if :207-209, itemValid :191, lastEfficiency :211, offload :213-215. consume() removes 1 graphite (Blocks.java:3030, N2264). TimerComp.timer :10-13 (not :11-14 — fixed in the slice; the same fix landed for N2266/N2269 in the dynamic-special wave). Blocks.java:3028/3030/3032.
- SSOT +3/+1/+1/+2 → 11776/1720/1649/3090 (audit 1336). +3 symbols, not the SCOPE-estimated +2 — the result dict carries 3 keys (fired/elapsed_after/threshold, like N2269). Exact-evidence 15/15. DEFERRED 291 (+1 new first-fire deviation; entry line 190 kept verbatim for the coordinator partial-edit at integration).

## Godot debt (this slice)

`C07WallCrafterTimerConsumeProof` — 6 keys: timer_consume_removes_graphite, timer_fires_at_use_time, timer_no_fire_below_threshold, timer_no_fire_when_time_scale_zero, timer_no_item_for_cliff_crusher, timer_requires_item_valid_and_positive_eff (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_wall_crafter_timer_consume`. Do NOT mark done until it passes there.
