extends Node

const main_scene := preload("res://scenes/Main.tscn")
const pump_state := preload("res://src/game/SourcePumpRuntimeState.gd")
const initial_build_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# The live loop already ticked the pump a few frames during setup,
	# so the amounts below are asserted as deltas, not absolutes.
	var pump: Variant = game.call("block_sprite_at_cell", Vector2i(5, 14))
	var catalog: Dictionary = content_registry_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(catalog["liquid_id_by_name"].get("water", -1))
	var liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	var before_amount: float = float(liquid_module_state.source_get_state(liquids, water_id).get("amount", 0.0))
	var frame_before: Dictionary = pump.get_meta(pump_state.SOURCE_PUMP_BUILDING_META_KEY, {})
	var before_warmup: float = float(frame_before.get("warmup", 0.0))
	var before_progress: float = float(frame_before.get("total_progress", 0.0))

	# --- the pump update (Pump.java:160-176): one frame of pumping
	# fills 7/60 water (amount 1.0 * pumpAmount 7/60 * edelta 1.0,
	# where edelta is the tick delta — Arc Time.delta is in ticks,
	# so a frame is delta 1/60s), warms up by warmupSpeed 0.019 and
	# advances totalProgress by warmup * edelta. ---
	var update: Dictionary = pump_state.source_pump_update_state(game, Vector2i(5, 14), 1.0 / 60.0)
	proof["pump_update_produces"] = str(update.get("liquid_drop", "")) == "water" and is_equal_approx(float(update.get("amount_pumped", -1.0)), 7.0 / 60.0) and is_equal_approx(float(update.get("liquid_amount", -1.0)), before_amount + 7.0 / 60.0)
	proof["pump_update_warmup"] = is_equal_approx(float(update.get("warmup", -1.0)), before_warmup + 0.019) and is_equal_approx(float(update.get("total_progress", -1.0)), before_progress + float(update.get("warmup", 0.0)) * 1.0)
	var second: Dictionary = pump_state.source_pump_update_state(game, Vector2i(5, 14), 1.0 / 60.0)
	proof["pump_update_second_frame"] = is_equal_approx(float(second.get("amount_pumped", -1.0)), 7.0 / 60.0) and is_equal_approx(float(second.get("liquid_amount", -1.0)), float(update.get("liquid_amount", 0.0)) + 7.0 / 60.0)

	# --- the conduit line (Blocks.java:2322-2327): 7 conduits from the
	# pump to the drill, liquidCapacity 20, live in the world. ---
	var line: Dictionary = initial_build_state.source_conduit_line_placement_state(8)
	var cells: Array = line.get("cells", [])
	proof["conduit_line"] = str(line.get("block_id", "")) == "conduit" and int(line.get("count", -1)) == 7 and cells.has(Vector2i(5, 13)) and cells.has(Vector2i(6, 8)) and is_equal_approx(float(line.get("liquid_capacity", -1.0)), 20.0)
	var all_live := true
	for cell in cells:
		var sprite: Variant = game.call("block_sprite_at_cell", cell)
		if sprite == null or str(sprite.get_meta("source_block_id", "")) != "conduit":
			all_live = false
	proof["conduit_live"] = all_live and cells.size() == 7

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PumpUpdateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
