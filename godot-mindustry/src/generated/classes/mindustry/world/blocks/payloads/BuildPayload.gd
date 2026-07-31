# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/BuildPayload.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "BuildPayload"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Payload"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "build", "type": "Building"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BuildPayload", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}]}, {"modifiers": ["public"], "name": "BuildPayload", "parameters": [{"name": "build", "type": "Building", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "block", "parameters": [], "return_type": "Block"}, {"modifiers": ["public"], "name": "place", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "place", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "contentEquals", "parameters": [{"name": "other", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "content", "parameters": [], "return_type": "UnlockableContent"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unitHolder", "type": "Unit", "varargs": false}, {"name": "buildingHolder", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "destroyed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "buildTime", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "x", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "y", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_build_payload_lifecycle_state := preload("res://src/game/SourceBuildPayloadLifecycleState.gd")
const source_build_payload_draw_state := preload("res://src/game/SourceBuildPayloadDrawState.gd")
const SOURCE_TILESIZE := source_world_defaults.TILESIZE

func java_method_block_0(_args: Array = []) -> Variant:
	var build_block: Variant = _args[0] if _args.size() > 0 else null
	return source_build_payload_state.block_state(build_block)

func java_method_place_1(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var build_block: Variant = _args[1] if _args.size() > 1 else null
	var build_team: Variant = _args[2] if _args.size() > 2 else null
	return source_build_payload_lifecycle_state.place_default_state(tile, build_block, build_team)

func java_method_place_2(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var build_block: Variant = _args[1] if _args.size() > 1 else null
	var build_team: Variant = _args[2] if _args.size() > 2 else null
	var rotation_value: int = int(_args[3] if _args.size() > 3 else 0)
	return source_build_payload_lifecycle_state.place_state(tile, build_block, build_team, rotation_value)

func java_method_contentEquals_3(_args: Array = []) -> Variant:
	var other_is_build_payload: bool = bool(_args[0] if _args.size() > 0 else false)
	var other_block: Variant = _args[1] if _args.size() > 1 else null
	var build_block: Variant = _args[2] if _args.size() > 2 else null
	return source_build_payload_state.content_equals_state(other_is_build_payload, other_block, build_block)

func java_method_content_4(_args: Array = []) -> Variant:
	var build_block: Variant = _args[0] if _args.size() > 0 else null
	return source_build_payload_state.content_state(build_block)

func java_method_update_5(_args: Array = []) -> Variant:
	var unit_holder_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var build_block_update_in_units: bool = bool(_args[1] if _args.size() > 1 else false)
	var unit_payload_update: bool = bool(_args[2] if _args.size() > 2 else false)
	var build_block_always_update_in_units: bool = bool(_args[3] if _args.size() > 3 else false)
	var unit_holder: Variant = _args[4] if _args.size() > 4 else null
	var building_holder: Variant = _args[5] if _args.size() > 5 else null
	return source_build_payload_lifecycle_state.update_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)

func java_method_destroyed_6(_args: Array = []) -> Variant:
	return source_build_payload_lifecycle_state.destroyed_state()

func java_method_requirements_7(_args: Array = []) -> Variant:
	var requirements: Variant = _args[0] if _args.size() > 0 else []
	return source_build_payload_state.requirements_state(requirements)

func java_method_buildTime_8(_args: Array = []) -> Variant:
	var build_time: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_build_payload_state.build_time_state(build_time)

func java_method_x_9(_args: Array = []) -> Variant:
	var build_x: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_build_payload_state.x_state(build_x)

func java_method_y_10(_args: Array = []) -> Variant:
	var build_y: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_build_payload_state.y_state(build_y)

func java_method_size_11(_args: Array = []) -> Variant:
	var build_block_size: float = float(_args[0] if _args.size() > 0 else 0.0)
	var source_tilesize: float = float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
	return source_build_payload_state.size_state(build_block_size, source_tilesize)

func java_method_remove_12(_args: Array = []) -> Variant:
	return source_build_payload_lifecycle_state.remove_state()

func java_method_write_13(_args: Array = []) -> Variant:
	var payload_block: int = int(_args[0] if _args.size() > 0 else 0)
	var build_block_id: int = int(_args[1] if _args.size() > 1 else 0)
	var build_version: int = int(_args[2] if _args.size() > 2 else 0)
	return source_build_payload_state.write_state(payload_block, build_block_id, build_version)

func java_method_set_14(_args: Array = []) -> Variant:
	var x: float = float(_args[0] if _args.size() > 0 else 0.0)
	var y: float = float(_args[1] if _args.size() > 1 else 0.0)
	var rotation: float = float(_args[2] if _args.size() > 2 else 0.0)
	return source_build_payload_state.set_state(x, y, rotation)

func java_method_drawShadow_15(_args: Array = []) -> Variant:
	var build_x: float = float(_args[0] if _args.size() > 0 else 0.0)
	var build_y: float = float(_args[1] if _args.size() > 1 else 0.0)
	var build_block_size: float = float(_args[2] if _args.size() > 2 else 0.0)
	var source_tilesize: float = float(_args[3] if _args.size() > 3 else SOURCE_TILESIZE)
	var alpha: float = float(_args[4] if _args.size() > 4 else 0.0)
	return source_build_payload_draw_state.draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)

func java_method_draw_16(_args: Array = []) -> Variant:
	var prev_z: float = float(_args[0] if _args.size() > 0 else 0.0)
	var layer_flying_unit_low: float = float(_args[1] if _args.size() > 1 else 0.0)
	var transform_z: float = float(_args[2] if _args.size() > 2 else prev_z)
	return source_build_payload_draw_state.draw_state(prev_z, layer_flying_unit_low, transform_z)

func java_method_icon_17(_args: Array = []) -> Variant:
	var full_icon: Variant = _args[0] if _args.size() > 0 else null
	return source_build_payload_draw_state.icon_state(full_icon)

func java_constructor_BuildPayload_0(_args: Array = []) -> Variant:
	var block: Variant = _args[0] if _args.size() > 0 else null
	var team: Variant = _args[1] if _args.size() > 1 else null
	return source_build_payload_state.constructor_block_team_state(block, team)

func java_constructor_BuildPayload_1(_args: Array = []) -> Variant:
	var build: Variant = _args[0] if _args.size() > 0 else null
	return source_build_payload_state.constructor_build_state(build)
