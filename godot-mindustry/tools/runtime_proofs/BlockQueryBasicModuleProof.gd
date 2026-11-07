extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var has_building_bridge := game.generated_block_has_building_bridge_state(true, false)
	var is_multiblock_bridge := game.generated_block_is_multiblock_bridge_state(3)
	var is_floor_bridge := game.generated_block_is_floor_bridge_state(true)
	var is_overlay_bridge := game.generated_block_is_overlay_bridge_state(true)
	var as_floor_bridge := game.generated_block_as_floor_bridge_state("floor-block")
	var is_air_bridge := game.generated_block_is_air_bridge_state(0)
	var can_be_built_bridge := game.generated_block_can_be_built_bridge_state("shown")
	var environment_buildable_bridge := game.generated_block_environment_buildable_bridge_state(true)
	var is_static_bridge := game.generated_block_is_static_bridge_state("walls")
	var is_banned_bridge := game.generated_block_is_banned_bridge_state(true)
	var supports_env_bridge := game.generated_block_supports_env_bridge_state(0b1111, 0b0100, 0b0011, 0b0011)
	var is_floor_source := game.source_block_is_floor_state(true)
	var is_overlay_source := game.source_block_is_overlay_state(true)
	var as_floor_source := game.source_block_as_floor_state("floor-block")
	var environment_buildable_source := game.source_block_environment_buildable_state(true)
	var proof := {
		"module": "SourceBlockQueryBasicState",
		"has_building_bridge_matches": has_building_bridge == source_block_query_basic_state.generated_block_has_building_bridge_state(true, false) and bool(has_building_bridge.get("matches", false)),
		"is_multiblock_bridge_matches": is_multiblock_bridge == source_block_query_basic_state.generated_block_is_multiblock_bridge_state(3) and bool(is_multiblock_bridge.get("matches", false)),
		"is_floor_bridge_matches": is_floor_bridge == source_block_query_basic_state.generated_block_is_floor_bridge_state(true) and bool(is_floor_bridge.get("matches", false)),
		"is_overlay_bridge_matches": is_overlay_bridge == source_block_query_basic_state.generated_block_is_overlay_bridge_state(true) and bool(is_overlay_bridge.get("matches", false)),
		"as_floor_bridge_matches": as_floor_bridge == source_block_query_basic_state.generated_block_as_floor_bridge_state("floor-block") and bool(as_floor_bridge.get("matches", false)),
		"is_air_bridge_matches": is_air_bridge == source_block_query_basic_state.generated_block_is_air_bridge_state(0) and bool(is_air_bridge.get("matches", false)),
		"can_be_built_bridge_matches": can_be_built_bridge == source_block_query_basic_state.generated_block_can_be_built_bridge_state("shown") and bool(can_be_built_bridge.get("matches", false)),
		"environment_buildable_bridge_matches": environment_buildable_bridge == source_block_query_basic_state.generated_block_environment_buildable_bridge_state(true) and bool(environment_buildable_bridge.get("matches", false)),
		"is_static_bridge_matches": is_static_bridge == source_block_query_basic_state.generated_block_is_static_bridge_state("walls") and bool(is_static_bridge.get("matches", false)),
		"is_banned_bridge_matches": is_banned_bridge == source_block_query_basic_state.generated_block_is_banned_bridge_state(true) and bool(is_banned_bridge.get("matches", false)),
		"supports_env_bridge_matches": supports_env_bridge == source_block_query_basic_state.generated_block_supports_env_bridge_state(0b1111, 0b0100, 0b0011, 0b0011) and bool(supports_env_bridge.get("matches", false)),
		"is_floor_source_matches": is_floor_source == source_block_query_basic_state.is_floor_state(true),
		"is_overlay_source_matches": is_overlay_source == source_block_query_basic_state.is_overlay_state(true),
		"as_floor_source_matches": as_floor_source == source_block_query_basic_state.as_floor_state("floor-block"),
		"environment_buildable_source_matches": environment_buildable_source == source_block_query_basic_state.environment_buildable_state(true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["has_building_bridge_matches"] and proof["is_multiblock_bridge_matches"] and proof["is_floor_bridge_matches"] and proof["is_overlay_bridge_matches"] and proof["as_floor_bridge_matches"] and proof["is_air_bridge_matches"] and proof["can_be_built_bridge_matches"] and proof["environment_buildable_bridge_matches"] and proof["is_static_bridge_matches"] and proof["is_banned_bridge_matches"] and proof["supports_env_bridge_matches"] and proof["is_floor_source_matches"] and proof["is_overlay_source_matches"] and proof["as_floor_source_matches"] and proof["environment_buildable_source_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockQueryBasicModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

