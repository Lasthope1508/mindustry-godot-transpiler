extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
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

	# --- Pure gate (N2209): PayloadUnloaderBuild does NOT
	# override shouldConsume (PayloadUnloader.java has no
	# shouldConsume at all; PayloadUnloader extends
	# PayloadLoader, PayloadUnloader.java:8, and
	# PayloadUnloaderBuild extends PayloadLoaderBuild,
	# PayloadUnloader.java:32), so it inherits
	# PayloadLoaderBuild.shouldConsume verbatim
	# (PayloadLoader.java:240, `public boolean
	# shouldConsume(){` with `return payload != null;`,
	# PayloadLoader.java:241) -- and unlike the
	# Separator/Drill gates this one has NO `&& enabled`:
	# Java returns the bare payload null check, so the pure
	# gate must NOT read enabled at all. The payload is the
	# PayloadBlockBuild field (`public @Nullable T payload;`,
	# PayloadBlock.java:92), default null. The gate reads
	# ONLY the null-ness of the frame payload key, so the
	# proof injects a minimal Dictionary fixture
	# ({"block": "conveyor"}) as the payload -- a
	# test-only stand-in, NOT a real BuildPayload; no live
	# fill sets the frame payload yet (the moveInPayload /
	# handlePayload / takePayload advance waits for its own
	# slice).
	var with_payload_gate: Dictionary = payload_unloader_build_state.source_payload_unloader_should_consume_state({"payload": {"block": "conveyor"}})
	proof["gate_true_with_payload"] = bool(with_payload_gate.get("should_consume", false)) and bool(with_payload_gate.get("has_payload", false))

	var null_payload_gate: Dictionary = payload_unloader_build_state.source_payload_unloader_should_consume_state({"payload": null})
	var missing_payload_gate: Dictionary = payload_unloader_build_state.source_payload_unloader_should_consume_state({})
	proof["gate_false_without_payload"] = bool(null_payload_gate.get("should_consume", true)) == false and bool(null_payload_gate.get("has_payload", true)) == false and bool(missing_payload_gate.get("should_consume", true)) == false and bool(missing_payload_gate.get("has_payload", true)) == false

	# The gate ignores enabled entirely: a disabled
	# payload-unloader holding a payload still gates true,
	# and a disabled payload-unloader holding nothing still
	# gates false -- the pure gate has no enabled term (the
	# driver runs the machinery only when enabled, so the
	# live path still respects disabled).
	var disabled_with_gate: Dictionary = payload_unloader_build_state.source_payload_unloader_should_consume_state({"payload": {"block": "conveyor"}, "enabled": false})
	var disabled_without_gate: Dictionary = payload_unloader_build_state.source_payload_unloader_should_consume_state({"payload": null, "enabled": false})
	proof["gate_ignores_enabled"] = bool(disabled_with_gate.get("should_consume", false)) and bool(disabled_without_gate.get("should_consume", true)) == false

	# --- Live tick: two payload-unloaders placed live; the
	# tick driver is called directly (as the N2163 proof
	# does), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# Unloader A (holding a payload, half power) keeps the
	# N2163 fold: efficiency folds the power min 0.5.
	# Unloader B (holding nothing, full power) folds
	# efficiency 0 -- the N2163 gap (efficiency 1.0 vs Java
	# 0.0) is closed. The payload is injected directly into
	# A's frame (the Separator items precedent: no live
	# intake fills the frame key yet).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["def_payload_unloader_consume_power_two_size_three"] = is_equal_approx(float(blocks_by_id["payload-unloader"].properties.get("consumePower", -1.0)), 2.0) and int(blocks_by_id["payload-unloader"].properties.get("size", -1)) == 3

	var unloader_a_cell := Vector2i(28, 20)
	var unloader_a := Sprite2D.new()
	game.add_child(unloader_a)
	game.call("record_placed_block", unloader_a, blocks_by_id["payload-unloader"], unloader_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader_a, blocks_by_id["payload-unloader"])
	var unloader_a_frame: Dictionary = unloader_a.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	var unloader_b_cell := Vector2i(20, 10)
	var unloader_b := Sprite2D.new()
	game.add_child(unloader_b)
	game.call("record_placed_block", unloader_b, blocks_by_id["payload-unloader"], unloader_b_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader_b, blocks_by_id["payload-unloader"])
	var unloader_b_frame: Dictionary = unloader_b.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	# The live updateTile path consumes a block/build descriptor, as in
	# C07PayloadUnloaderUpdateTileProof, rather than a block ID string.
	unloader_a_frame["payload"] = {"block": {"has_items": true, "has_liquids": false}, "build": {"items": {"copper": 1}}}
	unloader_a_frame["power_status"] = 0.5
	unloader_b_frame["power_status"] = 1.0
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_a_frame = unloader_a.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	unloader_b_frame = unloader_b.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(unloader_a_frame.get("efficiency", -1.0)), 0.5)
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(unloader_b_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
