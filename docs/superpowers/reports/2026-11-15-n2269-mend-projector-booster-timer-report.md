# N2269 MendProjector Booster Timer (timer-gated consume) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 8 — wave dynamic/special, integration branch `integration/wave-dynamic-special-n2265-n2269`, base `e07aac89`).

## Source

Defs: mender — `consumeItem(Items.silicon).boost()` (Blocks.java:1929), reload 200f, range 40f; mend-projector — `consumeItem(Items.phaseFabric).boost()` (:1941), reload 250f, range 85f. `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){ consume(); }` (MendProjector.java:102-104 — if :102, consume() :103, brace :104). `useTime = 400f` class default (:31; no def overrides). `canHeal = !checkSuppression()` (:94) — the driver keeps can_heal=true default (suppression untracked, N2184 precedent). `TimerComp.timer` (TimerComp.java:10-13): false if time infinite, else `Interval.get`; `Interval.get` resets `times[id] = Time.time` on fire (arc Interval.java:20-26); check :28-30; `Time.time` is in TICKS (arc Time.java:69-80). Java order: lerps (:96-100) → timer consume (:102-104) → heal scan (:106+). **Scope corrections (grep-verified): TimerComp.timer is :10-13 (not :11-14 — signature :10, infinite check :11, get :12, brace :13); the DEFERRED entry's ":101-103" is off by one the other way; Interval.check spans :28-30 (comparison :29).**

## Implementation

`SourceMendProjectorBuildState.gd`: pure `source_mend_projector_timer_use_state(elapsed, duration, time_scale)` → `{fired, elapsed_after, threshold}` — the frame-local Interval-equivalent (threshold = duration/time_scale; time_scale ≤ 0 → fired=false; reset to 0.0 on fire, NOT subtract). The tick accumulates `frame["timer_use_elapsed"]` EVERY tick, unconditionally (mirror of Time.time). BETWEEN the advance and the heal scan (Java order :102-104 before :106+): if `optional_efficiency > 0` AND the timer fires (400f) AND can_heal → DIRECT removal of 1 booster item per def via the N2263 helper `_mend_projector_booster_stacks_for_block` (clamped) + elapsed reset to 0.0. NO row added (N2263 did the rows); advance/heal-scan functions untouched (logic). Power-row Documented limits updated: timer consume live + first-fire deviation + no live intake + can_heal default true; stale "stays deferred" sentences in the item-row/advance comments updated (exact exprs preserved). **Documented deviation: first fire** — Java fires (nearly) immediately after placement when the gate first holds; the frame-local clock delays the first fire by one full interval (waits for a global-clock timer-infra slice).

## Commits

Slice `1791376a` (worker-N2269, branch `slice/N2269-mend-projector-booster-timer`, 5 files, +938/−21, đã push, remote tip verified by ls-remote). Integration cherry-pick `516296e0` on `integration/wave-dynamic-special-n2265-n2269` (base e07aac89). No coordinator fix needed for this slice — the MendProjector proofs need no item seeding (N2269 adds no row, and the 400-tick timer cannot fire in a 1–3 tick proof).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 15/15, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, booster_items, update_tile, heal_scan: Ran 16, 12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate (PID 8064, launch 23:07 by coordinator lượt 8, done 23:27 +07): Ran 6166 in 1159.193s, failures=218, skipped=5, 0 errors — 218/218 Godot-absent (213 inherited + 5 new proof tests N2265–N2269).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11752/1715/1639/3069; audit stays 1336. +3 symbols, not the SCOPE-estimated +2, because the pure function returns 3 keys (fired/elapsed_after/threshold). Shards touched: `defense_api_contracts.json`, `defense_slices.json` only; no shard gotcha (no symbol java_source under /world/consumers/). DEFERRED 289 (289 − 1 resolved + 1 new: first-fire deviation). Merged wave DEFERRED: 290 entries (DEFERRED-after-dynamic-special.py) — 289 − 6 resolved + 7 new, resolved by entry TEXT not number.

## Godot debt

`C07MendProjectorBoosterTimerProof` — 6 keys: timer_fires_at_use_time, timer_no_fire_below_threshold, timer_requires_positive_optional, timer_consume_removes_booster_item, timer_uses_per_def_stack, timer_no_fire_when_time_scale_zero (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
