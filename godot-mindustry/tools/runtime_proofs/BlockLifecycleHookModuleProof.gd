extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_lifecycle_hook_state := preload("res://src/game/SourceBlockLifecycleHookState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var build_editor_config_bridge := game.generated_block_build_editor_config_bridge_state({"kind": "table"})
	var on_picked_bridge := game.generated_block_on_picked_bridge_state({"tile": "picked"})
	var get_config_bridge := game.generated_block_get_config_bridge_state({"tile": "config"})
	var changed_bridge := game.generated_block_changed_bridge_state({"tile": "changed"})
	var place_began_bridge := game.generated_block_place_began_bridge_state({"tile": "begin"}, "previous-block")
	var place_began_builder_bridge := game.generated_block_place_began_builder_bridge_state({"tile": "begin-builder"}, "previous-block", "builder-unit")
	var place_ended_bridge := game.generated_block_place_ended_bridge_state({"tile": "ended"}, "builder-unit", 2, {"config": "payload"})
	var before_place_began_bridge := game.generated_block_before_place_began_bridge_state({"tile": "before"}, "previous-block")
	var editor_picked_bridge := game.generated_block_editor_picked_bridge_state({"tile": "editor"})
	var source_states := [
		game.source_block_build_editor_config_state({"kind": "table"}),
		game.source_block_on_picked_state({"tile": "picked"}),
		game.source_block_get_config_state({"tile": "config"}),
		game.source_block_changed_state({"tile": "changed"}),
		game.source_block_place_began_state({"tile": "begin"}, "previous-block"),
		game.source_block_place_began_builder_state({"tile": "begin-builder"}, "previous-block", "builder-unit"),
		game.source_block_place_ended_state({"tile": "ended"}, "builder-unit", 2, {"config": "payload"}),
		game.source_block_before_place_began_state({"tile": "before"}, "previous-block"),
		game.source_block_editor_picked_state({"tile": "editor"}),
	]
	var canonical_states := [
		source_block_lifecycle_hook_state.build_editor_config_state({"kind": "table"}),
		source_block_lifecycle_hook_state.on_picked_state({"tile": "picked"}),
		source_block_lifecycle_hook_state.get_config_state({"tile": "config"}),
		source_block_lifecycle_hook_state.block_changed_state({"tile": "changed"}),
		source_block_lifecycle_hook_state.place_began_state({"tile": "begin"}, "previous-block"),
		source_block_lifecycle_hook_state.place_began_builder_state({"tile": "begin-builder"}, "previous-block", "builder-unit"),
		source_block_lifecycle_hook_state.place_ended_state({"tile": "ended"}, "builder-unit", 2, {"config": "payload"}),
		source_block_lifecycle_hook_state.before_place_began_state({"tile": "before"}, "previous-block"),
		source_block_lifecycle_hook_state.editor_picked_state({"tile": "editor"}),
	]
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_LIFECYCLE_HOOK_MODULE_PROOF",
		"build_editor_config_bridge": build_editor_config_bridge,
		"on_picked_bridge": on_picked_bridge,
		"get_config_bridge": get_config_bridge,
		"changed_bridge": changed_bridge,
		"place_began_bridge": place_began_bridge,
		"place_began_builder_bridge": place_began_builder_bridge,
		"place_ended_bridge": place_ended_bridge,
		"before_place_began_bridge": before_place_began_bridge,
		"editor_picked_bridge": editor_picked_bridge,
		"build_editor_config_bridge_matches": build_editor_config_bridge == source_block_lifecycle_hook_state.generated_block_build_editor_config_bridge_state({"kind": "table"}),
		"on_picked_bridge_matches": on_picked_bridge == source_block_lifecycle_hook_state.generated_block_on_picked_bridge_state({"tile": "picked"}),
		"get_config_bridge_matches": get_config_bridge == source_block_lifecycle_hook_state.generated_block_get_config_bridge_state({"tile": "config"}),
		"changed_bridge_matches": changed_bridge == source_block_lifecycle_hook_state.generated_block_changed_bridge_state({"tile": "changed"}),
		"place_began_bridge_matches": place_began_bridge == source_block_lifecycle_hook_state.generated_block_place_began_bridge_state({"tile": "begin"}, "previous-block"),
		"place_began_builder_bridge_matches": place_began_builder_bridge == source_block_lifecycle_hook_state.generated_block_place_began_builder_bridge_state({"tile": "begin-builder"}, "previous-block", "builder-unit"),
		"place_ended_bridge_matches": place_ended_bridge == source_block_lifecycle_hook_state.generated_block_place_ended_bridge_state({"tile": "ended"}, "builder-unit", 2, {"config": "payload"}),
		"before_place_began_bridge_matches": before_place_began_bridge == source_block_lifecycle_hook_state.generated_block_before_place_began_bridge_state({"tile": "before"}, "previous-block"),
		"editor_picked_bridge_matches": editor_picked_bridge == source_block_lifecycle_hook_state.generated_block_editor_picked_bridge_state({"tile": "editor"}),
		"source_states_match_canonical": source_states == canonical_states,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(build_editor_config_bridge.get("matches", false)) \
		and bool(on_picked_bridge.get("matches", false)) \
		and bool(get_config_bridge.get("matches", false)) \
		and bool(changed_bridge.get("matches", false)) \
		and bool(place_began_bridge.get("matches", false)) \
		and bool(place_began_builder_bridge.get("matches", false)) \
		and bool(place_ended_bridge.get("matches", false)) \
		and bool(before_place_began_bridge.get("matches", false)) \
		and bool(editor_picked_bridge.get("matches", false)) \
		and proof["build_editor_config_bridge_matches"] \
		and proof["on_picked_bridge_matches"] \
		and proof["get_config_bridge_matches"] \
		and proof["changed_bridge_matches"] \
		and proof["place_began_bridge_matches"] \
		and proof["place_began_builder_bridge_matches"] \
		and proof["place_ended_bridge_matches"] \
		and proof["before_place_began_bridge_matches"] \
		and proof["editor_picked_bridge_matches"] \
		and proof["source_states_match_canonical"] \
		and proof["registry_valid"] \
		and proof["one_headquarter_per_ssot"]
	print("BLOCK_LIFECYCLE_HOOK_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockLifecycleHookModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
