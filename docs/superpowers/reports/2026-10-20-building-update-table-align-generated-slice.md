# N1956 — `BuildingComp.updateTableAlign(Table)`

## Scope

Migrates the upstream table alignment hook while keeping engine dependencies explicit. The canonical state records the exact `Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1)` lookup and `table.setPosition(pos.x, pos.y, Align.top)` mutation. It does not access Godot singletons or invent UI behavior.

## Evidence

- Canonical owner: `PortGame.source_building_update_table_align_state`.
- Generated method: `BuildingComp.java_method_updateTableAlign_164` delegates to `SourceBuildingConfigureState`.
- Runtime proof: `BUILDING_CONFIGURE_STATE_MODULE_PROOF matches=true` with registry valid and one SSOT headquarter.
- Validator: `0 errors`, `113 modules`, `0 JSON errors`, `0 unknown return keys`.
- Emitter: `801 classes`, `0 failures`.
- Focused emitter/slice gate: `602 passed`, one pytest cache permission warning.
- Godot editor parse: exit `0`.
- Full suite: `5293 passed`, `22490 subtests passed`, one pytest cache permission warning.

## Boundary

The resolved mouse-screen position is an explicit runtime input. Actual input/camera integration remains outside this slice and must be migrated through its own source-backed owner.
