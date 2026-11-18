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

	# --- Turret isActive() activity gate (N2279): TurretBuild.isActive()
	# (Turret.java:449-451) returns true only while the turret has a
	# target or shot on the previous tick, is enabled, and its placement
	# activation timer has elapsed:
	# `public boolean isActive(){`
	# `return (target != null || wasShooting) && enabled && activationTimer <= 0;`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). The target arrives as target_is_null (the
	# invalidateTarget :488 precedent), wasShooting arrives as is_shooting
	# (the should_consume :164 / sense :267 / update_tile_warmup :384
	# precedent -- named is_shooting per the family convention, but for
	# isActive() it carries wasShooting, Turret.java:292, set in
	# updateTile :517/:600/:608), activationTimer arrives as the explicit
	# float activation_timer (the frame tracks no activation timer key),
	# and enabled is read from the frame (the tick frame stamps
	# frame["enabled"], default true, BuildingComp.java:77
	# `transient boolean enabled = true;`). The comparison is `<= 0`: a
	# timer of exactly 0 is active. NO driver tick line: isActive() is a
	# predicate the tick driver reads, not a tick write of its own. The
	# proof calls the pure function with synthetic frames (no live tick:
	# isActive is a pure predicate over four inputs).

	# Active with a target: target present, not shooting, frame default
	# enabled true, activation timer 0 -> true.
	var with_target: Dictionary = turret_build_state.source_turret_is_active_state({}, false, false, 0.0)
	proof["active_with_target"] = bool(with_target.get("is_active", false))

	# Active while shooting: no target, but shot on the previous tick,
	# enabled, timer 0 -> true.
	var while_shooting: Dictionary = turret_build_state.source_turret_is_active_state({}, true, true, 0.0)
	proof["active_while_shooting"] = bool(while_shooting.get("is_active", false))

	# Inactive with no target and not shooting: nothing to shoot at and
	# no previous-tick shot, enabled, timer 0 -> false.
	var idle: Dictionary = turret_build_state.source_turret_is_active_state({}, true, false, 0.0)
	proof["inactive_no_target_not_shooting"] = not bool(idle.get("is_active", true))

	# Inactive when disabled: target present, but the frame says disabled
	# -> false, even though the target and timer legs hold.
	var disabled: Dictionary = turret_build_state.source_turret_is_active_state({"enabled": false}, false, false, 0.0)
	proof["inactive_when_disabled"] = not bool(disabled.get("is_active", true))

	# Inactive while the activation timer is positive: target present,
	# enabled, timer 5.0 (still counting down from activationTime) -> false.
	var activating: Dictionary = turret_build_state.source_turret_is_active_state({}, false, false, 5.0)
	proof["inactive_while_activation_timer_positive"] = not bool(activating.get("is_active", true))

	# Active at an activation timer of exactly 0: the `<= 0` boundary --
	# a timer of exactly 0 counts as elapsed, matching Java exactly.
	var at_zero: Dictionary = turret_build_state.source_turret_is_active_state({}, false, false, 0.0)
	proof["active_at_activation_timer_zero"] = bool(at_zero.get("is_active", false))

	# Active at a negative activation timer: below zero is also elapsed.
	var negative: Dictionary = turret_build_state.source_turret_is_active_state({}, false, false, -1.0)
	proof["active_at_activation_timer_negative"] = bool(negative.get("is_active", false))

	# The result carries ONLY the one is_active key: no frame echo, no
	# extra state.
	proof["returns_only_one_key"] = with_target.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretIsActiveProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
