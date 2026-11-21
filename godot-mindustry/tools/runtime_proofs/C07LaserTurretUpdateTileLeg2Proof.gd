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

	# --- LaserTurretBuild.updateTile() LEG 2 (N2373):
	# LaserTurretBuild.updateTile()
	# (LaserTurret.java:90-106) is the else-if
	# reloadCounter > 0 branch: with coolant, the used
	# liquid is (cheating ? maxUsed : min(liquids.get
	# (liquid), maxUsed)) * delta(); reloadCounter
	# falls by used * liquid.heatCapacity *
	# coolantMultiplier and the liquid is removed
	# (capped at zero, the LiquidModule.remove
	# contract); a chance roll of 0.06 * used may
	# spawn coolEffect.at() at a random offset inside
	# size * tilesize / 2. Without coolant,
	# reloadCounter falls by edelta(). When
	# reloadCounter <= 0 the guard fails and nothing
	# happens (reload_branch "none"). Leg 1 (N2372,
	# the bullets.any() branch) returns "bullets" or
	# "reload"; leg 2 returns "coolant" or "edelta".
	# The liquids dict arrives as an explicit
	# Dictionary (liquid name -> amount) and is never
	# mutated; cheating()/delta()/edelta() arrive as
	# explicit params; the chance roll and the
	# Mathf.range offsets arrive as explicit params
	# (the N1246 TractorBeam coolant-effect
	# precedent). NO driver tick line: a pure
	# function. The proof calls the pure function
	# with synthetic scalar inputs (no live tick).
	# Coolant case: reloadCounter 10, coolant amount
	# 2, multiplier 1.5, not cheating, delta 1,
	# water stored 5, heatCapacity 0.4: used =
	# min(5, 2) * 1 = 2, reloadCounter = 10 - 2 *
	# 0.4 * 1.5 = 8.8, water left 3.

	var coolant: Dictionary = {"amount": 2.0}
	var liquids: Dictionary = {"water": 5.0}
	var cooled: Dictionary = bridge.source_laser_turret_build_update_tile_leg2_state(10.0, coolant, 1.5, false, 1.0, 0.5, liquids, "water", 0.4, false, 100.0, 100.0, 2.0, 8.0, 0.0, 0.0)
	var cooled_liquids: Dictionary = cooled.get("liquids", {})

	# Coolant cools the counter by used * heatCapacity
	# * coolantMultiplier and removes the used liquid.
	proof["cools_with_liquid"] = is_equal_approx(float(cooled.get("used", -1.0)), 2.0) and is_equal_approx(float(cooled.get("max_used", -1.0)), 2.0) and is_equal_approx(float(cooled.get("reload_counter", -1.0)), 8.8) and is_equal_approx(float(cooled_liquids.get("water", -1.0)), 3.0) and String(cooled.get("reload_branch", "")) == "coolant"

	# Cheating uses maxUsed * delta even when less is
	# stored (water 0.5, maxUsed 2, delta 1: used 2),
	# the counter falls by 2 * 0.5 * 1 = 1, and the
	# removal caps at zero instead of going negative.
	var cheating_liquids: Dictionary = {"water": 0.5}
	var cheated: Dictionary = bridge.source_laser_turret_build_update_tile_leg2_state(10.0, coolant, 1.0, true, 1.0, 0.5, cheating_liquids, "water", 0.5, false, 100.0, 100.0, 2.0, 8.0, 0.0, 0.0)
	var cheated_liquids: Dictionary = cheated.get("liquids", {})
	proof["cheating_uses_max_used"] = is_equal_approx(float(cheated.get("used", -1.0)), 2.0) and is_equal_approx(float(cheated.get("reload_counter", -1.0)), 9.0) and String(cheated.get("reload_branch", "")) == "coolant"
	proof["removes_liquid_capped_at_zero"] = is_equal_approx(float(cheated_liquids.get("water", -1.0)), 0.0)

	# No coolant: the counter falls by edelta only,
	# nothing is used and the liquids pass through.
	var idle_liquids: Dictionary = {"water": 5.0}
	var edelta_tick: Dictionary = bridge.source_laser_turret_build_update_tile_leg2_state(10.0, null, 1.0, false, 1.0, 0.5, idle_liquids, "water", 0.4, false, 100.0, 100.0, 2.0, 8.0, 0.0, 0.0)
	var edelta_liquids: Dictionary = edelta_tick.get("liquids", {})
	proof["falls_back_to_edelta_without_coolant"] = is_equal_approx(float(edelta_tick.get("used", -1.0)), 0.0) and is_equal_approx(float(edelta_tick.get("reload_counter", -1.0)), 9.5) and is_equal_approx(float(edelta_liquids.get("water", -1.0)), 5.0) and String(edelta_tick.get("reload_branch", "")) == "edelta"

	# A non-positive counter fails the else-if guard:
	# nothing happens, branch "none".
	var guard_fail: Dictionary = bridge.source_laser_turret_build_update_tile_leg2_state(0.0, coolant, 1.5, false, 1.0, 0.5, {"water": 5.0}, "water", 0.4, true, 100.0, 100.0, 2.0, 8.0, 3.0, -2.0)
	var guard_liquids: Dictionary = guard_fail.get("liquids", {})
	proof["stays_idle_when_reload_counter_not_positive"] = is_equal_approx(float(guard_fail.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(guard_fail.get("used", -1.0)), 0.0) and is_equal_approx(float(guard_liquids.get("water", -1.0)), 5.0) and String(guard_fail.get("reload_branch", "")) == "none" and not bool(guard_fail.get("cool_effect_called", true)) and Dictionary(guard_fail.get("cool_effect_call", {"x": 1})).is_empty()

	# The cool effect spawns only when the chance roll
	# hits: at (100 + 3, 100 - 2) with range
	# size * tilesize / 2 = 2 * 8 / 2 = 8.
	var sparked: Dictionary = bridge.source_laser_turret_build_update_tile_leg2_state(10.0, coolant, 1.5, false, 1.0, 0.5, {"water": 5.0}, "water", 0.4, true, 100.0, 100.0, 2.0, 8.0, 3.0, -2.0)
	var spark_call: Dictionary = sparked.get("cool_effect_call", {})
	proof["spawns_cool_effect_when_chance_hits"] = bool(sparked.get("cool_effect_called", false)) and String(spark_call.get("call", "")) == "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));" and is_equal_approx(float(spark_call.get("x", -1.0)), 103.0) and is_equal_approx(float(spark_call.get("y", -1.0)), 98.0) and is_equal_approx(float(spark_call.get("range", -1.0)), 8.0)

	# A missed chance roll spawns nothing.
	proof["skips_cool_effect_when_chance_misses"] = not bool(cooled.get("cool_effect_called", true)) and Dictionary(cooled.get("cool_effect_call", {"x": 1})).is_empty()

	# The input liquids dict is never mutated: the
	# coolant case above still holds its 5.0 water.
	proof["does_not_mutate_input_liquids"] = is_equal_approx(float(liquids.get("water", -1.0)), 5.0) and is_equal_approx(float(cheating_liquids.get("water", -1.0)), 0.5) and is_equal_approx(float(idle_liquids.get("water", -1.0)), 5.0)

	# Each result carries ONLY its seven keys.
	proof["returns_only_seven_keys"] = cooled.size() == 7 and cheated.size() == 7 and edelta_tick.size() == 7 and guard_fail.size() == 7 and sparked.size() == 7

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretUpdateTileLeg2Proof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
