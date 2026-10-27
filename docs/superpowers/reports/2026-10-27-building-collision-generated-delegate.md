# BuildingComp `collision(Bullet)` generated delegate checkpoint

Date: 2026-10-27
Slice: N1963 follow-up for existing N1039 collision evidence
Upstream: `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`

## Scope

The generated `BuildingComp.collision(Bullet other)` callback now extracts its six existing source-backed inputs and delegates to `SourceBuildingDamageState.collision_damage_state(...)`. Armor calculation, pierce gating, pre-damage death state, raw damage, final damage, and removal result remain in the canonical state. The canonical result now carries the existing generated method key `method` and `raw_damage` fields, so the established result envelope is preserved without inline generated formulas.

## SSOT

- Existing owner retained: `PortGame.source_building_collision_damage_state`.
- Existing input/result schemas and collision symbols retained; N1039 metadata now records the delegate test and canonical result ownership.
- Extension mirrors and source audit report regenerated without new owner, alias, or duplicate symbol.

## Validation

- Emitter regeneration: `801 classes`, `0 failures`.
- Focused delegate test: `2 passed`; emitter collision test: `1 passed`; playable collision bridge tests: `2 passed`.
- Godot runtime proof: `BUILDING_DAMAGE_MODULE_PROOF matches=true`, `registry_valid=true`, `one_headquarter_per_ssot=true`; generated collision bridge included.
- Cross-catalog validator: `0 errors`; JSON mirror: `113 modules / 0 errors`.
- Full suite: `5311 passed`, `22504 subtests passed`, `1 pytest cache permission warning`, `1318.30s`.
