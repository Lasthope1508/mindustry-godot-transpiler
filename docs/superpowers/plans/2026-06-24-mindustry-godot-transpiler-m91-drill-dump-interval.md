# M91 Drill dump interval migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/world/Block.java`
- `mindustry-upstream/core/src/mindustry/world/blocks/production/Drill.java`
- Lines checked:
  - `protected final int timerDump = timers++;`
  - `public int dumpTime = 5;`
  - `if(timer(timerDump, dumpTime / timeScale)){`
  - `dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for dump timer field, default dump time, timer gate, and dump call.
- [x] Add RED Godot runtime structure test for dump time and interval helpers.
- [x] Prove RED failure before production code.
- [x] Add `verify_drill_dump_timer_source()` in `source_parity.py`.
- [x] Add `SOURCE_BLOCK_DUMP_TIME` in `PortGame.gd`.
- [x] Add `source_block_dump_time()` in `PortGame.gd`.
- [x] Add `source_drill_dump_interval()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify Godot LSP via MCP.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_drill_dump_timer_source` and missing `SOURCE_BLOCK_DUMP_TIME`/interval helpers.
- Targeted GREEN passed for both new tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 112 tests in 1.506s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd`: `diagnostics: []`.
- MCP runtime proof with `_process` disabled:
  - `source_block_dump_time("mechanical-drill") = 5`
  - `source_drill_dump_interval("mechanical-drill", 1.0) = 5`
  - `source_drill_dump_interval("mechanical-drill", 2.0) = 2.5`
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 94
- Done: 94
- Not done: 0
- Blocked: 0
