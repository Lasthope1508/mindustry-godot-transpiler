# N2285 Pump DumpLiquid — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

`if(liquidDrop != null){ dumpLiquid(liquidDrop); }` (Pump.java:178-180, after `totalProgress += warmup * Time.delta;` :176). `dumpLiquid(Liquid)` → scaling **2f** (BuildingComp.java:877-878). `dumpLiquid` impl **:886–908** (not :886–910); early return when `liquids.get(liquid) <= 0.0001f` (:889); iterate proximity from cdump, `incrementDump` EVERY iteration; transfer when `ofract < fract`: `(fract - ofract) * block.liquidCapacity / scaling`. `transferLiquid` **:914–921** (not :916–924); `canDumpLiquid` default true **:910–912** (not :912–914); campaign unlock **:891** (not :892). **Cursor invariant (Java-exact, found by N2286, confirmed here):** a full scan calls incrementDump once per neighbour = a full circle, so `cursor_after` always equals the input cursor — rotation shows in attempt order, not the final cursor. **Defs (brief was wrong):** the power-consuming Pump defs are rotary-pump (Blocks.java:2304–2312) + impulse-pump (:2313–2321); mechanical-pump (:2298–2302) has NO consumePower, so the driver gate excludes it. **validTiles/boost is N/A for Pump** (those are SolidPump.java:150-159); the Pump proximity deferral that stands is the per-tick re-scan (liquidDrop is only set in onProximityUpdate, Pump.java:141–152). **Pre-existing wrong cite (flagged, not this slice's file):** `SourcePumpRuntimeState.gd` and `register_pump_dump_liquid_binding.py` (N2090) cite the dump block as Pump.java:180–182; the real block is :178–180.

## Implementation

`SourceMechanicalPumpBuildState.gd` (there is NO SourcePumpBuildState.gd): pure **`source_mechanical_pump_dump_liquid_state`** → 3 keys {liquids_after, dumped_amount, cursor_after}. **The brief's pure name was unusable:** `source_pump_dump_liquid_state` is already owned by the N2090 scenario helper (input/result schemas + result symbols), and `upsert_source_state_schema` REPLACES — reusing it would have overwritten N2090's entries and broken `test_pump_dump_liquid_binding.py`. The family-convention name is used instead (the wave SCOPE table's pure name for N2285 needs updating). The pure wraps the shared `dump_liquid_state` (scaling 2.0, output_dir −1) + shared `increment_dump_cursor_state` callable; guard liquidDrop null → no-op. Tick wires the dump AFTER the N2221 advance (Java order :178–180 after :176), outside the efficiency branch, writes back via `source_set_state` + `frame["cdump"]`. Neighbour arrays are frame inputs (default `[]`). `SourceBuildingLiquidDumpState.gd` and `SourcePumpRuntimeState.gd` untouched (the scenario path stays untouched).

## Commits

Slice `321785c5` (worker-N2285, branch `slice/N2285-pump-dump-liquid`, 5 files, +1084/−15, đã push, remote tip verified by ls-remote). Integration cherry-pick `bca99f98` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 30/30, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (8 modules Ran 28): 20 PASS + 8 proof fails, all `AssertionError: unexpectedly None` — 0 other failures. One real regression was caught and fixed mid-run: the N2221 test's `'dumpLiquid waits for its own slice'` string had been split across two comment lines; fixed by keeping it on one line as a historical note in the advance docstring (N2148 lesson: split lines fail tests that pin strings). Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11831/1731/1664/3120; audit stays 1336. N2090's scenario schemas untouched (verified owner still `SourcePumpRuntimeState`, slice N2090). DEFERRED 300 (298 − 1 resolved: Pump dumpLiquid placed-path + 3 new: neighbour live fill, neighbour write-back, campaign unlock application). Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07PumpDumpLiquidProof` — 6 keys: dump_transfers_to_neighbour, dump_scales_by_two, dump_no_transfer_when_neighbour_full, dump_skipped_when_no_liquid_drop, dump_no_transfer_below_threshold, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
