extends Node

const catalog_script := preload("res://src/mindustry/content/ContentCatalog.gd")
const block_script := preload("res://src/mindustry/content/Block.gd")
const content := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var catalog := catalog_script.new()
	var items := content.source_item_catalog_state(catalog)
	var blocks: Dictionary = {}
	for block in catalog.get_many("block"):
		blocks[block.field] = block
	var air: Object = blocks["air"]
	var facts: Dictionary = items["item_facts_by_field"]
	var tile := {"floor": blocks["sand"], "overlay": air, "block": air}
	if "--missing-metadata" in OS.get_cmdline_user_args():
		tile["floor"] = block_script.new({"id": "unresolved"})
		terrain.source_tile_ore_state(tile, items, air)
		return
	var before: Dictionary = blocks["sand"].properties.duplicate(true)
	var proof: Dictionary = {}
	var result := terrain.source_tile_ore_state(tile, items, air)
	proof["actual_floor_drop"] = is_same(result["drop"], facts["sand"]) and not result["is_static"]
	tile["overlay"] = blocks["spawn"]
	proof["non_air_null_overlay_falls_back"] = is_same(terrain.source_tile_ore_state(tile, items, air)["drop"], facts["sand"])
	tile["overlay"] = blocks["oreCopper"]
	proof["item_only_constructor_overlay"] = is_same(terrain.source_tile_ore_state(tile, items, air)["drop"], facts["copper"])
	tile["overlay"] = blocks["oreCrystalThorium"]
	proof["drop_ignores_overlay_slug"] = is_same(terrain.source_tile_ore_state(tile, items, air)["drop"], facts["thorium"])
	tile["floor"] = blocks["stone"]
	tile["overlay"] = air
	proof["explicit_null_drop"] = terrain.source_tile_ore_state(tile, items, air)["drop"] == null
	tile["overlay"] = blocks["oreLead"]
	tile["block"] = blocks["stoneWall"]
	var wall := terrain.source_tile_ore_state(tile, items, air)
	proof["actual_static_wall_blocks_mining"] = wall["is_static"] and is_same(wall["drop"], facts["lead"]) and not drill.source_can_mine_state(wall, 9, null)["can_mine"]
	tile["block"] = blocks["cliff"]
	proof["cliff_constructor_static"] = terrain.source_tile_ore_state(tile, items, air)["is_static"]
	tile["block"] = blocks["mechanicalDrill"]
	proof["placed_building_is_not_static_wall"] = not terrain.source_tile_ore_state(tile, items, air)["is_static"]
	var fake_air := block_script.new({"id": "air", "properties": {"itemDrop": "lead", "cacheLayer": "normal"}})
	tile["overlay"] = fake_air
	proof["air_is_reference_identity"] = is_same(terrain.source_tile_ore_state(tile, items, air)["drop"], facts["lead"])
	var cells: Dictionary = {}
	cells[Vector2i(0, 0)] = {"floor": blocks["sand"], "overlay": air, "block": air}
	cells[Vector2i(0, 1)] = {"floor": blocks["stone"], "overlay": blocks["oreLead"], "block": air}
	cells[Vector2i(1, 0)] = {"floor": blocks["stone"], "overlay": blocks["oreCopper"], "block": air}
	cells[Vector2i(1, 1)] = {"floor": blocks["stone"], "overlay": blocks["oreLead"], "block": blocks["stoneWall"]}
	var lookups: Array = []
	var lookup := func(x: int, y: int) -> Variant:
		lookups.append(Vector2i(x, y))
		return cells.get(Vector2i(x, y))
	var linked := terrain.source_linked_ore_tiles_state(true, 2, 0, 0, 0, lookup, cells[Vector2i.ZERO], items, air)
	proof["source_footprint_order"] = lookups == [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)] and linked["ore_tiles"].size() == 4
	var selected := drill.source_count_ore_state(linked["ore_tiles"], 2, null)
	proof["actual_facts_priority_count_id_selection"] = is_same(selected["returnItem"], facts["lead"]) and selected["returnCount"] == 1 and selected["oreCount"].size() == 3
	lookups.clear()
	var clipped := terrain.source_linked_ore_tiles_state(true, 3, -1, 0, 0, lookup, cells[Vector2i.ZERO], items, air)
	proof["odd_size_offset_and_world_edges"] = lookups.size() == 9 and lookups[0] == Vector2i(-1, -1) and lookups[8] == Vector2i(1, 1) and clipped["ore_tiles"].size() == 4
	lookups.clear()
	var single := terrain.source_linked_ore_tiles_state(false, 1, 0, 50, 50, lookup, cells[Vector2i.ZERO], items, air)
	proof["single_tile_uses_self_without_lookup"] = lookups.is_empty() and single["ore_tiles"].size() == 1 and is_same(single["ore_tiles"][0]["drop"], facts["sand"])
	var empty := terrain.source_linked_ore_tiles_state(true, 2, 0, 90, 90, lookup, cells[Vector2i.ZERO], items, air)
	proof["empty_world_does_not_invent_tiles"] = empty["ore_tiles"].is_empty() and drill.source_count_ore_state(empty["ore_tiles"], 2, null)["returnItem"] == null
	proof["source_objects_unchanged"] = blocks["sand"].properties == before and cells[Vector2i(1, 1)]["block"] == blocks["stoneWall"]
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TileOreProviderProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
