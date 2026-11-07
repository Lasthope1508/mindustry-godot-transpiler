# N1958 — `BuildingComp` configure callbacks generated delegates

## Scope

The canonical source states for `onConfigureTapped`, `onConfigureClosed`, `shouldShowConfigure`, and `shouldHideConfigure` already existed. This slice removes the remaining inline dictionaries from generated `BuildingComp.gd` and routes each generated callback to its existing canonical `SourceBuildingConfigureState` function.

## Evidence

- Upstream source: `core/src/mindustry/entities/comp/BuildingComp.java`.
- Generated methods now call `on_configure_tapped_state`, `on_configure_closed_state`, `should_show_configure_state`, and `should_hide_configure_state` directly.
- Parity bridge methods remain the only generated-runtime comparison path and avoid recursion.
- SSOT registration adds N1958 delegate symbols and four generated bridge result schemas; no duplicate canonical owner or API contract was introduced.
- Emitter regeneration: `801 classes`, `0 failures`.
- Focused slice tests: `15 passed`.
- Emitter suite: `599 passed`, `20 subtests passed`.
- Full suite: `5299 passed`, `22501 subtests passed`, one pytest cache permission warning.
- Catalog validator: `0 errors`, `0 JSON errors`; all cross-catalog gate categories are zero.
- Godot runtime proof: `BUILDING_CONFIGURE_STATE_MODULE_PROOF matches=true`, `registry_valid=true`, `one_headquarter_per_ssot=true`.

## Boundary

This slice changes generated ownership flow only. It preserves the existing canonical callback semantics and keeps block-specific configure overrides deferred to their own source slices.
