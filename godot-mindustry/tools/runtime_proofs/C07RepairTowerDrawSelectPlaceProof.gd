extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- RepairTower drawSelect/drawPlace range state (N2231):
	# RepairTowerBuild.drawSelect() draws one dash circle around
	# the building (`Drawf.dashCircle(x, y, range,
	# Pal.placing);`, RepairTower.java:123, inside `public void
	# drawSelect(){`, RepairTower.java:122) and
	# RepairTower.drawPlace() draws the same circle at the ghost
	# position (`Drawf.dashCircle(x * tilesize + offset, y *
	# tilesize + offset, range, Pal.placing);`,
	# RepairTower.java:47, inside `public void drawPlace(int x,
	# int y, int rotation, boolean valid){`,
	# RepairTower.java:44, after `super.drawPlace(x, y, rotation,
	# valid);`, RepairTower.java:45). The radius is the per-def
	# range -- unit-repair-tower 100f (Blocks.java:6579), class
	# default 80f (`public float range = 80f;`,
	# RepairTower.java:21). The place center converts tile coords
	# to world coords with the tilesize and the block offset (`x *
	# tilesize + offset`, RepairTower.java:47; tilesize 8,
	# Vars.java:135; offset `((size + 1) % 2) * tilesize / 2f`,
	# Block.java:761 -- unit-repair-tower size 2, Blocks.java:6578,
	# so 4.0). The color is Pal.placing in both call sites. The
	# proof calls the pure functions with synthetic values (no
	# live tick: the dash-circle state is pure geometry from the
	# position plus explicit per-def params).

	# Select center at the building position: building (100, 100)
	# -> center (100, 100), radius catalog 100f.
	var select_catalog: Dictionary = repair_tower_build_state.source_repair_tower_draw_select_state(100.0, 100.0, 100.0)
	proof["select_center_at_building_position"] = (select_catalog.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 100))
	proof["select_radius_catalog_100"] = is_equal_approx(float(select_catalog.get("radius", -1.0)), 100.0)

	# Select radius class default 80f, same center rule.
	var select_default: Dictionary = repair_tower_build_state.source_repair_tower_draw_select_state(100.0, 100.0, 80.0)
	proof["select_radius_class_default_80"] = is_equal_approx(float(select_default.get("radius", -1.0)), 80.0)
	proof["select_color_is_placing"] = str(select_catalog.get("color", "")) == "Pal.placing" and str(select_default.get("color", "")) == "Pal.placing"

	# Place center converts tile to world: tile (10, 5),
	# tilesize 8, block offset 4.0 -> center (84, 44).
	var place_catalog: Dictionary = repair_tower_build_state.source_repair_tower_draw_place_state(10, 5, 100.0, 8.0, 4.0)
	proof["place_center_converts_tile_to_world"] = (place_catalog.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(84, 44))

	# Place center applies the block offset: tile (10, 12),
	# tilesize 8, offset 0.0 -> center (80, 96); offset 4.0 ->
	# center (84, 100), radius catalog 100f.
	var place_no_offset: Dictionary = repair_tower_build_state.source_repair_tower_draw_place_state(10, 12, 100.0, 8.0, 0.0)
	var place_offset: Dictionary = repair_tower_build_state.source_repair_tower_draw_place_state(10, 12, 100.0, 8.0, 4.0)
	proof["place_center_applies_block_offset"] = (place_no_offset.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(80, 96)) and (place_offset.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(84, 100))
	proof["place_radius_catalog_100"] = is_equal_approx(float(place_catalog.get("radius", -1.0)), 100.0) and is_equal_approx(float(place_offset.get("radius", -1.0)), 100.0)
	proof["place_color_is_placing"] = str(place_catalog.get("color", "")) == "Pal.placing" and str(place_offset.get("color", "")) == "Pal.placing"

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTowerBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_tower_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_tower_draw_select_state") and not driver_body.contains("source_repair_tower_draw_place_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerDrawSelectPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
