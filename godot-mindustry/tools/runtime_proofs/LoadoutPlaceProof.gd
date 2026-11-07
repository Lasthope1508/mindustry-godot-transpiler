extends Node

const main_scene := preload("res://scenes/Main.tscn")
const geometry := preload("res://src/game/SourceBlockGeometry.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


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
	var core = catalog.get_by_id("core-shard")
	var drill = catalog.get_by_id("mechanical-drill")
	var conveyor = catalog.get_by_id("conveyor")
	var copper_ore = catalog.get_by_id("ore-copper")
	var sharded: int = geometry.SOURCE_TEAM_SHARDED_ID

	# --- Loadout: core + drill + conveyor, core placed at (30, 20). ---
	# Origin is (30 - 0, 20 - 0) = (30, 20): core-anchored, not centered.
	# The size-3 core footprint is centered on its cell (sizeOffset -1),
	# so it covers (29..31, 19..21), not (30..32, 20..22). Copper under
	# two Drill cells so the Drill frame selects like the bootstrap
	# Drill. Two blocking conveyors are pre-placed first: one in the
	# Drill footprint (the removal pass must clear it) and one in the
	# Core footprint (the removal pass must skip core stiles).
	for ore_cell in [Vector2i(33, 20), Vector2i(33, 21)]:
		terrain.source_set_world_overlay_state(game, ore_cell.x, ore_cell.y, copper_ore, false)
	var blocking_drill := Sprite2D.new()
	game.add_child(blocking_drill)
	game.call("record_placed_block", blocking_drill, conveyor, Vector2i(33, 20))
	var blocking_core := Sprite2D.new()
	game.add_child(blocking_core)
	game.call("record_placed_block", blocking_core, conveyor, Vector2i(31, 20))
	var schem: Dictionary = {"width": 6, "height": 3, "tiles": [
		{"block": core, "x": 0, "y": 0, "config": null, "rotation": 0},
		{"block": drill, "x": 3, "y": 0, "config": "copper", "rotation": 0},
		{"block": conveyor, "x": 5, "y": 0, "config": null, "rotation": 0},
	]}
	var configured_pairs: Array = []
	var config_callback := func(_player: Variant, build: Variant, value: Variant) -> void:
		configured_pairs.append([build, value])
	var registered_cores: Array = []
	var register_core_hook := func(build: Variant, team_id: int) -> void:
		registered_cores.append([build, team_id])
	var priority_hook := func(block: Variant) -> int:
		return {"mechanical-drill": 10, "conveyor": -10}.get(block.id, 0)
	var placed: Dictionary = game.call("source_place_loadout_state", schem, 30, 20, sharded, true, priority_hook, config_callback, register_core_hook)
	await get_tree().process_frame
	var core_tile: Dictionary = game.call("source_world_tile", 30, 20)
	var drill_tile: Dictionary = game.call("source_world_tile", 33, 20)
	var conveyor_tile: Dictionary = game.call("source_world_tile", 35, 20)
	proof["loadout_place_places_all_tiles"] = placed.get("placed") == 3 and placed.get("skipped") == 0 and placed.get("origin") == Vector2i(30, 20) and core_tile.get("block") == core and core_tile.get("build") != null and game.call("source_world_tile", 31, 20).get("build") == core_tile.get("build") and game.call("source_world_tile", 29, 19).get("block") == core and game.call("source_world_tile", 31, 21).get("block") == core and drill_tile.get("block") == drill and drill_tile.get("build") != null and game.call("source_world_tile", 34, 21).get("block") == drill and conveyor_tile.get("block") == conveyor and conveyor_tile.get("build") != null
	proof["loadout_place_core_anchored"] = placed.get("origin") == Vector2i(30, 20) and placed.get("origin") != Vector2i(27, 19)
	proof["loadout_place_sorts_by_priority"] = placed.get("results")[0].get("cell") == Vector2i(33, 20) and placed.get("results")[1].get("cell") == Vector2i(30, 20) and placed.get("results")[2].get("cell") == Vector2i(35, 20) and schem["tiles"][0]["block"] == core and schem["tiles"][1]["block"] == drill and schem["tiles"][2]["block"] == conveyor
	proof["loadout_place_removal_clears_blocking_build"] = placed.get("results")[0].get("removed") == 1 and not is_instance_valid(blocking_drill) and drill_tile.get("block") == drill
	proof["loadout_place_core_skips_removal"] = placed.get("results")[1].get("removed") == 0 and game.call("source_world_tile", 31, 20).get("block") == core
	proof["loadout_place_registers_core"] = placed.get("cores_registered") == 1 and registered_cores.size() == 1 and registered_cores[0][0] == core_tile.get("build") and registered_cores[0][1] == sharded and placed.get("results")[1].get("core_placed") == true and placed.get("results")[1].get("core_registered") == true and placed.get("results")[0].get("core_placed") == false
	proof["loadout_place_config_hook_receives_build_and_config"] = placed.get("configured") == 1 and configured_pairs.size() == 1 and configured_pairs[0][0] == drill_tile.get("build") and configured_pairs[0][1] == "copper"
	proof["loadout_place_team_is_sharded"] = int(core_tile.get("build").get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == sharded and int(drill_tile.get("build").get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == sharded
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("LoadoutPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
