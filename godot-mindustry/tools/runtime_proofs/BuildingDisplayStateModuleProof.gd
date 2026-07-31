extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_display_state := preload("res://src/game/SourceBuildingDisplayState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_building_display_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_building_display_state.SOURCE_BUILDING_DISPLAY_FIXED_ONE_DECIMAL_KEY: Callable(game, source_building_display_state.SOURCE_BUILDING_DISPLAY_FIXED_ONE_DECIMAL_FALLBACK),
	}
	var override_callbacks := source_building_display_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_display_state.SOURCE_BUILDING_DISPLAY_FIXED_ONE_DECIMAL_KEY, Callable()) == Callable(self, "proof_fixed_one_decimal")

	var display_name_source := game.source_building_display_name_state("Copper Wall", false, true, "?", "Derelict")
	var display_name_module := source_building_display_state.display_name_state("Copper Wall", false, true, "?", "Derelict")
	var fixed_one_decimal_source := game.source_arc_strings_fixed_one_decimal(12.34)
	var fixed_one_decimal_module := source_building_display_state.fixed_one_decimal(12.34)
	var flow_label_source := game.source_building_display_flow_rate_label(12.34, "/sec")
	var flow_label_module := source_building_display_state.game_display_flow_rate_label(game, 12.34, "/sec")
	var override_flow_label := source_building_display_state.game_display_flow_rate_label(self, 12.34, "/sec")
	var primitive_override_flow_label := source_building_display_state.display_flow_rate_label(12.34, "/sec", Callable(self, "proof_fixed_one_decimal"))
	var flow_items_source: Variant = game.source_building_flow_items_state({"name": "copper"})
	var flow_items_module: Variant = source_building_display_state.flow_items_state({"name": "copper"})
	var display_consumption_source := game.source_building_display_consumption_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var display_consumption_module := source_building_display_state.display_consumption_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var display_bars_source := game.source_building_display_bars_state([null, {"bar": "ok"}])
	var display_bars_module := source_building_display_state.display_bars_state([null, {"bar": "ok"}])

	var bridge_name_source := game.generated_building_comp_get_display_name_bridge_state("Copper Wall", false, true, "?", "Derelict")
	var bridge_name_module := source_building_display_state.generated_building_comp_get_display_name_bridge_state("Copper Wall", false, true, "?", "Derelict")
	var bridge_flow_source := game.generated_building_comp_flow_items_bridge_state({"name": "copper"})
	var bridge_flow_module := source_building_display_state.generated_building_comp_flow_items_bridge_state({"name": "copper"})
	var bridge_consumption_source := game.generated_building_comp_display_consumption_bridge_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var bridge_consumption_module := source_building_display_state.generated_building_comp_display_consumption_bridge_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var bridge_bars_source := game.generated_building_comp_display_bars_bridge_state([null, {"bar": "ok"}])
	var bridge_bars_module := source_building_display_state.generated_building_comp_display_bars_bridge_state([null, {"bar": "ok"}])

	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingDisplayState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"fixed_one_decimal_matches": fixed_one_decimal_source == fixed_one_decimal_module and fixed_one_decimal_module == "12.3",
		"display_name_matches": display_name_source == display_name_module,
		"flow_label_matches": flow_label_source == flow_label_module,
		"override_flow_label_matches": override_flow_label == primitive_override_flow_label,
		"flow_items_matches": flow_items_source == flow_items_module,
		"display_consumption_matches": display_consumption_source == display_consumption_module,
		"display_bars_matches": display_bars_source == display_bars_module,
		"bridge_name_matches": bridge_name_source == bridge_name_module,
		"bridge_flow_matches": bridge_flow_source == bridge_flow_module,
		"bridge_consumption_matches": bridge_consumption_source == bridge_consumption_module,
		"bridge_bars_matches": bridge_bars_source == bridge_bars_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["fixed_one_decimal_matches"] and proof["display_name_matches"] and proof["flow_label_matches"] and proof["override_flow_label_matches"] and proof["flow_items_matches"] and proof["display_consumption_matches"] and proof["display_bars_matches"] and proof["bridge_name_matches"] and proof["bridge_flow_matches"] and proof["bridge_consumption_matches"] and proof["bridge_bars_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_DISPLAY_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingDisplayStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_fixed_one_decimal(value: float) -> String:
	return source_building_display_state.fixed_one_decimal(value)

func _building_display_method_names() -> Dictionary:
	return {
		source_building_display_state.SOURCE_BUILDING_DISPLAY_FIXED_ONE_DECIMAL_KEY: "proof_fixed_one_decimal",
	}
