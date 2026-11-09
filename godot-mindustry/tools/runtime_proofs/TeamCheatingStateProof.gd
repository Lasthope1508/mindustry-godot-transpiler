extends Node

const main_scene := preload("res://scenes/Main.tscn")
const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- no rules yet means a fresh TeamRule: cheat defaults false. ---
	proof["team_cheating_missing_rules_false"] = rules_state.source_team_cheating_state({}, 1).get("cheating", true) == false
	proof["team_cheating_null_rules_false"] = rules_state.source_team_cheating_state(null, 1).get("cheating", true) == false
	proof["team_cheating_missing_team_false"] = rules_state.source_team_cheating_state({"teams": {}}, 1).get("cheating", true) == false

	# --- the cheat flag is read per team, int keys or string keys. ---
	var cheating_rules: Dictionary = {"teams": {1: {"cheat": true}, 2: {"cheat": false}}}
	proof["team_cheating_cheat_true"] = rules_state.source_team_cheating_state(cheating_rules, 1).get("cheating", false) == true
	proof["team_cheating_other_team_false"] = rules_state.source_team_cheating_state(cheating_rules, 2).get("cheating", true) == false
	var string_key_rules: Dictionary = {"teams": {"1": {"cheat": true}}}
	proof["team_cheating_string_key_true"] = rules_state.source_team_cheating_state(string_key_rules, 1).get("cheating", false) == true

	# --- the drill tick reads the live cheat flag for its own team. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var frame: Dictionary = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	var team_id: int = int(frame.get("team_id", -1))
	proof["team_cheating_drill_team_known"] = team_id >= 0
	proof["team_cheating_drill_not_cheating_default"] = frame.get("cheating", true) == false
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["team_cheating_drill_frame_sees_cheat"] = frame.get("cheating", false) == true
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["team_cheating_drill_frame_sees_uncheat"] = frame.get("cheating", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TeamCheatingStateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
