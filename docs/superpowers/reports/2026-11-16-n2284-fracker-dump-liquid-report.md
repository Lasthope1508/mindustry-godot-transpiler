# N2284 Fracker DumpLiquid — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

Else-branch `dumpLiquid(result);` (**Fracker.java:42, NOT :43** — the brief, SCOPE, and DEFERRED entry were all off by one line: warmup :40, lastPump :41, dump :42, method closes :44). If-branch via `super.updateTile();` (Fracker.java:37) → SolidPump.updateTile ends with `dumpLiquid(result);` (SolidPump.java:140, unconditional, after `pumpTime += warmup * edelta();` :138). Both are `dumpLiquid(Liquid)` → scaling **2f** (BuildingComp.java:877-878). `dumpLiquid` impl **:886–908** (not :886–910 — :910 is canDumpLiquid); early return when `liquids.get(liquid) <= 0.0001f` (:889); iterate proximity from cdump, `incrementDump` EVERY iteration (:893–905); gate `other.block.hasLiquids && canDumpLiquid && other.liquids != null`; transfer when `ofract < fract`: `(fract - ofract) * block.liquidCapacity / scaling`. `transferLiquid` **:914–921** (not :916–924): flow = min(neighbour free capacity, amount), only when `next.acceptLiquid(self(), liquid)`. `canDumpLiquid` default true **:910–912** (not :912–914). Campaign unlock **:891**. `incrementDump` :1116–1121. `result` = oil (Blocks.java:2966), capacity 40f (:2971). **Cursor invariant (Java-exact, found by N2286, confirmed here):** a full scan calls incrementDump once per neighbour = a full circle, so `cursor_after` always equals the input cursor — the cursor only matters WITHIN the scan.

## Implementation

`SourceFrackerBuildState.gd`: pure `source_fracker_dump_liquid_state(frame, result_liquid_id, liquid_capacity, dump_neighbours)` → 3 keys {liquids_after, dumped_amount, cursor_after}, wrapping the shared `dump_liquid_state` (SourceBuildingLiquidDumpState.gd:156 — routing gate + fraction transfer + acceptLiquid gate; reused, not modified) with scaling 2f, output_dir −1. **ONE call site in the tick after the advance covers BOTH branches** (instead of two call sites): the advance runs exactly one branch, and the dump depends only on the post-advance store; in the if-branch Java dumps before `accumulator += …` but the accumulator does not affect the dump, so there is no observable difference. The pure N2220 is NOT modified. Neighbours arrive as ONE frame input `dump_liquid_neighbours` (Array of Dictionary: amount/capacity/accepts/has_liquids/can_dump/liquids_present/destination_present/relative_to, default `[]`), defaults per Java (destination present, can_dump true, accepts false). The pure does not mutate its input (duplicates the store, removes only when dumped ≠ 0 so the "current" key never flips). Campaign unlock passes false/false/false → DEFERRED. Tick persists `liquids_after` into the frame + sprite meta (N2275 precedent) + `frame["cdump"]`; `_initial_frame` gains `"cdump": 0`.

## Commits

Slice `2365f112` (worker-N2284, branch `slice/N2284-fracker-dump-liquid`, 5 files, +1165/−5, đã push, remote tip verified by ls-remote). Integration cherry-pick `3492b095` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 40/40, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (Fracker family 5 modules + SolidPump 3 modules + pump dump binding): Ran 35, 9 proof fails, all `AssertionError: unexpectedly None`; plus mechanical-pump update-tile + factory dump outputs Ran 8, 2 proof fails Godot-absent — 0 other failures. Old proofs N2224/N2255/N2268 still green (the dump is a no-op with no neighbours). Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11831/1731/1664/3120; audit stays 1336. DEFERRED 300 (298 − 1 resolved: Fracker dumpLiquid else-branch + 3 new: neighbour live fill, neighbour write-back, campaign unlock). The N2220 "SolidPump dumpLiquid + updateEffect" entry is kept unchanged for N2286 (pure N2220 unmodified). Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07FrackerDumpLiquidProof` — 6 keys: dump_transfers_to_neighbour, dump_scales_by_two, dump_no_transfer_when_neighbour_full, dump_no_transfer_below_threshold, dump_runs_in_both_branches, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.

**Note:** the N2224 test has a comment mentioning `:43` (not an assert) and the N2224 ledger entry keeps the old dump entry — those are N2224's historical snapshots, not modified.
