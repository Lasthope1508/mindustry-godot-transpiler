extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret status() (N2527): `public BlockStatus status(){` /
	# `if(enabled && !hasAmmo()) return BlockStatus.noInput;` /
	# `return super.status();` (Turret.java:369-372), with
	# super.status() the BuildingComp chain
	# (BuildingComp.java:632-646): `if(!enabled){` /
	# `return BlockStatus.logicDisable;` /
	# `if(!shouldConsume()){` / `return BlockStatus.noOutput;` /
	# `if(efficiency <= 0 || !productionValid()){` /
	# `return BlockStatus.noInput;` /
	# `return ((state.tick / 30f) % 1f) < efficiency ?
	# BlockStatus.active : BlockStatus.noInput;`.
	# The Turret leg runs BEFORE super. `has_ammo` is a bool
	# param (hasAmmo() mutates the ammo stack, Turret.java:703,
	# so it cannot be a pure read). `reload` is the per-def
	# reload time (ReloadTurret.java:10, `public float reload
	# = 10f;` -- duo 20f, Blocks.java). The proof drives the
	# pure function on exact legs: 1 enabled + no ammo ->
	# noInput (the Turret leg, before super); 2 disabled +
	# ammo -> logicDisable; 3 enabled + ammo + no consume
	# (reload_counter 10.0 >= reload 10.0, not shooting) ->
	# noOutput; 4 efficiency 0.0 -> noInput; 5 tick 0.0 /
	# efficiency 1.0 -> active (0.0 < 1.0); 6 tick 15.0 /
	# efficiency 0.5 -> noInput (0.5 < 0.5 is false -- the
	# exact boundary); 7 tick 12.0 / efficiency 0.5 ->
	# active (0.4 < 0.5); 8 disabled + no ammo ->
	# logicDisable (the Turret leg needs enabled, so the
	# disabled leg wins -- precedence).
	var frame: Dictionary = {}

	# Phase 1: enabled + no ammo -- the Turret leg fires
	# before super (shouldConsume would be true and
	# efficiency 1.0, yet the answer is noInput).
	frame = {"enabled": true, "is_shooting": true, "reload_counter": 0.0, "efficiency": 1.0}
	var status: Dictionary = turret_build_state.source_turret_status_state(frame, 0.0, false, 10.0)
	proof["status_no_input_enabled_no_ammo"] = str(status.get("status", "")) == "noInput"

	# Phase 2: disabled + ammo -> logicDisable.
	frame = {"enabled": false, "is_shooting": true, "reload_counter": 0.0, "efficiency": 1.0}
	status = turret_build_state.source_turret_status_state(frame, 0.0, true, 10.0)
	proof["status_logic_disable"] = str(status.get("status", "")) == "logicDisable"

	# Phase 3: enabled + ammo + no consume (not shooting,
	# reload_counter 10.0 >= reload 10.0) -> noOutput.
	frame = {"enabled": true, "is_shooting": false, "reload_counter": 10.0, "efficiency": 1.0}
	status = turret_build_state.source_turret_status_state(frame, 0.0, true, 10.0)
	proof["status_no_output_no_consume"] = str(status.get("status", "")) == "noOutput"

	# Phase 4: efficiency 0.0 -> noInput (shooting, so the
	# shouldConsume gate holds).
	frame = {"enabled": true, "is_shooting": true, "reload_counter": 0.0, "efficiency": 0.0}
	status = turret_build_state.source_turret_status_state(frame, 0.0, true, 10.0)
	proof["status_no_input_zero_efficiency"] = str(status.get("status", "")) == "noInput"

	# Phase 5: tick 0.0 / efficiency 1.0 -> active
	# (fmod(0.0 / 30.0, 1.0) = 0.0 < 1.0).
	frame = {"enabled": true, "is_shooting": true, "reload_counter": 0.0, "efficiency": 1.0}
	status = turret_build_state.source_turret_status_state(frame, 0.0, true, 10.0)
	proof["status_active_tick_zero"] = str(status.get("status", "")) == "active"

	# Phase 6: tick 15.0 / efficiency 0.5 -> noInput
	# (fmod(15.0 / 30.0, 1.0) = 0.5, and 0.5 < 0.5 is false
	# -- the exact boundary).
	frame = {"enabled": true, "is_shooting": true, "reload_counter": 0.0, "efficiency": 0.5}
	status = turret_build_state.source_turret_status_state(frame, 15.0, true, 10.0)
	proof["status_no_input_tick_edge"] = str(status.get("status", "")) == "noInput"

	# Phase 7: tick 12.0 / efficiency 0.5 -> active
	# (fmod(12.0 / 30.0, 1.0) = 0.4 < 0.5).
	frame = {"enabled": true, "is_shooting": true, "reload_counter": 0.0, "efficiency": 0.5}
	status = turret_build_state.source_turret_status_state(frame, 12.0, true, 10.0)
	proof["status_active_partial_efficiency"] = str(status.get("status", "")) == "active"

	# Phase 8: disabled + no ammo -> logicDisable (the
	# Turret leg needs enabled, so the disabled leg wins --
	# precedence over the noInput leg).
	frame = {"enabled": false, "is_shooting": true, "reload_counter": 0.0, "efficiency": 1.0}
	status = turret_build_state.source_turret_status_state(frame, 0.0, false, 10.0)
	proof["status_logic_disable_beats_no_ammo"] = str(status.get("status", "")) == "logicDisable"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
