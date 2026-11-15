# N2282 BurstDrill TimerDump — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

`if(timer(timerDump, dumpTime / timeScale)){ dump(items.has(dominantItem) ? dominantItem : null); }` (BurstDrill.java:83-84). `dumpTime = 5` (Block.java:438, no overrides); `timerDump = timers++;` (Block.java:436). **The brief was WRONG on the null case:** Java returns early at BurstDrill.java:77-79 (`if(dominantItem == null){ return; }`) BEFORE the timer check :83 — with no dominant item there is NO dump at all; `dump(null)` only happens when the dominant item EXISTS but the store lacks it. `items.has` = count > 0 (ItemSeq.java:79-81), not key presence — a zero-count entry still takes the dump(null) branch. Java order: null-return :77-79 → invertTime decay :81 → timerDump :83-84 → advance :87+. **Defs:** laser-drill is the base Drill (Blocks.java:2886); BurstDrill defs are impact-drill (:3070) + eruption-drill (:3093) — there is NO def named "burst-drill". `dump_item_state` (SourceBuildingItemDumpState.gd:337) covers BOTH dump(Item) branches — the brief's suggested `put_item_state` is putItem (BuildingComp.java:1000-1013), the wrong shape (N2276 lesson).

## Implementation

`SourceBurstDrillBuildState.gd`: pure `source_burst_drill_timer_dump_state(frame, source_delta, time_scale, dominant_item_name, content_item_ids, neighbour_accepts_item, neighbour_can_dump)` → 5 keys {fired, elapsed_after, dumped, items_after, cursor_after} (frame-local Interval-equivalent: frame key `timer_dump_elapsed`, accumulate unconditionally, fire at 5/time_scale, reset 0 on fire even when the dump fails). The pure no-ops (no fire) when the dominant item is empty, but the clock still accumulates so the dump fires as soon as a dominant item appears — correct Interval semantics. Tick wiring: BEFORE the N2219 advance call in the same `if enabled` block (Java order :83-84 before :87+); `frame["dominant_item"]` is already bound by the drill proximity path (N2219), no new frame input needed. Neighbour arrays reuse the N2276 names (`dump_neighbour_accepts`/`dump_neighbour_can_dump`). **First-fire deviation** (documented in docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks).

## Commits

Slice `eafd3fb5` (worker-N2282, branch `slice/N2282-burst-drill-timer-dump`, 5 files, +1122/−7, đã push, remote tip verified by ls-remote). Integration cherry-pick `5c4b1682` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 43/43, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (BurstDrill family: power N2149 + should-consume N2203 + update-tile N2219 + liquid-rows N2257): 12 PASS + 4 proof fails, all `AssertionError: unexpectedly None` — 0 other failures. The proof live key does NOT assert efficiency — N2257's required hydrogen row folds efficiency to 0 with no liquid, but the dump is a timer independent of efficiency so it still runs. Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11833/1731/1664/3120; audit stays 1336. DEFERRED 301 (298 with 1 merged entry rewritten to the narrowed "offload effects + neighbor routing" entry + 3 new: first-fire deviation, neighbour live fill, neighbour write-back). Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07BurstDrillTimerDumpProof` — 7 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_prefers_dominant_item, dump_falls_back_to_null, no_dump_without_dominant_item, dump_cursor_advances, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
