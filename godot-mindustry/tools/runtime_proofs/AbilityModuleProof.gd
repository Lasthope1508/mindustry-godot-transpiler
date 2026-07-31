extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ability_state := preload("res://src/game/SourceAbilityState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var unit := {"id": 77, "name": "test-unit"}
	var bars := {"slots": 3}
	var table_state := {"children": []}
	var type_value := "unit-type"
	var get_bundle_value := "ability.bundle"
	var bundle_value := "Localized Name"
	var class_simple_name := "TestAbility"
	var superclass_simple_name := "Ability"
	var clone_value := "clone-result"
	var exception_value := "clone-error"
	var update_bridge := game.generated_ability_update_bridge_state(unit)
	var draw_bridge := game.generated_ability_draw_bridge_state(unit)
	var death_bridge := game.generated_ability_death_bridge_state(unit)
	var created_bridge := game.generated_ability_created_bridge_state(unit)
	var init_bridge := game.generated_ability_init_bridge_state(type_value)
	var display_bars_bridge := game.generated_ability_display_bars_bridge_state(unit, bars)
	var display_bridge := game.generated_ability_display_bridge_state(table_state, "ability.name")
	var add_stats_bridge := game.generated_ability_add_stats_bridge_state(table_state, get_bundle_value, true, "Description")
	var ability_stat_bridge := game.generated_ability_ability_stat_bridge_state("speed", [1, 2], "speed=2")
	var copy_bridge := game.generated_ability_copy_bridge_state(true, clone_value, exception_value)
	var localized_bridge := game.generated_ability_localized_bridge_state(get_bundle_value, bundle_value)
	var get_bundle_bridge := game.generated_ability_get_bundle_bridge_state(class_simple_name, false, superclass_simple_name)
	var proof := {
		"module": "SourceAbilityState",
		"update_bridge_matches": update_bridge == source_ability_state.generated_update_bridge_state(unit),
		"draw_bridge_matches": draw_bridge == source_ability_state.generated_draw_bridge_state(unit),
		"death_bridge_matches": death_bridge == source_ability_state.generated_death_bridge_state(unit),
		"created_bridge_matches": created_bridge == source_ability_state.generated_created_bridge_state(unit),
		"init_bridge_matches": init_bridge == source_ability_state.generated_init_bridge_state(type_value),
		"display_bars_bridge_matches": display_bars_bridge == source_ability_state.generated_display_bars_bridge_state(unit, bars),
		"display_bridge_matches": display_bridge == source_ability_state.generated_display_bridge_state(table_state, "ability.name"),
		"add_stats_bridge_matches": add_stats_bridge == source_ability_state.generated_add_stats_bridge_state(table_state, get_bundle_value, true, "Description"),
		"ability_stat_bridge_matches": ability_stat_bridge == source_ability_state.generated_ability_stat_bridge_state("speed", [1, 2], "speed=2"),
		"copy_bridge_matches": copy_bridge == source_ability_state.generated_copy_bridge_state(true, clone_value, exception_value),
		"localized_bridge_matches": localized_bridge == source_ability_state.generated_localized_bridge_state(get_bundle_value, bundle_value),
		"get_bundle_bridge_matches": get_bundle_bridge == source_ability_state.generated_get_bundle_bridge_state(class_simple_name, false, superclass_simple_name),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["update_bridge_matches"] and proof["draw_bridge_matches"] and proof["death_bridge_matches"] and proof["created_bridge_matches"] and proof["init_bridge_matches"] and proof["display_bars_bridge_matches"] and proof["display_bridge_matches"] and proof["add_stats_bridge_matches"] and proof["ability_stat_bridge_matches"] and proof["copy_bridge_matches"] and proof["localized_bridge_matches"] and proof["get_bundle_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("ABILITY_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/AbilityModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
