# N2276 PayloadDeconstructor Dump Rows — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## Source

`dumpRate = 4` (PayloadDeconstructor.java:20). `updateTile()` (:111-115, not :110-116 — :110 is `super.updateTile()`, :116 is blank): `if(items.total() > 0){ for(int i = 0; i < dumpRate; i++){ dumpAccumulate(); } }`. `dumpAccumulate()` (BuildingComp.java:1048-1061): `dumpAccum += delta();` `while(dumpAccum >= 1f){ res |= dump(item); dumpAccum -= 1f; }` — dumpAccum is a Building field (default 0f); the −1f subtract is UNCONDITIONAL each while iteration, even when dump() fails (BuildingComp.java:1056-1058). `dump(Item todump)` (BuildingComp.java:1064+): scans proximity by dump cursor, `putItem` into a neighbour that accepts. **The brief was self-contradictory on order** ("run dump after advance" vs "mirror Java order dump BEFORE progress") — Java wins: the dump block (:111-115) runs BEFORE the deconstructing progress block (:117+), so the driver wires dump BEFORE the advance; the test pins the order by index compare. **The brief's suggested helper was wrong**: `game_put_item_state` is putItem (one specific item, needs a game object for callbacks) and cannot express `dump(null)` (neighbour-outer/item-inner) — the slice reuses `dump_item_state` in the same shared file (the correct port of `dump(null)`); no shared file was modified.

## Implementation

`SourcePayloadDeconstructorBuildState.gd`: pure `source_payload_deconstructor_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts_item, neighbour_can_dump)` → {dump_accum_after, dumped, items_after, cursor_after}: 4× dumpAccumulate when `items.total() > 0`, each `dump_accum += delta()` (delta, NOT edelta) then dump while `>= 1f`, subtracting 1f unconditionally per loop. Dump goes through shared `SourceBuildingItemDumpState.dump_item_state`, cursor + items map-back by content order. New frame keys `dump_accum` (0.0) + `cdump` (0) in `_initial_frame`; neighbour accept/canDump are frame inputs `dump_neighbour_accepts` / `dump_neighbour_can_dump` (default `[]`); content ids via `source_item_catalog_state` (PayloadLoader/Unloader precedent). Tick wiring: dump runs BEFORE the advance inside the same enabled gate (Java order), stamping `dump_accum`/`items`/`cdump` on the frame.

## Commits

Slice `75ce778a` (worker-N2276, branch `slice/N2276-payload-deconstructor-dump`, 5 files, +1037/−6, đã push, remote tip verified by ls-remote). Integration cherry-pick `fd5f1bfd` on `integration/wave-advances-6-n2274-n2280` (base 253151ad). No coordinator fix needed for this slice (the wave cite fix d0ea2b64 touched its register's DEFERRED snapshot only).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 35/35, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (12/16 PASS), the fails all their Godot proof tests — 0 other failures. Proof arithmetic validated by Python simulation of `dump_item_state` + the pure function (11/12 scenarios pass; the 1 "fail" was a wrong expectation in the check script, not in the proof: `items_after` keeps the dict unchanged when nothing dumps). Full wave gate run 2 (PID 4988, launch 01:07 by coordinator lượt 10, done 01:47 +07 16/11): Ran 6210 in 2126.929s, failures=229, skipped=5, 0 errors — 229/229 Godot-absent (222 inherited + 7 new proof tests N2274–N2280). Run 1 (PID 2132, launch 00:31, done 01:07) invalid: Ran 5527, failures=231, errors=15 — all javalang-import (VM restart #6 ~00:27 wiped javalang; reinstalled 0.13.0 at 01:00).

## SSOT / DEFERRED

SSOT single-slice +4/+1/+1/+2 → 11799/1724/1655/3102; audit stays 1336. DEFERRED 291 (290 − 1 resolved: dump rows + 2 new: neighbour live fill, neighbour write-back). Merged wave DEFERRED: 298 entries (DEFERRED-after-advances-6.py) — 290 − 9 resolved/removed + 17 new, resolved by entry TEXT not number.

## Godot debt

`C07PayloadDeconstructorDumpProof` — 7 keys: dump_accumulates_with_delta, dump_fires_when_accum_reaches_one, dump_rate_four_per_tick, no_dump_when_items_empty, dump_removes_item_from_store, dump_cursor_advances, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
