extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockPostInitState := preload("res://src/game/SourceBlockPostInitState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var requirements := [{"is_on_planets": ["serpulo"]}]
	var content_planets := [{"name": "serpulo", "is_landable": true}, {"name": "erekir", "is_landable": true}]
	var database_tag_bridge := game.generated_block_post_init_database_tag_bridge_state("", "turret")
	var shown_planets_bridge := game.generated_block_post_init_shown_planets_bridge_state(requirements, [], content_planets)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_POST_INIT_MODULE_PROOF",
		"database_tag_bridge": database_tag_bridge,
		"shown_planets_bridge": shown_planets_bridge,
		"database_tag_bridge_matches": database_tag_bridge == SourceBlockPostInitState.generated_database_tag_bridge_state("", "turret"),
		"shown_planets_bridge_matches": shown_planets_bridge == SourceBlockPostInitState.generated_shown_planets_bridge_state(requirements, [], content_planets),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(database_tag_bridge.get("matches", false)) and bool(shown_planets_bridge.get("matches", false)) and proof["database_tag_bridge_matches"] and proof["shown_planets_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_POST_INIT_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BlockPostInitModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
