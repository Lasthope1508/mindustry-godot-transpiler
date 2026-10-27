# BuildingComp `handleDamage(float)` generated delegate checkpoint

Date: 2026-10-27
Slice: N1961 follow-up to the existing N1035 generated `BuildingComp.handleDamage(float)` evidence
Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`

## Scope

The upstream method is the source-backed passthrough:

```java
public float handleDamage(float amount){
    return amount;
}
```

The generated callback now extracts the source parameter and delegates to `source_building_damage_state.handle_damage_state(amount)`. Canonical behavior remains in `SourceBuildingDamageState.gd`. Its parity bridge normalizes the scalar generated return into the existing dictionary result envelope before comparison, preserving the established API shape without leaving behavior in generated code.

## SSOT

- Existing canonical owner retained: `PortGame.source_building_handle_damage_state`.
- Existing schema and symbols retained; N1035 metadata now records the delegate test and scalar-envelope rule.
- Extension mirrors and source audit report regenerated; no duplicate owner or alias was added.

## Validation

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused delegate/emitter/playable tests: `4 passed`.
- Godot runtime proof: `BUILDING_DAMAGE_MODULE_PROOF matches=true`, `registry_valid=true`, `one_headquarter_per_ssot=true`; generated bridge result is included in the proof.
- Cross-catalog validator after metadata regeneration: `0 errors`; JSON mirror: `0 errors`.
- Full suite: `5306 passed`, `22504 subtests passed`, `1 pytest cache permission warning`, `1295.33s`.
- `git diff --check`: clean for the slice files.
