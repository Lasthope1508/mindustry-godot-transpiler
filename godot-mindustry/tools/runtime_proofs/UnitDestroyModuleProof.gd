extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_unit_destroy_state := preload("res://src/game/SourceUnitDestroyState.gd")
const source_unit_destroy_effects_state := preload("res://src/game/SourceUnitDestroyEffectsState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var remove_state := game.source_unit_remove_state(true, 3, 2.0, false, "team-color", "type-color")
	var initial_payload_state := game.source_unit_destroy_initial_payload_state(true, true, 1.0, 2.0, 3.0, 4)
	var explosion_dispatch_state := game.source_unit_destroy_explosion_dispatch_state(false, 10.0, 11.0, 1.5, 2.5, 3.5, 12.0, 4.0, true, 1.0, 1.5, 2, "death-explosion")
	var visual_effects_state := game.source_unit_destroy_visual_effects_state(10.0, 11.0, 6.0, -1.0, true, 42)
	var sound_and_event_state := game.source_unit_destroy_sound_and_event_state("boom", 0.8, 42)
	var suicide_bomb_trigger_state := game.source_unit_destroy_suicide_bomb_trigger_state(8.0, true, false)
	var mount_states := [
		{
			"shootOnDeath": true,
			"bulletKillShooter": false,
			"totalShots": 0,
			"shootOnDeathEffect": "shoot-effect",
		},
	]
	var shoot_on_death_mounts_state := game.source_unit_destroy_shoot_on_death_mounts_state(mount_states, false, 10.0, 11.0, 90.0, 42)
	var crash_landing_damage_state := game.source_unit_destroy_crash_landing_damage_state(true, false, true, 1.0, 6.0, 2.0, true, false, 2, 10.0, 11.0)
	var wreck_regions := [
		{"found": true, "name": "wreck-a"},
		{"found": false, "name": "wreck-b"},
	]
	var tmp_offsets := [
		{"x": 1.0, "y": 2.0},
		{"x": 3.0, "y": 4.0},
	]
	var wreck_decal_state := game.source_unit_destroy_wreck_decal_state(false, true, wreck_regions, tmp_offsets, 10.0, 11.0, 180.0, 8.0)
	var ability_states := [
		{"id": "ability-a"},
		{"id": "ability-b"},
	]
	var ability_death_state := game.source_unit_destroy_ability_death_state(ability_states, 42)
	var type_killed_remove_state := game.source_unit_destroy_type_killed_remove_state(42)
	var killed_state := game.source_unit_killed_state(true, 5.0, false, true, "wreck", 0.7, 42)
	var kill_sync_state := game.source_unit_kill_sync_state(false, false, true, 42)
	var proof := {
		"module": "UNIT_DESTROY_MODULE_PROOF",
		"remove_matches": remove_state == source_unit_destroy_state.remove_state(true, 3, 2.0, false, "team-color", "type-color"),
		"initial_payload_matches": initial_payload_state == source_unit_destroy_state.initial_payload_state(true, true, 1.0, 2.0, 3.0, 4) and initial_payload_state == source_unit_destroy_effects_state.initial_payload_state(true, true, 1.0, 2.0, 3.0, 4),
		"explosion_dispatch_matches": explosion_dispatch_state == source_unit_destroy_state.explosion_dispatch_state(false, 10.0, 11.0, 1.5, 2.5, 3.5, 12.0, 4.0, true, 1.0, 1.5, 2, "death-explosion") and explosion_dispatch_state == source_unit_destroy_effects_state.explosion_dispatch_state(false, 10.0, 11.0, 1.5, 2.5, 3.5, 12.0, 4.0, true, 1.0, 1.5, 2, "death-explosion"),
		"visual_effects_matches": visual_effects_state == source_unit_destroy_state.visual_effects_state(10.0, 11.0, 6.0, -1.0, true, 42) and visual_effects_state == source_unit_destroy_effects_state.visual_effects_state(10.0, 11.0, 6.0, -1.0, true, 42),
		"sound_and_event_matches": sound_and_event_state == source_unit_destroy_state.sound_and_event_state("boom", 0.8, 42) and sound_and_event_state == source_unit_destroy_effects_state.sound_and_event_state("boom", 0.8, 42),
		"suicide_bomb_trigger_matches": suicide_bomb_trigger_state == source_unit_destroy_state.suicide_bomb_trigger_state(8.0, true, false) and suicide_bomb_trigger_state == source_unit_destroy_effects_state.suicide_bomb_trigger_state(8.0, true, false),
		"shoot_on_death_mounts_matches": shoot_on_death_mounts_state == source_unit_destroy_state.shoot_on_death_mounts_state(mount_states, false, 10.0, 11.0, 90.0, 42),
		"crash_landing_damage_matches": crash_landing_damage_state == source_unit_destroy_state.crash_landing_damage_state(true, false, true, 1.0, 6.0, 2.0, true, false, 2, 10.0, 11.0),
		"wreck_decal_matches": wreck_decal_state == source_unit_destroy_state.wreck_decal_state(false, true, wreck_regions, tmp_offsets, 10.0, 11.0, 180.0, 8.0),
		"ability_death_matches": ability_death_state == source_unit_destroy_state.ability_death_state(ability_states, 42),
		"type_killed_remove_matches": type_killed_remove_state == source_unit_destroy_state.type_killed_remove_state(42),
		"killed_matches": killed_state == source_unit_destroy_state.killed_state(true, 5.0, false, true, "wreck", 0.7, 42),
		"kill_sync_matches": kill_sync_state == source_unit_destroy_state.kill_sync_state(false, false, true, 42),
		"effects_module_matches": initial_payload_state == source_unit_destroy_effects_state.initial_payload_state(true, true, 1.0, 2.0, 3.0, 4) and explosion_dispatch_state == source_unit_destroy_effects_state.explosion_dispatch_state(false, 10.0, 11.0, 1.5, 2.5, 3.5, 12.0, 4.0, true, 1.0, 1.5, 2, "death-explosion") and visual_effects_state == source_unit_destroy_effects_state.visual_effects_state(10.0, 11.0, 6.0, -1.0, true, 42) and sound_and_event_state == source_unit_destroy_effects_state.sound_and_event_state("boom", 0.8, 42) and suicide_bomb_trigger_state == source_unit_destroy_effects_state.suicide_bomb_trigger_state(8.0, true, false),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["remove_matches"] and proof["initial_payload_matches"] and proof["explosion_dispatch_matches"] and proof["visual_effects_matches"] and proof["sound_and_event_matches"] and proof["suicide_bomb_trigger_matches"] and proof["shoot_on_death_mounts_matches"] and proof["crash_landing_damage_matches"] and proof["wreck_decal_matches"] and proof["ability_death_matches"] and proof["type_killed_remove_matches"] and proof["killed_matches"] and proof["kill_sync_matches"] and proof["effects_module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitDestroyModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

