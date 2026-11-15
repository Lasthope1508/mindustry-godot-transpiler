# N2276 PayloadDeconstructor Dump Rows — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

PayloadDeconstructor dump rows: dumpRate 4 × dumpAccumulate. Pure `source_payload_deconstructor_dump_state` → 4 keys (dump_accum_after, dumped, items_after, cursor_after). Each dumpAccumulate adds delta() (not edelta), then dumps while dumpAccum ≥ 1f, subtracting 1f unconditionally per loop (even when dump fails).

## Key facts for the next agent

- **Dump block is PayloadDeconstructor.java:111-115** (not :110-116 — :110 is `super.updateTile()`, :116 is blank).
- **The brief was self-contradictory on order** — Java wins: dump runs BEFORE the advance (dump block :111-115 precedes the progress block :117+); the test pins the order by index compare.
- **The brief's suggested helper was wrong**: `game_put_item_state` is putItem (one specific item) and cannot express `dump(null)` (neighbour-outer/item-inner) — the slice reuses `dump_item_state` in the same shared file; no shared file was modified.
- New frame keys `dump_accum` (0.0) + `cdump` (0); neighbour accept/canDump are frame inputs `dump_neighbour_accepts` / `dump_neighbour_can_dump` (default `[]`); content ids via `source_item_catalog_state`.
- Deconstructing fill (handlePayload) is NOT this slice.
- SSOT +4/+1/+1/+2 → 11799/1724/1655/3102 (audit 1336). Exact-evidence 35/35. DEFERRED 291 (−1 resolved + 2 new: neighbour live fill, neighbour write-back).

## Godot debt (this slice)

`C07PayloadDeconstructorDumpProof` — 7 keys: dump_accumulates_with_delta, dump_fires_when_accum_reaches_one, dump_rate_four_per_tick, no_dump_when_items_empty, dump_removes_item_from_store, dump_cursor_advances, live_tick_dumps_item (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_payload_deconstructor_dump`. Do NOT mark done until it passes there.
