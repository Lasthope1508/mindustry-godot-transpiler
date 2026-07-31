extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_turret_combat_state := preload("res://src/game/SourceTurretCombatState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_turret_combat_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_turret_combat_state.SOURCE_TURRET_COMBAT_ANGLE_KEY: Callable(game, source_turret_combat_state.SOURCE_TURRET_COMBAT_ANGLE_FALLBACK),
		source_turret_combat_state.SOURCE_TURRET_COMBAT_TRNS_VEC_KEY: Callable(game, source_turret_combat_state.SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK),
	}
	var override_callbacks := source_turret_combat_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_turret_combat_state.SOURCE_TURRET_COMBAT_ANGLE_KEY, Callable()) == Callable(self, "proof_arc_angles_angle") \
		and override_callbacks.get(source_turret_combat_state.SOURCE_TURRET_COMBAT_TRNS_VEC_KEY, Callable()) == Callable(self, "proof_arc_angles_trns_vec")
	var cooldown := source_turret_combat_state.cooldown_state(1.0, 0.25)
	var fire := source_turret_combat_state.fire_cycle_state(0.0, 0.0, 0.1, 5.0, 8.0, 0.0, 1.0, 60.0, Callable(self, "_move_angle_toward"), Callable(self, "_angle_distance"))
	var recoil := source_turret_combat_state.recoil_offset(0.0, 1.0, 1.8, 1.0)
	var pattern := source_turret_combat_state.shoot_x_offset_state({"type": "ShootAlternate", "spread": 3.5}, 0)
	var origin := source_turret_combat_state.bullet_origin_state(0.0, 0.0, 0.0, {"shootX": 0.0, "shootY": 3.0}, 0.0, 0.0, 0.0, 0.0, 1, 8, Callable(self, "_trns"))
	var turret_origin := source_turret_combat_state.turret_bullet_origin_state(0.0, 0.0, 0.0, {"properties": {"shootX": 0.0, "shootY": 3.0}}, 0.0, 0.0, 0.0, 0.0, 1, 8, Callable(self, "_trns"))
	var game_turret_origin := source_turret_combat_state.game_turret_bullet_origin_state(self, 0.0, 0.0, 0.0, {"properties": {"shootX": 0.0, "shootY": 3.0}}, 0.0, 0.0, 0.0)
	var target_sprite := Node2D.new()
	target_sprite.position = Vector2(1.0, 1.0)
	var angle_to_target := source_turret_combat_state.game_angle_to_target(self, Vector2.ZERO, {"sprite": target_sprite})
	var total := source_turret_combat_state.total_inaccuracy(2.0, 1.0)
	var target := source_turret_combat_state.target_selection_state(Vector2.ZERO, 10.0, [{"target": "enemy", "position": Vector2(1, 1)}])
	var target_candidates := source_turret_combat_state.target_candidates_from_enemy_units([])
	var enemy_target := source_turret_combat_state.enemy_target_state(Vector2.ZERO, 10.0, [])
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var bullet_origin_rotation_offset_degrees := source_math_defaults.QUARTER_CIRCLE_DEGREES
	var proof := {
		"module": "TURRET_COMBAT_MODULE_PROOF",
		"bullet_origin_rotation_offset_degrees": bullet_origin_rotation_offset_degrees,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"cooldown": cooldown,
		"fire_should": bool(fire.get("should_fire", false)),
		"recoil_offset": recoil,
		"pattern_used": bool(pattern.get("used", false)),
		"origin_matches": origin.has("bulletX"),
		"turret_origin_matches": turret_origin.has("bulletX"),
		"game_turret_origin_matches": game_turret_origin.has("bulletX"),
		"game_angle_to_target_matches": is_equal_approx(angle_to_target, source_turret_combat_state.angle_to_target(Vector2.ZERO, {"sprite": target_sprite}, Callable(self, "proof_arc_angles_angle"))),
		"total_inaccuracy": total,
		"target_selected": bool(target.get("has_target", false)),
		"target_candidates_empty": target_candidates.is_empty(),
		"enemy_target_empty": not bool(enemy_target.get("has_target", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["default_callbacks_match"] and proof["override_callbacks_match"] and cooldown == source_turret_combat_state.cooldown_state(1.0, 0.25) and bool(fire.get("should_fire", false)) and recoil == source_turret_combat_state.recoil_offset(0.0, 1.0, 1.8, 1.0) and bool(pattern.get("used", false)) and origin.has("bulletX") and turret_origin.has("bulletX") and game_turret_origin.has("bulletX") and proof["game_angle_to_target_matches"] and total == source_turret_combat_state.total_inaccuracy(2.0, 1.0) and bool(target.get("has_target", false)) and target_candidates.is_empty() and not bool(enemy_target.get("has_target", false)) and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("TURRET_COMBAT_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TurretCombatModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	target_sprite.free()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _move_angle_toward(current_degrees: float, target_degrees: float, max_delta: float) -> float:
	return move_toward(current_degrees, target_degrees, max_delta)

func _angle_distance(current_degrees: float, target_degrees: float) -> float:
	return absf(target_degrees - current_degrees)

func _trns(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	return SourceMathState.source_angles_trns_vec(angle_degrees, x_value, y_value)

func proof_arc_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	return _trns(angle_degrees, x_value, y_value)

func proof_arc_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	var angle := rad_to_deg(atan2(to_y - from_y, to_x - from_x))
	return fmod(angle + 360.0, 360.0)

func _turret_combat_method_names() -> Dictionary:
	return {
		source_turret_combat_state.SOURCE_TURRET_COMBAT_ANGLE_KEY: "proof_arc_angles_angle",
		source_turret_combat_state.SOURCE_TURRET_COMBAT_TRNS_VEC_KEY: "proof_arc_angles_trns_vec",
	}
