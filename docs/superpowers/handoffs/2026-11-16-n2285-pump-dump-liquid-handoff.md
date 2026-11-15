# N2285 Pump DumpLiquid — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

Pump dumpLiquid(liquidDrop) on the placed path, scaling 2f, guarded by liquidDrop != null, after the N2221 advance. Pure `source_mechanical_pump_dump_liquid_state` → 3 keys (liquids_after, dumped_amount, cursor_after). The scenario path is untouched.

## Key facts for the next agent

- **The brief's pure name was unusable:** `source_pump_dump_liquid_state` is already owned by the N2090 scenario helper — `upsert_source_state_schema` REPLACES, so reusing it would have overwritten N2090's entries and broken `test_pump_dump_liquid_binding.py`. The family-convention name `source_mechanical_pump_dump_liquid_state` is used instead.
- **Defs (brief was wrong):** the power-consuming Pump defs are rotary-pump (Blocks.java:2304–2312) + impulse-pump (:2313–2321); mechanical-pump (:2298–2302) has NO consumePower, so the driver gate excludes it.
- dumpLiquid impl **:886–908**; `transferLiquid` **:914–921**; `canDumpLiquid` **:910–912**; campaign unlock **:891** (all confirmed by N2284/N2286/N2287 independently). Pump.java :178–180, totalProgress :176, scaling 2f :877–878 all correct as briefed.
- **Cursor invariant (Java-exact, found by N2286):** a full scan calls incrementDump once per neighbour = a full circle, so `cursor_after` always equals the input cursor.
- **validTiles/boost is N/A for Pump** (SolidPump.java:150-159); the Pump proximity deferral is the per-tick re-scan (liquidDrop only in onProximityUpdate, Pump.java:141–152).
- **Pre-existing wrong cite (flagged, not this slice's file):** `SourcePumpRuntimeState.gd` and `register_pump_dump_liquid_binding.py` (N2090) cite the dump block as Pump.java:180–182; the real block is :178–180.
- Regression caught mid-run: the N2221 test's `'dumpLiquid waits for its own slice'` string split across two comment lines — fixed by keeping it on one line (N2148 lesson).
- The driver is SourceMechanicalPumpBuildState.gd (there is NO SourcePumpBuildState.gd).
- SSOT +3/+1/+1/+2 → 11831/1731/1664/3120 (audit 1336). Exact-evidence 30/30. DEFERRED 300 (−1 +3 new).

## Godot debt (this slice)

`C07PumpDumpLiquidProof` — 6 keys: dump_transfers_to_neighbour, dump_scales_by_two, dump_no_transfer_when_neighbour_full, dump_skipped_when_no_liquid_drop, dump_no_transfer_below_threshold, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_pump_dump_liquid`. Do NOT mark done until it passes there.
