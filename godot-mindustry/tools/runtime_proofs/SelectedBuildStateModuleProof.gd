extends Node

const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var build_palette := [{"properties": {"hasPower": true}}]
	var selected := source_selected_build_state.selected_build(build_palette, 0)
	var selected_build_matches: bool = selected == build_palette[0]
	var has_power_matches: bool = source_selected_build_state.has_power(selected) == true
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceSelectedBuildState",
		"selected_build_matches": selected_build_matches,
		"has_power_matches": has_power_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("SELECTED_BUILD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
