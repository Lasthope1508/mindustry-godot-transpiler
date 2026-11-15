# N2287 LiquidBridge DoDump — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## What this slice did

LiquidBridge doDump: `dumpLiquid(liquids.current(), 1f)` in the unlinked branch only. Pure `source_liquid_bridge_do_dump_state` → 3 keys (liquids_after, dumped_amount, cursor_after). Scaling 1f (not the 2f default).

## Key facts for the next agent

- doDump is called ONLY from the unlinked branch: `if(!hadValidLink){ doDump(); warmup = 0f; }` (ItemBridge.java:335-337). The linked branch does NOT dump.
- **The base ItemBridge doDump is `dumpAccumulate()`** (ItemBridge.java:350-353, ITEM dump) — a DIFFERENT slice, not this one; this slice is only the LiquidBridge OVERRIDE (liquid dump).
- dumpLiquid impl **:886–908**; `transferLiquid` **:914–921**; `canDumpLiquid` **:910–912**; campaign unlock **:891** (all confirmed by N2284/N2285/N2286 independently).
- **Cursor invariant (Java-exact, found by N2286):** a full scan returns the cursor to its start (a stale cursor normalizes via `(cdump+prox)%prox`); the early return at ≤0.0001f does not move the cursor. The `dump_cursor_advances` proof key asserts this invariant, not a naive advance.
- **Cite fixes folded in:** `incrementDump` is :1116–1121 (N2276 wrote :1116–1120, missing the closing `}`); LiquidModule remove is :125 (N2275 wrote :124–127).
- Proximity is the min of the 3 neighbour arrays (a neighbour missing data is not modeled); gate arrays default per Java (`canDumpLiquid` default true).
- Phase-conduit ONLY (as in N2275). `liquids.current()` comes from the frame liquids store.
- SSOT +3/+1/+1/+2 → 11831/1731/1664/3120 (audit 1336). Exact-evidence 54/54. DEFERRED 300 (−1 +3 new).

## Godot debt (this slice)

`C07LiquidBridgeDoDumpProof` — 7 keys: dump_transfers_to_neighbour, dump_scales_by_one, dump_no_transfer_when_neighbour_full, dump_only_when_unlinked, dump_no_transfer_below_threshold, dump_cursor_advances, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_liquid_bridge_do_dump`. Do NOT mark done until it passes there.
