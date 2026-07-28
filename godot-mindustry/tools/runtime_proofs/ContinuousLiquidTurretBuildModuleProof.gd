extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")
const SourceContinuousLiquidTurretBuildState := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var was_shooting := true
	var enabled := true
	var liquids_null := false
	var current_amount := 3.5
	var current_liquid := "liquid-slag"
	var liquid_capacity := 10.0
	var liquid_consumed := 0.75
	var activated_before := false
	var sensor := "currentAmmoType"
	var super_sense_object_value := "super-sense"
	var has_correct_ammo := true
	var super_can_consume := true
	var super_should_consume := true
	var activated := true
	var peek_ammo := "ammo-liquid"
	var ammo_type := "ammo-liquid"
	var bullets_any := false
	var first_bullet_type := "ammo-liquid"
	var source_building := "source-building"
	var item := "copper"
	var current_liquid_ammo_type_present := true
	var current_liquid_amount := 1.5
	var current_ammo_multiplier := 2.0
	var active_sound_bridge := game.generated_continuous_liquid_turret_build_should_active_sound_bridge_state(was_shooting, enabled)
	var ammo_content_bridge := game.generated_continuous_liquid_turret_build_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid)
	var ammo_fraction_bridge := game.generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount, liquid_capacity)
	var update_tile_bridge := game.generated_continuous_liquid_turret_build_update_tile_bridge_state(current_amount, liquid_consumed, activated_before)
	var sense_object_bridge := game.generated_continuous_liquid_turret_build_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value)
	var can_consume_bridge := game.generated_continuous_liquid_turret_build_can_consume_bridge_state(has_correct_ammo, super_can_consume)
	var should_consume_bridge := game.generated_continuous_liquid_turret_build_should_consume_bridge_state(super_should_consume, activated)
	var use_ammo_bridge := game.generated_continuous_liquid_turret_build_use_ammo_bridge_state(peek_ammo)
	var peek_ammo_bridge := game.generated_continuous_liquid_turret_build_peek_ammo_bridge_state(current_liquid, ammo_type)
	var has_ammo_bridge := game.generated_continuous_liquid_turret_build_has_ammo_bridge_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)
	var has_correct_ammo_bridge := game.generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state(bullets_any, first_bullet_type, peek_ammo)
	var accept_item_bridge := game.generated_continuous_liquid_turret_build_accept_item_bridge_state(source_building, item)
	var accept_liquid_bridge := game.generated_continuous_liquid_turret_build_accept_liquid_bridge_state(source_building, current_liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "CONTINUOUS_LIQUID_TURRET_BUILD_MODULE_PROOF",
		"active_sound_bridge": active_sound_bridge,
		"ammo_content_bridge": ammo_content_bridge,
		"ammo_fraction_bridge": ammo_fraction_bridge,
		"update_tile_bridge": update_tile_bridge,
		"sense_object_bridge": sense_object_bridge,
		"can_consume_bridge": can_consume_bridge,
		"should_consume_bridge": should_consume_bridge,
		"use_ammo_bridge": use_ammo_bridge,
		"peek_ammo_bridge": peek_ammo_bridge,
		"has_ammo_bridge": has_ammo_bridge,
		"has_correct_ammo_bridge": has_correct_ammo_bridge,
		"accept_item_bridge": accept_item_bridge,
		"accept_liquid_bridge": accept_liquid_bridge,
		"active_sound_bridge_matches": active_sound_bridge == SourceContinuousLiquidTurretBuildState.generated_should_active_sound_bridge_state(was_shooting, enabled),
		"ammo_content_bridge_matches": ammo_content_bridge == SourceContinuousLiquidTurretBuildState.generated_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid),
		"ammo_fraction_bridge_matches": ammo_fraction_bridge == SourceContinuousLiquidTurretBuildState.generated_get_ammo_fraction_bridge_state(current_amount, liquid_capacity),
		"update_tile_bridge_matches": update_tile_bridge == SourceContinuousLiquidTurretBuildState.generated_update_tile_bridge_state(current_amount, liquid_consumed, activated_before),
		"sense_object_bridge_matches": sense_object_bridge == SourceContinuousLiquidTurretBuildState.generated_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value),
		"can_consume_bridge_matches": can_consume_bridge == SourceContinuousLiquidTurretBuildState.generated_can_consume_bridge_state(has_correct_ammo, super_can_consume),
		"should_consume_bridge_matches": should_consume_bridge == SourceContinuousLiquidTurretBuildState.generated_should_consume_bridge_state(super_should_consume, activated),
		"use_ammo_bridge_matches": use_ammo_bridge == SourceContinuousLiquidTurretBuildState.generated_use_ammo_bridge_state(peek_ammo),
		"peek_ammo_bridge_matches": peek_ammo_bridge == SourceContinuousLiquidTurretBuildState.generated_peek_ammo_bridge_state(current_liquid, ammo_type),
		"has_ammo_bridge_matches": has_ammo_bridge == SourceContinuousLiquidTurretBuildState.generated_has_ammo_bridge_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated),
		"has_correct_ammo_bridge_matches": has_correct_ammo_bridge == SourceContinuousLiquidTurretBuildState.generated_has_correct_ammo_bridge_state(bullets_any, first_bullet_type, peek_ammo),
		"accept_item_bridge_matches": accept_item_bridge == SourceContinuousLiquidTurretBuildState.generated_accept_item_bridge_state(source_building, item),
		"accept_liquid_bridge_matches": accept_liquid_bridge == SourceContinuousLiquidTurretBuildState.generated_accept_liquid_bridge_state(source_building, current_liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(active_sound_bridge.get("matches", false)) and bool(ammo_content_bridge.get("matches", false)) and bool(ammo_fraction_bridge.get("matches", false)) and bool(update_tile_bridge.get("matches", false)) and bool(sense_object_bridge.get("matches", false)) and bool(can_consume_bridge.get("matches", false)) and bool(should_consume_bridge.get("matches", false)) and bool(use_ammo_bridge.get("matches", false)) and bool(peek_ammo_bridge.get("matches", false)) and bool(has_ammo_bridge.get("matches", false)) and bool(has_correct_ammo_bridge.get("matches", false)) and bool(accept_item_bridge.get("matches", false)) and bool(accept_liquid_bridge.get("matches", false)) and proof["active_sound_bridge_matches"] and proof["ammo_content_bridge_matches"] and proof["ammo_fraction_bridge_matches"] and proof["update_tile_bridge_matches"] and proof["sense_object_bridge_matches"] and proof["can_consume_bridge_matches"] and proof["should_consume_bridge_matches"] and proof["use_ammo_bridge_matches"] and proof["peek_ammo_bridge_matches"] and proof["has_ammo_bridge_matches"] and proof["has_correct_ammo_bridge_matches"] and proof["accept_item_bridge_matches"] and proof["accept_liquid_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("CONTINUOUS_LIQUID_TURRET_BUILD_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretBuildModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
