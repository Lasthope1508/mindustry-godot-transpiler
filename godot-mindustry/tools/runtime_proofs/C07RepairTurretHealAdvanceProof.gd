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

	# --- RepairTurret heal advance (N2213):
	# RepairPointBuild.updateTile heals the acquired target
	# only when it has efficiency and the beam is aimed at
	# it (`if(target != null && efficiency > 0){` /
	# `float angle = Angles.angle(x, y, target.x +
	# offset.x, target.y + offset.y);` /
	# `if(Angles.angleDist(angle, rotation) < 30f){` /
	# `healed = true;` / `target.heal(repairSpeed *
	# strength * edelta() * multiplier);`,
	# RepairTurret.java:203-207). edelta() is efficiency *
	# delta() (BuildingComp.java:1927-1928, `return
	# efficiency * delta();`), and HealthComp.heal(float)
	# adds the amount and clamps (`health += amount;` /
	# `clampHealth();`, HealthComp.java:109-111). The
	# rotation slerp (RepairTurret.java:208) and the
	# strength lerp (RepairTurret.java:211) are NOT this
	# slice -- they wait for their own slices. The proof
	# calls the pure function
	# source_repair_turret_heal_advance_state(frame, x, y,
	# repair_speed, delta, multiplier) directly with
	# synthetic frames (the N2209 precedent -- the driver
	# tick line lands with GREEN). The turret sits at
	# (0, 0); a target due east (+x) is at angle 90
	# (Angles.angle is atan2(dx, dy) in degrees), so with
	# rotation 90 the aim cone passes, while a target due
	# north (+y) is at angle 0, 90 away from rotation 90,
	# so the cone blocks it. repair_speed 3.0 is the
	# repair-turret def (Blocks.java:6400); delta 1/60 is
	# one tick.
	var east_target: Dictionary = {"id": 1, "x": 10.0, "y": 0.0, "health": 50.0, "max_health": 100.0}
	var north_target: Dictionary = {"id": 2, "x": 0.0, "y": 10.0, "health": 50.0, "max_health": 100.0}

	# Heals when aimed: strength 1, efficiency 1,
	# multiplier 1 -- amount 3 * 1 * (1/60) * 1 = 0.05.
	var frame: Dictionary = {"target": east_target.duplicate(), "efficiency": 1.0, "strength": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	var result: Dictionary = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_applies_when_aimed"] = bool(result.get("healed", false)) and abs(float(result.get("heal_amount", -1.0)) - 0.05) < 0.001 and abs(float(result.get("target_health", -1.0)) - 50.05) < 0.001

	# Scales with strength: strength 0.5 halves the amount.
	frame = {"target": east_target.duplicate(), "efficiency": 1.0, "strength": 0.5, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_scales_with_strength"] = bool(result.get("healed", false)) and abs(float(result.get("heal_amount", -1.0)) - 0.025) < 0.001

	# Scales with efficiency: efficiency 0.5 halves edelta.
	frame = {"target": east_target.duplicate(), "efficiency": 0.5, "strength": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_scales_with_efficiency"] = bool(result.get("healed", false)) and abs(float(result.get("heal_amount", -1.0)) - 0.025) < 0.001

	# Blocked without power: efficiency 0 heals nothing.
	frame = {"target": east_target.duplicate(), "efficiency": 0.0, "strength": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_blocked_without_power"] = not bool(result.get("healed", true)) and abs(float(result.get("heal_amount", -1.0)) - 0.0) < 0.001 and abs(float(result.get("target_health", -1.0)) - 50.0) < 0.001

	# Blocked outside the aim cone: north target, rotation
	# 90 -- angle distance 90, above the strict 30 cone.
	frame = {"target": north_target.duplicate(), "efficiency": 1.0, "strength": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_blocked_outside_aim_cone"] = not bool(result.get("healed", true)) and abs(float(result.get("target_health", -1.0)) - 50.0) < 0.001

	# Clamps at max health: 99.99 + 0.05 stops at 100.0.
	var full_target: Dictionary = {"id": 3, "x": 10.0, "y": 0.0, "health": 99.99, "max_health": 100.0}
	frame = {"target": full_target, "efficiency": 1.0, "strength": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_clamps_at_max_health"] = bool(result.get("healed", false)) and abs(float(result.get("target_health", -1.0)) - 100.0) < 0.001

	# Applies the coolant multiplier: multiplier 2.6
	# (1 + 0.5 heat * 1.6 coolantMultiplier * 1.0
	# optionalEfficiency, the N2209 formula) scales the
	# amount to 0.13.
	frame = {"target": east_target.duplicate(), "efficiency": 1.0, "strength": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 2.6)
	proof["heal_applies_coolant_multiplier"] = bool(result.get("healed", false)) and abs(float(result.get("heal_amount", -1.0)) - 0.13) < 0.001 and abs(float(result.get("target_health", -1.0)) - 50.13) < 0.001

	# Flag set even at zero strength: Java sets `healed =
	# true;` before the heal call, so the gate flag is true
	# with a 0.0 amount and unchanged health.
	frame = {"target": east_target.duplicate(), "efficiency": 1.0, "strength": 0.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_heal_advance_state(frame, 0.0, 0.0, 3.0, 1.0 / 60.0, 1.0)
	proof["heal_flag_set_even_at_zero_strength"] = bool(result.get("healed", false)) and abs(float(result.get("heal_amount", -1.0)) - 0.0) < 0.001 and abs(float(result.get("target_health", -1.0)) - 50.0) < 0.001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretHealAdvanceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
