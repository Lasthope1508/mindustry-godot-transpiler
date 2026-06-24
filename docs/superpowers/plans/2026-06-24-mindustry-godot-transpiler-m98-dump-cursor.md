# M98 Dump cursor migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `BuildingComp.dump(Item)` and `incrementDump(int prox)`:
  - `transient int cdump;`
  - `int dump = this.cdump;`
  - `Building other = proximity.get((i + dump) % proximity.size);`
  - `incrementDump(proximity.size);`
  - `public void incrementDump(int prox){`
  - `if(prox != 0){`
  - `cdump = ((cdump + 1) % prox);`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `cdump`, neighbor index, and `incrementDump()` modulo semantics.
- [x] Add RED Godot runtime structure test for Drill dump cursor state and summary.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_dump_cursor_source()` in `source_parity.py`.
- [x] Add `drill_dump_cursor` in `PortGame.gd`.
- [x] Add `source_increment_dump_cursor()`, `set_drill_dump_cursor()`, and `increment_drill_dump()` in `PortGame.gd`.
- [x] Increment cursor on dump neighbor attempts.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_dump_cursor_source()` and missing `drill_dump_cursor`/cursor helpers.
- Targeted GREEN passed for source parity and cursor runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 125 tests in 1.474s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - Pure helper: `source_increment_dump_cursor(2, 4) = 3`.
  - Pure helper: `source_increment_dump_cursor(3, 4) = 0`.
  - Pure helper: `source_increment_dump_cursor(7, 0) = 7`.
  - State increments: `increment_drill_dump(4)` twice returns `[1, 2]`.
  - Current single-neighbor dump: Drill/core `1/3999 -> 0/4000`, cursor `0 -> 0`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 101
- Done: 101
- Not done: 0
- Blocked: 0
