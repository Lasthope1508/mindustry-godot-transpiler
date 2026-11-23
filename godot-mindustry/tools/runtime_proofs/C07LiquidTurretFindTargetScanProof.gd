extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_turret_build := preload("res://src/game/SourceLiquidTurretBuildState.gd")
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

	# --- LiquidTurretBuild.findTarget() extinguish-scan loop (N2408):
	# LiquidTurretBuild.findTarget() (LiquidTurret.java:91-117).
	# Only the 12 loop exprs: the shell is N1200-owned
	# (guard, `Fire result = null;`, `target = result;`,
	# `return;`, `super.findTarget();`) and is never
	# re-registered. The proof calls the pure function
	# with synthetic inputs (no live tick, no render):
	# the build stands at world (40, 40) with scan_range
	# 24 and tilesize 8, so the scan origin tile is (5,
	# 5) and the radius is 3 tiles (offsets -3..3).
	# World lookups arrive as Callables over three
	# scenario dictionaries (tile -> {"build": Variant,
	# "build_team": Variant} or null, fire, Fires.has);
	# dst2 is a Callable returning the squared distance
	# from the build to a fire. Fire positions are world
	# coords (tile center = tile * 8 + 4).
	var build_x: float = 40.0
	var build_y: float = 40.0
	var scan_range: float = 24.0
	var tilesize: float = 8.0
	var team: String = "sharded"
	var self_build: RefCounted = RefCounted.new()
	var crux_build: RefCounted = RefCounted.new()
	var tiles: Dictionary = {}
	var fires: Dictionary = {}
	var has_map: Dictionary = {}
	var world_tile: Callable = func(tx: int, ty: int) -> Variant:
		return tiles.get(Vector2i(tx, ty), {"build": null, "build_team": null})
	var fires_get: Callable = func(tx: int, ty: int) -> Variant:
		return fires.get(Vector2i(tx, ty))
	var fires_has: Callable = func(tx: int, ty: int) -> bool:
		return has_map.get(Vector2i(tx, ty), false) == true
	var dst2: Callable = func(fire: Variant) -> float:
		var dx: float = float(fire.get("x")) - build_x
		var dy: float = float(fire.get("y")) - build_y
		return dx * dx + dy * dy

	# Main world: E far (dst 800, scanned first), C
	# closest (dst 32) but on a crux build, SELF on the
	# own tile (dst 32), D present but finished
	# (fires_has false, dst 160), B nearest valid (dst
	# 160), N on a null tile, G farther (dst 1568,
	# scanned after B).
	var fire_e: Dictionary = {"id": "E", "x": 20.0, "y": 20.0}
	var fire_c: Dictionary = {"id": "C", "x": 44.0, "y": 36.0}
	var fire_self: Dictionary = {"id": "SELF", "x": 44.0, "y": 44.0}
	var fire_d: Dictionary = {"id": "D", "x": 44.0, "y": 52.0}
	var fire_b: Dictionary = {"id": "B", "x": 52.0, "y": 44.0}
	var fire_n: Dictionary = {"id": "N", "x": 68.0, "y": 20.0}
	var fire_g: Dictionary = {"id": "G", "x": 68.0, "y": 68.0}
	tiles[Vector2i(2, 2)] = {"build": null, "build_team": null}
	tiles[Vector2i(5, 4)] = {"build": crux_build, "build_team": "crux"}
	tiles[Vector2i(5, 5)] = {"build": self_build, "build_team": "sharded"}
	tiles[Vector2i(5, 6)] = {"build": null, "build_team": null}
	tiles[Vector2i(6, 5)] = {"build": null, "build_team": null}
	tiles[Vector2i(8, 2)] = null
	tiles[Vector2i(8, 8)] = {"build": null, "build_team": null}
	fires[Vector2i(2, 2)] = fire_e
	fires[Vector2i(5, 4)] = fire_c
	fires[Vector2i(5, 5)] = fire_self
	fires[Vector2i(5, 6)] = fire_d
	fires[Vector2i(6, 5)] = fire_b
	fires[Vector2i(8, 2)] = fire_n
	fires[Vector2i(8, 8)] = fire_g
	has_map[Vector2i(2, 2)] = true
	has_map[Vector2i(5, 4)] = true
	has_map[Vector2i(5, 5)] = true
	has_map[Vector2i(5, 6)] = false
	has_map[Vector2i(6, 5)] = true
	has_map[Vector2i(8, 2)] = true
	has_map[Vector2i(8, 8)] = true

	# The scan finds the nearest valid fire: B (dst
	# 160), not the closer-but-other-team C, not the
	# own-tile SELF, not the finished D, not the
	# null-tile N, not the farther G.
	var result: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_finds_nearest_valid_fire"] = (result.get("fire_result", {}) as Dictionary).get("id", "") == "B" and result.get("result_found", false) == true
	proof["scan_mindst_is_nearest_dst"] = result.get("mindst", -1.0) == 160.0

	# One fire alone on an other-team build is not a
	# target, even though it is the closest fire.
	tiles.clear()
	fires.clear()
	has_map.clear()
	tiles[Vector2i(5, 4)] = {"build": crux_build, "build_team": "crux"}
	fires[Vector2i(5, 4)] = fire_c
	has_map[Vector2i(5, 4)] = true
	var only_c: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_excludes_other_team_build"] = only_c.get("fire_result", fire_c) == null and only_c.get("result_found", true) == false

	# One fire alone on the turret's own tile is not a
	# target: `other.build != this` excludes it.
	tiles.clear()
	fires.clear()
	has_map.clear()
	tiles[Vector2i(5, 5)] = {"build": self_build, "build_team": "sharded"}
	fires[Vector2i(5, 5)] = fire_self
	has_map[Vector2i(5, 5)] = true
	var only_self: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_excludes_self_build_tile"] = only_self.get("fire_result", fire_self) == null and only_self.get("result_found", true) == false

	# One fire alone that Fires.has rejects (finished
	# fire) is not a target, even though Fires.get
	# returns it.
	tiles.clear()
	fires.clear()
	has_map.clear()
	tiles[Vector2i(5, 6)] = {"build": null, "build_team": null}
	fires[Vector2i(5, 6)] = fire_d
	has_map[Vector2i(5, 6)] = false
	var only_d: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_excludes_finished_fire"] = only_d.get("fire_result", fire_d) == null and only_d.get("result_found", true) == false

	# One fire alone on a null tile (out of bounds) is
	# not a target: `other != null` fails first.
	tiles.clear()
	fires.clear()
	has_map.clear()
	tiles[Vector2i(8, 2)] = null
	fires[Vector2i(8, 2)] = fire_n
	has_map[Vector2i(8, 2)] = true
	var only_n: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_excludes_null_tile"] = only_n.get("fire_result", fire_n) == null and only_n.get("result_found", true) == false

	# The first valid candidate is accepted while
	# result is null (mindst starts 0), then a nearer
	# candidate replaces it: E (dst 800, scanned
	# first) gives way to B (dst 160).
	tiles.clear()
	fires.clear()
	has_map.clear()
	tiles[Vector2i(2, 2)] = {"build": null, "build_team": null}
	tiles[Vector2i(6, 5)] = {"build": null, "build_team": null}
	fires[Vector2i(2, 2)] = fire_e
	fires[Vector2i(6, 5)] = fire_b
	has_map[Vector2i(2, 2)] = true
	has_map[Vector2i(6, 5)] = true
	var replaced: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_replaces_first_with_nearer"] = (replaced.get("fire_result", {}) as Dictionary).get("id", "") == "B" and replaced.get("mindst", -1.0) == 160.0

	# No fire anywhere: no target, mindst stays 0.
	tiles.clear()
	fires.clear()
	has_map.clear()
	var none: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_returns_no_fire_when_none"] = none.get("fire_result", fire_b) == null and none.get("mindst", -1.0) == 0.0 and none.get("result_found", true) == false

	# The scan reports its origin tile, radius, and
	# echoes the scalar inputs; the result carries
	# exactly the 12 scan keys.
	proof["scan_reports_origin_and_radius"] = result.get("tile_x", -1) == 5 and result.get("tile_y", -1) == 5 and result.get("scan_radius", -1) == 3 and result.get("build_x", -1.0) == 40.0 and result.get("build_y", -1.0) == 40.0 and result.get("scan_range", -1.0) == 24.0 and result.get("tilesize", -1.0) == 8.0 and result.get("team", "") == "sharded" and result.get("self_build", null) == self_build
	proof["scan_returns_only_twelve_keys"] = result.size() == 12

	# A second call on the same world yields the same
	# fire and distance: the scan is idempotent.
	tiles.clear()
	fires.clear()
	has_map.clear()
	tiles[Vector2i(2, 2)] = {"build": null, "build_team": null}
	tiles[Vector2i(5, 4)] = {"build": crux_build, "build_team": "crux"}
	tiles[Vector2i(5, 5)] = {"build": self_build, "build_team": "sharded"}
	tiles[Vector2i(5, 6)] = {"build": null, "build_team": null}
	tiles[Vector2i(6, 5)] = {"build": null, "build_team": null}
	tiles[Vector2i(8, 2)] = null
	tiles[Vector2i(8, 8)] = {"build": null, "build_team": null}
	fires[Vector2i(2, 2)] = fire_e
	fires[Vector2i(5, 4)] = fire_c
	fires[Vector2i(5, 5)] = fire_self
	fires[Vector2i(5, 6)] = fire_d
	fires[Vector2i(6, 5)] = fire_b
	fires[Vector2i(8, 2)] = fire_n
	fires[Vector2i(8, 8)] = fire_g
	has_map[Vector2i(2, 2)] = true
	has_map[Vector2i(5, 4)] = true
	has_map[Vector2i(5, 5)] = true
	has_map[Vector2i(5, 6)] = false
	has_map[Vector2i(6, 5)] = true
	has_map[Vector2i(8, 2)] = true
	has_map[Vector2i(8, 8)] = true
	var second: Dictionary = liquid_turret_build.source_liquid_turret_find_target_scan_state(build_x, build_y, scan_range, tilesize, team, self_build, world_tile, fires_get, fires_has, dst2)
	proof["scan_idempotent_second_call"] = (second.get("fire_result", {}) as Dictionary).get("id", "") == "B" and second.get("mindst", -1.0) == 160.0 and second.size() == 12

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidTurretFindTargetScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
