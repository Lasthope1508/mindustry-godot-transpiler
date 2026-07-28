extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockInitClipState := preload("res://src/game/SourceBlockInitClipState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var clip_size_bridge := game.generated_block_init_clip_size_bridge_state(4.0, 2, 8.0)
	var light_clip_size_bridge := game.generated_block_init_light_clip_size_bridge_state(12.0, 20.0)
	var liquid_light_bridge := game.generated_block_init_liquid_light_bridge_state(true, true, false, 10.0, 2)
	var liquid_capacity_bridge := game.generated_block_init_liquid_capacity_default_bridge_state(-1.0)
	var emit_light_bridge := game.generated_block_init_emit_light_radius_bridge_state(true, 10.0, 24.0)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_CLIP_MODULE_PROOF",
		"clip_size_bridge": clip_size_bridge,
		"light_clip_size_bridge": light_clip_size_bridge,
		"liquid_light_bridge": liquid_light_bridge,
		"liquid_capacity_bridge": liquid_capacity_bridge,
		"emit_light_bridge": emit_light_bridge,
		"clip_size_bridge_matches": clip_size_bridge == SourceBlockInitClipState.generated_clip_size_bridge_state(4.0, 2, 8.0),
		"light_clip_size_bridge_matches": light_clip_size_bridge == SourceBlockInitClipState.generated_light_clip_size_bridge_state(12.0, 20.0),
		"liquid_light_bridge_matches": liquid_light_bridge == SourceBlockInitClipState.generated_liquid_light_bridge_state(true, true, false, 10.0, 2),
		"liquid_capacity_bridge_matches": liquid_capacity_bridge == SourceBlockInitClipState.generated_liquid_capacity_default_bridge_state(-1.0),
		"emit_light_bridge_matches": emit_light_bridge == SourceBlockInitClipState.generated_emit_light_radius_bridge_state(true, 10.0, 24.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(clip_size_bridge.get("matches", false)) and bool(light_clip_size_bridge.get("matches", false)) and bool(liquid_light_bridge.get("matches", false)) and bool(liquid_capacity_bridge.get("matches", false)) and bool(emit_light_bridge.get("matches", false)) and proof["clip_size_bridge_matches"] and proof["light_clip_size_bridge_matches"] and proof["liquid_light_bridge_matches"] and proof["liquid_capacity_bridge_matches"] and proof["emit_light_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_CLIP_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BlockInitClipModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
