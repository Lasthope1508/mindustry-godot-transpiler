extends Node

const main_scene := preload("res://scenes/Main.tscn")
const predict_state := preload("res://src/game/SourcePredictState.gd")
const combat_state := preload("res://src/game/SourceTurretCombatState.gd")
const enemy_state := preload("res://src/game/SourceEnemyUnitRuntimeState.gd")
const ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _angle_diff_degrees(a: float, b: float) -> float:
	return absf(fposmod(a - b + 180.0, 360.0) - 180.0)


func _normalized_angle_degrees(a: float) -> float:
	return fposmod(a, 360.0)


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Predict.intercept is pure: the quadratic and the lead are
	# checked against hand-computed values before any game exists.
	# Shooter (0,0), target (100,0) walking +y at 1/tick, bullet 5/tick:
	# a = -24, b = 0, c = 10000, disc = 960000, roots (20.4124, -20.4124),
	# so the bullet meets the target at (100, 20.4124) after 20.4124 ticks.
	var lead: Dictionary = predict_state.source_predict_intercept_state(0.0, 0.0, 100.0, 0.0, 0.0, 1.0, 5.0, 1.0)
	proof["predict_intercept_lead"] = is_equal_approx(float(lead.get("intercept_x", -1.0)), 100.0) and is_equal_approx(float(lead.get("intercept_y", -1.0)), 20.412414523193153) and is_equal_approx(float(lead.get("intercept_time", -1.0)), 20.412414523193153) and bool(lead.get("used_intercept", false)) == true
	# A target outrunning the bullet (10/tick vs 5/tick) has no
	# positive root, so the intercept falls back to its position.
	var outrun: Dictionary = predict_state.source_predict_intercept_state(0.0, 0.0, 10.0, 0.0, 10.0, 0.0, 5.0, 1.0)
	proof["predict_intercept_outrun_falls_back"] = is_equal_approx(float(outrun.get("intercept_x", -1.0)), 10.0) and is_equal_approx(float(outrun.get("intercept_y", -1.0)), 0.0) and bool(outrun.get("used_intercept", true)) == false
	# A stationary target: the intercept is its position (t = 10).
	var still: Dictionary = predict_state.source_predict_intercept_state(0.0, 0.0, 30.0, 40.0, 0.0, 0.0, 5.0, 1.0)
	proof["predict_intercept_stationary"] = is_equal_approx(float(still.get("intercept_x", -1.0)), 30.0) and is_equal_approx(float(still.get("intercept_y", -1.0)), 40.0) and is_equal_approx(float(still.get("intercept_time", -1.0)), 10.0) and bool(still.get("used_intercept", false)) == true
	var quad: Dictionary = predict_state.source_predict_quad_state(1.0, 0.0, -4.0)
	proof["predict_quad_roots"] = bool(quad.get("has_roots", false)) == true and is_equal_approx(float(quad.get("root0", -99.0)), -2.0) and is_equal_approx(float(quad.get("root1", -99.0)), 2.0)
	var quad_linear: Dictionary = predict_state.source_predict_quad_state(0.0, 2.0, -4.0)
	proof["predict_quad_degenerate_linear"] = bool(quad_linear.get("has_roots", false)) == true and is_equal_approx(float(quad_linear.get("root0", -99.0)), 2.0) and is_equal_approx(float(quad_linear.get("root1", -99.0)), 2.0)
	var quad_none: Dictionary = predict_state.source_predict_quad_state(1.0, 0.0, 4.0)
	proof["predict_quad_no_roots"] = bool(quad_none.get("has_roots", true)) == false
	var quad_zero: Dictionary = predict_state.source_predict_quad_state(0.0, 0.0, 0.0)
	proof["predict_quad_zero"] = bool(quad_zero.get("has_roots", false)) == true and is_equal_approx(float(quad_zero.get("root0", -99.0)), 0.0) and is_equal_approx(float(quad_zero.get("root1", -99.0)), 0.0)

	# --- the sweep and the target position are no-ops without a game.
	var null_sweep: Dictionary = enemy_state.source_enemy_units_sweep_dead_state(null)
	proof["defense_sweep_null_game_zeros"] = int(null_sweep.get("swept_count", -1)) == 0 and int(null_sweep.get("remaining_count", -1)) == 0
	var null_target: Dictionary = combat_state.source_turret_target_position_state(null, Vector2.ZERO, null)
	proof["defense_target_position_null_game"] = bool(null_target.get("used_intercept", true)) == false

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the setup frames run the live loop with real deltas, and the
	# wave timer starts at 0 with no enemies, so a wave may already
	# have spawned: clear the board and pin the wave timer far out,
	# so this session has exactly one enemy, placed by the proof.
	game.set("wave_cooldown", 100000.0)
	for enemy in game.get("enemy_units"):
		var enemy_dict: Dictionary = enemy
		var sprite = enemy_dict.get("sprite", null)
		if is_instance_valid(sprite):
			sprite.queue_free()
	game.set("enemy_units", [])
	game.set("bullet_hit_count", 0)

	var duo_cell := Vector2i(19, 7)
	var duo_world: Vector2 = game.call("grid_to_world", duo_cell)
	var core_world: Vector2 = game.call("grid_to_world", game.get("core_pos"))
	proof["defense_duo_world"] = is_equal_approx(duo_world.x, 624.0) and is_equal_approx(duo_world.y, 240.0)
	proof["defense_core_world"] = is_equal_approx(core_world.x, 560.0) and is_equal_approx(core_world.y, 272.0)

	# --- the duo loads copper: the bootstrap already fills it to
	# maxAmmo 30 during enter, so drain the stacks first and load
	# 30 calls at ammoMultiplier 2 — 15 items land (30 ammo).
	var duo_key := str(game.call("cell_key", duo_cell))
	var duo_stacks: Dictionary = game.get("turret_ammo_stacks")
	duo_stacks[duo_key] = []
	var duo_totals: Dictionary = game.get("turret_total_ammo")
	duo_totals[duo_key] = 0
	var loaded: int = ammo_state.load_selected_turret_ammo(game, "copper", 30)
	var total_ammo: int = int(Dictionary(game.get("turret_total_ammo")).get(duo_key, -1))
	proof["defense_duo_loaded"] = loaded == 15 and total_ammo == 30

	# --- the sweep removes a dead enemy and keeps a live one: kill
	# the first dagger by hand, sweep, and check the list is empty.
	var dagger_type = game.call("selected_enemy_unit")
	game.call("spawn_enemy_unit", dagger_type, 0)
	var first_units: Array = game.get("enemy_units")
	proof["defense_dagger_spawned"] = first_units.size() == 1 and is_equal_approx(float(Dictionary(first_units[0]).get("health", -1.0)), 150.0)
	var first_dagger: Dictionary = first_units[0]
	first_dagger["health"] = 0.0
	var sweep_one: Dictionary = enemy_state.source_enemy_units_sweep_dead_state(game)
	proof["defense_sweep_removes_dead"] = int(sweep_one.get("swept_count", -1)) == 1 and int(sweep_one.get("remaining_count", -1)) == 0 and Array(game.get("enemy_units")).is_empty()
	var live_sweep: Dictionary = enemy_state.source_enemy_units_sweep_dead_state(game)
	proof["defense_sweep_empty_stays_empty"] = int(live_sweep.get("swept_count", -1)) == 0 and int(live_sweep.get("remaining_count", -1)) == 0

	# --- the live leg: a fresh dagger, placed 250px out on the line
	# through the duo and the core, so its walk to the core crosses
	# the duo's field of fire (it enters the 160px range after 90px,
	# then has 231px — 463 ticks, ~23 shots — before the core).
	# The natural spawn (lane 0, x = 0) only gives ~10 shots in the
	# (cell-origin) range circle, so the approach vector is the
	# harness setup; the spawn itself is exercised above and here.
	game.call("spawn_enemy_unit", dagger_type, 0)
	var dagger: Dictionary = Array(game.get("enemy_units"))[0]
	var dagger_sprite = dagger.get("sprite", null)
	var duo_to_core: Vector2 = core_world - duo_world
	var approach: Vector2 = duo_world - duo_to_core.normalized() * 250.0
	dagger_sprite.position = approach
	proof["defense_dagger_placed_on_approach"] = is_equal_approx(dagger_sprite.position.x, 847.606797749979) and is_equal_approx(dagger_sprite.position.y, 128.19660112501052)

	var entry_tick := -1
	var lead_checked := false
	var lead_angle_ok := false
	var lead_point_ahead := false
	var lead_used := false
	var death_tick := -1
	var death_health := 0.0
	var swept_tick := -1
	var hits_at_death := 0
	for tick in range(700):
		game.call("simulate_factory", 1.0 / 60.0)
		game.call("simulate_turrets", 1.0 / 60.0)
		game.call("simulate_bullets", 1.0 / 60.0)
		game.call("simulate_enemy_units", 1.0 / 60.0)
		var live_units: Array = game.get("enemy_units")
		if entry_tick < 0:
			var acquired = game.call("find_enemy_target", Vector2(duo_cell), 160.0)
			if acquired != null:
				entry_tick = tick
		if entry_tick >= 0 and not lead_checked and not live_units.is_empty():
			# The first tick in range: the live aim must equal the
			# intercept angle, and the intercept point must sit ahead
			# of the dagger along its walk. (The approach runs
			# straight through the duo, so the dagger's motion is
			# radial and the lead angle itself is zero — the lead is
			# a forward displacement, not a turn: the bullet meets
			# the dagger ~30px ahead of where it is now.)
			var pos: Vector2 = dagger_sprite.position
			var to_core: Vector2 = core_world - pos
			var vel: Vector2 = to_core.normalized() * 0.5
			var aim: float = float(game.call("source_angle_to_target", Vector2(duo_cell), dagger))
			var intercept: Dictionary = predict_state.source_predict_intercept_state(duo_world.x, duo_world.y, pos.x, pos.y, vel.x, vel.y, 2.5, 1.0)
			var intercept_point := Vector2(float(intercept.get("intercept_x", pos.x)), float(intercept.get("intercept_y", pos.y)))
			var intercept_angle: float = _normalized_angle_degrees(rad_to_deg(atan2(intercept_point.y - duo_world.y, intercept_point.x - duo_world.x)))
			var positioned: Dictionary = combat_state.source_turret_target_position_state(game, Vector2(duo_cell), dagger)
			lead_angle_ok = _angle_diff_degrees(aim, intercept_angle) < 1.0
			lead_point_ahead = pos.distance_to(intercept_point) > 10.0 and (intercept_point - pos).dot(to_core.normalized()) > 0.0
			lead_used = bool(positioned.get("used_intercept", false)) == true
			lead_checked = true
		if death_tick < 0 and float(dagger.get("health", 150.0)) <= 0.0:
			death_tick = tick
			death_health = float(dagger.get("health", 0.0))
			hits_at_death = int(game.get("bullet_hit_count"))
		if death_tick >= 0 and live_units.is_empty():
			swept_tick = tick
			break
		if live_units.is_empty():
			break

	proof["defense_dagger_entered_range"] = entry_tick >= 0
	proof["defense_lead_checked"] = lead_checked
	proof["defense_lead_angle_matches_intercept"] = lead_angle_ok
	proof["defense_lead_point_ahead"] = lead_point_ahead
	proof["defense_lead_used_intercept"] = lead_used
	proof["defense_hits_landed"] = int(game.get("bullet_hit_count")) > 0
	proof["defense_dagger_died"] = death_tick >= 0 and death_health <= 0.0 and bool(game.get("last_bullet_target_destroyed")) == true
	proof["defense_dagger_swept"] = swept_tick >= 0 and swept_tick >= death_tick and Array(game.get("enemy_units")).is_empty()
	proof["defense_core_unharmed"] = is_equal_approx(float(game.get("core_health")), 1100.0)
	var ammo_left: int = int(Dictionary(game.get("turret_total_ammo")).get(str(game.call("cell_key", duo_cell)), -1))
	proof["defense_ammo_spent"] = ammo_left < 30 and ammo_left >= 0
	proof["defense_death_before_core"] = death_tick >= 0 and death_tick < 643

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06DefenseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
