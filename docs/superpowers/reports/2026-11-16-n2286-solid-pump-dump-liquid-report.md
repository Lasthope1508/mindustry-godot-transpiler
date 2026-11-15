# N2286 SolidPump DumpLiquid — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

`dumpLiquid(result);` (SolidPump.java:140, unconditional, after `pumpTime += warmup * edelta();` :138). `dumpLiquid(Liquid)` → scaling **2f** (BuildingComp.java:877-878). `dumpLiquid` impl **:886–908** (not :886–910 — :909 is blank, :910 opens `canDumpLiquid`); early return when `liquids.get(liquid) <= 0.0001f` (:889); iterate proximity from cdump, `incrementDump` EVERY iteration; transfer when `ofract < fract`: `(fract - ofract) * block.liquidCapacity / scaling`. `transferLiquid` **:914–921** (not :916–924 — flow :915, accept gate :917, handle :918, remove :919). `canDumpLiquid` default true **:910–912** (not :912–914). Campaign unlock **:891** (not :892). **Defs:** ONLY water-extractor is a SolidPump (Blocks.java:2920, result water) — oil-extractor is a Fracker (Blocks.java:2964), whose dump is N2284. **Cursor invariant (Java-exact, FOUND BY THIS SLICE, confirmed by N2284/N2285/N2287):** a full scan over N neighbours calls `incrementDump` N times = one full circle → `cursor_after` ALWAYS equals the input cursor (the cursor only matters WITHIN the scan). The proof + test pin this behavior instead of "cursor advances".

## Implementation

`SourceSolidPumpBuildState.gd`: pure `source_solid_pump_dump_liquid_state(frame, result_liquid_id, liquid_capacity, neighbour_liquid_amounts, neighbour_liquid_capacities, neighbour_accepts_liquid, neighbour_can_dump_liquid)` → 3 keys {liquids_after, dumped_amount, cursor_after}, wrapping the shared `dump_liquid_state` (liquid = result water, scaling 2.0, output_dir −1, callback `increment_dump_cursor_state`, campaign flags per the scenario-pump N2090 precedent). **The pure N2220 is UNCHANGED** (only one docstring line noting the dump is live — N2276 precedent; the test pins the original 5-key return dict). Tick wires the dump AFTER the advance in the same enabled gate; `_initial_frame` gains `"cdump": 0`; store write-back via `source_set_state` (mutate in place, N2220 precedent). Neighbour arrays are frame inputs (default `[]`). The dump runs even when efficiency is 0 (unconditional — unlike the Fracker else-branch, which is one branch of two).

## Commits

Slice `3bfdf49f` (worker-N2286, branch `slice/N2286-solid-pump-dump-liquid`, 5 files, +1068/−6, đã push, remote tip verified by ls-remote). Integration cherry-pick `8ba8b4cb` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 36/36, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (SolidPump family 4 modules Ran 16): 12 PASS + 4 proof fails; bonus Fracker 3 modules + PayloadDeconstructor dump Ran 16: 12 PASS + 4 proof fails (Fracker reuses the N2220 pure — safe) — 0 other failures. Proof numbers hand-simulated through the helper (e.g. 20/40 vs neighbour 0/40 → dumped 10; flow clamp 5; 0.0001f threshold exact at the boundary; live tick extractor 20 → 10 at efficiency 0.5). Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11831/1731/1664/3120; audit stays 1336. DEFERRED 301 (298 with the merged "SolidPump dumpLiquid + updateEffect" entry replaced by the narrowed updateEffect-only entry + 3 new: neighbour live fill, neighbour write-back, campaign unlock surfacing). The live fraction fill entry is kept unchanged. Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07SolidPumpDumpLiquidProof` — 6 keys: dump_transfers_to_neighbour, dump_scales_by_two, dump_no_transfer_when_neighbour_full, dump_runs_when_efficiency_zero, dump_no_transfer_below_threshold, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.

**Note:** the Fracker DEFERRED entry quoted the old merged "SolidPump dumpLiquid + updateEffect" entry — that quote is now stale (the merged entry was replaced by the updateEffect-only entry); N2284 resolved the Fracker entry in this same wave, so no stale reference remains in the merged file.
