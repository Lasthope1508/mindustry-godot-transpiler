# N2287 LiquidBridge DoDump — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-7, integration branch `integration/wave-advances-7-n2281-n2287`, base `d6e4f9fd`).

## Source

`public void doDump(){ dumpLiquid(liquids.current(), 1f); }` (LiquidBridge.java:29-31) — scaling **1f**, NOT the 2f default. doDump is called from the ItemBridge.updateTile unlinked branch: `if(!hadValidLink){ doDump(); warmup = 0f; }` (ItemBridge.java:335-337). **The base ItemBridge doDump is `dumpAccumulate()`** (ItemBridge.java:350-353, ITEM dump) — a DIFFERENT slice, not this one; this slice is only the LiquidBridge OVERRIDE (liquid dump). `dumpLiquid` impl **:886–908** (not :886–910 — the method closes at :908; :910 is `canDumpLiquid`); early return when `liquids.get(liquid) <= 0.0001f` (:889); iterate proximity from cdump, `incrementDump` EVERY iteration; transfer when `ofract < fract`: `(fract - ofract) * block.liquidCapacity / scaling`. `transferLiquid` **:914–921** (not :916–924); `canDumpLiquid` default true **:910–912** (not :912–914); campaign unlock **:891** (not :892). `transient int cdump;` (BuildingComp.java:68). **Cursor invariant (Java-exact, found by N2286, confirmed here):** `incrementDump` runs EVERY iteration, so a full scan returns the cursor to its start (a stale cursor normalizes via `(cdump+prox)%prox`); the early return at ≤0.0001f does not move the cursor. **Cite fixes folded in:** `incrementDump` is :1116–1121 (N2276 wrote :1116–1120, missing the closing `}`); LiquidModule remove is :125 (N2275 wrote :124–127).

## Implementation

`SourceLiquidBridgeBuildState.gd` (phase-conduit ONLY, as in N2275 — bridge-conduit/reinforced-bridge-conduit OUT): pure `source_liquid_bridge_do_dump_state(frame, had_valid_link, liquids, liquid_capacity, neighbours)` → 3 keys {liquids_after, dumped_amount, cursor_after}, wrapping the shared `dump_liquid_state` (scaling **1f**, `SOURCE_LIQUID_BRIDGE_DUMP_SCALING := 1.0`, output_dir −1, callback `increment_dump_cursor_state`; reused, NOT modified). `liquids.current()` comes from the frame liquids store (N2275 precedent). Tick wiring in the unlinked branch after the transport advance (linked branch does NOT dump — Java calls doDump only when !hadValidLink). Neighbour arrays are frame inputs `dump_neighbour_amounts/capacities/accepts` (+ optional gate arrays), default `[]`; proximity is the min of the 3 arrays (a neighbour missing data is not modeled); gate arrays default per Java (`canDumpLiquid` default true). Frame gains `"cdump": 0`.

## Commits

Slice `fc48fa18` (worker-N2287, branch `slice/N2287-liquid-bridge-do-dump`, 5 files, +1064/−5, đã push, remote tip verified by ls-remote). Integration cherry-pick `3c69b01b` on `integration/wave-advances-7-n2281-n2287` (base d6e4f9fd). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 54/54, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (8 LiquidBridge + ItemBridge modules Ran 32: power/should-consume/update-transport/auto-link/link-frame): 24 PASS + 8 proof fails, all `AssertionError: unexpectedly None` — 0 other failures. Proof live-tick: phase-conduit unlinked, 50→20 (dump 30), efficiency 0 / potential 0.5, warmup 0, cdump 0. Full gate (wave advances-7 integration, run 2 PID 1754): Ran 6238 tests in 1158.186s, FAILED (failures=236, skipped=5), 0 errors — 236/236 Godot-absent `AssertionError: unexpectedly None` (229 inherited + 7 new proof tests N2281–N2287). Run 1 (PID 12422) was killed by VM restart #7 ~02:28–02:29 with no footer; javalang 0.13.0 reinstalled 02:29 before run 2.

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11831/1731/1664/3120; audit stays 1336. DEFERRED 300 (298 − 1 resolved: LiquidBridge doDump rows + 3 new: live neighbour fill, neighbour write-back, campaign unlock). Merged wave DEFERRED: 313 entries (DEFERRED-after-advances-7.py) — 298 − 7 resolved/removed + 22 new, resolved by entry TEXT not number.

## Godot debt

`C07LiquidBridgeDoDumpProof` — 7 keys: dump_transfers_to_neighbour, dump_scales_by_one, dump_no_transfer_when_neighbour_full, dump_only_when_unlinked, dump_no_transfer_below_threshold, dump_cursor_advances, live_tick_dumps_liquid (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). The `dump_cursor_advances` key asserts the full-cycle invariant (a full scan returns the cursor to its start), not a naive advance. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
