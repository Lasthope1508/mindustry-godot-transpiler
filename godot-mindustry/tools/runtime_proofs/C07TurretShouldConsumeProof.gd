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

	# --- TurretBuild.shouldConsume() (N2253):
	# TurretBuild overrides shouldConsume (Turret.java:364-366,
	# `public boolean shouldConsume(){` / `return isShooting ||
	# reloadCounter < reload;`) over isShooting
	# (Turret.java:292) and reloadCounter
	# (ReloadTurret.java:26, capped at reload,
	# Turret.java:723) against reload
	# (ReloadTurret.java:10, `public float reload = 10f;`).
	# updateConsumption forces efficiency to zero when the
	# gate is false (BuildingComp.java:1960, `boolean update
	# = shouldConsume() && productionValid();` + 1993,
	# `efficiency = optionalEfficiency = 0f;`).

	# A shooting turret consumes even with a full reload counter.
	var shooting: Dictionary = turret_build_state.source_turret_should_consume_state({}, true, 10.0, 10.0)
	proof["should_consume_shooting"] = bool(shooting.get("should_consume", false))

	# A non-shooting turret still reloading consumes.
	var reloading: Dictionary = turret_build_state.source_turret_should_consume_state({}, false, 5.0, 10.0)
	proof["should_consume_reloading"] = bool(reloading.get("should_consume", false))

	# A non-shooting turret with a full reload counter does not
	# consume: the comparison is strict (< reload, Turret.java:365),
	# so reloadCounter == reload is idle.
	var reloaded_idle: Dictionary = turret_build_state.source_turret_should_consume_state({}, false, 10.0, 10.0)
	proof["should_consume_reloaded_idle"] = not bool(reloaded_idle.get("should_consume", true))

	# A counter past reload does not consume either (live it is
	# capped at reload, Turret.java:723, so this only proves the
	# pure comparison, not a live state).
	var beyond: Dictionary = turret_build_state.source_turret_should_consume_state({}, false, 12.0, 10.0)
	proof["should_consume_beyond_reload"] = not bool(beyond.get("should_consume", true))

	# --- Live driver: the lancer is a PowerTurret with a power
	# consumer (consumePower 6f), placed live by the scenario
	# bootstrap; the tick driver is called directly (as the
	# N2148 proof does), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The frame
	# carries no isShooting / reloadCounter / reload keys yet,
	# so the driver reads the frame defaults (is_shooting=false,
	# reload_counter=0.0, reload=10f): 0.0 < 10f, the gate
	# passes, and half power folds to efficiency 0.5. If the
	# gate were false, updateConsumption would force
	# efficiency to 0 (BuildingComp.java:1960 + 1993).
	var lancer_cell := Vector2i(25, 7)
	var lancer: Variant = game.call("block_sprite_at_cell", lancer_cell)
	var lancer_frame: Dictionary = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	lancer_frame["power_status"] = 0.5
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	lancer_frame = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["driver_gate_passes_with_frame_defaults"] = is_equal_approx(float(lancer_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
