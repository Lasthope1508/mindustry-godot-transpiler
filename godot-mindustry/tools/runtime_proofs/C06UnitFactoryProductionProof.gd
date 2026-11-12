extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var factory_block = blocks_by_id["ground-factory"]

	# --- One tick of UnitFactoryBuild.updateTile()
	# (UnitFactory.java:392-442), driven directly on a bound
	# ground-factory frame (the dagger plan is silicon 10 + lead 10
	# over 900 ticks, N2120, Blocks.java). Deterministic: no
	# tick-driver timing, the pure function takes edelta,
	# unit_build_speed and source_delta as inputs.
	var plan: Dictionary = unit_factory_build_state.source_unit_factory_plan_requirements_state(factory_block, 0)

	# --- progress/time advance (UnitFactory.java:401-403):
	# `time += edelta() * speedScl * Vars.state.rules.unitBuildSpeed(team);`
	# `progress += edelta() * Vars.state.rules.unitBuildSpeed(team);`
	# efficiency 1.0, plan 0, edelta 1.0, unit build speed 1.0:
	# progress 0 -> 1.0, time 0 -> 1.0, speed_scl stays 1.0.
	var advancing: Dictionary = unit_factory_build_state.source_unit_factory_production_tick_state({"efficiency": 1.0, "current_plan": 0, "progress": 0.0, "time": 0.0, "speed_scl": 1.0}, plan, 1, 1.0, 1.0, 1.0)
	proof["production_progress_advances"] = is_equal_approx(float(advancing.get("progress", -1.0)), 1.0) and int(advancing.get("current_plan", -99)) == 0 and bool(advancing.get("completed", true)) == false and bool(advancing.get("banned", true)) == false
	proof["production_time_advances"] = is_equal_approx(float(advancing.get("time", -1.0)), 1.0) and is_equal_approx(float(advancing.get("speed_scl", -1.0)), 1.0)

	# --- no plan, no progress (UnitFactory.java:395-397, 406-408):
	# current_plan -1 keeps progress at 0 and speed_scl lerps
	# toward 0 (1.0 -> 0.95 at source_delta 1.0).
	var no_plan: Dictionary = unit_factory_build_state.source_unit_factory_production_tick_state({"efficiency": 1.0, "current_plan": -1, "progress": 0.0, "time": 0.0, "speed_scl": 1.0}, {}, 1, 1.0, 1.0, 1.0)
	proof["production_no_plan_no_progress"] = is_equal_approx(float(no_plan.get("progress", -1.0)), 0.0) and is_equal_approx(float(no_plan.get("speed_scl", -1.0)), 0.95) and int(no_plan.get("current_plan", 0)) == -1 and bool(no_plan.get("completed", true)) == false

	# --- completion (UnitFactory.java:415-436): progress 899.5 +
	# edelta 1.0 = 900.5 >= plan.time 900 -> completed, the payload
	# is the dagger unit, progress fmod 1.0 then clamped to 0.5, the
	# consume call fired and the UnitCreateEvent recorded.
	var completing: Dictionary = unit_factory_build_state.source_unit_factory_production_tick_state({"efficiency": 1.0, "current_plan": 0, "progress": 899.5, "time": 0.0, "speed_scl": 1.0}, plan, 1, 1.0, 1.0, 1.0)
	var completed_payload: Variant = completing.get("payload", null)
	proof["production_completes_payload"] = is_equal_approx(float(plan.get("time", -1.0)), 900.0) and bool(completing.get("completed", false)) == true and is_equal_approx(float(completing.get("progress", -1.0)), 0.5) and completed_payload is Dictionary and str(completed_payload.get("unit", "")) == "dagger" and bool(completing.get("consumed", false)) == true and bool(completing.get("unit_created_event", false)) == true

	# --- a held payload resets progress (UnitFactory.java:437-438):
	# progress 5.0 with a payload present reads 0 after the tick,
	# and nothing completes.
	var held: Dictionary = unit_factory_build_state.source_unit_factory_production_tick_state({"efficiency": 1.0, "current_plan": 0, "progress": 5.0, "time": 0.0, "speed_scl": 1.0, "payload": {"unit": "dagger"}}, plan, 1, 1.0, 1.0, 1.0)
	proof["production_payload_present_resets_progress"] = is_equal_approx(float(held.get("progress", -1.0)), 0.0) and bool(held.get("completed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitFactoryProductionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
