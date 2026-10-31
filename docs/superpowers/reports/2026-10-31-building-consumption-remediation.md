# BuildingComp consumption remediation — N1989–N1990

Date: 2026-10-31. Scope: findings F1–F5 from the consumption audit, on the existing working tree. Full Mindustry gameplay parity is outside this acceptance.

## Checkpoint status

| Checkpoint | Evidence | Status |
| --- | --- | --- |
| UC-A: real RED and explicit representation | Python RED: 2 failed / 6 passed; independent runtime RED: dictionary conversion errors, state/application mismatches | Complete |
| UC-B: single domain implementation | Canonical full state + application in the existing efficiency module; generated adapter regenerated, no inline consumer loops/formulas | Complete |
| UC-C: independent runtime behavior | 21 Java-backed golden cases; final native MCP matches=true, actual runtime errors empty | Complete |
| UC-D: complete acceptance | 5341 tests / 22534 subtests pass; validator and editor parse pass | Accepted |

## Changes by module

`SourceBuildingEfficiencyState` remains the domain owner. No new runtime module or one-line helper files were added.

1. **Initial branch:** `potential_efficiency` is left unchanged by the multiplier, matching Java. The existing multiplier helper scales only efficiency and optional efficiency.
2. **Consumer rows:** dictionary `result` is the canonical evaluated value. Existing `efficiency` field is a compatibility alias and fallback. Canonical `result` wins if both appear. Optional numeric rows remain explicitly documented legacy input to the same canonical reader; production bridges now pass dictionaries. Non-optional and optional aggregation no longer diverge between stage and complete paths.
3. **Full state:** `update_consumption_state(...)` composes existing initial, disabled, setup, non-optional, optional, efficiency, multiplier and second-pass helpers. It preserves all four Java state fields and the ordered update plan. It does not invoke consumers or mutate the caller's state.
4. **Runtime application:** `apply_update_consumption_state(consumption_state, self_state)` assigns potential, efficiency, optional efficiency and power before executing the planned consumers in order. Supplied concrete consumers implement `update(self_state)`. Invalid consumer interfaces produce an error instead of being silently ignored.
5. **Generated adapter:** complete calls (10+ args) delegate directly to full state. Historical shorter calls retain stage inspection compatibility and delegate to the corresponding helpers. The positional slot at index 8 remains the historical compatibility slot; it does not select behavior by value.
6. **Generated `update()` integration:** a complete mutable consumption frame may be supplied at index 11. Its required fields are registered in `source_building_update_consumption_frame`. Generated code calculates the canonical result, applies it, dispatches actual consumer objects, and includes the result in the existing consumption call envelope. No-frame `update()` remains the historical source-call inspection API; it does not fabricate runtime resource availability.
7. **Proof:** the second-pass bridge no longer feeds actual generated efficiency into its expected result. The new `BuildingConsumptionCanonicalProof` compares generated results and concrete runtime dispatch with independent golden values, rather than treating a second call to the same helper as semantic evidence.

## Source and SSOT

Behavior follows `BuildingComp.java:1931–2003`: multiplier touches two efficiency fields; initial/disabled return early; non-power starvation gates power; potential is assigned before no-update zeroing; multiplier runs before the second-pass guard.

- N1989: complete pure-state composition.
- N1990: state application and concrete consumer dispatch through the registered complete frame.
- Existing stage contracts retain their canonical owners. New owners cover composition and state application, not duplicate formulas.
- Added two API contracts, two ledger entries, eleven symbols and five schema objects. Existing consumer input schemas reference the explicit row schema. Existing manifest and 113-module structure are retained.
- Mirrors are regenerated from root contracts/ledger with `source_ssot.build_extension_shard`; they are not independently authored.
- Registration script: `tools/mindustry_godot_transpiler/register_building_consumption_canonical.py`.

The caller still evaluates upstream predicates and consumer availability into the registered explicit input frame. This change proves calculation, assignment and ordered callback dispatch at that boundary. It does not claim that every block/resource manager in the playable game supplies this frame yet. Concrete resources and subclass-specific overrides remain migration integration work; no-frame marker calls are not counted as executable consumption parity.

## Regression coverage

The golden runtime matrix covers scale 0/0.5/1/2, no consumers, cheating, disabled, invalid production, shouldConsume=false, optional clamping, power starvation versus non-power starvation, the 1e-7 threshold and a value above it, empty result arrays, canonical result precedence and legacy numeric/efficiency-alias compatibility. It verifies the four output fields, update count, trace order/self identity, applied state and actual consumer call order. A dictionary stage-composition check covers the former `float(dictionary)` failure at nine arguments.

The Python regression runs that scene headlessly where Godot is installed and fails on nonzero exit, missing proof, `matches=false`, SCRIPT ERROR or ERROR output. Architecture tests reject inline loops/min/zeroing in the generated callback. Emitter/playable tests now require delegation rather than the removed inline formulas. Native MCP remains a separate acceptance step.

## Validation record

- Emit: 801 classes / 0 failures.
- Targeted: 44 passed / 13 subtests passed, followed by the domain regression after the canonical-precedence case: 10 passed / 6 subtests passed.
- Validator before final acceptance: 0 errors, 113 modules, 0 JSON errors.
- First native MCP capture: 20 cases, matches=true, registry valid, one headquarter per SSOT. The stderr channel contained existing compiler warnings in `SourceBlockGeometry.gd` and `SourceBuildingVisibilityState.gd`; these are warnings, not runtime errors. Raw output is preserved; an empty stderr array is not claimed.
- Final full suite: **5341 passed / 22534 subtests passed in 972.64s**.
- Final native MCP: **21/21 cases pass**, matches=true, registry valid, one_headquarter_per_ssot=true. Every state, trace, application and dispatch check is true. Actual ERROR/SCRIPT ERROR entries: **0**. The MCP stderr container still holds **25 compiler warnings** from the two existing modules named above; its raw `errors` array is not empty and is not described as empty. The test project was explicitly stopped.
- Godot 4.6.2 editor parse: **exit 0**.
- Final validator: **0 errors / 113 modules / 0 JSON errors**, all nine catalog counters zero.
- Registration replay: all seven root/mirror file hashes unchanged; idempotence PASS.
- Canonical ledger: **1445 done records**. The design summary now projects this authoritative count rather than retaining the old mixed historical 1451 figure. Ledger counts are not method coverage or full game parity.
- Slice diff checks pass; source/evidence paths are staged specifically. Unrelated pre-existing working-tree edits are retained.

Evidence is retained under `docs/superpowers/reports/evidence/2026-10-31-building-consumption-remediation/`. Historical audit logs remain unchanged.

## Handoff after acceptance

Keep pure state calculation and execution separate. Full-state callers use the registered result schema; callers that need real effects supply a complete frame and concrete consumers. Reuse these APIs for subsequent block integration rather than adding local consumption formulas or treating a marker as execution.

Any subsequent integration slice must derive its predicates, consumer efficiency results and consumer objects from exact upstream behavior, register new boundary data only where necessary, and prove real resource changes with an independent expected result. This report does not authorize inventing production defaults or duplicating domain arithmetic inside gameplay callers.
