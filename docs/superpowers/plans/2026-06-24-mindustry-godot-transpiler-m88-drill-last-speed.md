# M88 Drill lastDrillSpeed migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/world/blocks/production/Drill.java`
- Lines checked from `DrillBuild.updateTile()`:
  - `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;`
  - `lastDrillSpeed = (speed * dominantItems * warmup) / delay;`
  - `lastDrillSpeed = 0f;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for exact `lastDrillSpeed` snippets.
- [x] Add RED Godot runtime structure test for per-cell last speed state.
- [x] Prove RED failure before production code.
- [x] Add `verify_drill_last_speed_source()` in `source_parity.py`.
- [x] Add `source_drill_delay()`, `source_drill_last_speed()`, `drill_last_speeds`, accessors, and factory wiring in `PortGame.gd`.
- [x] Wire last speed before warmup update to match Java source order.
- [x] Run targeted GREEN tests.
- [x] Run full Python test suite.
- [x] Verify Godot LSP via MCP.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_drill_last_speed_source` and missing `drill_last_speeds` state.
- Targeted GREEN passed for both new tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 107 tests in 1.429s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd`: `diagnostics: []`.
- MCP runtime proof with `_process` disabled:
  - `source_drill_delay("mechanical-drill", "copper") = 650`
  - `source_drill_last_speed("mechanical-drill", "copper", 2, 0.9, 1.0) = 0.00276923076923077`
  - `step_factory_drill(1.0)` reports `drill_last_speed = 0.00276923076923077`
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 91
- Done: 91
- Not done: 0
- Blocked: 0
