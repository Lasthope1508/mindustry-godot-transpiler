extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret drawSelect/drawPlace range state (N2220):
	# RepairPointBuild.drawSelect() draws one dash circle around
	# the building (`Drawf.dashCircle(x, y, repairRadius,
	# Pal.accent);`, RepairTurret.java:178, inside `public void
	# drawSelect(){`, RepairTurret.java:177) and
	# RepairTurret.drawPlace() draws the same circle at the ghost
	# position (`Drawf.dashCircle(x * tilesize + offset, y *
	# tilesize + offset, repairRadius, Pal.accent);`,
	# RepairTurret.java:98, inside `public void drawPlace(int x,
	# int y, int rotation, boolean valid){`,
	# RepairTurret.java:95, after `super.drawPlace(x, y, rotation,
	# valid);`, RepairTurret.java:96). The radius is the per-def
	# repairRadius -- repair-point 60f (Blocks.java:6389),
	# repair-turret 145f (Blocks.java:6401), class default 50f
	# (`public float repairRadius = 50f;`,
	# RepairTurret.java:32). The place center converts tile coords
	# to world coords with the tilesize and the block offset (`x *
	# tilesize + offset`, RepairTurret.java:98; tilesize 8,
	# Vars.java:135; offset `((size + 1) % 2) * tilesize / 2f`,
	# Block.java:761 -- repair-point size 1 so 0.0, repair-turret
	# size 2 so 4.0). The color is Pal.accent in both call sites.
	# The proof calls the pure functions with synthetic values
	# (no live tick: the dash-circle state is pure geometry from
	# the position plus explicit per-def params).

	# Select center at the building position: building (100, 100)
	# -> center (100, 100), radius repair-point 60f.
	var select_point: Dictionary = repair_turret_build_state.source_repair_turret_draw_select_state(100.0, 100.0, 60.0)
	proof["select_center_at_building_position"] = (select_point.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 100))
	proof["select_radius_repair_point_60"] = is_equal_approx(float(select_point.get("radius", -1.0)), 60.0)

	# Select radius repair-turret 145f, same center rule.
	var select_turret: Dictionary = repair_turret_build_state.source_repair_turret_draw_select_state(100.0, 100.0, 145.0)
	proof["select_radius_repair_turret_145"] = is_equal_approx(float(select_turret.get("radius", -1.0)), 145.0)
	proof["select_color_is_accent"] = str(select_point.get("color", "")) == "Pal.accent" and str(select_turret.get("color", "")) == "Pal.accent"

	# Place center converts tile to world: tile (10, 12),
	# tilesize 8, repair-point offset 0.0 -> center (80, 96).
	var place_point: Dictionary = repair_turret_build_state.source_repair_turret_draw_place_state(10, 12, 60.0, 8.0, repair_turret_build_state._block_offset_for_block_id("repair-point"))
	proof["place_center_converts_tile_to_world"] = (place_point.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(80, 96))

	# Place center applies the block offset: tile (10, 12),
	# tilesize 8, repair-turret offset 4.0 -> center (84, 100),
	# radius repair-turret 145f.
	var place_turret: Dictionary = repair_turret_build_state.source_repair_turret_draw_place_state(10, 12, 145.0, 8.0, repair_turret_build_state._block_offset_for_block_id("repair-turret"))
	proof["place_center_applies_block_offset"] = (place_turret.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(84, 100))
	proof["place_radius_repair_turret_145"] = is_equal_approx(float(place_turret.get("radius", -1.0)), 145.0)
	proof["place_color_is_accent"] = str(place_point.get("color", "")) == "Pal.accent" and str(place_turret.get("color", "")) == "Pal.accent"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretDrawSelectPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
