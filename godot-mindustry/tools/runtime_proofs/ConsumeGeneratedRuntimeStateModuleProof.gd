extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_generated_state := preload("res://src/game/SourceConsumeGeneratedState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var optional_wrapper := game.generated_consume_optional_bridge_state(false, true)
	var optional_module := source_consume_generated_state.generated_optional_bridge_state(false, true)
	var boost_wrapper := game.generated_consume_boost_bridge_state()
	var boost_module := source_consume_generated_state.generated_boost_bridge_state()
	var update_wrapper := game.generated_consume_update_flag_bridge_state(false)
	var update_module := source_consume_generated_state.generated_update_flag_bridge_state(false)
	var ignore_wrapper := game.generated_consume_ignore_bridge_state()
	var ignore_module := source_consume_generated_state.generated_ignore_bridge_state()
	var build_arg := {"id": "build"}
	var table_arg := {"id": "table"}
	var block_arg := {"id": "block"}
	var stats_arg := {"id": "stats"}
	var build_wrapper := game.generated_consume_build_bridge_state(build_arg, table_arg)
	var build_module := source_consume_generated_state.generated_build_bridge_state(build_arg, table_arg)
	var apply_wrapper := game.generated_consume_apply_bridge_state(block_arg)
	var apply_module := source_consume_generated_state.generated_apply_bridge_state(block_arg)
	var trigger_wrapper := game.generated_consume_trigger_bridge_state(build_arg)
	var trigger_module := source_consume_generated_state.generated_trigger_bridge_state(build_arg)
	var update_build_wrapper := game.generated_consume_update_build_bridge_state(build_arg)
	var update_build_module := source_consume_generated_state.generated_update_build_bridge_state(build_arg)
	var display_wrapper := game.generated_consume_display_bridge_state(stats_arg)
	var display_module := source_consume_generated_state.generated_display_bridge_state(stats_arg)
	var efficiency_wrapper := game.generated_consume_efficiency_bridge_state()
	var efficiency_module := source_consume_generated_state.generated_efficiency_bridge_state()
	var efficiency_multiplier_wrapper := game.generated_consume_efficiency_multiplier_bridge_state()
	var efficiency_multiplier_module := source_consume_generated_state.generated_efficiency_multiplier_bridge_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeGeneratedState",
		"optional_bridge_matches": optional_wrapper == optional_module and bool(optional_module.get("matches", false)),
		"boost_bridge_matches": boost_wrapper == boost_module and bool(boost_module.get("matches", false)),
		"update_flag_bridge_matches": update_wrapper == update_module and bool(update_module.get("matches", false)),
		"ignore_bridge_matches": ignore_wrapper == ignore_module and bool(ignore_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"trigger_bridge_matches": trigger_wrapper == trigger_module and bool(trigger_module.get("matches", false)),
		"update_build_bridge_matches": update_build_wrapper == update_build_module and bool(update_build_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"efficiency_multiplier_bridge_matches": efficiency_multiplier_wrapper == efficiency_multiplier_module and bool(efficiency_multiplier_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["optional_bridge_matches"] and proof["boost_bridge_matches"] and proof["update_flag_bridge_matches"] and proof["ignore_bridge_matches"] and proof["build_bridge_matches"] and proof["apply_bridge_matches"] and proof["trigger_bridge_matches"] and proof["update_build_bridge_matches"] and proof["display_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["efficiency_multiplier_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

