extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_loader_build_state := preload("res://src/game/SourcePayloadLoaderBuildState.gd")
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

	# --- Pure shouldConsume gate (N2208):
	# PayloadLoaderBuild overrides shouldConsume
	# (PayloadLoader.java:240, `public boolean shouldConsume(){`
	# with `return payload != null;`, PayloadLoader.java:241):
	# the payload-loader consumes only while it holds a
	# payload. The payload is the PayloadBlock field
	# (`public @Nullable T payload;`, PayloadBlock.java:92),
	# set by handlePayload (`this.payload = (T)payload;`,
	# PayloadBlock.java:122) and cleared by takePayload
	# (`payload = null;`, PayloadBlock.java:147). The gate
	# has NO `&& enabled` -- unlike the Separator/Drill
	# gates, Java returns the bare null check, so the pure
	# gate must NOT read enabled at all (the driver runs the
	# machinery only when enabled, so the live path still
	# respects disabled). The gate reads only null-ness, so
	# the proof injects a minimal Dictionary fixture as the
	# payload ({"block": "conveyor"} -- a test-only fixture,
	# NOT a real BuildPayload); no live fill sets
	# frame["payload"] yet (moveInPayload / handlePayload
	# fill waits for its own slice).
	var with_payload: Dictionary = payload_loader_build_state.source_payload_loader_should_consume_state({"payload": {"block": "conveyor"}})
	proof["gate_true_with_payload"] = bool(with_payload.get("should_consume", false)) and bool(with_payload.get("has_payload", false))

	var without_payload: Dictionary = payload_loader_build_state.source_payload_loader_should_consume_state({"payload": null})
	var missing_payload: Dictionary = payload_loader_build_state.source_payload_loader_should_consume_state({})
	proof["gate_false_without_payload"] = bool(without_payload.get("should_consume", true)) == false and bool(without_payload.get("has_payload", true)) == false and bool(missing_payload.get("should_consume", true)) == false

	# The gate ignores enabled entirely: a disabled loader
	# holding a payload still gates true, and a disabled
	# loader with no payload still gates false.
	var disabled_with: Dictionary = payload_loader_build_state.source_payload_loader_should_consume_state({"payload": {"block": "conveyor"}, "enabled": false})
	var disabled_without: Dictionary = payload_loader_build_state.source_payload_loader_should_consume_state({"payload": null, "enabled": false})
	proof["gate_ignores_enabled"] = bool(disabled_with.get("should_consume", false)) and bool(disabled_without.get("should_consume", true)) == false

	# --- Live tick: two payload-loaders placed live; the tick
	# driver is called directly (as the N2162 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. Loader A holds a payload at
	# half power: the N2162 fold is preserved (efficiency
	# 0.5). Loader B holds no payload at full power: the gate
	# is false, so updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992) -- the N2162 gap
	# (efficiency 1.0 vs Java 0.0) is closed.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	# The only payload-loader def (Blocks.java:6682-6689):
	# consumePower 2f, size 3; there is no
	# large-payload-loader.
	proof["def_payload_loader_consume_power_two_size_three"] = is_equal_approx(float(blocks_by_id["payload-loader"].properties.get("consumePower", -1.0)), 2.0) and int(blocks_by_id["payload-loader"].properties.get("size", -1)) == 3

	var loader_a_cell := Vector2i(28, 20)
	var loader_a := Sprite2D.new()
	game.add_child(loader_a)
	game.call("record_placed_block", loader_a, blocks_by_id["payload-loader"], loader_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the payload on it).
	payload_loader_build_state.source_payload_loader_bind_frame_state(loader_a, blocks_by_id["payload-loader"])
	var loader_a_frame: Dictionary = loader_a.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})

	var loader_b_cell := Vector2i(20, 10)
	var loader_b := Sprite2D.new()
	game.add_child(loader_b)
	game.call("record_placed_block", loader_b, blocks_by_id["payload-loader"], loader_b_cell)
	payload_loader_build_state.source_payload_loader_bind_frame_state(loader_b, blocks_by_id["payload-loader"])
	var loader_b_frame: Dictionary = loader_b.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})

	loader_a_frame["payload"] = {"block": "conveyor"}
	loader_a_frame["power_status"] = 0.5
	loader_b_frame["payload"] = null
	loader_b_frame["power_status"] = 1.0
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	loader_a_frame = loader_a.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	loader_b_frame = loader_b.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(loader_a_frame.get("efficiency", -1.0)), 0.5)
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(loader_b_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
