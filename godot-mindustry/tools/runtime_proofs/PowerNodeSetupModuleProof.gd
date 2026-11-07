extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_power_node_state := preload("res://src/game/SourcePowerNodeState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

const GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/power/PowerNode.gd"

func _ready() -> void:
	var game = PortGameScript.new()
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var stats_parent := {"stats": "base"}
	var init_parent := {"initialized": true}
	var stats_state: Dictionary = game.source_power_node_set_stats_state(6.0, 10, stats_parent)
	var init_state: Dictionary = game.source_power_node_init_state(24.0, 6.0, 8.0, init_parent)
	var plan_state: Dictionary = game.source_power_node_plan_config_clip_size_state(6.0, 8.0, 2.0)
	var generated_stats = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_setStats_3", [6.0, 10, stats_parent])
	var generated_init = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_init_4", [24.0, 6.0, 8.0, init_parent])
	var generated_plan = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_planConfigClipSize_18", [6.0, 8.0, 2.0])
	var proof: Dictionary = {
		"module": "POWER_NODE_SETUP_MODULE_PROOF",
		"source_matches": [
			stats_state == source_power_node_state.set_stats_state(6.0, 10, stats_parent),
			init_state == source_power_node_state.init_state(24.0, 6.0, 8.0, init_parent),
			plan_state == source_power_node_state.plan_config_clip_size_state(6.0, 8.0, 2.0),
			float(init_state.get("clip_size_after", -1.0)) == 48.0,
			float(plan_state.get("clip_size", -1.0)) == 112.0,
		],
		"generated_matches": [generated_stats == stats_state, generated_init == init_state, generated_plan == plan_state],
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = not proof["source_matches"].has(false) and not proof["generated_matches"].has(false) and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("POWER_NODE_SETUP_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerNodeSetupModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
