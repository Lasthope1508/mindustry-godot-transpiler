extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingDisplayState := preload("res://src/game/SourceBuildingDisplayState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceBuildingDisplayState.default_callbacks_state(game)
	var expected_callbacks := {
		"fixed_one_decimal": Callable(game, "source_arc_strings_fixed_one_decimal"),
	}

	var display_name_source := game.source_building_display_name_state("Copper Wall", false, true, "?", "Derelict")
	var display_name_module := SourceBuildingDisplayState.display_name_state("Copper Wall", false, true, "?", "Derelict")
	var flow_label_source := game.source_building_display_flow_rate_label(12.34, "/sec")
	var flow_label_module := SourceBuildingDisplayState.display_flow_rate_label(12.34, "/sec", callbacks.get("fixed_one_decimal", Callable()))
	var flow_items_source: Variant = game.source_building_flow_items_state({"name": "copper"})
	var flow_items_module: Variant = SourceBuildingDisplayState.flow_items_state({"name": "copper"})
	var display_consumption_source := game.source_building_display_consumption_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var display_consumption_module := SourceBuildingDisplayState.display_consumption_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var display_bars_source := game.source_building_display_bars_state([null, {"bar": "ok"}])
	var display_bars_module := SourceBuildingDisplayState.display_bars_state([null, {"bar": "ok"}])

	var bridge_name_source := game.generated_building_comp_get_display_name_bridge_state("Copper Wall", false, true, "?", "Derelict")
	var bridge_name_module := SourceBuildingDisplayState.generated_building_comp_get_display_name_bridge_state("Copper Wall", false, true, "?", "Derelict")
	var bridge_flow_source := game.generated_building_comp_flow_items_bridge_state({"name": "copper"})
	var bridge_flow_module := SourceBuildingDisplayState.generated_building_comp_flow_items_bridge_state({"name": "copper"})
	var bridge_consumption_source := game.generated_building_comp_display_consumption_bridge_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var bridge_consumption_module := SourceBuildingDisplayState.generated_building_comp_display_consumption_bridge_state([
		{"optional": true, "booster": true, "name": "skip"},
		{"optional": false, "booster": true, "name": "keep"},
	], {"id": 7})
	var bridge_bars_source := game.generated_building_comp_display_bars_bridge_state([null, {"bar": "ok"}])
	var bridge_bars_module := SourceBuildingDisplayState.generated_building_comp_display_bars_bridge_state([null, {"bar": "ok"}])

	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingDisplayState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"display_name_matches": display_name_source == display_name_module,
		"flow_label_matches": flow_label_source == flow_label_module,
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
	print("BUILDING_DISPLAY_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(10.0).timeout
	get_tree().quit(0)
