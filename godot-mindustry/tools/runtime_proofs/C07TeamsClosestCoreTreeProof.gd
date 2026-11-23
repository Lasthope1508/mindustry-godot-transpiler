extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# --- Teams closestCore + TeamData tree group (N2392):
	# Teams.closestCore()+TeamData.tree()
	# (Teams.java:56-58 + :437-440,
	# `public CoreBuild closestCore(float x, float y, Team team){` /
	# `return Geometry.findClosest(x, y, get(team).cores);` /
	# `public QuadTree<Unit> tree(){` /
	# `if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));` /
	# `return unitTree;`).
	# One grouped slice (main-thread decision 2026-11-21, the
	# N2380 seven-method / N2374 five-accessor group
	# precedent): two one-to-two-line read-only lookup
	# methods on Teams/TeamData (`cores` + `unitTree`).
	# The proof calls the two pure functions with synthetic
	# inputs (no live tick). Geometry.findClosest arrives
	# as a Callable (the proof's own nearest-by-dst2 scan
	# stands in for the arc engine call); Vars.world.
	# getQuadBounds arrives as a Callable returning the
	# bounds Dictionary for the fresh tree.

	# closestCore() returns the nearest core ref from the
	# resolved cores, or null when there are no cores.
	var find_closest := func(px: float, py: float, pcores: Array):
		var nearest: Variant = null
		var nearest_dst2: float = 3.4028235e38
		for entry in pcores:
			var dx: float = px - float(entry.get("x", 0.0))
			var dy: float = py - float(entry.get("y", 0.0))
			var dst2: float = dx * dx + dy * dy
			if nearest_dst2 > dst2:
				nearest_dst2 = dst2
				nearest = entry.get("ref", null)
		return nearest
	var cores: Array = [
		{"ref": "core-a", "x": 10.0, "y": 0.0},
		{"ref": "core-b", "x": 3.0, "y": 4.0},
	]
	var nearest: Dictionary = teams_state.source_teams_closest_core_state(0.0, 0.0, cores, find_closest)
	proof["closest_core_returns_nearest_core"] = nearest.get("core", "not-core-b") == "core-b"
	var nearest_empty: Dictionary = teams_state.source_teams_closest_core_state(0.0, 0.0, [], find_closest)
	proof["closest_core_null_when_no_cores"] = nearest_empty.get("core", "not-null") == null
	proof["closest_core_returns_only_one_key"] = nearest.size() == 1

	# tree() creates a fresh tree from the world-bounds
	# Callable when the cache is null, and returns the
	# cached tree (never calling the Callable) when present.
	var fresh_bounds: Dictionary = {"x": 0.0, "y": 0.0, "w": 200.0, "h": 200.0}
	var created: Dictionary = teams_state.source_team_data_tree_state(null, func(): return fresh_bounds)
	proof["tree_creates_when_cache_null"] = created.get("unit_tree", {}) == fresh_bounds
	var cached_tree: Dictionary = {"x": 5.0, "y": 5.0, "w": 50.0, "h": 50.0}
	var other_bounds: Dictionary = {"x": 99.0, "y": 99.0, "w": 1.0, "h": 1.0}
	var kept: Dictionary = teams_state.source_team_data_tree_state(cached_tree, func(): return other_bounds)
	proof["tree_returns_cached_when_present"] = kept.get("unit_tree", {}) == cached_tree
	proof["tree_returns_only_one_key"] = created.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsClosestCoreTreeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
