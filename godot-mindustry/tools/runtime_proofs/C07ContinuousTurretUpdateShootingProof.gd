extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceContinuousTurretBuildPortBridge.gd")
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

	# --- ContinuousTurretBuild.updateShooting() (N2367):
	# ContinuousTurretBuild.updateShooting()
	# (ContinuousTurret.java:138-146) fires one shot of the
	# peeked ammo exactly when no bullet is flying and the
	# consume / charging / warmup guard holds:
	# `protected void updateShooting(){`
	# `if(bullets.any()){`
	# `return;`
	# `}`
	# `if(canConsume() && !charging() && shootWarmup >= minWarmup){`
	# `shoot(peekAmmo());`
	# `}`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). Unlike LaserTurret.updateShooting
	# (N2364) the guard here is canConsume() (no reloadCounter /
	# efficiency leg) and shoot(peekAmmo()) is a single line.
	# The proof calls the pure function with synthetic guard
	# values (no live tick); the ammo type is a proof-only
	# placeholder string carried through untouched. Warmup
	# 1.0 against minWarmup 0.5 is ready; 0.4 is below;
	# exactly 0.5 is the >= boundary.

	# No bullets, can consume, not charging, warmup above
	# min: shot, with the peeked ammo type.
	var ready: Dictionary = bridge.source_continuous_turret_build_update_shooting_state(false, true, false, 1.0, 0.5, "meltdown-ammo")
	proof["shot_when_ready"] = bool(ready.get("shot", false)) and String(ready.get("ammo_type", "")) == "meltdown-ammo"

	# A bullet already flying blocks the shot even when the
	# guard holds; no ammo type is returned.
	var flying: Dictionary = bridge.source_continuous_turret_build_update_shooting_state(true, true, false, 1.0, 0.5, "meltdown-ammo")
	proof["no_shot_when_bullets"] = not bool(flying.get("shot", true)) and flying.get("ammo_type", "x") == null

	# Cannot consume: no shot.
	var starved: Dictionary = bridge.source_continuous_turret_build_update_shooting_state(false, false, false, 1.0, 0.5, "meltdown-ammo")
	proof["no_shot_without_consume"] = not bool(starved.get("shot", true)) and starved.get("ammo_type", "x") == null

	# Charging: no shot.
	var charging: Dictionary = bridge.source_continuous_turret_build_update_shooting_state(false, true, true, 1.0, 0.5, "meltdown-ammo")
	proof["no_shot_when_charging"] = not bool(charging.get("shot", true)) and charging.get("ammo_type", "x") == null

	# Warmup below minWarmup: no shot.
	var cold: Dictionary = bridge.source_continuous_turret_build_update_shooting_state(false, true, false, 0.4, 0.5, "meltdown-ammo")
	proof["no_shot_below_min_warmup"] = not bool(cold.get("shot", true)) and cold.get("ammo_type", "x") == null

	# Warmup exactly at minWarmup: the >= boundary shoots.
	var boundary: Dictionary = bridge.source_continuous_turret_build_update_shooting_state(false, true, false, 0.5, 0.5, "meltdown-ammo")
	proof["shot_at_exact_min_warmup"] = bool(boundary.get("shot", false)) and String(boundary.get("ammo_type", "")) == "meltdown-ammo"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretUpdateShootingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
