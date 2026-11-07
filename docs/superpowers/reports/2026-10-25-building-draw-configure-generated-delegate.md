# N1959 — `BuildingComp.drawConfigure()` generated delegate

## Scope

The canonical `PortGame.source_building_draw_configure_state` implementation already owned the source-backed drawing state. This slice removes the inline generated rendering dictionary from `BuildingComp.java_method_drawConfigure_171` and delegates it to `SourceBuildingDrawState.draw_configure_state`.

## Evidence

- Upstream source: `core/src/mindustry/entities/comp/BuildingComp.java`.
- Generated callback now delegates directly to `source_building_draw_state.draw_configure_state(...)`.
- Existing canonical owner and contract are reused; no duplicate draw owner is introduced.
- SSOT adds the N1959 delegate symbol and generated bridge result schema.
- Emitter regeneration: `801 classes`, `0 failures`.
- Focused delegate/emitter tests: `3 passed`.
- Full suite: `5301 passed`, `22504 subtests passed`, one pytest cache permission warning.
- Catalog validator: `0 errors`, `0 JSON errors`; all cross-catalog gates remain zero.
- Godot runtime proof: `BUILDING_DRAW_STATE_MODULE_PROOF matches=true`, including `generated_draw_configure_bridge_matches=true`, `registry_valid=true`, and `one_headquarter_per_ssot=true`.
- Godot editor parse: exit `0`.

## Boundary

This slice changes generated ownership flow only. The draw formula, color, stroke, square geometry, and reset semantics remain owned by the existing canonical source state.
