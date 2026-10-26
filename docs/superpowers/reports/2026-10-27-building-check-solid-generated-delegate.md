# BuildingComp `checkSolid()` generated delegate checkpoint

Date: 2026-10-27
Slice: N1960 follow-up to the existing N1034 generated `BuildingComp.checkSolid()` evidence
Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`

## Scope

The upstream method is the source-backed default:

```java
public boolean checkSolid(){
    return false;
}
```

The generated method now delegates directly to the existing canonical state:

```gdscript
return source_building_core_state.check_solid_state()
```

The canonical behavior remains in `SourceBuildingCoreState.gd`. The existing parity bridge still exposes the established dictionary contract by wrapping the generated scalar result before comparing it with the canonical envelope. This keeps the generated class thin and avoids reintroducing inline behavior or recursive bridge calls.

## SSOT

- Existing canonical owner retained: `PortGame.source_building_check_solid_state`.
- Existing schema retained: `source_building_check_solid_result`.
- Existing slice `N1034` metadata updated with the delegate test and the scalar-result/envelope rule.
- Extension mirrors and source audit report regenerated; no new canonical owner or duplicate symbol was introduced.

## Validation

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused delegate/emitter/playable/source-symbol tests: `4 passed` before the final parity assertion; final focused delegate file: `3 passed`.
- Full suite: `5303 passed`, `22504 subtests passed`, `1 pytest cache permission warning`, `1069.06s`.
- Cross-catalog validator: `0 errors`; JSON mirror: `0 errors`.
- Godot runtime proof: `BUILDING_CORE_STATE_MODULE_PROOF matches=true`, `registry_valid=true`, `one_headquarter_per_ssot=true`.
- `git diff --check`: clean for the slice files.

## Files

- `tools/mindustry_godot_transpiler/mindustry_port/emitter.py`
- `godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd`
- `godot-mindustry/src/game/SourceBuildingCoreState.gd`
- `tools/mindustry_godot_transpiler/tests/test_building_check_solid_generated_delegate.py`
- Existing emitter/playable tests and SSOT mirror metadata.
