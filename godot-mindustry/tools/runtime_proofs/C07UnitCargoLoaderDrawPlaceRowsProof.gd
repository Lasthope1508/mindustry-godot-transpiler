extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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

	# --- Draw-place rows (N2445): UnitCargoLoader.drawPlace()
	# (UnitCargoLoader.java:70-75). draw() is live since
	# N2415, the bar rows since N2417 and canPlaceOn since
	# N2330; all are untouched here. drawPlace() is
	# super.drawPlace(x, y, rotation, valid) (:71) + the
	# cap warning (`if(!Units.canCreate(Vars.player.team(),
	# unitType)){`, :73, then `drawPlaceText(
	# Core.bundle.get("bar.cargounitcap"), x, y, valid);`,
	# :74). The super call is recorded in the docstring,
	# NOT a result symbol (the N2439 precedent). The
	# warning fires only when the player's team cannot
	# create the unit type (`public static boolean
	# canCreate(Team team, UnitType type){` with `return
	# !type.useUnitCap || (team.data().countType(type) <
	# getCap(team) && !type.isBanned());`,
	# Units.java:115-117); Units.canCreate is a
	# team/indexer query the pure never runs -- it arrives
	# caller-supplied as can_create (the N2435 precedent).
	# drawPlaceText is the Block 4-arg overload (`public
	# float drawPlaceText(String text, int x, int y,
	# boolean valid){`, Block.java:531, delegating with
	# `return drawPlaceText(text, x, y, valid ? Pal.accent
	# : Pal.remove, true);`, Block.java:532). x/y are TILE
	# coords: the 5-arg overload converts them inside
	# (`float dx = x * tilesize + offset, dy = y * tilesize
	# + offset + size * tilesize / 2f + 3;`, Block.java:546),
	# so the record carries the tile coords as passed. The
	# bundle key is exact (`bar.cargounitcap = Cargo Unit
	# Cap Reached`, bundle.properties:1278). The pure
	# returns the draw call as data; it never draws for
	# real (the N2396 pattern).
	var tile_x := 10
	var tile_y := 20

	# --- Null warning: the team CAN create the unit, so
	# no warning call is recorded -- warning_call is null.
	var free: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_place_state(tile_x, tile_y, true, true)
	proof["draw_place_warning_null"] = free.get("warning_call", {}) == null

	# --- Warning present: the team CANNOT create the unit
	# (cap reached), so the warning call is recorded as a
	# drawPlaceText CALL record (the N2396 precedent).
	var capped: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_place_state(tile_x, tile_y, true, false)
	var warning: Dictionary = capped.get("warning_call", {})
	proof["draw_place_warning_present"] = warning.get("method", "") == "drawPlaceText"

	# --- Warning text: the exact bundle key
	# bar.cargounitcap (bundle.properties:1278) -- NOT the
	# resolved English text, the pure records the key.
	proof["draw_place_warning_text"] = warning.get("text", "") == "bar.cargounitcap"

	# --- Warning x/y: the TILE coords pass through
	# unchanged -- (10, 20) here, and a second call at
	# (3, 7) proves the values flow through rather than
	# being constants.
	var capped_other: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_place_state(3, 7, true, false)
	var warning_other: Dictionary = capped_other.get("warning_call", {})
	proof["draw_place_warning_xy"] = int(warning.get("x", -1)) == tile_x and int(warning.get("y", -1)) == tile_y and int(warning_other.get("x", -1)) == 3 and int(warning_other.get("y", -1)) == 7

	# --- Warning valid true: a valid placement records
	# valid true on the warning call (Java draws the
	# warning regardless of validity; the 4-arg overload
	# picks Pal.accent from it, Block.java:532).
	proof["draw_place_warning_valid_true"] = bool(warning.get("valid", false)) == true

	# --- Warning valid false: an invalid placement still
	# warns (the warning is about the cap, not the
	# placement) and records valid false (Pal.remove in
	# the 4-arg overload, Block.java:532).
	var capped_invalid: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_place_state(tile_x, tile_y, false, false)
	var warning_invalid: Dictionary = capped_invalid.get("warning_call", {})
	proof["draw_place_warning_valid_false"] = bool(warning_invalid.get("valid", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderDrawPlaceRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
