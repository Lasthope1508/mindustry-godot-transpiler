extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid := preload("res://src/game/SourceConsumeLiquidState.gd")
const base := preload("res://src/game/SourceConsumeLiquidBaseState.gd")
const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const catalog_owner := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const storage := preload("res://src/game/SourceLiquidModuleState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

class ProbeBlock extends RefCounted:
	var properties: Dictionary

class ProbeLiquid extends RefCounted:
	var field: String
	var id: String

class ProbeCatalog extends RefCounted:
	var liquids: Array
	func get_many(kind: String) -> Array:
		return liquids if kind == "liquid" else []

func _ready() -> void:
	var capability_matches: bool = base.source_apply_capability_state() == {"block_has_liquids_after": true}
	for before in [false, true]:
		capability_matches = capability_matches and base.apply_state(before)["block_has_liquids_before"] == before and base.apply_state(before)["block_has_liquids_after"]
	var original_filter := [false, true, false]
	var projected = liquid.source_apply_filter_state(original_filter, 2)
	var legacy = liquid.apply_state(false, original_filter, 2, base.apply_state)
	var filter_matches: bool = original_filter == [false, true, false] and projected["liquid_filter_after"] == [false, true, true] and legacy["liquid_filter_after"] == projected["liquid_filter_after"] and legacy["block_has_liquids_after"]
	var fixture_catalog := ProbeCatalog.new()
	for index in range(3):
		var entry := ProbeLiquid.new()
		entry.field = "javaField" + str(index)
		entry.id = "content-slug-" + str(index)
		fixture_catalog.liquids.append(entry)
	var partial_matches := true
	var cache_matches := true
	var definitions_preserved := true
	for before in [{}, {"hasLiquids": false}, {"hasLiquids": true}]:
		var block := ProbeBlock.new()
		block.properties = before.duplicate()
		block.properties["consumeLiquid"] = [{"liquid": "javaField0", "amount": 0.0, "optional": true, "update": false}, {"liquid": "javaField2", "amount": 1.0}]
		var original := block.properties.duplicate(true)
		var result = liquid.source_apply_liquid_consumers_state(block, fixture_catalog)
		partial_matches = partial_matches and result["has_liquids"] and result["liquid_filter"] == [true, false, true] and placed.source_block_has_liquids_state(block)["has_liquids"]
		var repeated = liquid.source_apply_liquid_consumers_state(block, fixture_catalog)
		cache_matches = cache_matches and is_same(result, repeated) and is_same(result["liquid_filter"], repeated["liquid_filter"])
		definitions_preserved = definitions_preserved and block.properties == original
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)
	var catalog = game.get("content_catalog")
	var actual_block = catalog.get_many("block").filter(func(value): return value.id == "electrolyzer")[0]
	var original_properties: Dictionary = actual_block.properties.duplicate(true)
	var missing_constructor_capability: bool = not actual_block.properties.has("hasLiquids")
	var first := Sprite2D.new()
	var second := Sprite2D.new()
	game.add_child(first)
	game.add_child(second)
	game.call("record_placed_block", first, actual_block, Vector2i(200, 200))
	game.call("record_placed_block", second, actual_block, Vector2i(210, 200))
	var applied: Dictionary = actual_block.get_meta(liquid.SOURCE_BLOCK_LIQUID_APPLY_META_KEY)
	var typed = catalog_owner.source_liquid_catalog_state(catalog)
	var water_id: int = typed["liquid_id_by_name"]["water"]
	var actual_filter_matches: bool = applied["has_liquids"] and applied["liquid_filter"].size() == catalog.get_many("liquid").size() and applied["liquid_filter"].count(true) == 1 and applied["liquid_filter"][water_id]
	var first_frame: Dictionary = first.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
	var second_frame: Dictionary = second.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
	storage.source_reset_state(first_frame, water_id, 3.0)
	var allocation_matches: bool = missing_constructor_capability and first_frame["liquids"][water_id] == 3.0 and second_frame["liquids"][water_id] == 0.0 and not is_same(first_frame, second_frame)
	definitions_preserved = definitions_preserved and actual_block.properties == original_properties
	var state := registry.canonical_headquarter_registry_state()
	var proof := {"matches": capability_matches and filter_matches and partial_matches and cache_matches and definitions_preserved and actual_filter_matches and allocation_matches and state.get("errors", []).is_empty() and state.get("one_headquarter_per_ssot", false), "capability_matches": capability_matches, "filter_matches": filter_matches, "partial_input_matches": partial_matches, "shared_apply_cache": cache_matches, "source_definitions_preserved": definitions_preserved, "actual_filter_matches": actual_filter_matches, "actual_placement_allocation_matches": allocation_matches, "registry_valid": state.get("errors", []).is_empty(), "one_headquarter_per_ssot": state.get("one_headquarter_per_ssot", false)}
	proof_state.write_proof("LiquidConsumerApplyHydrationProof", proof)
	game.queue_free()
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
