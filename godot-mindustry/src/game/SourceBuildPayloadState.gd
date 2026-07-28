class_name SourceBuildPayloadState
extends RefCounted

const SourceWorldDefaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_BUILD_PAYLOAD_SOURCE := "core/src/mindustry/world/blocks/payloads/BuildPayload.java"
const SOURCE_BUILD_PAYLOAD_CLASS_EXPR := "public class BuildPayload implements Payload{"
const SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR := "public Building build;"
const SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR := "import static mindustry.Vars.*;"
const SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR := "emptyTile"
const SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR := "build.tile = emptyTile;"
const SOURCE_BUILD_PAYLOAD_BLOCK_METHOD := "public Block block(){"
const SOURCE_BUILD_PAYLOAD_BUILD_BLOCK_RETURN_EXPR := "return build.block;"
const SOURCE_BUILD_PAYLOAD_CONTENT_EQUALS_METHOD := "public boolean contentEquals(Payload other){"
const SOURCE_BUILD_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR := "return other instanceof BuildPayload bp && bp.block() == build.block;"
const SOURCE_BUILD_PAYLOAD_CONTENT_METHOD := "public UnlockableContent content(){"
const SOURCE_BUILD_PAYLOAD_BUILD_TIME_METHOD := "public float buildTime(){"
const SOURCE_BUILD_PAYLOAD_BUILD_TIME_RETURN_EXPR := "return build.block.buildTime;"
const SOURCE_BUILD_PAYLOAD_REQUIREMENTS_METHOD := "public ItemStack[] requirements(){"
const SOURCE_BUILD_PAYLOAD_REQUIREMENTS_RETURN_EXPR := "return build.block.requirements;"
const SOURCE_BUILD_PAYLOAD_X_METHOD := "public float x(){"
const SOURCE_BUILD_PAYLOAD_X_RETURN_EXPR := "return build.x;"
const SOURCE_BUILD_PAYLOAD_Y_METHOD := "public float y(){"
const SOURCE_BUILD_PAYLOAD_Y_RETURN_EXPR := "return build.y;"
const SOURCE_BUILD_PAYLOAD_SIZE_METHOD := "public float size(){"
const SOURCE_BUILD_PAYLOAD_SIZE_RETURN_EXPR := "return build.block.size * tilesize;"
const SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_CONSTRUCTOR := "public BuildPayload(Block block, Team team){"
const SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_BUILD_ASSIGN_EXPR := "this.build = block.newBuilding().create(block, team);"
const SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_TILE_ASSIGN_EXPR := "this.build.tile = emptyTile;"
const SOURCE_BUILD_PAYLOAD_BUILD_CONSTRUCTOR := "public BuildPayload(Building build){"
const SOURCE_BUILD_PAYLOAD_BUILD_ASSIGN_EXPR := "this.build = build;"
const SOURCE_BUILD_PAYLOAD_WRITE_METHOD := "public void write(Writes write){"
const SOURCE_BUILD_PAYLOAD_WRITE_PAYLOAD_BLOCK_EXPR := "write.b(payloadBlock);"
const SOURCE_BUILD_PAYLOAD_WRITE_BLOCK_ID_EXPR := "write.s(build.block.id);"
const SOURCE_BUILD_PAYLOAD_WRITE_VERSION_EXPR := "write.b(build.version());"
const SOURCE_BUILD_PAYLOAD_WRITE_ALL_EXPR := "build.writeAll(write);"
const SOURCE_BUILD_PAYLOAD_SET_METHOD := "public void set(float x, float y, float rotation){"
const SOURCE_BUILD_PAYLOAD_SET_EXPR := "build.set(x, y);"

static func generated_state_matches_generated_subset(result: Variant, canonical: Variant) -> bool:
	if result is Dictionary and canonical is Dictionary:
		for key in canonical.keys():
			if not result.has(key):
				return false
			if not generated_state_matches_generated_subset(result.get(key), canonical.get(key)):
				return false
		return true
	if result is Array and canonical is Array:
		if result.size() != canonical.size():
			return false
		for index in range(canonical.size()):
			if not generated_state_matches_generated_subset(result[index], canonical[index]):
				return false
		return true
	return result == canonical

static func block_state(build_block: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_block_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "method": SOURCE_BUILD_PAYLOAD_BLOCK_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_BUILD_BLOCK_RETURN_EXPR, "build_block": build_block}

static func constructor_block_team_state(block: Variant, team: Variant) -> Dictionary:
	var create_call: Dictionary = {"call": SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_BUILD_ASSIGN_EXPR.trim_suffix(";").trim_prefix("this.build = "), "block": block, "team": team}
	return {"source_owner": "PortGame.source_build_payload_constructor_block_team_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "constructor": SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_CONSTRUCTOR, "build_assign_expr": SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_BUILD_ASSIGN_EXPR, "tile_assign_expr": SOURCE_BUILD_PAYLOAD_BLOCK_TEAM_TILE_ASSIGN_EXPR, "block": block, "team": team, "create_call": create_call, "tile_after": SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR}

static func constructor_build_state(build: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_constructor_build_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "constructor": SOURCE_BUILD_PAYLOAD_BUILD_CONSTRUCTOR, "build_assign_expr": SOURCE_BUILD_PAYLOAD_BUILD_ASSIGN_EXPR, "build": build, "build_after": build}

static func content_equals_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	var content_equals: bool = other_is_build_payload and other_block == build_block
	return {"source_owner": "PortGame.source_build_payload_content_equals_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_CONTENT_EQUALS_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR, "other_is_build_payload": other_is_build_payload, "other_block": other_block, "build_block": build_block, "content_equals": content_equals}

static func content_state(build_block: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_content_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_CONTENT_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_BUILD_BLOCK_RETURN_EXPR, "content": build_block}

static func build_time_state(build_time: float) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_build_time_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_BUILD_TIME_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_BUILD_TIME_RETURN_EXPR, "buildTime": build_time}

static func requirements_state(requirements: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_requirements_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_REQUIREMENTS_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_REQUIREMENTS_RETURN_EXPR, "requirements": requirements}

static func x_state(build_x: float) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_x_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_X_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_X_RETURN_EXPR, "x": build_x}

static func y_state(build_y: float) -> Dictionary:
	return {"source_owner": "PortGame.source_build_payload_y_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_Y_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_Y_RETURN_EXPR, "y": build_y}

static func size_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	var size: float = build_block_size * source_tilesize
	return {"source_owner": "PortGame.source_build_payload_size_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_SIZE_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_SIZE_RETURN_EXPR, "build_block_size": build_block_size, "source_tilesize": source_tilesize, "size": size}

static func write_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	var write_calls: Array = [{"call": SOURCE_BUILD_PAYLOAD_WRITE_PAYLOAD_BLOCK_EXPR, "method": "write.b", "value": payload_block}, {"call": SOURCE_BUILD_PAYLOAD_WRITE_BLOCK_ID_EXPR, "method": "write.s", "value": build_block_id}, {"call": SOURCE_BUILD_PAYLOAD_WRITE_VERSION_EXPR, "method": "write.b", "value": build_version}, {"call": SOURCE_BUILD_PAYLOAD_WRITE_ALL_EXPR, "method": "build.writeAll", "called": true}]
	return {"source_owner": "PortGame.source_build_payload_write_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_WRITE_METHOD, "payload_block_write_expr": SOURCE_BUILD_PAYLOAD_WRITE_PAYLOAD_BLOCK_EXPR, "block_id_write_expr": SOURCE_BUILD_PAYLOAD_WRITE_BLOCK_ID_EXPR, "version_write_expr": SOURCE_BUILD_PAYLOAD_WRITE_VERSION_EXPR, "write_all_expr": SOURCE_BUILD_PAYLOAD_WRITE_ALL_EXPR, "payload_block": payload_block, "build_block_id": build_block_id, "build_version": build_version, "write_all_called": true, "write_calls": write_calls}

static func set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	var set_call: Dictionary = {"call": SOURCE_BUILD_PAYLOAD_SET_EXPR, "x": x, "y": y}
	return {"source_owner": "PortGame.source_build_payload_set_state", "source": SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_SET_METHOD, "set_expr": SOURCE_BUILD_PAYLOAD_SET_EXPR, "x": x, "y": y, "rotation": rotation_value, "set_called": true, "set_call": set_call}

static func generated_build_payload_block_bridge_state(build_block: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_block_0([build_block])
	var canonical = block_state(build_block)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_block_state", "generated_owner": "BuildPayload.java_method_block_0", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_constructor_block_team_bridge_state(block: Variant, team: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_constructor_BuildPayload_0([block, team])
	var canonical = constructor_block_team_state(block, team)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_constructor_block_team_state", "generated_owner": "BuildPayload.java_constructor_BuildPayload_0", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_constructor_build_bridge_state(build: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_constructor_BuildPayload_1([build])
	var canonical = constructor_build_state(build)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_constructor_build_state", "generated_owner": "BuildPayload.java_constructor_BuildPayload_1", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_content_equals_bridge_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_contentEquals_3([other_is_build_payload, other_block, build_block])
	var canonical = content_equals_state(other_is_build_payload, other_block, build_block)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_content_equals_state", "generated_owner": "BuildPayload.java_method_contentEquals_3", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_content_bridge_state(build_block: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_content_4([build_block])
	var canonical = content_state(build_block)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_content_state", "generated_owner": "BuildPayload.java_method_content_4", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_requirements_bridge_state(requirements: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_requirements_7([requirements])
	var canonical = requirements_state(requirements)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_requirements_state", "generated_owner": "BuildPayload.java_method_requirements_7", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_build_time_bridge_state(build_time: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_buildTime_8([build_time])
	var canonical = build_time_state(build_time)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_build_time_state", "generated_owner": "BuildPayload.java_method_buildTime_8", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_x_bridge_state(build_x: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_x_9([build_x])
	var canonical = x_state(build_x)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_x_state", "generated_owner": "BuildPayload.java_method_x_9", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_y_bridge_state(build_y: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_y_10([build_y])
	var canonical = y_state(build_y)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_y_state", "generated_owner": "BuildPayload.java_method_y_10", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_size_bridge_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_size_11([build_block_size, source_tilesize])
	var canonical = size_state(build_block_size, source_tilesize)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_size_state", "generated_owner": "BuildPayload.java_method_size_11", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_size_11([build_block_size])
	var canonical = size_state(build_block_size, SourceWorldDefaults.TILESIZE)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_size_state", "generated_owner": "BuildPayload.java_method_size_11", "defaulted_arg": "source_tilesize", "source_tilesize": result.get("source_tilesize", null), "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_write_bridge_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_write_13([payload_block, build_block_id, build_version])
	var canonical = write_state(payload_block, build_block_id, build_version)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_write_state", "generated_owner": "BuildPayload.java_method_write_13", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd")
	var instance = script.new()
	var result = instance.java_method_set_14([x, y, rotation_value])
	var canonical = set_state(x, y, rotation_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_build_payload_set_state", "generated_owner": "BuildPayload.java_method_set_14", "result": result, "canonical": canonical, "matches": matches}
