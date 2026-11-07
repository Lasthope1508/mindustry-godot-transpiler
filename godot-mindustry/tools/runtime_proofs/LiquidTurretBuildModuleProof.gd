extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_liquid_turret_build_state := preload("res://src/game/SourceLiquidTurretBuildState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var was_shooting := true
	var enabled := false
	var liquids_null := false
	var current_amount := 2.5
	var current_liquid := "liquid-water"
	var liquid_capacity := 6.0
	var sensor := "currentAmmoType"
	var super_sense_object_value := "super-sense"
	var extinguish := true
	var current_liquid_can_extinguish := true
	var fire_result := "fire-target"
	var cheating := false
	var ammo_type := "liquid-water"
	var ammo_multiplier := 2.0
	var current_liquid_for_peek := "liquid-water"
	var current_liquid_for_has_ammo := "liquid-water"
	var current_amount_for_has_ammo := 1.5
	var source_building := "source-building"
	var item := "copper"
	var current_liquid_ammo_type_present := true
	var current_liquid_amount := 0.75
	var current_ammo_multiplier := 2.0
	var active_sound_bridge := game.generated_liquid_turret_build_should_active_sound_bridge_state(was_shooting, enabled)
	var ammo_content_bridge := game.generated_liquid_turret_build_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid)
	var ammo_fraction_bridge := game.generated_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount, liquid_capacity)
	var sense_object_bridge := game.generated_liquid_turret_build_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value)
	var find_target_bridge := game.generated_liquid_turret_build_find_target_extinguish_bridge_state(extinguish, current_liquid_can_extinguish, fire_result)
	var use_ammo_bridge := game.generated_liquid_turret_build_use_ammo_bridge_state(cheating, current_liquid_for_peek, ammo_type, ammo_multiplier)
	var peek_ammo_bridge := game.generated_liquid_turret_build_peek_ammo_bridge_state(current_liquid_for_peek, ammo_type)
	var has_ammo_bridge := game.generated_liquid_turret_build_has_ammo_bridge_state(current_liquid_for_has_ammo, ammo_type, current_amount_for_has_ammo, ammo_multiplier)
	var accept_item_bridge := game.generated_liquid_turret_build_accept_item_bridge_state(source_building, item)
	var accept_liquid_bridge := game.generated_liquid_turret_build_accept_liquid_bridge_state(source_building, current_liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "LIQUID_TURRET_BUILD_MODULE_PROOF",
		"active_sound_bridge": active_sound_bridge,
		"ammo_content_bridge": ammo_content_bridge,
		"ammo_fraction_bridge": ammo_fraction_bridge,
		"sense_object_bridge": sense_object_bridge,
		"find_target_bridge": find_target_bridge,
		"use_ammo_bridge": use_ammo_bridge,
		"peek_ammo_bridge": peek_ammo_bridge,
		"has_ammo_bridge": has_ammo_bridge,
		"accept_item_bridge": accept_item_bridge,
		"accept_liquid_bridge": accept_liquid_bridge,
		"active_sound_bridge_matches": active_sound_bridge == source_liquid_turret_build_state.generated_should_active_sound_bridge_state(was_shooting, enabled),
		"ammo_content_bridge_matches": ammo_content_bridge == source_liquid_turret_build_state.generated_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid),
		"ammo_fraction_bridge_matches": ammo_fraction_bridge == source_liquid_turret_build_state.generated_get_ammo_fraction_bridge_state(current_amount, liquid_capacity),
		"sense_object_bridge_matches": sense_object_bridge == source_liquid_turret_build_state.generated_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value),
		"find_target_bridge_matches": find_target_bridge == source_liquid_turret_build_state.generated_find_target_extinguish_bridge_state(extinguish, current_liquid_can_extinguish, fire_result),
		"use_ammo_bridge_matches": use_ammo_bridge == source_liquid_turret_build_state.generated_use_ammo_bridge_state(cheating, current_liquid_for_peek, ammo_type, ammo_multiplier),
		"peek_ammo_bridge_matches": peek_ammo_bridge == source_liquid_turret_build_state.generated_peek_ammo_bridge_state(current_liquid_for_peek, ammo_type),
		"has_ammo_bridge_matches": has_ammo_bridge == source_liquid_turret_build_state.generated_has_ammo_bridge_state(current_liquid_for_has_ammo, ammo_type, current_amount_for_has_ammo, ammo_multiplier),
		"accept_item_bridge_matches": accept_item_bridge == source_liquid_turret_build_state.generated_accept_item_bridge_state(source_building, item),
		"accept_liquid_bridge_matches": accept_liquid_bridge == source_liquid_turret_build_state.generated_accept_liquid_bridge_state(source_building, current_liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(active_sound_bridge.get("matches", false)) and bool(ammo_content_bridge.get("matches", false)) and bool(ammo_fraction_bridge.get("matches", false)) and bool(sense_object_bridge.get("matches", false)) and bool(find_target_bridge.get("matches", false)) and bool(use_ammo_bridge.get("matches", false)) and bool(peek_ammo_bridge.get("matches", false)) and bool(has_ammo_bridge.get("matches", false)) and bool(accept_item_bridge.get("matches", false)) and bool(accept_liquid_bridge.get("matches", false)) and proof["active_sound_bridge_matches"] and proof["ammo_content_bridge_matches"] and proof["ammo_fraction_bridge_matches"] and proof["sense_object_bridge_matches"] and proof["find_target_bridge_matches"] and proof["use_ammo_bridge_matches"] and proof["peek_ammo_bridge_matches"] and proof["has_ammo_bridge_matches"] and proof["accept_item_bridge_matches"] and proof["accept_liquid_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("LIQUID_TURRET_BUILD_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("LiquidTurretBuildModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

