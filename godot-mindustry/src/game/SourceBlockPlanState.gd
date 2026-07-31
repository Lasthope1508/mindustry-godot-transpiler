extends RefCounted
class_name SourceBlockPlanState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY := "mod_float"
const SOURCE_BLOCK_PLAN_MOD_FLOAT_FALLBACK := "source_arc_mathf_mod_float"
const SOURCE_BLOCK_PLAN_ROTATION_KEY := "plan_rotation"
const SOURCE_BLOCK_PLAN_ROTATION_FALLBACK := "source_block_plan_rotation_state"

static func _source_mod_float(value: float, mod: float) -> float:
	return fmod(fmod(value, mod) + mod, mod)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_block_plan_method_names"):
		var names = game.call("_block_plan_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY, SOURCE_BLOCK_PLAN_MOD_FLOAT_FALLBACK)),
		SOURCE_BLOCK_PLAN_ROTATION_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BLOCK_PLAN_ROTATION_KEY, SOURCE_BLOCK_PLAN_ROTATION_FALLBACK)),
	}

static func is_hidden_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	var is_hidden_value: bool = (not build_visibility_visible) and (not revealed_blocks_contains_self)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_HIDDEN_STATE, "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public boolean isHidden(){", "return_expr": "return !buildVisibility.visible() && !state.rules.revealedBlocks.contains(this);", "build_visibility_visible": build_visibility_visible, "revealed_blocks_contains_self": revealed_blocks_contains_self, "is_hidden": is_hidden_value}

static func plan_rotation_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	var plan_rotation_value: int = 0 if ((not rotate_value) and lock_rotation) else rot
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLAN_ROTATION_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public int planRotation(int rot){", "return_expr": "return !rotate && lockRotation ? 0 : rot;", "rotate": rotate_value, "lockRotation": lock_rotation, "rot": rot, "plan_rotation": plan_rotation_value}

static func flip_rotation_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool, mod_fn: Callable, plan_rotation_fn: Callable) -> Dictionary:
	var rotation_even: bool = rotation_before % 2 == 0
	var flip_guard: bool = (x_value == rotation_even) != invert_flip
	var mod_value: int = int(mod_fn.call(float(rotation_before + 2), 4.0))
	var rotation_plan_state: Dictionary = plan_rotation_fn.call(rotate_value, lock_rotation, mod_value)
	var rotation_after: int = int(rotation_plan_state["plan_rotation"]) if flip_guard else rotation_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_FLIP_ROTATION_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void flipRotation(BuildPlan req, boolean x){", "guard_expr": "if((x == (req.rotation % 2 == 0)) != invertFlip){", "assignment_expr": "req.rotation = planRotation(Mathf.mod(req.rotation + 2, 4));", "rotation_before": rotation_before, "x": x_value, "invertFlip": invert_flip, "rotate": rotate_value, "lockRotation": lock_rotation, "rotation_even": rotation_even, "flip_guard": flip_guard, "mod_input": rotation_before + 2, "mod_value": mod_value, "plan_rotation_state": rotation_plan_state, "rotation_after": rotation_after}

static func game_flip_rotation_state(game: Object, rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return flip_rotation_state(
		rotation_before,
		x_value,
		invert_flip,
		rotate_value,
		lock_rotation,
		callbacks.get(SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY, Callable()),
		callbacks.get(SOURCE_BLOCK_PLAN_ROTATION_KEY, Callable())
	)

static func get_plan_configs_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	var options_after: Array = options_before.duplicate()
	if item_configured:
		options_after.append_array(content_items)
	if liquid_configured:
		options_after.append_array(content_liquids)
	var item_options_added: int = content_items.size() if item_configured else 0
	var liquid_options_added: int = content_liquids.size() if liquid_configured else 0
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_PLAN_CONFIGS_STATE, "source": "core/src/mindustry/world/Block.java", "comment": "/** Fills the specified array with the list of configuration options this block has. Only used for plans. */", "method": "public void getPlanConfigs(Seq<UnlockableContent> options){", "item_guard_expr": "if(configurations.containsKey(Item.class)){", "item_add_expr": "options.add(content.items());", "liquid_guard_expr": "if(configurations.containsKey(Liquid.class)){", "liquid_add_expr": "options.add(content.liquids());", "options_before": options_before, "item_configured": item_configured, "liquid_configured": liquid_configured, "content_items": content_items, "content_liquids": content_liquids, "item_options_added": item_options_added, "liquid_options_added": liquid_options_added, "options_after": options_after}

static func generated_block_is_hidden_bridge_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_isHidden_127", [build_visibility_visible, revealed_blocks_contains_self], null)
	var canonical = is_hidden_state(build_visibility_visible, revealed_blocks_contains_self)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_HIDDEN_STATE, "generated_owner": "block.java_method_isHidden_127", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_plan_rotation_bridge_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_planRotation_129", [rotate_value, lock_rotation, rot], null)
	var canonical = plan_rotation_state(rotate_value, lock_rotation, rot)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLAN_ROTATION_STATE, "generated_owner": "block.java_method_planRotation_129", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_flip_rotation_bridge_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_flipRotation_130", [rotation_before, x_value, invert_flip, rotate_value, lock_rotation], null)
	var canonical = flip_rotation_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation, Callable(SourceBlockPlanState, "_source_mod_float"), Callable(SourceBlockPlanState, "plan_rotation_state"))
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_FLIP_ROTATION_STATE, "generated_owner": "block.java_method_flipRotation_130", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_get_plan_configs_bridge_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_getPlanConfigs_131", [options_before, item_configured, liquid_configured, content_items, content_liquids], null)
	var canonical = get_plan_configs_state(options_before, item_configured, liquid_configured, content_items, content_liquids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_PLAN_CONFIGS_STATE, "generated_owner": "block.java_method_getPlanConfigs_131", "result": result, "canonical": canonical, "matches": matches}
