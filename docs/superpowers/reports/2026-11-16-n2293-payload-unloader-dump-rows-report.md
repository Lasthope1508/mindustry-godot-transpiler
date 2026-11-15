# N2293 PayloadUnloader Dump Rows — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## Source

End of updateTile (PayloadUnloader.java:**105–108** — the brief's :104–110 was off by one: :104 is blank, :109 closes the method): `dumpLiquid(liquids.current());` + `for(int i = 0; i < offloadSpeed; i++){ dumpAccumulate(); }`. **The dump is TRULY unconditional** — it sits OUTSIDE `if(payload != null)` (:52–54) AND outside the if-else shouldExport/moveInPayload (:57–103, closes :103), not merely "after the moveInPayload branch". offloadSpeed = 4 (PayloadUnloader.java:9). `dumpLiquid(Liquid)` → scaling 2f (BuildingComp.java:877-878). `dumpLiquid` impl :886–908; threshold :889; unlock :891; `canDumpLiquid` :910–912; `transferLiquid` :914–921; `dumpAccumulate` :1048–1061; `dump(Item)` :1072–1114; `incrementDump` :1116–1121; `hasItems = true;` (PayloadLoader.java:37). **`liquids.current()` is never null in Java** (`private Liquid current = content.liquid(0);`, LiquidModule.java:24) — the null guard in the pure is only for partial fixtures. **Cursor invariant (N2286, Java-exact):** a full dumpLiquid scan returns the cursor to its start.

## Implementation

`SourcePayloadUnloaderBuildState.gd`: **1 pure** `source_payload_unloader_dump_state` covering both liquid + item → 6 keys {liquids_after, dumped_liquid, items_after, dumped_items, cursor_after, dump_accum_after}. Liquid: wraps the shared `dump_liquid_state` (scaling 2f, output_dir −1), passing the current liquid **id** (int) instead of the name — the helper only uses it as bookkeeping. Item: 4× `dump_accumulate_state` (the static the PortBridge instance method delegates to — the static pure cannot call the instance method directly; no driver precedent instantiates the bridge) + `dump_item_state` routing. Campaign flags follow the N2286 precedent (false/true/true), differing from N2284 (false/false/false) — not observable since the pure doesn't surface an unlock key (DEFERRED). Tick wiring after the N2232 advance, inside the enabled gate (N2195 precedent). Frame keys: `dump_accum`, `cdump`. Neighbour arrays are frame inputs (default `[]`).

## Commits

Slice `a4c75553` (worker-N2293, branch `slice/N2293-payload-unloader-dump-rows`, 5 files, +1266/−4, đã push, remote tip verified by ls-remote). Integration cherry-pick `48d41518` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 56/56, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings: 30/30 non-proof PASS (Unloader power/should-consume/update-tile/live-fill, Loader family 5 modules, Deconstructor dump — 40 tests, 10 fails all proof Godot-absent, counted 10× `unexpectedly None`); plus N2284/N2286/N2281: 9/9 non-proof PASS, 3 fails all proof Godot-absent — 0 other failures. Proof live-tick pins the dump running even with **no payload + efficiency 0** (gate false) — the unconditional Java behavior. Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice +6/+1/+1/+2 → 11861/1738/1671/3134; audit stays 1336. Shards changed: `payload_slices` + `payload_api_contracts` (N2279 precedent). DEFERRED 315 (313 − 1 resolved: PayloadUnloader dump rows + 3 new: neighbour live fill, neighbour write-back, campaign-unlock surfacing). Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

`C07PayloadUnloaderDumpProof` — 6 keys: dump_transfers_liquid_to_neighbour, dump_scales_liquid_by_two, dump_items_via_accumulate, dump_accum_grows_by_four_delta, dump_no_transfer_when_neighbour_full, live_tick_dumps_both (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
