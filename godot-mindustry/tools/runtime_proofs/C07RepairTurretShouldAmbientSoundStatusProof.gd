extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret shouldAmbientSound/status (N2221):
	# RepairPointBuild.shouldAmbientSound() returns `target !=
	# null && efficiency > 0f` (RepairTurret.java:182, inside
	# `public boolean shouldAmbientSound(){`,
	# RepairTurret.java:181) and RepairPointBuild.status()
	# returns `Mathf.equal(potentialEfficiency, 0f, 0.01f) ?
	# BlockStatus.noInput : super.status()`
	# (RepairTurret.java:226, inside `public BlockStatus
	# status(){`, RepairTurret.java:225). super.status() is
	# BuildingComp.status() (BuildingComp.java:632-646):
	# disabled -> logicDisable, shouldConsume false ->
	# noOutput, efficiency <= 0 or productionValid false ->
	# noInput, else the tick flicker `((state.tick / 30f) %
	# 1f) < efficiency ? active : noInput`. The proof calls the
	# pure functions with synthetic frames (no live tick:
	# status() / shouldAmbientSound() are read functions, not
	# per-tick; the tick arrives as an explicit param).

	# Ambient true with a target and efficiency above zero.
	var ambient_on: Dictionary = repair_turret_build_state.source_repair_turret_should_ambient_sound_state({"has_target": true, "efficiency": 1.0})
	proof["ambient_true_target_and_efficiency"] = bool(ambient_on.get("should_ambient_sound", false))

	# Ambient false with no target, even at full efficiency.
	var ambient_no_target: Dictionary = repair_turret_build_state.source_repair_turret_should_ambient_sound_state({"has_target": false, "efficiency": 1.0})
	proof["ambient_false_no_target"] = not bool(ambient_no_target.get("should_ambient_sound", true))

	# Ambient false with a target but zero efficiency.
	var ambient_no_efficiency: Dictionary = repair_turret_build_state.source_repair_turret_should_ambient_sound_state({"has_target": true, "efficiency": 0.0})
	proof["ambient_false_zero_efficiency"] = not bool(ambient_no_efficiency.get("should_ambient_sound", true))

	# Status noInput with zero potential efficiency.
	var status_zero: Dictionary = repair_turret_build_state.source_repair_turret_status_state({"potential_efficiency": 0.0, "enabled": true, "has_target": true, "efficiency": 1.0}, 0.0)
	proof["status_no_input_zero_potential"] = str(status_zero.get("status", "")) == "noInput"

	# Status noInput with near-zero potential efficiency, inside
	# the 0.01 Mathf.equal tolerance.
	var status_near_zero: Dictionary = repair_turret_build_state.source_repair_turret_status_state({"potential_efficiency": 0.005, "enabled": true, "has_target": true, "efficiency": 1.0}, 0.0)
	proof["status_no_input_near_zero_potential"] = str(status_near_zero.get("status", "")) == "noInput"

	# Status logicDisable when disabled, even at full potential.
	var status_disabled: Dictionary = repair_turret_build_state.source_repair_turret_status_state({"potential_efficiency": 1.0, "enabled": false, "has_target": true, "efficiency": 1.0}, 0.0)
	proof["status_logic_disable"] = str(status_disabled.get("status", "")) == "logicDisable"

	# Status noOutput when shouldConsume is false (no target),
	# even at full potential and enabled.
	var status_no_consume: Dictionary = repair_turret_build_state.source_repair_turret_status_state({"potential_efficiency": 1.0, "enabled": true, "has_target": false, "efficiency": 1.0}, 0.0)
	proof["status_no_output_no_consume"] = str(status_no_consume.get("status", "")) == "noOutput"

	# Status active with full potential, a target, full
	# efficiency and tick 0 ((0 / 30) % 1 = 0 < 1.0).
	var status_active: Dictionary = repair_turret_build_state.source_repair_turret_status_state({"potential_efficiency": 1.0, "enabled": true, "has_target": true, "efficiency": 1.0}, 0.0)
	proof["status_active"] = str(status_active.get("status", "")) == "active"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretShouldAmbientSoundStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
