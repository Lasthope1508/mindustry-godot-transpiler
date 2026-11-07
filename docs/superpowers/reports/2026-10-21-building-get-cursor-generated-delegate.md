# N1957 — `BuildingComp.getCursor()` generated delegate hardening

## Scope

The canonical cursor owner already existed as `PortGame.source_building_cursor_state` (N554). This checkpoint removes the remaining inline cursor decision from generated `BuildingComp.java_method_getCursor_165` and routes the generated method through `SourceBuildingMetaState.cursor_state`, without creating a second owner or contract.

## Evidence

- Existing canonical owner reused: `PortGame.source_building_cursor_state`.
- Generated method now delegates to `source_building_meta_state.cursor_state(...)`.
- Runtime proof: `BUILDING_META_STATE_MODULE_PROOF` reports `cursor_bridge_matches=true`, `matches=true`, valid registry and one SSOT headquarter.
- Validator: `0 errors`, `113 modules`, `0 JSON errors`, `0 unknown return keys`.
- Emitter regeneration: `801 classes`, `0 failures`.
- Focused emitter/playable gate: `2931 passed`, one pytest cache permission warning.
- Full suite: `5295 passed`, `22492 subtests passed`, one pytest cache permission warning.
- Godot editor parse: exit `0` from the preceding editor verification; runtime proof also loaded the generated class successfully.

## Boundary

The source-backed hand/arrow rule remains in the existing canonical cursor module. This slice changes generated ownership flow only; it does not alter cursor semantics or player/team input resolution.
