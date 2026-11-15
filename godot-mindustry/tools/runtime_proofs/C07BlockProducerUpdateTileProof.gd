extends Node

const main_scene := preload("res://scenes/Main.tscn")
const constructor_build_state := preload("res://src/game/SourceConstructorBuildState.gd")
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

	# --- Pure advance (N2274): BlockProducerBuild.updateTile()
	# (BlockProducer.java:107-128). The produce gate
	# (BlockProducer.java:110, `boolean produce = recipe !=
	# null && efficiency > 0 && payload == null;`) with the
	# progress advance (BlockProducer.java:113, `progress +=
	# buildSpeed * edelta();`); the completion branch
	# (BlockProducer.java:115-120, `if(progress >=
	# recipe.buildTime){` / `consume();` / `payload = new
	# BuildPayload(recipe, team);` / `payVector.setZero();` /
	# `progress %= 1f;` -- the remainder is KEPT); the heat
	# lerp (BlockProducer.java:124, `heat =
	# Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);`);
	# the time advance (BlockProducer.java:125, `time += heat
	# * delta();`); moveOutPayload (BlockProducer.java:127).
	# delta() is `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924) and edelta() is `return
	# efficiency * delta();` (BuildingComp.java:1927-1929).
	# The front snapshot is the no-front default (no live
	# front query yet) and move_payload_result is false.
	var no_front: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false}
	var conveyor_stacks: Array = [{"item": "copper", "amount": 1}]

	# --- Progress accumulates while producing: 0.6 buildSpeed
	# (constructor, Blocks.java:6662) * edelta 1.0 (efficiency
	# 1.0, delta 1.0 tick) = 0.6, below the 20.0 buildTime, so
	# nothing completes.
	var producing_frame: Dictionary = {"recipe": {"block": "conveyor"}, "team_id": 1, "efficiency": 1.0, "progress": 0.0, "heat": 0.0, "time": 0.0, "items": {"copper": 1}, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var accumulated: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(producing_frame, 1.0, 1.0, 0.6, 20.0, conveyor_stacks, 0.0, 3.0, no_front, false)
	proof["progress_accumulates_when_producing"] = is_equal_approx(float(accumulated.get("progress", -1.0)), 0.6) and bool(accumulated.get("consumed", true)) == false and accumulated.get("payload", {}) == null

	# --- Progress completes and spawns the payload: 19.8 +
	# 0.6 = 20.4 >= 20.0 buildTime, so consume() fires (the
	# N2265 trigger removes the 1 copper), the BuildPayload
	# spawns (BuildPayload.java:18-21, `public BuildPayload(
	# Block block, Team team){`), and payVector zeroes before
	# moveOutPayload approaches the dest in the same tick.
	var completing_frame: Dictionary = {"recipe": {"block": "conveyor"}, "team_id": 1, "efficiency": 1.0, "progress": 19.8, "heat": 0.0, "time": 0.0, "items": {"copper": 1}, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var completed: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(completing_frame, 1.0, 1.0, 0.6, 20.0, conveyor_stacks, 0.0, 3.0, no_front, false)
	var spawned_payload: Dictionary = completed.get("payload", {})
	proof["progress_completes_spawns_payload"] = bool(completed.get("consumed", false)) and str(spawned_payload.get("block", "")) == "conveyor" and int(spawned_payload.get("team", -1)) == 1 and int(Dictionary(completed.get("items", {})).get("copper", -1)) == 0

	# --- Progress keeps the remainder: 20.4 %= 1f is 0.4, NOT
	# a reset to 0 (BlockProducer.java:120, `progress %= 1f;`).
	proof["progress_keeps_remainder_mod_one"] = is_equal_approx(float(completed.get("progress", -1.0)), 0.4) and not is_equal_approx(float(completed.get("progress", -1.0)), 0.0)

	# --- Heat lerps toward produce: producing from 0.0 ->
	# lerp(0, 1, 0.15 * 1.0) = 0.15; idle (no recipe) from 0.5
	# -> lerp(0.5, 0, 0.15 * 1.0) = 0.425. The lerp takes the
	# RAW Time.delta (arc Mathf.lerpDelta, Mathf.java:430-432).
	var heated: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(producing_frame, 1.0, 1.0, 0.6, 20.0, conveyor_stacks, 0.0, 3.0, no_front, false)
	var idle_frame: Dictionary = {"recipe": null, "team_id": 1, "efficiency": 1.0, "progress": 0.0, "heat": 0.5, "time": 0.0, "items": {}, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var cooled: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(idle_frame, 1.0, 1.0, 0.6, 20.0, [], 0.0, 3.0, no_front, false)
	proof["heat_lerps_toward_produce"] = is_equal_approx(float(heated.get("heat", -1.0)), 0.15) and is_equal_approx(float(cooled.get("heat", -1.0)), 0.425)

	# --- Time accumulates with heat: the NEW heat (0.15)
	# times delta 1.0 (BlockProducer.java:125, `time += heat
	# * delta();` -- the heat line runs first).
	proof["time_accumulates_with_heat"] = is_equal_approx(float(heated.get("time", -1.0)), 0.15)

	# --- No progress without the produce gate: null recipe,
	# zero efficiency, or a payload already present each hold
	# progress at 5.0 (BlockProducer.java:110, `boolean
	# produce = recipe != null && efficiency > 0 && payload
	# == null;`).
	var no_recipe_frame: Dictionary = {"recipe": null, "team_id": 1, "efficiency": 1.0, "progress": 5.0, "heat": 0.0, "time": 0.0, "items": {}, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var no_recipe: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(no_recipe_frame, 1.0, 1.0, 0.6, 20.0, [], 0.0, 3.0, no_front, false)
	var no_efficiency_frame: Dictionary = {"recipe": {"block": "conveyor"}, "team_id": 1, "efficiency": 0.0, "progress": 5.0, "heat": 0.0, "time": 0.0, "items": {"copper": 1}, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var no_efficiency: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(no_efficiency_frame, 1.0, 1.0, 0.6, 20.0, conveyor_stacks, 0.0, 3.0, no_front, false)
	var has_payload_frame: Dictionary = {"recipe": {"block": "conveyor"}, "team_id": 1, "efficiency": 1.0, "progress": 5.0, "heat": 0.0, "time": 0.0, "items": {"copper": 1}, "payload": {"block": "conveyor", "team": 1}, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var has_payload: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(has_payload_frame, 1.0, 1.0, 0.6, 20.0, conveyor_stacks, 0.0, 3.0, no_front, false)
	proof["no_progress_without_recipe"] = is_equal_approx(float(no_recipe.get("progress", -1.0)), 5.0) and is_equal_approx(float(no_efficiency.get("progress", -1.0)), 5.0) and is_equal_approx(float(has_payload.get("progress", -1.0)), 5.0) and bool(no_recipe.get("consumed", true)) == false and bool(no_efficiency.get("consumed", true)) == false and bool(has_payload.get("consumed", true)) == false

	# --- moveOutPayload approaches the dest: a payload at
	# payVector (0, 0) with rotdeg 0 and size 3 heads for dest
	# trns(0, 12) = (12, 0) (PayloadBlock.java:204, `Vec2 dest
	# = Tmp.v1.trns(rotdeg(), size * tilesize/2f);`) by
	# payloadSpeed * delta() = 0.7 * 1.0 (PayloadBlock.java:207,
	# `payVector.approach(dest, payloadSpeed * delta());`),
	# so payVector.x reads 0.7 and the payload stays (not
	# arrived -- arrival is dst2 < 0.001^2).
	var move_out_frame: Dictionary = {"recipe": null, "team_id": 1, "efficiency": 0.0, "progress": 0.0, "heat": 0.0, "time": 0.0, "items": {}, "payload": {"block": "conveyor", "team": 1}, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}
	var moved_out: Dictionary = constructor_build_state.source_constructor_update_tile_advance_state(move_out_frame, 1.0, 1.0, 0.6, 20.0, [], 0.0, 3.0, no_front, false)
	var moved_pay_vector: Dictionary = moved_out.get("pay_vector", {})
	proof["move_out_payload_approaches_dest"] = is_equal_approx(float(moved_pay_vector.get("x", -1.0)), 0.7) and is_equal_approx(float(moved_pay_vector.get("y", -1.0)), 0.0) and moved_out.get("payload", null) != null

	# --- Live tick: the constructor is a Constructor build
	# with a power consumer (consumePower 2.5f, large-constructor
	# 3f), placed live; the tick driver is called directly (as
	# the N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. The
	# recipe is the conveyor (catalog requirements: 1 copper;
	# buildTime = 1 * 0.5 copper cost = 0.5, Block.java:1432-1443),
	# so one tick at buildSpeed 0.6 advances progress 0.6 >= 0.5
	# and completes: the payload spawns, the copper is consumed,
	# progress keeps the 0.6 remainder, and heat lerps to 0.15.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var constructor_cell := Vector2i(28, 20)
	var constructor := Sprite2D.new()
	game.add_child(constructor)
	game.call("record_placed_block", constructor, blocks_by_id["constructor"], constructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	constructor_build_state.source_constructor_bind_frame_state(constructor, blocks_by_id["constructor"])
	var constructor_frame: Dictionary = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})

	# N2216: the shouldConsume gate (BlockProducer.java:103,
	# `return super.shouldConsume() && recipe() != null;`) closes
	# with no recipe, so the proof holds a recipe fixture (the
	# family dict fixture {"block": <id>}, the N2161/N2216
	# precedent) -- otherwise efficiency would read 0.
	constructor_frame["recipe"] = {"block": "conveyor"}

	constructor_frame["power_status"] = 1.0
	constructor_frame["items"] = {"copper": 1}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	var live_payload: Dictionary = constructor_frame.get("payload", {})
	proof["live_tick_advances_progress"] = str(live_payload.get("block", "")) == "conveyor" and int(Dictionary(constructor_frame.get("items", {})).get("copper", -1)) == 0 and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.6) and is_equal_approx(float(constructor_frame.get("heat", -1.0)), 0.15) and is_equal_approx(float(Dictionary(constructor_frame.get("pay_vector", {})).get("x", -1.0)), 0.7)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BlockProducerUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
