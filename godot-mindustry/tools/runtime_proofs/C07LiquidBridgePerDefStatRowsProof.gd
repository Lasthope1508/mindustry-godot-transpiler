extends Node

const main_scene := preload("res://scenes/Main.tscn")
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

	# --- Per-def stat rows (N2494): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2489 /
	# N2490 precedent). The phase-conduit def
	# (Blocks.java:2385-2397) sets range 12,
	# liquidCapacity 100f, arrowPeriod 0.9f,
	# arrowTimeScl 2.75f and requirements
	# phase-fabric 5 / silicon 7 / metaglass 20 /
	# titanium 10; size 1 is the inherited Block
	# default (the def sets NO size line). An
	# unknown def id falls back to the CLASS
	# defaults (the N2304 fallback precedent):
	# size 1 (Block.java:215), range 0
	# (ItemBridge.java:27 has NO initializer),
	# liquidCapacity 10f (the -1f field,
	# Block.java:77, is a sentinel Block.init()
	# replaces with round(10f * consumeAmount),
	# Block.java:1418 -- consumeAmount stays 1f,
	# LiquidBridge has no liquid consumers),
	# arrowPeriod 0.4f (ItemBridge.java:37),
	# arrowTimeScl 6.2f (ItemBridge.java:38) and
	# NO requirements (the Block default is the
	# empty array, Block.java:356). Pure-only: the
	# caller reads it; the advance + shouldConsume
	# pures take these values as caller-supplied
	# inputs and are unchanged.

	# --- Def row: phase-conduit -- size 1, range
	# 12, liquidCapacity 100f, arrowPeriod 0.9f,
	# arrowTimeScl 2.75f, requirements phase-fabric
	# 5 / silicon 7 / metaglass 20 / titanium 10.
	var bridge: Dictionary = liquid_bridge_build_state.source_liquid_bridge_per_def_stats_state("phase-conduit")
	var bridge_requirements: Dictionary = bridge.get("requirements", {})
	proof["stats_bridge"] = int(bridge.get("size", -1)) == 1 and int(bridge.get("range", -1)) == 12 and is_equal_approx(float(bridge.get("liquid_capacity", -1.0)), 100.0) and is_equal_approx(float(bridge.get("arrow_period", -1.0)), 0.9) and is_equal_approx(float(bridge.get("arrow_time_scl", -1.0)), 2.75) and int(bridge_requirements.get("phase-fabric", -1)) == 5 and int(bridge_requirements.get("silicon", -1)) == 7 and int(bridge_requirements.get("metaglass", -1)) == 20 and int(bridge_requirements.get("titanium", -1)) == 10

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, range 0, liquidCapacity 10f,
	# arrowPeriod 0.4f, arrowTimeScl 6.2f, and NO
	# requirements.
	var fallback: Dictionary = liquid_bridge_build_state.source_liquid_bridge_per_def_stats_state("no-such-def")
	var empty_fallback: Dictionary = liquid_bridge_build_state.source_liquid_bridge_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and int(fallback.get("range", -1)) == 0 and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 10.0) and is_equal_approx(float(fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(fallback.get("arrow_time_scl", -1.0)), 6.2) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and int(empty_fallback.get("range", -1)) == 0 and is_equal_approx(float(empty_fallback.get("liquid_capacity", -1.0)), 10.0) and is_equal_approx(float(empty_fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(empty_fallback.get("arrow_time_scl", -1.0)), 6.2) and empty_requirements.is_empty()

	# --- Range / capacity: the def links 12 tiles
	# and holds 100f while the class defaults link
	# 0 tiles and hold 10f -- the def overrides
	# BOTH class fields.
	proof["stats_range_capacity"] = int(bridge.get("range", -1)) == 12 and is_equal_approx(float(bridge.get("liquid_capacity", -1.0)), 100.0) and int(fallback.get("range", -1)) == 0 and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 10.0)

	# --- Arrows: the def draws arrows at period
	# 0.9f / time scale 2.75f while the class
	# defaults draw them at 0.4f / 6.2f.
	proof["stats_arrows"] = is_equal_approx(float(bridge.get("arrow_period", -1.0)), 0.9) and is_equal_approx(float(bridge.get("arrow_time_scl", -1.0)), 2.75) and is_equal_approx(float(fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(fallback.get("arrow_time_scl", -1.0)), 6.2)

	# --- Requirements: the def dict carries
	# exactly the four items (phase-fabric 5,
	# silicon 7, metaglass 20, titanium 10); the
	# class fallback carries none.
	proof["stats_requirements"] = bridge_requirements.size() == 4 and int(bridge_requirements.get("phase-fabric", -1)) == 5 and int(bridge_requirements.get("silicon", -1)) == 7 and int(bridge_requirements.get("metaglass", -1)) == 20 and int(bridge_requirements.get("titanium", -1)) == 10 and fallback_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2275 transport pure as its caller-supplied
	# liquid_capacity -- a warm bridge holding 50
	# of liquid 0 against an empty partner moves
	# 50.0 at the def capacity 100f (fract 0.5)
	# but only 10.0 at the class capacity 10f
	# (fract 5.0, clamped to 1.0, times 10f).
	var frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "moved": false}
	var liquids: Dictionary = {"current": 0, "liquids": [50.0]}
	var def_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": float(bridge.get("liquid_capacity", 0.0)), "liquids": {"current": 0, "liquids": [0.0]}}
	var fallback_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": float(fallback.get("liquid_capacity", 0.0)), "liquids": {"current": 0, "liquids": [0.0]}}
	var def_advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(frame, 1.0, float(bridge.get("liquid_capacity", 0.0)), 1.0, true, liquids, def_partner)
	var fallback_advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(frame, 1.0, float(fallback.get("liquid_capacity", 0.0)), 1.0, true, liquids, fallback_partner)
	proof["stats_live_input"] = is_equal_approx(float(def_advanced.get("flow", -1.0)), 50.0) and is_equal_approx(float(fallback_advanced.get("flow", -1.0)), 10.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgePerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
