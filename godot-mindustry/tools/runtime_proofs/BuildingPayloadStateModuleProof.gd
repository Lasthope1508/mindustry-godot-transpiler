extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_payload_state := preload("res://src/game/SourceBuildingPayloadState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const generated_building_comp_script := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")

func _building_payload_state_method_names() -> Dictionary:
	return {
		source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY: "_proof_increment_dump_cursor",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var building_comp := generated_building_comp_script.new()
	var callbacks := source_building_payload_state.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(game, source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	var override_callbacks := source_building_payload_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(self, "_proof_increment_dump_cursor")
	var wrapper := game.source_dump_payload_state(3, 0, [false, true, false])
	var module := source_building_payload_state.game_dump_payload_state(game, 3, 0, [false, true, false])
	var empty_wrapper := game.source_dump_payload_state(0, 2, [])
	var empty_module := source_building_payload_state.game_dump_payload_state(game, 0, 2, [])
	var payload_state := {"kind": "proof_payload"}
	var generated_accept_payload: Variant = building_comp.java_method_acceptPayload_82([{}, payload_state])
	var generated_handle_payload: Variant = building_comp.java_method_handlePayload_83([{}, payload_state])
	var generated_move_payload: Variant = building_comp.java_method_movePayload_84([payload_state, true, true, true, true])
	var generated_dump_payload: Variant = building_comp.java_method_dumpPayload_85([payload_state, 3, 0, [false, true, false]])
	var generated_get_payload: Variant = building_comp.java_method_getPayload_99([])
	var generated_take_payload: Variant = building_comp.java_method_takePayload_100([])
	var generated_get_payloads: Variant = building_comp.java_method_getPayloads_101([])
	var generated_contracts_match: bool = generated_accept_payload == source_building_payload_state.accept_payload_state() \
		and generated_handle_payload == source_building_payload_state.handle_payload_state(payload_state) \
		and generated_move_payload == source_building_payload_state.move_payload_state(true, true, true, true) \
		and generated_dump_payload == source_building_payload_state.dump_payload_state(3, 0, [false, true, false], Callable(source_building_item_dump_state, "increment_dump_cursor_state")) \
		and generated_get_payload == source_building_payload_state.get_payload_default_state() \
		and generated_take_payload == source_building_payload_state.take_payload_default_state() \
		and generated_get_payloads == source_building_payload_state.get_payloads_default_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingPayloadState",
		"matches": wrapper == module and empty_wrapper == empty_module,
		"module_matches": wrapper == module and empty_wrapper == empty_module,
		"game_dump_matches": wrapper == module and empty_wrapper == empty_module,
		"generated_contracts_match": generated_contracts_match,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["module_matches"] and proof["game_dump_matches"] and proof["generated_contracts_match"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_PAYLOAD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingPayloadStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _proof_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	return int((current_dump + 1) % proximity_size) if proximity_size > 0 else current_dump
