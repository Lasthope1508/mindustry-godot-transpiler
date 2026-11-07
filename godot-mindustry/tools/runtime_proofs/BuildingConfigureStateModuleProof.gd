extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_configure_state := preload("res://src/game/SourceBuildingConfigureState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

var tile_config_calls: Array = []
var hide_config_calls := 0

func _tile_config_callback(player_state: Variant, self_state: Variant, value: Variant) -> void:
	tile_config_calls.append({"player": player_state, "self": self_state, "value": value})

func _hide_config_callback() -> void:
	hide_config_calls += 1

func _ready() -> void:
	var game: PortGame = PortGameScript.new()
	game.load_content_registry()
	var value_state: Dictionary = {"kind": "Item", "class": "CopperItem", "is_null": false}
	var anonymous_value_state: Dictionary = {"superclass": "LogicBlock", "class": "Anon", "is_anonymous_class": true, "is_null": false}
	var builder_state: Dictionary = {"exists": true, "is_player": true, "colored_name": "[accent]Builder"}
	var direct_value_state: Dictionary = {"config": "enabled"}
	var copied_config: Dictionary = {"payload": "router"}
	var player_state: Dictionary = {"id": 1, "name": "player"}
	var self_state: Dictionary = {"id": 6}
	var block_state: Dictionary = {"lastConfig": "old"}
	var callback := Callable(self, "_tile_config_callback")
	var hide_callback := Callable(self, "_hide_config_callback")
	var table_state: Dictionary = {"id": "build-table"}
	var build_configuration := game.source_building_build_configuration_state(table_state)
	var build_configuration_canonical := source_building_configure_state.build_configuration_state(table_state)
	var mouse_screen_state: Dictionary = {"x": 320.0, "y": 180.0}
	var update_table_align := game.source_building_update_table_align_state(table_state, 64.0, 96.0, 3, 8.0, mouse_screen_state)
	var update_table_align_canonical := source_building_configure_state.update_table_align_state(table_state, 64.0, 96.0, 3, 8.0, mouse_screen_state)
	var local_configure := game.source_building_configure_local_state(block_state, player_state, self_state, "enabled", callback)
	var local_configure_canonical := source_building_configure_state.configure_state(block_state, player_state, self_state, "enabled", callback)
	var server_configure := game.source_building_configure_any_state(self_state, "server-enabled", callback)
	var server_configure_canonical := source_building_configure_state.configure_any_state(self_state, "server-enabled", callback)
	var deselect_selected := game.source_building_deselect_state(false, self_state, self_state, hide_callback)
	var deselect_selected_canonical := source_building_configure_state.deselect_state(false, self_state, self_state, hide_callback)
	var deselect_headless := game.source_building_deselect_state(true, self_state, self_state, hide_callback)
	var deselect_other := game.source_building_deselect_state(false, {"id": 7}, self_state, hide_callback)
	var source_matches: Array[bool] = [
		game.source_building_configured_type_state(value_state) == source_building_configure_state.configured_type_state(value_state),
		game.source_building_configured_type_state(anonymous_value_state) == source_building_configure_state.configured_type_state(anonymous_value_state),
		game.source_building_configured_last_access_state(builder_state, "old") == source_building_configure_state.configured_last_access_state(builder_state, "old"),
		game.source_building_configured_direct_handler_state(true, "Item", direct_value_state) == source_building_configure_state.configured_direct_handler_state(true, "Item", direct_value_state),
		game.source_building_configured_copy_config_state(true, copied_config, false) == source_building_configure_state.configured_copy_config_state(true, copied_config, false),
		game.source_building_on_configure_build_tapped_state(true, true) == source_building_configure_state.on_configure_build_tapped_state(true, true),
		game.source_building_on_configure_tapped_state(16.0, 24.0) == source_building_configure_state.on_configure_tapped_state(16.0, 24.0),
		game.source_building_on_configure_closed_state() == source_building_configure_state.on_configure_closed_state(),
		game.source_building_configure_menu_visibility_state(player_state) == source_building_configure_state.configure_menu_visibility_state(player_state),
		game.source_building_should_show_configure_state(player_state) == source_building_configure_state.should_show_configure_state(player_state),
		game.source_building_should_hide_configure_state(player_state) == source_building_configure_state.should_hide_configure_state(player_state),
		local_configure == local_configure_canonical,
		server_configure == server_configure_canonical,
		deselect_selected == deselect_selected_canonical,
		not bool(deselect_headless.get("hide_config", true)),
		not bool(deselect_other.get("hide_config", true)),
		game.source_building_config_tapped_state(),
		build_configuration == build_configuration_canonical,
		update_table_align == update_table_align_canonical,
	]
	var generated_matches: Array[bool] = [
		game.generated_building_comp_configured_type_bridge_state(value_state) == source_building_configure_state.generated_configured_type_bridge_state(value_state),
		game.generated_building_comp_update_last_access_bridge_state(builder_state, "old") == source_building_configure_state.generated_update_last_access_bridge_state(builder_state, "old"),
		game.generated_building_comp_on_configure_tapped_bridge_state(16.0, 24.0) == source_building_configure_state.generated_on_configure_tapped_bridge_state(16.0, 24.0),
		game.generated_building_comp_on_configure_closed_bridge_state() == source_building_configure_state.generated_on_configure_closed_bridge_state(),
		game.generated_building_comp_should_show_configure_bridge_state(player_state) == source_building_configure_state.generated_should_show_configure_bridge_state(player_state),
		game.generated_building_comp_should_hide_configure_bridge_state(player_state) == source_building_configure_state.generated_should_hide_configure_bridge_state(player_state),
		game.generated_building_comp_configure_bridge_state(block_state, player_state, self_state, "enabled") == source_building_configure_state.generated_configure_bridge_state(block_state, player_state, self_state, "enabled"),
		game.generated_building_comp_configure_any_bridge_state(self_state, "server-enabled") == source_building_configure_state.generated_configure_any_bridge_state(self_state, "server-enabled"),
		game.generated_building_comp_deselect_bridge_state(false, self_state, self_state) == source_building_configure_state.generated_deselect_bridge_state(false, self_state, self_state),
		game.generated_building_comp_config_tapped_bridge_state() == source_building_configure_state.generated_config_tapped_bridge_state(),
		game.generated_building_comp_build_configuration_bridge_state(table_state) == source_building_configure_state.generated_build_configuration_bridge_state(table_state),
		game.generated_building_comp_update_table_align_bridge_state(table_state, 64.0, 96.0, 3, 8.0, mouse_screen_state) == source_building_configure_state.generated_update_table_align_bridge_state(table_state, 64.0, 96.0, 3, 8.0, mouse_screen_state),
	]
	var callback_matches: bool = (
		local_configure.get("block_state", {}).get("lastConfig") == "enabled"
		and server_configure.get("player") == null
		and not server_configure.has("block_state")
		and tile_config_calls.size() == 4
		and tile_config_calls[0] == {"player": player_state, "self": self_state, "value": "enabled"}
		and tile_config_calls[2] == {"player": null, "self": self_state, "value": "server-enabled"}
		and hide_config_calls == 2
	)
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var configure_tap_branches_match := true
	# Expected values come from the Java branches, independently of the canonical helper.
	for case in [[true, true, true, false], [true, false, false, true], [false, true, false, false], [false, false, false, true]]:
		var bridge: Dictionary = game.generated_building_comp_on_configure_build_tapped_bridge_state(case[0], case[1])
		var actual: Variant = bridge.get("result")
		configure_tap_branches_match = configure_tap_branches_match and bool(bridge.get("matches", false))
		configure_tap_branches_match = configure_tap_branches_match and actual is Dictionary
		if actual is Dictionary:
			configure_tap_branches_match = configure_tap_branches_match and actual.get("deselect") == case[2] and actual.get("configure_null") == case[2] and actual.get("consumed") == case[3]
	var proof: Dictionary = {
		"module": "BUILDING_CONFIGURE_STATE_MODULE_PROOF",
		"source_matches": source_matches,
		"generated_matches": generated_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"callback_matches": callback_matches,
		"configure_tap_branches_match": configure_tap_branches_match,
	}
	proof["matches"] = not source_matches.has(false) and not generated_matches.has(false) and callback_matches and configure_tap_branches_match and bool(proof["one_headquarter_per_ssot"]) and bool(proof["registry_valid"])
	var proof_label := get_node_or_null("ProofCanvas/ProofLabel") as Label
	if proof_label != null:
		proof_label.text = "BUILDING_CONFIGURE_STATE_MODULE_PROOF matches=%s registry_valid=%s" % [str(proof["matches"]), str(proof["registry_valid"])]
	print("BUILDING_CONFIGURE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingConfigureStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

