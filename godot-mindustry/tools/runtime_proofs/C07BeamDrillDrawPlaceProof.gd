extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _place_case(world: Dictionary, valid: bool = true, blocked_items: Variant = null) -> Dictionary:
	var world_tile: Callable = func(rx: int, ry: int) -> Variant:
		return world.get("%d,%d" % [rx, ry], null)
	var drill_times: Dictionary = {"copper": 160.0, "lead": 160.0, "thorium": 160.0, "beryllium": 160.0}
	var get_drill_time: Callable = func(item_name: String) -> float:
		return float(drill_times.get(item_name, 200.0))
	var item_icon: Callable = func(item_name: String) -> Variant:
		return "icon-" + item_name
	return state.source_beam_drill_draw_place_state(10, 10, 0, valid, 2, 5, 3, blocked_items, world_tile, get_drill_time, item_icon, 0.0, 8.0, 24.0, 42.0)


func _tile(wall_drop: Variant, hardness: float, solid: bool = true) -> Dictionary:
	return {"solid": solid, "wall_drop": wall_drop, "wall_drop_hardness": hardness}


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

	# --- BeamDrillBuild.drawPlace() (N2385):
	# BeamDrillBuild.drawPlace() (BeamDrill.java:138-197) scans
	# one ray per footprint side (nearbySide + world.tile),
	# draws one dash line per side, and shows the drillspeed
	# text plus the found item's icon (or the tier-requirement
	# text when only an unmineable drop was found). The proof
	# drives the pure function with synthetic worlds (no live
	# tick): plasma-bore defaults (drillTime 160, tier 3,
	# size 2, range 5, Blocks.java:3038-3051), placement at
	# tile (10, 10) rotation 0, so the two sides are (12, 10)
	# and (12, 11); tilesize 8, offset 0, iconSmall 24, the
	# drillspeed text width pinned at 42. Copper hardness 1
	# and lead hardness 2 are mineable at tier 3; thorium
	# hardness 4 is not. NO driver tick line: drawPlace is
	# placement UI, not per-tick state.

	# Both sides face copper: one item, count 2, the icon
	# is shown; drill speed 60 / 160 * 2 = 0.75.
	var single_world: Dictionary = {"12,10": _tile("copper", 1.0), "12,11": _tile("copper", 1.0)}
	var single: Dictionary = _place_case(single_world)
	var single_dashes: Array = single.get("dash_lines", [])
	proof["single_item_found"] = single.get("item", "") == "copper" and int(single.get("count", -1)) == 2 and not bool(single.get("multiple", true)) and is_equal_approx(float(single.get("drill_speed", -1.0)), 0.75) and single.get("branch", "") == "item"

	# The icon rect follows the N2351 formula: dx = x *
	# tilesize + offset - width/2 - 4 = 80 - 21 - 4 = 55,
	# dy = y * tilesize + offset + size * tilesize/2 + 5 =
	# 80 + 8 + 5 = 93, s = iconSmall/4 = 6; the shadow rect
	# sits one pixel lower (dy - 1 = 92).
	var single_icon: Dictionary = single.get("icon_rect", {})
	var single_shadow: Dictionary = single.get("icon_shadow_rect", {})
	proof["icon_rect_geometry"] = single_icon.get("region", "") == "icon-copper" and is_equal_approx(float(single_icon.get("x", -1.0)), 55.0) and is_equal_approx(float(single_icon.get("y", -1.0)), 93.0) and is_equal_approx(float(single_icon.get("w", -1.0)), 6.0) and is_equal_approx(float(single_icon.get("h", -1.0)), 6.0) and is_equal_approx(float(single_shadow.get("y", -1.0)), 92.0)

	# Copper on one side, lead on the other: the last found
	# item wins, multiple is true, and the icon is hidden.
	var multi_world: Dictionary = {"12,10": _tile("copper", 1.0), "12,11": _tile("lead", 2.0)}
	var multi: Dictionary = _place_case(multi_world)
	proof["multiple_items_hide_icon"] = bool(multi.get("multiple", false)) and multi.get("item", "") == "lead" and int(multi.get("count", -1)) == 2 and multi.get("icon_rect", "x") == null and multi.get("icon_shadow_rect", "x") == null

	# Empty world: no item, no invalid drop, branch "none";
	# both dash lines are Pal.remove and run the full ray
	# (len = min(j, range - 1) = 4, end x = (12 + 4) * 8
	# = 128).
	var empty: Dictionary = _place_case({})
	var empty_dashes: Array = empty.get("dash_lines", [])
	var empty_dash0: Dictionary = empty_dashes[0]
	var empty_dash1: Dictionary = empty_dashes[1]
	proof["no_drop_dash_remove"] = empty.get("branch", "") == "none" and empty.get("item", "x") == null and empty.get("invalid_item", "x") == null and empty_dash0.get("color", "") == "Pal.remove" and is_equal_approx(float(empty_dash0.get("x2", -1.0)), 128.0) and is_equal_approx(float(empty_dash1.get("x2", -1.0)), 128.0) and is_equal_approx(float(empty_dash1.get("y2", -1.0)), 88.0)

	# Only thorium (hardness 4 > tier 3): the drop is
	# invalid, the branch is "tier_req", and the dash line
	# is Pal.remove (found is still null).
	var invalid_world: Dictionary = {"12,10": _tile("thorium", 4.0)}
	var invalid_only: Dictionary = _place_case(invalid_world)
	proof["invalid_only_tier_req"] = invalid_only.get("branch", "") == "tier_req" and invalid_only.get("invalid_item", "") == "thorium" and invalid_only.get("item", "x") == null

	# A blocked drop counts as invalid, not as found.
	var blocked: Dictionary = _place_case({"12,10": _tile("copper", 1.0)}, true, ["copper"])
	proof["blocked_item_is_invalid"] = blocked.get("branch", "") == "tier_req" and blocked.get("invalid_item", "") == "copper" and blocked.get("item", "x") == null

	# The copper wall sits two steps out: the ray steps
	# past the empty tiles, finds it at j = 2, and the dash
	# line ends at (12 + 2) * 8 = 112. Only one side found
	# anything, so count is 1.
	var deep_world: Dictionary = {"14,10": _tile("copper", 1.0)}
	var deep: Dictionary = _place_case(deep_world)
	var deep_dashes: Array = deep.get("dash_lines", [])
	var deep_dash0: Dictionary = deep_dashes[0]
	proof["scan_steps_to_deeper_drop"] = int(deep.get("count", -1)) == 1 and is_equal_approx(float(deep_dash0.get("x2", -1.0)), 112.0) and deep_dash0.get("color", "") == "Pal.placing"

	# A non-solid tile does NOT stop the ray: the copper
	# behind it at j = 1 is found, len = 1, dash end x =
	# (12 + 1) * 8 = 104.
	var floor_world: Dictionary = {"12,10": _tile(null, 0.0, false), "13,10": _tile("copper", 1.0)}
	var floor_case: Dictionary = _place_case(floor_world)
	var floor_dashes: Array = floor_case.get("dash_lines", [])
	var floor_dash0: Dictionary = floor_dashes[0]
	proof["non_solid_does_not_stop_ray"] = floor_case.get("item", "") == "copper" and is_equal_approx(float(floor_dash0.get("x2", -1.0)), 104.0)

	# The rate is 60 / drillTime * count: 0.75 for count 2,
	# 0.375 for count 1.
	proof["drill_speed_formula"] = is_equal_approx(float(single.get("drill_speed", -1.0)), 0.75) and is_equal_approx(float(deep.get("drill_speed", -1.0)), 0.375)

	# Dash endpoints are tile-to-world with tilesize 8: side
	# 0 runs (12, 10) -> (96, 80), side 1 runs (12, 11) ->
	# (96, 88); both found at j = 0, so len = 0 and the
	# lines are zero-length.
	var dash0: Dictionary = single_dashes[0]
	var dash1: Dictionary = single_dashes[1]
	proof["dash_line_endpoints"] = is_equal_approx(float(dash0.get("x1", -1.0)), 96.0) and is_equal_approx(float(dash0.get("y1", -1.0)), 80.0) and is_equal_approx(float(dash0.get("x2", -1.0)), 96.0) and is_equal_approx(float(dash0.get("y2", -1.0)), 80.0) and is_equal_approx(float(dash1.get("x1", -1.0)), 96.0) and is_equal_approx(float(dash1.get("y1", -1.0)), 88.0) and is_equal_approx(float(dash1.get("x2", -1.0)), 96.0) and is_equal_approx(float(dash1.get("y2", -1.0)), 88.0)

	# Commands arrive in Java order: one dash_line per
	# side, then the drillspeed text, then mixcol / rect /
	# reset / rect for the icon.
	var single_commands: Array = single.get("commands", [])
	var actions: Array = []
	for command in single_commands:
		actions.append((command as Dictionary).get("action", ""))
	proof["commands_order"] = actions == ["dash_line", "dash_line", "draw_place_text", "mixcol", "rect", "reset", "rect"]

	# The tier-req command carries the verbatim i18n key,
	# valid false, and the Pal.remove color.
	var invalid_commands: Array = invalid_only.get("commands", [])
	var tier_command: Dictionary = {}
	for command in invalid_commands:
		var command_dict: Dictionary = command
		if command_dict.get("action", "") == "draw_place_text":
			tier_command = command_dict
	proof["tier_req_command"] = tier_command.get("text_key", "") == "bar.drilltierreq" and tier_command.get("valid", true) == false and tier_command.get("color", "") == "Pal.remove"

	# The drillspeed text keeps its verbatim key, the
	# computed rate, and 2 decimals.
	var speed_text: Dictionary = single.get("drill_speed_text", {})
	proof["drill_speed_text_content"] = speed_text.get("key", "") == "bar.drillspeed" and is_equal_approx(float(speed_text.get("value", -1.0)), 0.75) and int(speed_text.get("decimals", -1)) == 2

	# With valid false the drillspeed text color is
	# Pal.remove (the 4-arg drawPlaceText overload).
	var invalid_placement: Dictionary = _place_case(single_world, false)
	var placement_commands: Array = invalid_placement.get("commands", [])
	var speed_command: Dictionary = {}
	for command in placement_commands:
		var command_dict: Dictionary = command
		if command_dict.get("action", "") == "draw_place_text":
			speed_command = command_dict
	proof["valid_false_text_color"] = speed_command.get("color", "") == "Pal.remove"

	# Each result carries ONLY its own keys.
	proof["returns_only_eleven_keys"] = single.size() == 11

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDrawPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
