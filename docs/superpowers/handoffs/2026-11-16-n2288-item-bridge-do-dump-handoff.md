# N2288 ItemBridge DoDump — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## What this slice did

ItemBridge doDump/dumpAccumulate in the unlinked branch only. Pure `source_item_bridge_do_dump_state` → 5 keys (dump_accum_after, dumped, dump_attempts, items_after, cursor_after). Reuses the shared `dump_accumulate_state` static + `dump_item_state` routing.

## Key facts for the next agent

- doDump is ONLY in the unlinked branch: `if(!hadValidLink){ doDump(); warmup = 0f; }` (ItemBridge.java:335-337). The linked branch does NOT dump.
- dumpAccumulate may dump MULTIPLE times per frame: `dumpAccum += delta(); while(dumpAccum >= 1f){ res |= dump(item); dumpAccum -= 1f; }` (BuildingComp.java:1053-1061).
- **No `items.total() > 0` gate around the accumulator** (unlike the Deconstructor) — the accum advances even with an empty store, the dump just fails.
- delta() = Time.delta × timeScale (BuildingComp.java:1922-1924), NOT edelta().
- The PortBridge `source_dump_accumulate_attempt_state` is an INSTANCE method — the all-static driver calls the underlying `dump_accumulate_state` static directly (N2276 precedent).
- `dump(Item)` is :1072-1114 (the method closes at :1114 — N2294 correction).
- The worker built DEFERRED from DEFERRED-after-advances-7.py (313), NOT the N2287 register's stale 300-entry list.
- SSOT +5/+1/+1/+2 → 11860/1738/1671/3134 (audit 1336). Exact-evidence 43/43. DEFERRED 314 (−1 +2 new).

## Godot debt (this slice)

`C07ItemBridgeDoDumpProof` — 6 keys: dump_fires_when_accum_reaches_one, dump_no_fire_below_threshold, dump_multiple_times_per_frame, dump_only_when_unlinked, dump_removes_item_from_store, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_item_bridge_do_dump`. Do NOT mark done until it passes there.
