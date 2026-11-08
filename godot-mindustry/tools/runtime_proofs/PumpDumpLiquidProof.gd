extends Node

const main_scene := preload("res://scenes/Main.tscn")
const pump_state := preload("res://src/game/SourcePumpRuntimeState.gd")
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

	# The live loop already ticked the pump (and its dump) a few frames
	# during setup, so the amounts below are asserted as deltas.
	var catalog: Dictionary = content_registry_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(catalog["liquid_id_by_name"].get("water", -1))
	var pump: Variant = game.call("block_sprite_at_cell", Vector2i(5, 14))
	var conduit: Variant = game.call("block_sprite_at_cell", Vector2i(5, 13))
	var pump_liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	var conduit_liquids: Dictionary = conduit.get_meta("source_building_liquids", {})

	# --- the pump dump (Pump.java:180-182, BuildingComp.java:877-878):
	# one second of pumping fills 7.0 water (7/60 per frame over 60
	# frames); the dump then moves (pump - conduit) / 2 to the
	# conduit (fract - ofract) * 20 / 2, so both end at the average. ---
	var update: Dictionary = pump_state.source_pump_update_state(game, Vector2i(5, 14), 1.0)
	var pump_before: float = float(update.get("liquid_amount", 0.0))
	var conduit_before: float = float(liquid_module_state.source_get_state(conduit_liquids, water_id).get("amount", 0.0))
	var expected_dump: float = (pump_before - conduit_before) / 2.0
	var expected_after: float = (pump_before + conduit_before) / 2.0
	var dump: Dictionary = pump_state.source_pump_dump_liquid_state(game, Vector2i(5, 14))
	proof["pump_dump_moves_water"] = str(dump.get("liquid_drop", "")) == "water" and is_equal_approx(float(dump.get("amount_dumped", -1.0)), expected_dump) and is_equal_approx(float(dump.get("liquid_amount", -1.0)), expected_after)
	var conduit_after: float = float(liquid_module_state.source_get_state(conduit_liquids, water_id).get("amount", 0.0))
	proof["pump_dump_conduit_gains"] = is_equal_approx(conduit_after, expected_after)
	proof["pump_dump_cursor"] = int(dump.get("dump_cursor", -1)) == 0
	var pump_frame: Dictionary = pump.get_meta(pump_state.SOURCE_PUMP_BUILDING_META_KEY, {})
	proof["pump_dump_cursor_persisted"] = int(pump_frame.get("dump_cursor", -1)) == 0

	# --- a second dump right after equalizes nothing: both hold the
	# same amount, so fract == ofract and nothing transfers. ---
	var second: Dictionary = pump_state.source_pump_dump_liquid_state(game, Vector2i(5, 14))
	proof["pump_dump_second_noop"] = is_equal_approx(float(second.get("amount_dumped", -1.0)), 0.0) and is_equal_approx(float(second.get("liquid_amount", -1.0)), expected_after)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PumpDumpLiquidProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
