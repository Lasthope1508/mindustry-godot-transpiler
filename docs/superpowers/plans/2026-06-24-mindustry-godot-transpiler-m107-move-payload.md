# M107 Move payload migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `movePayload()`:
  - `public boolean movePayload(Payload todump){`
  - `int trns = block.size/2 + 1;`
  - `Tile next = tile.nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);`
  - `if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){`
  - `next.build.handlePayload(self(), todump);`
  - `return true;`
  - `return false;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `movePayload()` snippets.
- [x] Add RED Godot runtime structure test for move-payload state helpers.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_move_payload_source()` in `source_parity.py`.
- [x] Add `source_payload_forward_offset()` and `source_move_payload_state()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.
- [x] Run `git diff --check`.
- [x] Stage only touched files and commit.

## Verification

- Targeted RED failed for missing `verify_building_move_payload_source()` and missing `source_payload_forward_offset()`.
- Targeted GREEN passed for source parity and runtime structure tests.
- MCP first runtime pass exposed a Godot warning: parameter `block_size` shadowed existing `block_size()` function.
- Added RED assertion for non-shadowing `payload_block_size`, then renamed the helper parameter.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 143 tests in 1.440s`, `OK` after warning fix.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled after warning fix:
  - `source_payload_forward_offset(1/2/3)` returns `[1, 2, 2]`.
  - `source_move_payload_state(false, true, true, true)` returns `false`.
  - `source_move_payload_state(true, false, true, true)` returns `false`.
  - `source_move_payload_state(true, true, false, true)` returns `false`.
  - `source_move_payload_state(true, true, true, false)` returns `false`.
  - `source_move_payload_state(true, true, true, true)` returns `true`.
  - Debug output `errors: []`, stop output `finalErrors: []`.
- `git diff --check`: exit `0` with CRLF normalization warnings only.

## Totals After This Beat

- Total tracked work items: 110
- Done: 110
- Not done: 0
- Blocked: 0
