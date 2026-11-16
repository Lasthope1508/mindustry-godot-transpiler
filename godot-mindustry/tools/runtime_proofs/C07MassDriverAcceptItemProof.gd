extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
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

	# --- Pure acceptItem (N2336): the intake gate
	# (MassDriver.java:285-288, `public boolean acceptItem(Building
	# source, Item item){` with `//mass drivers that output only
	# cannot accept items` and `return items.total() <
	# itemCapacity && linkValid();`) -- two terms: the store total
	# under the def itemCapacity (120, Blocks.java:2170) AND
	# linkValid() (MassDriver.java:346-349, `protected boolean
	# linkValid(){` with `if(link == -1) return false;` and
	# `return world.build(this.link) instanceof MassDriverBuild
	# other && other.block == block && other.team == team &&
	# within(other, range);`). The source/item args are ignored
	# by Java -- the gate is capacity + link only -- so the pure
	# takes no source/item inputs. The link is the config link
	# (`public int link = -1;`, MassDriver.java:116, default -1).
	# The linked dict carries the precomputed linkValid
	# components (exists / is_mass_driver / same_block /
	# same_team / within_range), the N2225 partner precedent --
	# the SAME dict the N2237 advance reads for its has_link
	# conjunction. within is STRICT dst2 < range*range
	# (Position.java:44-46, the N2229 verification); range is
	# the single def 440f (Blocks.java:2172). The pure reads the
	# frame link + items and the linked dict, and returns
	# {accepts}. The link value here is a packed cell pos
	# (Point2.pack, arc Point2.java:40-42); only -1 vs not -1
	# matters to the gate.
	var linked_ok: Dictionary = {"exists": true, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": true}
	var link_pos: int = (30 << 16) | 21

	# Accepts when linked with room: an empty store accepts, a
	# half-full store accepts, and 119 of 120 accepts (the
	# STRICT < boundary: 119 < 120). The item mix does not
	# matter -- only the total counts.
	var empty: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {}}, 120, linked_ok)
	var roomy: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {"copper": 5}}, 120, linked_ok)
	var one_short: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {"copper": 100, "lead": 19}}, 120, linked_ok)
	proof["accepts_when_linked_and_room"] = bool(empty.get("accepts", false)) and bool(roomy.get("accepts", false)) and bool(one_short.get("accepts", false))

	# Rejects when full: exactly at capacity (120) rejects (the
	# STRICT < boundary: 120 < 120 is false), and over capacity
	# rejects too -- handlePayload can overfill the store to
	# 2x capacity (MassDriver.java:324), so the gate must hold
	# above the cap as well.
	var full: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {"copper": 120}}, 120, linked_ok)
	var overfull: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {"copper": 200}}, 120, linked_ok)
	proof["rejects_when_full"] = not bool(full.get("accepts", true)) and not bool(overfull.get("accepts", true))

	# Rejects when unlinked: link -1 rejects even with a
	# fully-valid partner dict (the guard fires first); a
	# missing partner (exists false) rejects; a partner that is
	# not a MassDriver rejects (the instanceof term). A missing
	# link key defaults to -1 and rejects the same way.
	var unlinked: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": -1, "items": {}}, 120, linked_ok)
	var missing: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {}}, 120, {"exists": false, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": true})
	var not_driver: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {}}, 120, {"exists": true, "is_mass_driver": false, "same_block": false, "same_team": true, "within_range": true})
	var no_link_key: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"items": {}}, 120, linked_ok)
	proof["rejects_when_unlinked"] = not bool(unlinked.get("accepts", true)) and not bool(missing.get("accepts", true)) and not bool(not_driver.get("accepts", true)) and not bool(no_link_key.get("accepts", true))

	# Rejects when the partner is the wrong block: same_block
	# false rejects even when every other term holds (a
	# MassDriver must link to the SAME block def -- single def,
	# so a MassDriver IS the same block, but the term is still
	# evaluated).
	var wrong_block: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {}}, 120, {"exists": true, "is_mass_driver": true, "same_block": false, "same_team": true, "within_range": true})
	proof["rejects_when_partner_wrong_block"] = not bool(wrong_block.get("accepts", true))

	# Rejects when the partner is the wrong team: same_team
	# false rejects even when every other term holds (unlike
	# shooterValid, MassDriver.java:342-344, linkValid DOES
	# check the team).
	var wrong_team: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {}}, 120, {"exists": true, "is_mass_driver": true, "same_block": true, "same_team": false, "within_range": true})
	proof["rejects_when_partner_wrong_team"] = not bool(wrong_team.get("accepts", true))

	# Rejects when the partner is out of range: within_range
	# false rejects even when every other term holds (within is
	# STRICT dst2 < range*range, Position.java:44-46, range the
	# single def 440f).
	var out_of_range: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"link": link_pos, "items": {}}, 120, {"exists": true, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": false})
	proof["rejects_when_partner_out_of_range"] = not bool(out_of_range.get("accepts", true))

	# --- Live tick: two mass drivers placed live (the N2237 /
	# N2294 pattern -- the tick driver is called directly, not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status; the write-back itself is already
	# proven by N2142). Driver A at (28, 21) links to driver B
	# at (30, 21): 2 cells apart is 16 world units, well inside
	# the 440 range, same block, same team -- so A's frame
	# stamps accepts_item true on the first tick (empty store),
	# while unlinked B stamps false. Filling A's store to
	# exactly 120 and ticking again stamps false: the capacity
	# term fails even though the link still holds. The link is
	# stamped on A's frame directly (Point2.pack(30, 21) -- the
	# port has no config UI, so the link is a frame key). NO
	# power on either driver: acceptItem has no efficiency term,
	# so the verdicts do not depend on power.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var driver_a_cell := Vector2i(28, 21)
	var driver_b_cell := Vector2i(30, 21)
	var driver_a := Sprite2D.new()
	var driver_b := Sprite2D.new()
	game.add_child(driver_a)
	game.add_child(driver_b)
	game.call("record_placed_block", driver_a, blocks_by_id["mass-driver"], driver_a_cell)
	game.call("record_placed_block", driver_b, blocks_by_id["mass-driver"], driver_b_cell)
	# Bind the frames explicitly (the N2149 pattern: the driver
	# binds them on the first tick, but the proof needs the live
	# frame dicts before the tick to stamp power_status and the
	# link on them).
	mass_driver_build_state.source_mass_driver_bind_frame_state(driver_a, blocks_by_id["mass-driver"])
	mass_driver_build_state.source_mass_driver_bind_frame_state(driver_b, blocks_by_id["mass-driver"])
	var driver_a_frame: Dictionary = driver_a.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var driver_b_frame: Dictionary = driver_b.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	driver_a_frame["link"] = (30 << 16) | 21
	driver_a_frame["power_status"] = 0.0
	driver_b_frame["power_status"] = 0.0
	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	driver_a_frame = driver_a.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	driver_b_frame = driver_b.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	proof["accepts_when_linked_and_room"] = bool(proof["accepts_when_linked_and_room"]) and bool(driver_a_frame.get("accepts_item", false))
	proof["rejects_when_unlinked"] = bool(proof["rejects_when_unlinked"]) and not bool(driver_b_frame.get("accepts_item", true))
	driver_a_frame["items"] = {"copper": 120}
	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	driver_a_frame = driver_a.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	proof["rejects_when_full"] = bool(proof["rejects_when_full"]) and not bool(driver_a_frame.get("accepts_item", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverAcceptItemProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
