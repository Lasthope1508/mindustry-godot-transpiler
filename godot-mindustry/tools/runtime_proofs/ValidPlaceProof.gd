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
	var stone = catalog.get_by_id("stone")
	var deep_water = catalog.get_by_id("deep-water")
	var copper_ore = catalog.get_by_id("ore-copper")
	var sharded: int = geometry.SOURCE_TEAM_SHARDED_ID
	var crux := 2
	# Block fields the content catalog does not export, keyed by block id.
	# Values are the Block.java field defaults plus the creator/constructor
	# overrides verified against pinned upstream: Conveyor rotate=true and
	# group transportation (anyReplace true); Drill solid=true and group
	# drills; CoreBlock solid=true; AirBlock alwaysReplace=true; OreBlock
	# is a Floor and an OverlayFloor.
	var block_flags: Dictionary = {
		"conveyor": {"rotate": true, "group": "transportation", "group_any_replace": true, "subclass": "Conveyor"},
		"mechanical-drill": {"solid": true, "group": "drills", "group_any_replace": false, "subclass": "Drill"},
		"core-shard": {"solid": true, "group": "none", "group_any_replace": false, "subclass": "CoreBlock"},
		"air": {"always_replace": true, "group": "none", "group_any_replace": false, "subclass": "AirBlock"},
		"stone": {"is_floor": true, "is_overlay": false},
		"deep-water": {"is_floor": true, "is_overlay": false},
		"ore-copper": {"is_floor": true, "is_overlay": true},
	}
	var floor_flags: Dictionary = {
		"stone": {"is_deep": false, "is_liquid": false, "liquid_drop": null, "placeable_on": true},
		"deep-water": {"is_deep": true, "is_liquid": true, "liquid_drop": "water", "placeable_on": true},
		"air": {"is_deep": false, "is_liquid": false, "liquid_drop": null, "placeable_on": true},
	}
	var rules_state: Dictionary = {"editor": false, "waves": false, "wave_team_id": crux, "derelict_repair": true, "polygon_core_protection": false, "static_fog": true, "fog": false, "place_range_check": false}
	var cores_state: Dictionary = {"cores": [{"cell": Vector2i(17, 8), "team_id": sharded, "protect_cores": true}], "build_radius": 400.0, "tilesize": 8.0}
	# Drill.canPlaceOn: any linked tile whose overlay drops copper. Other
	# blocks use the Block default (true).
	var can_place_on_hook := func(block: Variant, tile: Dictionary, _team: int, _rotation: int) -> bool:
		if block.id != "mechanical-drill":
			return true
		for cell in game.call("occupied_cells", Vector2i(tile["x"], tile["y"]), block):
			if game.call("source_world_tile", cell.x, cell.y).get("overlay").id == "ore-copper":
				return true
		return false

	# --- Empty stone allows a conveyor; out of world is rejected. ---
	var empty: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 40, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_empty_stone_allows_conveyor"] = empty.get("valid") == true and empty.get("reason") == ""
	var outside: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 60, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_out_of_world_rejects"] = outside.get("valid") == false and outside.get("reason") == "tile_missing"

	# --- Drill needs ore under it (canPlaceOn hook). ---
	for ore_cell in [Vector2i(33, 20), Vector2i(33, 21)]:
		terrain.source_set_world_overlay_state(game, ore_cell.x, ore_cell.y, copper_ore, false)
	var drill_ore: Dictionary = game.call("source_valid_place_state", drill, block_flags, floor_flags, sharded, 33, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_drill_on_ore_allows"] = drill_ore.get("valid") == true and drill_ore.get("reason") == ""
	var drill_no_ore: Dictionary = game.call("source_valid_place_state", drill, block_flags, floor_flags, sharded, 40, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_drill_without_ore_rejects"] = drill_no_ore.get("valid") == false and drill_no_ore.get("reason") == "can_place_on"

	# --- Same block, same rotation is rejected; another rotation is not. ---
	var placed_conveyor := Sprite2D.new()
	game.add_child(placed_conveyor)
	game.call("record_placed_block", placed_conveyor, conveyor, Vector2i(40, 20))
	var same_rotation: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 40, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_same_block_same_rotation_rejects"] = same_rotation.get("valid") == false and same_rotation.get("reason") == "same_block_rotation"
	var other_rotation: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 40, 20, 1, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_same_block_other_rotation_allows"] = other_rotation.get("valid") == true and other_rotation.get("reason") == ""
	# A drill cannot replace the conveyor (groups differ, no anyReplace),
	# so the footprint cell fails with cannot_replace. Ore first, so the
	# canPlaceOn hook does not fire before the footprint loop.
	terrain.source_set_world_overlay_state(game, 40, 20, copper_ore, false)
	var drill_on_conveyor: Dictionary = game.call("source_valid_place_state", drill, block_flags, floor_flags, sharded, 40, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_drill_on_conveyor_rejects"] = drill_on_conveyor.get("valid") == false and drill_on_conveyor.get("reason") == "cannot_replace" and drill_on_conveyor.get("cell") == Vector2i(40, 20)

	# --- A solid block with a unit overlap is rejected; without units it
	# passes. (Checked before the drill is placed below, or the footprint
	# cell would fail with cannot_replace first.) ---
	var unit_overlap_hook := func(_block: Variant, _x: int, _y: int) -> bool:
		return true
	var unit_overlap: Dictionary = game.call("source_valid_place_state", drill, block_flags, floor_flags, sharded, 33, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, unit_overlap_hook)
	proof["valid_place_solid_unit_overlap_rejects"] = unit_overlap.get("valid") == false and unit_overlap.get("reason") == "unit_overlap"

	# --- A conveyor cannot replace a drill (size 1 under size 2 bounds). ---
	var placed_drill := Sprite2D.new()
	game.add_child(placed_drill)
	game.call("record_placed_block", placed_drill, drill, Vector2i(33, 20))
	var conveyor_on_drill: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 33, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_conveyor_on_drill_rejects"] = conveyor_on_drill.get("valid") == false and conveyor_on_drill.get("reason") == "cannot_replace"

	# --- Deep water: one deep cell fails the footprint check; all deep
	# cells around it fail the shallows check first. ---
	terrain.source_set_world_floor_state(game, 42, 20, deep_water)
	var deep_cell: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 42, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_deep_water_rejects"] = deep_cell.get("valid") == false and deep_cell.get("reason") == "deep_floor"
	for deep in [Vector2i(44, 20), Vector2i(43, 20), Vector2i(45, 20), Vector2i(44, 19), Vector2i(44, 21)]:
		terrain.source_set_world_floor_state(game, deep.x, deep.y, deep_water)
	var no_shallows: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 44, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_no_shallows_rejects"] = no_shallows.get("valid") == false and no_shallows.get("reason") == "no_shallows"

	# --- Core protection: an enemy team is blocked near the core, the
	# owning team is not; polygon mode takes the closest protected core. ---
	var enemy_core: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, crux, 30, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_enemy_core_radius_blocks"] = enemy_core.get("valid") == false and enemy_core.get("reason") == "core_protection"
	var own_core: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 30, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_own_core_radius_allows"] = own_core.get("valid") == true and own_core.get("reason") == ""
	var polygon_rules: Dictionary = rules_state.duplicate()
	polygon_rules["polygon_core_protection"] = true
	var polygon_enemy: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, crux, 30, 20, 0, true, true, polygon_rules, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_polygon_core_blocks_enemy"] = polygon_enemy.get("valid") == false and polygon_enemy.get("reason") == "core_protection"
	var small_radius: Dictionary = {"cores": [{"cell": Vector2i(17, 8), "team_id": sharded, "protect_cores": true}], "build_radius": 40.0, "tilesize": 8.0}
	var small_enemy: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, crux, 30, 20, 0, true, true, rules_state, small_radius, can_place_on_hook, null, null, null, null)
	proof["valid_place_small_core_radius_allows_enemy"] = small_enemy.get("valid") == true and small_enemy.get("reason") == ""

	# --- A derelict building is rejected when derelictRepair is off. ---
	var placed_derelict := Sprite2D.new()
	game.add_child(placed_derelict)
	game.call("record_placed_block", placed_derelict, conveyor, Vector2i(46, 20), 0)
	var no_repair_rules: Dictionary = rules_state.duplicate()
	no_repair_rules["derelict_repair"] = false
	var derelict: Dictionary = game.call("source_valid_place_state", conveyor, block_flags, floor_flags, sharded, 46, 20, 0, true, true, no_repair_rules, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_derelict_rejects"] = derelict.get("valid") == false and derelict.get("reason") == "derelict"

	# --- Floor blocks: placing the same floor is rejected, another floor
	# is allowed. ---
	var same_floor: Dictionary = game.call("source_valid_place_state", stone, block_flags, floor_flags, sharded, 40, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_floor_already_rejects"] = same_floor.get("valid") == false and same_floor.get("reason") == "floor_already"
	var other_floor: Dictionary = game.call("source_valid_place_state", deep_water, block_flags, floor_flags, sharded, 40, 20, 0, true, true, rules_state, cores_state, can_place_on_hook, null, null, null, null)
	proof["valid_place_other_floor_allows"] = other_floor.get("valid") == true and other_floor.get("reason") == ""
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ValidPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
