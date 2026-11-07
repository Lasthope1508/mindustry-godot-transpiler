extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_puddles_deposit_state := preload("res://src/game/SourcePuddlesDepositState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var created := game.source_puddles_deposit_tile_liquid_state({"id": "tile-1"}, "water", 100.0)
	var solid := source_puddles_deposit_state.deposit_tile_liquid_state({"id": "tile-2"}, "water", 10.0, null, true)
	var same := source_puddles_deposit_state.deposit_tile_liquid_state({"id": "tile-3"}, "water", 12.0, {"liquid_id": "water", "amount": 4.0, "accepting": 3.0})
	var client := source_puddles_deposit_state.deposit_tile_liquid_state({"id": "tile-4"}, "water", 10.0, null, false, true)
	var fire := source_puddles_deposit_state.deposit_tile_liquid_state({"id": "tile-5"}, {"id": "hot-water", "temperature": 0.8}, 10.0, {"liquid_id": {"id": "oil", "flammability": 0.5, "temperature": 0.2}, "amount": 20.0}, false, false, 70.0, {"fireball_chance_passed": true})
	var cold := source_puddles_deposit_state.deposit_tile_liquid_state({"id": "tile-6"}, {"id": "cold-water", "temperature": 0.2}, 10.0, {"liquid_id": {"id": "hot-liquid", "flammability": 0.0, "temperature": 0.8}, "amount": 20.0}, false, false, 70.0, {"steam_chance_passed": true})
	var created_result: Dictionary = created.get("result", {})
	var solid_result: Dictionary = solid.get("result", {})
	var same_result: Dictionary = same.get("result", {})
	var client_result: Dictionary = client.get("result", {})
	var fire_result: Dictionary = fire.get("result", {})
	var cold_result: Dictionary = cold.get("result", {})
	var proof := {
		"module": "PUDDLES_DEPOSIT_MODULE_PROOF",
		"created_amount_capped": float(created_result.get("amount_after", -1.0)) == 70.0,
		"solid_blocked": not bool(solid_result.get("deposited", true)),
		"same_liquid_accepting_updated": float(same_result.get("puddle", {}).get("accepting", -1.0)) == 12.0,
		"client_creation_blocked": not bool(client_result.get("created", true)),
		"fire_reaction_completed": fire_result.get("reason", "") == "different_liquid_reaction" and fire_result.get("reaction", {}).get("fires_create_called", false) and fire_result.get("reaction", {}).get("fireball_create_called", false),
		"cold_hot_reaction_completed": cold_result.get("reaction", {}).get("reason", "") == "cold_on_hot" and cold_result.get("reaction", {}).get("steam_effect_called", false) and float(cold_result.get("amount_after", -1.0)) == 19.0,
		"source_owner_present": str(created.get("source_owner", "")) == "port_game.source_puddles_deposit_tile_liquid_state",
	}
	proof["matches"] = proof["created_amount_capped"] and proof["solid_blocked"] and proof["same_liquid_accepting_updated"] and proof["client_creation_blocked"] and proof["fire_reaction_completed"] and proof["cold_hot_reaction_completed"] and proof["source_owner_present"]
	runtime_proof_state.write_proof("PuddlesDepositModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
