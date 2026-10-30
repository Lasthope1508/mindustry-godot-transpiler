# BuildingComp `changeTeam(Team)` generated delegate checkpoint

Date: 2026-10-29
Slice: N1965 follow-up to existing N175/N534 delegate evidence
Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`

## Scope

The source overload is the narrow delegate:

```java
public void changeTeam(Team next){
    changeTeam(next, true);
}
```

The generated callback now parses `next_team` and delegates directly to the
existing `SourceBuildingLifecycleState.change_team_delegate_state(...)` owner.
The inline generated result dictionary was removed. The two-argument
`changeTeam(Team, boolean)` method, including force-team and power-graph
branches, remains unchanged and is intentionally deferred to a separate
checkpoint.

## Validation

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused generated delegate and emitter tests: `2 passed`.
- Focused playable bridge tests: `2 passed`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- `BUILDING_LIFECYCLE_STATE_MODULE_PROOF`: `matches=true`,
  `change_team_delegate_bridge_matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`.
- Full Python suite: `5315 passed`, `22504 subtests passed`, one non-blocking
  `.pytest_cache` permission warning, `1300.31s`.

## N1966 follow-up: initial guard delegate

The first part of `changeTeam(Team next, boolean updatePower)` now delegates
to `SourceBuildingLifecycleState.change_team_initial_state(...)`. Generated
code keeps only argument parsing, canonical envelope metadata, and orchestration
into the still-separate power proximity/link/final branches. The source-backed
guard, force-team resolution, equality return, and index-removal decision no
longer have duplicated formulas in the generated callback.

- Focused initial delegate/emitter tests: `2 passed`.
- Focused playable initial bridge test: `1 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- `BUILDING_LIFECYCLE_STATE_MODULE_PROOF`: `matches=true`,
  `change_team_initial_matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`.
- Full Python suite: `5316 passed`, `22504 subtests passed`; one non-blocking
  `.pytest_cache` permission warning, `1283.20s`.

The power proximity, power links, and final event/index branches remain
separate source-backed delegates for the next checkpoints.

## N1967 follow-up: power proximity delegate

The generated power-proximity dictionary now comes from
`SourceBuildingLifecycleState.change_team_power_proximity_state(...)`. Only
canonical envelope metadata and the existing `result["power_proximity"]`
orchestration assignment remain in generated code. Power links and final
event/index state are unchanged and remain the next independent delegates.

- Focused proximity delegate/emitter tests: `2 passed`.
- Focused playable proximity bridge tests: `2 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- `BUILDING_LIFECYCLE_STATE_MODULE_PROOF`: `matches=true`,
  `change_team_initial_matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`.
- Full Python suite: `5317 passed`, `22504 subtests passed`; one non-blocking
  `.pytest_cache` permission warning, `1393.82s`.

## N1968/N1969 follow-up: power-links and final delegates

The remaining `changeTeam(Team next, boolean updatePower)` result sections now
use the canonical helpers `change_team_power_links_state(...)` and
`change_team_final_state(...)`. Generated code retains only source-backed input
normalization, metadata, and assignment into the established result envelope.

- Focused power-links/final delegate and emitter tests: `4 passed`.
- Focused playable power-links/final bridge tests: `4 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- `BUILDING_LIFECYCLE_STATE_MODULE_PROOF`: `matches=true`,
  `change_team_generated_links_matches=true`,
  `change_team_generated_final_matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`.
- Full Python suite: `5319 passed`, `22504 subtests passed`; one non-blocking
  `.pytest_cache` permission warning, `1375.94s`.

The complete generated `changeTeam(Team, boolean)` orchestration now routes
all four state sections through canonical lifecycle helpers.

## N1970/N1971 follow-up: pickup delegates

`BuildingComp.canPickup()` and `pickedUp()` now delegate to the existing
canonical pickup lifecycle state. Generated callbacks only normalize their
source-backed inputs and no longer construct inline result dictionaries.

- Focused pickup delegate/emitter tests: `5 passed`.
- Focused playable pickup bridge tests: `4 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- `BUILDING_LIFECYCLE_STATE_MODULE_PROOF`: `matches=true`,
  `pickup_can_bridge_matches=true`, `pickup_picked_bridge_matches=true`,
  `registry_valid=true`, `one_headquarter_per_ssot=true`.
- Full Python suite: `5321 passed`, `22504 subtests passed`; one non-blocking
  `.pytest_cache` permission warning, `1045.87s`.

`afterPickedUp()` remains the next independent pickup lifecycle delegate.

## N1972 follow-up: afterPickedUp delegate

`BuildingComp.afterPickedUp()` now delegates to canonical
`after_picked_up_state(...)`. Generated code only normalizes the four source
inputs; status reset, new power graph, and link clearing remain in canonical
state.

- Focused afterPickedUp delegate/emitter tests: `2 passed`.
- Focused playable afterPickedUp bridge tests: `2 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- `BUILDING_LIFECYCLE_STATE_MODULE_PROOF`: `matches=true`,
  `pickup_after_picked_up_matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`.
- Full Python suite: `5322 passed`, `22504 subtests passed`; one non-blocking
  `.pytest_cache` permission warning, `1041.83s`.

## N1973-N1975 follow-up: proximity delegates

The generated `BuildingComp.removeFromProximity()`, `updateProximity()`, and
`onNearbyBuildAdded(Building)` callbacks now normalize only their source-backed
inputs and delegate to the existing canonical lifecycle proximity state. The
inline generated formulas and result dictionaries were removed; no SSOT owner,
alias, or schema was added.

- RED delegate gate: `3 failed` before emitter changes.
- Focused generated delegate tests: `3 passed`.
- Focused emitter tests: `3 passed`.
- Focused playable bridge tests: `9 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 runtime proof: `BUILDING_LIFECYCLE_STATE_MODULE_PROOF` reported
  `matches=true`, `remove_from_proximity_bridge_matches=true`,
  `update_proximity_bridge_matches=true`,
  `on_nearby_build_added_bridge_matches=true`, `registry_valid=true`, and
  `one_headquarter_per_ssot=true`.
- Full Python suite: `5325 passed`, `22504 subtests passed` in `1170.01s`; one
  non-blocking `.pytest_cache` permission warning.

## N1976-N1977 follow-up: efficiency delegates

The generated `BuildingComp.consume()` and `canConsume()` callbacks now keep
only source-backed argument normalization and delegate to
`SourceBuildingEfficiencyState.consume_state(...)` and
`can_consume_state(...)`. The generated class now preloads the canonical
efficiency owner; no new SSOT owner, alias, or schema was introduced.

- Focused generated delegate tests: `2 passed`.
- Focused emitter tests: `4 passed`.
- Focused playable bridge tests: `2 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 `BuildingEfficiencyStateModuleProof`: `matches=true`,
  `update_consumption_call_bridge_matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`; generated `BuildingComp.gd` parsed without
  errors after adding the efficiency preload.
- Full Python suite: `5327 passed`, `22504 subtests passed` in `1343.87s`; one
  non-blocking `.pytest_cache` permission warning.

## N1978-N1979 follow-up: time delegates

The generated `BuildingComp.delta()` and `edelta()` callbacks now delegate to
the existing `SourceBuildingTimeState.delta(...)` and `edelta(...)` helpers.
Generated code keeps only typed input normalization; the arithmetic and
cross-method dependency no longer live in the generated envelope.

- Focused generated delegate tests: `2 passed`.
- Focused emitter tests: `2 passed`.
- Focused playable bridge tests: `2 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 `BuildingTimeStateModuleProof`: `matches=true`,
  `registry_valid=true`, `one_headquarter_per_ssot=true`; generated class parsed
  without errors.
- Full Python suite: `5329 passed`, `22504 subtests passed` in `1362.71s`; one
  non-blocking `.pytest_cache` permission warning.

## N1980-N1981 follow-up: efficiency multiplier delegates

The generated `BuildingComp.updateEfficiencyMultiplier()` and
`efficiencyScale()` callbacks now delegate to the existing canonical
`SourceBuildingEfficiencyState` helpers. Generated code keeps only typed input
normalization for the multiplier and no inputs for the default scale.

- Focused generated delegate tests: `2 passed`.
- Focused emitter tests: `2 passed`.
- Focused playable bridge tests: `2 passed`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 efficiency proof: `matches=true`, `registry_valid=true`,
  `one_headquarter_per_ssot=true`; no generated-script parse errors.
- Full Python suite: `5331 passed`, `22504 subtests passed` in `1196.92s`; one
  non-blocking `.pytest_cache` permission warning.

## N1982-N1983 BuildingComp updateConsumption initial/disabled delegates (2026-10-30)

The first two `BuildingComp.updateConsumption()` branches now delegate to the existing canonical `SourceBuildingEfficiencyState` helpers. Generated code still normalizes all callback inputs and keeps the setup, consumer passes, efficiency, and second-pass orchestration inline for the next slices; the `initial/cheating` and disabled result construction is no longer duplicated in generated code.

- Emitter regeneration: `801 classes`, `0 failures`.
- RED delegate gate added for both branches; focused generated delegate/emitter tests: `9 passed`.
- Focused playable bridge/proof tests: `26 passed`, `7 subtests passed`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 `BuildingEfficiencyStateModuleProof`: `matches=true`, with `update_consumption_initial_branch_matches=true`, `update_consumption_disabled_branch_matches=true`, `registry_valid=true`, and `one_headquarter_per_ssot=true`.
- Full Python suite: `5332 passed`, `22504 subtests passed` in `1343.41s`; one non-blocking `.pytest_cache` permission warning.

## N1984 BuildingComp updateConsumption setup delegate (2026-10-30)

The setup branch of `BuildingComp.updateConsumption()` now delegates to
`SourceBuildingEfficiencyState.update_consumption_setup_state(...)` when the
callback is invoked with only the primary inputs. Consumer result passes and
efficiency/second-pass orchestration remain staged for subsequent slices.

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused generated delegate/emitter tests: `10 passed`.
- Focused playable bridge/proof tests: `26 passed`, `7 subtests passed`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 `BuildingEfficiencyStateModuleProof`: `matches=true`, with
  initial, disabled, and setup branch matches true, registry valid, and one
  headquarter per SSOT.
- Full Python suite: `5333 passed`, `22504 subtests passed` in `1222.95s`; one
  non-blocking `.pytest_cache` permission warning.

## N1985 BuildingComp updateConsumption non-optional pass delegate (2026-10-30)

The non-optional consumer pass of `BuildingComp.updateConsumption()` now delegates
its source-backed result aggregation to
`SourceBuildingEfficiencyState.update_consumption_non_optional_pass_state(...)`.
The generated callback retains the loop for full orchestration paths while the
stage return boundary is canonicalized; optional, efficiency, and second-pass
stages remain for subsequent slices.

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused generated delegate/emitter tests: `11 passed`.
- Focused playable bridge tests: `25 passed`, `7 subtests passed`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 efficiency proof: `matches=true`, including initial, disabled,
  setup, and non-optional branch matches, registry valid, one headquarter per SSOT.
- Full Python suite: `5334 passed`, `22504 subtests passed` in `1362.52s`; one
  non-blocking `.pytest_cache` permission warning.

## N1986 BuildingComp updateConsumption optional pass delegate (2026-10-30)

The optional consumer pass now delegates to
`SourceBuildingEfficiencyState.update_consumption_optional_pass_state(...)`.
The delegate boundary is evaluated before the legacy float loop, so dictionary
result rows follow the canonical contract; the loop remains for later full
orchestration paths.

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused generated delegate/emitter tests: `12 passed`.
- Focused playable bridge tests: `25 passed`, `7 subtests passed`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 efficiency proof: `matches=true`, including initial, disabled,
  setup, non-optional, and optional branch matches.
- Full Python suite: `5335 passed`, `22504 subtests passed` in `1341.42s`; one
  non-blocking `.pytest_cache` permission warning.

## N1987 BuildingComp updateConsumption efficiency pass delegate (2026-10-30)

The efficiency stage now delegates to
`SourceBuildingEfficiencyState.update_consumption_efficiency_state(...)` after
canonical non-optional and optional aggregation. The later multiplier and
second-pass paths remain staged for subsequent slices.

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused generated delegate/emitter tests: `13 passed`.
- Focused playable bridge tests: `25 passed`, `7 subtests passed`.
- Cross-catalog validator: `0 errors`; JSON mirror `113 modules / 0 errors`.
- Godot 4.6.2 efficiency proof: `matches=true`, including initial, disabled,
  setup, non-optional, optional, and efficiency branch matches.
- Full Python suite: `5336 passed`, `22504 subtests passed` in `1276.42s`; one
  non-blocking `.pytest_cache` permission warning.
