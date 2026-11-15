# N2284 Fracker DumpLiquid — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

Fracker dumpLiquid(result) in BOTH updateTile branches, scaling 2f, via the shared `dump_liquid_state` helper. Pure `source_fracker_dump_liquid_state` → 3 keys (liquids_after, dumped_amount, cursor_after). ONE call site in the tick after the advance covers both branches.

## Key facts for the next agent

- **Fracker dump else-branch is :42, NOT :43** (brief + SCOPE + DEFERRED were all off by one: warmup :40, lastPump :41, dump :42, method closes :44).
- dumpLiquid impl **:886–908** (not :886–910); `transferLiquid` **:914–921** (not :916–924); `canDumpLiquid` **:910–912** (not :912–914); campaign unlock **:891**; threshold :889; loop :893–905; `incrementDump` :1116–1121. Confirmed by N2285/N2286/N2287 independently.
- `result` = oil (Blocks.java:2966), capacity 40f (:2971).
- **ONE call site after the advance covers both branches:** the advance runs exactly one branch, and the dump depends only on the post-advance store; in the if-branch Java dumps before `accumulator += …` but the accumulator does not affect the dump.
- **Cursor invariant (Java-exact, found by N2286):** a full scan calls incrementDump once per neighbour = a full circle, so `cursor_after` always equals the input cursor.
- Neighbours arrive as ONE frame input `dump_liquid_neighbours` (Array of Dictionary), defaults per Java. The pure does not mutate its input (removes only when dumped ≠ 0 so the "current" key never flips).
- The pure N2220 is NOT modified. Old proofs N2224/N2255/N2268 still green (dump is a no-op with no neighbours).
- SSOT +3/+1/+1/+2 → 11831/1731/1664/3120 (audit 1336). Exact-evidence 40/40. DEFERRED 300 (−1 +3 new).

## Godot debt (this slice)

`C07FrackerDumpLiquidProof` — 6 keys: dump_transfers_to_neighbour, dump_scales_by_two, dump_no_transfer_when_neighbour_full, dump_no_transfer_below_threshold, dump_runs_in_both_branches, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_fracker_dump_liquid`. Do NOT mark done until it passes there.
