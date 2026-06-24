# M100 Move forward migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `moveForward(Item item)`:
  - `public boolean moveForward(Item item){`
  - `Building other = front();`
  - `if(other != null && other.team == team && other.acceptItem(self(), item)){`
  - `other.handleItem(self(), item);`
  - `return true;`
  - `return false;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `moveForward(Item)` front lookup, team/accept guard, handle call, and return values.
- [x] Add RED Godot runtime structure test for source move-forward handoff to core.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_move_forward_source()` in `source_parity.py`.
- [x] Add `source_move_forward_accept_state()` in `PortGame.gd`.
- [x] Add `source_move_forward_to_core()` using existing source core accept/handle helpers.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_move_forward_source()` and missing `source_move_forward_accept_state()` / `source_move_forward_to_core()` helpers.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 129 tests in 1.469s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_move_forward_accept_state(false, true, true)` returns `false`.
  - `source_move_forward_accept_state(true, false, true)` returns `false`.
  - `source_move_forward_accept_state(true, true, false)` returns `false`.
  - `source_move_forward_accept_state(true, true, true)` returns `true`.
  - Full core: `source_move_forward_to_core("copper", true, true)` returns `false`; core remains `4000`.
  - Open core: `source_move_forward_to_core("copper", true, true)` returns `true`; core changes `3999 -> 4000`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 103
- Done: 103
- Not done: 0
- Blocked: 0
