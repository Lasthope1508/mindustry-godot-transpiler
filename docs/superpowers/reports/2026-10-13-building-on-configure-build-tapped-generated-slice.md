# N1953 BuildingComp `onConfigureBuildTapped` generated delegate slice

## Scope

- Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Method: `public boolean onConfigureBuildTapped(Building other)`
- Canonical owner: `PortGame.source_building_on_configure_build_tapped_state`
- Generated owner: `BuildingComp.java_method_onConfigureBuildTapped_166`
- Domain: existing `SourceBuildingConfigureState.gd`; no second canonical owner was introduced.

## Source-backed behavior

The generated callback delegates to the existing canonical configure owner. The canonical state preserves the upstream branch boundary: `block.clearOnDoubleTap`, `self() == other`, `deselect()`, `configure(null)`, the false/true returns, and the default `self() != other` result. The UI/network side effects remain deferred to the existing configure/runtime integration boundary.

## SSOT and implementation

- `SourceBuildingSourceTextState.gd` owns the exact Java method literal.
- `SourceBuildingConfigureState.gd` owns canonical state and generated comparison.
- `SourceBuildingConfigurePortBridge.gd` exposes the thin facade.
- `emitter.py` emits the generated callback delegate.
- `register_building_on_configure_build_tapped_generated_slice.py` updates the N1953 ledger, contracts, schemas, symbols, and registered mirrors.
- The existing N604 source ownership remains canonical; N1953 records only the generated bridge.

## Verification

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused slice/configure/catalog tests: `16 passed`.
- Full Python suite: `5271 tests`, `OK`, `1171.641s` (`n1953_full_unittest_20261013_rerun.log`).
- Failed-gate recheck after catalog stabilization: `10 passed`.
- Validator snapshot: `0 errors`, `113 modules`, `0 JSON errors`.
- Godot runtime proof: `BUILDING_CONFIGURE_STATE_MODULE_PROOF matches=true`, `source_matches` all true, `generated_matches` all true, all four clear-on-double-tap/same-building branches true, `registry_valid=true`, `one_headquarter_per_ssot=true`.
- Godot editor parse: exit `0` in `n1953_editor_parse_20261013.log`.
- The MCP editor process can launch the playable scene and connect on port `7777`; the bounded proof scene exits immediately after writing its machine-readable proof, so its direct headless output is retained as the proof artifact.
- `git diff --check`: only pre-existing worktree line-ending/blank-at-EOF notices; no N1953 content error.

## Checkpoint

N1953 is complete and the next migration slice may start from the remaining generated `BuildingComp` stubs after refreshing the five SSOT roots and registered mirrors. Full Mindustry parity remains incomplete.

