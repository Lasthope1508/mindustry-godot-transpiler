extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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

	# --- Pure gate (N2198): LiquidBridgeBuild inherits
	# ItemBridgeBuild.shouldConsume() (ItemBridge.java:495,
	# `public boolean shouldConsume(){` with `return hadValidLink
	# && enabled;`, ItemBridge.java:496) verbatim -- LiquidBridge
	# extends ItemBridge (LiquidBridge.java:7, `public class
	# LiquidBridge extends ItemBridge{`) and LiquidBridgeBuild
	# extends ItemBridgeBuild (LiquidBridge.java:19, `public class
	# LiquidBridgeBuild extends ItemBridgeBuild{`), overriding
	# only updateTransport and doDump (LiquidBridge.java:22-31).
	# The gate is a conjunction: a valid link AND enabled. Both
	# halves are proven -- a linked but disabled bridge does not
	# consume either.
	var linked_gate: Dictionary = liquid_bridge_build_state.source_liquid_bridge_should_consume_state({"had_valid_link": true, "enabled": true})
	proof["gate_true_with_valid_link"] = bool(linked_gate.get("should_consume", false)) and bool(linked_gate.get("had_valid_link", false))

	var unlinked_gate: Dictionary = liquid_bridge_build_state.source_liquid_bridge_should_consume_state({"had_valid_link": false, "enabled": true})
	proof["gate_false_when_unlinked"] = bool(unlinked_gate.get("should_consume", true)) == false and bool(unlinked_gate.get("had_valid_link", true)) == false

	var disabled_gate: Dictionary = liquid_bridge_build_state.source_liquid_bridge_should_consume_state({"had_valid_link": true, "enabled": false})
	proof["gate_false_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and bool(disabled_gate.get("had_valid_link", false))

	# --- Live tick: two phase-conduits in the same row, 3 cells
	# apart (within range 12); conduit A links to conduit B via
	# N2197's pure configure (reused, not copied), conduit B
	# stays unlinked (link -1) -- a partner that points back
	# would fail the double-link check (ItemBridge.java:154).
	# Conduit C sits far away, unlinked: its gate is false, so
	# its efficiency folds to 0 even at full power -- the N2179
	# gap (efficiency 1.0 vs Java 0.0) is closed. The tick driver
	# is called directly (as the N2179 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The gate reads the PREVIOUS
	# tick's had_valid_link: updateConsumption runs before
	# updateTile (BuildingComp.java:2274-2277), so the recompute
	# lands after the fold -- conduit A folds efficiency 0 on
	# the first tick after linking, and folds power on the
	# second. Correct per Java, not a bug.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var conduit_a_cell := Vector2i(28, 21)
	var conduit_a := Sprite2D.new()
	game.add_child(conduit_a)
	game.call("record_placed_block", conduit_a, blocks_by_id["phase-conduit"], conduit_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to configure the link on it).
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(conduit_a, blocks_by_id["phase-conduit"])
	var conduit_a_frame: Dictionary = conduit_a.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})

	var conduit_b_cell := Vector2i(31, 21)
	var conduit_b := Sprite2D.new()
	game.add_child(conduit_b)
	game.call("record_placed_block", conduit_b, blocks_by_id["phase-conduit"], conduit_b_cell)
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(conduit_b, blocks_by_id["phase-conduit"])
	var conduit_b_frame: Dictionary = conduit_b.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})

	var conduit_c_cell := Vector2i(10, 10)
	var conduit_c := Sprite2D.new()
	game.add_child(conduit_c)
	game.call("record_placed_block", conduit_c, blocks_by_id["phase-conduit"], conduit_c_cell)
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(conduit_c, blocks_by_id["phase-conduit"])
	var conduit_c_frame: Dictionary = conduit_c.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})

	# The Point2 handler is RELATIVE (ItemBridge.java:64,
	# `config(Point2.class, (ItemBridgeBuild tile, Point2 i) ->
	# tile.link = Point2.pack(i.x + tile.tileX(), i.y +
	# tile.tileY()));`): {x: 3, y: 0} from (28, 21) packs
	# (31, 21) = 31 * 65536 + 21 = 2031637.
	var point2_configured: Dictionary = item_bridge_build_state.source_item_bridge_configure_state(conduit_a_frame, {"x": 3, "y": 0}, 28, 21)
	conduit_a_frame["link"] = int(point2_configured.get("link", -1))
	conduit_a_frame["power_status"] = 0.5
	conduit_b_frame["power_status"] = 1.0
	conduit_c_frame["power_status"] = 1.0
	liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)
	conduit_a_frame = conduit_a.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	conduit_b_frame = conduit_b.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	conduit_c_frame = conduit_c.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(conduit_c_frame.get("efficiency", -1.0)), 0.0)
	var linked_tick: bool = bool(conduit_a_frame.get("had_valid_link", false)) and bool(conduit_b_frame.get("had_valid_link", true)) == false

	# Second tick: conduit A's gate now reads the recomputed
	# had_valid_link, so the N2179 power fold is preserved --
	# efficiency folds the power min 0.5.
	liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)
	conduit_a_frame = conduit_a.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(conduit_a_frame.get("efficiency", -1.0)), 0.5)

	# Unlink conduit A: the next tick recomputes had_valid_link
	# back to false -- the key tracks the live link, it is not
	# sticky.
	var unlinked_configured: Dictionary = item_bridge_build_state.source_item_bridge_configure_state(conduit_a_frame, -1, 28, 21)
	conduit_a_frame["link"] = int(unlinked_configured.get("link", -1))
	liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)
	conduit_a_frame = conduit_a.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	proof["live_tick_recomputes_had_valid_link"] = linked_tick and bool(conduit_a_frame.get("had_valid_link", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
