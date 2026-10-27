# BuildingComp core generated delegates checkpoint

Date: 2026-10-27
Slice: N1962 follow-up for existing N1036-N1038 evidence
Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`

## Scope

The generated callbacks for `absorbLasers()`, `isInsulated()`, and `collide(Bullet other)` now only extract their source parameters and delegate to the existing canonical `SourceBuildingCoreState` methods. The canonical methods remain source-backed by the upstream returns (`block.absorbLasers`, `block.insulated`, and `true`). Their parity bridges normalize scalar generated returns into the established result dictionaries before comparison.

## SSOT

- Canonical owners retained: `PortGame.source_building_absorb_lasers_state`, `PortGame.source_building_is_insulated_state`, and `PortGame.source_building_collide_state`.
- Existing schemas and symbols retained; N1036-N1038 metadata now records the delegate tests and envelope rule.
- Extension mirrors and source audit report regenerated without new owners, aliases, or duplicate symbols.

## Validation

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused delegate tests: `3 passed`; emitter cluster: `3 passed`; playable cluster: `9 passed`.
- Godot runtime proof: `BUILDING_CORE_STATE_MODULE_PROOF matches=true`, `registry_valid=true`, `one_headquarter_per_ssot=true`.
- Cross-catalog validator: `0 errors`; JSON mirror: `113 modules / 0 errors`.
- Full suite: `5309 passed`, `22504 subtests passed`, `1 pytest cache permission warning`, `1343.97s`.
