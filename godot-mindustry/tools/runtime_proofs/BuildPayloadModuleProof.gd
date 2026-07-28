extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")
const SourceBuildPayloadState := preload("res://src/game/SourceBuildPayloadState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var build_block := "build-block"
	var block := "block"
	var team := "team"
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var block_bridge := game.generated_build_payload_block_bridge_state(build_block)
	var constructor_block_team_bridge := game.generated_build_payload_constructor_block_team_bridge_state(block, team)
	var constructor_build_bridge := game.generated_build_payload_constructor_build_bridge_state(build_block)
	var proof := {
		"module": "BUILD_PAYLOAD_MODULE_PROOF",
		"block_bridge": block_bridge,
		"constructor_block_team_bridge": constructor_block_team_bridge,
		"constructor_build_bridge": constructor_build_bridge,
		"block_bridge_matches": block_bridge == SourceBuildPayloadState.generated_build_payload_block_bridge_state(build_block),
		"constructor_block_team_bridge_matches": constructor_block_team_bridge == SourceBuildPayloadState.generated_build_payload_constructor_block_team_bridge_state(block, team),
		"constructor_build_bridge_matches": constructor_build_bridge == SourceBuildPayloadState.generated_build_payload_constructor_build_bridge_state(build_block),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(block_bridge.get("matches", false)) and bool(constructor_block_team_bridge.get("matches", false)) and bool(constructor_build_bridge.get("matches", false)) and proof["block_bridge_matches"] and proof["constructor_block_team_bridge_matches"] and proof["constructor_build_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILD_PAYLOAD_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildPayloadModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
