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

	# --- Super.updateTile payload update (N2471):
	# PayloadLoaderBuild.updateTile() calls
	# super.updateTile() (PayloadLoader.java:149),
	# which is PayloadBlockBuild.updateTile()
	# (PayloadBlock.java:158-162): `if(payload !=
	# null){` then `payload.update(null, this);`.
	# Payload.update is a default no-op
	# (Payload.java:42) and both overrides are
	# ENTITY behaviour (a live inner building /
	# unit) the port cannot model -- there is no
	# live payload entity -- so the N2231 advance
	# skips the call. N2471 ports it as a
	# pure-only CALL record (the N2396
	# precedent): source_payload_loader_payload_
	# update_state(payload) returns
	# {payload_update_call} -- null when the
	# payload is null, else {method:
	# "payload.update", unit_holder: null,
	# building_holder: "self", payload_kind}.
	# The Loader's payload is always a
	# BuildPayload (PayloadLoader.java:86), so a
	# kind-less dict -- the N2231 contract
	# carries no kind key -- records the build
	# call; a dict carrying kind "UnitPayload"
	# records the unit dispatch. The call is
	# unconditional on payload non-null:
	# BuildPayload.update's gate (`if(unitHolder
	# != null && ...)` , BuildPayload.java:53)
	# short-circuits with the Loader's null
	# unit holder. No tick wiring: the N2231
	# advance still skips the call.
	var storage_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": true, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var explicit_build_payload: Dictionary = {"kind": "BuildPayload", "block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": true, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var unit_payload: Dictionary = {"kind": "UnitPayload"}
	var unknown_kind_payload: Dictionary = {"kind": "SomethingElse"}

	# --- Update call build: a non-null build
	# payload records the payload.update call --
	# both the kind-less N2231-contract dict
	# (the Loader's payload is always a
	# BuildPayload, PayloadLoader.java:86) and
	# an explicit kind "BuildPayload" dict.
	var built: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state(storage_payload)
	var built_call: Dictionary = built.get("payload_update_call", {})
	var explicit_built: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state(explicit_build_payload)
	var explicit_built_call: Dictionary = explicit_built.get("payload_update_call", {})
	proof["update_call_build"] = str(built_call.get("method", "")) == "payload.update" and str(built_call.get("payload_kind", "")) == "BuildPayload" and str(explicit_built_call.get("method", "")) == "payload.update" and str(explicit_built_call.get("payload_kind", "")) == "BuildPayload"

	# --- Update call unit: a caller-supplied
	# dict carrying kind "UnitPayload" records
	# the same payload.update call with the unit
	# dispatch kind (the generic Payload.update
	# dispatch; UnitPayload.update delegates to
	# the unit type, UnitPayload.java:51-53).
	var united: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state(unit_payload)
	var united_call: Dictionary = united.get("payload_update_call", {})
	proof["update_call_unit"] = str(united_call.get("method", "")) == "payload.update" and str(united_call.get("payload_kind", "")) == "UnitPayload"

	# --- Update null: a null payload records no
	# call (the `if(payload != null){` gate,
	# PayloadBlock.java:159) -- and neither does
	# a non-Dictionary payload (the N2329
	# precedent: a non-Dict entry is not a
	# payload).
	var nulled: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state(null)
	var stringed: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state("not-a-payload")
	var numbered: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state(42)
	proof["update_null"] = nulled.get("payload_update_call", {}) == null and stringed.get("payload_update_call", {}) == null and numbered.get("payload_update_call", {}) == null

	# --- Update kind: the kind default is
	# "BuildPayload" (a kind-less dict records
	# the build call -- the Loader generic,
	# PayloadLoader.java:86); an explicit
	# "BuildPayload" stays build, an explicit
	# "UnitPayload" dispatches unit, and an
	# unknown kind string falls back to build
	# (only two Payload implementations exist
	# in Java: BuildPayload + UnitPayload).
	var unknowned: Dictionary = payload_loader_build_state.source_payload_loader_payload_update_state(unknown_kind_payload)
	var unknowned_call: Dictionary = unknowned.get("payload_update_call", {})
	proof["update_kind"] = str(built_call.get("payload_kind", "")) == "BuildPayload" and str(explicit_built_call.get("payload_kind", "")) == "BuildPayload" and str(united_call.get("payload_kind", "")) == "UnitPayload" and str(unknowned_call.get("payload_kind", "")) == "BuildPayload"

	# --- Update holders: the call records the
	# Java args exactly -- unit_holder null and
	# building_holder "self" (`payload.update(
	# null, this);`, PayloadBlock.java:160) --
	# for both the build and the unit dispatch.
	proof["update_holders"] = built_call.get("unit_holder", {}) == null and str(built_call.get("building_holder", "")) == "self" and united_call.get("unit_holder", {}) == null and str(united_call.get("building_holder", "")) == "self"

	# --- Update gate null holder: the call
	# ALWAYS runs for a non-null payload -- the
	# pure takes no gate inputs at all, because
	# BuildPayload.update's gate (`if(unitHolder
	# != null && ...)` , BuildPayload.java:53)
	# short-circuits with the Loader's null unit
	# holder, so no updateInUnits / rules input
	# could ever suppress it. A build payload
	# records the call with unit_holder null.
	proof["update_gate_null_holder"] = built.get("payload_update_call", {}) != null and built_call.get("unit_holder", {}) == null and str(built_call.get("method", "")) == "payload.update"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderSuperUpdateTileRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
