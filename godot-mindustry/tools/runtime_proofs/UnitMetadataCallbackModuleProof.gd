extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceUnitMetadataState := preload("res://src/game/SourceUnitMetadataState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var callbacks := SourceUnitMetadataState.default_callbacks_state(game)
	var expected_callbacks := {
		"bullet_damage": Callable(game, "source_bullet_damage"),
	}
	var unit_type: Variant = game.selected_enemy_unit()
	var wrapper := game.source_unit_weapon_damage(unit_type)
	var module := SourceUnitMetadataState.unit_weapon_damage(unit_type, callbacks.get("bullet_damage", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceUnitMetadataState",
		"wrapper_matches": is_equal_approx(float(wrapper), float(module)),
		"default_callbacks_match": callbacks == expected_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["wrapper_matches"]
	print("UNIT_METADATA_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
