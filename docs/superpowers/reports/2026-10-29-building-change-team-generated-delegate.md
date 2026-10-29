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
