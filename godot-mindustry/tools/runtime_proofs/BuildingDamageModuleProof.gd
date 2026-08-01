extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_building_damage_state := preload("res://src/game/SourceBuildingDamageState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var damage_amount := 7.5
	var current_health := 50.0
	var bullet_building_damage := 11.0
	var block_armor := 2.0
	var bullet_pierce_armor := false
	var bullet_armor_multiplier := 1.5
	var bullet_block_armor_multiplier := 1.25
	var source_team := "team-blue"
	var dead_state := false
	var source_time := 12.0
	var net_client := false
	var handled_damage := 3.0
	var self_state := {"id": 1}
	var handle_damage := game.source_building_handle_damage_state(damage_amount)
	var collision_damage := game.source_building_collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)
	var damage_delegate := game.source_building_damage_delegate_state(source_team, damage_amount)
	var bullet_damage := game.source_building_bullet_damage_state("bullet", source_team, damage_amount)
	var dead_guard := game.source_building_damage_dead_guard_state(dead_state)
	var block_health_scale := game.source_building_damage_block_health_scale_state(damage_amount, current_health, block_armor, source_time)
	var handle_damage_gate := game.source_building_damage_handle_damage_gate_state(net_client, current_health, damage_amount, handled_damage)
	var health_changed_call := game.source_building_damage_health_changed_call_state()
	var destroy_gate := game.source_building_damage_destroy_gate_state(current_health - 55.0, self_state)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_DAMAGE_MODULE_PROOF",
		"handle_damage": handle_damage,
		"collision_damage": collision_damage,
		"damage_delegate": damage_delegate,
		"bullet_damage": bullet_damage,
		"dead_guard": dead_guard,
		"block_health_scale": block_health_scale,
		"handle_damage_gate": handle_damage_gate,
		"health_changed_call": health_changed_call,
		"destroy_gate": destroy_gate,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = handle_damage == source_building_damage_state.handle_damage_state(damage_amount) and collision_damage == source_building_damage_state.collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier) and damage_delegate == source_building_damage_state.damage_delegate_state(source_team, damage_amount) and bullet_damage == source_building_damage_state.bullet_damage_state("bullet", source_team, damage_amount) and dead_guard == source_building_damage_state.dead_guard_state(dead_state) and block_health_scale == source_building_damage_state.block_health_scale_state(damage_amount, current_health, block_armor, source_time) and handle_damage_gate == source_building_damage_state.handle_damage_gate_state(net_client, current_health, damage_amount, handled_damage) and health_changed_call == source_building_damage_state.health_changed_call_state() and destroy_gate == source_building_damage_state.destroy_gate_state(current_health - 55.0, self_state) and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_label := get_node_or_null("ProofCanvas/ProofLabel") as Label
	if proof_label != null:
		proof_label.text = "BUILDING_DAMAGE_MODULE_PROOF matches=%s registry_valid=%s" % [str(proof["matches"]), str(proof["registry_valid"])]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_DAMAGE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingDamageModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
		proof_file.close()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
