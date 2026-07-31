extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_turret_init_state_script := preload("res://src/game/SourceTurretInitState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var shoot_y := 3.0
	var shoot_y_is_negative_infinity := true
	var size := 2.0
	var source_tilesize := 8.0
	var elevation := -1.0
	var recoil_time := -1.0
	var reload := 12.0
	var cooldown_time := -1.0
	var new_target_interval := -1.0
	var target_interval := 18.0
	var target_ground := false
	var disable_overlap_check := false
	var range_value := 80.0
	var tracking_range := 60.0
	var coolant_present := false
	var found_consume_coolant := true
	var place_overlap_range := 20.0
	var place_overlap_margin := 56.0
	var fog_radius_multiplier := 1.0
	var fog_radius := 4
	var has_consumer := false
	var source_turret_init_state := game.source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)
	var generated_turret_init_bridge_state := game.generated_turret_init_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)
	var generated_turret_init_source_tilesize_default_bridge_state := game.generated_turret_init_source_tilesize_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size)
	var generated_turret_init_size_default_bridge_state := game.generated_turret_init_size_default_bridge_state(shoot_y, shoot_y_is_negative_infinity)
	var generated_turret_init_disable_overlap_check_default_bridge_state := game.generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground)
	var generated_turret_init_range_default_bridge_state := game.generated_turret_init_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check)
	var generated_turret_init_tracking_range_default_bridge_state := game.generated_turret_init_tracking_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value)
	var source_base_turret_init_state := game.source_base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)
	var generated_base_turret_init_bridge_state := game.generated_base_turret_init_bridge_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)
	var generated_base_turret_reinitialize_consumers_bridge_state := game.generated_base_turret_reinitialize_consumers_bridge_state()
	var source_base_turret_check_init_coolant_state := game.source_base_turret_check_init_coolant_state(coolant_present, has_consumer)
	var generated_base_turret_check_init_coolant_bridge_state := game.generated_base_turret_check_init_coolant_bridge_state(coolant_present, has_consumer)
	var proof := {
		"module": "SourceTurretInitState",
		"source_turret_init_matches": source_turret_init_state == source_turret_init_state_script.turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range),
		"turret_init_bridge_matches": generated_turret_init_bridge_state == source_turret_init_state_script.generated_turret_init_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range),
		"turret_init_source_tilesize_default_bridge_matches": generated_turret_init_source_tilesize_default_bridge_state == source_turret_init_state_script.generated_turret_init_source_tilesize_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size),
		"turret_init_size_default_bridge_matches": generated_turret_init_size_default_bridge_state == source_turret_init_state_script.generated_turret_init_size_default_bridge_state(shoot_y, shoot_y_is_negative_infinity),
		"turret_init_disable_overlap_check_default_bridge_matches": generated_turret_init_disable_overlap_check_default_bridge_state == source_turret_init_state_script.generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground),
		"turret_init_range_default_bridge_matches": generated_turret_init_range_default_bridge_state == source_turret_init_state_script.generated_turret_init_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check),
		"turret_init_tracking_range_default_bridge_matches": generated_turret_init_tracking_range_default_bridge_state == source_turret_init_state_script.generated_turret_init_tracking_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value),
		"source_base_turret_init_matches": source_base_turret_init_state == source_turret_init_state_script.base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius),
		"base_turret_init_bridge_matches": generated_base_turret_init_bridge_state == source_turret_init_state_script.generated_base_turret_init_bridge_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius),
		"base_turret_reinitialize_consumers_bridge_matches": generated_base_turret_reinitialize_consumers_bridge_state == source_turret_init_state_script.generated_base_turret_reinitialize_consumers_bridge_state(),
		"source_base_turret_check_init_coolant_matches": source_base_turret_check_init_coolant_state == source_turret_init_state_script.base_turret_check_init_coolant_state(coolant_present, has_consumer),
		"base_turret_check_init_coolant_bridge_matches": generated_base_turret_check_init_coolant_bridge_state == source_turret_init_state_script.generated_base_turret_check_init_coolant_bridge_state(coolant_present, has_consumer),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(generated_turret_init_bridge_state.get("matches", false)) and bool(generated_turret_init_source_tilesize_default_bridge_state.get("matches", false)) and bool(generated_turret_init_size_default_bridge_state.get("matches", false)) and bool(generated_turret_init_disable_overlap_check_default_bridge_state.get("matches", false)) and bool(generated_turret_init_range_default_bridge_state.get("matches", false)) and bool(generated_turret_init_tracking_range_default_bridge_state.get("matches", false)) and bool(generated_base_turret_init_bridge_state.get("matches", false)) and bool(generated_base_turret_reinitialize_consumers_bridge_state.get("matches", false)) and bool(generated_base_turret_check_init_coolant_bridge_state.get("matches", false)) and proof["source_turret_init_matches"] and proof["turret_init_bridge_matches"] and proof["turret_init_source_tilesize_default_bridge_matches"] and proof["turret_init_size_default_bridge_matches"] and proof["turret_init_disable_overlap_check_default_bridge_matches"] and proof["turret_init_range_default_bridge_matches"] and proof["turret_init_tracking_range_default_bridge_matches"] and proof["source_base_turret_init_matches"] and proof["base_turret_init_bridge_matches"] and proof["base_turret_reinitialize_consumers_bridge_matches"] and proof["source_base_turret_check_init_coolant_matches"] and proof["base_turret_check_init_coolant_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("TURRET_INIT_MODULE_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TurretInitModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
