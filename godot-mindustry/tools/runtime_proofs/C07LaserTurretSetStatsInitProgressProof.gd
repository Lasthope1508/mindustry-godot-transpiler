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

	# --- LaserTurret.setStats()+init() + LaserTurretBuild.progress() (N2386):
	# LaserTurret.setStats() (LaserTurret.java:26-33)
	# drops the booster stat row and, when a coolant
	# consumer exists, adds an input row with the
	# boosters spec (reload, coolant.amount,
	# coolantMultiplier, baseReload false,
	# this::consumesLiquid). LaserTurret.init()
	# (LaserTurret.java:36-43) resolves the coolant
	# consumer with findConsumer when it is still
	# null. LaserTurretBuild.progress()
	# (LaserTurret.java:110-112) is 1 -
	# clamp(reloadCounter / reload). The proof calls
	# the pure functions with synthetic inputs (no
	# live tick). `stats` arrives as an Array of row
	# dicts and is never mutated. `coolant` is
	# `ConsumeLiquidBase` (BaseTurret.java:34) as a
	# Dictionary {amount} or null. `coolantMultiplier`
	# defaults to 1f (LaserTurret.java:22).
	# `this::consumesLiquid` is Block.consumesLiquid
	# (Block.java:778) as an explicit Callable. NO
	# driver tick line: three pure functions.

	var filter_pass: Callable = func(liquid: Variant) -> bool: return true
	var coolant: Dictionary = {"amount": 2.0}
	var rows: Array = [{"stat": "booster", "value": 1.0}, {"stat": "health", "value": 100.0}]
	var with_coolant: Dictionary = bridge.source_laser_turret_build_set_stats_state(rows, coolant, 60.0, 1.5, filter_pass)
	var with_coolant_rows: Array = with_coolant.get("stats", [])

	# The booster row is dropped; the health row
	# survives; the input row is appended with the
	# boosters spec (reload 60, coolant amount 2,
	# multiplier 1.5, baseReload false, the filter).
	proof["set_stats_removes_booster"] = with_coolant_rows.size() == 2 and String((with_coolant_rows[0] as Dictionary).get("stat", "")) == "health" and String((with_coolant_rows[1] as Dictionary).get("stat", "")) == "input"
	var input_row: Dictionary = with_coolant_rows[1]
	var boosters: Dictionary = input_row.get("boosters", {})
	var row_filter: Callable = boosters.get("consumes_liquid", Callable())
	proof["set_stats_adds_input_row_with_coolant"] = is_equal_approx(float(boosters.get("reload", -1.0)), 60.0) and is_equal_approx(float(boosters.get("coolant_amount", -1.0)), 2.0) and is_equal_approx(float(boosters.get("coolant_multiplier", -1.0)), 1.5) and bool(boosters.get("base_reload", true)) == false and row_filter.is_valid() and bool(row_filter.call("water"))

	# Without coolant there is no input row, but the
	# booster row is still dropped.
	var no_coolant: Dictionary = bridge.source_laser_turret_build_set_stats_state(rows, null, 60.0, 1.5, filter_pass)
	var no_coolant_rows: Array = no_coolant.get("stats", [])
	proof["set_stats_skips_input_row_without_coolant"] = no_coolant_rows.size() == 1 and String((no_coolant_rows[0] as Dictionary).get("stat", "")) == "health"

	# The input stats array is never mutated: the
	# booster row is still in the caller's array.
	proof["set_stats_inputs_unmutated"] = rows.size() == 2 and String((rows[0] as Dictionary).get("stat", "")) == "booster"

	# init resolves the coolant from the finder only
	# when it is null: found consumer {amount 3}
	# becomes the coolant, coolant_found is true.
	var found: Dictionary = {"amount": 3.0}
	var resolved: Dictionary = bridge.source_laser_turret_build_init_state(null, found)
	proof["init_uses_found_consumer_when_coolant_null"] = bool(resolved.get("coolant_found", false)) and Dictionary(resolved.get("coolant", {})).get("amount", -1.0) == 3.0

	# An existing coolant passes through unchanged
	# and the finder result is ignored.
	var kept: Dictionary = bridge.source_laser_turret_build_init_state(coolant, found)
	proof["init_keeps_existing_coolant"] = not bool(kept.get("coolant_found", true)) and Dictionary(kept.get("coolant", {})).get("amount", -1.0) == 2.0

	# Null coolant and no consumer found: coolant
	# stays null, coolant_found is false.
	var nothing: Dictionary = bridge.source_laser_turret_build_init_state(null, null)
	proof["init_stays_null_when_nothing_found"] = not bool(nothing.get("coolant_found", true)) and nothing.get("coolant", "x") == null

	# progress is 1 - clamp(reloadCounter / reload):
	# ready at 0, half at half reload, 0 at reload
	# or past it (clamped), 1 for a negative counter.
	var ready: Dictionary = bridge.source_laser_turret_build_progress_state(0.0, 60.0)
	var half: Dictionary = bridge.source_laser_turret_build_progress_state(30.0, 60.0)
	var done: Dictionary = bridge.source_laser_turret_build_progress_state(60.0, 60.0)
	var over: Dictionary = bridge.source_laser_turret_build_progress_state(90.0, 60.0)
	var negative: Dictionary = bridge.source_laser_turret_build_progress_state(-10.0, 60.0)
	proof["progress_clamps_reload_fraction"] = is_equal_approx(float(ready.get("progress", -1.0)), 1.0) and is_equal_approx(float(half.get("progress", -1.0)), 0.5) and is_equal_approx(float(done.get("progress", -1.0)), 0.0) and is_equal_approx(float(over.get("progress", -1.0)), 0.0) and is_equal_approx(float(negative.get("progress", -1.0)), 1.0)

	# Each result carries ONLY its expected keys.
	proof["returns_only_expected_keys"] = with_coolant.size() == 1 and no_coolant.size() == 1 and resolved.size() == 2 and kept.size() == 2 and nothing.size() == 2 and ready.size() == 1 and half.size() == 1 and done.size() == 1 and over.size() == 1 and negative.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretSetStatsInitProgressProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
