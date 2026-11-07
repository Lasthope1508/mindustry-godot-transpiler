extends Node

const main_scene := preload("res://scenes/Main.tscn")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the bridge ignores a stale game-global item id and uses the dominant item. ---
	game.set("drill_output_item_id", "titanium")
	var state: Dictionary = game.source_drill_runtime_state(1.0)
	proof["drill_bridge_dominant_active"] = state.get("drill_active") == true
	proof["drill_bridge_dominant_delay"] = is_equal_approx(float(state.get("drill_delay", 0.0)), 650.0)
	proof["drill_bridge_dominant_not_global"] = float(state.get("drill_delay", 0.0)) != 750.0
	proof["drill_bridge_dominant_global_untouched"] = game.get("drill_output_item_id") == "titanium"

	# --- the delay matches the copper delay computed directly. ---
	var copper_delay: float = game.source_drill_delay("mechanical-drill", "copper")
	var titanium_delay: float = game.source_drill_delay("mechanical-drill", "titanium")
	proof["drill_bridge_dominant_copper_delay"] = is_equal_approx(copper_delay, 650.0) and is_equal_approx(titanium_delay, 750.0) and is_equal_approx(float(state.get("drill_delay", 0.0)), copper_delay)

	# --- with the global set back to the dominant item, the delay is the same. ---
	game.set("drill_output_item_id", "copper")
	var state_copper: Dictionary = game.source_drill_runtime_state(1.0)
	proof["drill_bridge_dominant_same"] = is_equal_approx(float(state_copper.get("drill_delay", 0.0)), float(state.get("drill_delay", 0.0)))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillBridgeDominantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
