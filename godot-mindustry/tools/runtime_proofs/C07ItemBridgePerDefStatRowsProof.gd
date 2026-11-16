extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- Per-def stat rows (N2493): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2490
	# precedent). The single ItemBridge def
	# phase-conveyor (Blocks.java:2116-2125) sets
	# range 12, transportTime 2f, arrowPeriod 0.9f,
	# arrowTimeScl 2.75f and requirements
	# phase-fabric 5 / silicon 7 / lead 10 /
	# graphite 10; size 1 comes from the Block
	# class default (Block.java:215) -- the def
	# block sets NO size. An unknown def id falls
	# back to the CLASS defaults (the N2304
	# fallback precedent): size 1 (Block.java:215),
	# range 0 (ItemBridge.java:27, no initializer),
	# transportTime 0f (ItemBridge.java:28, no
	# initializer), arrowPeriod 0.4f
	# (ItemBridge.java:37), arrowTimeScl 6.2f
	# (ItemBridge.java:38) and NO requirements
	# (the Block default is the empty array,
	# Block.java:356). Pure-only: the caller reads
	# it; the advance + draw + linkValid pures
	# take these values as caller-supplied inputs
	# and are unchanged.

	# --- Def row: phase-conveyor -- size 1, range
	# 12, transportTime 2f, arrowPeriod 0.9f,
	# arrowTimeScl 2.75f, requirements phase-fabric
	# 5 / silicon 7 / lead 10 / graphite 10.
	var bridge: Dictionary = item_bridge_build_state.source_item_bridge_per_def_stats_state("phase-conveyor")
	var bridge_requirements: Dictionary = bridge.get("requirements", {})
	proof["stats_bridge"] = int(bridge.get("size", -1)) == 1 and int(bridge.get("range_value", -1)) == 12 and is_equal_approx(float(bridge.get("transport_time", -1.0)), 2.0) and is_equal_approx(float(bridge.get("arrow_period", -1.0)), 0.9) and is_equal_approx(float(bridge.get("arrow_time_scl", -1.0)), 2.75) and int(bridge_requirements.get("phase-fabric", -1)) == 5 and int(bridge_requirements.get("silicon", -1)) == 7 and int(bridge_requirements.get("lead", -1)) == 10 and int(bridge_requirements.get("graphite", -1)) == 10

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, range 0, transportTime 0f,
	# arrowPeriod 0.4f, arrowTimeScl 6.2f, and NO
	# requirements.
	var fallback: Dictionary = item_bridge_build_state.source_item_bridge_per_def_stats_state("no-such-def")
	var empty_fallback: Dictionary = item_bridge_build_state.source_item_bridge_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and int(fallback.get("range_value", -1)) == 0 and is_equal_approx(float(fallback.get("transport_time", -1.0)), 0.0) and is_equal_approx(float(fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(fallback.get("arrow_time_scl", -1.0)), 6.2) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and int(empty_fallback.get("range_value", -1)) == 0 and is_equal_approx(float(empty_fallback.get("transport_time", -1.0)), 0.0) and is_equal_approx(float(empty_fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(empty_fallback.get("arrow_time_scl", -1.0)), 6.2) and empty_requirements.is_empty()

	# --- Range / transport time: the def links
	# 12 cells out and moves an item in 2f, while
	# the class defaults link 0 cells (range has
	# no initializer) and move in 0f.
	proof["stats_range_time"] = int(bridge.get("range_value", -1)) == 12 and is_equal_approx(float(bridge.get("transport_time", -1.0)), 2.0) and int(fallback.get("range_value", -1)) == 0 and is_equal_approx(float(fallback.get("transport_time", -1.0)), 0.0)

	# --- Arrows: the def draws arrows at period
	# 0.9f / time scale 2.75f while the class
	# defaults draw at 0.4f / 6.2f -- the def
	# overrides BOTH class fields.
	proof["stats_arrows"] = is_equal_approx(float(bridge.get("arrow_period", -1.0)), 0.9) and is_equal_approx(float(bridge.get("arrow_time_scl", -1.0)), 2.75) and is_equal_approx(float(fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(fallback.get("arrow_time_scl", -1.0)), 6.2)

	# --- Requirements: the def dict carries
	# exactly the four items (phase-fabric 5,
	# silicon 7, lead 10, graphite 10); the class
	# fallback carries none.
	proof["stats_requirements"] = bridge_requirements.size() == 4 and int(bridge_requirements.get("phase-fabric", -1)) == 5 and int(bridge_requirements.get("silicon", -1)) == 7 and int(bridge_requirements.get("lead", -1)) == 10 and int(bridge_requirements.get("graphite", -1)) == 10 and fallback_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2197 linkValid pure as its caller-supplied
	# range -- a partner 12 cells out on the same
	# column links under the def range 12 but not
	# under the class range 0.
	var def_link: Dictionary = item_bridge_build_state.source_item_bridge_link_valid_state(0, 0, 0, 12, int(bridge.get("range_value", 0)), true, true, -1, 0, true, true)
	var fallback_link: Dictionary = item_bridge_build_state.source_item_bridge_link_valid_state(0, 0, 0, 12, int(fallback.get("range_value", 0)), true, true, -1, 0, true, true)
	proof["stats_live_input"] = bool(def_link.get("had_valid_link", false)) == true and bool(fallback_link.get("had_valid_link", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgePerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
