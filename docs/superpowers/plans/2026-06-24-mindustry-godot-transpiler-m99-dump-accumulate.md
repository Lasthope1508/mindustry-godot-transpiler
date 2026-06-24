# M99 Dump accumulate migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `dumpAccumulate()` and `dumpAccumulate(Item item)`:
  - `private transient float dumpAccum;`
  - `public boolean dumpAccumulate(){`
  - `return dumpAccumulate(null);`
  - `public boolean dumpAccumulate(Item item){`
  - `boolean res = false;`
  - `dumpAccum += delta();`
  - `while(dumpAccum >= 1f){`
  - `res |= dump(item);`
  - `dumpAccum -=1f;`
  - `return res;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `dumpAccum` and `dumpAccumulate()` loop semantics.
- [x] Add RED Godot runtime structure test for accumulator attempt scheduling.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_dump_accumulate_source()` in `source_parity.py`.
- [x] Add `building_dump_accum` in `PortGame.gd`.
- [x] Add `source_dump_accumulate_attempt_state()` without fabricating actual dump success.
- [x] Add `step_building_dump_accum()` and expose state in runtime summary.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_dump_accumulate_source()` and missing `building_dump_accum`/accumulator helpers.
- Targeted GREEN passed for source parity and accumulator runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 127 tests in 1.425s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_dump_accumulate_attempt_state(0.25, 2.8)` returns `dump_attempts=3`, `dump_accum=0.0499999999999998`.
  - `step_building_dump_accum(0.6)` returns `dump_attempts=0`, `dump_accum=0.6`; summary reports `building_dump_accum=0.6`.
  - Second `step_building_dump_accum(0.6)` returns `dump_attempts=1`, `dump_accum=0.2`; summary reports `building_dump_accum=0.2`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 102
- Done: 102
- Not done: 0
- Blocked: 0
