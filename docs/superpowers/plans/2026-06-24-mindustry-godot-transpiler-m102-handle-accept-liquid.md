# M102 Handle and accept liquid migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from default `acceptLiquid()` and `handleLiquid()`:
  - `public boolean acceptLiquid(Building source, Liquid liquid){`
  - `return block.hasLiquids && block.consumesLiquid(liquid);`
  - `public void handleLiquid(Building source, Liquid liquid, float amount){`
  - `liquids.add(liquid, amount);`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for default liquid accept/handle snippets.
- [x] Add RED Godot runtime structure test for liquid accept state and amount accumulation.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_handle_accept_liquid_source()` in `source_parity.py`.
- [x] Add `source_building_accept_liquid_state()` in `PortGame.gd`.
- [x] Add `source_building_handle_liquid_amount()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_handle_accept_liquid_source()` and missing source liquid helpers.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 133 tests in 1.412s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_building_accept_liquid_state(false, true)` returns `false`.
  - `source_building_accept_liquid_state(true, false)` returns `false`.
  - `source_building_accept_liquid_state(true, true)` returns `true`.
  - `source_building_handle_liquid_amount(0.0, 2.5)` returns `2.5`.
  - `source_building_handle_liquid_amount(3.25, 0.75)` returns `4`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 105
- Done: 105
- Not done: 0
- Blocked: 0
