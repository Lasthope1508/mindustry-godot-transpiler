extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourcePayloadAmmoTurretBuildPortBridge.gd")
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

	# --- PayloadTurretBuild.write()+read() (N2376):
	# PayloadTurretBuild.write()+read()
	# (PayloadAmmoTurret.java:179-190) persists the payloads
	# seq on write (`payloads.write(write);`) and restores
	# it on read (`payloads.read(read);`), then drops every
	# held content whose type is not in ammoTypes
	# (`payloads.removeAll(u -> !ammoTypes.containsKey(u));`).
	# `super.write(write);` / `super.read(read, revision);`
	# are callee/context (TurretBuild.write/read, N2322).
	# The proof calls the pure function with synthetic
	# inputs (no live tick). NO driver tick line: pure
	# persistence functions.

	var ammo_types: Dictionary = {"copper": "copper-bullet", "lead": "lead-bullet", "titanium": "titanium-bullet"}

	# Write persists the payloads in order.
	var persisted: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state(["copper", "lead"], ["copper"], ammo_types)
	proof["write_persists_payloads"] = persisted.get("write_payload_contents", []) == ["copper", "lead"]

	# Write of empty persists empty.
	var persisted_empty: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state([], [], ammo_types)
	proof["write_empty_persists_empty"] = persisted_empty.get("write_payload_contents", ["not-empty"]).is_empty()

	# Read keeps contents whose type is in ammoTypes.
	var kept: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state([], ["copper", "lead"], ammo_types)
	proof["read_keeps_ammo_contents"] = kept.get("payload_contents", []) == ["copper", "lead"]

	# Read drops contents whose type is not in ammoTypes.
	var dropped: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state([], ["silicon", "graphite"], ammo_types)
	proof["read_removes_non_ammo_contents"] = dropped.get("payload_contents", ["not-empty"]).is_empty()

	# Mixed read filters correctly, keeping stored order.
	var mixed: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state([], ["silicon", "lead", "graphite", "copper"], ammo_types)
	proof["read_mixed_filters_correctly"] = mixed.get("payload_contents", []) == ["lead", "copper"]

	# Read of empty stays empty.
	var read_empty: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state(["copper"], [], ammo_types)
	proof["read_empty_stays_empty"] = read_empty.get("payload_contents", ["not-empty"]).is_empty()

	# Write then read round trips when every content is an
	# ammo type: the written contents survive the read.
	var written: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state(["titanium", "copper"], [], ammo_types)
	var round_tripped: Dictionary = bridge.source_payload_ammo_turret_build_write_read_state([], written.get("write_payload_contents", []), ammo_types)
	proof["write_then_read_round_trips"] = round_tripped.get("payload_contents", []) == ["titanium", "copper"]

	# Inputs are read, never written: all three inputs are
	# unchanged after the call.
	var payload_contents: Array = ["copper", "lead"]
	var stored_payload_contents: Array = ["silicon", "lead"]
	var ammo_types_before: Dictionary = ammo_types.duplicate()
	var payload_contents_before: Array = payload_contents.duplicate()
	var stored_payload_contents_before: Array = stored_payload_contents.duplicate()
	bridge.source_payload_ammo_turret_build_write_read_state(payload_contents, stored_payload_contents, ammo_types)
	proof["write_read_inputs_unmutated"] = payload_contents == payload_contents_before and stored_payload_contents == stored_payload_contents_before and ammo_types == ammo_types_before

	# The result carries EXACTLY the two keys.
	proof["write_read_returns_only_two_keys"] = persisted.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadTurretWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
