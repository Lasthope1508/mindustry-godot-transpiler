# N2283 WallCrafter TimerDump — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

WallCrafter timerDump dump: frame-local Interval (5f/time_scale) + `dump(output)` after the N2223 advance + N2273 timerUse. Pure `source_wall_crafter_timer_dump_state` → 5 keys (fired, elapsed_after, dumped, items_after, cursor_after). Second independent frame clock (`timer_dump_elapsed`, beside N2273's `timer_use_elapsed`).

## Key facts for the next agent

- **The output item is SAND, not graphite** (`public Item output = Items.sand;` WallCrafter.java:43; both defs Blocks.java:3009/:3023) — graphite is only the large def's booster item.
- Java order: timerUse :207-209, offload :213-215, timerDump :220-221.
- `dumpTime = 5` (Block.java:438, no overrides); `timerDump = timers++;` (Block.java:436).
- **Cite fix:** the old driver cited `hasItems = true;` as WallCrafter.java:58 — actually **:56**, fixed in the `_initial_frame` comment.
- **First-fire deviation** (docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks).
- The DEFERRED entry "WallCrafter frame items intake" stays as-is: the offload cannot run without the getEfficiency live fill (efficiency_factor defaults 0.0), so no live intake fills items yet.
- SSOT +5/+1/+1/+2 → 11833/1731/1664/3120 (audit 1336). Exact-evidence 25/25. DEFERRED 299 (1 entry updated in place + 1 new).

## Godot debt (this slice)

`C07WallCrafterTimerDumpProof` — 6 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_removes_output_item, dump_cursor_advances, no_dump_when_output_absent, live_tick_dumps_output (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_wall_crafter_timer_dump`. Do NOT mark done until it passes there.
