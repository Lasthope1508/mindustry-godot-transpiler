extends Node

const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var angle_dist := source_math_state.source_angles_angle_dist(10.0, 350.0)
	var move_toward_value := source_math_state.source_angles_move_toward(350.0, 10.0, 15.0)
	var vec2_angle := source_math_state.source_vec2_angle(0.0, -1.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceMathState",
		"angle_dist_matches": angle_dist == -20.0,
		"move_toward_matches": move_toward_value == 5.0,
		"vec2_angle_matches": vec2_angle == source_math_defaults.FULL_CIRCLE_DEGREES - 90.0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["angle_dist_matches"] and proof["move_toward_matches"] and proof["vec2_angle_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("SOURCE_MATH_ANGLE_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
