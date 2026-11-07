extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const display_profile_runtime_script := preload("res://src/game/DisplayProfileRuntime.gd")

const RESPONSIVE_VIEWPORT_PROFILES := [
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(390, 844),
	Vector2i(844, 390),
]

func _ready() -> void:
	var runtime := display_profile_runtime_script.new(source_ssot_accessor_runtime_state)
	var loaded := runtime.load()
	runtime.sync_runtime_viewport_size(Vector2i(1920, 1080))
	runtime.sync_runtime_camera_zoom(Vector2(runtime.camera_initial_zoom, runtime.camera_initial_zoom))
	var summary: Dictionary = runtime.runtime_summary()
	var background_cells := runtime.background_cells()
	var background_size := runtime.background_size()
	var expected_background_count := int(summary.get("background_width_tiles", 0)) * int(summary.get("background_height_tiles", 0))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var responsive_viewport_results := []
	var all_responsive_viewports_cover_background := true
	for viewport_size in RESPONSIVE_VIEWPORT_PROFILES:
		var viewport_runtime := display_profile_runtime_script.new(source_ssot_accessor_runtime_state)
		var viewport_loaded := viewport_runtime.load()
		viewport_runtime.sync_runtime_viewport_size(viewport_size)
		viewport_runtime.sync_runtime_camera_zoom(Vector2(viewport_runtime.camera_initial_zoom, viewport_runtime.camera_initial_zoom))
		var viewport_summary: Dictionary = viewport_runtime.runtime_summary()
		var viewport_background_cells := viewport_runtime.background_cells()
		var viewport_background_count := int(viewport_summary.get("background_width_tiles", 0)) * int(viewport_summary.get("background_height_tiles", 0))
		var viewport_matches := (
			viewport_loaded
			and viewport_background_cells.size() == viewport_background_count
			and bool(viewport_summary.get("covers_visible_world", false))
			and bool(viewport_summary.get("background_covers_camera_clamp_bounds", false))
		)
		all_responsive_viewports_cover_background = all_responsive_viewports_cover_background and viewport_matches
		responsive_viewport_results.append({
			"viewport_width": viewport_size.x,
			"viewport_height": viewport_size.y,
			"world_width_tiles": int(viewport_summary.get("world_width_tiles", 0)),
			"world_height_tiles": int(viewport_summary.get("world_height_tiles", 0)),
			"background_width_tiles": int(viewport_summary.get("background_width_tiles", 0)),
			"background_height_tiles": int(viewport_summary.get("background_height_tiles", 0)),
			"background_cell_count": viewport_background_cells.size(),
			"background_cell_count_matches": viewport_background_cells.size() == viewport_background_count,
			"covers_visible_world": bool(viewport_summary.get("covers_visible_world", false)),
			"background_covers_camera_clamp_bounds": bool(viewport_summary.get("background_covers_camera_clamp_bounds", false)),
			"matches": viewport_matches,
		})
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
		"responsive_viewport_results": responsive_viewport_results,
		"all_responsive_viewports_cover_background": all_responsive_viewports_cover_background,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["profile_loaded"] and proof["background_cell_count_matches"] and proof["background_size_matches"] and proof["background_negative_min_cell"] and proof["covers_visible_world"] and proof["background_covers_camera_clamp_bounds"] and proof["all_responsive_viewports_cover_background"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("DISPLAY_PROFILE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("DisplayProfileRuntimeModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
