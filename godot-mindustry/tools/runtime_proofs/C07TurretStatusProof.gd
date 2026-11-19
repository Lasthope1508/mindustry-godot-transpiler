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

	# --- Turret status() block status (N2285): TurretBuild.status()
	# (Turret.java:369-374) returns noInput when enabled with no
	# ammo, else super.status() -- BaseTurretBuild.status()
	# (BaseTurret.java:143-145) returns the BuildingComp.status()
	# result while the activation timer is at most zero, else
	# BlockStatus.inactive:
	# `public BlockStatus status(){`
	# `if(enabled && !hasAmmo()) return BlockStatus.noInput;`
	# ``
	# `return super.status();`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). enabled arrives from the tick frame
	# (absent reads true); has_ammo, activation_timer and
	# building_status arrive as explicit params -- hasAmmo()
	# (Turret.java:698-712) is NOT ported here (the N2311/N2261
	# precedent), and building_status carries the live N1888
	# PortGame.source_building_status_state result. NO driver tick
	# line: status() is a read accessor. The proof calls the pure
	# function with synthetic frames (no live tick: status is a
	# pure accessor over the frame's enabled plus three explicit
	# params).

	# Enabled with no ammo returns noInput even while activating:
	# timer 60, building leg active -- the Turret leg fires first.
	var no_input: Dictionary = turret_build_state.source_turret_status_state({"enabled": true}, false, 60.0, "active")
	proof["status_no_input_enabled_no_ammo"] = String(no_input.get("status", "")) == "noInput"

	# The building leg passes active through at timer zero: the
	# BaseTurret leg returns super.status() while the timer is at
	# most zero.
	var active: Dictionary = turret_build_state.source_turret_status_state({"enabled": true}, true, 0.0, "active")
	proof["status_building_active"] = String(active.get("status", "")) == "active"

	# The building leg passes noInput through at timer zero.
	var building_no_input: Dictionary = turret_build_state.source_turret_status_state({"enabled": true}, true, 0.0, "noInput")
	proof["status_building_no_input"] = String(building_no_input.get("status", "")) == "noInput"

	# A disabled turret with ammo falls through to the building
	# leg's logicDisable: the first leg needs enabled, and the
	# N1888 helper already returns logicDisable for !enabled.
	var logic_disable: Dictionary = turret_build_state.source_turret_status_state({"enabled": false}, true, 0.0, "logicDisable")
	proof["status_building_logic_disable"] = String(logic_disable.get("status", "")) == "logicDisable"

	# A positive timer returns inactive even with an active
	# building leg: BaseTurret.java:144, `BlockStatus.inactive`.
	var inactive: Dictionary = turret_build_state.source_turret_status_state({"enabled": true}, true, 60.0, "active")
	proof["status_inactive"] = String(inactive.get("status", "")) == "inactive"

	# A disabled turret with no ammo and a positive timer still
	# returns inactive: the first leg needs enabled (so it does
	# not fire), and the BaseTurret leg does not check enabled.
	var inactive_disabled: Dictionary = turret_build_state.source_turret_status_state({"enabled": false}, false, 60.0, "logicDisable")
	proof["status_inactive_disabled_no_ammo"] = String(inactive_disabled.get("status", "")) == "inactive"

	# A disabled turret with no ammo at timer zero falls through
	# to the building leg's logicDisable (the first leg needs
	# enabled, the timer leg returns super.status()).
	var disabled_no_ammo: Dictionary = turret_build_state.source_turret_status_state({"enabled": false}, false, 0.0, "logicDisable")
	proof["status_disabled_no_ammo_falls_to_building"] = String(disabled_no_ammo.get("status", "")) == "logicDisable"

	# A negative timer still takes the building leg (<= 0): the
	# BaseTurret comparison is `activationTimer <= 0`, not `== 0`.
	var negative_timer: Dictionary = turret_build_state.source_turret_status_state({"enabled": true}, true, -1.0, "noOutput")
	proof["status_negative_timer_building_leg"] = String(negative_timer.get("status", "")) == "noOutput"

	# The result carries ONLY the one status key: no frame echo,
	# no extra state.
	proof["returns_only_one_key"] = no_input.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
