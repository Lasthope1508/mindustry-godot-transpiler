extends RefCounted
class_name SourceBlockMetadataState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BLOCK_HEALTH_DEFAULT := source_block_defaults.HEALTH_DEFAULT
const SOURCE_BLOCK_SCALED_HEALTH_DEFAULT := source_block_defaults.SCALED_HEALTH_DEFAULT
const SOURCE_BLOCK_ITEM_CAPACITY_DEFAULT := source_block_defaults.ITEM_CAPACITY_DEFAULT
const SOURCE_BLOCK_CAN_OVERDRIVE_DEFAULT := source_block_defaults.CAN_OVERDRIVE_DEFAULT
const SOURCE_BLOCK_DUMP_TIME := source_factory_defaults.BLOCK_DUMP_TIME
const SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT := source_factory_defaults.DRILL_DELAY_DRILL_TIME_DEFAULT
const SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT := source_factory_defaults.DRILL_DELAY_ITEM_HARDNESS_DEFAULT
const SOURCE_DRILL_WARMUP_SPEED_COMMENT := "Speed at which the drill speeds up."
const SOURCE_DRILL_WARMUP_SPEED_FIELD := "public float warmupSpeed = 0.015f;"
const SOURCE_DRILL_WARMUP_SPEED_KEY := "warmupSpeed"
const SOURCE_DRILL_WARMUP_SPEED_DEFAULT := source_factory_defaults.DRILL_WARMUP_SPEED
const SOURCE_CONVEYOR_WORLD_SPEED_DEFAULT := source_factory_defaults.CONVEYOR_WORLD_SPEED_DEFAULT

static func block_properties(block) -> Dictionary:
	if block == null:
		return {}
	if block is Dictionary:
		var dictionary: Dictionary = block
		if dictionary.has("properties") and dictionary.get("properties") is Dictionary:
			return dictionary.get("properties", {}).duplicate(true)
		return dictionary.duplicate(true)
	if block is Object:
		var properties = block.get("properties")
		if properties is Dictionary:
			return properties.duplicate(true)
	return {}

static func block_health_value(block) -> float:
	var properties := block_properties(block)
	return float(properties.get("health", SOURCE_BLOCK_HEALTH_DEFAULT))

static func block_health(block_id: String, content_catalog) -> float:
	var block = _catalog_entry(content_catalog, block_id)
	var properties := block_properties(block)
	return float(properties.get("health", SOURCE_BLOCK_HEALTH_DEFAULT))

static func block_size(block) -> int:
	var properties := block_properties(block)
	return max(source_block_defaults.SIZE_DEFAULT, int(properties.get("size", source_block_defaults.SIZE_DEFAULT)))

static func block_item_capacity(block_id: String, content_catalog) -> int:
	var block = _catalog_entry(content_catalog, block_id)
	var properties := block_properties(block)
	return int(properties.get("itemCapacity", SOURCE_BLOCK_ITEM_CAPACITY_DEFAULT))

static func block_dump_time(block_id: String, content_catalog) -> float:
	var block = _catalog_entry(content_catalog, block_id)
	var properties := block_properties(block)
	return float(properties.get("dumpTime", SOURCE_BLOCK_DUMP_TIME))

static func block_warmup_speed(block_id: String, content_catalog) -> float:
	var block = _catalog_entry(content_catalog, block_id)
	var properties := block_properties(block)
	if not properties.has("warmupSpeed"):
		return SOURCE_DRILL_WARMUP_SPEED_DEFAULT
	return float(properties.get("warmupSpeed", SOURCE_DRILL_WARMUP_SPEED_DEFAULT))

static func block_conveyor_world_speed(block_id: String, tile_size: float, content_catalog) -> float:
	var block = _catalog_entry(content_catalog, block_id)
	var properties := block_properties(block)
	return float(properties.get("speed", SOURCE_CONVEYOR_WORLD_SPEED_DEFAULT)) * float(tile_size) * source_factory_defaults.CONVEYOR_TILE_SPEED_SCALE

static func block_drill_delay_state(block_id: String, item_id: String, content_catalog) -> Dictionary:
	var block = _catalog_entry(content_catalog, block_id)
	var item = _catalog_entry(content_catalog, item_id)
	var block_props := block_properties(block)
	var item_props := block_properties(item)
	var drill_multipliers = block_props.get("drillMultipliers", {})
	var drill_multiplier := 1.0
	if drill_multipliers is Dictionary and drill_multipliers.has(item_id):
		drill_multiplier = float(drill_multipliers.get(item_id, 1.0))
	return {
		"drill_time": float(block_props.get("drillTime", SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT)),
		"item_hardness": float(item_props.get("hardness", SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT)),
		"drill_multiplier": drill_multiplier,
	}

static func block_booster_item(block) -> String:
	var properties := block_properties(block)
	return str(properties.get("boosterItem", ""))

static func block_can_overdrive(block, default_can_overdrive := source_block_defaults.CAN_OVERDRIVE_DEFAULT) -> bool:
	var properties := block_properties(block)
	return bool(properties.get("canOverdrive", default_can_overdrive))

static func content_type_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_CONTENT_TYPE_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public ContentType getContentType(){", "content_type_return_expr": "return ContentType.block;", "content_type": "ContentType.block"}

static func generated_content_type_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_getContentType_120", [], null)
	var canonical = content_type_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_CONTENT_TYPE_STATE,
		"generated_owner": "block.java_method_getContentType_120",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func logic_visible_state(build_visibility_value: String) -> Dictionary:
	var logic_visible: bool = build_visibility_value != "hidden"
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOGIC_VISIBLE_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean logicVisible(){", "logic_visible_return_expr": "return buildVisibility != BuildVisibility.hidden;", "build_visibility": build_visibility_value, "logic_visible": logic_visible}

static func generated_logic_visible_bridge_state(build_visibility_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_logicVisible_121", [build_visibility_value], null)
	var canonical = logic_visible_state(build_visibility_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOGIC_VISIBLE_STATE,
		"generated_owner": "block.java_method_logicVisible_121",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func _catalog_entry(content_catalog, content_id: String):
	if content_catalog != null and content_catalog.has_method("get_by_id"):
		return content_catalog.get_by_id(content_id)
	return null
