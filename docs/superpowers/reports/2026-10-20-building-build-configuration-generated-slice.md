# N1955 — `BuildingComp.buildConfiguration(Table)`

## Scope

This slice migrates the upstream `BuildingComp.buildConfiguration(Table)` base hook. The upstream body is intentionally empty and is documented as a UI hook invoked when a configurable block is tapped. The migration preserves the `Table` input, method identity, documentation evidence, and no-op behavior without inventing UI behavior or subclass overrides.

## SSOT and implementation

- Canonical owner: `PortGame.source_building_build_configuration_state`.
- Canonical implementation: `godot-mindustry/src/game/SourceBuildingConfigureState.gd`.
- Generated bridge: `BuildingComp.java_method_buildConfiguration_163` delegates to `generated_build_configuration_bridge_state`.
- Source literals and method identity: `SourceBuildingSourceTextState.gd`.
- Owner registry: `SourceRuntimeOwnerBuildingRegistry.gd`.
- Registration: `register_building_build_configuration_generated_slice.py`.
- Proof: `BuildingConfigureStateModuleProof.gd` compares facade, canonical, and generated results.

## Checkpoint evidence

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused slice and SSOT tests: `1107 passed`; one pytest cache permission warning only.
- Cross-catalog validator: `0 errors`, `113 modules`, `0 JSON errors`, `0 unknown return keys`.
- Godot runtime proof: `BUILDING_CONFIGURE_STATE_MODULE_PROOF matches=true`, `registry_valid=true`, `one_headquarter_per_ssot=true`.
- Godot editor parse: exit `0`.
- Full suite after the final contract/result schema registration: `5290 passed`, `22480 subtests passed`, one pytest cache permission warning.

## Boundary

Concrete subclass implementations and actual UI construction remain deferred to later source-backed slices. This checkpoint only removes the generated `return null` stub for the empty base hook.
