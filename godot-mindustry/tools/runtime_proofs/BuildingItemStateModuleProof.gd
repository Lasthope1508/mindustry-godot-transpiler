extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const generated_building_comp_script := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var generated_building_comp := generated_building_comp_script.new()
	var move_forward_game := PortGameScript.new()
	var move_forward_module_game := PortGameScript.new()
	var accept_wrapper := game.source_move_forward_accept_state(true, true, true)
	var accept_module := source_building_item_state.move_forward_accept_state(true, true, true)
	var move_forward_wrapper := move_forward_game.source_move_forward_to_core("copper")
	var move_forward_module := source_building_item_state.move_forward_to_core_runtime_state(move_forward_module_game, "copper", true, true)
	var generated_move_forward: Variant = generated_building_comp_script.new().java_method_moveForward_112([true, true, true])
	var stack_wrapper := game.source_building_accept_stack_state(true, true, true, 7, 4, 3)
	var stack_module := source_building_item_state.accept_stack_state(true, true, true, 7, 4, 3)
	var item := {"kind": "copper"}
	var generated_accept_stack: Variant = generated_building_comp.java_method_acceptStack_77([item, 3, {}, true, true, true, 7, 4])
	var generated_maximum_accepted: Variant = generated_building_comp.java_method_getMaximumAccepted_78([item, 7])
	var generated_remove_stack: Variant = generated_building_comp.java_method_removeStack_79([item, 3, true, 4])
	var generated_handle_stack: Variant = generated_building_comp.java_method_handleStack_80([item, 3, {}, 4])
	var generated_handle_item: Variant = generated_building_comp.java_method_handleItem_87([{}, item, 4])
	var generated_accept_item: Variant = generated_building_comp.java_method_acceptItem_88([{}, item, true, 4, 7])
	var generated_item_contracts_match: bool = generated_accept_stack == source_building_item_state.accept_stack_state(true, true, true, 7, 4, 3) \
		and generated_maximum_accepted == source_building_item_state.maximum_accepted(7) \
		and generated_remove_stack == source_building_item_state.remove_stack_state(true, 4, 3) \
		and generated_handle_stack == source_building_item_state.handle_stack_count(4, 3) \
		and generated_handle_item == source_building_item_state.handle_item_count(4) \
		and generated_accept_item == source_building_item_state.accept_item_state(true, 4, 7)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_ITEM_STATE_MODULE_PROOF",
		"move_forward_accept_matches": accept_wrapper == accept_module,
		"move_forward_to_core_matches": move_forward_wrapper == move_forward_module,
		"generated_move_forward_matches": bool(generated_move_forward.get("return_value", false)) and generated_move_forward.get("source_owner", "") == "port_game.source_building_move_forward_state",
		"stack_matches": stack_wrapper == stack_module,
		"generated_item_contracts_match": generated_item_contracts_match,
		"module_matches": accept_wrapper == accept_module and move_forward_wrapper == move_forward_module and stack_wrapper == stack_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["generated_move_forward_matches"] and proof["generated_item_contracts_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_ITEM_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingItemStateModuleProof", proof)
	game.free()
	move_forward_game.free()
	move_forward_module_game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
