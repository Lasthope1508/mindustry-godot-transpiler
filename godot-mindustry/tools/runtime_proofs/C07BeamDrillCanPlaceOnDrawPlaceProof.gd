extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- canPlaceOn + drawPlace rows (N2478):
	# canPlaceOn (BeamDrill.java:198-214) walks size
	# lasers x range tiles from the nearbySide origins
	# and returns true on the first mineable drop (the
	# :205 gate); the break sits OUTSIDE the drop check,
	# so the first solid tile ends the laser's walk
	# either way. drawPlace (BeamDrill.java:137-195)
	# walks the same rays, records one dash line per
	# laser (`int len = Math.min(j, range - 1);`, :172;
	# Pal.placing when the laser found a mineable drop,
	# Pal.remove otherwise), the speed text
	# (`float width = drawPlaceText(Core.bundle.
	# formatFloat("bar.drillspeed", 60f /
	# getDrillTime(item) * count, 2), x, y, valid);`,
	# :183) when an item was found, the single-item icon
	# (`s = iconSmall / 4f`, :185) when !multiple, and
	# the tier-req text (`drawPlaceText(Core.bundle.
	# get("bar.drilltierreq"), x, y, false);`, :192)
	# when no item was found but an invalid drop was.
	# Geometry: the plasma-bore def (size 2, range 5,
	# tier 3, drillTime 160f, Blocks.java:3042-3045)
	# placed at tile (0, 0), rotation 0: the nearbySide
	# origins (Block.java:936-944, corner (0, 0)) are
	# (2, 0) and (2, 1), the rays walk +x (Geometry.d4,
	# arc Geometry.java:23-24), tilesize is 8
	# (Vars.java:135), the Block offset is 4.0 for size
	# 2 (`offset = ((size + 1) % 2) * tilesize / 2f;`,
	# Block.java:761). Item hardness: copper 1, lead 1,
	# thorium 4, tungsten 5 (Items.java:17/23/56/113).
	# VERIFY-FIRST: invalidItem is the LAST unmineable
	# drop (`invalidItem = drop;`, :158, overwrites
	# every time) -- NOT the first, as the brief said;
	# `len = min(j, range-1)` has NO off-by-one (j is
	# the solid tile's own index at the break); the
	# tier-req text passes valid=false HARDCODED.
	# Pure-only: no tick wiring -- the placement UI
	# calls these, and the call site waits for its own
	# slice.

	# --- First mineable: laser 0 finds copper at j=0
	# (the origin tile itself is solid), laser 1 finds
	# nothing. can_place_on is true; dash 0 is
	# Pal.placing with len 0 (from (16, 0) to (16, 0)),
	# dash 1 is Pal.remove with len 4 (j == range -> len
	# range-1, from (16, 8) to (48, 8)); the speed text
	# reads 60/160*1 = 0.375 under bar.drillspeed; the
	# icon draws (single item) at dx = 0*8 + 4 - 40/2 -
	# 4 = -20, dy = 0*8 + 4 + 2*8/2 + 5 = 17, size 6.0
	# (iconSmall/4f); no tier-req text.
	var first_world: Dictionary = {"2,0": {"solid": true, "wall_drop": {"id": "copper", "hardness": 1}}}
	var first_place: Dictionary = beam_drill_build_state.source_beam_drill_can_place_on_state(0, 0, 0, 2, 5, 3, null, first_world)
	var first_draw: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, first_world, 160.0, {}, 40.0)
	var first_dashes: Array = first_draw.get("dash_lines", [])
	var first_speed: Variant = first_draw.get("speed_text", null)
	var first_icon: Variant = first_draw.get("icon", null)
	proof["place_first_mineable"] = first_place.get("can_place_on", false) == true and first_dashes.size() == 2 and str(first_dashes[0].get("color", "")) == "Pal.placing" and int(first_dashes[0].get("len", -1)) == 0 and is_equal_approx(float((first_dashes[0].get("from", {}) as Dictionary).get("x", -1.0)), 16.0) and is_equal_approx(float((first_dashes[0].get("to", {}) as Dictionary).get("x", -1.0)), 16.0) and str(first_dashes[1].get("color", "")) == "Pal.remove" and int(first_dashes[1].get("len", -1)) == 4 and is_equal_approx(float((first_dashes[1].get("to", {}) as Dictionary).get("x", -1.0)), 48.0) and first_speed is Dictionary and str((first_speed as Dictionary).get("text", "")) == "bar.drillspeed" and is_equal_approx(float((first_speed as Dictionary).get("value", -1.0)), 0.375) and int((first_speed as Dictionary).get("decimals", -1)) == 2 and int((first_speed as Dictionary).get("count", -1)) == 1 and first_icon is Dictionary and str((first_icon as Dictionary).get("item", "")) == "copper" and is_equal_approx(float((first_icon as Dictionary).get("size", -1.0)), 6.0) and is_equal_approx(float((first_icon as Dictionary).get("x", -1.0)), -20.0) and is_equal_approx(float((first_icon as Dictionary).get("y", -1.0)), 17.0) and first_draw.get("tier_req_text", null) == null

	# --- Break on solid: laser 0 hits thorium (hardness
	# 4 > tier 3) at j=0 with mineable copper BEHIND it
	# at j=1; laser 1 finds nothing. The break ends
	# laser 0's walk, so can_place_on is false and the
	# copper never counts (no speed text); the tier-req
	# text fires with valid=false and invalid_item
	# thorium. A blocked copper drop counts the same
	# way: copper behind a blocked list reads as
	# unmineable (can_place_on false, tier-req
	# invalid_item copper).
	var break_world: Dictionary = {"2,0": {"solid": true, "wall_drop": {"id": "thorium", "hardness": 4}}, "3,0": {"solid": true, "wall_drop": {"id": "copper", "hardness": 1}}}
	var break_place: Dictionary = beam_drill_build_state.source_beam_drill_can_place_on_state(0, 0, 0, 2, 5, 3, null, break_world)
	var break_draw: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, break_world, 160.0, {}, 40.0)
	var break_tier: Variant = break_draw.get("tier_req_text", null)
	var blocked_place: Dictionary = beam_drill_build_state.source_beam_drill_can_place_on_state(0, 0, 0, 2, 5, 3, ["copper"], first_world)
	var blocked_draw: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, ["copper"], first_world, 160.0, {}, 40.0)
	var blocked_tier: Variant = blocked_draw.get("tier_req_text", null)
	proof["place_break_on_solid"] = break_place.get("can_place_on", true) == false and break_draw.get("speed_text", null) == null and break_draw.get("icon", null) == null and break_tier is Dictionary and str((break_tier as Dictionary).get("text", "")) == "bar.drilltierreq" and (break_tier as Dictionary).get("valid", true) == false and str((break_tier as Dictionary).get("invalid_item", "")) == "thorium" and blocked_place.get("can_place_on", true) == false and blocked_tier is Dictionary and str((blocked_tier as Dictionary).get("invalid_item", "")) == "copper"

	# --- Dash colors: laser 0 finds copper at j=2 (two
	# null tiles first -- the walk continues past them),
	# laser 1 hits thorium at j=1. Dash 0 is Pal.placing
	# with len 2 (from (16, 0) to (32, 0)); dash 1 is
	# Pal.remove with len 1 (from (16, 8) to (24, 8)).
	# can_place_on is true (laser 0 mines); the speed
	# text fires (item found) and the tier-req text
	# does NOT (the if/else-if: an invalid drop only
	# shows when NO item was found).
	var colors_world: Dictionary = {"4,0": {"solid": true, "wall_drop": {"id": "copper", "hardness": 1}}, "3,1": {"solid": true, "wall_drop": {"id": "thorium", "hardness": 4}}}
	var colors_place: Dictionary = beam_drill_build_state.source_beam_drill_can_place_on_state(0, 0, 0, 2, 5, 3, null, colors_world)
	var colors_draw: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, colors_world, 160.0, {}, 40.0)
	var colors_dashes: Array = colors_draw.get("dash_lines", [])
	proof["place_dash_colors"] = colors_place.get("can_place_on", false) == true and colors_dashes.size() == 2 and str(colors_dashes[0].get("color", "")) == "Pal.placing" and int(colors_dashes[0].get("len", -1)) == 2 and is_equal_approx(float((colors_dashes[0].get("to", {}) as Dictionary).get("x", -1.0)), 32.0) and str(colors_dashes[0].get("found", "")) == "copper" and str(colors_dashes[1].get("color", "")) == "Pal.remove" and int(colors_dashes[1].get("len", -1)) == 1 and is_equal_approx(float((colors_dashes[1].get("to", {}) as Dictionary).get("x", -1.0)), 24.0) and colors_dashes[1].get("found", null) == null and colors_draw.get("speed_text", null) != null and colors_draw.get("tier_req_text", null) == null

	# --- Speed text: both lasers find copper at j=0
	# (count 2). With the copper multiplier 2.0 the
	# drill time is 160/2 = 80, so the speed is
	# 60/80*2 = 1.5; with an empty map (the BeamDrill
	# def case -- neither def sets a multiplier) it is
	# 60/160*2 = 0.75. The icon draws in both cases
	# (one item, !multiple).
	var speed_world: Dictionary = {"2,0": {"solid": true, "wall_drop": {"id": "copper", "hardness": 1}}, "2,1": {"solid": true, "wall_drop": {"id": "copper", "hardness": 1}}}
	var speed_boosted: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, speed_world, 160.0, {"copper": 2.0}, 40.0)
	var speed_def: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, speed_world, 160.0, {}, 40.0)
	var speed_boosted_text: Variant = speed_boosted.get("speed_text", null)
	var speed_def_text: Variant = speed_def.get("speed_text", null)
	proof["place_speed_text"] = speed_boosted_text is Dictionary and str((speed_boosted_text as Dictionary).get("text", "")) == "bar.drillspeed" and is_equal_approx(float((speed_boosted_text as Dictionary).get("value", -1.0)), 1.5) and str((speed_boosted_text as Dictionary).get("item", "")) == "copper" and int((speed_boosted_text as Dictionary).get("count", -1)) == 2 and speed_def_text is Dictionary and is_equal_approx(float((speed_def_text as Dictionary).get("value", -1.0)), 0.75) and speed_boosted.get("icon", null) != null and speed_def.get("icon", null) != null

	# --- Multiple items: laser 0 finds copper, laser 1
	# finds lead -- two different items, so multiple is
	# true and the icon is suppressed, but the speed
	# text still draws (drawPlace does NOT null the item
	# when multiple, unlike updateFacing). item is the
	# LAST found (lead): with the lead multiplier 2.0
	# the drill time is 160/2 = 80, so the speed is
	# 60/80*2 = 1.5 -- a copper item would read 0.75.
	var multiple_world: Dictionary = {"2,0": {"solid": true, "wall_drop": {"id": "copper", "hardness": 1}}, "2,1": {"solid": true, "wall_drop": {"id": "lead", "hardness": 1}}}
	var multiple_draw: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, multiple_world, 160.0, {"lead": 2.0}, 40.0)
	var multiple_speed: Variant = multiple_draw.get("speed_text", null)
	proof["place_multiple_items"] = multiple_draw.get("icon", null) == null and multiple_speed is Dictionary and str((multiple_speed as Dictionary).get("item", "")) == "lead" and is_equal_approx(float((multiple_speed as Dictionary).get("value", -1.0)), 1.5) and int((multiple_speed as Dictionary).get("count", -1)) == 2 and multiple_draw.get("tier_req_text", null) == null

	# --- Tier req: no mineable drop anywhere -- laser 0
	# hits thorium, laser 1 hits tungsten. can_place_on
	# is false, no speed text, no icon; the tier-req
	# text fires with valid=false and invalid_item
	# tungsten -- the LAST unmineable drop, not the
	# first (Java overwrites invalidItem every time).
	var tier_world: Dictionary = {"2,0": {"solid": true, "wall_drop": {"id": "thorium", "hardness": 4}}, "2,1": {"solid": true, "wall_drop": {"id": "tungsten", "hardness": 5}}}
	var tier_place: Dictionary = beam_drill_build_state.source_beam_drill_can_place_on_state(0, 0, 0, 2, 5, 3, null, tier_world)
	var tier_draw: Dictionary = beam_drill_build_state.source_beam_drill_draw_place_state(0, 0, 0, true, 2, 5, 3, null, tier_world, 160.0, {}, 40.0)
	var tier_text: Variant = tier_draw.get("tier_req_text", null)
	proof["place_tier_req"] = tier_place.get("can_place_on", true) == false and tier_draw.get("speed_text", null) == null and tier_draw.get("icon", null) == null and tier_text is Dictionary and str((tier_text as Dictionary).get("text", "")) == "bar.drilltierreq" and (tier_text as Dictionary).get("valid", true) == false and str((tier_text as Dictionary).get("invalid_item", "")) == "tungsten"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillCanPlaceOnDrawPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
