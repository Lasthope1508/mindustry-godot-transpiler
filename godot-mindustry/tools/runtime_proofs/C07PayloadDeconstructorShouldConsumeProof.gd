extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Pure shouldConsume gate (N2210):
	# PayloadDeconstructorBuild.shouldConsume()
	# (PayloadDeconstructor.java:219-221, `public boolean
	# shouldConsume(){` with `return deconstructing != null &&
	# enabled;`, PayloadDeconstructor.java:220) reads the
	# nullable field `public @Nullable Payload deconstructing;`
	# (PayloadDeconstructor.java:52), set by the updateTile
	# advance (`deconstructing = payload;`,
	# PayloadDeconstructor.java:199, when moveInPayload
	# succeeds, PayloadDeconstructor.java:197). The gate has an
	# `&& enabled` term -- unlike the PayloadLoader /
	# PayloadUnloader gate (`return payload != null;`,
	# PayloadLoader.java:240-242), which has none -- so a
	# disabled deconstructor with a payload in progress still
	# does not consume. The gate reads only the null-ness of
	# frame["deconstructing"], so the proof injects a minimal
	# Dictionary fixture as the deconstructing payload
	# (test-only: only null-ness is read, no real BuildPayload
	# is built).
	var deconstructing: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_should_consume_state({"deconstructing": {"block": "conveyor"}, "enabled": true})
	proof["gate_true_when_deconstructing_and_enabled"] = bool(deconstructing.get("should_consume", false)) and bool(deconstructing.get("deconstructing_present", false))

	var idle: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_should_consume_state({"deconstructing": null, "enabled": true})
	proof["gate_false_when_no_deconstructing"] = bool(idle.get("should_consume", true)) == false and bool(idle.get("deconstructing_present", true)) == false

	var disabled: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_should_consume_state({"deconstructing": {"block": "conveyor"}, "enabled": false})
	proof["gate_false_when_disabled"] = bool(disabled.get("should_consume", true)) == false and bool(disabled.get("deconstructing_present", false))

	# --- Live tick: the payload-deconstructor is a PayloadDeconstructor build
	# with a power consumer (consumePower 3f), placed live; the
	# tick driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2200 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The payload-deconstructor tick
	# models no other consumers, so with a power consumer the
	# first pass holds only the power row; when the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var payload_deconstructor_cell := Vector2i(28, 21)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the deconstructing payload on it).
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})

	# A freshly bound frame carries the deconstructing key at
	# its Java default null (the field is nullable,
	# PayloadDeconstructor.java:52).
	proof["frame_key_default_null"] = payload_deconstructor_frame.has("deconstructing") and payload_deconstructor_frame.get("deconstructing") == null

	# Idle (no deconstructing payload): gate false -> efficiency
	# 0 even at half power.
	payload_deconstructor_frame["deconstructing"] = null
	payload_deconstructor_frame["power_status"] = 0.5
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.0)

	# Deconstructing: gate true -> efficiency folds the power
	# min 0.5 (the N2166 power fold preserved).
	payload_deconstructor_frame["deconstructing"] = {"block": "conveyor"}
	payload_deconstructor_frame["power_status"] = 0.5
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
