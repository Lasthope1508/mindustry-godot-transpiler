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

	# --- Per-def stat rows (N2496): StackRouter.
	# The single StackRouter def surge-router
	# (Blocks.java:2255-2268) sets speed 6f /
	# health 130 / requirements surge-alloy 5 /
	# tungsten 1, and NO size / itemCapacity /
	# glow lines, so those take the class values:
	# size 1 (Block.java:215), itemCapacity 10
	# (StackRouter.java:20), glowAlpha 1f /
	# glowColor Pal.redLight (StackRouter.java:
	# 15-16). The class defaults are size 1 /
	# speed 5f (DuctRouter.java:19) /
	# itemCapacity 10 / health 40 init-resolved
	# (the class field is the -1 sentinel,
	# Block.java:190, resolved by init(),
	# Block.java:1378-1394, to Mathf.round(1 *
	# 1 * 40, 5) = 40 for size 1 with no
	# requirements) / glowAlpha 1f / glowColor
	# Pal.redLight / no requirements. The stat
	# anchor is setStats() (DuctRouter.java:
	# 48-52, inherited): `stats.add(
	# Stat.itemsMoved, 60f / speed *
	# itemCapacity, StatUnit.itemsSecond);` --
	# 60/6*10 = 100 items/s for surge-router,
	# 60/5*10 = 120 at the class defaults. The
	# pure returns the def's seven rows; an
	# unknown def id falls back to the CLASS
	# defaults (the N2304 fallback precedent).
	#
	# Fixture: the pure takes the catalog def id
	# ("surge-router") and returns {size, speed,
	# item_capacity, health, glow_alpha,
	# glow_color, requirements} as data.
	# Pure-only: the tick never calls it -- the
	# advance / draw / stats pures take these
	# values as caller-supplied inputs, and the
	# live-input keys below compose them.

	# --- Router row: surge-router reads size 1
	# / speed 6.0 / itemCapacity 10 / health
	# 130 / glowAlpha 1.0 / glowColor
	# Pal.redLight / requirements surge-alloy 5
	# / tungsten 1 (Blocks.java:2255-2268).
	var router: Dictionary = stack_router_build_state.source_stack_router_per_def_stats_state("surge-router")
	var router_requirements: Dictionary = router.get("requirements", {})
	proof["stats_router"] = int(router.get("size", -1)) == 1 and float(router.get("speed", -1.0)) == 6.0 and int(router.get("item_capacity", -1)) == 10 and int(router.get("health", -1)) == 130 and float(router.get("glow_alpha", -1.0)) == 1.0 and str(router.get("glow_color", "")) == "Pal.redLight" and router_requirements.size() == 2 and int(router_requirements.get("surge-alloy", -1)) == 5 and int(router_requirements.get("tungsten", -1)) == 1

	# --- Class fallback: an unknown def id (and
	# the empty id) reads the CLASS defaults --
	# size 1 / speed 5.0 / itemCapacity 10 /
	# health 40 init-resolved / glowAlpha 1.0 /
	# glowColor Pal.redLight / no requirements
	# -- the N2304 fallback precedent. The
	# health is the init-resolved 40, NOT the
	# -1 class-field sentinel.
	var fallback: Dictionary = stack_router_build_state.source_stack_router_per_def_stats_state("unknown-def")
	var empty: Dictionary = stack_router_build_state.source_stack_router_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and float(fallback.get("speed", -1.0)) == 5.0 and int(fallback.get("item_capacity", -1)) == 10 and int(fallback.get("health", -1)) == 40 and float(fallback.get("glow_alpha", -1.0)) == 1.0 and str(fallback.get("glow_color", "")) == "Pal.redLight" and fallback_requirements.is_empty() and int(empty.get("size", -1)) == 1 and float(empty.get("speed", -1.0)) == 5.0 and int(empty.get("item_capacity", -1)) == 10 and int(empty.get("health", -1)) == 40 and float(empty.get("glow_alpha", -1.0)) == 1.0 and str(empty.get("glow_color", "")) == "Pal.redLight" and empty_requirements.is_empty()

	# --- Speed / capacity rows: the setStats
	# rows (DuctRouter.java:51) read off the
	# pure's values -- 60 / speed * itemCapacity
	# items per second: 60/6*10 = 100.0 for
	# surge-router, 60/5*10 = 120.0 at the class
	# defaults (the N2442 stats pure).
	var router_stats: Dictionary = stack_router_build_state.source_stack_router_stats_state(float(router.get("speed", 0.0)), int(router.get("item_capacity", 0)))
	var fallback_stats: Dictionary = stack_router_build_state.source_stack_router_stats_state(float(fallback.get("speed", 0.0)), int(fallback.get("item_capacity", 0)))
	proof["stats_speed_capacity"] = float(router_stats.get("items_moved_per_second", -1.0)) == 100.0 and float(fallback_stats.get("items_moved_per_second", -1.0)) == 120.0

	# --- Health / glow rows: the def health is
	# 130 vs the class-resolved 40, and the
	# glow rows feed the N2433 draw pure as its
	# caller-supplied inputs -- at power.status
	# 1.0 the glow call carries alpha glowAlpha
	# * power.status = 1.0 in Pal.redLight, and
	# at power.status 0.5 the folded alpha is
	# 0.5 (StackRouter.java:81, `Draw.color(
	# glowColor, glowAlpha * power.status);`).
	var drawn: Dictionary = stack_router_build_state.source_stack_router_draw_state(0.0, 0.0, 0, null, 1.0, true, str(router.get("glow_color", "")), float(router.get("glow_alpha", 0.0)))
	var drawn_half: Dictionary = stack_router_build_state.source_stack_router_draw_state(0.0, 0.0, 0, null, 0.5, true, str(router.get("glow_color", "")), float(router.get("glow_alpha", 0.0)))
	var glow_call: Dictionary = drawn.get("glow_call", {})
	proof["stats_health_glow"] = int(router.get("health", -1)) == 130 and int(fallback.get("health", -1)) == 40 and float(drawn.get("glow_alpha_value", -1.0)) == 1.0 and float(drawn_half.get("glow_alpha_value", -1.0)) == 0.5 and float(glow_call.get("alpha", -1.0)) == 1.0 and str(glow_call.get("color", "")) == "Pal.redLight" and str(glow_call.get("region", "")) == "glowRegion"

	# --- Requirements: the def dict carries
	# exactly the two items (surge-alloy 5,
	# tungsten 1); the class fallback carries
	# none (the Block default is the empty
	# array, Block.java:356).
	proof["stats_requirements"] = router_requirements.size() == 2 and int(router_requirements.get("surge-alloy", -1)) == 5 and int(router_requirements.get("tungsten", -1)) == 1 and fallback_requirements.is_empty()

	# --- Live input: the pure's speed /
	# itemCapacity feed the N2240 advance pure
	# as its caller-supplied inputs -- a full
	# router (10 surge-alloy, current
	# surge-alloy, progress 5.0) with efficiency
	# 1.0 and the def baseEfficiency 1.0
	# (Blocks.java:2265) charges eff 2.0, so
	# progress 5.0 + 2.0 = 7.0 crosses the cap
	# (speed 6.0) and unloading starts with
	# progress fmod(7.0, 6.0) = 1.0, no handoff
	# with no targets (StackRouter.java:30-42).
	var frame: Dictionary = {"enabled": true, "efficiency": 1.0, "unloading": false, "current": "surge-alloy", "progress": 5.0, "items": {"surge-alloy": 10}}
	var advanced: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state(frame, float(router.get("speed", 0.0)), 1.0, int(router.get("item_capacity", 0)), [], ["surge-alloy"])
	proof["stats_live_input"] = bool(advanced.get("unloading", false)) and float(advanced.get("progress", -1.0)) == 1.0 and int(advanced.get("handed_off", -1)) == 0 and str(advanced.get("current", "")) == "surge-alloy"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
