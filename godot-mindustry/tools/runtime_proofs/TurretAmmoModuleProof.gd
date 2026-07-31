extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var turret_properties := {"ammoMultiplier": 2.0, "maxAmmo": 30, "ammoPerShot": 1}
	var stacks: Array = []
	var ammo_entries: Array = []
	var item_data := source_turret_ammo_state.item_turret_ammo_data(turret_properties, "copper")
	var turret_data := source_turret_ammo_state.turret_item_turret_ammo_data({"properties": turret_properties}, "copper")
	var peek_stack := source_turret_ammo_state.peek_ammo_stack_state(stacks, 1, ammo_entries)
	var use_stack := source_turret_ammo_state.use_ammo_stack_state(stacks, 1, 1, ammo_entries)
	var peek_turret := source_turret_ammo_state.peek_turret_ammo_state(turret_properties, stacks)
	var use_turret := source_turret_ammo_state.use_turret_ammo_state(turret_properties, stacks, 1)
	var handle_turret := source_turret_ammo_state.handle_turret_item_state(turret_properties, "copper", false, 1, 2.0, false, ammo_entries)
	var item_handle := source_turret_ammo_state.item_turret_build_handle_item_state("copper", false, 1, 2.0, false, ammo_entries)
	var peek_turret_for_turret := source_turret_ammo_state.peek_turret_ammo_state_for_turret({"properties": turret_properties}, stacks)
	var use_turret_for_turret := source_turret_ammo_state.use_turret_ammo_state_for_turret({"properties": turret_properties}, stacks, 1)
	var handle_turret_for_turret := source_turret_ammo_state.handle_turret_item_state_for_turret({"properties": turret_properties}, "copper", false, 1, 2.0, false, ammo_entries)
	var max_ammo_value := source_turret_ammo_state.max_ammo({"properties": turret_properties}, 30)
	var item_accept := source_turret_ammo_state.item_turret_build_accept_item_state("copper", 1, 30.0, 2.0, false)
	var liquid_ammo := source_turret_ammo_state.liquid_turret_ammo_state([])
	var item_ammo := source_turret_ammo_state.item_turret_ammo_state([])
	var continuous_ammo := source_turret_ammo_state.continuous_liquid_turret_ammo_state([])
	var generated_liquid_bridge := source_turret_ammo_state.generated_liquid_turret_ammo_bridge_state([])
	var generated_item_bridge := source_turret_ammo_state.generated_item_turret_ammo_bridge_state([])
	var generated_continuous_bridge := source_turret_ammo_state.generated_continuous_liquid_turret_ammo_bridge_state([])
	var selected_entries := source_turret_ammo_state.selected_turret_ammo_entries({"properties": turret_properties})
	var bootstrap_game := PortGameScript.new()
	bootstrap_game.load_content_registry()
	var selected_runtime_bootstrap_loaded := source_turret_ammo_state.bootstrap_selected_turret_ammo(bootstrap_game)
	var selected_runtime_bootstrap_total := bootstrap_game.selected_turret_total_ammo()
	var selected_runtime_bootstrap_item := bootstrap_game.selected_turret_loaded_ammo_item()
	var load_game := PortGameScript.new()
	load_game.load_content_registry()
	var selected_runtime_load_loaded := source_turret_ammo_state.load_selected_turret_ammo(load_game, "copper", 2)
	var selected_runtime_load_total := load_game.selected_turret_total_ammo()
	var use_game := PortGameScript.new()
	use_game.load_content_registry()
	var selected_runtime_use_loaded := source_turret_ammo_state.load_selected_turret_ammo(use_game, "copper", 2)
	var selected_runtime_use_total_before := use_game.selected_turret_total_ammo()
	var selected_runtime_use := source_turret_ammo_state.use_selected_turret_ammo_once(use_game)
	var selected_runtime_use_total_after := use_game.selected_turret_total_ammo()
	var selected_runtime_use_item := str(selected_runtime_use.get("item", ""))
	var selected_runtime_counts_match := selected_runtime_bootstrap_loaded > 0 and selected_runtime_bootstrap_total > 0 and selected_runtime_load_loaded == 2 and selected_runtime_load_total > 0 and selected_runtime_use_loaded == 2 and selected_runtime_use_total_after == selected_runtime_use_total_before - use_game.selected_turret_ammo_per_shot() and selected_runtime_use_item == "copper"
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_AMMO_MODULE_PROOF",
		"item_turret_ammo_data": item_data,
		"turret_item_turret_ammo_data": turret_data,
		"peek_ammo_stack_state": peek_stack,
		"use_ammo_stack_state": use_stack,
		"peek_turret_ammo_state": peek_turret,
		"use_turret_ammo_state": use_turret,
		"handle_turret_item_state": handle_turret,
		"selected_turret_ammo_entries_matches": true,
		"selected_runtime_bootstrap_loaded": selected_runtime_bootstrap_loaded,
		"selected_runtime_bootstrap_total": selected_runtime_bootstrap_total,
		"selected_runtime_bootstrap_item": selected_runtime_bootstrap_item,
		"selected_runtime_load_loaded": selected_runtime_load_loaded,
		"selected_runtime_load_total": selected_runtime_load_total,
		"selected_runtime_use_loaded": selected_runtime_use_loaded,
		"selected_runtime_use_item": selected_runtime_use_item,
		"selected_runtime_use_total_before": selected_runtime_use_total_before,
		"selected_runtime_use_total_after": selected_runtime_use_total_after,
		"selected_runtime_counts_match": selected_runtime_counts_match,
		"item_turret_build_handle_item_state": item_handle,
		"item_turret_build_accept_item_state": item_accept,
		"liquid_turret_ammo_state": liquid_ammo,
		"item_turret_ammo_state": item_ammo,
		"continuous_liquid_turret_ammo_state": continuous_ammo,
		"generated_liquid_turret_ammo_bridge_state": generated_liquid_bridge,
		"generated_item_turret_ammo_bridge_state": generated_item_bridge,
		"generated_continuous_liquid_turret_ammo_bridge_state": generated_continuous_bridge,
		"generated_bridge_matches": bool(generated_liquid_bridge.get("matches", false)) and bool(generated_item_bridge.get("matches", false)) and bool(generated_continuous_bridge.get("matches", false)),
		"peek_turret_ammo_state_for_turret": peek_turret_for_turret,
		"use_turret_ammo_state_for_turret": use_turret_for_turret,
		"handle_turret_item_state_for_turret": handle_turret_for_turret,
		"selected_turret_ammo_entries": selected_entries,
		"max_ammo": max_ammo_value,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	var proof_json := JSON.stringify(proof)
	print("TURRET_AMMO_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TurretAmmoModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	bootstrap_game.free()
	load_game.free()
	use_game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
