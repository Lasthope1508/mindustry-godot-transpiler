extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_router_build_state := preload("res://src/game/SourceStackRouterBuildState.gd")
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

	# --- Pure fill (N2472): the live proximity query that
	# fills frame["proximity_neighbours"] (DEFERRED #210,
	# QUERY HALF ONLY), which the N2324 target list reads
	# before the N2240 advance. Java builds proximity in
	# updateProximity() (BuildingComp.java:1879-1903): it
	# scans Edges.getEdges(block.size) (:1883), looks up
	# world.build(tile.x + point.x, tile.y + point.y)
	# (:1885), and keeps same-team buildings only
	# (`if(other == null || other.team != team) continue;`,
	# :1887). The ring is the Edges static block
	# (Edges.java:23-40): bot/top from the size, 4*size
	# edge points, sorted by Mathf.angle -- and
	# Mathf.angle NORMALIZES to [0, 360) (arc Mathf.java:
	# 98-102), so the size-1 ring is east / north / west /
	# south = rel 0/1/2/3, the Geometry.d4 order. rel is
	# relativeTo(Building) (BuildingComp.java:530-540) in
	# tile-offset form: |dx| > |dy| picks east/west (0/2),
	# otherwise the y branch picks north/south (1/3) -- a
	# diagonal ring point takes the y branch. A ring tile
	# yields an entry only when the tile is known (a
	# world_tiles Dict entry) AND a building stands there
	# (a team_map key -- its presence IS the building
	# signal) AND its team matches the router. The id is
	# the ring tile's "x,y" key (the port cell_key
	# format); accepts_item is the neighbour acceptItem
	# answer, a missing key rejecting. The fill never reads
	# the solid flag. Every pure case below uses cell (10,
	# 10), size 1, team 1 unless noted.

	# Ring order at size 1: all four ring tiles present
	# (world + team 1 + accepts true) fill four entries in
	# Edges order -- east (11, 10), north (10, 11), west
	# (9, 10), south (10, 9). The solid flags mix true and
	# false to prove the fill never consults solidity. The
	# decoys at (12, 10) (off the ring) and (11, 11)
	# (diagonal, off the ring) carry world + team entries
	# but are never read. The size-2 ring (bot -1, top 2)
	# fills eight entries in angle order: (12, 10), (12,
	# 11), (11, 12), (10, 12), (9, 11), (9, 10), (10, 9),
	# (11, 9). Size 0 fills nothing (the invalid-size
	# guard).
	var ring_map: Dictionary = {
		"11,10": {"solid": true, "wall_drop": ""},
		"10,11": {"solid": false, "wall_drop": ""},
		"9,10": {"solid": true, "wall_drop": ""},
		"10,9": {"solid": false, "wall_drop": ""},
		"12,10": {"solid": true, "wall_drop": ""},
		"11,11": {"solid": true, "wall_drop": ""},
	}
	var ring_teams: Dictionary = {"11,10": 1, "10,11": 1, "9,10": 1, "10,9": 1, "12,10": 1, "11,11": 1}
	var ring_accepts: Dictionary = {"11,10": true, "10,11": true, "9,10": true, "10,9": true, "12,10": true, "11,11": true}
	var ring_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(ring_map, Vector2i(10, 10), 1, 1, ring_teams, ring_accepts).get("proximity_neighbours", [])
	var ring_ids: Array = []
	for ring_entry in ring_filled:
		ring_ids.append(str(ring_entry.get("id", "")))
	var size2_map: Dictionary = {
		"12,10": {"solid": true, "wall_drop": ""},
		"12,11": {"solid": true, "wall_drop": ""},
		"11,12": {"solid": true, "wall_drop": ""},
		"10,12": {"solid": true, "wall_drop": ""},
		"9,11": {"solid": true, "wall_drop": ""},
		"9,10": {"solid": true, "wall_drop": ""},
		"10,9": {"solid": true, "wall_drop": ""},
		"11,9": {"solid": true, "wall_drop": ""},
	}
	var size2_teams: Dictionary = {"12,10": 1, "12,11": 1, "11,12": 1, "10,12": 1, "9,11": 1, "9,10": 1, "10,9": 1, "11,9": 1}
	var size2_accepts: Dictionary = {"12,10": true, "12,11": true, "11,12": true, "10,12": true, "9,11": true, "9,10": true, "10,9": true, "11,9": true}
	var size2_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(size2_map, Vector2i(10, 10), 2, 1, size2_teams, size2_accepts).get("proximity_neighbours", [])
	var size2_ids: Array = []
	for size2_entry in size2_filled:
		size2_ids.append(str(size2_entry.get("id", "")))
	var size0_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(ring_map, Vector2i(10, 10), 0, 1, ring_teams, ring_accepts).get("proximity_neighbours", ["x"])
	proof["query_ring_order"] = ring_filled.size() == 4 and ring_ids == ["11,10", "10,11", "9,10", "10,9"] and size2_filled.size() == 8 and size2_ids == ["12,10", "12,11", "11,12", "10,12", "9,11", "9,10", "10,9", "11,9"] and size0_filled.is_empty()

	# rel values: the size-1 ring reads rel 0/1/2/3 in ring
	# order (east / north / west / south). The size-2 ring
	# pins the diagonal rule (ties go to the y branch): the
	# (-1, 1) offset at (9, 11) reads rel 1 (north, not
	# west) and the (1, -1) offset at (11, 9) reads rel 3
	# (south, not east); the (2, 1) offset at (12, 11)
	# reads rel 0 (|dx| > |dy|) and the (1, 2) offset at
	# (11, 12) reads rel 1 (|dy| > |dx|).
	var ring_rels: Array = []
	for ring_entry in ring_filled:
		ring_rels.append(int(ring_entry.get("rel", -9)))
	var size2_rels: Array = []
	for size2_entry in size2_filled:
		size2_rels.append(int(size2_entry.get("rel", -9)))
	proof["query_rel_values"] = ring_rels == [0, 1, 2, 3] and size2_rels == [0, 0, 1, 1, 1, 2, 3, 3]

	# The team gate: east is an ally (team 1, included),
	# north is an enemy (team 2, excluded -- the Java
	# same-team filter), west has a world tile but NO
	# team_map key (no building, skipped), south has a
	# team_map key but NO world_tiles entry (a null tile,
	# skipped). Only east survives. Empty maps fill an
	# empty list (no neighbours anywhere).
	var gate_map: Dictionary = {
		"11,10": {"solid": true, "wall_drop": ""},
		"10,11": {"solid": true, "wall_drop": ""},
		"9,10": {"solid": true, "wall_drop": ""},
	}
	var gate_teams: Dictionary = {"11,10": 1, "10,11": 2, "10,9": 1}
	var gate_accepts: Dictionary = {"11,10": true, "10,11": true, "9,10": true, "10,9": true}
	var gate_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(gate_map, Vector2i(10, 10), 1, 1, gate_teams, gate_accepts).get("proximity_neighbours", [])
	var empty_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state({}, Vector2i(10, 10), 1, 1, {}, {}).get("proximity_neighbours", ["x"])
	proof["query_team_gate"] = gate_filled.size() == 1 and str(gate_filled[0].get("id", "")) == "11,10" and int(gate_filled[0].get("team", -1)) == 1 and empty_filled.is_empty()

	# The accepts map: east accepts, north rejects, west
	# has NO accepts_map key (missing rejects, false --
	# the N2324 pure's default), south accepts. The filled
	# list feeds the N2324 target pure directly: with
	# current copper, no sort item, rotation 0, team 1,
	# cdump 0 and 2 handoffs, call 1 matches east (cdump
	# 1) and call 2 skips north (rejects, cdump 2) and
	# west (backwards rel 2, cdump 3) before matching
	# south (cdump 0) -- targets [east, south]. With all
	# accepts false the target list is empty (a full scan
	# with no match, cdump unchanged at 0).
	var accepts_map: Dictionary = {
		"11,10": {"solid": true, "wall_drop": ""},
		"10,11": {"solid": true, "wall_drop": ""},
		"9,10": {"solid": true, "wall_drop": ""},
		"10,9": {"solid": true, "wall_drop": ""},
	}
	var accepts_teams: Dictionary = {"11,10": 1, "10,11": 1, "9,10": 1, "10,9": 1}
	var accepts_answers: Dictionary = {"11,10": true, "10,11": false, "10,9": true}
	var accepts_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(accepts_map, Vector2i(10, 10), 1, 1, accepts_teams, accepts_answers).get("proximity_neighbours", [])
	var accepts_values: Array = []
	for accepts_entry in accepts_filled:
		accepts_values.append(bool(accepts_entry.get("accepts_item", true)))
	var composed_list: Dictionary = stack_router_build_state.source_stack_router_target_list_state(accepts_filled, "copper", null, 0, 1, 0, 2)
	var composed_targets: Array = composed_list.get("targets", [])
	var composed_ids: Array = []
	for composed_entry in composed_targets:
		composed_ids.append(str(composed_entry.get("id", "")))
	var all_reject_filled: Array = stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(accepts_map, Vector2i(10, 10), 1, 1, accepts_teams, {"11,10": false, "10,11": false, "9,10": false, "10,9": false}).get("proximity_neighbours", [])
	var all_reject_list: Dictionary = stack_router_build_state.source_stack_router_target_list_state(all_reject_filled, "copper", null, 0, 1, 0, 2)
	proof["query_accepts_map"] = accepts_filled.size() == 4 and accepts_values == [true, false, false, true] and composed_ids == ["11,10", "10,9"] and int(composed_list.get("cdump_after", -1)) == 0 and Array(all_reject_list.get("targets", ["x"])).is_empty() and int(all_reject_list.get("cdump_after", -1)) == 0

	# --- Live ticks: two surge-routers placed live; the
	# tick driver is called directly (as the N2240/N2324
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick. Both routers tick in
	# the same call; each has its own frame.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Supplied lists WIN (the N2381 precedent): this
	# router seeds proximity_neighbours by hand (two
	# entries, seed-a / seed-b) AND carries world_tiles +
	# team_map + accepts_map inputs whose ring would fill
	# four entries if the fill ran. After two ticks the
	# seeded list is untouched and the live flag is NOT
	# set -- the fill never ran. Its store stays empty, so
	# no handoff happens either way.
	var seeded_cell := Vector2i(28, 24)
	var seeded := Sprite2D.new()
	game.add_child(seeded)
	game.call("record_placed_block", seeded, blocks_by_id["surge-router"], seeded_cell)
	stack_router_build_state.source_stack_router_bind_frame_state(seeded, blocks_by_id["surge-router"])
	var seeded_frame: Dictionary = seeded.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	seeded_frame["items"] = {}
	seeded_frame["power_status"] = 0.5
	seeded_frame["proximity_neighbours"] = [{"id": "seed-a", "rel": 0, "team": 1, "accepts_item": true}, {"id": "seed-b", "rel": 1, "team": 1, "accepts_item": true}]
	seeded_frame["world_tiles"] = {
		"29,24": {"solid": true, "wall_drop": ""},
		"28,25": {"solid": true, "wall_drop": ""},
		"27,24": {"solid": true, "wall_drop": ""},
		"28,23": {"solid": true, "wall_drop": ""},
	}
	seeded_frame["team_by_tile"] = {"29,24": 1, "28,25": 1, "27,24": 1, "28,23": 1}
	seeded_frame["accepts_item_by_tile"] = {"29,24": true, "28,25": true, "27,24": true, "28,23": true}

	# Live tick with the fill: this router seeds NO
	# proximity_neighbours, so the fill runs -- a first
	# tick on the empty store stamps the live team_id
	# (the N2324 pattern) and the fill stamps an empty
	# list + the live flag; then the store is seeded
	# full (10 copper, current copper, progress 5.0,
	# cdump 0) with the ring maps (east + north accept,
	# west accepts but sits backwards at rotation 0,
	# south rejects). The second tick refreshes the fill
	# (the live flag), folds efficiency 0.5, charges
	# progress 5.0 -> 6.5 (eff 1.5, unloading starts,
	# progress wraps to 0.5) and hands all 10 copper off
	# in target-list order -- east, north alternating
	# (call 1 east, call 2 north, call 3 skips west +
	# south then east again, ...) -- so handed_to is
	# ["29,21", "28,22"] x5, cdump stamps 2, the copper
	# drains to 0, current clears to null and unloading
	# clears to false.
	var stack_router_cell := Vector2i(28, 21)
	var stack_router := Sprite2D.new()
	game.add_child(stack_router)
	game.call("record_placed_block", stack_router, blocks_by_id["surge-router"], stack_router_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# seed the store on it).
	stack_router_build_state.source_stack_router_bind_frame_state(stack_router, blocks_by_id["surge-router"])
	var stack_router_frame: Dictionary = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var live_team: int = int(stack_router_frame.get("team_id", -1))

	stack_router_frame["items"] = {"copper": 10}
	stack_router_frame["current"] = "copper"
	stack_router_frame["progress"] = 5.0
	stack_router_frame["power_status"] = 0.5
	stack_router_frame["cdump"] = 0
	stack_router_frame["sort_item"] = null
	stack_router_frame["world_tiles"] = {
		"29,21": {"solid": true, "wall_drop": ""},
		"28,22": {"solid": true, "wall_drop": ""},
		"27,21": {"solid": true, "wall_drop": ""},
		"28,20": {"solid": true, "wall_drop": ""},
	}
	stack_router_frame["team_by_tile"] = {"29,21": live_team, "28,22": live_team, "27,21": live_team, "28,20": live_team}
	stack_router_frame["accepts_item_by_tile"] = {"29,21": true, "28,22": true, "27,21": true, "28,20": false}
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	seeded_frame = seeded.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var seeded_neighbours: Array = seeded_frame.get("proximity_neighbours", [])
	var seeded_ids: Array = []
	for seeded_entry in seeded_neighbours:
		seeded_ids.append(str(seeded_entry.get("id", "")))
	proof["query_supplied_wins"] = seeded_neighbours.size() == 2 and seeded_ids == ["seed-a", "seed-b"] and bool(seeded_frame.get("proximity_neighbours_live", true)) == false
	var live_filled: Array = stack_router_frame.get("proximity_neighbours", [])
	var live_ids: Array = []
	var live_rels: Array = []
	var live_teams: Array = []
	var live_accepts: Array = []
	for live_entry in live_filled:
		live_ids.append(str(live_entry.get("id", "")))
		live_rels.append(int(live_entry.get("rel", -9)))
		live_teams.append(int(live_entry.get("team", -1)))
		live_accepts.append(bool(live_entry.get("accepts_item", true)))
	var live_items: Dictionary = stack_router_frame.get("items", {})
	proof["query_live_tick"] = bool(stack_router_frame.get("proximity_neighbours_live", false)) == true and live_filled.size() == 4 and live_ids == ["29,21", "28,22", "27,21", "28,20"] and live_rels == [0, 1, 2, 3] and live_teams == [live_team, live_team, live_team, live_team] and live_accepts == [true, true, true, false] and is_equal_approx(float(stack_router_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(stack_router_frame.get("progress", -1.0)), 0.5) and bool(stack_router_frame.get("unloading", true)) == false and stack_router_frame.get("current", {}) == null and int(live_items.get("copper", -1)) == 0 and int(stack_router_frame.get("handed_off", -1)) == 10 and Array(stack_router_frame.get("handed_to", [])) == ["29,21", "28,22", "29,21", "28,22", "29,21", "28,22", "29,21", "28,22", "29,21", "28,22"] and int(stack_router_frame.get("cdump", -1)) == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterLiveProximityQueryProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
