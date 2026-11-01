extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const consume := preload("res://src/game/SourceConsumeState.gd")
const efficiency := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class ProbeBlock extends RefCounted:
	var properties: Dictionary

class ProbeLiquid extends RefCounted:
	var field: String
	var id: String

class ProbeCatalog extends RefCounted:
	var liquids: Array
	func get_many(kind: String) -> Array:
		assert(kind == "liquid")
		return liquids

func _ready() -> void:
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
	var block = catalog.get_many("block").filter(func(value): return value.id == "mechanical-drill")[0]
	var bound_at_placement: bool = block.has_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY)
	var rows: Array = block.get_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY)
	var repeated = liquid_state.source_bind_liquid_consumers_state(block, catalog)["consumers"]
	var shared: bool = is_same(rows, repeated) and is_same(rows[0], repeated[0])
	var definitions = liquid_state.source_liquid_consumer_definitions_state(block)["consume_builder"]
	var definition_preserved: bool = definitions[0]["liquid"] == "water" and definitions[0]["amount"] == 0.05
	var descriptor_matches: bool = rows[0]["liquid"] == 0 and rows[0]["amount"] == 0.05 and rows[0]["optional"] and rows[0]["booster"] and not rows[0]["ignored"]
	var groups := consume.classify_consumer_arrays(rows, "ignored", "optional", "update")
	var optional_matches: bool = groups["optional_consumers"].size() == 1 and groups["non_optional_consumers"].is_empty() and groups["update_consumers"].size() == 1
	var efficiency_results: Array = []
	for amount in [0.1, 0.05, 0.0]:
		var result = liquid_state.efficiency_state(amount, rows[0]["amount"], 2.0, 1.0, 1.0)["efficiency"]
		var frame := efficiency.update_consumption_state(true, false, true, true, true, 1.0, [], [{"result": result}], [], {})
		efficiency_results.append([frame["efficiency"], frame["optional_efficiency"]])
	optional_matches = optional_matches and efficiency_results == [[1.0, 1.0], [1.0, 0.5], [1.0, 0.0]]
	var first := ProbeLiquid.new()
	first.field = "otherJavaName"
	first.id = "other-slug"
	var second := ProbeLiquid.new()
	second.field = "coolantJavaName"
	second.id = "different-content-slug"
	var fake_catalog := ProbeCatalog.new()
	fake_catalog.liquids = [first, second]
	var fake_block := ProbeBlock.new()
	fake_block.properties = {"consumeLiquid": [{"liquid": "coolantJavaName", "amount": 2.0, "update": false}]}
	var remapped = liquid_state.source_bind_liquid_consumers_state(fake_block, fake_catalog)["consumers"]
	var remap_groups := consume.classify_consumer_arrays(remapped, "ignored", "optional", "update")
	var remap_matches: bool = remapped[0]["liquid"] == 1 and remapped[0]["amount"] == 2.0 and remap_groups["optional_consumers"].is_empty() and remap_groups["update_consumers"].is_empty() and remap_groups["non_optional_consumers"].size() == 1
	var state := registry.canonical_headquarter_registry_state()
	var proof := {"matches": bound_at_placement and shared and definition_preserved and descriptor_matches and optional_matches and remap_matches and state.get("errors", []).is_empty() and state.get("one_headquarter_per_ssot", false), "bound_at_placement": bound_at_placement, "shared_block_consumers": shared, "definition_preserved": definition_preserved, "descriptor_matches": descriptor_matches, "optional_efficiency_matches": optional_matches, "efficiency_results": efficiency_results, "java_field_remap_matches": remap_matches, "registry_valid": state.get("errors", []).is_empty(), "one_headquarter_per_ssot": state.get("one_headquarter_per_ssot", false)}
	proof_state.write_proof("LiquidConsumerHydrationProof", proof)
	game.queue_free()
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
