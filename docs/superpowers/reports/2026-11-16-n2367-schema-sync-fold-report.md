# Report N2367 — Schema-sync fold of write-back + offload advance keys

**Slice:** N2367 — Fold the 9 advance result keys exposed by the
advances-17/18 write-back slices into their owning result schemas +
contract return_keys, and register the 5 keys that had no symbol.
**Wave:** advances-18 (coordinator-serial). **Commit:** `d155bbf5d`
on `integration/wave-advances-18-n2358-n2364` (no slice branch —
coordinator-serial after integration). **Files:** 20, +453/−63.

## Source

Java: BuildingComp.java:1001-1016 (offload), :1007 (proximity get),
:1009 (handleItem), :1053-1061 (dumpAccumulate), :1057
(`res |= dump(item);`), :1072-1113 (dump path), :1082/:1099
(proximity get), :1089 (dump(null) branch), :1103 (specific branch).

## Implementation

Full fold — symbols + schema + contract for all 9 keys:
- N2360 BurstDrill timerDump: `dump_neighbour_index`, `dumped_item`
  (symbols already registered by N2360) → N2282 schema/contract.
- N2361 Separator timerDump: `dump_neighbour_index`, `dumped_item`
  (symbols already registered by N2361) → N2281 schema/contract.
- N2362 ItemBridge doDump: `dump_deliveries` (Array) → N2288
  schema/contract + 1 new symbol (registered by the N2362 register;
  `f('Array', 'res |= dump(item);', ...)`).
- N2363 BeamDrill timerDump: `dump_neighbour_index`, `dumped_item`
  → N2289 schema/contract + 2 new symbols (N2363 register).
- N2353 Separator offload: `offload_neighbour_index`,
  `offload_routed` → N2222 schema/contract + 2 new symbols (N2353
  register, godot_owner = the Separator advance — the N2353 tests now
  allow mixed owners).

Design: the 5 owning registers split schema/contract (merged keys)
from the symbol loop (ORIGINAL outputs only) —
`upsert_source_symbols` does `symbols.update(entries)`, a wholesale
replace, so folding the keys into the symbol loop would have stolen
the write-back slices' symbol ownership. Verified after the re-runs:
N2360/N2361 symbols still carry their write-back tests.

## Tests

Targeted 11 modules (3 symbol slices + 5 owning + N2360/N2361/N2343)
Ran 44 (33 PASS + 11 proof Godot-absent), 0 other errors. No new
proof test.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT **12013/1799/1729/3250 → 12018/1799/1729/3250 (+5 symbols)**;
ledger/contracts/schemas counts unchanged (no new slices, contracts,
or schemas — only key sets within 5 existing schemas + 5 existing
contracts grew). Audit stays 1336. DEFERRED 0.
Folded schemas: `source_burst_drill_timer_dump_state_result` 5→7,
`source_separator_timer_dump_state_result` 5→7,
`source_item_bridge_do_dump_state_result` 5→6,
`source_beam_drill_timer_dump_state_result` 5→7,
`source_separator_update_tile_advance_state_result` 8→10; all 5
contracts' return_keys match.

## Godot debt

- No new proof, no re-run needed (no driver or proof fixture changed;
  registration-only slice).
- The offload keys now have symbols — no gap remains from the N2353
  "unregistered API shape" note.
