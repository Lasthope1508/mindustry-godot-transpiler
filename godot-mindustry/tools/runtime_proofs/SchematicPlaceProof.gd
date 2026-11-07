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
	var drill = catalog.get_by_id("mechanical-drill")
	var conveyor = catalog.get_by_id("conveyor")
	var copper_ore = catalog.get_by_id("ore-copper")
	var air = catalog.get_by_id("air")
	var sharded: int = geometry.SOURCE_TEAM_SHARDED_ID

	# --- Schem A: Drill + 2 conveyors, placed at center (27, 21). ---
	# Origin is (27 - 4/2, 21 - 2/2) = (25, 20). Copper under two Drill
	# cells so the Drill frame selects like the bootstrap Drill.
	for ore_cell in [Vector2i(25, 20), Vector2i(25, 21)]:
		terrain.source_set_world_overlay_state(game, ore_cell.x, ore_cell.y, copper_ore, false)
	var schem_a: Dictionary = {"width": 4, "height": 2, "tiles": [
		{"block": drill, "x": 0, "y": 0, "config": null, "rotation": 0},
		{"block": conveyor, "x": 2, "y": 0, "config": "copper", "rotation": 0},
		{"block": conveyor, "x": 3, "y": 0, "config": null, "rotation": 0},
	]}
	var configured_pairs: Array = []
	var config_callback := func(_player: Variant, build: Variant, value: Variant) -> void:
		configured_pairs.append([build, value])
	var placed_a: Dictionary = game.call("source_place_schematic_state", schem_a, 27, 21, sharded, true, null, config_callback)
	var tile_25_20: Dictionary = game.call("source_world_tile", 25, 20)
	var tile_27_20: Dictionary = game.call("source_world_tile", 27, 20)
	proof["schematic_place_places_all_tiles"] = placed_a.get("placed") == 3 and placed_a.get("skipped") == 0 and placed_a.get("origin") == Vector2i(25, 20) and tile_25_20.get("block") == drill and tile_25_20.get("build") != null and game.call("source_world_tile", 26, 20).get("build") == tile_25_20.get("build") and game.call("source_world_tile", 25, 21).get("build") == tile_25_20.get("build") and game.call("source_world_tile", 26, 21).get("block") == drill and tile_27_20.get("block") == conveyor and tile_27_20.get("build") != null and game.call("source_world_tile", 28, 20).get("block") == conveyor
	proof["schematic_place_team_is_sharded"] = int(tile_25_20.get("build").get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == sharded
	proof["schematic_place_config_hook_receives_build_and_config"] = placed_a.get("configured") == 1 and configured_pairs.size() == 1 and configured_pairs[0][0] == tile_27_20.get("build") and configured_pairs[0][1] == "copper"

	# --- Overwrite: a 1x1 Conveyor over the Drill replaces it. ---
	var schem_c: Dictionary = {"width": 1, "height": 1, "tiles": [
		{"block": conveyor, "x": 0, "y": 0, "config": null, "rotation": 0},
	]}
	var drill_sprite: Variant = tile_25_20.get("build")
	var placed_c: Dictionary = game.call("source_place_schematic_state", schem_c, 25, 20, sharded, true, null, null)
	await get_tree().process_frame
	proof["schematic_place_overwrite_replaces"] = placed_c.get("placed") == 1 and not is_instance_valid(drill_sprite) and game.call("source_world_tile", 25, 20).get("block") == conveyor and game.call("source_world_tile", 26, 20).get("block") == air and game.call("source_world_tile", 25, 21).get("build") == null and game.call("source_world_tile", 26, 21).get("build") == null

	# --- No overwrite + hook: Conveyor rejected, Drill allowed. ---
	var schem_d: Dictionary = {"width": 2, "height": 1, "tiles": [
		{"block": conveyor, "x": 0, "y": 0, "config": null, "rotation": 0},
		{"block": drill, "x": 1, "y": 0, "config": null, "rotation": 0},
	]}
	var reject_conveyor := func(block: Variant, _team: int, _x: int, _y: int, _rotation: int) -> bool:
		return block.id != "conveyor"
	var placed_d: Dictionary = game.call("source_place_schematic_state", schem_d, 26, 20, sharded, false, reject_conveyor, null)
	proof["schematic_place_no_overwrite_hook_rejects"] = placed_d.get("placed") == 1 and placed_d.get("skipped") == 1 and placed_d.get("results")[0].get("skipped") == "valid_place_rejected" and placed_d.get("results")[1].get("placed") == true and game.call("source_world_tile", 25, 20).get("block") == conveyor and game.call("source_world_tile", 26, 20).get("block") == drill

	# --- No overwrite + no hook: fail-closed, nothing placed. ---
	var placed_d2: Dictionary = game.call("source_place_schematic_state", schem_d, 26, 20, sharded, false, null, null)
	proof["schematic_place_no_overwrite_no_hook_skips_all"] = placed_d2.get("placed") == 0 and placed_d2.get("skipped") == 2 and placed_d2.get("results")[0].get("skipped") == "valid_place_unchecked" and placed_d2.get("results")[1].get("skipped") == "valid_place_unchecked" and game.call("source_world_tile", 26, 20).get("block") == drill

	# --- Out-of-world stile is skipped, the rest still place. ---
	var schem_b: Dictionary = {"width": 2, "height": 1, "tiles": [
		{"block": conveyor, "x": 0, "y": 0, "config": null, "rotation": 0},
	]}
	var placed_b: Dictionary = game.call("source_place_schematic_state", schem_b, 60, 20, sharded, true, null, null)
	proof["schematic_place_out_of_world_tile_skipped"] = placed_b.get("placed") == 0 and placed_b.get("skipped") == 1 and placed_b.get("results")[0].get("skipped") == "tile_missing"
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("SchematicPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
