extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_build_payload_draw_state_script := preload("res://src/game/SourceBuildPayloadDrawState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var build_block := "build-block"
	var block := "block"
	var team := "team"
	var other_block := "other-block"
	var requirements := ["req-1", "req-2"]
	var build_time := 7.5
	var build_x := 13.0
	var build_y := 21.0
	var build_block_size := 3.5
	var source_tilesize := 8.0
	var payload_block := 12
	var build_block_id := 34
	var build_version := 5
	var x := 9.5
	var y := 11.75
	var rotation_value := 45.0
	var prev_z := 2.5
	var layer_flying_unit_low := 4.0
	var transform_z := 6.0
	var alpha := 0.75
	var full_icon := "icon"
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var block_bridge := game.generated_build_payload_block_bridge_state(build_block)
	var constructor_block_team_bridge := game.generated_build_payload_constructor_block_team_bridge_state(block, team)
	var constructor_build_bridge := game.generated_build_payload_constructor_build_bridge_state(build_block)
	var content_equals_bridge := game.generated_build_payload_content_equals_bridge_state(true, other_block, build_block)
	var content_bridge := game.generated_build_payload_content_bridge_state(build_block)
	var build_time_bridge := game.generated_build_payload_build_time_bridge_state(build_time)
	var requirements_bridge := game.generated_build_payload_requirements_bridge_state(requirements)
	var x_bridge := game.generated_build_payload_x_bridge_state(x)
	var y_bridge := game.generated_build_payload_y_bridge_state(y)
	var size_bridge := game.generated_build_payload_size_bridge_state(build_block_size, source_tilesize)
	var size_default_bridge := game.generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size)
	var write_bridge := game.generated_build_payload_write_bridge_state(payload_block, build_block_id, build_version)
	var set_bridge := game.generated_build_payload_set_bridge_state(x, y, rotation_value)
	var draw_shadow_bridge := game.generated_build_payload_draw_shadow_bridge_state(build_x, build_y, build_block_size, source_tilesize, alpha)
	var draw_bridge := game.generated_build_payload_draw_bridge_state(prev_z, layer_flying_unit_low, transform_z)
	var icon_bridge := game.generated_build_payload_icon_bridge_state(full_icon)
	var proof := {
		"module": "BUILD_PAYLOAD_MODULE_PROOF",
		"block_bridge": block_bridge,
		"constructor_block_team_bridge": constructor_block_team_bridge,
		"constructor_build_bridge": constructor_build_bridge,
		"content_equals_bridge": content_equals_bridge,
		"content_bridge": content_bridge,
		"build_time_bridge": build_time_bridge,
		"requirements_bridge": requirements_bridge,
		"x_bridge": x_bridge,
		"y_bridge": y_bridge,
		"size_bridge": size_bridge,
		"size_default_bridge": size_default_bridge,
		"write_bridge": write_bridge,
		"set_bridge": set_bridge,
		"draw_shadow_bridge": draw_shadow_bridge,
		"draw_bridge": draw_bridge,
		"icon_bridge": icon_bridge,
		"block_bridge_matches": block_bridge == source_build_payload_state.generated_build_payload_block_bridge_state(build_block),
		"constructor_block_team_bridge_matches": constructor_block_team_bridge == source_build_payload_state.generated_build_payload_constructor_block_team_bridge_state(block, team),
		"constructor_build_bridge_matches": constructor_build_bridge == source_build_payload_state.generated_build_payload_constructor_build_bridge_state(build_block),
		"content_equals_bridge_matches": content_equals_bridge == source_build_payload_state.generated_build_payload_content_equals_bridge_state(true, other_block, build_block),
		"content_bridge_matches": content_bridge == source_build_payload_state.generated_build_payload_content_bridge_state(build_block),
		"build_time_bridge_matches": build_time_bridge == source_build_payload_state.generated_build_payload_build_time_bridge_state(build_time),
		"requirements_bridge_matches": requirements_bridge == source_build_payload_state.generated_build_payload_requirements_bridge_state(requirements),
		"x_bridge_matches": x_bridge == source_build_payload_state.generated_build_payload_x_bridge_state(x),
		"y_bridge_matches": y_bridge == source_build_payload_state.generated_build_payload_y_bridge_state(y),
		"size_bridge_matches": size_bridge == source_build_payload_state.generated_build_payload_size_bridge_state(build_block_size, source_tilesize),
		"size_default_bridge_matches": size_default_bridge == source_build_payload_state.generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size),
		"write_bridge_matches": write_bridge == source_build_payload_state.generated_build_payload_write_bridge_state(payload_block, build_block_id, build_version),
		"set_bridge_matches": set_bridge == source_build_payload_state.generated_build_payload_set_bridge_state(x, y, rotation_value),
		"draw_shadow_bridge_matches": draw_shadow_bridge == source_build_payload_draw_state_script.generated_build_payload_draw_shadow_bridge_state(build_x, build_y, build_block_size, source_tilesize, alpha),
		"draw_bridge_matches": draw_bridge == source_build_payload_draw_state_script.generated_build_payload_draw_bridge_state(prev_z, layer_flying_unit_low, transform_z),
		"icon_bridge_matches": icon_bridge == source_build_payload_draw_state_script.generated_build_payload_icon_bridge_state(full_icon),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(block_bridge.get("matches", false)) and bool(constructor_block_team_bridge.get("matches", false)) and bool(constructor_build_bridge.get("matches", false)) and bool(content_equals_bridge.get("matches", false)) and bool(content_bridge.get("matches", false)) and bool(build_time_bridge.get("matches", false)) and bool(requirements_bridge.get("matches", false)) and bool(x_bridge.get("matches", false)) and bool(y_bridge.get("matches", false)) and bool(size_bridge.get("matches", false)) and bool(size_default_bridge.get("matches", false)) and bool(write_bridge.get("matches", false)) and bool(set_bridge.get("matches", false)) and bool(draw_shadow_bridge.get("matches", false)) and bool(draw_bridge.get("matches", false)) and bool(icon_bridge.get("matches", false)) and proof["block_bridge_matches"] and proof["constructor_block_team_bridge_matches"] and proof["constructor_build_bridge_matches"] and proof["content_equals_bridge_matches"] and proof["content_bridge_matches"] and proof["build_time_bridge_matches"] and proof["requirements_bridge_matches"] and proof["x_bridge_matches"] and proof["y_bridge_matches"] and proof["size_bridge_matches"] and proof["size_default_bridge_matches"] and proof["write_bridge_matches"] and proof["set_bridge_matches"] and proof["draw_shadow_bridge_matches"] and proof["draw_bridge_matches"] and proof["icon_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILD_PAYLOAD_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildPayloadModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
