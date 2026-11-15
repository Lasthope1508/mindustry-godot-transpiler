# N2281 Separator TimerDump — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

Separator timerDump dump: frame-local Interval (5f/time_scale) + `dump()` after the N2222 advance. Pure `source_separator_timer_dump_state` → 5 keys (fired, elapsed_after, dumped, items_after, cursor_after). Uses the shared `dump_item_state` (the correct port of `dump(null)`); same `cdump` cursor as the N2222 offload.

## Key facts for the next agent

- `if(timer(timerDump, dumpTime / timeScale)){ dump(); }` (Separator.java:165-166) runs AFTER the progress/offload block (:140-163) — dump after advance in the same tick.
- `dumpTime = 5` (Block.java:438, NO overrides anywhere in upstream); `timerDump = timers++;` (Block.java:436).
- **This timer DOES divide by timeScale** (unlike N2280's literal-20), so 5f/time_scale is Java-exact at every time_scale.
- The timer resets elapsed to 0 on fire even when the dump fails (Java resets the Interval when timer() returns true).
- **First-fire deviation** (docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (5 ticks).
- Neighbour accept/canDump are frame inputs (default `[]`) — no neighbour → no transfer.
- Flag: the N2222 proof live-tick may be stale after N2252 (asserts efficiency 0.5 when stamping power 0.5 without seeding slag — an empty slag store folds efficiency to 0). The N2281 proof seeds slag per the N2252 precedent.
- SSOT +5/+1/+1/+2 → 11833/1731/1664/3120 (audit 1336). Exact-evidence 33/33. DEFERRED 300 (−1 +3 new).

## Godot debt (this slice)

`C07SeparatorTimerDumpProof` — 6 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_removes_item_from_store, dump_cursor_advances, no_dump_when_items_empty, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_separator_timer_dump`. Do NOT mark done until it passes there.
