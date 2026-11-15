# N2288 ItemBridge DoDump — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## Source

Unlinked branch `if(!hadValidLink){ doDump(); warmup = 0f; }` (ItemBridge.java:335-337). `public void doDump(){ dumpAccumulate(); }` (ItemBridge.java:350-353). `dumpAccumulate()` delegates `dumpAccumulate(null)` (BuildingComp.java:1048-1050). `dumpAccumulate(Item)` (BuildingComp.java:1053-1061): `dumpAccum += delta(); while(dumpAccum >= 1f){ res |= dump(item); dumpAccum -= 1f; }` — may dump MULTIPLE times per frame. `dump()` = `dump(null)` (BuildingComp.java:1064-1066; `dump(Item)` :1072-1114 — the method closes at :1114, N2294 correction). `private transient float dumpAccum;` (:99); `transient int cdump;` (:68); `delta()` = Time.delta × timeScale (:1922-1924), NOT edelta().

## Implementation

`SourceItemBridgeBuildState.gd` (phase-conveyor ONLY, as in N2225): pure `source_item_bridge_do_dump_state(frame, had_valid_link, source_delta, time_scale, content_item_ids, neighbour_accepts_item, neighbour_can_dump)` → 5 keys {dump_accum_after, dumped, dump_attempts, items_after, cursor_after}. The 5th key `dump_attempts` (number of dump() fires) is a worker decision — the brief allowed 4–5 keys, and 5 matches the SSOT estimate. Reuses the shared `dump_accumulate_state` static (SourceBuildingItemDumpState.gd:186-193 — the static the PortBridge instance method delegates to; the all-static driver calls it directly, N2276 precedent) + `dump_item_state` per attempt (dump(null) semantics). Counting attempts up-front is Java-exact (the while loop calls dump() exactly once per unit of accum, subtracting 1f unconditionally). **No `items.total() > 0` gate around the accumulator** (unlike the Deconstructor) — the accum advances even with an empty store, the dump just fails. Linked → store/accum/cursor untouched. Tick wiring: after the N2225 advance in the enabled gate; neighbour arrays are frame inputs (`dump_neighbour_accepts` / `dump_neighbour_can_dump`, default `[]`); `_initial_frame` gains `dump_accum: 0.0` + `cdump: 0`.

## Commits

Slice `dca7c8d6` (worker-N2288, branch `slice/N2288-item-bridge-do-dump`, 5 files, +1053/−7, đã push, remote tip verified by ls-remote). Integration cherry-pick `9670ecb3` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 43/43, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (9 modules: ItemBridge power/should-consume/transport/auto-link/link-frame + LiquidBridge power/should-consume/update-transport/do-dump): all 3/4 PASS, only their proof tests fail — 0 other failures. Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11860/1738/1671/3134; audit stays 1336. DEFERRED 314 (313 − 1 resolved: ItemBridge doDump/dumpAccumulate + 2 new: live neighbour fill, neighbour write-back). The worker built from DEFERRED-after-advances-7.py (313), NOT the N2287 register's stale 300-entry list — avoiding the stale-base trap. Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

`C07ItemBridgeDoDumpProof` — 6 keys: dump_fires_when_accum_reaches_one, dump_no_fire_below_threshold, dump_multiple_times_per_frame, dump_only_when_unlinked, dump_removes_item_from_store, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
