# N2289 BeamDrill TimerDump — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## What this slice did

BeamDrill dump timer: frame-local Interval (5f/time_scale) + `dump()` after the N2195 advance. Pure `source_beam_drill_timer_dump_state` → 5 keys (fired, elapsed_after, dumped, items_after, cursor_after). Mirror of the N2281 Separator precedent.

## Key facts for the next agent

- `if(timer(timerDump, dumpTime / timeScale)){ dump(); }` (BeamDrill.java:264-266), AFTER the drop loop (:253-262) in the same tick.
- `dumpTime = 5` (Block.java:438, no overrides); `timerDump = timers++;` (Block.java:436).
- `hasItems = true;` (BeamDrill.java:66).
- **First-fire deviation** (docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks).
- The drop loop + time reset (entry 223) is NOT in this slice — it needs lastItem from updateFacing.
- Flag: the N2195 live proof is STALE since N2256 (asserts multiplier 1.75 / time 0.875 at power_status 0.5, but with no hydrogen the booster row folds optionalEfficiency to 0 → multiplier 1.0, time 0.5). Needs an N2290-style fix slice.
- SSOT +5/+1/+1/+2 → 11860/1738/1671/3134 (audit 1336). Exact-evidence 33/33. DEFERRED 315 (−1 +3 new).

## Godot debt (this slice)

`C07BeamDrillTimerDumpProof` — 6 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_removes_item_from_store, dump_cursor_advances, no_dump_when_items_empty, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_beam_drill_timer_dump`. Do NOT mark done until it passes there.
