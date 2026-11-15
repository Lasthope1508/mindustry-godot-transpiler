# N2273 WallCrafter Timer Use — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## Source

`boostItemUseTime = 120f` (WallCrafter.java:45 — the CLASS default; cliff-crusher keeps it, but has no item consumer so the timer never fires consume). **The only def with a booster overrides it: large-cliff-crusher `boostItemUseTime = 60f / 0.75f;` (Blocks.java:3032) = 80f** → the timer live-fires at 80f. `timer(timerUse, boostItemUseTime)` (WallCrafter.java:207-209): if timer fires AND `itemValid()` (:191: item exists && items.has(item) && items.get(item) >= 1) AND `eff > 0` → `items.remove(item, 1); lastEfficiency = eff;` (:211). `eff` computed :196-206 (not :193-206 — :193 is the warmup line). Offload :213-215. consume() removes 1 graphite (Blocks.java:3030, N2264). TimerComp.timer :10-13 (not :11-14 — fixed in the slice; the same fix landed for N2266/N2269 in the dynamic-special wave). Blocks.java:3028/3030/3032.

## Implementation

`SourceWallCrafterBuildState.gd`: pure `source_wall_crafter_timer_use_state` (frame-local Interval-equivalent, N2266/N2269 precedent): accumulate frame key `timer_use_elapsed` unconditionally each tick before the enabled-gate; the check runs after the advance (eff from the N2223 return dict); on fire with itemValid && eff > 0 → DIRECT removal of 1 graphite + reset elapsed. The driver resolves the per-def duration via helper `_wall_crafter_boost_item_use_time_for_block` (the catalog has no boostItemUseTime property); the pure takes duration as a param; test + proof cover both 120f and 80f. The N2223 advance is NOT modified. **First-fire deviation (documented in docstring + DEFERRED)**: Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval.

## Commits

Slice `550bfeb5` (worker-N2273, branch `slice/N2273-wall-crafter-timer-consume`, 5 files, +1040/−4, đã push, remote tip verified by ls-remote). Integration cherry-pick `b13ab652` on `integration/wave-power-launch-build-n2270-n2273` (base 3bca6665). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 15/15, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (15/20 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate (PID 14057, launch 23:50 by coordinator lượt 9, done 00:11 +07 16/11): Ran 6182 in 1189.124s, failures=222, skipped=5, 0 errors — 222/222 Godot-absent (218 inherited + 4 new proof tests N2270–N2273).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11776/1720/1649/3090; audit stays 1336. +3 symbols, not the SCOPE-estimated +2 — the result dict carries 3 keys (fired/elapsed_after/threshold, like N2269). DEFERRED 291 (290 + 1 new first-fire deviation entry; entry line 190 kept verbatim for the coordinator partial-edit at integration). Merged wave DEFERRED: 290 entries (DEFERRED-after-power-launch-build.py) — 290 − 5 resolved/removed + 5 new, resolved by entry TEXT not number.

## Godot debt

`C07WallCrafterTimerConsumeProof` — 6 keys: timer_consume_removes_graphite, timer_fires_at_use_time, timer_no_fire_below_threshold, timer_no_fire_when_time_scale_zero, timer_no_item_for_cliff_crusher, timer_requires_item_valid_and_positive_eff (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
