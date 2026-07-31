extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_consume_state := preload("res://src/game/SourceBlockConsumeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var liquid := {"id": 1, "name": "water"}
	var stacks := [{"liquid": liquid, "amount": 2.5}]
	var item := {"id": 2, "name": "copper"}
	var item_stack := {"type": "ItemStack", "item": item, "amount": 3}
	var consume := {"type": "ConsumePower", "powerPerTick": 1.5}
	var consume_builder_before := [{"type": "ConsumeItems"}]
	var consume_builder_without_power := consume_builder_before.duplicate()
	var liquid_bridge := game.generated_block_consume_liquid_bridge_state(liquid, 1.25)
	var liquids_bridge := game.generated_block_consume_liquids_bridge_state(stacks)
	var power_bridge := game.generated_block_consume_power_bridge_state(4.0)
	var power_cond_bridge := game.generated_block_consume_power_cond_bridge_state(2.0, "condition")
	var power_dynamic_bridge := game.generated_block_consume_power_dynamic_bridge_state("usage")
	var power_dynamic_displayed_bridge := game.generated_block_consume_power_dynamic_displayed_bridge_state(9.0, "display-usage")
	var power_buffered_bridge := game.generated_block_consume_power_buffered_bridge_state(20.0)
	var item_single_bridge := game.generated_block_consume_item_single_bridge_state(item)
	var item_amount_bridge := game.generated_block_consume_item_amount_bridge_state(item, 5)
	var items_varargs_bridge := game.generated_block_consume_items_varargs_bridge_state([item_stack])
	var coolant_single_bridge := game.generated_block_consume_coolant_single_bridge_state(0.8)
	var coolant_filtered_bridge := game.generated_block_consume_coolant_filtered_bridge_state(0.9, true, false)
	var generic_bridge := game.generated_block_consume_generic_bridge_state(consume, true, consume_builder_before, consume_builder_without_power, null)
	var proof := {
		"module": "SourceBlockConsumeState",
		"liquid_bridge_matches": liquid_bridge == source_block_consume_state.generated_block_consume_liquid_bridge_state(liquid, 1.25) and bool(liquid_bridge.get("matches", false)),
		"liquids_bridge_matches": liquids_bridge == source_block_consume_state.generated_block_consume_liquids_bridge_state(stacks) and bool(liquids_bridge.get("matches", false)),
		"power_bridge_matches": power_bridge == source_block_consume_state.generated_block_consume_power_bridge_state(4.0) and bool(power_bridge.get("matches", false)),
		"power_cond_bridge_matches": power_cond_bridge == source_block_consume_state.generated_block_consume_power_cond_bridge_state(2.0, "condition") and bool(power_cond_bridge.get("matches", false)),
		"power_dynamic_bridge_matches": power_dynamic_bridge == source_block_consume_state.generated_block_consume_power_dynamic_bridge_state("usage") and bool(power_dynamic_bridge.get("matches", false)),
		"power_dynamic_displayed_bridge_matches": power_dynamic_displayed_bridge == source_block_consume_state.generated_block_consume_power_dynamic_displayed_bridge_state(9.0, "display-usage") and bool(power_dynamic_displayed_bridge.get("matches", false)),
		"power_buffered_bridge_matches": power_buffered_bridge == source_block_consume_state.generated_block_consume_power_buffered_bridge_state(20.0) and bool(power_buffered_bridge.get("matches", false)),
		"item_single_bridge_matches": item_single_bridge == source_block_consume_state.generated_block_consume_item_single_bridge_state(item) and bool(item_single_bridge.get("matches", false)),
		"item_amount_bridge_matches": item_amount_bridge == source_block_consume_state.generated_block_consume_item_amount_bridge_state(item, 5) and bool(item_amount_bridge.get("matches", false)),
		"items_varargs_bridge_matches": items_varargs_bridge == source_block_consume_state.generated_block_consume_items_varargs_bridge_state([item_stack]) and bool(items_varargs_bridge.get("matches", false)),
		"coolant_single_bridge_matches": coolant_single_bridge == source_block_consume_state.generated_block_consume_coolant_single_bridge_state(0.8) and bool(coolant_single_bridge.get("matches", false)),
		"coolant_filtered_bridge_matches": coolant_filtered_bridge == source_block_consume_state.generated_block_consume_coolant_filtered_bridge_state(0.9, true, false) and bool(coolant_filtered_bridge.get("matches", false)),
		"generic_bridge_matches": generic_bridge == source_block_consume_state.generated_block_consume_generic_bridge_state(consume, true, consume_builder_before, consume_builder_without_power, null) and bool(generic_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["liquid_bridge_matches"] and proof["liquids_bridge_matches"] and proof["power_bridge_matches"] and proof["power_cond_bridge_matches"] and proof["power_dynamic_bridge_matches"] and proof["power_dynamic_displayed_bridge_matches"] and proof["power_buffered_bridge_matches"] and proof["item_single_bridge_matches"] and proof["item_amount_bridge_matches"] and proof["items_varargs_bridge_matches"] and proof["coolant_single_bridge_matches"] and proof["coolant_filtered_bridge_matches"] and proof["generic_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_CONSUME_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockConsumeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
