extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- DrillBuild.drawPlace() (N2351, LEG slice):
	# DrillBuild.drawPlace() (Drill.java:140-169,
	# `public void drawPlace(int x, int y, int rotation,
	# boolean valid){`) with `super.drawPlace(x, y,
	# rotation, valid);` (:141, Block base -- deferred,
	# recorded as super_draw_place_called) and `Tile tile
	# = world.tile(x, y);` (:143). The null-tile guard
	# `if(tile == null) return;` (:144) is NOT re-owned
	# (owned by N1769/N919/N1821/N2038/N2330, other
	# methods) -- it arrives as the explicit has_tile
	# param. `countOre(tile);` (:146) is NOT re-owned
	# (N2020/N2021/N2071/N2302/N2330) -- its result
	# (returnItem) arrives as explicit params. The
	# drillspeed text width (:149) is NOT re-owned (N699
	# source_drill_output_rate) -- it arrives as the
	# explicit width param. The owned geometry is `float
	# dx = x * tilesize + offset - width/2f - 4f, dy = y *
	# tilesize + offset + size * tilesize / 2f + 5, s =
	# iconSmall / 4f;` (:150) with the shadow rect
	# `Draw.rect(returnItem.fullIcon, dx, dy - 1, s, s);`
	# (:152) and the foreground rect `Draw.rect(
	# returnItem.fullIcon, dx, dy, s, s);` (:154). The
	# drawMineItem branch `if(drawMineItem){` (:156) /
	# `Draw.color(returnItem.color);` (:157) /
	# `Draw.rect(itemRegion, tile.worldx() + offset,
	# tile.worldy() + offset);` (:158) -- tile.worldx()
	# is x * tilesize (Tile.java:166-168). The else branch
	# `}else{` (:161) searches linked tiles (:162,
	# deferred to the caller as the explicit linked_item
	# param), then `Item item = to == null ? null :
	# to.drop();` (:163), `if(item != null){` (:164) and
	# `drawPlaceText(Core.bundle.get("bar.drilltierreq"),
	# x, y, valid);` (:165), whose 4-arg overload picks
	# `valid ? Pal.accent : Pal.remove` (Block.java:532).
	# tilesize is 8 (`public static final int tilesize =
	# 8;`, Vars.java:135) and iconSmall is 24 (`iconSmall
	# = 8*3f;`, Vars.java:139). Per-def sizes:
	# impact-drill `size = 4;` (Blocks.java:3073),
	# eruption-drill `size = 5;` (Blocks.java:3096).

	# Null tile draws nothing: no branch, no commands.
	var null_tile: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, false, true, "copper-icon", "copper-color", 40.0, true, "item-region", 0.0, 4, 8.0, 24.0, null)
	proof["draw_place_null_tile_no_commands"] = String(null_tile.get("branch", "")) == "none" and (null_tile.get("commands", []) as Array).is_empty() and bool(null_tile.get("super_draw_place_called", false)) == true

	# Return-item branch, impact-drill at (10, 20), size
	# 4, tilesize 8, offset 0, width 40, iconSmall 24:
	# dx = 10*8 + 0 - 40/2 - 4 = 56, dy = 20*8 + 0 +
	# 4*8/2 + 5 = 181, s = 24/4 = 6.
	var impact: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, true, true, "copper-icon", "copper-color", 40.0, true, "item-region", 0.0, 4, 8.0, 24.0, null)
	proof["draw_place_return_item_geometry"] = String(impact.get("branch", "")) == "return_item" and is_equal_approx(float(impact.get("dx", -1.0)), 56.0) and is_equal_approx(float(impact.get("dy", -1.0)), 181.0) and is_equal_approx(float(impact.get("icon_size", -1.0)), 6.0)

	# The 4 icon commands in Java order: mixcol
	# darkGray 1.0, shadow rect at dy - 1 (180), reset,
	# foreground rect at dy (181).
	var impact_commands: Array = impact.get("commands", [])
	proof["draw_place_return_item_commands"] = impact_commands.size() == 7 and String((impact_commands[0] as Dictionary).get("action", "")) == "mixcol" and String((impact_commands[0] as Dictionary).get("color", "")) == "darkGray" and is_equal_approx(float((impact_commands[0] as Dictionary).get("alpha", -1.0)), 1.0) and String((impact_commands[1] as Dictionary).get("action", "")) == "rect" and String((impact_commands[1] as Dictionary).get("region", "")) == "copper-icon" and is_equal_approx(float((impact_commands[1] as Dictionary).get("x", -1.0)), 56.0) and is_equal_approx(float((impact_commands[1] as Dictionary).get("y", -1.0)), 180.0) and String((impact_commands[2] as Dictionary).get("action", "")) == "reset" and String((impact_commands[3] as Dictionary).get("action", "")) == "rect" and is_equal_approx(float((impact_commands[3] as Dictionary).get("y", -1.0)), 181.0)

	# Mine-item sub-branch: color + rect at (x *
	# tilesize + offset, y * tilesize + offset) = (80,
	# 160), then reset; mine_item_drawn true.
	proof["draw_place_mine_item_drawn"] = bool(impact.get("mine_item_drawn", false)) == true and String((impact_commands[4] as Dictionary).get("action", "")) == "color" and String((impact_commands[4] as Dictionary).get("color", "")) == "copper-color" and String((impact_commands[5] as Dictionary).get("action", "")) == "rect" and String((impact_commands[5] as Dictionary).get("region", "")) == "item-region" and is_equal_approx(float((impact_commands[5] as Dictionary).get("x", -1.0)), 80.0) and is_equal_approx(float((impact_commands[5] as Dictionary).get("y", -1.0)), 160.0) and String((impact_commands[6] as Dictionary).get("action", "")) == "reset"

	# drawMineItem false: only the 4 icon commands,
	# mine_item_drawn false.
	var no_mine: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, true, true, "copper-icon", "copper-color", 40.0, false, "item-region", 0.0, 4, 8.0, 24.0, null)
	proof["draw_place_mine_item_hidden"] = bool(no_mine.get("mine_item_drawn", true)) == false and (no_mine.get("commands", []) as Array).size() == 4

	# Eruption-drill (size 5) at the same position: dy
	# = 160 + 5*8/2 + 5 = 185, dx unchanged (56).
	var eruption: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, true, true, "copper-icon", "copper-color", 40.0, true, "item-region", 0.0, 5, 8.0, 24.0, null)
	proof["draw_place_eruption_geometry"] = is_equal_approx(float(eruption.get("dx", -1.0)), 56.0) and is_equal_approx(float(eruption.get("dy", -1.0)), 185.0)

	# tilesize 1.0 reads the raw offsets: dx = 10*1 +
	# 0 - 40/2 - 4 = -14, dy = 20*1 + 0 + 4*1/2 + 5 = 27.
	var tilesize_one: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, true, true, "copper-icon", "copper-color", 40.0, true, "item-region", 0.0, 4, 1.0, 24.0, null)
	proof["draw_place_tilesize_one_geometry"] = is_equal_approx(float(tilesize_one.get("dx", -1.0)), -14.0) and is_equal_approx(float(tilesize_one.get("dy", -1.0)), 27.0)

	# Tier-req branch: no return item, a linked tile
	# drops an item -- one draw_place_text command with
	# the "bar.drilltierreq" key, Pal.accent when valid.
	var tier_req: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, true, false, null, null, 0.0, true, "item-region", 0.0, 4, 8.0, 24.0, "beryllium")
	var tier_commands: Array = tier_req.get("commands", [])
	proof["draw_place_tier_req_shown"] = String(tier_req.get("branch", "")) == "tier_req" and bool(tier_req.get("tier_req_shown", false)) == true and tier_commands.size() == 1 and String((tier_commands[0] as Dictionary).get("action", "")) == "draw_place_text" and String((tier_commands[0] as Dictionary).get("text_key", "")) == "bar.drilltierreq" and String((tier_commands[0] as Dictionary).get("color", "")) == "Pal.accent" and bool((tier_commands[0] as Dictionary).get("valid", false)) == true

	# Invalid placement: the same text in Pal.remove.
	var tier_invalid: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, false, true, false, null, null, 0.0, true, "item-region", 0.0, 4, 8.0, 24.0, "beryllium")
	var tier_invalid_commands: Array = tier_invalid.get("commands", [])
	proof["draw_place_tier_req_invalid_color"] = String(tier_invalid.get("branch", "")) == "tier_req" and tier_invalid_commands.size() == 1 and String((tier_invalid_commands[0] as Dictionary).get("color", "")) == "Pal.remove" and bool((tier_invalid_commands[0] as Dictionary).get("valid", true)) == false

	# No linked item drops anything: no branch, no
	# commands.
	var no_linked: Dictionary = burst_drill_build_state.source_drill_draw_place_state(10, 20, 0, true, true, false, null, null, 0.0, true, "item-region", 0.0, 4, 8.0, 24.0, null)
	proof["draw_place_no_linked_item_empty"] = String(no_linked.get("branch", "")) == "none" and (no_linked.get("commands", []) as Array).is_empty() and bool(no_linked.get("tier_req_shown", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillDrawPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
