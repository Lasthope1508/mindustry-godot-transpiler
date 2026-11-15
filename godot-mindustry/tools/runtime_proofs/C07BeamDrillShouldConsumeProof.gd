extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- Pure gate (N2202): BeamDrillBuild.shouldConsume()
	# (BeamDrill.java:270, `public boolean shouldConsume(){`
	# with `return items.total() < itemCapacity && facingAmount
	# > 0 && enabled;`, BeamDrill.java:271) is a three-way
	# conjunction: the item store under capacity, at least one
	# facing wall-ore tile, and enabled. All three halves are
	# proven -- a full store, no facing ore, and a disabled
	# drill each close the gate on their own. The capacity is
	# the plasma-bore's 10 (the Block.java:75 field default,
	# `public int itemCapacity = 10;`); the large-plasma-bore's
	# 20 (Blocks.java:3062) takes the same pure path through the
	# catalog. The gate reads the current frame: the live
	# facing scan (updateFacing, BeamDrill.java:375-410) and the
	# production advance that fills the store
	# (BeamDrill.java:253-261) wait for their own slices, so the
	# proof sets facing_amount and items on the frame directly.
	var all_three: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state({"items": {"beryllium": 5}, "facing_amount": 2, "enabled": true}, 10)
	proof["gate_true_when_all_three_conditions"] = bool(all_three.get("should_consume", false)) and int(all_three.get("items_total", -1)) == 5 and int(all_three.get("facing_amount", -1)) == 2

	var full_gate: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state({"items": {"beryllium": 10}, "facing_amount": 2, "enabled": true}, 10)
	proof["gate_false_when_items_full"] = bool(full_gate.get("should_consume", true)) == false and int(full_gate.get("items_total", -1)) == 10

	var no_facing_gate: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state({"items": {}, "facing_amount": 0, "enabled": true}, 10)
	proof["gate_false_when_no_facing"] = bool(no_facing_gate.get("should_consume", true)) == false and int(no_facing_gate.get("facing_amount", -1)) == 0

	var disabled_gate: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state({"items": {}, "facing_amount": 2, "enabled": false}, 10)
	proof["gate_false_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and int(disabled_gate.get("facing_amount", -1)) == 2

	# --- Live tick: the plasma-bore is a BeamDrill with a power
	# consumer (consumePower 0.15f), placed live; the tick
	# driver is called directly (as the N2155 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. With facing ore and room in the
	# store the gate is true, so the N2155 power fold is
	# preserved -- efficiency folds the power min 0.5. With no
	# facing ore the gate is false, so efficiency folds to 0
	# even at full power -- the N2155 gap (efficiency 1.0 vs
	# Java 0.0) is closed.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var drill_cell := Vector2i(28, 20)
	var drill := Sprite2D.new()
	game.add_child(drill)
	game.call("record_placed_block", drill, blocks_by_id["plasma-bore"], drill_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and the
	# gate inputs on it).
	beam_drill_build_state.source_beam_drill_bind_frame_state(drill, blocks_by_id["plasma-bore"])
	var drill_frame: Dictionary = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})

	# Gate true (facing ore, room in the store): efficiency
	# folds the power min 0.5.
	drill_frame["power_status"] = 0.5
	drill_frame["facing_amount"] = 2
	drill_frame["items"] = {}
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 0.5)

	# Gate false (no facing ore): efficiency 0 even at full
	# power.
	drill_frame["power_status"] = 1.0
	drill_frame["facing_amount"] = 0
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
