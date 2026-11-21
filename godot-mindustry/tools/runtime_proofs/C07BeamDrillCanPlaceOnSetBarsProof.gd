extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _place_case(world: Dictionary, rotation: int = 0, blocked_items: Variant = null) -> Dictionary:
	var world_tile: Callable = func(rx: int, ry: int) -> Variant:
		return world.get("%d,%d" % [rx, ry], null)
	return state.source_beam_drill_can_place_on_state({}, 10, 10, rotation, 2, 5, 3, blocked_items, world_tile)


func _bars_case(last_drill_speed: float, warmup: float) -> Dictionary:
	return state.source_beam_drill_set_bars_state({}, null, last_drill_speed, warmup)


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

	# --- BeamDrill.canPlaceOn() + setBars() (N2391):
	# BeamDrill.canPlaceOn() (BeamDrill.java:198-214) scans
	# one ray per footprint side (nearbySide + world.tile)
	# and returns true on the first mineable wall drop
	# (hardness <= tier, not blocked). BeamDrill.setBars()
	# (BeamDrill.java:90-97) adds the drillspeed bar: key
	# "drillspeed", text Core.bundle.format("bar.drillspeed",
	# Strings.fixed(lastDrillSpeed * 60, 2)), color Pal.ammo,
	# fraction warmup. The proof drives the pure functions
	# with synthetic worlds (no live tick): plasma-bore
	# defaults (tier 3, size 2, range 5, Blocks.java:3038-3051),
	# placement at tile (10, 10) rotation 0, so the two sides
	# are (12, 10) and (12, 11) and the rays run +x; rotation 1
	# puts the sides at (10, 12) and (11, 12) with rays running
	# +y. Copper hardness 1 and lead hardness 2 are mineable
	# at tier 3; thorium hardness 4 is not. NO driver tick
	# line: canPlaceOn is a placement predicate, setBars is a
	# load-time bar spec.

	# Copper on the first side: true at once.
	var mineable: Dictionary = _place_case({"12,10": _tile("copper", 1.0)})
	proof["mineable_first_side_true"] = bool(mineable.get("can_place_on", false))

	# Empty world: no side finds anything.
	var empty: Dictionary = _place_case({})
	proof["no_mineable_false"] = not bool(empty.get("can_place_on", true))

	# Only thorium (hardness 4 > tier 3) on both sides: the
	# drops are invalid, each ray stops at its first solid
	# tile, and the answer stays false.
	var hard_world: Dictionary = {"12,10": _tile("thorium", 4.0), "12,11": _tile("thorium", 4.0)}
	var too_hard: Dictionary = _place_case(hard_world)
	proof["too_hard_false"] = not bool(too_hard.get("can_place_on", true))

	# A blocked drop counts as invalid, not as found.
	var blocked: Dictionary = _place_case({"12,10": _tile("copper", 1.0)}, 0, ["copper"])
	proof["blocked_false"] = not bool(blocked.get("can_place_on", true))

	# A non-solid tile does NOT stop the ray: the copper
	# behind it at j = 1 is found.
	var floor_world: Dictionary = {"12,10": _tile(null, 0.0, false), "13,10": _tile("copper", 1.0)}
	var floor_case: Dictionary = _place_case(floor_world)
	proof["non_solid_does_not_stop_ray"] = bool(floor_case.get("can_place_on", false))

	# The copper wall sits two steps out: the ray steps
	# past the empty tiles and finds it at j = 2.
	var deep_world: Dictionary = {"14,10": _tile("copper", 1.0)}
	var deep: Dictionary = _place_case(deep_world)
	proof["scan_steps_to_deeper_drop"] = bool(deep.get("can_place_on", false))

	# Rotation changes the ray: with rotation 1 the sides
	# are (10, 12) and (11, 12) and the rays run +y, so the
	# copper at (10, 13) is found at j = 1; the same world
	# with rotation 0 never looks there.
	var rotated_world: Dictionary = {"10,13": _tile("copper", 1.0)}
	var rotated: Dictionary = _place_case(rotated_world, 1)
	var unrotated: Dictionary = _place_case(rotated_world, 0)
	proof["rotation_changes_ray"] = bool(rotated.get("can_place_on", false)) and not bool(unrotated.get("can_place_on", true))

	# The bar text is "Drill Speed: {rate}/s" with the rate
	# lastDrillSpeed * 60 at 2 decimals: 0.5 * 60 = 30.00.
	var bars: Dictionary = _bars_case(0.5, 0.75)
	proof["bar_text_format"] = bars.get("bar_key", "") == "drillspeed" and bars.get("bar_text", "") == "Drill Speed: 30.00/s"

	# Strings.fixed truncates, it does not round: 0.12345
	# * 60 = 7.407 becomes "7.40", not "7.41".
	var trunc_bars: Dictionary = _bars_case(0.12345, 0.5)
	proof["bar_text_truncates"] = trunc_bars.get("bar_text", "") == "Drill Speed: 7.40/s"

	# The bar color is Pal.ammo (Color "ff8947").
	proof["bar_color_ammo"] = bars.get("bar_color", Color.BLACK) == Color("ff8947")

	# The bar fraction is the warmup value itself (the
	# clamp to 0..1 happens Bar-side, not here).
	proof["bar_fraction_warmup"] = is_equal_approx(float(bars.get("bar_fraction", -1.0)), 0.75)

	# Each result carries ONLY its own keys.
	proof["returns_only_expected_keys"] = mineable.size() == 1 and bars.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillCanPlaceOnSetBarsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
