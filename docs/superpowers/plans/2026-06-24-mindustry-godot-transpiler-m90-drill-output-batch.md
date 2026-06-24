# M90 Drill output batch/modulo migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/world/blocks/production/Drill.java`
- Lines checked from `DrillBuild.updateTile()`:
  - `if(dominantItems > 0 && progress >= delay && items.total() < itemCapacity){`
  - `int amount = (int)(progress / delay);`
  - `offload(dominantItem);`
  - `progress %= delay;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for output gate, amount cast, offload, and modulo.
- [x] Add RED Godot runtime structure test for `source_drill_output_batch()` and factory wiring.
- [x] Prove RED failure before production code.
- [x] Add `verify_drill_output_batch_source()` in `source_parity.py`.
- [x] Add `source_drill_output_batch()` in `PortGame.gd`.
- [x] Route factory drill production through raw source progress and batch modulo.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify Godot LSP via MCP.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_drill_output_batch_source` and missing `source_drill_output_batch` runtime wiring.
- Targeted GREEN passed for both new tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 110 tests in 1.410s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd`: `diagnostics: []`.
- MCP runtime proof with `_process` disabled:
  - `source_drill_delay("mechanical-drill", "copper") = 650`
  - `source_block_item_capacity("mechanical-drill") = 10`
  - `source_drill_output_batch(1301, 650, 2, 0, 10) = {"amount": 2, "progress": 1}`
  - `source_drill_output_batch(1301, 650, 2, 10, 10) = {"amount": 0, "progress": 1301}`
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 93
- Done: 93
- Not done: 0
- Blocked: 0
