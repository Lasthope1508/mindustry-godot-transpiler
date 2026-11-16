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

	# --- RepairTurret strength lerp (N2215):
	# RepairPointBuild.updateTile fades the beam strength
	# toward 1 while healing and toward 0 otherwise
	# (`strength = Mathf.lerpDelta(strength, healed ? 1f
	# : 0f, 0.08f * Time.delta);`,
	# RepairTurret.java:212). Unlike the heal and the
	# slerp, the lerp sits OUTSIDE the `if(target != null
	# && efficiency > 0){` gate (RepairTurret.java:203) --
	# it runs on EVERY tick, so a turret that stops
	# healing decays its beam back to 0 instead of
	# freezing at full strength. `healed` is the same
	# tick's local (`boolean healed = false;`,
	# RepairTurret.java:200, set `healed = true;` only
	# inside the aim cone, RepairTurret.java:206, before
	# the heal `target.heal(repairSpeed * strength *
	# edelta() * multiplier);`, RepairTurret.java:207) --
	# the N2213 heal stamps it on the frame, so the pure
	# function reads `frame["healed"]` (absent -> false).
	# strength is a Java field (`public float strength,
	# rotation = 90;`, RepairTurret.java:155), default 0.
	# Mathf.lerpDelta multiplies its progress by
	# Time.delta and clamps to [0, 1] (`return
	# lerp(fromValue, toValue, clamp(progress *
	# Time.delta));`, Mathf.java:431), and lerp is the
	# plain linear interpolation (`return fromValue +
	# (toValue - fromValue) * progress;`,
	# Mathf.java:426). The proof calls the pure function
	# source_repair_turret_strength_lerp_state(frame,
	# delta) directly with synthetic frames (the N2214
	# precedent -- the driver tick line lands with GREEN).
	# delta 1/60 is one tick, so one tick moves the
	# strength by 0.08 / 60 = 0.0013333 of the gap to its
	# target (1 while healing, 0 otherwise).
	var frame: Dictionary = {"strength": 0.5, "healed": true}
	var result: Dictionary = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0 / 60.0)
	proof["strength_rises_toward_one_when_healed"] = abs(float(result.get("strength", -1.0)) - 0.5006667) < 0.0001

	# Decays toward 0 when not healing: strength 0.5,
	# healed false -- one tick covers 0.5 * 0.0013333 =
	# 0.0006667 of the gap, so strength becomes 0.4993333.
	frame = {"strength": 0.5, "healed": false}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0 / 60.0)
	proof["strength_decays_toward_zero_when_not_healed"] = abs(float(result.get("strength", -1.0)) - 0.4993333) < 0.0001

	# Rises from 0 when healing: strength 0.0, healed --
	# one tick covers 1.0 * 0.0013333, so strength becomes
	# 0.0013333.
	frame = {"strength": 0.0, "healed": true}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0 / 60.0)
	proof["strength_rises_from_zero_when_healed"] = abs(float(result.get("strength", -1.0)) - 0.0013333) < 0.0001

	# Decays from 1 when not healing: strength 1.0,
	# healed false -- one tick covers 1.0 * 0.0013333, so
	# strength becomes 0.9986667.
	frame = {"strength": 1.0, "healed": false}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0 / 60.0)
	proof["strength_decays_from_one_when_not_healed"] = abs(float(result.get("strength", -1.0)) - 0.9986667) < 0.0001

	# Scales with delta: a 1-second delta moves the
	# strength by 0.08 of the gap, so 0.5 healing becomes
	# 0.5 + 0.5 * 0.08 = 0.54.
	frame = {"strength": 0.5, "healed": true}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0)
	proof["strength_scales_with_delta"] = abs(float(result.get("strength", -1.0)) - 0.54) < 0.001

	# Clamps progress at 1: a huge delta (60.0 seconds)
	# pushes 0.08 * 60 = 4.8 past the [0, 1] clamp, so
	# progress is 1.0 and strength 0.25 lands exactly on
	# the healed target 1.0.
	frame = {"strength": 0.25, "healed": true}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 60.0)
	proof["strength_clamps_progress_at_one"] = abs(float(result.get("strength", -1.0)) - 1.0) < 0.001

	# Unchanged at 1 when healing: already at the target,
	# the gap is 0, so strength stays 1.0.
	frame = {"strength": 1.0, "healed": true}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0 / 60.0)
	proof["strength_unchanged_at_one_when_healed"] = abs(float(result.get("strength", -1.0)) - 1.0) < 0.001

	# Unchanged at 0 when not healing: already at the
	# target, the gap is 0, so strength stays 0.0.
	frame = {"strength": 0.0, "healed": false}
	result = repair_turret_build_state.source_repair_turret_strength_lerp_state(frame, 1.0 / 60.0)
	proof["strength_unchanged_at_zero_when_not_healed"] = abs(float(result.get("strength", -1.0)) - 0.0) < 0.001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretStrengthLerpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
