# N2281 Separator TimerDump — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

`if(timer(timerDump, dumpTime / timeScale)){ dump(); }` (Separator.java:165-166, after the progress/offload block :140-163 — so the dump runs AFTER the advance in the same tick). `dumpTime = 5` (Block.java:438, `public int dumpTime = 5;` — NO overrides anywhere in upstream, grep-verified); `timerDump = timers++;` (Block.java:436). `dump()` = `dump(null)` (BuildingComp.java:1064-1066; `dump(Item)` :1072-1113 — neighbour-outer/item-inner scan). `TimerComp.timer` (:10-13); `Interval.get` (arc Interval.java:20-26, reset :28-30); `Time.time` in ticks (`timeRaw += delta;`, arc Time.java). `hasItems = true;` (Separator.java:31).

## Implementation

`SourceSeparatorBuildState.gd`: pure `source_separator_timer_dump_state` → 5 keys {fired, elapsed_after, dumped, items_after, cursor_after} (frame-local Interval-equivalent, N2266/N2269/N2273/N2280 precedent: frame key `timer_dump_elapsed`, accumulate unconditionally each tick, fire at 5/time_scale, reset 0 on fire — including when the dump fails, since Java resets the Interval when timer() returns true). **This timer DOES divide by timeScale** (unlike N2280's literal-20), so 5f/time_scale is Java-exact at every time_scale. Tick wiring: after the N2222 advance, when the timer fires → `dump_item_state` (SourceBuildingItemDumpState.gd:337, reused not modified — the correct port of `dump(null)`; `game_put_item_state` cannot express it, N2276 lesson), persist items/cdump into the frame. The dump uses the SAME `cdump` cursor as the N2222 offload (Java uses one `this.cdump`). Neighbour accept/canDump are frame inputs (`dump_neighbour_accepts` / `dump_neighbour_can_dump`, default `[]`) — no neighbour → no transfer, items unchanged. **First-fire deviation** (documented in docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks).

## Commits

Slice `15905aad` (worker-N2281, branch `slice/N2281-separator-timer-dump`, 5 files, +1171/−6, đã push, remote tip verified by ls-remote). Integration cherry-pick `f7e33226` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 33/33, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (6 modules Ran 24: Separator power/should-consume/update-tile/liquid-row + N2276 PayloadDeconstructor dump + N2280 RepairTurret timer-target): 18 PASS + 6 proof fails, all `AssertionError: unexpectedly None` — 0 other failures. Proof live-tick: separator live, efficiency 1.0, progress 1/35, copper 5→4, cdump 0→1, clock reset 0.0 (slag seeded per the N2252 precedent). Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11833/1731/1664/3120; audit stays 1336. DEFERRED 300 (298 − 1 resolved: Separator timerDump dump + 3 new: first-fire deviation, dump neighbour live fill, dump neighbour write-back). Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07SeparatorTimerDumpProof` — 6 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_removes_item_from_store, dump_cursor_advances, no_dump_when_items_empty, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.

**Flag (not this slice):** the N2222 proof live-tick may be stale after N2252 — it asserts efficiency 0.5 when stamping power 0.5 without seeding slag, but with the liquid row live an empty slag store folds efficiency to 0. The N2281 proof seeds slag to avoid this. The Godot agent should seed slag when running the N2222 proof, or a follow-up slice should fix the N2222 proof scene.
