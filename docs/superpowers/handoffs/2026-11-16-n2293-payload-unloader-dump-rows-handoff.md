# N2293 PayloadUnloader Dump Rows — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## What this slice did

PayloadUnloader dump rows: dumpLiquid(current) 2f + 4× dumpAccumulate at the end of updateTile. 1 pure `source_payload_unloader_dump_state` covering both liquid + item → 6 keys.

## Key facts for the next agent

- Dump statements are PayloadUnloader.java:**105–108** (not :104–110 — :104 is blank, :109 closes the method).
- **The dump is TRULY unconditional** — outside `if(payload != null)` (:52–54) AND outside the if-else (:57–103). It runs even with no payload + efficiency 0.
- offloadSpeed = 4 (PayloadUnloader.java:9). dumpLiquid scaling 2f (BuildingComp.java:877-878).
- **`liquids.current()` is never null in Java** (LiquidModule.java:24) — the null guard in the pure is only for partial fixtures.
- The PortBridge `source_dump_accumulate_attempt_state` is an INSTANCE method — the static pure calls the underlying `dump_accumulate_state` static directly (same as N2288/N2294).
- Liquid param passed as id (int), not name — the helper only uses it as bookkeeping.
- Campaign flags follow the N2286 precedent (false/true/true), differing from N2284 (false/false/false) — not observable.
- **Cursor invariant (N2286, Java-exact):** a full dumpLiquid scan returns the cursor to its start.
- SSOT +6/+1/+1/+2 → 11861/1738/1671/3134 (audit 1336). Exact-evidence 56/56. DEFERRED 315 (−1 +3 new).

## Godot debt (this slice)

`C07PayloadUnloaderDumpProof` — 6 keys: dump_transfers_liquid_to_neighbour, dump_scales_liquid_by_two, dump_items_via_accumulate, dump_accum_grows_by_four_delta, dump_no_transfer_when_neighbour_full, live_tick_dumps_both (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_payload_unloader_dump`. Do NOT mark done until it passes there.
