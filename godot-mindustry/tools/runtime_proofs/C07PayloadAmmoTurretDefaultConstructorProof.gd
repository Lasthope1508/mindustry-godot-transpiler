extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_ammo_turret_build := preload("res://src/game/SourcePayloadAmmoTurretBuildPortBridge.gd")
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

	# --- PayloadAmmoTurret(String name) (N2416):
	# PayloadAmmoTurret(String name)
	# (PayloadAmmoTurret.java:26-33). One ctor slice
	# (batch 30 slot 3): the 1 distinguishing field
	# default only. `super(name);` is N2185-owned and
	# `acceptsPayload = true;` is N2168-owned -- neither
	# is re-registered here. The proof calls the pure
	# function with synthetic inputs (no live tick, no
	# render): one call returns the ctor default, writes
	# it into the def frame, preserves unrelated frame
	# keys, overwrites a stale frame value, and is
	# idempotent on a second call. `maxAmmo` overrides
	# the Turret base default 30 (Turret.java:47) with
	# 3; the payload ammo turret holds at most 3 payload
	# ammo at once. The default is frame data only; no
	# Draw is ported.

	# One call returns the ctor default, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = payload_ammo_turret_build.source_payload_ammo_turret_default_constructor_state(fresh, 3)
	proof["ctor_defaults_max_ammo"] = result.get("max_ammo", -1) == 3
	proof["ctor_returns_only_two_keys"] = result.size() == 2

	# The call writes the default into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("payload_ammo_turret_defaults", {}) as Dictionary) == fresh and fresh.get("max_ammo", -1) == 3

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "afflict", "range": 210.0}
	var kept_result: Dictionary = payload_ammo_turret_build.source_payload_ammo_turret_default_constructor_state(kept, 3)
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "afflict" and kept.get("range", 0.0) == 210.0 and kept_result.get("max_ammo", -1) == 3

	# A stale frame value is overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"max_ammo": 30}
	var stale_result: Dictionary = payload_ammo_turret_build.source_payload_ammo_turret_default_constructor_state(stale, 3)
	proof["ctor_overwrites_stale_frame_values"] = stale.get("max_ammo", -1) == 3 and stale_result.get("max_ammo", -1) == 3

	# A different int passes through unchanged: the value
	# is not hardcoded to 3 in the function.
	var other: Dictionary = payload_ammo_turret_build.source_payload_ammo_turret_default_constructor_state({}, 5)
	proof["ctor_max_ammo_passthrough"] = result.get("max_ammo", -1) == 3 and other.get("max_ammo", -1) == 5

	# A second call on the same frame yields the same
	# value: the ctor is idempotent.
	var second: Dictionary = payload_ammo_turret_build.source_payload_ammo_turret_default_constructor_state(fresh, 3)
	proof["ctor_idempotent_second_call"] = second.get("max_ammo", -1) == 3 and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadAmmoTurretDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
