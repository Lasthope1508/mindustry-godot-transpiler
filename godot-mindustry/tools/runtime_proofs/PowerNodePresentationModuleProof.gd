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
	var laser_input := {"x1": 10.0, "y1": 20.0, "x2": 110.0, "y2": 80.0, "size1": 2.0, "size2": 3.0, "tilesize": 8.0, "angle1": 30.963756, "vx": 0.857493, "vy": 0.514496}
	var setup_state: Dictionary = game.source_power_node_setup_color_state(0.75, 0.8, 0.5, 0.1)
	var laser_state: Dictionary = game.source_power_node_draw_laser_state(laser_input, false)
	var generated_setup = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_setupColor_7", [0.75, 0.8, 0.5, 0.1], null)
	var generated_laser = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_drawLaser_9", [laser_input, false], null)
	var proof: Dictionary = {
		"module": "POWER_NODE_PRESENTATION_MODULE_PROOF",
		"source_matches": [
			setup_state == source_power_node_state.setup_color_state(0.75, 0.8, 0.5, 0.1),
			laser_state == source_power_node_state.draw_laser_state(laser_input, false),
			is_equal_approx(float(setup_state.get("lerp_factor", 0.0)), 0.315),
			is_equal_approx(float(setup_state.get("alpha", 0.0)), 0.4),
			is_equal_approx(float(laser_state.get("len1", 0.0)), 6.5),
			is_equal_approx(float(laser_state.get("len2", 0.0)), 10.5),
		],
		"generated_matches": [generated_setup == setup_state, generated_laser == laser_state],
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = not proof["source_matches"].has(false) and not proof["generated_matches"].has(false) and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("POWER_NODE_PRESENTATION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerNodePresentationModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
