extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_payload_state := preload("res://src/game/SourceBuildingPayloadState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _dependencies(events: Array, net_client: bool) -> Dictionary:
	var next_id := 90
	return {
		"unit_is_player": true,
		"net_client": net_client,
		"spawn_effect": func(unit: Variant) -> void: events.append({"effect": "spawn", "unit": unit}),
		"clear_unit": func(unit: Variant) -> void: events.append({"effect": "clear_unit", "unit": unit}),
		"remove_unit": func(unit: Variant) -> void: events.append({"effect": "remove", "unit": unit}),
		"next_id": func() -> int:
			next_id += 1
			return next_id,
		"assign_unit_id": func(unit: Variant, value: int) -> void: events.append({"effect": "assign_id", "unit": unit, "id": value}),
		"post_deferred": func(callback: Callable) -> void: events.append({"effect": "post_deferred", "callback": callback}),
		"unit_drop_effect": func(unit: Variant) -> void: events.append({"effect": "unit_drop", "unit": unit}),
	}


func _run_path(game: Object, net_client: bool) -> Dictionary:
	var events: Array = []
	var grabbed: Array = []
	var unit := {"id": 7, "kind": "proof_unit"}
	var result: Dictionary = game.generated_building_comp_handle_unit_payload_bridge_state(
		unit,
		func(payload: Variant) -> void: grabbed.append(payload),
		_dependencies(events, net_client)
	)
	if not net_client:
		var deferred: Callable = events.filter(func(event: Dictionary) -> bool: return event.get("effect", "") == "post_deferred")[0].get("callback", Callable())
		if deferred.is_valid():
			deferred.call()
	return {"bridge": result, "events": events, "grabbed": grabbed}


func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var client := _run_path(game, true)
	var server := _run_path(game, false)
	var proof := {
		"module": "BUILDING_UNIT_PAYLOAD_MODULE_PROOF",
		"client": client,
		"server": server,
		"client_matches": bool(client.get("bridge", {}).get("matches", false)),
		"server_matches": bool(server.get("bridge", {}).get("matches", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["client_matches"] and proof["server_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("BUILDING_UNIT_PAYLOAD_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingUnitPayloadModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
