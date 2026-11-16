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

	# --- RepairTower Units.nearby driver integration (N2211):
	# the driver tick line calls the N2210 pure query
	# (source_units_nearby_damaged_count_state, the circle
	# overload `public static void nearby(@Nullable Team team,
	# float x, float y, float radius, Cons<Unit> cons){`,
	# Units.java:445) and stamps `nearby_damaged_units` live on
	# the frame, BEFORE the refresh call, so the refresh block
	# (`if(potentialEfficiency > 0 && (refresh += Time.delta)
	# >= refreshInterval){` / `targets.clear();` /
	# `refresh = 0f;` / `Units.nearby(team, x, y, range, u ->
	# {` / `if(u.damaged()){` / `targets.add(u);`,
	# RepairTower.java:59-64) consumes a live observation at
	# every expiry. RED decisions pinned here: the query runs
	# only while potentialEfficiency > 0 (the Java gate,
	# RepairTower.java:59); the units list is the frame's
	# `units` key (`frame.get("units", [])`, the N2141/N2144
	# precedent -- no live units list is stamped on any frame
	# yet, so the proof seeds it, exactly as the N2190 proof
	# stamps power_status on the frame before ticking); the
	# centre is the tower's world position
	# (`sprite.position`); the radius is the per-def range
	# (`block.properties.get("range", 80.0)` -- 100f for
	# unit-repair-tower, `range = 100f;`, Blocks.java:6579).
	# Five towers, one shared driver tick each phase (the
	# driver ticks every placed repair tower per call):
	# A stamps + refresh-consumes, B stamps zero, C proves the
	# per-def range, D proves the no-power gate, E proves the
	# tower-centred query.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(30, 21), Vector2i(32, 21), Vector2i(34, 21), Vector2i(36, 21)]
	var towers: Array[Sprite2D] = []
	for cell in cells:
		var tower := Sprite2D.new()
		game.add_child(tower)
		game.call("record_placed_block", tower, blocks_by_id["unit-repair-tower"], cell)
		# The raw Sprite2D nodes never pass through the texture
		# path (SourceTextureRuntimeState.configure_block_sprite),
		# which is what assigns a placed block its world position
		# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
		# so without this every tower sits at the origin (0, 0)
		# and the tower-centred key cannot distinguish a
		# tower-centred query from an origin-centred one. Seed
		# the position exactly the way the game does.
		tower.position = game.source_block_sprite_base_position(blocks_by_id["unit-repair-tower"], cell)
		repair_tower_build_state.source_repair_tower_bind_frame_state(tower, blocks_by_id["unit-repair-tower"])
		towers.append(tower)
	var frames: Array[Dictionary] = []
	for tower in towers:
		frames.append(tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {}))
	# Full power everywhere except D (index 3), which proves
	# the no-power gate.
	for index in range(5):
		frames[index]["power_status"] = 0.0 if index == 3 else 1.0
	# One shared tick wires team_id onto every frame.
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(5):
		frames[index] = towers[index].get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	var teams: Array[int] = []
	for frame in frames:
		teams.append(int(frame.get("team_id", 1)))
	var positions: Array[Vector2] = []
	for tower in towers:
		positions.append(tower.position)

	# A: two damaged same-team in range, one undamaged in
	# range, one damaged other-team in range, one damaged
	# same-team far away -- expect 2.
	frames[0]["units"] = [
		{"team_id": teams[0], "x": positions[0].x + 10.0, "y": positions[0].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"team_id": teams[0], "x": positions[0].x - 10.0, "y": positions[0].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"team_id": teams[0], "x": positions[0].x + 10.0, "y": positions[0].y + 10.0, "hit_size": 6.0, "health": 100.0, "max_health": 100.0},
		{"team_id": teams[0] + 1, "x": positions[0].x + 10.0, "y": positions[0].y - 10.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"team_id": teams[0], "x": positions[0].x + 500.0, "y": positions[0].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]
	# B: one undamaged same-team in range only -- the refresh
	# stamps targets_count 0 after 6s (Java clears the targets
	# and adds nothing).
	frames[1]["units"] = [
		{"team_id": teams[1], "x": positions[1].x + 10.0, "y": positions[1].y, "hit_size": 6.0, "health": 100.0, "max_health": 100.0},
	]
	# C: one damaged same-team at 90 from the tower -- inside
	# the per-def range 100 (effective radius 103) but outside
	# the class default 80 (effective radius 83). Expect 1:
	# the driver reads the per-def range, not the default.
	frames[2]["units"] = [
		{"team_id": teams[2], "x": positions[2].x + 90.0, "y": positions[2].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]
	# D: one damaged same-team in range, but no power -- the
	# potentialEfficiency gate blocks the query, so no
	# observation is stamped at all.
	frames[3]["units"] = [
		{"team_id": teams[3], "x": positions[3].x + 10.0, "y": positions[3].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]
	# E: one damaged same-team at absolute (10, 0) -- inside
	# radius 100 of the origin but far from the tower. Expect
	# 0: the query is centred on the tower, not the origin.
	frames[4]["units"] = [
		{"team_id": teams[4], "x": 10.0, "y": 0.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]

	# One shared tick stamps the live counts.
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(5):
		frames[index] = towers[index].get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["live_driver_stamps_nearby_count"] = int(frames[0].get("nearby_damaged_units", -1)) == 2
	proof["live_driver_uses_per_def_range"] = int(frames[2].get("nearby_damaged_units", -1)) == 1
	proof["live_count_not_stamped_at_no_power"] = not frames[3].has("nearby_damaged_units")
	proof["live_query_centred_on_tower"] = int(frames[4].get("nearby_damaged_units", -1)) == 0

	# 360 shared ticks (6s) fire the refresh on A and B: the
	# refresh consumes the live observation and stamps
	# targets_count (2 on A, 0 on B).
	for iteration in range(360):
		repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(5):
		frames[index] = towers[index].get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["live_refresh_consumes_stamped_count"] = int(frames[0].get("targets_count", -1)) == 2
	proof["live_no_damaged_units_stamps_zero"] = int(frames[1].get("targets_count", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerNearbyDriverProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
