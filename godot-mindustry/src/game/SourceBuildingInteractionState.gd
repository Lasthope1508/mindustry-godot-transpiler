extends RefCounted
class_name SourceBuildingInteractionState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_INTERACTION_IS_COMMANDABLE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_IS_COMMANDABLE_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_IS_COMMANDABLE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_IS_COMMANDABLE_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_IS_PAYLOAD_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_IS_PAYLOAD_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_IS_PAYLOAD_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_IS_PAYLOAD_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_OVERWROTE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_OVERWROTE_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_OVERWROTE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_OVERWROTE_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_ON_REMOVED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_ON_REMOVED_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_ON_REMOVED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_ON_REMOVED_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_UNIT_ON_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_UNIT_ON_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_UNIT_ON_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_UNIT_ON_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_UNIT_ON_ANY_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_UNIT_ON_ANY_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_UNIT_ON_ANY_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_UNIT_ON_ANY_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_UNIT_REMOVED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_UNIT_REMOVED_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_UNIT_REMOVED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_UNIT_REMOVED_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_PUDDLE_ON_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_PUDDLE_ON_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_PUDDLE_ON_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_PUDDLE_ON_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTION_TAPPED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_TAPPED_JAVA_METHOD
const SOURCE_BUILDING_INTERACTION_TAPPED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTION_TAPPED_GENERATED_OWNER
const SOURCE_BUILDING_UNIT_ON_COMMENT := source_building_source_text_state.SOURCE_BUILDING_UNIT_ON_COMMENT
const SOURCE_BUILDING_UNIT_ON_METHOD := source_building_source_text_state.SOURCE_BUILDING_UNIT_ON_METHOD
const SOURCE_BUILDING_UNIT_ON_EMPTY_BODY := source_building_source_text_state.SOURCE_BUILDING_UNIT_ON_EMPTY_BODY
const SOURCE_BUILDING_UNIT_ON_ANY_COMMENT := source_building_source_text_state.SOURCE_BUILDING_UNIT_ON_ANY_COMMENT
const SOURCE_BUILDING_UNIT_ON_ANY_METHOD := source_building_source_text_state.SOURCE_BUILDING_UNIT_ON_ANY_METHOD
const SOURCE_BUILDING_UNIT_ON_ANY_EMPTY_BODY := source_building_source_text_state.SOURCE_BUILDING_UNIT_ON_ANY_EMPTY_BODY
const SOURCE_BUILDING_UNIT_REMOVED_COMMENT := source_building_source_text_state.SOURCE_BUILDING_UNIT_REMOVED_COMMENT
const SOURCE_BUILDING_UNIT_REMOVED_METHOD := source_building_source_text_state.SOURCE_BUILDING_UNIT_REMOVED_METHOD
const SOURCE_BUILDING_UNIT_REMOVED_EMPTY_BODY := source_building_source_text_state.SOURCE_BUILDING_UNIT_REMOVED_EMPTY_BODY

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func is_commandable_state(block_commandable: bool) -> bool:
	return block_commandable

static func is_payload_state(tile_is_empty_tile: bool) -> bool:
	return tile_is_empty_tile

static func overwrote_state(previous_state: Variant) -> Dictionary:
	return {"method": "public void overwrote(Seq<Building> previous){", "comment": "Called when a block is placed over some other blocks. This seq will always have at least one item.", "no_op": true, "previous_state": previous_state}

static func on_removed_state(current_state: Variant) -> Dictionary:
	return {"method": "public void onRemoved(){", "no_op": true, "current_state": current_state}

static func unit_on_state(unit_state: Variant) -> Variant:
	return unit_state

static func unit_on_any_state(unit_state: Variant) -> Variant:
	return unit_state

static func unit_removed_state(unit_state: Variant) -> Variant:
	return unit_state

static func puddle_on_state(puddle_state: Variant) -> Dictionary:
	return {
		"comment": "Called when a puddle is on this building. Only called at an interval (40 ticks).",
		"method": "public void puddleOn(Puddle puddle){",
		"no_op": true,
		"puddle_state": puddle_state,
	}

static func tapped_state(current_state: Variant) -> Dictionary:
	return {
		"comment": "/** Called when the block is tapped by the local player. */",
		"method": "public void tapped(){",
		"empty_body": "public void tapped(){\n\n    }",
		"current_state": current_state,
		"no_op": true,
	}

static func is_commandable_bridge_canonical_state(block_commandable: bool) -> Dictionary:
	return {"method": "public boolean isCommandable(){", "return_expr": "return block.commandable;", "block_commandable": block_commandable, "commandable": is_commandable_state(block_commandable)}

static func is_payload_bridge_canonical_state(tile_is_empty_tile: bool) -> Dictionary:
	return {"method": "public boolean isPayload(){", "return_expr": "return tile == emptyTile;", "tile_is_empty_tile": tile_is_empty_tile, "is_payload": is_payload_state(tile_is_empty_tile)}

static func unit_on_bridge_canonical_state(unit_state: Variant) -> Dictionary:
	return {"method": SOURCE_BUILDING_UNIT_ON_METHOD, "empty_body": SOURCE_BUILDING_UNIT_ON_EMPTY_BODY, "unit_state": unit_on_state(unit_state)}

static func unit_on_any_bridge_canonical_state(unit_state: Variant) -> Dictionary:
	return {"method": SOURCE_BUILDING_UNIT_ON_ANY_METHOD, "empty_body": SOURCE_BUILDING_UNIT_ON_ANY_EMPTY_BODY, "unit_state": unit_on_any_state(unit_state)}

static func unit_removed_bridge_canonical_state(unit_state: Variant) -> Dictionary:
	return {"method": SOURCE_BUILDING_UNIT_REMOVED_METHOD, "empty_body": SOURCE_BUILDING_UNIT_REMOVED_EMPTY_BODY, "unit_state": unit_removed_state(unit_state)}

static func tapped_bridge_canonical_state(current_state: Variant) -> Dictionary:
	var source_state := tapped_state(current_state)
	return {"method": source_state.get("method", ""), "empty_body": source_state.get("empty_body", ""), "current_state": source_state.get("current_state"), "no_op": bool(source_state.get("no_op", false))}

static func generated_is_commandable_bridge_state(block_commandable: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_IS_COMMANDABLE_JAVA_METHOD, [block_commandable])
	var canonical = is_commandable_bridge_canonical_state(block_commandable)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_COMMANDABLE_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_IS_COMMANDABLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_is_payload_bridge_state(tile_is_empty_tile: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_IS_PAYLOAD_JAVA_METHOD, [tile_is_empty_tile])
	var canonical = is_payload_bridge_canonical_state(tile_is_empty_tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_PAYLOAD_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_IS_PAYLOAD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_overwrote_bridge_state(previous_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_OVERWROTE_JAVA_METHOD, [previous_state])
	var canonical = overwrote_state(previous_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_OVERWROTE_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_OVERWROTE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_on_removed_bridge_state(current_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_ON_REMOVED_JAVA_METHOD, [current_state])
	var canonical = on_removed_state(current_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_REMOVED_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_ON_REMOVED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_unit_on_bridge_state(unit_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_UNIT_ON_JAVA_METHOD, [unit_state])
	var canonical = unit_on_bridge_canonical_state(unit_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UNIT_ON_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_UNIT_ON_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_unit_on_any_bridge_state(unit_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_UNIT_ON_ANY_JAVA_METHOD, [unit_state])
	var canonical = unit_on_any_bridge_canonical_state(unit_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UNIT_ON_ANY_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_UNIT_ON_ANY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_unit_removed_bridge_state(unit_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_UNIT_REMOVED_JAVA_METHOD, [unit_state])
	var canonical = unit_removed_bridge_canonical_state(unit_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UNIT_REMOVED_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_UNIT_REMOVED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_puddle_on_bridge_state(puddle_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_PUDDLE_ON_JAVA_METHOD, [puddle_state])
	var canonical = puddle_on_state(puddle_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PUDDLE_ON_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_PUDDLE_ON_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_tapped_bridge_state(current_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTION_TAPPED_JAVA_METHOD, [current_state])
	var canonical = tapped_bridge_canonical_state(current_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TAPPED_STATE, "generated_owner": SOURCE_BUILDING_INTERACTION_TAPPED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
