extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_mass_driver_build_state := preload("res://src/game/SourcePayloadMassDriverBuildState.gd")
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

	# --- Super.updateTile payload update (N2488):
	# PayloadDriverBuild.updateTile() calls
	# super.updateTile() (PayloadMassDriver.java:156),
	# which is PayloadBlockBuild.updateTile()
	# (PayloadBlock.java:158-162): `if(payload !=
	# null){` then `payload.update(null, this);`.
	# Payload.update is a default no-op
	# (Payload.java:42) and both overrides are
	# ENTITY behaviour (a live inner building /
	# unit) the port cannot model -- there is no
	# live payload entity -- so the N2245 advance
	# notes the call and advances only the driver
	# frame. N2488 ports it as a pure-only CALL
	# record (the N2471 Loader precedent, the
	# N2396 record-the-call precedent):
	# source_payload_mass_driver_payload_
	# update_state(payload) returns
	# {payload_update_call} -- null when the
	# payload is null, else {method:
	# "payload.update", unit_holder: null,
	# building_holder: "self", payload_kind}.
	# Verify-first: the PMD generic is
	# PayloadBlockBuild<Payload>
	# (PayloadMassDriver.java:132), NOT
	# BuildPayload -- BOTH kinds are genuinely
	# possible in Java, so the "BuildPayload"
	# default for a kind-less dict is the N2471
	# port convention, not a Java-exact generic
	# default. The PMD payload contract carries
	# no kind key (it carries "size" in world
	# units, the N2245 advance); a dict
	# carrying kind "UnitPayload" records the
	# unit dispatch. The call is unconditional
	# on payload non-null:
	# BuildPayload.update's gate (`if(unitHolder
	# != null && ...)` , BuildPayload.java:53)
	# short-circuits with the PMD's null unit
	# holder. No tick wiring: the N2245 advance
	# still skips the call.
	var kindless_payload: Dictionary = {}
	var explicit_build_payload: Dictionary = {"kind": "BuildPayload", "size": 24.0}
	var unit_payload: Dictionary = {"kind": "UnitPayload"}
	var unknown_kind_payload: Dictionary = {"kind": "SomethingElse"}
	var live_payload: Dictionary = {"size": 24.0}

	# --- Update call build: a non-null build
	# payload records the payload.update call --
	# both the kind-less dict (the N2471 port
	# convention: no kind key -> the build call)
	# and an explicit kind "BuildPayload" dict.
	var built: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(kindless_payload)
	var built_call: Dictionary = built.get("payload_update_call", {})
	var explicit_built: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(explicit_build_payload)
	var explicit_built_call: Dictionary = explicit_built.get("payload_update_call", {})
	proof["update_call_build"] = str(built_call.get("method", "")) == "payload.update" and str(built_call.get("payload_kind", "")) == "BuildPayload" and str(explicit_built_call.get("method", "")) == "payload.update" and str(explicit_built_call.get("payload_kind", "")) == "BuildPayload"

	# --- Update call unit: a caller-supplied
	# dict carrying kind "UnitPayload" records
	# the same payload.update call with the unit
	# dispatch kind (the generic Payload.update
	# dispatch; UnitPayload.update delegates to
	# the unit type, UnitPayload.java:51-53).
	var united: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(unit_payload)
	var united_call: Dictionary = united.get("payload_update_call", {})
	proof["update_call_unit"] = str(united_call.get("method", "")) == "payload.update" and str(united_call.get("payload_kind", "")) == "UnitPayload"

	# --- Update null: a null payload records no
	# call (the `if(payload != null){` gate,
	# PayloadBlock.java:159) -- and neither does
	# a non-Dictionary payload (the N2329
	# precedent: a non-Dict entry is not a
	# payload).
	var nulled: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(null)
	var stringed: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state("not-a-payload")
	var numbered: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(42)
	proof["update_null"] = nulled.get("payload_update_call", {}) == null and stringed.get("payload_update_call", {}) == null and numbered.get("payload_update_call", {}) == null

	# --- Update kind: the kind default is
	# "BuildPayload" (a kind-less dict records
	# the build call -- the N2471 port
	# convention, NOT a Java-exact generic
	# default: the PMD generic is
	# PayloadBlockBuild<Payload>,
	# PayloadMassDriver.java:132); an explicit
	# "BuildPayload" stays build, an explicit
	# "UnitPayload" dispatches unit, and an
	# unknown kind string falls back to build
	# (only two Payload implementations exist
	# in Java: BuildPayload + UnitPayload).
	var unknowned: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(unknown_kind_payload)
	var unknowned_call: Dictionary = unknowned.get("payload_update_call", {})
	proof["update_kind"] = str(built_call.get("payload_kind", "")) == "BuildPayload" and str(explicit_built_call.get("payload_kind", "")) == "BuildPayload" and str(united_call.get("payload_kind", "")) == "UnitPayload" and str(unknowned_call.get("payload_kind", "")) == "BuildPayload"

	# --- Update holders: the call records the
	# Java args exactly -- unit_holder null and
	# building_holder "self" (`payload.update(
	# null, this);`, PayloadBlock.java:160) --
	# for both the build and the unit dispatch.
	proof["update_holders"] = built_call.get("unit_holder", {}) == null and str(built_call.get("building_holder", "")) == "self" and united_call.get("unit_holder", {}) == null and str(united_call.get("building_holder", "")) == "self"

	# --- Update live input: the pure accepts
	# the payload exactly as a live PMD frame
	# carries it -- {"size": 24.0}, the N2245
	# payload contract (payload.size() in world
	# units, the targetSize input; no kind key)
	# -- and records the full build call (method
	# + holders + kind). The call ALWAYS runs
	# for a non-null payload: the pure takes no
	# gate inputs at all, because
	# BuildPayload.update's gate (`if(unitHolder
	# != null && ...)` , BuildPayload.java:53)
	# short-circuits with the PMD's null unit
	# holder.
	var lived: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_payload_update_state(live_payload)
	var lived_call: Dictionary = lived.get("payload_update_call", {})
	proof["update_live_input"] = lived.get("payload_update_call", {}) != null and str(lived_call.get("method", "")) == "payload.update" and lived_call.get("unit_holder", {}) == null and str(lived_call.get("building_holder", "")) == "self" and str(lived_call.get("payload_kind", "")) == "BuildPayload"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverSuperUpdateTileRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
