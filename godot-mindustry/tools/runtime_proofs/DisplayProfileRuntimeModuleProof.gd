extends Node

const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const display_profile_runtime_script := preload("res://src/game/DisplayProfileRuntime.gd")

func _ready() -> void:
	var runtime := display_profile_runtime_script.new(source_ssot_catalog)
	var loaded := runtime.load()
	runtime.sync_runtime_viewport_size(Vector2i(1920, 1080))
	runtime.sync_runtime_camera_zoom(Vector2(runtime.camera_initial_zoom, runtime.camera_initial_zoom))
	var summary: Dictionary = runtime.runtime_summary()
	var background_cells := runtime.background_cells()
	var background_size := runtime.background_size()
	var expected_background_count := int(summary.get("background_width_tiles", 0)) * int(summary.get("background_height_tiles", 0))
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "DisplayProfileRuntime",
		"profile_loaded": loaded,
		"viewport_width": int(summary.get("viewport_width", 0)),
		"viewport_height": int(summary.get("viewport_height", 0)),
		"world_width_tiles": int(summary.get("world_width_tiles", 0)),
		"world_height_tiles": int(summary.get("world_height_tiles", 0)),
		"background_width_tiles": int(summary.get("background_width_tiles", 0)),
		"background_height_tiles": int(summary.get("background_height_tiles", 0)),
		"background_cell_count": background_cells.size(),
		"background_cell_count_matches": background_cells.size() == expected_background_count,
		"background_size_matches": background_size == Vector2i(int(summary.get("background_width_tiles", 0)), int(summary.get("background_height_tiles", 0))),
		"background_negative_min_cell": not background_cells.is_empty() and background_cells[0].x < 0 and background_cells[0].y < 0,
		"covers_visible_world": bool(summary.get("covers_visible_world", false)),
		"background_covers_camera_clamp_bounds": bool(summary.get("background_covers_camera_clamp_bounds", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["profile_loaded"] and proof["background_cell_count_matches"] and proof["background_size_matches"] and proof["background_negative_min_cell"] and proof["covers_visible_world"] and proof["background_covers_camera_clamp_bounds"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("DISPLAY_PROFILE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/DisplayProfileRuntimeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
