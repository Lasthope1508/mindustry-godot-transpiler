extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockInitSoundState := preload("res://src/game/SourceBlockInitSoundState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var destroy_bridge := game.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 3)
	var place_bridge := game.generated_block_init_place_sound_bridge_state("Sounds.unset", 2)
	var break_bridge := game.generated_block_init_break_sound_bridge_state("Sounds.unset", 1)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_SOUND_MODULE_PROOF",
		"destroy_bridge": destroy_bridge,
		"place_bridge": place_bridge,
		"break_bridge": break_bridge,
		"destroy_bridge_matches": destroy_bridge == SourceBlockInitSoundState.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 3),
		"place_bridge_matches": place_bridge == SourceBlockInitSoundState.generated_block_init_place_sound_bridge_state("Sounds.unset", 2),
		"break_bridge_matches": break_bridge == SourceBlockInitSoundState.generated_block_init_break_sound_bridge_state("Sounds.unset", 1),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(destroy_bridge.get("matches", false)) and bool(place_bridge.get("matches", false)) and bool(break_bridge.get("matches", false)) and proof["destroy_bridge_matches"] and proof["place_bridge_matches"] and proof["break_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_SOUND_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BlockInitSoundModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
