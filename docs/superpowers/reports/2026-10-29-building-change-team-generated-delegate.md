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
