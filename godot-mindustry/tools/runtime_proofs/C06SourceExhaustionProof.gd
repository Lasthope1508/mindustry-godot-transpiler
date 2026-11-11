extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const adjacent_factory_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")
const efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const consume_power_state := preload("res://src/game/SourceConsumePowerState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _fresh_module(max_id: int, pairs: Dictionary) -> Dictionary:
	var amounts: Array = []
	for i in range(max_id + 1):
		amounts.append(0.0)
	for liquid_id in pairs.keys():
		amounts[int(liquid_id)] = float(pairs[liquid_id])
	return {"liquids": amounts, "current": 0, "flow": null}


func _power_step(game: Object) -> Dictionary:
	return factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)


func _simulate(game: Object, count: int) -> void:
	for iteration in range(count):
		game.call("simulate_factory", 1.0 / 60.0)


func _place(game: Object, block: Variant, cell: Vector2i) -> Sprite2D:
	var sprite := Sprite2D.new()
	game.add_child(sprite)
	game.call("record_placed_block", sprite, block, cell)
	return sprite


func _set_frame_items(sprite: Sprite2D, meta_key: String, items: Dictionary) -> void:
	# The bound RuntimeConsumer actors capture the frame's items
	# Dictionary object at bind time (SourceConsumeItemsState.
	# RuntimeConsumer.efficiency reads its own `items` field,
	# not build["items"]) — replacing the dict would leave the
	# actors reading the old, empty module forever, so the new
	# stacks are written into the existing dict in place (the
	# same object Java's ItemModule is). The frame's shouldConsume
	# body reads frame["items"] directly, so it sees either form.
	var frame: Dictionary = sprite.get_meta(meta_key, {})
	if not frame.has("items"):
		frame["items"] = {}
	var held: Dictionary = frame["items"]
	held.clear()
	for key in items:
		held[key] = items[key]
	sprite.set_meta(meta_key, frame)


func _stamp(game: Object, cell: Vector2i) -> Dictionary:
	return placed_power_graph_state.source_consumer_should_consume_for_cell_state(game, cell)


func _ready() -> void:
	var proof: Dictionary = {}

	# --- the first pass, direct: BuildingComp.updateConsumption()
	# (BuildingComp.java:1960-1978) clears shouldConsumePower when
	# a non-power consumer's efficiency is at most 0.0000001f; a
	# power consumer's failure never clears it (the `cons !=
	# block.consPower` guard). ---
	var starved_pass: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 0.0, "is_power": false}])
	proof["first_pass_starved_clears"] = bool(starved_pass.get("should_consume_power", true)) == false
	var fed_pass: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 1.0, "is_power": false}])
	proof["first_pass_fed_keeps"] = bool(fed_pass.get("should_consume_power", false)) == true
	var power_fail_pass: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 0.0, "is_power": true}])
	proof["first_pass_power_failure_ignored"] = bool(power_fail_pass.get("should_consume_power", false)) == true

	# --- requested power, direct: ConsumePower.requestedPower
	# (ConsumePower.java:60-63) charges an unbuffered consumer
	# `usage * (entity.shouldConsume() ? 1f : 0f)` — an output-full
	# factory requests nothing. ---
	proof["requested_power_output_full_zero"] = is_equal_approx(float(consume_power_state.requested_power_state(false, 0.5, 0.0, 0.0, false).get("requested_power", -1.0)), 0.0)
	proof["requested_power_fed_usage"] = is_equal_approx(float(consume_power_state.requested_power_state(false, 0.5, 0.0, 0.0, true).get("requested_power", -1.0)), 0.5)

	# --- the helper is pure: a null game reads the true default,
	# so the graph keeps its static behavior when there is no
	# building to read a frame from. ---
	var null_helper: Dictionary = placed_power_graph_state.source_consumer_should_consume_for_cell_state(null, Vector2i(30, 7))
	proof["stamp_null_game_default"] = bool(null_helper.get("should_consume", false)) == true and bool(null_helper.get("shouldConsumePower", false)) == true and bool(null_helper.get("found", true)) == false

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the setup frames run the live loop with real deltas, and
	# the wave timer starts at 0 with no enemies, so a wave may
	# already have spawned: clear the board and pin the wave timer
	# far out, so the measured ticks run only the factory chain
	# (the pause proof uses the same pin). ---
	game.set("wave_cooldown", 100000.0)
	for enemy in game.get("enemy_units"):
		var enemy_dict: Dictionary = enemy
		var sprite = enemy_dict.get("sprite", null)
		if is_instance_valid(sprite):
			sprite.queue_free()
	game.set("enemy_units", [])
	game.set("bullet_hit_count", 0)

	# --- reset the measured state: the battery starts empty (the
	# live-loop step writes its status back to the sprite meta
	# every tick, so a charge from the setup frames would leak
	# into the measurement). ---
	placed_power_graph_state.source_battery_set_power_status_for_cell_state(game, Vector2i(23, 7), 0.0)

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var cryofluid_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var max_liquid_id := 0
	for liquid_id in liquid_id_by_name.values():
		max_liquid_id = maxi(max_liquid_id, int(liquid_id))

	var smelter = blocks_by_id["silicon-smelter"]
	var mixer = blocks_by_id["cryofluid-mixer"]
	var crusher = blocks_by_id["cliff-crusher"]

	# --- output-full, direct: GenericCrafterBuild.shouldConsume()
	# (GenericCrafter.java:203-231) blocks when the held output
	# stack plus one output would exceed itemCapacity (silicon
	# 10 + 1 > 10); 9 + 1 == 10 still consumes, and an empty
	# frame consumes. ---
	var full_frame: Dictionary = {"enabled": true, "items": {"silicon": 10}}
	var full_should: Dictionary = factory_build_state.source_factory_should_consume_state(full_frame, smelter, {}, liquid_id_by_name)
	proof["factory_should_consume_output_full_item"] = bool(full_should.get("should_consume", true)) == false and bool(full_should.get("item_blocked", false)) == true
	var room_frame: Dictionary = {"enabled": true, "items": {"silicon": 9}}
	var room_should: Dictionary = factory_build_state.source_factory_should_consume_state(room_frame, smelter, {}, liquid_id_by_name)
	proof["factory_should_consume_room_item"] = bool(room_should.get("should_consume", false)) == true and bool(room_should.get("item_blocked", true)) == false
	var empty_frame: Dictionary = {"enabled": true, "items": {}}
	var empty_should: Dictionary = factory_build_state.source_factory_should_consume_state(empty_frame, smelter, {}, liquid_id_by_name)
	proof["factory_should_consume_empty"] = bool(empty_should.get("should_consume", false)) == true

	# --- output-full, direct, liquids: the mixer holds its
	# output liquid at liquidCapacity (36.0, cryofluid-mixer), so
	# every output liquid is full (`if(allFull){`,
	# GenericCrafter.java:226) and it stops consuming; at 10.0
	# it still consumes. ---
	var mixer_full_module: Dictionary = _fresh_module(max_liquid_id, {cryofluid_id: 36.0})
	var mixer_full_should: Dictionary = factory_build_state.source_factory_should_consume_state({"enabled": true, "items": {}}, mixer, mixer_full_module, liquid_id_by_name)
	proof["mixer_liquid_full"] = bool(mixer_full_should.get("should_consume", true)) == false and bool(mixer_full_should.get("all_liquids_full", false)) == true
	var mixer_room_module: Dictionary = _fresh_module(max_liquid_id, {cryofluid_id: 10.0})
	var mixer_room_should: Dictionary = factory_build_state.source_factory_should_consume_state({"enabled": true, "items": {}}, mixer, mixer_room_module, liquid_id_by_name)
	proof["mixer_liquid_room"] = bool(mixer_room_should.get("should_consume", false)) == true and bool(mixer_room_should.get("all_liquids_full", true)) == false

	# --- output-full, direct, adjacent: WallCrafterBuild.
	# shouldConsume() (WallCrafter.java:246-248) consumes while
	# the held output stack fits itemCapacity — the crusher
	# holds sand 10 at capacity 10, so it stops; at 9 it still
	# consumes. ---
	var crusher_full_frame: Dictionary = {"enabled": true, "items": {"sand": 10}}
	var crusher_full_should: Dictionary = adjacent_factory_build_state.source_adjacent_factory_should_consume_state(crusher_full_frame, crusher)
	proof["adjacent_crusher_full"] = bool(crusher_full_should.get("should_consume", true)) == false and bool(crusher_full_should.get("output_blocked", false)) == true
	var crusher_room_frame: Dictionary = {"enabled": true, "items": {"sand": 9}}
	var crusher_room_should: Dictionary = adjacent_factory_build_state.source_adjacent_factory_should_consume_state(crusher_room_frame, crusher)
	proof["adjacent_crusher_room"] = bool(crusher_room_should.get("should_consume", false)) == true and bool(crusher_room_should.get("output_blocked", true)) == false

	# --- LIVE, starved smelter: the smelter (30,7) is placed
	# with no inputs, so its coal/sand actors read efficiency
	# 0.0 (ConsumeItems.java:51-54, no stack held) and the
	# first pass clears should_consume_power — while its
	# outputs still have room, so should_consume stays true.
	# The power step runs after the tick driver stamps the
	# flag, so five ticks settle it; the graph then needs only
	# the lancer's 6.0/60. ---
	var smelter_cell := Vector2i(30, 7)
	var smelter_sprite := _place(game, smelter, smelter_cell)
	_simulate(game, 5)
	var starved_stamp: Dictionary = _stamp(game, smelter_cell)
	proof["live_smelter_starved_flag_false"] = bool(starved_stamp.get("shouldConsumePower", true)) == false
	proof["live_smelter_starved_should_consume_true"] = bool(starved_stamp.get("should_consume", false)) == true
	var starved_step: Dictionary = _power_step(game)
	proof["live_needed_starved_excludes_smelter"] = is_equal_approx(float(starved_step.get("power_needed", -1.0)), 6.0 / 60.0)

	# --- LIVE, fed smelter: coal 5 + sand 5 fill the rows, so
	# the actors read efficiency 1.0 and the first pass keeps
	# the flag — the graph now needs the smelter's 0.5/60 on
	# top of the lancer's 6.0/60. Five ticks is far short of
	# the 40-tick craftTime, so nothing is consumed yet. ---
	_set_frame_items(smelter_sprite, factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {"coal": 5, "sand": 5})
	_simulate(game, 5)
	var fed_stamp: Dictionary = _stamp(game, smelter_cell)
	proof["live_smelter_fed_flag_true"] = bool(fed_stamp.get("shouldConsumePower", false)) == true
	var fed_step: Dictionary = _power_step(game)
	proof["live_needed_fed_includes_smelter"] = is_equal_approx(float(fed_step.get("power_needed", -1.0)), 6.5 / 60.0)

	# --- LIVE, output-full smelter: silicon 10 fills the
	# output stack while the inputs stay fed, so the two acts
	# separate — should_consume goes false (item_blocked) while
	# the first-pass flag stays true, and the graph needs only
	# the lancer again because requestedPower reads
	# should_consume false. ---
	_set_frame_items(smelter_sprite, factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {"coal": 5, "sand": 5, "silicon": 10})
	_simulate(game, 5)
	var full_stamp: Dictionary = _stamp(game, smelter_cell)
	proof["live_smelter_output_full_stamp_false"] = bool(full_stamp.get("should_consume", true)) == false
	proof["live_smelter_output_full_flag_true"] = bool(full_stamp.get("shouldConsumePower", false)) == true
	var full_step: Dictionary = _power_step(game)
	proof["live_needed_output_full_excludes_smelter"] = is_equal_approx(float(full_step.get("power_needed", -1.0)), 6.0 / 60.0)

	# --- LIVE, adjacent crusher: the crusher (40,7) is placed
	# with room for its sand output, so the stamp reads true
	# on both keys and the graph needs the lancer plus the
	# crusher's 0.183333.../60; filling its sand stack to
	# capacity 10 stops it, and the graph drops back to the
	# lancer alone. ---
	var crusher_cell := Vector2i(40, 7)
	var crusher_sprite := _place(game, crusher, crusher_cell)
	_simulate(game, 5)
	var crusher_stamp: Dictionary = _stamp(game, crusher_cell)
	proof["live_crusher_stamp_true"] = bool(crusher_stamp.get("should_consume", false)) == true and bool(crusher_stamp.get("shouldConsumePower", false)) == true
	var crusher_step: Dictionary = _power_step(game)
	proof["live_needed_crusher_included"] = is_equal_approx(float(crusher_step.get("power_needed", -1.0)), (6.0 + 0.18333333333333332) / 60.0)
	_set_frame_items(crusher_sprite, adjacent_factory_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {"sand": 10})
	_simulate(game, 5)
	var crusher_full_stamp: Dictionary = _stamp(game, crusher_cell)
	proof["live_crusher_full_stamp_false"] = bool(crusher_full_stamp.get("should_consume", true)) == false
	var crusher_full_step: Dictionary = _power_step(game)
	proof["live_needed_crusher_excluded"] = is_equal_approx(float(crusher_full_step.get("power_needed", -1.0)), 6.0 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06SourceExhaustionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
