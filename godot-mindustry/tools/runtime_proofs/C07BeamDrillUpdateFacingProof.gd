extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- BeamDrillBuild.onProximityUpdate() + updateLasers()
	# + updateFacing() (N2379):
	# BeamDrillBuild.onProximityUpdate()
	# (BeamDrill.java:362-366) calls the two helpers in
	# order when the build is rotated:
	# `public void onProximityUpdate(){`
	# `//when rotated.`
	# `updateLasers();`
	# `updateFacing();`
	# `}`
	# BeamDrillBuild.updateLasers()
	# (BeamDrill.java:368-373) fills every null laser
	# point then recomputes it with nearbySide:
	# `protected void updateLasers(){`
	# `for(int i = 0; i < size; i++){`
	# `if(lasers[i] == null) lasers[i] = new Point2();`
	# `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`
	# `}`
	# `}`
	# BeamDrillBuild.updateFacing()
	# (BeamDrill.java:375-412) scans each laser's ray
	# for the first solid tile with a mineable wall drop:
	# `protected void updateFacing(){`
	# `lastItem = null;`
	# `boolean multiple = false;`
	# `int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);`
	# `facingAmount = 0;`
	# `for(int p = 0; p < size; p++){`
	# `Point2 l = lasers[p];`
	# `Tile dest = null;`
	# `for(int i = 0; i < range; i++){`
	# `int rx = l.x + dx*i, ry = l.y + dy*i;`
	# `Tile other = world.tile(rx, ry);`
	# `if(other != null){`
	# `if(other.solid()){`
	# `Item drop = other.wallDrop();`
	# `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
	# `facingAmount ++;`
	# `if(lastItem != drop && lastItem != null){`
	# `multiple = true;`
	# `}`
	# `lastItem = drop;`
	# `dest = other;`
	# `}`
	# `break;`
	# `}`
	# `}`
	# `}`
	# `facing[p] = dest;`
	# `}`
	# `if(multiple){`
	# `lastItem = null;`
	# `}`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220). The proof drives the three
	# pure functions with synthetic frames and tile
	# Dictionaries (no live tick): the world_tile
	# Callable maps "x,y" to a tile Dictionary {"solid",
	# "wall_drop", "wall_drop_hardness"} or null. The
	# plasma-bore def drives the cases (tier 3, size 2,
	# range 5, Blocks.java:3049-3065); copper hardness 1
	# and lead hardness 2 are mineable at tier 3,
	# titanium hardness 5 is not. NO driver tick line:
	# proximity update runs at placement / rotation.

	# The proximity entry calls both helpers: lasers are
	# filled from the footprint and the facing ray finds
	# the copper wall in one call.
	var copper_tile: Dictionary = {"solid": true, "wall_drop": "copper", "wall_drop_hardness": 1.0}
	var copper_world: Dictionary = {"12,10": copper_tile}
	var copper_lookup: Callable = func(rx: int, ry: int) -> Variant: return copper_world.get("%d,%d" % [rx, ry], null)
	var entry_frame: Dictionary = {}
	var entry: Dictionary = state.source_beam_drill_on_proximity_update_state(entry_frame, 10, 10, 0, 2, 5, 3, null, copper_lookup)
	var entry_lasers: Array = entry.get("lasers", [])
	var entry_facing: Array = entry.get("facing", [])
	proof["on_proximity_update_calls_both"] = entry_lasers == [Vector2i(12, 10), Vector2i(12, 11)] and int(entry.get("facing_amount", -1)) == 1 and str(entry.get("last_item", "")) == "copper" and entry_facing[0] == copper_tile and entry_facing[1] == null

	# updateLasers fills null entries before recomputing
	# them with nearbySide.
	var null_frame: Dictionary = {"lasers": [null, null]}
	var filled: Dictionary = state.source_beam_drill_update_lasers_state(null_frame, 10, 10, 0, 2)
	proof["update_lasers_fills_nulls"] = filled.get("lasers", []) == [Vector2i(12, 10), Vector2i(12, 11)]

	# Rotation 0 faces +x: the side points are the
	# footprint's right edge (corner (10, 10), size 2).
	var rot0_frame: Dictionary = {}
	var rot0: Dictionary = state.source_beam_drill_update_lasers_state(rot0_frame, 10, 10, 0, 2)
	proof["update_lasers_rotation_zero"] = rot0.get("lasers", []) == [Vector2i(12, 10), Vector2i(12, 11)]

	# Rotation 1 faces +y: the side points are the
	# footprint's top edge.
	var rot1_frame: Dictionary = {}
	var rot1: Dictionary = state.source_beam_drill_update_lasers_state(rot1_frame, 10, 10, 1, 2)
	proof["update_lasers_rotation_one"] = rot1.get("lasers", []) == [Vector2i(10, 12), Vector2i(11, 12)]

	# A solid copper wall on the first laser's ray counts
	# once, becomes the last item, and is the facing tile.
	var count_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var counted: Dictionary = state.source_beam_drill_update_facing_state(count_frame, 0, 2, 5, 3, null, copper_lookup)
	var counted_facing: Array = counted.get("facing", [])
	proof["update_facing_counts_solid_drop"] = int(counted.get("facing_amount", -1)) == 1 and str(counted.get("last_item", "")) == "copper" and counted_facing[0] == copper_tile and counted_facing[1] == null

	# A solid wall whose drop is harder than the tier
	# counts nothing and still stops the ray.
	var titanium_tile: Dictionary = {"solid": true, "wall_drop": "titanium", "wall_drop_hardness": 5.0}
	var titanium_world: Dictionary = {"12,10": titanium_tile}
	var titanium_lookup: Callable = func(rx: int, ry: int) -> Variant: return titanium_world.get("%d,%d" % [rx, ry], null)
	var hard_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var hard: Dictionary = state.source_beam_drill_update_facing_state(hard_frame, 0, 2, 5, 3, null, titanium_lookup)
	var hard_facing: Array = hard.get("facing", [])
	proof["update_facing_ignores_hard_drop"] = int(hard.get("facing_amount", -1)) == 0 and hard.get("last_item", "x") == null and hard_facing[0] == null

	# A blocked drop counts nothing even when mineable.
	var blocked_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var blocked: Dictionary = state.source_beam_drill_update_facing_state(blocked_frame, 0, 2, 5, 3, ["copper"], copper_lookup)
	var blocked_facing: Array = blocked.get("facing", [])
	proof["update_facing_ignores_blocked_drop"] = int(blocked.get("facing_amount", -1)) == 0 and blocked.get("last_item", "x") == null and blocked_facing[0] == null

	# A non-solid tile does NOT stop the ray: the scan
	# continues to the solid copper wall behind it.
	var air_tile: Dictionary = {"solid": false, "wall_drop": null, "wall_drop_hardness": 0.0}
	var skip_world: Dictionary = {"12,10": air_tile, "13,10": copper_tile}
	var skip_lookup: Callable = func(rx: int, ry: int) -> Variant: return skip_world.get("%d,%d" % [rx, ry], null)
	var skip_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var skipped: Dictionary = state.source_beam_drill_update_facing_state(skip_frame, 0, 2, 5, 3, null, skip_lookup)
	var skipped_facing: Array = skipped.get("facing", [])
	proof["update_facing_skips_non_solid"] = int(skipped.get("facing_amount", -1)) == 1 and str(skipped.get("last_item", "")) == "copper" and skipped_facing[0] == copper_tile

	# The first solid tile stops the ray even when its
	# drop is null: the copper wall behind it is never
	# reached.
	var bare_tile: Dictionary = {"solid": true, "wall_drop": null, "wall_drop_hardness": 0.0}
	var stop_world: Dictionary = {"12,10": bare_tile, "13,10": copper_tile}
	var stop_lookup: Callable = func(rx: int, ry: int) -> Variant: return stop_world.get("%d,%d" % [rx, ry], null)
	var stop_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var stopped: Dictionary = state.source_beam_drill_update_facing_state(stop_frame, 0, 2, 5, 3, null, stop_lookup)
	var stopped_facing: Array = stopped.get("facing", [])
	proof["update_facing_stops_at_first_solid"] = int(stopped.get("facing_amount", -1)) == 0 and stopped.get("last_item", "x") == null and stopped_facing[0] == null

	# Two different drops count twice, but the multiple
	# rule clears the last item.
	var lead_tile: Dictionary = {"solid": true, "wall_drop": "lead", "wall_drop_hardness": 2.0}
	var two_world: Dictionary = {"12,10": copper_tile, "12,11": lead_tile}
	var two_lookup: Callable = func(rx: int, ry: int) -> Variant: return two_world.get("%d,%d" % [rx, ry], null)
	var two_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var two: Dictionary = state.source_beam_drill_update_facing_state(two_frame, 0, 2, 5, 3, null, two_lookup)
	var two_facing: Array = two.get("facing", [])
	proof["update_facing_multiple_clears_last_item"] = int(two.get("facing_amount", -1)) == 2 and two.get("last_item", "x") == null and two_facing[0] == copper_tile and two_facing[1] == lead_tile

	# The same drop on both rays counts twice and keeps
	# the last item.
	var same_world: Dictionary = {"12,10": copper_tile, "12,11": copper_tile}
	var same_lookup: Callable = func(rx: int, ry: int) -> Variant: return same_world.get("%d,%d" % [rx, ry], null)
	var same_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var same: Dictionary = state.source_beam_drill_update_facing_state(same_frame, 0, 2, 5, 3, null, same_lookup)
	var same_facing: Array = same.get("facing", [])
	proof["update_facing_same_drop_keeps_last_item"] = int(same.get("facing_amount", -1)) == 2 and str(same.get("last_item", "")) == "copper" and same_facing[0] == copper_tile and same_facing[1] == copper_tile

	# A world with no tiles anywhere is safe: nothing
	# counts, nothing faces, nothing crashes.
	var empty_world: Dictionary = {}
	var empty_lookup: Callable = func(rx: int, ry: int) -> Variant: return empty_world.get("%d,%d" % [rx, ry], null)
	var empty_frame: Dictionary = {"lasers": [Vector2i(12, 10), Vector2i(12, 11)]}
	var empty: Dictionary = state.source_beam_drill_update_facing_state(empty_frame, 0, 2, 5, 3, null, empty_lookup)
	var empty_facing: Array = empty.get("facing", [])
	proof["update_facing_null_tile_safe"] = int(empty.get("facing_amount", -1)) == 0 and empty.get("last_item", "x") == null and empty_facing == [null, null]

	# Each result carries ONLY its own keys.
	proof["returns_only_four_keys"] = entry.size() == 4 and filled.size() == 1 and counted.size() == 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillUpdateFacingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
