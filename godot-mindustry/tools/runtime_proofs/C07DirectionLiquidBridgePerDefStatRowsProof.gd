extends Node

const main_scene := preload("res://scenes/Main.tscn")
const direction_liquid_bridge_build_state := preload("res://src/game/SourceDirectionLiquidBridgeBuildState.gd")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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

	# --- Per-def stat rows (N2502): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2489 /
	# N2490 precedent). This slice CREATES the
	# family's driver: the port had NO
	# SourceDirectionLiquidBridge* files at all.
	# The reinforced-bridge-conduit def
	# (Blocks.java:2432-2443) sets range 4,
	# liquidCapacity 120f, health 250 and
	# requirements graphite 8 / beryllium 20;
	# size 1 is the inherited Block default (the
	# def sets NO size line) and speed 5f is the
	# class field (the def sets NO speed line).
	# An unknown def id falls back to the CLASS
	# defaults (the N2304 fallback precedent):
	# size 1 (Block.java:215), range 4
	# (DirectionBridge.java:31 -- the def
	# restates the class value), liquidCapacity
	# 20f (the CONSTRUCTOR value,
	# DirectionLiquidBridge.java:26, which
	# survives Block.init() because the replace
	# only runs under `if(liquidCapacity < 0){`,
	# Block.java:1407), health 40 post-init (the
	# -1 sentinel, Block.java:190, resolved by
	# init() with scaledHealth 40,
	# Block.java:1378-1395 -- the N2495 / N2496
	# / N2497 coordinator decision), speed 5f
	# (DirectionLiquidBridge.java:15) and NO
	# requirements (the Block default is the
	# empty array, Block.java:356). Pure-only:
	# the caller reads it; the tick / advance /
	# shouldConsume pures do not exist yet for
	# this family.

	# --- Def row: reinforced-bridge-conduit --
	# size 1, range 4, liquidCapacity 120f,
	# health 250, speed 5f, requirements
	# graphite 8 / beryllium 20.
	var bridge: Dictionary = direction_liquid_bridge_build_state.source_direction_liquid_bridge_per_def_stats_state("reinforced-bridge-conduit")
	var bridge_requirements: Dictionary = bridge.get("requirements", {})
	proof["stats_bridge"] = int(bridge.get("size", -1)) == 1 and int(bridge.get("range_value", -1)) == 4 and is_equal_approx(float(bridge.get("liquid_capacity", -1.0)), 120.0) and int(bridge.get("health", -1)) == 250 and is_equal_approx(float(bridge.get("speed", -1.0)), 5.0) and int(bridge_requirements.get("graphite", -1)) == 8 and int(bridge_requirements.get("beryllium", -1)) == 20

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, range 4, liquidCapacity 20f,
	# health 40, speed 5f, and NO requirements.
	var fallback: Dictionary = direction_liquid_bridge_build_state.source_direction_liquid_bridge_per_def_stats_state("no-such-def")
	var empty_fallback: Dictionary = direction_liquid_bridge_build_state.source_direction_liquid_bridge_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and int(fallback.get("range_value", -1)) == 4 and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 20.0) and int(fallback.get("health", -1)) == 40 and is_equal_approx(float(fallback.get("speed", -1.0)), 5.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and int(empty_fallback.get("range_value", -1)) == 4 and is_equal_approx(float(empty_fallback.get("liquid_capacity", -1.0)), 20.0) and int(empty_fallback.get("health", -1)) == 40 and is_equal_approx(float(empty_fallback.get("speed", -1.0)), 5.0) and empty_requirements.is_empty()

	# --- Range / capacity: the def links 4 tiles
	# and holds 120f while the class defaults
	# link 4 tiles and hold 20f -- the def
	# restates the class range but overrides the
	# capacity.
	proof["stats_range_capacity"] = int(bridge.get("range_value", -1)) == 4 and is_equal_approx(float(bridge.get("liquid_capacity", -1.0)), 120.0) and int(fallback.get("range_value", -1)) == 4 and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 20.0)

	# --- Health / speed: the def has 250 health
	# at speed 5f while the class defaults have
	# 40 post-init health at the same speed 5f --
	# the def overrides health only.
	proof["stats_health_speed"] = int(bridge.get("health", -1)) == 250 and is_equal_approx(float(bridge.get("speed", -1.0)), 5.0) and int(fallback.get("health", -1)) == 40 and is_equal_approx(float(fallback.get("speed", -1.0)), 5.0)

	# --- Requirements: the def dict carries
	# exactly the two items (graphite 8,
	# beryllium 20); the class fallback carries
	# none.
	proof["stats_requirements"] = bridge_requirements.size() == 2 and int(bridge_requirements.get("graphite", -1)) == 8 and int(bridge_requirements.get("beryllium", -1)) == 20 and fallback_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2275 transport pure as its caller-supplied
	# liquid_capacity -- a warm bridge holding 50
	# of liquid 0 against an empty partner moves
	# 50.0 at the def capacity 120f (fract 0.42)
	# but only 20.0 at the class capacity 20f
	# (fract 2.5, clamped to 1.0, times 20f).
	# This driver has no live advance yet, so the
	# cross-driver feed is a proof-only
	# composition: the N2275 LiquidBridge pure
	# consumes range/liquidCapacity the same way
	# (BuildingComp.java:944-947), and the
	# DirectionLiquidBridge advance will take
	# these rows as caller-supplied inputs when
	# it lands.
	var frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "moved": false}
	var liquids: Dictionary = {"current": 0, "liquids": [50.0]}
	var def_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": float(bridge.get("liquid_capacity", 0.0)), "liquids": {"current": 0, "liquids": [0.0]}}
	var fallback_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": float(fallback.get("liquid_capacity", 0.0)), "liquids": {"current": 0, "liquids": [0.0]}}
	var def_advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(frame, 1.0, float(bridge.get("liquid_capacity", 0.0)), 1.0, true, liquids, def_partner)
	var fallback_advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(frame, 1.0, float(fallback.get("liquid_capacity", 0.0)), 1.0, true, liquids, fallback_partner)
	proof["stats_live_input"] = is_equal_approx(float(def_advanced.get("flow", -1.0)), 50.0) and is_equal_approx(float(fallback_advanced.get("flow", -1.0)), 20.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DirectionLiquidBridgePerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
