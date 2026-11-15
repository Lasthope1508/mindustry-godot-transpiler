# N2286 SolidPump DumpLiquid — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

SolidPump dumpLiquid(result), unconditional, after `pumpTime += warmup * edelta();`, scaling 2f. Pure `source_solid_pump_dump_liquid_state` → 3 keys (liquids_after, dumped_amount, cursor_after). The pure N2220 is UNCHANGED.

## Key facts for the next agent

- **Cursor invariant (Java-exact, FOUND BY THIS SLICE):** a full scan over N neighbours calls `incrementDump` N times = one full circle → `cursor_after` ALWAYS equals the input cursor (the cursor only matters WITHIN the scan). Confirmed independently by N2284/N2285/N2287. The proof + test pin this instead of "cursor advances".
- dumpLiquid impl **:886–908** (not :886–910 — :909 is blank, :910 opens `canDumpLiquid`); `transferLiquid` **:914–921** (flow :915, accept gate :917, handle :918, remove :919); `canDumpLiquid` **:910–912**; campaign unlock **:891**.
- **Defs:** ONLY water-extractor is a SolidPump (Blocks.java:2920, result water) — oil-extractor is a Fracker (Blocks.java:2964), whose dump is N2284.
- The dump runs even when efficiency is 0 (unconditional — unlike the Fracker else-branch, which is one branch of two).
- The Fracker driver reuses the N2220 pure — the dump wiring lives in the SolidPump driver only, so Fracker is unaffected (N2284 wires its own dump in the Fracker driver).
- SSOT +3/+1/+1/+2 → 11831/1731/1664/3120 (audit 1336). Exact-evidence 36/36. DEFERRED 301 (merged entry replaced by narrowed updateEffect-only + 3 new).

## Godot debt (this slice)

`C07SolidPumpDumpLiquidProof` — 6 keys: dump_transfers_to_neighbour, dump_scales_by_two, dump_no_transfer_when_neighbour_full, dump_runs_when_efficiency_zero, dump_no_transfer_below_threshold, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_solid_pump_dump_liquid`. Do NOT mark done until it passes there.
