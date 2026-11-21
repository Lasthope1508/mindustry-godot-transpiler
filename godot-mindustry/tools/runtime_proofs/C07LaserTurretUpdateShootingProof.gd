extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceLaserTurretBuildPortBridge.gd")
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

	# --- LaserTurretBuild.updateShooting() (N2364):
	# LaserTurretBuild.updateShooting()
	# (LaserTurret.java:120-132) shoots only when no bullet
	# is around and the guard holds (reloadCounter <= 0,
	# efficiency > 0, not charging, shootWarmup >= minWarmup):
	# `protected void updateShooting(){`
	# `if(bullets.any()){`
	# `return;`
	# `}`
	# `if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){`
	# `BulletType type = peekAmmo();`
	# `shoot(type);`
	# `reloadCounter = reload;`
	# `}`
	# `}`
	# on `public class LaserTurretBuild extends PowerTurretBuild{`
	# (LaserTurret.java:44). The bullets seq / peekAmmo() /
	# charging() / shoot(type) arrive as explicit params or
	# are callees (the N2330 param precedent; peekAmmo owned
	# at N1172, charging at Turret.java:715-717). NO driver
	# tick line: a pure decision function. The proof calls
	# the pure function with synthetic scalar inputs (no live
	# tick). The ammo type is a Variant, passed here as the
	# string "test-bullet-type" (peekAmmo echoes shootType).

	# A bullet around blocks shooting even when ready.
	var blocked: Dictionary = bridge.source_laser_turret_build_update_shooting_state(true, 0.0, 1.0, false, 1.0, 0.0, 10.0, "test-bullet-type")
	proof["update_shooting_bullets_present_no_shoot"] = bool(blocked.get("should_shoot", true)) == false and float(blocked.get("reload_counter", -1.0)) == 0.0

	# Ready (no bullet, counter at zero, efficiency, not
	# charging, warmed up) shoots the peekAmmo type and
	# resets the counter to reload.
	var ready: Dictionary = bridge.source_laser_turret_build_update_shooting_state(false, 0.0, 1.0, false, 1.0, 0.0, 10.0, "test-bullet-type")
	proof["update_shooting_ready_shoots"] = bool(ready.get("should_shoot", false)) == true and String(ready.get("shoot_type", "")) == "test-bullet-type" and float(ready.get("reload_counter", -1.0)) == 10.0

	# A positive reload counter blocks shooting on its own.
	var counting: Dictionary = bridge.source_laser_turret_build_update_shooting_state(false, 5.0, 1.0, false, 1.0, 0.0, 10.0, "test-bullet-type")
	proof["update_shooting_reload_counter_positive_no_shoot"] = bool(counting.get("should_shoot", true)) == false and float(counting.get("reload_counter", -1.0)) == 5.0

	# Zero efficiency blocks shooting on its own.
	var no_power: Dictionary = bridge.source_laser_turret_build_update_shooting_state(false, 0.0, 0.0, false, 1.0, 0.0, 10.0, "test-bullet-type")
	proof["update_shooting_efficiency_zero_no_shoot"] = bool(no_power.get("should_shoot", true)) == false

	# Charging blocks shooting on its own.
	var charging: Dictionary = bridge.source_laser_turret_build_update_shooting_state(false, 0.0, 1.0, true, 1.0, 0.0, 10.0, "test-bullet-type")
	proof["update_shooting_charging_no_shoot"] = bool(charging.get("should_shoot", true)) == false

	# Warmup below minWarmup blocks shooting on its own.
	var cold: Dictionary = bridge.source_laser_turret_build_update_shooting_state(false, 0.0, 1.0, false, 0.0, 1.0, 10.0, "test-bullet-type")
	proof["update_shooting_warmup_low_no_shoot"] = bool(cold.get("should_shoot", true)) == false

	# Idle (no bullet, not ready) returns a null shoot type.
	proof["update_shooting_shoot_type_null_when_idle"] = blocked.get("shoot_type", "not-null") == null

	# Each result carries ONLY its three keys.
	proof["update_shooting_returns_only_three_keys"] = ready.size() == 3 and blocked.size() == 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretUpdateShootingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
