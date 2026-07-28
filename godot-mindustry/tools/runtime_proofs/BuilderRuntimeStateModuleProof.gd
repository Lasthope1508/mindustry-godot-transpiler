extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuilderRuntimeState := preload("res://src/game/SourceBuilderRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var can_build_bridge := game.generated_builder_comp_can_build_bridge_state(12.5, 1.5)
	var add_build_bridge := game.generated_builder_comp_add_build_bridge_state([], {"x": 9, "y": 5}, true, true, true, true, 0.75)
	var update_build_logic_bridge := game.generated_builder_comp_update_build_logic_bridge_state(30.0, 1.25, 1.1, 0.9, false, true)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDER_RUNTIME_STATE_MODULE_PROOF",
		"can_build_bridge": can_build_bridge,
		"add_build_bridge": add_build_bridge,
		"update_build_logic_bridge": update_build_logic_bridge,
		"can_build_bridge_matches": can_build_bridge == SourceBuilderRuntimeState.generated_builder_comp_can_build_bridge_state(12.5, 1.5),
		"add_build_bridge_matches": add_build_bridge == SourceBuilderRuntimeState.generated_builder_comp_add_build_bridge_state([], {"x": 9, "y": 5}, true, true, true, true, 0.75),
		"update_build_logic_bridge_matches": update_build_logic_bridge == SourceBuilderRuntimeState.generated_builder_comp_update_build_logic_bridge_state(30.0, 1.25, 1.1, 0.9, false, true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["can_build_bridge_matches"] and proof["add_build_bridge_matches"] and proof["update_build_logic_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDER_RUNTIME_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuilderRuntimeStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
