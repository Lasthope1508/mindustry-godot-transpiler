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

	# --- ContinuousTurretBuild.updateBullet() (N2366):
	# ContinuousTurretBuild.updateBullet()
	# (ContinuousTurret.java:102-130) moves one surviving
	# bullet to its rotated muzzle offset, re-aims its laser
	# end point toward the target with a smoothed length, and
	# refreshes its damage / lifetime while the turret is
	# shooting:
	# `protected void updateBullet(BulletEntry entry){`
	# `bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),`
	# `bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),`
	# `angle = rotation + entry.rotation;`
	# `entry.bullet.rotation(angle);`
	# `entry.bullet.set(bulletX, bulletY);`
	# `//target length of laser`
	# `float shootLength = Math.min(dst(targetPos), range);`
	# `//current length of laser`
	# `float curLength = dst(entry.bullet.aimX, entry.bullet.aimY);`
	# `//resulting length of the bullet (smoothed)`
	# `float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);`
	# `//actual aim end point based on length`
	# `Tmp.v1.trns(rotation, lastLength = resultLength).add(x, y);`
	# `entry.bullet.aimX = Tmp.v1.x;`
	# `entry.bullet.aimY = Tmp.v1.y;`
	# `if(scaleDamageEfficiency){`
	# `entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();`
	# `}`
	# `if(isShooting && hasAmmo()){`
	# `entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);`
	# `entry.bullet.keepAlive = true;`
	# `}`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). Angles.trnsx/trnsy are the
	# THREE-arg overloads (Angles.java:74-79): they rotate the
	# (shootX + entry.x, shootY + entry.y) offset by rotation - 90.
	# The proof calls the pure function with synthetic bullet
	# entries (no live tick); "mark" is a proof-only order
	# marker carried through untouched. Building at (100, 200),
	# rotation 0, muzzle offset (0, 8), target (300, 200),
	# range 200: the offset rotated by -90 lands at (108, 200)
	# and the laser aims at (300, 200).

	var make_entry := func() -> Dictionary:
		return {
			"x": 0.0, "y": 0.0, "rotation": 30.0, "mark": 1,
			"bullet": {
				"aim_x": 100.0, "aim_y": 200.0,
				"damage": 5.0, "time": 3.0, "lifetime": 40.0,
				"type_damage": 10.0, "type_optimal_life_fract": 0.5,
				"damage_multiplier": 2.0,
			},
		}

	# aimChangeSpeed INF (the ContinuousTurret.java:17 default)
	# snaps the length to shootLength in one tick.
	var snap: Dictionary = bridge.source_continuous_turret_build_update_bullet_state(make_entry.call(), 100.0, 200.0, 0.0, 0.0, 8.0, 300.0, 200.0, 200.0, INF, false, 0.5, 1.0, 0.8, true, true, 1.0 / 60.0)

	# The muzzle offset (0, 8) rotated by rotation - 90 = -90
	# lands at (+8, 0): bullet (108, 200); angle is
	# rotation + entry.rotation = 0 + 30.
	proof["bullet_position_rotated"] = is_equal_approx(float(snap.get("bullet_x", -1.0)), 108.0) and is_equal_approx(float(snap.get("bullet_y", -1.0)), 200.0) and is_equal_approx(float(snap.get("bullet_angle", -1.0)), 30.0)

	# Finite aimChangeSpeed advances the length by exactly
	# source_delta * speed per tick: cur 0, shoot 200, speed
	# 60, delta 1/60 -> result 1. INF snaps it to 200.
	var smooth: Dictionary = bridge.source_continuous_turret_build_update_bullet_state(make_entry.call(), 100.0, 200.0, 0.0, 0.0, 8.0, 300.0, 200.0, 200.0, 60.0, false, 0.5, 1.0, 0.8, true, true, 1.0 / 60.0)
	proof["laser_length_smoothed"] = (
		is_equal_approx(float(smooth.get("shoot_length", -1.0)), 200.0)
		and is_equal_approx(float(smooth.get("cur_length", -1.0)), 0.0)
		and is_equal_approx(float(smooth.get("result_length", -1.0)), 1.0)
		and is_equal_approx(float(snap.get("result_length", -1.0)), 200.0)
		and is_equal_approx(float(snap.get("shoot_length", -1.0)), 200.0)
	)

	# The aim end point extends along rotation by
	# resultLength: (100 + cos(0) * 200, 200 + sin(0) * 200)
	# = (300, 200); lastLength is assigned resultLength.
	proof["aim_endpoint_set"] = is_equal_approx(float(snap.get("bullet_aim_x", -1.0)), 300.0) and is_equal_approx(float(snap.get("bullet_aim_y", -1.0)), 200.0) and is_equal_approx(float(snap.get("last_length", -1.0)), 200.0)

	# scaleDamageEfficiency: damage = type.damage *
	# min(efficiency, 1) * timeScale * damageMultiplier()
	# = 10 * 0.5 * 1 * 2 = 10; without the flag the input
	# damage is kept.
	var scaled: Dictionary = bridge.source_continuous_turret_build_update_bullet_state(make_entry.call(), 100.0, 200.0, 0.0, 0.0, 8.0, 300.0, 200.0, 200.0, INF, true, 0.5, 1.0, 0.8, true, true, 1.0 / 60.0)
	proof["damage_scaled"] = is_equal_approx(float(scaled.get("bullet_damage", -1.0)), 10.0) and is_equal_approx(float(snap.get("bullet_damage", -1.0)), 5.0)

	# isShooting and hasAmmo: time = lifetime *
	# type.optimalLifeFract * min(shootWarmup, efficiency)
	# = 40 * 0.5 * min(0.8, 0.5) = 10; keepAlive is set.
	proof["keep_alive_set"] = is_equal_approx(float(snap.get("bullet_time", -1.0)), 10.0) and bool(snap.get("bullet_keep_alive", false))

	# Without ammo (or without shooting) the time is kept
	# and keepAlive stays false.
	var no_ammo: Dictionary = bridge.source_continuous_turret_build_update_bullet_state(make_entry.call(), 100.0, 200.0, 0.0, 0.0, 8.0, 300.0, 200.0, 200.0, INF, false, 0.5, 1.0, 0.8, true, false, 1.0 / 60.0)
	var not_shooting: Dictionary = bridge.source_continuous_turret_build_update_bullet_state(make_entry.call(), 100.0, 200.0, 0.0, 0.0, 8.0, 300.0, 200.0, 200.0, INF, false, 0.5, 1.0, 0.8, false, true, 1.0 / 60.0)
	proof["no_keep_alive_without_ammo"] = (
		is_equal_approx(float(no_ammo.get("bullet_time", -1.0)), 3.0)
		and not bool(no_ammo.get("bullet_keep_alive", true))
		and is_equal_approx(float(not_shooting.get("bullet_time", -1.0)), 3.0)
		and not bool(not_shooting.get("bullet_keep_alive", true))
	)

	# A target beyond range caps shootLength at range:
	# target (500, 200) is 400 away, range 200.
	var capped: Dictionary = bridge.source_continuous_turret_build_update_bullet_state(make_entry.call(), 100.0, 200.0, 0.0, 0.0, 8.0, 500.0, 200.0, 200.0, INF, false, 0.5, 1.0, 0.8, true, true, 1.0 / 60.0)
	proof["range_caps_length"] = is_equal_approx(float(capped.get("shoot_length", -1.0)), 200.0)

	# The input dicts are not mutated: same values before
	# and after the call, including the nested bullet dict.
	var entry: Dictionary = make_entry.call()
	var before_bullet: Dictionary = (entry.get("bullet", {}) as Dictionary).duplicate()
	bridge.source_continuous_turret_build_update_bullet_state(entry, 100.0, 200.0, 0.0, 0.0, 8.0, 300.0, 200.0, 200.0, INF, true, 0.5, 1.0, 0.8, true, true, 1.0 / 60.0)
	var after_bullet: Dictionary = entry.get("bullet", {})
	proof["input_unmutated"] = (
		is_equal_approx(float(entry.get("x", -1.0)), 0.0)
		and is_equal_approx(float(entry.get("y", -1.0)), 0.0)
		and is_equal_approx(float(entry.get("rotation", -1.0)), 30.0)
		and is_equal_approx(float(after_bullet.get("aim_x", -1.0)), float(before_bullet.get("aim_x", -2.0)))
		and is_equal_approx(float(after_bullet.get("aim_y", -1.0)), float(before_bullet.get("aim_y", -2.0)))
		and is_equal_approx(float(after_bullet.get("damage", -1.0)), float(before_bullet.get("damage", -2.0)))
		and is_equal_approx(float(after_bullet.get("time", -1.0)), float(before_bullet.get("time", -2.0)))
	)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretUpdateBulletProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
