extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_liquid_dump_state := preload("res://src/game/SourceBuildingLiquidDumpState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const generated_building_comp_script := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _building_liquid_state_method_names() -> Dictionary:
	return {
		source_building_liquid_dump_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY: "_proof_increment_dump_cursor",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var generated_building_comp := generated_building_comp_script.new()
	var callbacks := source_building_liquid_dump_state.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_building_liquid_dump_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(game, source_building_liquid_dump_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	var override_callbacks := source_building_liquid_dump_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_liquid_dump_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(self, "_proof_increment_dump_cursor")
	var wrapper = game.source_building_dump_liquid_routing_gate_state(
		"water",
		3,
		1,
		-1,
		0,
		[0, 1, 2],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		[true, true, false]
	)
	var module := source_building_liquid_dump_state.dump_liquid_routing_gate_state(
		"water",
		3,
		1,
		-1,
		0,
		[0, 1, 2],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		callbacks.get(source_building_liquid_dump_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)
	var wrapper_module := source_building_liquid_dump_state.game_dump_liquid_routing_gate_state(
		game,
		"water",
		3,
		1,
		-1,
		0,
		[0, 1, 2],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		[true, true, false]
	)
	var liquid := "water"
	var to_state := {"id": "proof-to"}
	var from_state := {"id": "proof-from"}
	var self_state := {"id": "proof-self"}
	var generated_accept_liquid: Variant = generated_building_comp.java_method_acceptLiquid_89([{}, liquid, true, true])
	var generated_handle_liquid: Variant = generated_building_comp.java_method_handleLiquid_90([{}, liquid, 3.5, 2.0])
	var dump_runtime_args := [
		9.0, false, true, true, 2, 1, 0,
		[0, 1], [true, true], [true, true], [true, true], [true, true],
		[1.0, 2.0], [10.0, 10.0], [true, true], 10.0,
	]
	var generated_dump_liquid_default: Variant = generated_building_comp.java_method_dumpLiquid_91([liquid] + dump_runtime_args)
	var generated_dump_liquid_scaling: Variant = generated_building_comp.java_method_dumpLiquid_92([liquid, 2.0] + dump_runtime_args)
	var generated_dump_liquid_output_dir: Variant = generated_building_comp.java_method_dumpLiquid_93([liquid, 2.0, -1] + dump_runtime_args)
	var expected_dump_liquid_default := source_building_liquid_state.dump_liquid_state(liquid, 2.0, -1, 9.0, false, true, true, 2, 1, 0, [0, 1], [true, true], [true, true], [true, true], [true, true], [1.0, 2.0], [10.0, 10.0], [true, true], 10.0, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var expected_dump_liquid_scaling := source_building_liquid_state.dump_liquid_state(liquid, 2.0, -1, 9.0, false, true, true, 2, 1, 0, [0, 1], [true, true], [true, true], [true, true], [true, true], [1.0, 2.0], [10.0, 10.0], [true, true], 10.0, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var expected_dump_liquid_output_dir := source_building_liquid_state.dump_liquid_state(liquid, 2.0, -1, 9.0, false, true, true, 2, 1, 0, [0, 1], [true, true], [true, true], [true, true], [true, true], [1.0, 2.0], [10.0, 10.0], [true, true], 10.0, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var generated_can_dump_liquid: Variant = generated_building_comp.java_method_canDumpLiquid_94([to_state, liquid])
	var generated_transfer_liquid: Variant = generated_building_comp.java_method_transferLiquid_95([{}, 4.0, liquid, 10.0, 7.0, true, 12.0])
	var generated_move_liquid_forward: Variant = generated_building_comp.java_method_moveLiquidForward_96([true, liquid, true, false, false, false, 9.0, 0.0])
	var generated_move_liquid: Variant = generated_building_comp.java_method_moveLiquid_97([{}, liquid, true, true, true, 9.0, 1.0, 10.0, 1.0, 10.0, true])
	var generated_get_liquid_destination: Variant = generated_building_comp.java_method_getLiquidDestination_98([from_state, liquid, self_state])
	var generated_liquid_contracts_match: bool = generated_accept_liquid == source_building_liquid_state.accept_liquid_state(true, true) \
		and generated_handle_liquid == source_building_liquid_state.handle_liquid_amount(2.0, 3.5) \
		and generated_dump_liquid_default == expected_dump_liquid_default \
		and generated_dump_liquid_scaling == expected_dump_liquid_scaling \
		and generated_dump_liquid_output_dir == expected_dump_liquid_output_dir \
		and generated_can_dump_liquid == source_building_liquid_state.can_dump_liquid_default_state(to_state, liquid) \
		and generated_transfer_liquid == source_building_liquid_state.transfer_liquid_state(liquid, 4.0, 10.0, 7.0, true, 12.0) \
		and generated_move_liquid_forward == source_building_liquid_state.move_liquid_forward_state(true, liquid, true, false, false, false, 9.0, 0.0) \
		and generated_move_liquid == source_building_liquid_state.move_liquid_state(liquid, true, true, true, 9.0, 1.0, 10.0, 1.0, 10.0, true) \
		and generated_get_liquid_destination == source_building_liquid_state.get_liquid_destination_default_state(from_state, liquid, self_state)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingLiquidState",
		"matches": wrapper == module,
		"module_matches": wrapper == module,
		"game_routing_matches": wrapper_module == module,
		"generated_liquid_contracts_match": generated_liquid_contracts_match,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["module_matches"] and proof["game_routing_matches"] and proof["generated_liquid_contracts_match"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_LIQUID_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingLiquidStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _proof_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	if proximity_size != 0:
		return (current_dump + 1) % proximity_size
	return current_dump
