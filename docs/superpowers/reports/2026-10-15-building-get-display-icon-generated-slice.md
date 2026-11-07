# N1954 BuildingComp `getDisplayIcon` generated delegate slice

## Scope

- Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Method: `public TextureRegion getDisplayIcon()`
- Canonical owner: `PortGame.source_building_display_icon_state`
- Generated owner: `BuildingComp.java_method_getDisplayIcon_158`
- Domain: existing `SourceBuildingDisplayState.gd`; the existing N563 display icon state remains the single canonical owner.

## Source-backed behavior

The upstream method returns exactly `block.uiIcon`. N1954 only bridges the generated callback to the existing canonical `display_icon_state(block_ui_icon)` result. It does not create a second display-icon contract or duplicate the N563 source ownership.

## SSOT and implementation

- `SourceBuildingSourceTextState.gd` owns the generated method identity.
- `SourceBuildingDisplayState.gd` owns the generated comparison/result envelope.
- `SourceBuildingDisplayPortBridge.gd` exposes the thin generated bridge.
- `SourceRuntimeOwnerBuildingRegistry.gd` records the canonical display-icon owner.
- `emitter.py` adds the BuildingComp preload and generated delegate.
- `register_building_get_display_icon_generated_slice.py` updates N1954, generated result schema, and registered mirrors.

## Verification

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused N1954/display/catalog tests: `12 passed`.
- Godot runtime proof: `BUILDING_DISPLAY_STATE_MODULE_PROOF matches=true`; display icon source/module and generated bridge comparisons are true; `registry_valid=true`; `one_headquarter_per_ssot=true`.
- Validator snapshot: `0 errors`, `113 modules`, `0 JSON errors`.
- Godot editor parse: exit `0`.
- Full Python suite: `5274 tests`, `OK`, `1177.428s` (`n1954_full_unittest_20261015.log`).

## Checkpoint

N1954 is complete: the independent full-suite rerun remains green. The next migration slice may start from the remaining generated BuildingComp stubs after refreshing all five SSOT roots and registered mirrors. Full Mindustry parity remains incomplete.
