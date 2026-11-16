extends Node

const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")
const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


class FakeContentCatalog extends RefCounted:
	var blocks: Dictionary = {}

	func _init(blocks_input: Dictionary) -> void:
		blocks = blocks_input

	func get_by_id(block_id: String):
		return blocks.get(block_id, null)


class FakePowerGame extends RefCounted:
	var sprites: Dictionary = {}
	var placed_block_origins: Dictionary = {}
	var content_catalog = null
	var rules_state: Dictionary = {}

	func block_sprite_at_cell(cell: Vector2i) -> Variant:
		return sprites.get(cell, null)

	func power_graph_role_for_block(block) -> Dictionary:
		return building_power_state.block_power_role_state(block)


func _battery_at(batteries: Array, cell: Vector2i) -> Dictionary:
	for battery in batteries:
		if battery is Dictionary and battery.get("origin_cell", null) == cell:
			return battery
	return {}


func _make_game(battery_ids: Array, cheating: bool) -> Dictionary:
	# A proof-local fake game (the N2354 FakePowerGame precedent,
	# extended with the placed-block origins + content catalog the
	# factory step groups through): two battery sprites and one
	# accelerator sprite, each carrying the block id the catalog
	# resolves. The battery block dicts carry the live `enabled`
	# flag the N2134 stamp reads through block_properties; the
	# static enabled from block_battery_state is true for both
	# (has_power or outputs_power or consumes_power or
	# power_buffered), so only the stamp can tell them apart.
	# The accelerator block consumes no power (usage 0.0), so the
	# distribute step neither uses nor charges the batteries and
	# the only status movement is the launch drain itself; its
	# frame carries a pending one-shot launch_drain_request of
	# 500.0 (the N2354 shape).
	var blocks := {
		"battery": {"id": "battery", "has_power": true, "outputs_power": true, "consumes_power": true, "power_buffered": true, "power_usage": 0.0, "power_capacity": 1000.0, "enabled": true},
		"battery-disabled": {"id": "battery-disabled", "has_power": true, "outputs_power": true, "consumes_power": true, "power_buffered": true, "power_usage": 0.0, "power_capacity": 1000.0, "enabled": false},
		"accelerator": {"id": "accelerator", "has_power": true, "outputs_power": false, "consumes_power": true, "power_buffered": false, "power_usage": 0.0, "power_capacity": 0.0, "enabled": true},
	}
	var game := FakePowerGame.new()
	game.content_catalog = FakeContentCatalog.new(blocks)
	var first_cell := Vector2i(1, 1)
	var second_cell := Vector2i(2, 2)
	var accelerator_cell := Vector2i(3, 3)
	var first_sprite := Sprite2D.new()
	first_sprite.set_meta(placed_block_state.SOURCE_BLOCK_ID_META_KEY, battery_ids[0])
	first_sprite.set_meta(placed_power_graph_state.SOURCE_BATTERY_POWER_STATUS_META_KEY, 1.0)
	game.sprites[first_cell] = first_sprite
	var second_sprite := Sprite2D.new()
	second_sprite.set_meta(placed_block_state.SOURCE_BLOCK_ID_META_KEY, battery_ids[1])
	second_sprite.set_meta(placed_power_graph_state.SOURCE_BATTERY_POWER_STATUS_META_KEY, 1.0)
	game.sprites[second_cell] = second_sprite
	var accelerator_sprite := Sprite2D.new()
	accelerator_sprite.set_meta(placed_block_state.SOURCE_BLOCK_ID_META_KEY, "accelerator")
	accelerator_sprite.set_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {"enabled": true, "power_status": 1.0, "battery_stored": 0.0, "launch_drain_request": {"requirement": 500.0}})
	if cheating:
		accelerator_sprite.set_meta(block_geometry.SOURCE_BUILD_TEAM_META_KEY, 1)
		game.rules_state = {"teams": {1: {"cheat": true}}}
	game.sprites[accelerator_cell] = accelerator_sprite
	game.placed_block_origins = {first_cell: first_cell, second_cell: second_cell, accelerator_cell: accelerator_cell}
	return {"game": game, "first_cell": first_cell, "second_cell": second_cell, "accelerator_cell": accelerator_cell, "accelerator_sprite": accelerator_sprite}


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Mixed game: one enabled battery (1.0 x 1000) and one
	# disabled battery (1.0 x 1000, live enabled false). The
	# factory step stamps the grouped batteries before the graph
	# update, so the launch drain (requirement 500, 50% of the
	# enabled stored 1000) scales ONLY the enabled battery
	# (1.0 -> 0.5) and the N2342 stored total reads 500.0 --
	# the disabled battery's 1000 is excluded from both, even
	# though its static enabled was true. ---
	var mixed: Dictionary = _make_game(["battery", "battery-disabled"], false)
	var mixed_game: FakePowerGame = mixed.get("game")
	var mixed_step: Dictionary = factory_state.source_factory_update_power_graph_state(mixed_game, 1.0 / 60.0)
	var mixed_frame: Dictionary = mixed.get("accelerator_sprite").get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var mixed_distribute: Array = mixed_step.get("update", {}).get("battery_distribute_state", {}).get("batteries", [])
	var mixed_enabled: Dictionary = _battery_at(mixed_distribute, mixed.get("first_cell"))
	var mixed_disabled: Dictionary = _battery_at(mixed_distribute, mixed.get("second_cell"))
	proof["factory_stamp_disabled_excluded_from_stored"] = is_equal_approx(float(mixed_frame.get("battery_stored", -1.0)), 500.0)
	proof["factory_stamp_disabled_untouched_by_drain"] = is_equal_approx(float(placed_power_graph_state.source_battery_power_status_for_cell_state(mixed_game, mixed.get("second_cell")).get("status", -1.0)), 1.0)
	proof["factory_stamp_enabled_drained"] = is_equal_approx(float(placed_power_graph_state.source_battery_power_status_for_cell_state(mixed_game, mixed.get("first_cell")).get("status", -1.0)), 0.5)
	proof["factory_stamp_disabled_flag_false_in_update"] = bool(mixed_enabled.get("enabled", false)) == true and bool(mixed_disabled.get("enabled", true)) == false

	# --- All-enabled control: two enabled batteries (1.0 x 1000
	# each) store 2000, so the same 500.0 drain scales BOTH by
	# x0.75 (percentage 0.25) and the stored total reads 1500.0
	# -- the stamp leaves an all-enabled list unchanged. ---
	var enabled_only: Dictionary = _make_game(["battery", "battery"], false)
	var enabled_game: FakePowerGame = enabled_only.get("game")
	var enabled_step: Dictionary = factory_state.source_factory_update_power_graph_state(enabled_game, 1.0 / 60.0)
	var enabled_frame: Dictionary = enabled_only.get("accelerator_sprite").get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var enabled_distribute: Array = enabled_step.get("update", {}).get("battery_distribute_state", {}).get("batteries", [])
	var all_enabled_flags := enabled_distribute.size() == 2
	for battery in enabled_distribute:
		if not (battery is Dictionary) or not bool(battery.get("enabled", false)):
			all_enabled_flags = false
	proof["factory_stamp_all_enabled_drain_scales_both"] = is_equal_approx(float(placed_power_graph_state.source_battery_power_status_for_cell_state(enabled_game, enabled_only.get("first_cell")).get("status", -1.0)), 0.75) and is_equal_approx(float(placed_power_graph_state.source_battery_power_status_for_cell_state(enabled_game, enabled_only.get("second_cell")).get("status", -1.0)), 0.75)
	proof["factory_stamp_all_enabled_stored_total"] = is_equal_approx(float(enabled_frame.get("battery_stored", -1.0)), 1500.0)
	proof["factory_stamp_all_enabled_flags_true"] = all_enabled_flags

	# --- Cheat branch: the same mixed batteries, but the
	# accelerator's team cheats, so PowerGraph.update() returns
	# before the distribution runs and the drain + stored total
	# read the top-level batteries instead. The stamp ran before
	# the update, so those are the stamped list too: the
	# disabled battery is still untouched and the stored total
	# still reads 500.0. (Stamping updated_batteries instead
	# would leave this branch unstamped.) ---
	var cheat: Dictionary = _make_game(["battery", "battery-disabled"], true)
	var cheat_game: FakePowerGame = cheat.get("game")
	var cheat_step: Dictionary = factory_state.source_factory_update_power_graph_state(cheat_game, 1.0 / 60.0)
	var cheat_frame: Dictionary = cheat.get("accelerator_sprite").get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	proof["factory_stamp_cheat_branch_disabled_untouched"] = bool(cheat_step.get("update", {}).get("cheat_state", {}).get("returned", false)) == true and is_equal_approx(float(placed_power_graph_state.source_battery_power_status_for_cell_state(cheat_game, cheat.get("second_cell")).get("status", -1.0)), 1.0)
	proof["factory_stamp_cheat_branch_stored_total"] = is_equal_approx(float(cheat_frame.get("battery_stored", -1.0)), 500.0)

	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FactoryBatteryEnabledStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
