extends Node

const main_scene := preload("res://scenes/Main.tscn")
const predict_state := preload("res://src/game/SourcePredictState.gd")
const combat_state := preload("res://src/game/SourceTurretCombatState.gd")
const ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- TurretBuild.targetPosition(Posc) (Turret.java:453-470),
	# the one line N2122 did not register --
	# `var offset = Tmp.v1.setZero();` (:457, the charge offset
	# starts at zero before the accurateDelay branch). The GD
	# function already exists (N2122); the zero init is live
	# as `velocity := Vector2.ZERO`, only recomputed when the
	# target sits off the core. The proof drives the func
	# directly (no live loop) with one dagger in two
	# positions: exactly on the core (the offset stays at
	# its zero init, so the aim gets no lead) and 250px out
	# on the approach line (the offset is updated, so the
	# aim leads the dagger toward the core).

	# A null game yields no intercept (the guard leg).
	var null_target: Dictionary = combat_state.source_turret_target_position_state(null, Vector2.ZERO, null)
	proof["offset_zero_null_game_no_intercept"] = bool(null_target.get("used_intercept", true)) == false

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# The setup frames run the live loop with real deltas, and
	# the wave timer starts at 0 with no enemies, so a wave may
	# already have spawned: clear the board and pin the wave
	# timer far out, so this session has exactly one enemy,
	# placed by the proof.
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

	# --- the duo loads copper: the bootstrap already fills it to
	# maxAmmo 30 during enter, so drain the stacks first and load
	# 30 calls at ammoMultiplier 2 -- 15 items land (30 ammo).
	var duo_key := str(game.call("cell_key", duo_cell))
	var duo_stacks: Dictionary = game.get("turret_ammo_stacks")
	duo_stacks[duo_key] = []
	var duo_totals: Dictionary = game.get("turret_total_ammo")
	duo_totals[duo_key] = 0
	var loaded: int = ammo_state.load_selected_turret_ammo(game, "copper", 30)
	var total_ammo: int = int(Dictionary(game.get("turret_total_ammo")).get(duo_key, -1))
	var duo_loaded: bool = loaded == 15 and total_ammo == 30

	var dagger_type = game.call("selected_enemy_unit")
	game.call("spawn_enemy_unit", dagger_type, 0)
	var dagger: Dictionary = Array(game.get("enemy_units"))[0]
	var dagger_sprite = dagger.get("sprite", null)

	# --- the offset stays zero when the target sits on the core:
	# the direction to the core is zero, so the GD velocity is
	# never recomputed from its Vector2.ZERO init, and the
	# intercept runs with zero velocity -- the aim point is the
	# dagger's current position, with no lead.
	dagger_sprite.position = core_world
	var at_core: Dictionary = combat_state.source_turret_target_position_state(game, Vector2(duo_cell), dagger)
	var at_core_point: Dictionary = at_core.get("target_position", {})
	var at_core_pos := Vector2(float(at_core_point.get("x", -9999.0)), float(at_core_point.get("y", -9999.0)))
	proof["offset_zero_at_core_no_lead"] = duo_loaded and bool(at_core.get("used_intercept", false)) == true and is_equal_approx(at_core_pos.x, core_world.x) and is_equal_approx(at_core_pos.y, core_world.y)
	# The same aim equals the pure zero-velocity intercept: the
	# func really called Predict.intercept with the offset still
	# at its zero init, not with a recomputed velocity.
	var bullet_speed: float = float(at_core.get("bullet_speed", -1.0))
	var pure: Dictionary = predict_state.source_predict_intercept_state(duo_world.x, duo_world.y, core_world.x, core_world.y, 0.0, 0.0, bullet_speed, 1.0)
	proof["offset_zero_at_core_matches_pure_intercept"] = bullet_speed > 0.0 and is_equal_approx(at_core_pos.x, float(pure.get("intercept_x", -9999.0))) and is_equal_approx(at_core_pos.y, float(pure.get("intercept_y", -9999.0)))

	# --- the offset is updated when the target is off the core:
	# 250px out on the approach line, the aim leads the dagger
	# toward the core (the same geometry as C06DefenseProof).
	var duo_to_core: Vector2 = core_world - duo_world
	var approach: Vector2 = duo_world - duo_to_core.normalized() * 250.0
	dagger_sprite.position = approach
	var away: Dictionary = combat_state.source_turret_target_position_state(game, Vector2(duo_cell), dagger)
	var away_point: Dictionary = away.get("target_position", {})
	var away_pos := Vector2(float(away_point.get("x", -9999.0)), float(away_point.get("y", -9999.0)))
	var to_core: Vector2 = core_world - approach
	proof["offset_updated_away_from_core_leads"] = bool(away.get("used_intercept", false)) == true and approach.distance_to(away_pos) > 10.0 and (away_pos - approach).dot(to_core.normalized()) > 0.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretTargetPositionOffsetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
