# N2283 WallCrafter TimerDump — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

`if(timer(timerDump, dumpTime / timeScale)){ dump(output); }` (WallCrafter.java:220-221 — if :220, `dump(output);` :221, close :222; ":220-222" is the full block with brace). `dumpTime = 5` (Block.java:438, no overrides); `timerDump = timers++;` (Block.java:436). **The output item is SAND, not graphite** (the brief's guess was wrong): `public Item output = Items.sand;` (WallCrafter.java:43); both defs set `output = Items.sand;` (Blocks.java:3009/:3023) — graphite is only the large def's booster item. Java order: timerUse :207-209, offload :213-215, timerDump :220-221. **Cite fix:** the old driver cited `hasItems = true;` as WallCrafter.java:58 — actually **:56**, fixed in the `_initial_frame` comment.

## Implementation

`SourceWallCrafterBuildState.gd`: pure `source_wall_crafter_timer_dump_state(elapsed, time_scale, frame, output_item, content_item_ids, neighbour_accepts_item, neighbour_can_dump)` → 5 keys {fired, elapsed_after, dumped, items_after, cursor_after} (frame-local Interval-equivalent: frame key `timer_dump_elapsed` — a SECOND independent clock beside N2273's `timer_use_elapsed` — accumulate unconditionally each tick outside the enabled gate, fire at 5/time_scale, reset 0 on fire even when the dump fails). Const `SOURCE_WALL_CRAFTER_DUMP_TIME := 5.0`. Tick wiring: inside the enabled gate, AFTER the N2223 advance + N2273 timerUse (Java order :207-209 → :220-221), when the timer fires → `dump(output)` via `dump_item_state` (reused, not modified), persist items/cdump/elapsed into the frame. Neighbour accept/canDump are frame inputs (default `[]`). **First-fire deviation** (documented in docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks).

## Commits

Slice `ca592ed9` (worker-N2283, branch `slice/N2283-wall-crafter-timer-dump`, 5 files, +1077/−9, đã push, remote tip verified by ls-remote). Integration cherry-pick `727d3aa2` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 25/25, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (8 modules Ran 31: 5 WallCrafter + PayloadDeconstructor dump + building_item_dump_runtime_slice + building_dump_binding): 24 PASS + 7 proof fails, all `AssertionError: unexpectedly None` — 0 other failures. Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11833/1731/1664/3120; audit stays 1336. DEFERRED 299 (298 with 1 entry updated in place — the WallCrafter live-fill entry now records timerDump live since N2283 — + 1 new first-fire deviation entry). Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07WallCrafterTimerDumpProof` — 6 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_removes_output_item, dump_cursor_advances, no_dump_when_output_absent, live_tick_dumps_output (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.

**Flag (not this slice):** the DEFERRED entry "WallCrafter frame items intake" still says the offload/dump "waits for its own slice" even though the offload is live since N2223 and the dump since this slice — the entry is about intake from outside, and the offload cannot run without the getEfficiency live fill (efficiency_factor defaults 0.0), so the entry stays substantively true and is kept as-is.
