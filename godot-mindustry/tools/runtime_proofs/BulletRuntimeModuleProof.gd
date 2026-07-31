extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	game.bullets = []
	game.bullet_hit_count = 0
	var spawn_state := source_bullet_runtime_state.spawn_state({"damage": 1.0, "speed": 1.0, "sprite": "bullet"}, 0.0, Vector2(5, 7))
	var runtime_context := source_bullet_runtime_state.target_step_context(game, {"sprite": null, "target": null, "velocity": Vector2.ZERO, "damage": 1.0, "hitSize": 4.0, "lifetime_remaining": 1.0}, 0.1)
	var target_step_from_context := source_bullet_runtime_state.target_step_from_context(runtime_context)
	var target_step_state := source_bullet_runtime_state.target_step_state(Vector2.ZERO, Vector2.ZERO, 0.1, Vector2.ZERO, 1.0, 4.0, 1.0, 1.0)
	var runtime_step := source_bullet_runtime_state.runtime_step_from_context(runtime_context)
	var runtime_hit_application := source_bullet_runtime_state.runtime_hit_application_state(runtime_context, runtime_step, 0)
	var angle_helper_matches := source_bullet_runtime.arc_angles_angle_dist(10.0, 350.0) == 20.0 and source_bullet_runtime.arc_angles_move_toward(10.0, 30.0, 5.0) == 15.0
	var impact_type_state := {"impact": true, "knockback": -1.0}
	var impact_bullet_state := {"rotation": 0.0, "x": 0.0, "y": 0.0}
	var impact_entity_state := {"isUnit": true, "x": 1.0, "y": 0.0}
	var impact_state := source_bullet_runtime.hit_entity_unit_effects_state(impact_type_state, impact_bullet_state, impact_entity_state, {})
	var impact_expected := source_bullet_runtime.arc_angles_trns_vec(source_math_defaults.HALF_CIRCLE_DEGREES, 80.0, 0.0)
	var impact_half_circle_matches := absf(float(impact_state.get("impulseVector", {}).get("x", 0.0)) - float(impact_expected.get("x", 0.0))) < 0.001 and absf(float(impact_state.get("impulseVector", {}).get("y", 0.0)) - float(impact_expected.get("y", 0.0))) < 0.001
	var circle_shooter_rotation_offset_degrees := source_math_defaults.QUARTER_CIRCLE_DEGREES
	var texture_path := source_bullet_runtime_state.texture_path("bullet")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BULLET_RUNTIME_MODULE_PROOF",
		"spawn_state": spawn_state,
		"runtime_step_matches": bool(runtime_step.get("next_position", Vector2.ZERO) == Vector2.ZERO),
		"target_context_matches": bool(runtime_context.has("target_position")),
		"target_step_from_context_matches": bool(target_step_from_context.has("next_position")),
		"target_step_state_matches": bool(target_step_state.has("next_position")),
		"runtime_hit_application_matches": bool(runtime_hit_application.has("hit_count")),
		"angle_helper_matches": angle_helper_matches,
		"impact_half_circle_matches": impact_half_circle_matches,
		"circle_shooter_rotation_offset_degrees": circle_shooter_rotation_offset_degrees,
		"texture_path": texture_path,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["runtime_step_matches"] and proof["target_context_matches"] and proof["target_step_from_context_matches"] and proof["target_step_state_matches"] and proof["runtime_hit_application_matches"] and proof["angle_helper_matches"] and proof["impact_half_circle_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BULLET_RUNTIME_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BulletRuntimeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.close()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
