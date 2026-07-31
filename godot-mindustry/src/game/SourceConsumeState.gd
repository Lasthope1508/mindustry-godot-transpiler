extends RefCounted
class_name SourceConsumeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func optional_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_OPTIONAL_STATE,
		"optional_after": optional_value,
		"booster_after": boost_value,
		"return_self": true,
		"method": "public Consume optional(boolean optional, boolean boost){",
	}

static func boost_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_BOOST_STATE,
		"optional_after": true,
		"booster_after": true,
		"return_self": true,
		"method": "public Consume boost(){",
	}

static func update_flag_state(update_value: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_UPDATE_FLAG_STATE,
		"update_after": update_value,
		"return_self": true,
		"method": "public Consume update(boolean update){",
	}

static func ignore_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_IGNORE_STATE,
		"ignored": true,
		"method": "public boolean ignore(){",
	}

static func build_state(build: Variant, table: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_BUILD_STATE,
		"empty_body": true,
		"build": build,
		"table": table,
		"method": "public void build(Building build, Table table){",
	}

static func apply_state(block: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_APPLY_STATE,
		"empty_body": true,
		"block": block,
		"method": "public void apply(Block block){",
	}

static func trigger_state(build: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_TRIGGER_STATE,
		"empty_body": true,
		"build": build,
		"method": "public void trigger(Building build){",
	}

static func update_build_state(build: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_UPDATE_BUILD_STATE,
		"empty_body": true,
		"build": build,
		"method": "public void update(Building build){",
	}

static func display_state(stats: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_DISPLAY_STATE,
		"empty_body": true,
		"stats": stats,
		"method": "public void display(Stats stats){",
	}

static func efficiency_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_EFFICIENCY_STATE,
		"efficiency": 1.0,
		"method": "public float efficiency(Building build){",
	}

static func efficiency_multiplier_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_STATE,
		"efficiency_multiplier": 1.0,
		"method": "public float efficiencyMultiplier(Building build){",
	}

static func generated_optional_bridge_state(optional_value: bool, boost_value: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_optional_1([optional_value, boost_value])
	var canonical = optional_state(optional_value, boost_value)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_OPTIONAL_STATE, "generated_owner": "consume.optional", "result": result, "canonical": canonical, "matches": result.get("optional_after", null) == canonical.get("optional_after", null) and result.get("booster_after", null) == canonical.get("booster_after", null) and result.get("return_self", null) == canonical.get("return_self", null)}

static func generated_boost_bridge_state() -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_boost_2([])
	var canonical = boost_state()
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_BOOST_STATE, "generated_owner": "consume.boost", "result": result, "canonical": canonical, "matches": result.get("optional_after", null) == canonical.get("optional_after", null) and result.get("booster_after", null) == canonical.get("booster_after", null) and result.get("return_self", null) == canonical.get("return_self", null)}

static func generated_update_flag_bridge_state(update_value: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_update_3([update_value])
	var canonical = update_flag_state(update_value)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_UPDATE_FLAG_STATE, "generated_owner": "consume.update", "result": result, "canonical": canonical, "matches": result.get("update_after", null) == canonical.get("update_after", null) and result.get("return_self", null) == canonical.get("return_self", null)}

static func generated_ignore_bridge_state() -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_ignore_4([])
	var canonical = ignore_state()
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_IGNORE_STATE, "generated_owner": "consume.ignore", "result": result, "canonical": canonical, "matches": result.get("ignored", null) == canonical.get("ignored", null)}

static func generated_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_build_5([build, table])
	var canonical = build_state(build, table)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_BUILD_STATE, "generated_owner": "consume.build", "result": result, "canonical": canonical, "matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("build", null) == canonical.get("build", null) and result.get("table", null) == canonical.get("table", null)}

static func generated_apply_bridge_state(block: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block])
	var canonical = apply_state(block)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_APPLY_STATE, "generated_owner": "consume.apply", "result": result, "canonical": canonical, "matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("block", null) == canonical.get("block", null)}

static func generated_trigger_bridge_state(build: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_trigger_6([build])
	var canonical = trigger_state(build)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_TRIGGER_STATE, "generated_owner": "consume.trigger", "result": result, "canonical": canonical, "matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("build", null) == canonical.get("build", null)}

static func generated_update_build_bridge_state(build: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_update_7([build])
	var canonical = update_build_state(build)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_UPDATE_BUILD_STATE, "generated_owner": "consume.update(Building)", "result": result, "canonical": canonical, "matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("build", null) == canonical.get("build", null)}

static func generated_display_bridge_state(stats: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_display_10([stats])
	var canonical = display_state(stats)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_DISPLAY_STATE, "generated_owner": "consume.display", "result": result, "canonical": canonical, "matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("stats", null) == canonical.get("stats", null)}

static func generated_efficiency_bridge_state() -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_8([])
	var canonical = efficiency_state()
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_EFFICIENCY_STATE, "generated_owner": "consume.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null)}

static func generated_efficiency_multiplier_bridge_state() -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/Consume.gd")
	var instance = script.new()
	var result = instance.java_method_efficiencyMultiplier_9([])
	var canonical = efficiency_multiplier_state()
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_STATE_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume.efficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}
