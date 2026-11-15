# N2282 BurstDrill TimerDump — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

BurstDrill timerDump dump: frame-local Interval (5f/time_scale) + `dump(dominantItem or null)` BEFORE the N2219 advance. Pure `source_burst_drill_timer_dump_state` → 5 keys (fired, elapsed_after, dumped, items_after, cursor_after).

## Key facts for the next agent

- **The brief was WRONG on the null case:** Java returns early at BurstDrill.java:77-79 (`if(dominantItem == null){ return; }`) BEFORE the timer check :83 — with no dominant item there is NO dump at all; `dump(null)` only happens when the dominant item EXISTS but the store lacks it. The pure no-ops when dominant is empty but the clock still accumulates.
- `items.has` = count > 0 (ItemSeq.java:79-81), not key presence — a zero-count entry still takes the dump(null) branch.
- Java order: null-return :77-79 → invertTime decay :81 → timerDump :83-84 → advance :87+.
- `dump_item_state` covers BOTH dump(Item) branches — `put_item_state` is putItem, the wrong shape (N2276 lesson).
- `frame["dominant_item"]` is already bound by the drill proximity path (N2219) — no new frame input was needed.
- **Defs:** laser-drill is the base Drill (Blocks.java:2886); BurstDrill defs are impact-drill (:3070) + eruption-drill (:3093) — there is NO def named "burst-drill".
- The proof live key does NOT assert efficiency (N2257's required hydrogen row folds efficiency to 0 with no liquid, but the dump is a timer independent of efficiency).
- SSOT +5/+1/+1/+2 → 11833/1731/1664/3120 (audit 1336). Exact-evidence 43/43. DEFERRED 301 (1 merged entry rewritten to narrowed offload-only + 3 new).

## Godot debt (this slice)

`C07BurstDrillTimerDumpProof` — 7 keys: timer_fires_at_five_ticks, timer_no_fire_below_threshold, dump_prefers_dominant_item, dump_falls_back_to_null, no_dump_without_dominant_item, dump_cursor_advances, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_burst_drill_timer_dump`. Do NOT mark done until it passes there.
