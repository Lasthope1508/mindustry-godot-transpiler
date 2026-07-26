class_name SourceBuildPayloadLifecycleState
extends RefCounted

const SourceBuildPayloadState := preload("res://src/game/SourceBuildPayloadState.gd")

const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_METHOD := "public void place(Tile tile){"
const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_DELEGATE_EXPR := "place(tile, 0);"
const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_ROTATION := 0
const SOURCE_BUILD_PAYLOAD_PLACE_METHOD := "public void place(Tile tile, int rotation){"
const SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR := "tile.setBlock(build.block, build.team, rotation, () -> build);"
const SOURCE_BUILD_PAYLOAD_PLACE_DROPPED_EXPR := "build.dropped();"
const SOURCE_BUILD_PAYLOAD_UPDATE_METHOD := "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){"
const SOURCE_BUILD_PAYLOAD_UPDATE_GUARD_EXPR := "if(unitHolder != null && (!build.block.updateInUnits || (!state.rules.unitPayloadUpdate && !build.block.alwaysUpdateInUnits))) return;"
const SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR := "build.updatePayload(unitHolder, buildingHolder);"
const SOURCE_BUILD_PAYLOAD_DESTROYED_METHOD := "public void destroyed(){"
const SOURCE_BUILD_PAYLOAD_DESTROYED_DEAD_ASSIGN_EXPR := "build.dead = true;"
const SOURCE_BUILD_PAYLOAD_DESTROYED_ON_DESTROYED_EXPR := "build.onDestroyed();"
const SOURCE_BUILD_PAYLOAD_REMOVE_METHOD := "public void remove(){"
const SOURCE_BUILD_PAYLOAD_REMOVE_EXPR := "build.remove();"

static func place_default_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	var rotation_value: int = SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_ROTATION
	return {"source_owner": "PortGame.source_build_payload_place_default_state", "source": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "method": SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_METHOD, "delegate_expr": SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_DELEGATE_EXPR, "tile": tile, "build_block": build_block, "build_team": build_team, "delegated_rotation": rotation_value}

static func place_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	var set_block_call: Dictionary = {"call": SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR, "tile": tile, "block": build_block, "team": build_team, "rotation": rotation_value, "build_supplier": "() -> build"}
	return {"source_owner": "PortGame.source_build_payload_place_state", "source": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "method": SOURCE_BUILD_PAYLOAD_PLACE_METHOD, "set_block_expr": SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR, "dropped_expr": SOURCE_BUILD_PAYLOAD_PLACE_DROPPED_EXPR, "tile": tile, "build_block": build_block, "build_team": build_team, "rotation": rotation_value, "set_block_call": set_block_call, "dropped_called": true}

static func update_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var returned: bool = unit_holder_present and ((not build_block_update_in_units) or ((not unit_payload_update) and (not build_block_always_update_in_units)))
	var tile_after: Variant = null
	var update_payload_called: bool = false
	var update_payload_call: Variant = null
	if not returned:
		tile_after = SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR
		update_payload_called = true
		update_payload_call = {"call": SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {"source_owner": "PortGame.source_build_payload_update_state", "source": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_UPDATE_METHOD, "guard_expr": SOURCE_BUILD_PAYLOAD_UPDATE_GUARD_EXPR, "tile_assign_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR, "update_payload_expr": SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unit_holder_present": unit_holder_present, "build_block_update_in_units": build_block_update_in_units, "unit_payload_update": unit_payload_update, "build_block_always_update_in_units": build_block_always_update_in_units, "unitHolder": unit_holder, "buildingHolder": building_holder, "returned": returned, "tile_after": tile_after, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}

static func destroyed_state() -> Dictionary:
	var dead_after: bool = true
	var on_destroyed_called: bool = true
	return {"source_owner": "PortGame.source_build_payload_destroyed_state", "source": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_DESTROYED_METHOD, "dead_assign_expr": SOURCE_BUILD_PAYLOAD_DESTROYED_DEAD_ASSIGN_EXPR, "on_destroyed_expr": SOURCE_BUILD_PAYLOAD_DESTROYED_ON_DESTROYED_EXPR, "dead_after": dead_after, "on_destroyed_called": on_destroyed_called}

static func remove_state() -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_remove_state", "source": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SourceBuildPayloadState.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_REMOVE_METHOD, "remove_expr": SOURCE_BUILD_PAYLOAD_REMOVE_EXPR, "remove_called": true}
