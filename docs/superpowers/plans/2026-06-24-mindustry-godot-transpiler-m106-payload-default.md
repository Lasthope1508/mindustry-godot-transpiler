# M106 Payload default migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from default payload methods:
  - `public boolean acceptPayload(Building source, Payload payload){`
  - `return false;`
  - `public void handlePayload(Building source, Payload payload){`
  - empty `handlePayload` body

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for default payload snippets.
- [x] Add RED Godot runtime structure test for payload default helpers.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_payload_default_source()` in `source_parity.py`.
- [x] Add `source_building_accept_payload_state()` and `source_building_handle_payload_state()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.
- [x] Run `git diff --check`.
- [x] Stage only touched files and commit.

## Verification

- Targeted RED failed for missing `verify_building_payload_default_source()` and missing `source_building_accept_payload_state()`.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 141 tests in 1.423s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_building_accept_payload_state()` returns `false`.
  - `source_building_handle_payload_state({payload="test", count=3})` returns `{payload="test", count=3}`.
  - Debug output `errors: []`, stop output `finalErrors: []`.
- `git diff --check`: exit `0` with CRLF normalization warnings only.

## Totals After This Beat

- Total tracked work items: 109
- Done: 109
- Not done: 0
- Blocked: 0
