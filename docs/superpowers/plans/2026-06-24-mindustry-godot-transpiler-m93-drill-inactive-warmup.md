# M93 Drill inactive warmup migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/world/blocks/production/Drill.java`
- Lines checked from inactive branch in `DrillBuild.updateTile()`:
  - `}else{`
  - `lastDrillSpeed = 0f;`
  - `warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);`
  - `return;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Reuse existing source parity coverage for inactive warmup snippet.
- [x] Add RED Godot runtime structure test for inactive warmup helper and factory else wiring.
- [x] Prove RED failure before production code.
- [x] Add `source_drill_inactive_warmup_state()` in `PortGame.gd`.
- [x] Route factory drill inactive branch through source warmup decay after setting last speed to `0`.
- [x] Run targeted GREEN test.
- [x] Run full Python suite.
- [x] Verify Godot LSP via MCP.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `source_drill_inactive_warmup_state`.
- Targeted GREEN passed for the new test.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 115 tests in 1.529s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd`: `diagnostics: []`.
- MCP runtime proof with `_process` disabled:
  - `source_drill_inactive_warmup_state(0.9, 0.015, 60) = 1.11022302462516e-16`
  - `source_drill_inactive_warmup_state(0.5, 0.015, 10) = 0.35`
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 96
- Done: 96
- Not done: 0
- Blocked: 0
