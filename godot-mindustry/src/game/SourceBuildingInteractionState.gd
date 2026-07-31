extends RefCounted
class_name SourceBuildingInteractionState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const BUILDING_COMP_GENERATED_CLASS := "res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd"
const SOURCE_BUILDING_UNIT_ON_COMMENT := "/** Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  */"
const SOURCE_BUILDING_UNIT_ON_METHOD := "public void unitOn(Unit unit){"
const SOURCE_BUILDING_UNIT_ON_EMPTY_BODY := "public void unitOn(Unit unit){\n    }"
const SOURCE_BUILDING_UNIT_ON_ANY_COMMENT := "/** Called every frame a unit is on this. Applies to any unit.  */"
const SOURCE_BUILDING_UNIT_ON_ANY_METHOD := "public void unitOnAny(Unit unit){"
const SOURCE_BUILDING_UNIT_ON_ANY_EMPTY_BODY := "public void unitOnAny(Unit unit){\n    }"
const SOURCE_BUILDING_UNIT_REMOVED_COMMENT := "/** Called when a unit that spawned at this tile is removed. */"
const SOURCE_BUILDING_UNIT_REMOVED_METHOD := "public void unitRemoved(Unit unit){"
const SOURCE_BUILDING_UNIT_REMOVED_EMPTY_BODY := "public void unitRemoved(Unit unit){\n    }"

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
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_isCommandable_140", [block_commandable], null)
	var canonical = is_commandable_bridge_canonical_state(block_commandable)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_COMMANDABLE_STATE, "generated_owner": "building_comp.java_method_isCommandable_140", "result": result, "canonical": canonical, "matches": matches}

static func generated_is_payload_bridge_state(tile_is_empty_tile: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_isPayload_141", [tile_is_empty_tile], null)
	var canonical = is_payload_bridge_canonical_state(tile_is_empty_tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_PAYLOAD_STATE, "generated_owner": "building_comp.java_method_isPayload_141", "result": result, "canonical": canonical, "matches": matches}

static func generated_overwrote_bridge_state(previous_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_overwrote_142", [previous_state], null)
	var canonical = overwrote_state(previous_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_OVERWROTE_STATE, "generated_owner": "building_comp.java_method_overwrote_142", "result": result, "canonical": canonical, "matches": matches}

static func generated_on_removed_bridge_state(current_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_onRemoved_143", [current_state], null)
	var canonical = on_removed_state(current_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_REMOVED_STATE, "generated_owner": "building_comp.java_method_onRemoved_143", "result": result, "canonical": canonical, "matches": matches}

static func generated_unit_on_bridge_state(unit_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_unitOn_144", [unit_state], null)
	var canonical = unit_on_bridge_canonical_state(unit_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UNIT_ON_STATE, "generated_owner": "building_comp.java_method_unitOn_144", "result": result, "canonical": canonical, "matches": matches}

static func generated_unit_on_any_bridge_state(unit_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_unitOnAny_145", [unit_state], null)
	var canonical = unit_on_any_bridge_canonical_state(unit_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UNIT_ON_ANY_STATE, "generated_owner": "building_comp.java_method_unitOnAny_145", "result": result, "canonical": canonical, "matches": matches}

static func generated_unit_removed_bridge_state(unit_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_unitRemoved_146", [unit_state], null)
	var canonical = unit_removed_bridge_canonical_state(unit_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UNIT_REMOVED_STATE, "generated_owner": "building_comp.java_method_unitRemoved_146", "result": result, "canonical": canonical, "matches": matches}

static func generated_puddle_on_bridge_state(puddle_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_puddleOn_147", [puddle_state], null)
	var canonical = puddle_on_state(puddle_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PUDDLE_ON_STATE, "generated_owner": "building_comp.java_method_puddleOn_147", "result": result, "canonical": canonical, "matches": matches}

static func generated_tapped_bridge_state(current_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BUILDING_COMP_GENERATED_CLASS, "java_method_tapped_150", [current_state], null)
	var canonical = tapped_bridge_canonical_state(current_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TAPPED_STATE, "generated_owner": "building_comp.java_method_tapped_150", "result": result, "canonical": canonical, "matches": matches}
